import 'dart:math' as math;

import '../combat/combat_state.dart';
import '../model/card_def.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/event_def.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../model/meta_bonus.dart';
import '../model/talisman_def.dart';
import '../rng.dart';
import 'ascent.dart';
import 'feats.dart';
import 'ghost.dart';
import 'legacy.dart';
import 'map_gen.dart';
import 'run_state.dart';

/// Reglas de la run: mapa, recompensas, santuario, eventos, talismanes,
/// mercader, maestro errante y fuente de meditación.
class RunEngine {
  RunEngine(this.data);

  final GameData data;

  /// La run empieza como novicio; el camino se elige en el santuario.
  /// [meta]: los dones de la escuela (reinos y meridianos).
  RunState newRun({
    required int seed,
    Difficulty difficulty = Difficulty.normal,
    int pico = 0,
    List<String> locked = const [],
    MetaBonus meta = MetaBonus.none,
    Ghost? ghost,
    Legacy? legacy,
  }) {
    final starter = data.starterDeck;
    final hp = data.balance.difficulty(difficulty).playerHp +
        data.balance.picoMods(pico).playerHp +
        meta.maxHp;
    // El mapa sale de la misma semilla: la subida entera es reproducible.
    final fixed = data.balance.fixedMap;
    final (map, rng) = fixed != null
        ? (fixed, Rng.seeded(seed))
        : _stageMap(0, Rng.seeded(seed));
    var r = RunState(
      difficulty: difficulty,
      pico: pico,
      style: null,
      hp: hp,
      maxHp: hp,
      deck: [
        for (var i = 0; i < starter.length; i++)
          CombatCard(uid: i, cardId: starter[i]),
      ],
      nextUid: starter.length,
      phase: RunPhase.map,
      currentNode: null,
      visited: const [],
      rewardOptions: const [],
      rng: rng,
      map: map,
      locked: locked,
      meta: meta,
      jade: meta.startJade,
      rerollsLeft: meta.rerolls,
      ghost: ghost,
    );
    if (meta.upgradedStarters > 0) {
      final (pool, rng2) =
          r.rng.shuffle([for (final c in r.deck) if (canUpgrade(c)) c.uid]);
      r = r.copyWith(rng: rng2);
      for (final uid in pool.take(meta.upgradedStarters)) {
        r = _upgrade(r, uid);
      }
    }
    if (meta.startTalisman > 0) {
      // Un talismán a elección antes del primer nodo.
      final (shuffled, rng3) = r.rng.shuffle(missingTalismans(r, rare: false));
      final options = shuffled.take(data.balance.talismanChoices).toList();
      if (options.isNotEmpty) {
        r = r.copyWith(
          phase: RunPhase.talisman,
          talismanOptions: options,
          rng: rng3,
        );
      }
    }
    // La herencia va primero; el don de la escuela queda esperando.
    if (legacy != null) {
      r = r.copyWith(phase: RunPhase.legacy, legacy: legacy);
    }
    return r;
  }

  /// El legado del discípulo de [last] (la subida anterior, ganada o
  /// perdida), o null si no hubo ninguna.
  Legacy? legacyOf(Ascent? last) {
    final def = data.balance.legacy;
    if (last == null || !def.enabled) return null;
    final far = last.stage >= def.hpStage;
    return Legacy(
      n: last.n,
      card: data.cards.containsKey(last.keepsake) ? last.keepsake : null,
      upgrades: last.keepsakeUp * def.upgradePct ~/ 100,
      maxHp: far ? def.maxHp : 0,
      jade: far ? 0 : def.jade,
    );
  }

  /// Tomar la herencia: la carta entra al mazo o se suman los números.
  /// Después, el talismán de los meridianos si había, o el mapa.
  RunState chooseLegacy(RunState r, LegacyPick pick) {
    final l = r.legacy;
    if (r.phase != RunPhase.legacy || l == null) {
      throw StateError('No hay legado');
    }
    final next = r.talismanOptions.isEmpty ? RunPhase.map : RunPhase.talisman;
    return switch (pick) {
      LegacyPick.card when l.card != null => r.copyWith(
          deck: [
            ...r.deck,
            CombatCard(uid: r.nextUid, cardId: l.card!, upgrades: l.upgrades),
          ],
          nextUid: r.nextUid + 1,
          phase: next,
        ),
      LegacyPick.card => throw StateError('El legado no trae carta'),
      LegacyPick.stat => r.copyWith(
          maxHp: r.maxHp + l.maxHp,
          hp: r.hp + l.maxHp,
          jade: r.jade + l.jade,
          phase: next,
        ),
    };
  }

  (List<MapNodeDef>, Rng) _stageMap(int stage, Rng rng) {
    final st = data.balance.stages[stage];
    return generateMap(
      st.floors,
      rng,
      scenes: st.scenes,
      lights: st.lights,
      packable: packable,
      passFights: data.balance.passFights,
    );
  }

  /// Puede ir en grupo: los comunes que no se escapan.
  bool packable(String id) {
    final e = data.enemy(id);
    return e.rank == EnemyRank.common &&
        !e.phases.any((p) => p.pattern.any((i) => i.kind == IntentKind.flee));
  }

  /// Etapa que recorre la run.
  StageDef stageOf(RunState r) => data.balance.stages[r.stage];

  /// La run está en la última etapa: su jefe es la cumbre.
  bool isLastStage(RunState r) => r.stage >= data.balance.stages.length - 1;

  /// El nodo actual es el jefe de la etapa (no tiene nada después).
  bool _atStageBoss(RunState r) =>
      r.currentNode != null && r.node(r.currentNode!).next.isEmpty;

  /// Después de la recompensa: al mapa, o al descanso si se venció al jefe
  /// de una etapa intermedia.
  RunPhase _afterReward(RunState r) =>
      _atStageBoss(r) && !isLastStage(r) ? RunPhase.stageClear : RunPhase.map;

  /// Termina la recompensa: al mapa, o al descanso de la etapa vencida, donde
  /// el camino ofrece sus despertares.
  RunState _leaveReward(RunState r) {
    if (_passGoesOn(r)) return r.copyWith(phase: RunPhase.passChoice);
    final phase = _afterReward(r);
    if (phase == RunPhase.map && _merchantDue(r)) return _wanderingMerchant(r);
    if (phase != RunPhase.stageClear) return r.copyWith(phase: phase);
    final (options, rng) = _rollAwakenings(r);
    return r.copyWith(phase: phase, awakeningOptions: options, rng: rng);
  }

  /// Toca el mercader ambulante: se ganaron sus combates, o se venció al
  /// élite y en la etapa todavía no hubo ninguno. Nunca después del jefe.
  bool _merchantDue(RunState r) {
    final every = data.balance.merchantEvery;
    if (every <= 0 || r.currentNode == null || _atStageBoss(r)) return false;
    if (r.node(r.currentNode!).type != NodeType.combat) return false;
    final due = r.nextMerchantAt > 0 ? r.nextMerchantAt : every;
    if (r.combatsSinceMerchant >= due) return true;
    return r.stageMerchants == 0 &&
        data.enemy(enemyOf(r)).rank == EnemyRank.elite;
  }

