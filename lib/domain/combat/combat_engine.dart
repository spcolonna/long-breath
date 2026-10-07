import 'dart:math' as math;

import '../model/awakening_def.dart';
import '../model/card_def.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/form_def.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../model/talisman_def.dart';
import '../rng.dart';
import 'combat_action.dart';
import 'combat_event.dart';
import 'combat_state.dart';

class CombatResult {
  const CombatResult(this.state, this.events);
  final CombatState state;
  final List<CombatEvent> events;
}

/// Motivo por el que una acción no es válida (la interfaz lo traduce).
enum Invalid {
  combatOver,
  mustDiscard,
  notInHand,
  firstTurnOnly,
  noBreath,
  dingbuUsed,
  sameStance,
  breatheUsed,
  retainTooMany,
  noDiscard,
}

/// Valores finales de una carta en el estado actual (lo que muestra la UI).
class CardPreview {
  const CardPreview({
    required this.cost,
    required this.playable,
    required this.damage,
    required this.structure,
    required this.guard,
    required this.height,
    required this.stanceAfter,
    required this.advancesForms,
    required this.completesForms,
    required this.interruptsForms,
    this.reason,
    this.stanceDamage = 0,
    this.stanceStructure = 0,
    this.stanceGuard = 0,
    this.stanceCost = 0,
    this.styleDamage = 0,
    this.retained = false,
  });

  final int cost;
  final bool playable;
  final Invalid? reason;

  /// Daño y daño a Estructura que recibe el enemigo (con todos los modificadores).
  final int damage;
  final int structure;
  final int guard;
  final Height? height;
  final Stance stanceAfter;
  final List<String> advancesForms;
  final List<String> completesForms;
  final List<String> interruptsForms;

  /// Cuánto suma (o resta) la postura actual a cada valor de la carta.
  final int stanceDamage;
  final int stanceStructure;
  final int stanceGuard;
  final int stanceCost;

  /// Daño que suma el camino o la carta por el turno (primer golpe, cadena,
  /// retenida); ya está incluido en [damage].
  final int styleDamage;

  /// La carta viene retenida del turno anterior.
  final bool retained;
}

/// Intención del enemigo con los valores finales ya aplicados.
class IntentView {
  const IntentView({
    required this.intent,
    required this.damage,
    required this.structure,
    required this.skipped,
    required this.countdown,
    required this.punishIfSameStance,
    this.stolen = 0,
  });

  final IntentDef intent;

  /// Jade que se lleva si se escapa (Mono Ladrón).
  final int stolen;
  final int damage;
  final int structure;

  /// El enemigo está Desequilibrado y pierde esta acción.
  final bool skipped;

  /// Acciones que faltan para el ataque con cuenta regresiva (0 = este turno).
  final int? countdown;

  /// Discípulo: si terminás el turno en esta postura, el ataque se potencia.
  final bool punishIfSameStance;
}

/// Motor de combate: reductor puro (estado + acción → estado + eventos).
class CombatEngine {
  CombatEngine(this.data);

  final GameData data;

  // ---------------------------------------------------------------- inicio

  CombatResult start({
    required List<CombatCard> deck,
    required String enemyId,
    required Style? style,
    required int playerHp,
    required int seed,
    bool shuffle = true,
    Difficulty difficulty = Difficulty.normal,
    int pico = 0,
    int stage = 0,
    int? maxHp,
    Iterable<String>? forms,
    List<String> talismans = const [],
    List<String> awakenings = const [],
  }) {
    final b = data.balance;
    final styleStats = b.statsOf(style);
    final aw = b.awakeningsEffect(awakenings);
    final enemy = data.enemy(enemyId);
    final dif = b.difficulty(difficulty);
    // Los Picos se suman encima de la dificultad.
    final pm = b.picoMods(pico) +
        (stage < b.stages.length ? b.stages[stage].enemyMods : const PicoDef());
    final rankHp = pm.enemyHp +
        switch (enemy.rank) {
          EnemyRank.common => pm.commonHp,
          EnemyRank.elite => pm.eliteHp,
          EnemyRank.boss => pm.bossHp,
        };
    int pct(int v, int p, [int extra = 0]) =>
        (v * p * (100 + extra) / 10000).round();
    final enemyHp = pct(enemy.hp, dif.enemyHp, rankHp);
    final enemyStructure =
        pct(enemy.structure, dif.enemyStructure, pm.enemyStructure);
    final effects = [for (final id in talismans) data.talisman(id).effect];
    int sum(int Function(TalismanEffect e) of) =>
        effects.fold(0, (a, e) => a + of(e));
    final extraStructure = sum((e) => e.structure);
    final startStance = effects
            .map((e) => e.startStance)
            .whereType<Stance>()
            .firstOrNull ??
        b.startStance;
    final (shuffled, rng) = shuffle
        ? Rng.seeded(seed).shuffle(deck)
        : (deck, Rng.seeded(seed));
    final d = _Draft(
      turn: 0,
      phase: CombatPhase.playerTurn,
      handSize: styleStats.draw + aw.draw,
      breathPerTurn: styleStats.breath,
      retainMax: styleStats.retain + aw.retain,
      hp: playerHp,
      maxHp: maxHp ?? b.playerHp,
      structure: b.playerStructure + extraStructure,
      maxStructure: b.playerStructure + extraStructure,
      guard: 0,
      guardHeight: null,
      stance: startStance,
      breath: 0,
      enemy: _EnemyDraft(
        id: enemy.id,
        hp: math.max(1, enemyHp - sum((e) => e.enemyHp)),
        maxHp: enemyHp,
        structure: math.max(1, enemyStructure - sum((e) => e.enemyStructure)),
        maxStructure: enemyStructure,
        scales: enemy.scales,
      ),
      drawPile: [...shuffled],
      hand: [],
      discard: [],
      exhausted: [],
      breathesLeft: b.breathesPerCombat,
      // Solo las formas que conoce (null = todas: tests y herramientas).
      formProgress: {
        for (final f in data.forms)
          if (forms == null || forms.contains(f.id)) f.id: 0,
      },
      rng: rng,
      enemyDamagePct: pct(dif.enemyDamage, 100, pm.enemyDamage),
      talismans: talismans,
      nextTurnBreathMod: sum((e) => e.firstTurnBreath),
      firstStrike: styleStats.firstStrike + aw.firstStrike,
      chain: styleStats.chain + aw.chain,
      retainedDiscount: styleStats.retainedDiscount + aw.retainedDiscount,
      awakened: aw,
    );
    final events = <CombatEvent>[
      for (final id in talismans)
        if (data.talisman(id).effect.atStart) TalismanTriggered(id),
    ];
    _startPlayerTurn(d, events);
    return CombatResult(d.freeze(), events);
  }

