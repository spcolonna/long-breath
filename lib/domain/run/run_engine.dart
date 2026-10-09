import 'dart:math' as math;

import '../combat/combat_state.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/event_def.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../model/meta_bonus.dart';
import '../model/talisman_def.dart';
import '../rng.dart';
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
    return r;
  }

  (List<MapNodeDef>, Rng) _stageMap(int stage, Rng rng) {
    final st = data.balance.stages[stage];
    return generateMap(
      st.floors,
      rng,
      scenes: st.scenes,
      lights: st.lights,
      packable: packable,
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
      phase: switch (n.type) {
        NodeType.combat => RunPhase.combat,
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

  String enemyOf(RunState r) => r.node(r.currentNode!).enemy!;

  /// Enemigos del combate actual, en el orden en que entran.
  List<String> packOf(RunState r) {
    final n = r.node(r.currentNode!);
    return [n.enemy!, ...n.waves];
  }

  /// [fledWith]: si el enemigo se escapó, el jade que se llevó (null si
  /// lo venciste). Escapado no deja jade ni loto.
  RunState finishCombat(
    RunState r, {
    required bool won,
    required int hp,
    int? fledWith,
  }) {
    if (!won) return r.copyWith(hp: 0, phase: RunPhase.defeat);
    final b = data.balance;
    final lotus = b.meridians.lotus;
    final boss = _atStageBoss(r);
    final elite = !boss && data.enemy(enemyOf(r)).rank == EnemyRank.elite;
    final fled = fledWith != null;
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
      final jade =
          rolled + b.packJade * r.node(r.currentNode!).waves.length;
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
    r = r.copyWith(hp: healed);
    // El élite y el jefe dejan elegir un talismán antes del premio.
    final (talismans, rngT) = elite || boss
        ? _rollTalismans(
            r.rng, r, b.talismanChoices + r.meta.talismanChoices)
        : (const <String>[], r.rng);
    r = r.copyWith(rng: rngT);
    // El jefe deja cartas; el que se escapó, también (no hay otro premio).
    final (kind, rngK) = boss || fled
        ? (RewardKind.cards, r.rng)
        : _rollRewardKind(r, allowTalisman: !elite);
    return _offer(r.copyWith(rng: rngK), kind).copyWith(
      phase: talismans.isEmpty ? RunPhase.reward : RunPhase.talisman,
      talismanOptions: kind == RewardKind.talisman ? null : talismans,
      cardlessStreak: kind == RewardKind.cards ? 0 : r.cardlessStreak + 1,
    );
  }

  /// Semillas de loto con el extra del árbol.
  int lotusOf(RunState r, int base) =>
      (base * (100 + r.meta.lotusPct) / 100).round();

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
    return _rollCardReward(r.copyWith(rerollsLeft: r.rerollsLeft - 1));
  }

  void _checkReward(RunState r, [RewardKind? kind]) {
    if (r.phase != RunPhase.reward) throw StateError('No hay recompensa');
    if (kind != null && r.rewardKind != kind) {
      throw StateError('El premio es ${r.rewardKind.name}');
    }
  }

  // ------------------------------------------------------------ talismanes

  /// Suma un efecto de todos los talismanes de la run.
  int talismanSum(RunState r, int Function(TalismanEffect e) of) =>
      r.talismans.fold(0, (a, id) => a + of(data.talisman(id).effect));

  /// Talismanes que todavía no se tienen ([rare]: null = cualquiera).
  List<String> missingTalismans(RunState r, {bool? rare}) => [
        for (final t in data.talismans.values)
          if (!r.talismans.contains(t.id) &&
              !r.locked.contains(t.id) &&
              (rare == null || t.rare == rare))
            t.id,
      ];

  (List<String>, Rng) _rollTalismans(Rng rng, RunState r, int n) {
    final (shuffled, next) = rng.shuffle(missingTalismans(r));
    return (shuffled.take(n).toList(), next);
  }

  /// Suma un talismán: los de Vida máxima también curan lo mismo.
  RunState addTalisman(RunState r, String id) {
    final extra = data.talisman(id).effect.maxHp;
    return r.copyWith(
      talismans: [...r.talismans, id],
      maxHp: r.maxHp + extra,
      hp: r.hp + extra,
    );
  }

  /// Elegir uno de los talismanes del élite; después viene la recompensa.
  RunState chooseTalisman(RunState r, String id) {
    if (r.phase != RunPhase.talisman) throw StateError('No hay talismán');
    if (!r.talismanOptions.contains(id)) {
      throw StateError('Talismán no ofrecido: $id');
    }
    // Al empezar la subida (meridianos) se vuelve al mapa.
    return addTalisman(r, id).copyWith(
      talismanOptions: const [],
      phase: r.currentNode == null ? RunPhase.map : RunPhase.reward,
    );
  }

  // --------------------------------------------------------------- eventos

  /// Primero los eventos propios de la etapa que no viste, después los
  /// generales que no viste y, si ya viste todo, cualquiera de la etapa.
  RunState _rollEvent(RunState r) {
    final stageId = stageOf(r).id;
    final here = [for (final e in data.events) if (e.fitsStage(stageId)) e];
    final fresh = [for (final e in here) if (!r.seenEvents.contains(e.id)) e];
    final own = [for (final e in fresh) if (e.stages != null) e.id];
    final pool = own.isNotEmpty
        ? own
        : fresh.isNotEmpty
            ? [for (final e in fresh) e.id]
            : [for (final e in here) e.id];
    final (shuffled, rng) = r.rng.shuffle(pool);
    return r.copyWith(eventId: shuffled.first, rng: rng);
  }

  /// Una opción con costo de Vida solo se puede pagar si no te deja en 0;
  /// una con precio, si alcanza el jade.
  bool canChoose(RunState r, EventOptionDef o) =>
      r.hp > o.cost && r.jade >= o.price;

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
    String? talisman, card, form, upgraded, lost;
    switch (outcome.gain) {
      case null:
        break;
      case EventGain.form:
        final forms = learnableForms(next);
        if (forms.isNotEmpty) {
          final (pick, rng2) = _pick(next.rng, forms);
          form = pick;
          next = next.copyWith(knownForms: [...next.knownForms, pick], rng: rng2);
        } else {
          (next, card) = _gainCard(next);
        }
      case EventGain.talisman || EventGain.rareTalisman:
        final rare = outcome.gain == EventGain.rareTalisman;
        var pool = missingTalismans(next, rare: rare);
        if (pool.isEmpty) pool = missingTalismans(next);
        if (pool.isNotEmpty) {
          final (pick, rng2) = _pick(next.rng, pool);
          talisman = pick;
          next = addTalisman(next.copyWith(rng: rng2), pick);
        }
      case EventGain.card:
        (next, card) = _gainCard(next);
      case EventGain.upgrade:
        final pool = [for (final c in next.deck) if (canUpgrade(c)) c.uid];
        if (pool.isNotEmpty) {
          final (uid, rng2) = _pick(next.rng, pool);
          upgraded = next.deck.firstWhere((c) => c.uid == uid).cardId;
          next = _upgrade(next, uid).copyWith(rng: rng2);
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
    return next.copyWith(
      phase: RunPhase.map,
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
      ),
    );
  }

  (RunState, String) _gainCard(RunState r) {
    final pool = [
      for (final c in data.rewardPoolFor(r.style, locked: r.locked)) c.id,
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
    final pool = learnableForms(r);
    if (pool.isEmpty) return (null, rng);
    final (shuffled, next) = rng.shuffle(pool);
    return (shuffled.first, next);
  }

  (List<String>, Rng) _rollRewards(Rng rng, RunState r, int n) {
    final pool = [
      for (final c in data.rewardPoolFor(r.style, locked: r.locked)) c.id,
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

  /// Vida que cura la fuente en la dificultad de la run.
  int healOf(RunState r) =>
      data.balance.difficulty(r.difficulty).fountainHeal +
      data.balance.picoMods(r.pico).fountainHeal +
      talismanSum(r, (e) => e.fountainHeal) +
      r.meta.fountainHeal;

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

  /// Mercader de la etapa en la que está la run.
  MerchantDef merchantOf(RunState r) => data.balance
      .merchantAt(r.stage)
      .discounted(r.meta.merchantDiscountPct);

  RunState _rollShop(RunState r) {
    final m = merchantOf(r);
    final (cards, rng) = _rollRewards(r.rng, r, m.cards);
    // Más arriba se venden raros; si no queda ninguno, uno común.
    final rares = m.rareTalisman ? missingTalismans(r, rare: true) : <String>[];
    final (talismans, rng2) = rng.shuffle(
      rares.isNotEmpty ? rares : missingTalismans(r, rare: false),
    );
    final (sale, rng3) = rng2.nextInt(math.max(1, cards.length));
    return r.copyWith(
      shopCards: cards,
      shopSale: cards.isEmpty ? null : cards[sale],
      clearShopSale: cards.isEmpty,
      shopTea: false,
      shopTalisman: talismans.isEmpty ? null : talismans.first,
      clearShopTalisman: talismans.isEmpty,
      shopRemoved: false,
      shopUpgraded: false,
      rng: rng3,
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
      clearShopSale: true,
    );
  }

  void _checkShop(RunState r, int price) {
    if (r.phase != RunPhase.merchant) throw StateError('No hay mercader');
    if (!canAfford(r, price)) throw StateError('No alcanza el jade');
  }

  // -------------------------------------------------------- maestro errante

  RunState _rollMaster(RunState r) {
    final (forms, rng) = r.rng.shuffle(learnableForms(r));
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

  void _checkMaster(RunState r) {
    if (r.phase != RunPhase.master) throw StateError('No hay maestro');
  }

  void _checkFountain(RunState r) {
    if (r.phase != RunPhase.fountain) throw StateError('No estás en la fuente');
  }
}