  /// Un mercader en el camino: la tienda se abre sin nodo propio y, al
  /// salir, se vuelve al mapa.
  RunState _wanderingMerchant(RunState r) {
    final b = data.balance;
    final (roll, rng) = r.rng.nextInt(b.merchantSpread * 2 + 1);
    return _rollShop(
      r.copyWith(
        phase: RunPhase.merchant,
        combatsSinceMerchant: 0,
        nextMerchantAt: math.max(1, b.merchantEvery - b.merchantSpread + roll),
        stageMerchants: r.stageMerchants + 1,
        rng: rng,
      ),
    );
  }

  /// El mercader actual está en el camino (no es un nodo del mapa).
  bool isWanderingMerchant(RunState r) =>
      r.phase == RunPhase.merchant &&
      (r.currentNode == null ||
          r.node(r.currentNode!).type != NodeType.merchant);

  /// Despertares del camino que la run todavía no aprendió.
  List<String> missingAwakenings(RunState r) => [
        for (final a in data.balance.statsOf(r.style).awakenings)
          if (!r.awakenings.contains(a.id)) a.id,
      ];

  (List<String>, Rng) _rollAwakenings(RunState r) {
    final (shuffled, rng) = r.rng.shuffle(missingAwakenings(r));
    return (shuffled.take(data.balance.awakeningChoices).toList(), rng);
  }

  /// Vida que se recupera al pasar a la etapa siguiente.
  int stageHealOf(RunState r) =>
      ((r.maxHp - r.hp) * data.balance.stageHeal / 100).round();

  /// Subir a la etapa siguiente: cura, mapa nuevo y se empieza desde abajo.
  /// Si el camino ofreció despertares, hay que elegir uno ([awakening]).
  RunState advanceStage(RunState r, {String? awakening}) {
    if (r.phase != RunPhase.stageClear) throw StateError('No hay etapa vencida');
    if (awakening != null
        ? !r.awakeningOptions.contains(awakening)
        : r.awakeningOptions.isNotEmpty) {
      throw StateError('Despertar no ofrecido: $awakening');
    }
    final (map, rng) = _stageMap(r.stage + 1, r.rng);
    return r.copyWith(
      awakenings: [...r.awakenings, ?awakening],
      awakeningOptions: const [],
      stage: r.stage + 1,
      stageMerchants: 0,
      stageWins: 0,
      stageJade: 0,
      stageLotus: 0,
      hp: r.hp + stageHealOf(r),
      map: map,
      rng: rng,
      visited: const [],
      clearCurrentNode: true,
      phase: RunPhase.map,
    );
  }

  /// Menú de pruebas: una subida nueva que arranca en la etapa [stage]
  /// (0 = la primera) con el piso [floor] (1 = el primero) por delante. El
  /// camino ya elegido ([style]) y los pisos de abajo, recorridos.
  RunState debugStart({
    required int seed,
    required int stage,
    required int floor,
    Difficulty difficulty = Difficulty.normal,
    int pico = 0,
    Style style = Style.tiger,
    MetaBonus meta = MetaBonus.none,
    Ghost? ghost,
    String? weapon,
    int weaponLevel = 1,
  }) {
    var r = newRun(
      seed: seed,
      difficulty: difficulty,
      pico: pico,
      meta: meta,
      ghost: ghost,
    ).copyWith(style: style, jade: 150);
    if (weapon != null) r = equipWeapon(r, weapon, level: weaponLevel);
    final last = data.balance.stages.length - 1;
    for (var s = 0; s < stage.clamp(0, last); s++) {
      r = advanceStage(r.copyWith(phase: RunPhase.stageClear));
    }
    // Recorre un camino real hasta el piso anterior al pedido.
    final path = <String>[];
    var next = r.starts;
    for (var f = 1; f < floor && next.isNotEmpty; f++) {
      path.add(next.first);
      next = r.node(next.first).next;
    }
    return r.copyWith(
      visited: path,
      currentNode: path.isEmpty ? null : path.last,
      clearCurrentNode: path.isEmpty,
      phase: RunPhase.map,
    );
  }

  /// Nodos a los que se puede avanzar desde la posición actual.
  List<String> available(RunState r) {
    if (r.phase != RunPhase.map) return const [];
    final current = r.currentNode;
    return current == null ? r.starts : r.node(current).next;
  }

  /// Un combate a medias (se cerró la app o el jugador salió) se retoma
  /// desde el mapa, como si todavía no se hubiera entrado a ese nodo.
  RunState retreat(RunState r) {
    if (r.phase != RunPhase.combat) return r;
    // Un duelo a medias vuelve a la escena del evento.
    if (r.duel != null) {
      return r.copyWith(
        phase: RunPhase.event,
        eventId: r.lastEvent!.eventId,
        clearDuel: true,
      );
    }
    final visited = r.visited.sublist(0, r.visited.length - 1);
    return r.copyWith(
      phase: RunPhase.map,
      visited: visited,
      currentNode: visited.isEmpty ? null : visited.last,
      clearCurrentNode: visited.isEmpty,
    );
  }

  RunState enter(RunState r, String nodeId) {
    if (!available(r).contains(nodeId)) {
      throw StateError('Nodo no disponible: $nodeId');
    }
    final n = r.node(nodeId);
    final entered = r.copyWith(
      currentNode: nodeId,
      visited: [...r.visited, nodeId],
      passStep: 0,
      phase: switch (n.type) {
        NodeType.combat || NodeType.pass => RunPhase.combat,
        NodeType.fountain => RunPhase.fountain,
        NodeType.shrine => RunPhase.shrine,
        NodeType.event => RunPhase.event,
        NodeType.merchant => RunPhase.merchant,
        NodeType.master => RunPhase.master,
      },
    );
    if (n.type == NodeType.event) return _rollEvent(entered);
    if (n.type == NodeType.merchant) {
      // Mapas guardados antes del mercader ambulante: cuenta como uno.
      return _rollShop(
        entered.copyWith(
          combatsSinceMerchant: 0,
          stageMerchants: entered.stageMerchants + 1,
        ),
      );
    }
    if (n.type == NodeType.master) return _rollMaster(entered);
    if (n.type != NodeType.shrine) return entered;
    final (shuffled, rng) = entered.rng.shuffle([
      for (final s in Style.values)
        if (!entered.locked.contains(s.name)) s,
    ]);
    return entered.copyWith(
      pathOptions: shuffled.take(data.balance.pathChoices).toList(),
      rng: rng,
    );
  }

  /// Tomar uno de los caminos que ofrece el santuario.
  RunState choosePath(RunState r, Style style) {
    if (r.phase != RunPhase.shrine) throw StateError('No estás en el santuario');
    if (!r.pathOptions.contains(style)) {
      throw StateError('Camino no ofrecido: ${style.name}');
    }
    return r.copyWith(style: style, pathOptions: const [], phase: RunPhase.map);
  }