  // --------------------------------------------------------------- reductor

  CombatResult reduce(CombatState state, CombatAction action) {
    final error = validate(state, action);
    if (error != null) throw StateError(error.name);
    final d = _Draft.of(state);
    final events = <CombatEvent>[];
    switch (action) {
      case PlayCard(:final uid):
        _playCard(d, uid, events);
      case Dingbu(:final stance):
        d.breath -= data.transition.cost;
        d.dingbuUsed = true;
        d.stance = stance;
        events.add(StanceChanged(stance));
      case Breathe():
        final n = d.hand.length;
        d.discard.addAll(d.hand);
        d.hand.clear();
        d.retained.clear();
        d.breathesLeft--;
        d.breath -= data.balance.breatheCost;
        _draw(d, n, events);
      case EndTurn(:final retain):
        _endTurn(d, retain.toSet(), events);
      case ChooseDiscard(:final uid):
        final card = d.hand.firstWhere((c) => c.uid == uid);
        d.hand.remove(card);
        d.retained.remove(uid);
        d.discard.add(card);
        d.pendingDiscard--;
        if (d.pendingDiscard == 0) d.phase = CombatPhase.playerTurn;
    }
    return CombatResult(d.freeze(), events);
  }

  /// Devuelve el motivo por el que la acción no es válida, o null.
  Invalid? validate(CombatState s, CombatAction action) {
    if (s.isOver) return Invalid.combatOver;
    if (s.phase == CombatPhase.discarding && action is! ChooseDiscard) {
      return Invalid.mustDiscard;
    }
    switch (action) {
      case PlayCard(:final uid):
        final c = s.handCard(uid);
        if (c == null) return Invalid.notInHand;
        final def = data.card(c.cardId);
        if (def.firstTurnOnly && s.turn != 1) return Invalid.firstTurnOnly;
        if (costOf(s, def, uid) > s.player.breath) return Invalid.noBreath;
      case Dingbu(:final stance):
        if (s.dingbuUsed) return Invalid.dingbuUsed;
        if (s.player.breath < data.transition.cost) return Invalid.noBreath;
        if (stance == s.player.stance) return Invalid.sameStance;
      case Breathe():
        if (s.breathesLeft <= 0) return Invalid.breatheUsed;
        if (s.player.breath < data.balance.breatheCost) return Invalid.noBreath;
      case EndTurn(:final retain):
        if (retain.length > s.retainMax) return Invalid.retainTooMany;
        if (retain.any((u) => s.handCard(u) == null)) return Invalid.notInHand;
      case ChooseDiscard(:final uid):
        if (s.phase != CombatPhase.discarding) return Invalid.noDiscard;
        if (s.handCard(uid) == null) return Invalid.notInHand;
    }
    return null;
  }

  /// Acciones legales (para bots). EndTurn se ofrece sin retener.
  List<CombatAction> legalActions(CombatState s) {
    if (s.isOver) return const [];
    if (s.phase == CombatPhase.discarding) {
      return [for (final c in s.hand) ChooseDiscard(c.uid)];
    }
    final out = <CombatAction>[];
    final seen = <String>{};
    for (final c in s.hand) {
      if (!seen.add('${c.cardId}/${c.upgrades}')) continue;
      final a = PlayCard(c.uid);
      if (validate(s, a) == null) out.add(a);
    }
    for (final st in Stance.values) {
      final a = Dingbu(st);
      if (validate(s, a) == null) out.add(a);
    }
    if (s.hand.isNotEmpty && validate(s, const Breathe()) == null) {
      out.add(const Breathe());
    }
    out.add(const EndTurn());
    return out;
  }

  // ------------------------------------------------------------- cálculos

  /// Formas que se siguen en este combate (las que el jugador conoce).
  Iterable<FormDef> knownForms(CombatState s) =>
      data.forms.where((f) => s.formProgress.containsKey(f.id));

  /// Costo de la carta en mano; con [uid], cuenta si viene retenida.
  int costOf(CombatState s, CardDef def, [int? uid]) => _cost(
    def,
    s.player.stance,
    (uid != null && s.retained.contains(uid) ? s.retainedDiscount : 0) +
        _firstStrikeDiscount(def, s.attacksThisTurn, s.awakened),
  );

  /// Despertar del Tigre: el primer ataque del turno cuesta menos.
  int _firstStrikeDiscount(CardDef def, int attacks, AwakeningEffect aw) =>
      def.type.isAttack && attacks == 0 ? aw.firstStrikeDiscount : 0;

  int _cost(CardDef def, Stance stance, [int discount = 0]) => math.max(
    0,
    def.cost + (data.stance(stance).costModifier[def.type] ?? 0) - discount,
  );

  /// Daño extra que el camino y la carta suman a un ataque según el turno:
  /// primer golpe (Tigre), cadena (Serpiente) y carta retenida (Grulla).
  int _styleDamage(
    CardDef def, {
    required int attacks,
    required bool retained,
    required int firstStrike,
    required int chain,
    AwakeningEffect awakened = AwakeningEffect.none,
  }) {
    if (!def.type.isAttack || def.damage == 0) return 0;
    return (attacks == 0 ? firstStrike : 0) +
        (chain + def.chainDamage) * attacks +
        (retained ? def.retainedDamage + awakened.retainedDamage : 0);
  }

  /// Estructura extra de la carta según el turno: cadena (Serpiente) y
  /// carta retenida (Grulla).
  int _styleStructure(
    CardDef def, {
    required int attacks,
    required bool retained,
    AwakeningEffect awakened = AwakeningEffect.none,
  }) {
    if (!def.type.isAttack) return 0;
    return (def.chainStructure + awakened.chainStructure) * attacks +
        (retained ? def.retainedStructure : 0) +
        (attacks == 0 ? awakened.firstStrikeStructure : 0);
  }

  /// Daño y Estructura de la carta antes de los modificadores del enemigo.
  (int, int) _cardHit(
    CardDef def,
    int upgrades,
    Stance stance,
    bool staggered,
    int turnStructureBonus,
    int fistBonus, [
    int styleDamage = 0,
    int styleStructure = 0,
  ]) {
    if (def.damage == 0 && def.structure == 0) return (0, 0);
    final st = data.stance(stance);
    var dmg = def.damage + (def.guard == 0 ? upgrades : 0);
    var str = def.structure;
    if (def.type.isAttack) {
      dmg += st.damageBonus[def.type] ?? 0;
      str += st.structureBonus[def.type] ?? 0;
    }
    if (def.type == CardType.fist && def.damage > 0) dmg += fistBonus;
    dmg += styleDamage;
    if (staggered) dmg += def.bonusDamageIfStaggered;
    final ssb = def.stanceStructureBonus;
    if (ssb != null && ssb.$1 == stance) str += ssb.$2;
    str += turnStructureBonus + styleStructure;
    return (dmg, str);
  }

  /// Aporte de la postura a daño, Estructura, guardia y costo de la carta.
  (int, int, int, int) _stanceDelta(CardDef def, int upgrades, Stance stance) {
    final st = data.stance(stance);
    var dmg = 0, str = 0;
    if ((def.damage > 0 || def.structure > 0) && def.type.isAttack) {
      dmg = st.damageBonus[def.type] ?? 0;
      str = st.structureBonus[def.type] ?? 0;
    }
    final ssb = def.stanceStructureBonus;
    if (ssb != null && ssb.$1 == stance) str += ssb.$2;
    final guard = def.guard == 0
        ? 0
        : _guardOf(def, upgrades, stance) - (def.guard + upgrades);
    return (dmg, str, guard, _cost(def, stance) - def.cost);
  }

  int _guardOf(CardDef def, int upgrades, Stance stance, [int bonus = 0]) {
    if (def.guard == 0) return 0;
    return math.max(
      0,
      def.guard + upgrades + data.stance(stance).guardModifier + bonus,
    );
  }

  /// Daño efectivo sobre el enemigo: ×2 desequilibrado; si no, ½ inamovible
  /// y menos sus escamas.
  int _enemyDamageTaken(EnemyDef def, bool staggered, int scales, int dmg) {
    if (staggered) return dmg * data.balance.enemyBreakDamageMultiplier;
    if (def.immovable) dmg ~/= 2;
    return math.max(0, dmg - scales);
  }

  /// Daño de un ataque enemigo con la dificultad aplicada.
  int _enemyDamage(int dmg, int pct) =>
      pct == 100 ? dmg : (dmg * pct / 100).round();