  /// Semilla del combate del nodo actual (derivada de la run, reproducible).
  (int, RunState) combatSeed(RunState r) {
    final (seed, rng) = r.rng.nextInt(0x7FFFFFFF);
    return (seed, r.copyWith(rng: rng));
  }

  String enemyOf(RunState r) => r.duel ?? packOf(r).first;

  /// Enemigos del combate actual, en el orden en que entran.
  List<String> packOf(RunState r) {
    if (r.duel != null) return [r.duel!];
    final n = r.node(r.currentNode!);
    if (n.type == NodeType.pass) return [passChain(n)[r.passStep]];
    return [n.enemy!, ...n.waves];
  }

  /// Si el grupo del combate actual pelea todo junto (no en oleadas).
  bool togetherOf(RunState r) =>
      r.duel == null &&
      r.node(r.currentNode!).type != NodeType.pass &&
      r.node(r.currentNode!).together;

  // ------------------------------------------------------------------ paso

  /// Los rivales de un paso de montaña, en el orden en que se enfrentan.
  List<String> passChain(MapNodeDef n) => [n.enemy!, ...n.waves];

  /// Se está en un paso y el combate actual es el último de la cadena.
  bool _passEnd(RunState r) {
    if (r.duel != null || r.currentNode == null) return false;
    final n = r.node(r.currentNode!);
    return n.type == NodeType.pass && r.passStep >= passChain(n).length - 1;
  }

  /// En un paso y todavía quedan combates después del actual.
  bool _passGoesOn(RunState r) {
    if (r.currentNode == null) return false;
    final n = r.node(r.currentNode!);
    return n.type == NodeType.pass && r.passStep < passChain(n).length - 1;
  }

  /// Jade de más del combate actual del paso: crece con cada uno vencido.
  int passBonus(RunState r, [int? step]) => data.balance.passJade * (step ?? r.passStep);

  /// Seguir por el paso: el próximo combate, sin curar.
  RunState passContinue(RunState r) {
    if (r.phase != RunPhase.passChoice) throw StateError('No estás en un paso');
    return r.copyWith(phase: RunPhase.combat, passStep: r.passStep + 1);
  }

  /// Volver al mapa con lo ganado en el paso.
  RunState passRetreat(RunState r) {
    if (r.phase != RunPhase.passChoice) throw StateError('No estás en un paso');
    return r.copyWith(phase: RunPhase.map, passStep: 0);
  }

  /// [fledWith]: si el enemigo se escapó, el jade que se llevó (null si
  /// lo venciste). Escapado no deja jade ni loto. [tally]: lo que pasó en
  /// el combate para los hitos (formas y desvíos).
  RunState finishCombat(
    RunState r, {
    required bool won,
    required int hp,
    int? fledWith,
    Map<String, int> tally = const {},
  }) {
    final boss = _atStageBoss(r);
    final elite = !boss && data.enemy(packOf(r).first).rank == EnemyRank.elite;
    final passEnd = _passEnd(r);
    final fled = fledWith != null;
    final beaten = won && !fled;
    final flawless = beaten && hp >= r.hp;
    r = r.copyWith(
      feats: addFeats(r.feats, {
        ...tally,
        if (flawless) Feat.flawless: 1,
        if (flawless && boss) Feat.flawlessBoss: 1,
        if (beaten && (boss || elite)) Feat.beat(enemyOf(r)): 1,
      }),
    );
    if (!won) return r.copyWith(hp: 0, phase: RunPhase.defeat);
    final b = data.balance;
    final lotus = b.meridians.lotus;
    final lotusBase = fled
        ? 0
        : lotus.perCombat +
            (elite ? lotus.elite : 0) +
            (boss ? lotus.boss : 0);
    if (boss && isLastStage(r)) {
      final gained = lotusOf(r, lotusBase + lotus.victory);
      return r.copyWith(
        hp: hp,
        phase: RunPhase.victory,
        lotus: r.lotus + gained,
        lotusGained: gained,
      );
    }
    if (boss) {
      // Jefe de una etapa intermedia: jade para la etapa que viene.
      r = r.copyWith(jade: r.jade + b.stageJade, jadeGained: b.stageJade);
    } else if (fled) {
      final lost = math.min(r.jade, fledWith);
      r = r.copyWith(jade: r.jade - lost, jadeGained: -lost);
    } else {
      final (rolled, rngJ) = _rollJade(r);
      // Cada enemigo de más en el grupo suma jade.
      final jade = rolled +
          b.packJade * (packOf(r).length - 1) +
          passBonus(r) +
          talismanSum(r, (e) => e.winJade);
      r = r.copyWith(jade: r.jade + jade, jadeGained: jade, rng: rngJ);
    }
    final gained = lotusOf(r, lotusBase);
    r = r.copyWith(
      combatsSinceMerchant: r.combatsSinceMerchant + 1,
      lotus: r.lotus + gained,
      lotusGained: gained,
      stageWins: r.stageWins + 1,
      stageJade: r.stageJade + math.max(0, r.jadeGained),
      stageLotus: r.stageLotus + gained,
    );
    final healed = math.min(
      r.maxHp,
      hp + talismanSum(r, (e) => e.winHeal) + r.meta.winHeal,
    );
    r = _ghostDrop(r.copyWith(hp: healed));
    // El élite, el jefe y el rival de un duelo dejan elegir un talismán
    // antes del premio (el duelo, con el del camino entre ellos).
    // La pelea de una emboscada paga como un combate común.
    final ambush = r.duel != null &&
        r.lastEvent != null &&
        data.event(r.lastEvent!.eventId).ambush;
    final duel = r.duel != null && !ambush;
    // El último del paso también: es el premio por llegar hasta el final.
    final (talismans, rngT) = elite || boss || passEnd || (duel && !fled)
        ? _rollTalismans(
            r.rng,
            r,
            b.talismanChoices + r.meta.talismanChoices,
            boss: boss,
            path: duel,
          )
        : (const <String>[], r.rng);
    r = r.copyWith(rng: rngT, clearDuel: true);
    // El jefe deja cartas; el que se escapó, también (no hay otro premio).
    // El primer élite sin arma la garantiza.
    final (kind, rngK) = boss || fled
        ? (RewardKind.cards, r.rng)
        : elite && r.weapon == null && data.weapons.isNotEmpty
        ? (RewardKind.weapon, r.rng)
        : _rollRewardKind(r, allowTalisman: !elite && !duel && !passEnd);
    return _offer(r.copyWith(rng: rngK), kind).copyWith(
      phase: talismans.isEmpty ? RunPhase.reward : RunPhase.talisman,
      talismanOptions: kind == RewardKind.talisman ? null : talismans,
      cardlessStreak: kind == RewardKind.cards ? 0 : r.cardlessStreak + 1,
    );
  }