  CardPreview preview(CombatState s, int uid) {
    final c = s.handCard(uid)!;
    final def = data.card(c.cardId);
    final stance = s.player.stance;
    final stanceAfter = def.stance ?? stance;
    final enemyDef = data.enemy(s.enemy.id);
    final style = _styleDamage(
      def,
      attacks: s.attacksThisTurn,
      retained: s.retained.contains(uid),
      firstStrike: s.firstStrike,
      chain: s.chain,
      awakened: s.awakened,
    );
    final (dmg, str) = _cardHit(
      def,
      c.upgrades,
      stance,
      s.enemy.staggered,
      s.turnStructureBonus,
      s.fistBonus,
      style,
      _styleStructure(
        def,
        attacks: s.attacksThisTurn,
        retained: s.retained.contains(uid),
        awakened: s.awakened,
      ),
    );
    final dealt = _enemyDamageTaken(
      enemyDef,
      s.enemy.staggered,
      s.enemy.scales,
      dmg,
    );
    final (sDmg, sStr, sGuard, sCost) = _stanceDelta(def, c.upgrades, stance);
    final advances = <String>[],
        completes = <String>[],
        interrupts = <String>[];
    for (final f in knownForms(s)) {
      final p = s.formProgress[f.id]!;
      if (f.steps[p] == def.id) {
        (p + 1 == f.steps.length ? completes : advances).add(f.id);
      } else if (def.type.isAttack && p > (f.steps.first == def.id ? 1 : 0)) {
        // Solo avisa si se pierde progreso (reiniciar en el paso 1 desde 1 no).
        interrupts.add(f.id);
      }
    }
    return CardPreview(
      cost: costOf(s, def, uid),
      playable: validate(s, PlayCard(uid)) == null,
      reason: validate(s, PlayCard(uid)),
      damage: dealt,
      structure: s.enemy.staggered ? 0 : str,
      guard: _guardOf(def, c.upgrades, stance, s.awakened.guardBonus),
      height: def.height,
      stanceAfter: stanceAfter,
      advancesForms: advances,
      completesForms: completes,
      interruptsForms: interrupts,
      stanceDamage: dmg > 0 ? sDmg : 0,
      stanceStructure: s.enemy.staggered ? 0 : sStr,
      stanceGuard: sGuard,
      stanceCost: sCost,
      styleDamage: style,
      retained: s.retained.contains(uid),
    );
  }

  IntentDef currentIntent(EnemyCombat e) =>
      data.enemy(e.id).phases[e.phaseIndex].pattern[e.patternIndex];

  IntentView intentView(CombatState s) {
    final e = s.enemy;
    final def = data.enemy(e.id);
    final intent = currentIntent(e);
    final punish = s.punishPending ? 1 : 0;
    final pattern = def.phases[e.phaseIndex].pattern;
    final cdIndex = pattern.indexWhere((i) => i.countdown);
    int? countdown;
    if (cdIndex >= 0) {
      countdown = (cdIndex - e.patternIndex) % pattern.length;
    }
    final isAttack = intent.kind == IntentKind.attack;
    return IntentView(
      intent: intent,
      damage: isAttack
          ? _enemyDamage(
              intent.damage +
                  e.chargeBonus +
                  e.wrath +
                  punish * def.sameStancePunishDamage,
              s.enemyDamagePct,
            )
          : 0,
      structure: isAttack
          ? intent.structure + punish * def.sameStancePunishStructure
          : 0,
      skipped: e.skipNextAction,
      countdown: countdown,
      punishIfSameStance:
          def.sameStancePunishDamage > 0 &&
          s.lastTurnEndStance != null &&
          s.lastTurnEndStance == s.player.stance,
      stolen: e.stolen,
    );
  }

  // --------------------------------------------------------------- jugar

  void _playCard(_Draft d, int uid, List<CombatEvent> events) {
    final card = d.hand.firstWhere((c) => c.uid == uid);
    final def = data.card(card.cardId);
    final wasRetained = d.retained.remove(uid);
    d.breath -= _cost(
      def,
      d.stance,
      (wasRetained ? d.retainedDiscount : 0) +
          _firstStrikeDiscount(def, d.attacksThisTurn, d.awakened),
    );
    d.hand.remove(card);
    events.add(CardPlayed(def.id));

    final g = _guardOf(def, card.upgrades, d.stance, d.awakened.guardBonus);
    if (def.type == CardType.defense) {
      d.guard += g;
      d.guardHeight = def.height;
      d.deflectBonusDamage += def.onDeflectDamage;
      d.deflectBonusStructure += def.onDeflectStructure;
      events.add(GuardGained(g, def.height));
    }

    final (dmg, str) = _cardHit(
      def,
      card.upgrades,
      d.stance,
      d.enemy.staggered,
      d.turnStructureBonus,
      d.fistBonus,
      _styleDamage(
        def,
        attacks: d.attacksThisTurn,
        retained: wasRetained,
        firstStrike: d.firstStrike,
        chain: d.chain,
        awakened: d.awakened,
      ),
      _styleStructure(
        def,
        attacks: d.attacksThisTurn,
        retained: wasRetained,
        awakened: d.awakened,
      ),
    );
    if (def.type.isAttack) {
      d.attacksThisTurn++;
      // Despertar de la Serpiente: el tercer ataque del turno roba.
      if (d.attacksThisTurn == 3 && d.awakened.thirdAttackDraw > 0) {
        _draw(d, d.awakened.thirdAttackDraw, events);
      }
    }
    if (dmg > 0 && d.enemy.parryReady && !d.enemy.staggered) {
      _parry(d, str, events);
    } else if (dmg > 0 || str > 0) {
      final staggered = d.enemy.staggered;
      _hitEnemy(d, dmg, str, events, def.type);
      if (dmg > 0 && !staggered && !d.isOver) _thorns(d, events);
    }
    if (d.isOver) return;

    if (def.clearGuard) {
      d.guard = 0;
      d.guardHeight = null;
    }

    // Pega con la postura en la que estabas; recién después te deja en la
    // de la carta. Así preparar la postura (con otra carta o Paso en T) paga.
    if (def.stance != null && def.stance != d.stance) {
      d.stance = def.stance!;
      events.add(StanceChanged(d.stance));
    }
    d.breath += def.gainBreath;
    d.turnStructureBonus += def.turnStructureBonus;

    (def.exhaust ? d.exhausted : d.discard).add(card);
    if (def.draw > 0) _draw(d, def.draw, events);

    if (!d.isOver) _advanceForms(d, def, events);
  }

  void _advanceForms(_Draft d, CardDef def, List<CombatEvent> events) {
    for (final f in data.forms) {
      final p = d.formProgress[f.id];
      if (p == null) continue;
      if (f.steps[p] == def.id) {
        if (p + 1 == f.steps.length) {
          d.formProgress[f.id] = 0;
          d.formsCompleted[f.id] = (d.formsCompleted[f.id] ?? 0) + 1;
          events.add(FormCompleted(f.id));
          _applyForm(d, f.effect, events);
          if (d.isOver) return;
          _talismansOnForm(d, events);
        } else {
          d.formProgress[f.id] = p + 1;
          events.add(FormAdvanced(f.id, p + 1));
        }
      } else if (def.type.isAttack) {
        final restart = f.steps.first == def.id ? 1 : 0;
        if (p > 0) events.add(FormInterrupted(f.id));
        d.formProgress[f.id] = restart;
        if (restart == 1) events.add(FormAdvanced(f.id, 1));
      }
    }
  }

  void _applyForm(_Draft d, FormEffect fx, List<CombatEvent> events) {
    if (fx.damage > 0 || fx.structure > 0) {
      _hitEnemy(d, fx.damage, fx.structure + d.turnStructureBonus, events);
    }
    if (fx.guard > 0) {
      d.guard += fx.guard;
      d.guardHeight = fx.height ?? d.guardHeight;
      events.add(GuardGained(fx.guard, fx.height));
    }
    if (fx.heal > 0) {
      final healed = math.min(fx.heal, d.maxHp - d.hp);
      d.hp += healed;
      events.add(PlayerHealed(healed));
    }
    if (fx.breath > 0) {
      d.breath += fx.breath;
      events.add(BreathGained(fx.breath));
    }
    if (fx.fistBonus > 0) {
      d.fistBonus += fx.fistBonus;
      events.add(FistBonusGained(fx.fistBonus, d.fistBonus));
    }
    if (fx.draw > 0) _draw(d, fx.draw, events);
  }

  void _talismansOnForm(_Draft d, List<CombatEvent> events) {
    for (final id in d.talismans) {
      final heal = data.talisman(id).effect.formHeal;
      if (heal <= 0) continue;
      final healed = math.min(heal, d.maxHp - d.hp);
      events.add(TalismanTriggered(id));
      if (healed > 0) {
        d.hp += healed;
        events.add(PlayerHealed(healed));
      }
    }
  }

  /// [type]: tipo de la carta; una Guardia que frena un solo tipo deja
  /// pasar los otros (las formas y los desvíos, sin tipo, sí los frena).
  void _hitEnemy(
    _Draft d,
    int dmg,
    int str,
    List<CombatEvent> events, [
    CardType? type,
  ]) {
    final e = d.enemy;
    final def = data.enemy(e.id);
    var taken = dmg == 0
        ? 0
        : _enemyDamageTaken(def, e.staggered, e.scales, dmg);
    final covers =
        e.guardBlocks == null || type == null || type == e.guardBlocks;
    if (!covers && e.guard > 0 && taken > 0) events.add(const GuardBypassed());
    final absorbed = covers ? math.min(e.guard, taken) : 0;
    e.guard -= absorbed;
    taken -= absorbed;
    e.hp = math.max(0, e.hp - taken);
    final strTaken = e.staggered ? 0 : math.min(str, e.structure);
    e.structure -= strTaken;
    events.add(EnemyDamaged(taken, strTaken, absorbed: absorbed));
    if (e.hp == 0) {
      d.phase = CombatPhase.won;
      events.add(const Victory());
      return;
    }
    if (!e.staggered && e.structure == 0) _breakEnemy(d, events);
    _checkEnemyPhase(d, events);
  }

  /// Espinas: golpearlo con una carta te lastima.
  void _thorns(_Draft d, List<CombatEvent> events) {
    final n = data.enemy(d.enemy.id).thorns;
    if (n <= 0) return;
    d.hp = math.max(0, d.hp - n);
    events.add(ThornsHurt(n));
    if (d.hp == 0) {
      d.phase = CombatPhase.lost;
      events.add(const Defeat());
    }
  }

  void _breakEnemy(_Draft d, List<CombatEvent> events) {
    final e = d.enemy;
    e.staggered = true;
    e.skipNextAction = true;
    e.staggerEndsTurn = d.turn + 1;
    events.add(const EnemyBroken());
    // Despertar del Tigre: desequilibrar roba.
    if (d.awakened.breakDraw > 0) _draw(d, d.awakened.breakDraw, events);
    if (e.wrath > 0) {
      e.wrath = 0;
      events.add(const WrathCalmed());
    }
    if (e.scales > 0) {
      e.scales--;
      events.add(ScaleShed(e.scales));
    }
  }

  /// Abanico: el golpe no hace daño (la Estructura sí entra) y el enemigo
  /// devuelve el suyo.
  void _parry(_Draft d, int str, List<CombatEvent> events) {
    final back = data.enemy(d.enemy.id).parry;
    d.enemy.parryReady = false;
    events.add(Parried(back));
    if (str > 0) _hitEnemy(d, 0, str, events);
    if (d.isOver) return;
    d.hp = math.max(0, d.hp - back);
    if (d.hp == 0) {
      d.phase = CombatPhase.lost;
      events.add(const Defeat());
    }
  }