  /// Los contadores de la subida al terminar, con lo que se llevaba:
  /// despertares y talismanes (para los hitos).
  Map<String, int> finalFeats(RunState r) => {
    ...r.feats,
    for (final a in r.awakenings) Feat.awakening(a): 1,
    for (final t in r.talismans) Feat.talisman(t): 1,
    Feat.talismans: r.talismans.length,
    if (r.talismans.any((t) => data.talisman(t).tier == TalismanTier.boss))
      Feat.bossTalisman: 1,
  };

  /// Vencido el Discípulo Perdido, suelta la carta del caído que lo
  /// llevaba (una sola vez por subida). Si su registro no guardó carta, una
  /// de su camino.
  RunState _ghostDrop(RunState r) {
    final g = r.ghost;
    if (g == null || g.claimedAt != null) return r;
    if (!packOf(r).contains(ghostEnemy)) return r;
    var id = g.card;
    var upgrades = g.upgrades;
    var rng = r.rng;
    if (id == null || !data.cards.containsKey(id)) {
      final pool = [
        for (final c in data.cards.values)
          if (!r.locked.contains(c.id) &&
              (c.pool == (g.style?.name ?? '') ||
                  (g.style == null &&
                      data.balance.rewardPools.contains(c.pool))))
            c.id,
      ];
      if (pool.isEmpty) return r;
      final (picked, next) = _pick(rng, pool);
      id = picked;
      rng = next;
      upgrades = 0;
    }
    final card = id;
    return r.copyWith(
      deck: [
        ...r.deck,
        CombatCard(uid: r.nextUid, cardId: card, upgrades: upgrades),
      ],
      nextUid: r.nextUid + 1,
      rng: rng,
      ghost: g.claim(r.currentNode!, card),
    );
  }

  /// Semillas de loto con el extra del árbol.
  int lotusOf(RunState r, int base) =>
      (base * (100 + r.meta.lotusPct) / 100).round();

  /// Semillas que deja el jade que sobró al terminar la subida: se ofrenda
  /// a la escuela en vez de perderse.
  int offeringOf(RunState r) {
    final per = data.balance.meridians.lotus.jadePer;
    return per <= 0 || r.jade <= 0 ? 0 : lotusOf(r, r.jade ~/ per);
  }

  /// Sorteo del premio de un combate común o de élite.
  (RewardKind, Rng) _rollRewardKind(RunState r, {required bool allowTalisman}) {
    final def = data.balance.combatRewards;
    if (r.cardlessStreak >= def.maxWithoutCards) return (RewardKind.cards, r.rng);
    final weights = {
      for (final e in def.weightsAt(r.stage).entries)
        if (e.value > 0 && (allowTalisman || e.key != RewardKind.talisman))
          e.key: e.value,
    };
    final total = weights.values.fold(0, (a, w) => a + w);
    if (total == 0) return (RewardKind.cards, r.rng);
    var (roll, rng) = r.rng.nextInt(total);
    var kind = RewardKind.cards;
    for (final e in weights.entries) {
      if (roll < e.value) {
        kind = e.key;
        break;
      }
      roll -= e.value;
    }
    // Si el premio no sirve de nada, se cambia por otro.
    kind = switch (kind) {
      RewardKind.tea when r.hp >= r.maxHp => RewardKind.jade,
      RewardKind.upgrade when !r.deck.any(canUpgrade) => RewardKind.cards,
      RewardKind.talisman when missingTalismans(r).isEmpty => RewardKind.jade,
      RewardKind.weapon when !canGainWeapon(r) => RewardKind.jade,
      _ => kind,
    };
    return (kind, rng);
  }

  /// Prepara el premio [kind]: cartas y forma, talismanes o una cantidad.
  RunState _offer(RunState r, RewardKind kind) {
    final def = data.balance.combatRewards;
    final cleared = r.copyWith(
      rewardKind: kind,
      rewardOptions: const [],
      clearRewardForm: true,
      rewardAmount: 0,
    );
    switch (kind) {
      case RewardKind.cards:
        return _rollCardReward(cleared);
      case RewardKind.talisman:
        final (options, rng) =
            _rollTalismans(r.rng, r, def.talismanChoices);
        return cleared.copyWith(talismanOptions: options, rng: rng);
      case RewardKind.jade:
        return cleared.copyWith(rewardAmount: def.jadeAt(r.stage));
      case RewardKind.lotus:
        return cleared.copyWith(
          rewardAmount:
              lotusOf(r, data.balance.meridians.lotus.rewardAt(r.stage)),
        );
      case RewardKind.tea:
        return cleared.copyWith(
          rewardAmount: math.max(
            1,
            (r.maxHp * def.teaPctAt(r.stage) / 100).round(),
          ),
        );
      case RewardKind.upgrade:
        return cleared.copyWith(rewardAmount: data.balance.fountainUpgrade);
      case RewardKind.weapon:
        final (options, rng) = _rollWeapons(r);
        return cleared.copyWith(weaponOptions: options, rng: rng);
    }
  }

  RunState _rollCardReward(RunState r) {
    final (options, rng) = _rollRewards(
      r.rng,
      r,
      data.balance.rewardChoices + r.meta.rewardChoices,
    );
    final (form, rng2) = _rollForm(rng, r);
    return r.copyWith(
      rewardOptions: options,
      rewardForm: form,
      clearRewardForm: form == null,
      rng: rng2,
    );
  }

  /// Vida que curaría el té del premio (no pasa del máximo).
  int teaHealOf(RunState r) => math.min(r.rewardAmount, r.maxHp - r.hp);

  /// Tomar el premio que no se elige (jade, loto o té) o dejar pasar el que
  /// se elige (mejora o talismán).
  RunState collectReward(RunState r) {
    _checkReward(r);
    final n = r.rewardAmount;
    return _leaveReward(
      switch (r.rewardKind) {
        RewardKind.jade => r.copyWith(
            jade: r.jade + n,
            jadeGained: r.jadeGained + n,
            stageJade: r.stageJade + n,
          ),
        RewardKind.lotus => r.copyWith(
            lotus: r.lotus + n,
            lotusGained: r.lotusGained + n,
            stageLotus: r.stageLotus + n,
          ),
        RewardKind.tea => r.copyWith(hp: r.hp + teaHealOf(r)),
        _ => r,
      }
          .copyWith(
        rewardOptions: const [],
        clearRewardForm: true,
        talismanOptions: const [],
        weaponOptions: const [],
        rewardAmount: 0,
      ),
    );
  }

  /// Premio de mejora: una carta del mazo gana +N.
  RunState chooseRewardUpgrade(RunState r, int uid) {
    _checkReward(r, RewardKind.upgrade);
    final card = r.deck.firstWhere((c) => c.uid == uid);
    if (!canUpgrade(card)) throw StateError('No se puede mejorar');
    return _leaveReward(_upgrade(r, uid).copyWith(rewardAmount: 0));
  }

  /// Premio de talismán: uno de los que se ofrecen.
  RunState chooseRewardTalisman(RunState r, String id) {
    _checkReward(r, RewardKind.talisman);
    if (!r.talismanOptions.contains(id)) {
      throw StateError('Talismán no ofrecido: $id');
    }
    return _leaveReward(
      addTalisman(r, id).copyWith(talismanOptions: const []),
    );
  }