  void _checkEnemyPhase(_Draft d, List<CombatEvent> events) {
    final e = d.enemy;
    final phases = data.enemy(e.id).phases;
    for (var i = e.phaseIndex + 1; i < phases.length; i++) {
      final t = phases[i].hpThreshold;
      if (t != null && e.hp <= e.maxHp * t) {
        e.phaseIndex = i;
        e.patternIndex = 0;
        events.add(EnemyPhaseChanged(i));
        final regrow = phases[i].scales;
        if (regrow != null && e.scales < regrow) {
          e.scales = regrow;
          events.add(ScalesRegrown(regrow));
        }
      }
    }
  }

  // ------------------------------------------------------------- turnos

  void _endTurn(_Draft d, Set<int> retain, List<CombatEvent> events) {
    final kept = d.hand.where((c) => retain.contains(c.uid)).toList();
    d.discard.addAll(d.hand.where((c) => !retain.contains(c.uid)));
    d.hand
      ..clear()
      ..addAll(kept);
    d.retained
      ..clear()
      ..addAll(kept.map((c) => c.uid));

    final enemyDef = data.enemy(d.enemy.id);
    if (enemyDef.sameStancePunishDamage > 0 &&
        d.lastTurnEndStance != null &&
        d.lastTurnEndStance == d.stance) {
      d.punishPending = true;
    }
    d.lastTurnEndStance = d.stance;
    d.turnStructureBonus = 0;

    final e = d.enemy;
    if (e.staggered && e.staggerEndsTurn <= d.turn) {
      e.staggered = false;
      e.structure = e.maxStructure;
      events.add(const EnemyRecovered());
    }

    _enemyAct(d, events);
    if (d.isOver) return;
    _startPlayerTurn(d, events);
  }

  void _enemyAct(_Draft d, List<CombatEvent> events) {
    final e = d.enemy;
    final def = data.enemy(e.id);
    e.guard = 0;
    e.guardBlocks = null;
    final phaseBefore = e.phaseIndex;
    if (e.skipNextAction) {
      e.skipNextAction = false;
      events.add(const EnemyActionSkipped());
    } else {
      final healed = math.min(def.regen, e.maxHp - e.hp);
      if (healed > 0) {
        e.hp += healed;
        events.add(EnemyRegenerated(healed));
      }
      final intent = currentIntent(e.freeze());
      switch (intent.kind) {
        case IntentKind.attack:
          _enemyAttack(d, def, intent, events);
        case IntentKind.guard:
          e.guard = intent.value;
          e.guardBlocks = intent.blocks;
          events.add(EnemyGuarded(intent.value, intent.blocks));
        case IntentKind.charge:
          e.chargeBonus += intent.value;
          events.add(EnemyCharged(intent.value));
        case IntentKind.discard:
          d.pendingDiscard += intent.count;
        case IntentKind.flee:
          e.fled = true;
          d.phase = CombatPhase.won;
          events.add(EnemyFled(e.stolen));
          return;
      }
      if (def.wrath > 0 && !d.isOver) {
        e.wrath += def.wrath;
        events.add(EnemyEnraged(e.wrath));
      }
    }
    if (d.isOver) return;
    // Si cambió de fase durante su acción, la nueva fase arranca en el paso 0.
    if (e.phaseIndex != phaseBefore) return;
    final pattern = def.phases[e.phaseIndex].pattern;
    e.patternIndex = (e.patternIndex + 1) % pattern.length;
  }

  void _enemyAttack(
    _Draft d,
    EnemyDef def,
    IntentDef intent,
    List<CombatEvent> events,
  ) {
    final e = d.enemy;
    var damage = intent.damage + e.chargeBonus + e.wrath;
    var structure = intent.structure;
    e.chargeBonus = 0;
    if (d.punishPending) {
      damage += def.sameStancePunishDamage;
      structure += def.sameStancePunishStructure;
      d.punishPending = false;
    }
    damage = _enemyDamage(damage, d.enemyDamagePct);
    final stance = data.stance(d.stance);
    final match = d.guard > 0 && d.guardHeight == intent.height;
    // La Guardia no se consume: en un ataque doble se aplica a cada golpe,
    // así que si desvía uno los desvía todos. El desvío premia una vez por acción.
    if (match && d.guard >= damage) {
      d.deflects++;
      events.add(const Deflected());
      d.nextTurnBreathMod += data.balance.deflectBreathBonus +
          stance.deflectBreathBonus +
          d.awakened.deflectBreath;
      for (final id in d.talismans) {
        final extra = data.talisman(id).effect.deflectBreath;
        if (extra > 0) {
          d.nextTurnBreathMod += extra;
          events.add(TalismanTriggered(id));
        }
      }
      _hitEnemy(
        d,
        d.deflectBonusDamage,
        data.balance.deflectEnemyStructureLoss + d.deflectBonusStructure,
        events,
      );
      return;
    }
    final absorb = d.guard == 0 ? 0 : (match ? d.guard : d.guard ~/ 2);
    final blocked = d.guard > 0;
    for (var hit = 0; hit < intent.hits; hit++) {
      final taken = math.max(0, damage - absorb);
      var s = blocked ? structure ~/ 2 : structure;
      s = (s * stance.incomingStructureMultiplier).floor();
      if (s > 0) s += stance.incomingStructureBonus;
      d.hp = math.max(0, d.hp - taken);
      d.structure = math.max(0, d.structure - s);
      events.add(PlayerHit(taken, s, blocked: blocked));
      if (taken > 0 && def.steal > 0) {
        e.stolen += def.steal;
        events.add(JadeStolen(def.steal, e.stolen));
      }
      if (d.hp == 0) {
        d.phase = CombatPhase.lost;
        events.add(const Defeat());
        return;
      }
      if (d.structure == 0) {
        d.nextTurnBreathMod -= data.balance.playerBreakBreathPenalty;
        d.structure = d.maxStructure;
        events.add(const PlayerBroken());
      }
    }
    if (intent.interrupt) {
      d.formProgress.updateAll((_, _) => 0);
      events.add(const FormsResetByEnemy());
    }
    if (intent.drain > 0) {
      d.nextTurnBreathMod -= intent.drain;
      events.add(BreathDrained(intent.drain));
    }
    if (intent.freeze > 0) {
      d.drawPenalty += intent.freeze;
      events.add(HandFrozen(intent.freeze));
    }
  }