  /// Volver a tirar las cartas del premio (los del árbol de meridianos).
  RunState rerollReward(RunState r) {
    _checkReward(r, RewardKind.cards);
    if (r.rerollsLeft <= 0) throw StateError('No quedan');
    final spent = r.copyWith(rerollsLeft: r.rerollsLeft - 1);
    // Las cartas de un evento de camino se vuelven a tirar del camino.
    if (r.node(r.currentNode!).type == NodeType.event) {
      final (options, rng) = _rollPathCards(spent.rng, spent);
      return spent.copyWith(rewardOptions: options, rng: rng);
    }
    return _rollCardReward(spent);
  }

  void _checkReward(RunState r, [RewardKind? kind]) {
    if (r.phase != RunPhase.reward) throw StateError('No hay recompensa');
    if (kind != null && r.rewardKind != kind) {
      throw StateError('El premio es ${r.rewardKind.name}');
    }
  }

  // ----------------------------------------------------------------- armas

  /// Recompensas posibles: las del camino más las del arma.
  List<CardDef> _pool(RunState r) => data.rewardPoolFor(
    r.style,
    locked: r.locked,
    weapon: r.weapon,
    weaponLevel: r.weaponLevel,
  );

  /// Lo que da el arma equipada (con el bonus de su camino).
  TalismanEffect weaponEffectOf(RunState r) => r.weapon == null
      ? TalismanEffect.none
      : data.weapon(r.weapon!).effectAt(r.weaponLevel, r.style);

  /// Si el arma equipada todavía se puede templar.
  bool canForge(RunState r) =>
      r.weapon != null && r.weaponLevel < data.weapon(r.weapon!).maxLevel;

  /// Si un premio de arma sirve: conseguir la primera o templar la propia.
  bool canGainWeapon(RunState r) =>
      data.weapons.isNotEmpty && (r.weapon == null || canForge(r));

  RunState equipWeapon(RunState r, String id, {int level = 1}) {
    data.weapon(id);
    return r.copyWith(weapon: id, weaponLevel: level);
  }

  RunState forgeWeapon(RunState r) {
    if (!canForge(r)) throw StateError('No se puede templar');
    return r.copyWith(weaponLevel: r.weaponLevel + 1);
  }

  /// Las armas del botín: la propia (para templarla) o las tres, con la del
  /// camino primero.
  (List<String>, Rng) _rollWeapons(RunState r) {
    if (r.weapon != null) return ([r.weapon!], r.rng);
    final (all, rng) = r.rng.shuffle([...data.weapons.keys]);
    bool own(String w) => data.weapon(w).path == r.style;
    return ([...all.where(own), ...all.where((w) => !own(w))], rng);
  }

  /// Premio de arma: equipar una de las ofrecidas o templar la propia.
  RunState chooseRewardWeapon(RunState r, String id) {
    _checkReward(r, RewardKind.weapon);
    if (!r.weaponOptions.contains(id)) throw StateError('Arma no ofrecida: $id');
    final armed = id == r.weapon ? forgeWeapon(r) : equipWeapon(r, id);
    return _leaveReward(armed.copyWith(weaponOptions: const []));
  }

  // ------------------------------------------------------------ talismanes

  /// Suma un efecto de todos los talismanes de la run.
  /// El arma cuenta como uno más.
  int talismanSum(RunState r, int Function(TalismanEffect e) of) =>
      r.talismans.fold(0, (a, id) => a + of(data.talisman(id).effect)) +
      of(weaponEffectOf(r));

  /// Talismanes que todavía no se tienen ([rare]: null = común o raro).
  /// Los de jefe solo salen con [boss], los del mercader solo con [shop] y
  /// los de camino solo a ese camino.
  List<String> missingTalismans(
    RunState r, {
    bool? rare,
    bool boss = false,
    bool shop = false,
  }) => [
    for (final t in data.talismans.values)
      if (!r.talismans.contains(t.id) &&
          !r.locked.contains(t.id) &&
          t.boss == boss &&
          t.shop == shop &&
          (t.pool == null || t.pool == r.style) &&
          (boss || shop || rare == null || t.rare == rare))
        t.id,
  ];

  /// El jefe de etapa ofrece los suyos primero y completa con los demás;
  /// con [path], el talismán del camino va primero.
  (List<String>, Rng) _rollTalismans(
    Rng rng,
    RunState r,
    int n, {
    bool boss = false,
    bool path = false,
  }) {
    final (own, rng2) = rng.shuffle(
      boss
          ? missingTalismans(r, boss: true)
          : path
              ? [
                  for (final id in missingTalismans(r))
                    if (data.talisman(id).pool != null) id,
                ]
              : <String>[],
    );
    final (rest, next) = rng2.shuffle(missingTalismans(r));
    return ([...own, ...rest].take(n).toList(), next);
  }

  /// Suma un talismán: los de Vida máxima también curan lo mismo (y los
  /// que la quitan nunca dejan al discípulo en 0).
  RunState addTalisman(RunState r, String id) {
    final extra = data.talisman(id).effect.maxHp;
    final maxHp = math.max(1, r.maxHp + extra);
    return r.copyWith(
      talismans: [...r.talismans, id],
      maxHp: maxHp,
      hp: (r.hp + extra).clamp(1, maxHp),
    );
  }

  /// Elegir uno de los talismanes del élite; después viene la recompensa.
  RunState chooseTalisman(RunState r, String id) {
    if (r.phase != RunPhase.talisman) throw StateError('No hay talismán');
    if (!r.talismanOptions.contains(id)) {
      throw StateError('Talismán no ofrecido: $id');
    }
    // Al empezar la subida (meridianos) y después de un duelo se vuelve al
    // mapa: el talismán es todo el premio.
    final done = r.currentNode == null ||
        r.node(r.currentNode!).type == NodeType.event;
    return addTalisman(r, id).copyWith(
      talismanOptions: const [],
      rewardOptions: done ? const [] : null,
      phase: done ? RunPhase.map : RunPhase.reward,
    );
  }

  // --------------------------------------------------------------- eventos

  /// Primero el del camino en esta etapa, después la segunda parte de un
  /// evento de más abajo, los propios de la etapa que no viste, los
  /// generales que no viste y, si ya viste todo, cualquiera de la etapa. Los
  /// de otro camino nunca salen; una segunda parte, solo con su marca.
  RunState _rollEvent(RunState r) {
    final stageId = stageOf(r).id;
    final here = [
      for (final e in data.events)
        if (e.fitsStage(stageId) &&
            (e.path == null || e.path == r.style) &&
            (e.after == null || (r.marks[e.after] ?? r.stage) < r.stage))
          e,
    ];
    final fresh = [for (final e in here) if (!r.seenEvents.contains(e.id)) e];
    final path = [for (final e in fresh) if (e.path != null) e.id];
    final back = [for (final e in fresh) if (e.after != null) e.id];
    final own = [for (final e in fresh) if (e.stages != null) e.id];
    final pool = path.isNotEmpty
        ? path
        : back.isNotEmpty
        ? back
        : own.isNotEmpty
        ? own
        : fresh.isNotEmpty
            ? [for (final e in fresh) e.id]
            : [for (final e in here) e.id];
    final (shuffled, rng) = r.rng.shuffle(pool);
    return r.copyWith(eventId: shuffled.first, rng: rng);
  }

  /// Lo que habilita una opción con requisito (el talismán, el arma o la
  /// forma que se tiene), o null si no se cumple o no pide nada.
  String? needMet(RunState r, EventOptionDef o) {
    final n = o.needs;
    if (n == null) return null;
    final owned = switch (n.kind) {
      EventNeedKind.talisman => r.talismans,
      EventNeedKind.weapon => [?r.weapon],
      EventNeedKind.form => r.knownForms,
    };
    for (final id in owned) {
      if (n.ids.isEmpty || n.ids.contains(id)) return id;
    }
    return null;
  }

  /// Las opciones que se ven: las que piden algo, solo si se tiene, y
  /// primero (son lo que se ganó con lo que se lleva).
  List<EventOptionDef> eventOptions(RunState r, EventDef e) => [
    for (final o in e.options)
      if (o.needs != null && needMet(r, o) != null) o,
    for (final o in e.options)
      if (o.needs == null) o,
  ];

  /// Una opción con costo de Vida solo se puede pagar si no te deja en 0;
  /// una con precio, si alcanza el jade; una con requisito, si se cumple.
  bool canChoose(RunState r, EventOptionDef o) =>
      r.hp > o.cost &&
      r.jade >= o.price &&
      (o.needs == null || needMet(r, o) != null);

  /// Resuelve la opción elegida y vuelve al mapa.
  RunState resolveEvent(RunState r, String optionId) {
    if (r.phase != RunPhase.event) throw StateError('No hay evento');
    final event = data.event(r.eventId!);
    final option = event.option(optionId);
    if (!canChoose(r, option)) throw StateError('No alcanza la Vida o el jade');
    var rng = r.rng;
    bool? success;
    var outcome = option.outcome;
    if (option.chance != null) {
      final (roll, next) = rng.nextInt(100);
      rng = next;
      success = roll < option.chance!;
      if (!success) outcome = option.failure!;
    }
    var next = r.copyWith(
      rng: rng,
      jade: r.jade - option.price + outcome.jade,
    );
    final startHp = next.hp;
    if (outcome.maxHp > 0) {
      next = next.copyWith(
        maxHp: next.maxHp + outcome.maxHp,
        hp: next.hp + outcome.maxHp,
      );
    }
    if (outcome.hp > 0) next = next.copyWith(hp: math.max(1, next.hp - outcome.hp));
    if (outcome.heal > 0) {
      next = next.copyWith(hp: math.min(next.maxHp, next.hp + outcome.heal));
    }
    String? talisman, card, form, upgraded, lost, tempered;
    // Las ganancias que se eligen pasan por la pantalla del premio.
    RunState? offer;
    switch (outcome.gain) {
      case null:
        break;
      case EventGain.form:
        final (forms, rng2) = _shuffleForms(next.rng, next);
        if (forms.isNotEmpty) {
          final pick = forms.first;
          form = pick;
          next = next.copyWith(knownForms: [...next.knownForms, pick], rng: rng2);
        } else {
          (next, card) = _gainCard(next);
        }
      case EventGain.talisman ||
          EventGain.rareTalisman ||
          EventGain.pathTalisman:
        final rare = outcome.gain != EventGain.talisman;
        final own = [
          for (final id in missingTalismans(next, rare: true))
            if (data.talisman(id).pool != null) id,
        ];
        var pool = outcome.gain == EventGain.pathTalisman && own.isNotEmpty
            ? own
            : missingTalismans(next, rare: rare);
        if (pool.isEmpty) pool = missingTalismans(next);
        if (pool.isNotEmpty) {
          final (pick, rng2) = _pick(next.rng, pool);
          talisman = pick;
          next = addTalisman(next.copyWith(rng: rng2), pick);
        }
      case EventGain.card:
        (next, card) = _gainCard(next);
      case EventGain.pathCards:
        final (options, rng2) = _rollPathCards(next.rng, next);
        offer = next.copyWith(
          rewardKind: RewardKind.cards,
          rewardOptions: options,
          clearRewardForm: true,
          rewardAmount: 0,
          jadeGained: 0,
          lotusGained: 0,
          rng: rng2,
        );
      case EventGain.pickUpgrade:
        if (next.deck.any(canUpgrade)) {
          offer = next.copyWith(
            rewardKind: RewardKind.upgrade,
            rewardOptions: const [],
            clearRewardForm: true,
            rewardAmount: data.balance.fountainUpgrade,
            jadeGained: 0,
            lotusGained: 0,
          );
        }
      case EventGain.upgrade:
        (next, upgraded) = _upgradeAny(next);
      case EventGain.temper:
        if (canForge(next)) {
          tempered = next.weapon;
          next = forgeWeapon(next);
        } else {
          (next, upgraded) = _upgradeAny(next);
        }
      case EventGain.loseStarter:
        final pool = [
          for (final c in next.deck)
            if (data.card(c.cardId).pool == 'starter') c.uid,
        ];
        if (pool.isNotEmpty) {
          final (uid, rng2) = _pick(next.rng, pool);
          lost = next.deck.firstWhere((c) => c.uid == uid).cardId;
          next = next.copyWith(
            deck: [for (final c in next.deck) if (c.uid != uid) c],
            rng: rng2,
          );
        }
    }
    if (offer != null) next = offer;
    if (outcome.mark != null) {
      next = next.copyWith(marks: {...next.marks, outcome.mark!: r.stage});
    }
    // El duelo de la opción; o el del resultado (escabullirse y que te vean).
    final duel = success == false ? outcome.duel : option.duel ?? outcome.duel;
    return next.copyWith(
      phase: duel != null
          ? RunPhase.combat
          : offer != null
              ? RunPhase.reward
              : RunPhase.map,
      duel: duel,
      clearEventId: true,
      seenEvents: [...next.seenEvents, event.id],
      lastEvent: EventResult(
        eventId: event.id,
        optionId: optionId,
        success: success,
        hp: next.hp - startHp - (next.maxHp - r.maxHp),
        maxHp: next.maxHp - r.maxHp,
        jade: next.jade - r.jade,
        talisman: talisman,
        card: card,
        form: form,
        upgraded: upgraded,
        lost: lost,
        duel: duel,
        tempered: tempered,
        mark: outcome.mark,
      ),
    );
  }