  void _startPlayerTurn(_Draft d, List<CombatEvent> events) {
    d.turn++;
    d.guard = 0;
    d.guardHeight = null;
    d.deflectBonusDamage = 0;
    d.deflectBonusStructure = 0;
    d.dingbuUsed = false;
    d.attacksThisTurn = 0;
    d.enemy.parryReady = data.enemy(d.enemy.id).parry > 0;
    d.breath = math.max(0, d.breathPerTurn + d.nextTurnBreathMod);
    d.nextTurnBreathMod = 0;
    events.add(TurnStarted(d.turn, d.breath));
    // Las cartas retenidas son extra: siempre se roba la mano completa
    // (menos la escarcha, pero nunca menos de una carta).
    _draw(d, math.max(1, d.handSize - d.drawPenalty), events);
    d.drawPenalty = 0;
    if (d.pendingDiscard > 0 && d.hand.isNotEmpty) {
      d.pendingDiscard = math.min(d.pendingDiscard, d.hand.length);
      d.phase = CombatPhase.discarding;
      events.add(DiscardRequired(d.pendingDiscard));
    } else {
      d.pendingDiscard = 0;
    }
  }

  void _draw(_Draft d, int n, List<CombatEvent> events) {
    var drawn = 0;
    for (var i = 0; i < n; i++) {
      if (d.drawPile.isEmpty) {
        if (d.discard.isEmpty) break;
        final (shuffled, rng) = d.rng.shuffle(d.discard);
        d.rng = rng;
        d.drawPile.addAll(shuffled);
        d.discard.clear();
        events.add(const DeckShuffled());
      }
      d.hand.add(d.drawPile.removeAt(0));
      drawn++;
    }
    if (drawn > 0) events.add(CardsDrawn(drawn));
  }
}

// ------------------------------------------------------------------ drafts

class _EnemyDraft {
  _EnemyDraft({
    required this.id,
    required this.hp,
    required this.maxHp,
    required this.structure,
    required this.maxStructure,
    this.guard = 0,
    this.phaseIndex = 0,
    this.patternIndex = 0,
    this.staggered = false,
    this.staggerEndsTurn = 0,
    this.skipNextAction = false,
    this.chargeBonus = 0,
    this.scales = 0,
    this.wrath = 0,
    this.parryReady = false,
    this.stolen = 0,
    this.fled = false,
    this.guardBlocks,
  });

  factory _EnemyDraft.of(EnemyCombat e) => _EnemyDraft(
    id: e.id,
    hp: e.hp,
    maxHp: e.maxHp,
    structure: e.structure,
    maxStructure: e.maxStructure,
    guard: e.guard,
    phaseIndex: e.phaseIndex,
    patternIndex: e.patternIndex,
    staggered: e.staggered,
    staggerEndsTurn: e.staggerEndsTurn,
    skipNextAction: e.skipNextAction,
    chargeBonus: e.chargeBonus,
    scales: e.scales,
    wrath: e.wrath,
    parryReady: e.parryReady,
    stolen: e.stolen,
    fled: e.fled,
    guardBlocks: e.guardBlocks,
  );

  final String id;
  int hp;
  final int maxHp;
  int structure;
  final int maxStructure;
  int guard;
  int phaseIndex;
  int patternIndex;
  bool staggered;
  int staggerEndsTurn;
  bool skipNextAction;
  int chargeBonus;
  int scales;
  int wrath;
  bool parryReady;
  int stolen;
  bool fled;
  CardType? guardBlocks;

  EnemyCombat freeze() => EnemyCombat(
    id: id,
    hp: hp,
    maxHp: maxHp,
    structure: structure,
    maxStructure: maxStructure,
    guard: guard,
    phaseIndex: phaseIndex,
    patternIndex: patternIndex,
    staggered: staggered,
    staggerEndsTurn: staggerEndsTurn,
    skipNextAction: skipNextAction,
    chargeBonus: chargeBonus,
    scales: scales,
    wrath: wrath,
    parryReady: parryReady,
    stolen: stolen,
    fled: fled,
    guardBlocks: guardBlocks,
  );
}