  /// Mejora una carta al azar de las que se pueden mejorar.
  (RunState, String?) _upgradeAny(RunState r) {
    final pool = [for (final c in r.deck) if (canUpgrade(c)) c.uid];
    if (pool.isEmpty) return (r, null);
    final (uid, rng) = _pick(r.rng, pool);
    final id = r.deck.firstWhere((c) => c.uid == uid).cardId;
    return (_upgrade(r, uid).copyWith(rng: rng), id);
  }

  /// Tres cartas del camino de la run para elegir (sin camino, de las de
  /// recompensa).
  (List<String>, Rng) _rollPathCards(Rng rng, RunState r) {
    final style = r.style;
    final pool = [
      for (final c in data.rewardPoolFor(style, locked: r.locked))
        if (style == null || c.pool == style.name) c.id,
    ];
    final (shuffled, next) = rng.shuffle(pool);
    return (shuffled.take(data.balance.rewardChoices).toList(), next);
  }

  (RunState, String) _gainCard(RunState r) {
    final pool = [
      for (final c in _pool(r)) c.id,
    ];
    final (id, rng) = _pick(r.rng, pool);
    return (
      r.copyWith(
        deck: [...r.deck, CombatCard(uid: r.nextUid, cardId: id)],
        nextUid: r.nextUid + 1,
        rng: rng,
      ),
      id,
    );
  }

  (T, Rng) _pick<T>(Rng rng, List<T> items) {
    final (i, next) = rng.nextInt(items.length);
    return (items[i], next);
  }

  /// Formas que todavía se pueden aprender en este camino.
  List<String> learnableForms(RunState r) => [
        for (final f in data.forms)
          if (!r.knownForms.contains(f.id) &&
              !r.locked.contains(f.id) &&
              (f.pool == null || f.pool == r.style))
            f.id,
      ];

  (String?, Rng) _rollForm(Rng rng, RunState r) {
    final (shuffled, next) = _shuffleForms(rng, r);
    return (shuffled.firstOrNull, next);
  }

  /// Formas aprendibles barajadas; con camino, dos de cada tres veces va
  /// primero una del camino (son las que su mazo puede completar).
  (List<String>, Rng) _shuffleForms(Rng rng, RunState r) {
    final (shuffled, next) = rng.shuffle(learnableForms(r));
    final own = [
      for (final id in shuffled)
        if (data.forms.firstWhere((f) => f.id == id).pool != null) id,
    ];
    if (own.isEmpty) return (shuffled, next);
    final (roll, next2) = next.nextInt(3);
    if (roll == 0) return (shuffled, next2);
    return ([own.first, ...shuffled.where((id) => id != own.first)], next2);
  }

  (List<String>, Rng) _rollRewards(Rng rng, RunState r, int n) {
    final pool = [
      for (final c in _pool(r)) c.id,
    ];
    final (shuffled, next) = rng.shuffle(pool);
    return (shuffled.take(n).toList(), next);
  }

  /// Elegir una recompensa o saltear (cardId null).
  RunState chooseReward(RunState r, String? cardId) {
    _checkReward(r);
    if (cardId != null && !r.rewardOptions.contains(cardId)) {
      throw StateError('Recompensa inválida: $cardId');
    }
    return _leaveReward(r.copyWith(
      deck: cardId == null
          ? r.deck
          : [...r.deck, CombatCard(uid: r.nextUid, cardId: cardId)],
      nextUid: cardId == null ? r.nextUid : r.nextUid + 1,
      rewardOptions: const [],
      clearRewardForm: true,
    ));
  }

  /// Aprender la forma ofrecida en vez de sumar una carta.
  RunState chooseForm(RunState r, String formId) {
    if (r.phase != RunPhase.reward) throw StateError('No hay recompensa');
    if (r.rewardForm != formId) {
      throw StateError('Forma no ofrecida: $formId');
    }
    return _leaveReward(r.copyWith(
      knownForms: [...r.knownForms, formId],
      rewardOptions: const [],
      clearRewardForm: true,
    ));
  }

  /// Vida que cura la fuente en la dificultad de la run (un talismán con
  /// costo la achica, pero nunca le quita Vida).
  int healOf(RunState r) => math.max(
    0,
    data.balance.difficulty(r.difficulty).fountainHeal +
        data.balance.picoMods(r.pico).fountainHeal +
        talismanSum(r, (e) => e.fountainHeal) +
        r.meta.fountainHeal,
  );

  RunState fountainHeal(RunState r) {
    _checkFountain(r);
    return r.copyWith(
      hp: math.min(r.maxHp, r.hp + healOf(r)),
      phase: RunPhase.map,
    );
  }

  RunState fountainRemove(RunState r, int uid) {
    _checkFountain(r);
    return r.copyWith(
      deck: [for (final c in r.deck) if (c.uid != uid) c],
      phase: RunPhase.map,
    );
  }

  /// Una carta se puede mejorar si tiene daño o Guardia.
  bool canUpgrade(CombatCard c) {
    final def = data.card(c.cardId);
    return def.damage > 0 || def.guard > 0;
  }

  RunState fountainUpgrade(RunState r, int uid) {
    _checkFountain(r);
    return _upgrade(r, uid).copyWith(phase: RunPhase.map);
  }

  RunState _upgrade(RunState r, int uid) => r.copyWith(
        deck: [
          for (final c in r.deck)
            if (c.uid == uid)
              CombatCard(
                uid: c.uid,
                cardId: c.cardId,
                upgrades: c.upgrades + data.balance.fountainUpgrade,
              )
            else
              c,
        ],
      );

  // ----------------------------------------------------------------- jade

  (int, Rng) _rollJade(RunState r) {
    final b = data.balance;
    final elite = data.enemy(enemyOf(r)).rank == EnemyRank.elite;
    // La élite paga con un talismán; si no da jade, no se tira.
    if (elite && b.jadeElite == 0) return (0, r.rng);
    final (extra, rng) = r.rng.nextInt(b.jadeSpread + 1);
    return ((elite ? b.jadeElite : b.jadeCommon) + extra, rng);
  }

  // ------------------------------------------------------------- mercader

  /// Mercader de la etapa en la que está la run (los Picos lo encarecen).
  MerchantDef merchantOf(RunState r) => data.balance
      .merchantAt(r.stage)
      .discounted(
        r.meta.merchantDiscountPct +
            talismanSum(r, (e) => e.shopDiscountPct) -
            data.balance.picoMods(r.pico).merchantPct,
      );