class _Draft {
  _Draft({
    required this.turn,
    required this.phase,
    required this.handSize,
    required this.breathPerTurn,
    required this.retainMax,
    required this.hp,
    required this.maxHp,
    required this.structure,
    required this.maxStructure,
    required this.guard,
    required this.guardHeight,
    required this.stance,
    required this.breath,
    required this.enemy,
    required this.drawPile,
    required this.hand,
    required this.discard,
    required this.exhausted,
    required this.breathesLeft,
    required this.formProgress,
    required this.rng,
    this.nextTurnBreathMod = 0,
    this.dingbuUsed = false,
    this.turnStructureBonus = 0,
    this.deflectBonusDamage = 0,
    this.deflectBonusStructure = 0,
    this.lastTurnEndStance,
    this.punishPending = false,
    this.pendingDiscard = 0,
    Map<String, int>? formsCompleted,
    this.deflects = 0,
    this.enemyDamagePct = 100,
    this.fistBonus = 0,
    this.talismans = const [],
    this.firstStrike = 0,
    this.chain = 0,
    this.retainedDiscount = 0,
    this.attacksThisTurn = 0,
    this.drawPenalty = 0,
    this.awakened = AwakeningEffect.none,
    List<int>? retained,
  }) : formsCompleted = formsCompleted ?? {},
       retained = retained ?? [];

  factory _Draft.of(CombatState s) => _Draft(
    turn: s.turn,
    phase: s.phase,
    handSize: s.handSize,
    breathPerTurn: s.breathPerTurn,
    retainMax: s.retainMax,
    hp: s.player.hp,
    maxHp: s.player.maxHp,
    structure: s.player.structure,
    maxStructure: s.player.maxStructure,
    guard: s.player.guard,
    guardHeight: s.player.guardHeight,
    stance: s.player.stance,
    breath: s.player.breath,
    enemy: _EnemyDraft.of(s.enemy),
    drawPile: [...s.drawPile],
    hand: [...s.hand],
    discard: [...s.discard],
    exhausted: [...s.exhausted],
    breathesLeft: s.breathesLeft,
    formProgress: {...s.formProgress},
    rng: s.rng,
    nextTurnBreathMod: s.nextTurnBreathMod,
    dingbuUsed: s.dingbuUsed,
    turnStructureBonus: s.turnStructureBonus,
    deflectBonusDamage: s.deflectBonusDamage,
    deflectBonusStructure: s.deflectBonusStructure,
    lastTurnEndStance: s.lastTurnEndStance,
    punishPending: s.punishPending,
    pendingDiscard: s.pendingDiscard,
    formsCompleted: {...s.formsCompleted},
    deflects: s.deflects,
    enemyDamagePct: s.enemyDamagePct,
    fistBonus: s.fistBonus,
    talismans: s.talismans,
    firstStrike: s.firstStrike,
    chain: s.chain,
    retainedDiscount: s.retainedDiscount,
    attacksThisTurn: s.attacksThisTurn,
    drawPenalty: s.drawPenalty,
    awakened: s.awakened,
    retained: [...s.retained],
  );

  int turn;
  CombatPhase phase;
  final int handSize;
  final int breathPerTurn;
  final int retainMax;
  int hp;
  final int maxHp;
  int structure;
  final int maxStructure;
  int guard;
  Height? guardHeight;
  Stance stance;
  int breath;
  final _EnemyDraft enemy;
  final List<CombatCard> drawPile;
  final List<CombatCard> hand;
  final List<CombatCard> discard;
  final List<CombatCard> exhausted;
  int breathesLeft;
  final Map<String, int> formProgress;
  Rng rng;
  int nextTurnBreathMod;
  bool dingbuUsed;
  int turnStructureBonus;
  int deflectBonusDamage;
  int deflectBonusStructure;
  Stance? lastTurnEndStance;
  bool punishPending;
  int pendingDiscard;
  final Map<String, int> formsCompleted;
  int deflects;
  final int enemyDamagePct;
  int fistBonus;
  final List<String> talismans;
  final int firstStrike;
  final int chain;
  final int retainedDiscount;
  int attacksThisTurn;
  int drawPenalty;
  final AwakeningEffect awakened;
  final List<int> retained;

  bool get isOver => phase == CombatPhase.won || phase == CombatPhase.lost;

  CombatState freeze() => CombatState(
    turn: turn,
    phase: phase,
    handSize: handSize,
    breathPerTurn: breathPerTurn,
    retainMax: retainMax,
    player: PlayerCombat(
      hp: hp,
      maxHp: maxHp,
      structure: structure,
      maxStructure: maxStructure,
      guard: guard,
      guardHeight: guardHeight,
      stance: stance,
      breath: breath,
    ),
    enemy: enemy.freeze(),
    drawPile: List.unmodifiable(drawPile),
    hand: List.unmodifiable(hand),
    discard: List.unmodifiable(discard),
    exhausted: List.unmodifiable(exhausted),
    nextTurnBreathMod: nextTurnBreathMod,
    dingbuUsed: dingbuUsed,
    breathesLeft: breathesLeft,
    turnStructureBonus: turnStructureBonus,
    deflectBonusDamage: deflectBonusDamage,
    deflectBonusStructure: deflectBonusStructure,
    lastTurnEndStance: lastTurnEndStance,
    punishPending: punishPending,
    formProgress: Map.unmodifiable(formProgress),
    pendingDiscard: pendingDiscard,
    formsCompleted: Map.unmodifiable(formsCompleted),
    deflects: deflects,
    rng: rng,
    enemyDamagePct: enemyDamagePct,
    fistBonus: fistBonus,
    talismans: talismans,
    firstStrike: firstStrike,
    chain: chain,
    retainedDiscount: retainedDiscount,
    attacksThisTurn: attacksThisTurn,
    retained: List.unmodifiable(retained),
    drawPenalty: drawPenalty,
    awakened: awakened,
  );
}