  RunState _rollShop(RunState r) {
    final m = merchantOf(r);
    final (cards, rng) = _rollRewards(r.rng, r, m.cards);
    // La mitad de las veces trae uno de los suyos, que solo él vende. Si
    // no, más arriba se venden raros; si no queda ninguno, uno común.
    final own = missingTalismans(r, shop: true);
    final (pick, rng1) = rng.nextInt(2);
    final rares = m.rareTalisman ? missingTalismans(r, rare: true) : <String>[];
    final (talismans, rng2) = rng1.shuffle(
      own.isNotEmpty && pick == 0
          ? own
          : rares.isNotEmpty
          ? rares
          : missingTalismans(r, rare: false),
    );
    // La vitrina: un raro aparte, caro, distinto del de arriba.
    final shown = talismans.isEmpty ? null : talismans.first;
    final (showcase, rng2b) = m.rare > 0
        ? rng2.shuffle([
            for (final t in missingTalismans(r, rare: true))
              if (t != shown) t,
          ])
        : (const <String>[], rng2);
    final (sale, rng3) = rng2b.nextInt(math.max(1, cards.length));
    // Sin arma vende una (la del camino la mitad de las veces); con arma,
    // la templa.
    var rng4 = rng3;
    String? weapon;
    if (canForge(r)) {
      weapon = r.weapon;
    } else if (r.weapon == null && data.weapons.isNotEmpty) {
      final (ws, next) = _rollWeapons(r);
      final (coin, next2) = next.nextInt(2);
      weapon = coin == 0 ? ws.first : ws.last;
      rng4 = next2;
    }
    return r.copyWith(
      shopWeapon: weapon,
      clearShopWeapon: weapon == null,
      shopForged: false,
      shopCards: cards,
      shopSale: cards.isEmpty ? null : cards[sale],
      clearShopSale: cards.isEmpty,
      shopTea: false,
      shopTalisman: talismans.isEmpty ? null : talismans.first,
      clearShopTalisman: talismans.isEmpty,
      shopRare: showcase.isEmpty ? null : showcase.first,
      clearShopRare: showcase.isEmpty,
      shopRemoved: false,
      shopUpgraded: false,
      rng: rng4,
    );
  }

  bool canAfford(RunState r, int price) => r.jade >= price;

  /// Precio de una carta de la tienda (la de oferta sale más barata).
  int cardPrice(RunState r, String cardId) =>
      cardId == r.shopSale ? merchantOf(r).salePrice : merchantOf(r).card;

  RunState buyCard(RunState r, String cardId) {
    final price = cardPrice(r, cardId);
    _checkShop(r, price);
    if (!r.shopCards.contains(cardId)) throw StateError('No está en venta');
    return r.copyWith(
      jade: r.jade - price,
      deck: [...r.deck, CombatCard(uid: r.nextUid, cardId: cardId)],
      nextUid: r.nextUid + 1,
      shopCards: [for (final c in r.shopCards) if (c != cardId) c],
    );
  }

  RunState buyTalisman(RunState r) {
    final price = merchantOf(r).talisman;
    _checkShop(r, price);
    if (r.shopTalisman == null) throw StateError('No hay talismán');
    return addTalisman(r, r.shopTalisman!)
        .copyWith(jade: r.jade - price, clearShopTalisman: true);
  }

  /// Comprar el raro de la vitrina.
  RunState buyRare(RunState r) {
    final price = merchantOf(r).rare;
    _checkShop(r, price);
    if (r.shopRare == null) throw StateError('No hay vitrina');
    return addTalisman(r, r.shopRare!)
        .copyWith(jade: r.jade - price, clearShopRare: true);
  }

  /// Comprar el arma en venta (sin arma).
  RunState buyWeapon(RunState r) {
    final price = merchantOf(r).weapon;
    _checkShop(r, price);
    final w = r.shopWeapon;
    if (w == null || r.weapon != null) throw StateError('No hay arma');
    return equipWeapon(r, w).copyWith(
      jade: r.jade - price,
      clearShopWeapon: true,
    );
  }

  /// Templar el arma con el mercader (una vez por tienda).
  RunState buyForge(RunState r) {
    final price = merchantOf(r).weaponForge;
    _checkShop(r, price);
    if (r.shopForged || r.shopWeapon != r.weapon) throw StateError('Ya se usó');
    return forgeWeapon(r).copyWith(jade: r.jade - price, shopForged: true);
  }

  RunState buyRemove(RunState r, int uid) {
    final price = merchantOf(r).remove;
    _checkShop(r, price);
    if (r.shopRemoved) throw StateError('Ya se usó');
    return r.copyWith(
      jade: r.jade - price,
      deck: [for (final c in r.deck) if (c.uid != uid) c],
      shopRemoved: true,
    );
  }

  RunState buyUpgrade(RunState r, int uid) {
    final price = merchantOf(r).upgrade;
    _checkShop(r, price);
    if (r.shopUpgraded) throw StateError('Ya se usó');
    return _upgrade(r, uid).copyWith(jade: r.jade - price, shopUpgraded: true);
  }

  /// Té de jengibre: cura un poco, una vez por tienda.
  RunState buyTea(RunState r) {
    final m = merchantOf(r);
    _checkShop(r, m.tea);
    if (r.shopTea) throw StateError('Ya se usó');
    return r.copyWith(
      jade: r.jade - m.tea,
      hp: math.min(r.maxHp, r.hp + m.teaHeal),
      shopTea: true,
    );
  }

  RunState leaveShop(RunState r) {
    if (r.phase != RunPhase.merchant) throw StateError('No hay mercader');
    return r.copyWith(
      phase: RunPhase.map,
      shopCards: const [],
      clearShopTalisman: true,
      clearShopRare: true,
      clearShopSale: true,
      clearShopWeapon: true,
    );
  }

  void _checkShop(RunState r, int price) {
    if (r.phase != RunPhase.merchant) throw StateError('No hay mercader');
    if (!canAfford(r, price)) throw StateError('No alcanza el jade');
  }

  // -------------------------------------------------------- maestro errante

  RunState _rollMaster(RunState r) {
    final (forms, rng) = _shuffleForms(r.rng, r);
    return r.copyWith(
      masterForms: forms.take(data.balance.masterForms).toList(),
      rng: rng,
    );
  }

  /// Aprender una de las formas que enseña el maestro.
  RunState masterTeach(RunState r, String formId) {
    _checkMaster(r);
    if (!r.masterForms.contains(formId)) throw StateError('Forma no ofrecida');
    return r.copyWith(
      knownForms: [...r.knownForms, formId],
      masterForms: const [],
      phase: RunPhase.map,
    );
  }

  /// Mejorar una carta con el maestro (en vez de aprender una forma).
  RunState masterUpgrade(RunState r, int uid) {
    _checkMaster(r);
    return _upgrade(r, uid)
        .copyWith(masterForms: const [], phase: RunPhase.map);
  }

  /// El maestro templa hasta el nivel 2; el último, solo el botín o el
  /// mercader.
  static const masterForgeMax = 2;

  bool canMasterForge(RunState r) =>
      canForge(r) && r.weaponLevel < masterForgeMax;

  /// Templar el arma con el maestro (en vez de forma o mejora).
  RunState masterForge(RunState r) {
    _checkMaster(r);
    if (!canMasterForge(r)) throw StateError('El maestro no la templa');
    return forgeWeapon(r).copyWith(masterForms: const [], phase: RunPhase.map);
  }

  void _checkMaster(RunState r) {
    if (r.phase != RunPhase.master) throw StateError('No hay maestro');
  }

  void _checkFountain(RunState r) {
    if (r.phase != RunPhase.fountain) throw StateError('No estás en la fuente');
  }
}
