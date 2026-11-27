import 'dart:math' as math;

import '../model/awakening_def.dart';
import '../model/card_def.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/room.dart';
import '../model/form_def.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../model/meta_bonus.dart';
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
  badTarget,
  mustBreathe,
  noBreather,
  structureFull,
  noCounter,
  flowFull,
  noTechnique,
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
    this.chained = false,
    this.closesCircle = false,
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

  /// Se juega desde la postura que pide: encadena y suma su extra.
  final bool chained;

  /// Encadena desde la última postura que faltaba este turno: cierra el
  /// círculo.
  final bool closesCircle;
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
    this.guardBlocks,
    this.hidden = false,
    this.reaction,
  });

  final IntentDef intent;

  /// Niebla: no se sabe qué va a hacer.
  final bool hidden;

  /// Cambió de intención por una reacción (null: sigue su ciclo).
  final Reaction? reaction;

  /// Tipo que frenaría la guardia (resuelve la guardia espejo).
  final CardType? guardBlocks;

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
    // Null = sin ajustes de dificultad: lecciones, muñecos y tests.
    Difficulty? difficulty,
    int pico = 0,
    int stage = 0,
    int? maxHp,
    Iterable<String>? forms,
    List<String> talismans = const [],
    String? weapon,
    int weaponLevel = 1,
    List<String> awakenings = const [],
    List<String> waves = const [],
    // Con [together], los de [waves] entran junto al primero (no en oleadas).
    bool together = false,
    // Dones de la escuela (reinos y meridianos).
    MetaBonus meta = MetaBonus.none,
    // Rivales cuya historia ya se conoce: arrancan dudando.
    Set<String> revealed = const {},
    int revealedPct = 100,
    // Condición de la sala y reto opcional (peleas comunes).
    RoomRule? room,
    Challenge? challenge,
    // Atajo de Shuang: los rivales arrancan con este % menos de Vida.
    int weakenPct = 0,
    // Cuesta empinada: Aliento de menos en el primer turno.
    int breathToll = 0,
  }) {
    final b = data.balance;
    final styleStats = b.statsOf(style);
    final aw = b.awakeningsEffect(awakenings);
    final dif = difficulty == null
        ? const DifficultyDef(hanzi: '', playerHp: 0, fountainHeal: 0)
        : b.difficulty(difficulty);
    // Los Picos se suman encima de la dificultad.
    final pm = b.picoMods(pico) +
        (stage < b.stages.length ? b.stages[stage].enemyMods : const PicoDef());
    // Campanas de los Picos: élites y jefes pelean con la de las salas.
    final picoRoom = room ??
        (pm.bells > 0 && data.enemy(enemyId).rank != EnemyRank.common
            ? RoomRule.bell
            : null);
    int pct(int v, int p, [int extra = 0]) =>
        (v * p * (100 + extra) / 10000).round();
    final wfx = weapon == null
        ? null
        : data.weapon(weapon).effectAt(weaponLevel, style);
    final effects = [
      for (final id in talismans) data.talisman(id).effect,
      ?wfx,
    ];
    int sum(int Function(TalismanEffect e) of) =>
        effects.fold(0, (a, e) => a + of(e));
    // En un grupo cada enemigo trae menos Vida: si no, el nodo dura el doble.
    final pair = together && waves.isNotEmpty;
    // Élite con escolta: el élite casi entero y el que lo acompaña, liviano.
    final escorted = pair && data.enemy(enemyId).rank == EnemyRank.elite;
    final packHp = pair ? b.packTogetherHp : b.packHpPct(1 + waves.length);
    _EnemyDraft spawn(String id) {
      final enemy = data.enemy(id);
      final rankHp = pm.enemyHp +
          switch (enemy.rank) {
            EnemyRank.common => pm.commonHp,
            EnemyRank.elite => pm.eliteHp,
            EnemyRank.boss => pm.bossHp,
          };
      final hp = pct(
        pct(enemy.hp, dif.enemyHp, rankHp),
        !escorted
            ? packHp
            : enemy.rank == EnemyRank.elite
            ? b.escortEliteHp
            : b.escortHp,
      );
      final structure =
          pct(enemy.structure, dif.enemyStructure, pm.enemyStructure);
      final elite = enemy.rank == EnemyRank.elite;
      final second =
          elite && pm.eliteSecond > 0 ? enemy.second : const EliteSecond(thorns: 0);
      return _EnemyDraft(
        id: enemy.id,
        hp: math.max(
          1,
          hp * (100 - weakenPct) ~/ 100 - sum((e) => e.enemyHp) - meta.enemyHp,
        ),
        maxHp: hp,
        structure: math.max(
            1,
            (revealed.contains(enemy.id)
                    ? (structure * revealedPct / 100).round()
                    : structure) -
                sum((e) => e.enemyStructure) -
                meta.enemyStructure),
        maxStructure: structure,
        scales: enemy.scales,
        // Picos: arranca cubierto; el élite, con espinas y su segunda
        // pregunta; el jefe, con una fase de más.
        guard: pm.enemyGuard,
        thorns: elite ? pm.eliteThorns + second.thorns : 0,
        regen: elite ? second.regen : 0,
        furyStep: pm.fury + (elite ? second.fury : 0),
        extraPhase: enemy.rank == EnemyRank.boss && pm.bossPhase > 0,
      );
    }
    final extraStructure = sum((e) => e.structure) + meta.structure;
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
      handSize: math.max(
          1, styleStats.draw + aw.draw + sum((e) => e.handSize) + meta.handSize),
      breathPerTurn: styleStats.breath + sum((e) => e.turnBreath) + meta.turnBreath,
      retainMax: styleStats.retain + aw.retain + meta.retain,
      hp: playerHp,
      maxHp: maxHp ?? b.playerHp,
      structure: b.playerStructure + extraStructure,
      maxStructure: b.playerStructure + extraStructure,
      guard: 0,
      guardHeight: null,
      stance: startStance,
      breath: 0,
      enemies: [
        spawn(enemyId),
        if (together) for (final id in waves) spawn(id),
      ],
      reserve: together ? [] : [for (final id in waves) spawn(id).freeze()],
      drawPile: [...shuffled],
      hand: [],
      discard: [],
      exhausted: [],
      breathesLeft: math.max(0, b.breathesPerCombat + meta.breathes + pm.breathes),
      // Solo las formas que conoce (null = todas: tests y herramientas).
      formProgress: {
        for (final f in data.forms)
          if (forms == null || forms.contains(f.id)) f.id: 0,
      },
      rng: rng,
      // Dos a la vez pegan menos cada uno: si no, el turno enemigo es doble.
      enemyDamagePct: pct(
        pct(dif.enemyDamage, 100, pm.enemyDamage),
        escorted
            ? b.escortDamage
            : pair
            ? b.packTogetherDamage
            : 100,
      ),
      talismans: talismans,
      weapon: weapon,
      weaponLevel: weaponLevel,
      weaponEffect: wfx,
      nextTurnBreathMod:
          sum((e) => e.firstTurnBreath) + meta.firstTurnBreath - breathToll,
      firstStrike: styleStats.firstStrike + aw.firstStrike + meta.firstStrike,
      chain: styleStats.chain + aw.chain + meta.chain,
      retainedDiscount: styleStats.retainedDiscount + aw.retainedDiscount,
      awakened: aw,
      style: style,
      trial: picoRoom == null && challenge == null && pm.fog <= 0 && pm.thinAir <= 0
          ? Trial.none
          : Trial(
              room: picoRoom,
              fogOpening: pm.fog > 0,
              thinAir: math.max(0, pm.thinAir),
              challenge: challenge,
              startHp: playerHp,
              swiftTurns: b.rooms.swiftTurns,
              bellEvery: b.rooms.bellEvery,
              bellDamage: b.rooms.bellDamageAt(stage),
              windDiscount: b.rooms.windDiscount,
            ),
    );
    final events = <CombatEvent>[
      for (final id in talismans)
        if (data.talisman(id).effect.atStart) TalismanTriggered(id),
      if (wfx != null && wfx.atStart) const WeaponTriggered(),
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
      case Target(:final index):
        d.target = d.cur = index;
        events.add(TargetChanged(index));
      case Dingbu(:final stance):
        d.breath -= dingbuCost(state);
        d.dingbuUsed = true;
        d.stance = stance;
        _stanceChanged(d, events);
      case Breathe(:final mode):
        final b = data.balance;
        d.breathesLeft--;
        events.add(Breathed(mode));
        // Aire fino: respirar lo despeja por el resto de la pelea.
        if (d.trial.thinAir > 0) d.trial = d.trial.copyWith(thinAir: 0);
        switch (mode) {
          case BreatheMode.hand:
            // Con la mano vacía (o casi) igual trae cartas nuevas.
            final n = math.max(d.hand.length, b.breatheMinDraw);
            d.discard.addAll(d.hand);
            d.hand.clear();
            d.retained.clear();
            d.breath -= b.breatheCost;
            _draw(d, n, events);
          case BreatheMode.breath:
            d.breath += b.breatheBreath;
            events.add(BreathGained(b.breatheBreath));
          case BreatheMode.structure:
            final n = math.min(b.breatheStructure, d.maxStructure - d.structure);
            d.structure += n;
            events.add(StructureRecovered(n));
        }
      case Counter(:final mode):
        final b = data.balance;
        d.counterReady = false;
        events.add(Countered(mode));
        switch (mode) {
          case CounterMode.free:
            d.counterFree = true;
          case CounterMode.draw:
            _draw(d, b.counterDraw, events);
          case CounterMode.flow:
            _flow(d, 1, FlowCause.counter, events);
        }
      case Technique():
        _technique(d, events);
      case EndTurn(:final retain):
        _endTurn(d, retain.toSet(), events);
      case ChooseDiscard(:final uid):
        final card = d.hand.firstWhere((c) => c.uid == uid);
        d.hand.remove(card);
        d.retained.remove(uid);
        d.discard.add(card);
        d.pendingDiscard--;
        if (d.pendingDiscard == 0) d.phase = CombatPhase.playerTurn;
      case ChooseBreather(:final breather):
        _takeBreather(d, breather, events);
        d.phase = d.pendingDiscard > 0
            ? CombatPhase.discarding
            : CombatPhase.playerTurn;
        _nextWave(d, events);
    }
    _settle(d, events);
    _watchChallenge(d, events);
    return CombatResult(d.freeze(), events);
  }

  /// Después de cada acción: si cayó el apuntado y queda otro en escena, se
  /// apunta a ese; si no queda ninguno, entra la siguiente oleada.
  void _settle(_Draft d, List<CombatEvent> events) {
    if (d.isOver) return;
    if (d.enemies.length > 1) {
      d.enemyDown = false;
      if (d.enemies[d.target].hp == 0) {
        d.target = d.cur = d.enemies.indexWhere((e) => e.hp > 0);
        events.add(TargetChanged(d.target));
      }
    } else if (d.enemyDown && d.phase != CombatPhase.breather) {
      if (breathers.isEmpty) {
        _nextWave(d, events);
      } else {
        // Antes del siguiente, un respiro: el jugador elige un premio chico.
        d.phase = CombatPhase.breather;
        events.add(BreatherOffered(breathers));
      }
    }
  }

  /// Respiros que ofrece el balance (vacío = las oleadas entran sin pausa).
  List<Breather> get breathers {
    final b = data.balance.breather;
    return [
      if (b.healPct > 0) Breather.rest,
      if (b.draw > 0 || b.breath > 0) Breather.focus,
      if (b.fist > 0) Breather.fist,
    ];
  }

  /// Lo que da cada respiro (cantidades en el balance, `packs.breather`).
  int breatherHeal(CombatState s) =>
      math.max(1, (s.player.maxHp * data.balance.breather.healPct / 100).round());

  void _takeBreather(_Draft d, Breather b, List<CombatEvent> events) {
    final cfg = data.balance.breather;
    events.add(BreatherTaken(b));
    switch (b) {
      case Breather.rest:
        final healed = math.min(
            math.max(1, (d.maxHp * cfg.healPct / 100).round()), d.maxHp - d.hp);
        if (healed > 0) {
          d.hp += healed;
          events.add(PlayerHealed(healed));
        }
      case Breather.focus:
        if (cfg.breath > 0) {
          d.breath += cfg.breath;
          events.add(BreathGained(cfg.breath));
        }
        if (cfg.draw > 0) _draw(d, cfg.draw, events);
      case Breather.fist:
        d.fistBonus += cfg.fist;
        events.add(FistBonusGained(cfg.fist, d.fistBonus));
    }
  }

  /// Cayó un enemigo del grupo: entra el siguiente. El jugador conserva todo
  /// (Vida, mano, postura, formas); se borra lo que dependía del caído.
  void _nextWave(_Draft d, List<CombatEvent> events) {
    final next = d.reserve.removeAt(0);
    d.enemy = _EnemyDraft.of(next)
      ..parryReady = data.enemy(next.id).parry > 0;
    d.wave++;
    d.enemyDown = false;
    d.punishPending = false;
    d.lastTurnEndStance = null;
    d.lastAttackType = null;
    events.add(WaveStarted(next.id, d.wave + 1, d.wave + 1 + d.reserve.length));
  }

  /// Devuelve el motivo por el que la acción no es válida, o null.
  Invalid? validate(CombatState s, CombatAction action) {
    if (s.isOver) return Invalid.combatOver;
    if (s.phase == CombatPhase.discarding && action is! ChooseDiscard) {
      return Invalid.mustDiscard;
    }
    if (s.phase == CombatPhase.breather && action is! ChooseBreather) {
      return Invalid.mustBreathe;
    }
    switch (action) {
      case Target(:final index):
        if (index < 0 ||
            index >= s.enemies.length ||
            index == s.target ||
            s.enemies[index].hp == 0) {
          return Invalid.badTarget;
        }
      case PlayCard(:final uid):
        final c = s.handCard(uid);
        if (c == null) return Invalid.notInHand;
        final def = data.card(c.cardId);
        if (def.firstTurnOnly && s.turn != 1) return Invalid.firstTurnOnly;
        if (costOf(s, def, uid) > s.player.breath) return Invalid.noBreath;
      case Dingbu(:final stance):
        if (s.dingbuUsed) return Invalid.dingbuUsed;
        if (s.player.breath < dingbuCost(s)) return Invalid.noBreath;
        if (stance == s.player.stance) return Invalid.sameStance;
      case Breathe(:final mode):
        if (s.breathesLeft <= 0) return Invalid.breatheUsed;
        if (mode == BreatheMode.hand &&
            s.player.breath < data.balance.breatheCost) {
          return Invalid.noBreath;
        }
        if (mode == BreatheMode.structure &&
            s.player.structure >= s.player.maxStructure) {
          return Invalid.structureFull;
        }
      case Counter(:final mode):
        if (!s.counterReady) return Invalid.noCounter;
        if (mode == CounterMode.flow && s.flow >= flowMax) {
          return Invalid.flowFull;
        }
      case Technique():
        if (s.style == null || s.flow < flowMax) return Invalid.noTechnique;
      case EndTurn(:final retain):
        if (retain.length > s.retainMax) return Invalid.retainTooMany;
        if (retain.any((u) => s.handCard(u) == null)) return Invalid.notInHand;
      case ChooseDiscard(:final uid):
        if (s.phase != CombatPhase.discarding) return Invalid.noDiscard;
        if (s.handCard(uid) == null) return Invalid.notInHand;
      case ChooseBreather(:final breather):
        if (s.phase != CombatPhase.breather ||
            !breathers.contains(breather)) {
          return Invalid.noBreather;
        }
    }
    return null;
  }

  /// Acciones legales (para bots). EndTurn se ofrece sin retener.
  List<CombatAction> legalActions(CombatState s) {
    if (s.isOver) return const [];
    if (s.phase == CombatPhase.discarding) {
      return [for (final c in s.hand) ChooseDiscard(c.uid)];
    }
    if (s.phase == CombatPhase.breather) {
      return [for (final b in breathers) ChooseBreather(b)];
    }
    final out = <CombatAction>[];
    final seen = <String>{};
    for (final c in s.hand) {
      if (!seen.add('${c.cardId}/${c.upgrades}')) continue;
      final a = PlayCard(c.uid);
      if (validate(s, a) == null) out.add(a);
    }
    for (final i in s.alive) {
      if (i != s.target) out.add(Target(i));
    }
    for (final st in Stance.values) {
      final a = Dingbu(st);
      if (validate(s, a) == null) out.add(a);
    }
    for (final m in BreatheMode.values) {
      final a = Breathe(m);
      if (validate(s, a) == null) out.add(a);
    }
    for (final m in CounterMode.values) {
      final a = Counter(m);
      if (validate(s, a) == null) out.add(a);
    }
    if (validate(s, const Technique()) == null) out.add(const Technique());
    out.add(const EndTurn());
    return out;
  }

  // ------------------------------------------------------------- cálculos

  /// Formas que se siguen en este combate (las que el jugador conoce).
  Iterable<FormDef> knownForms(CombatState s) =>
      data.forms.where((f) => s.formProgress.containsKey(f.id));

  /// Costo de la carta en mano; con [uid], cuenta si viene retenida.
  int costOf(CombatState s, CardDef def, [int? uid]) =>
      s.counterFree ? 0 : _cost(
    def,
    s.player.stance,
    (uid != null && s.retained.contains(uid) ? s.retainedDiscount : 0) +
        _firstStrikeDiscount(def, s.attacksThisTurn, s.awakened) +
        _firstCardDiscount(s.talismans, s.cardsThisTurn, s.weaponEffect) +
        windDiscount(s.trial, def),
  );

  /// Viento de altura: las patadas cuestan menos.
  static int windDiscount(Trial t, CardDef def) =>
      t.room == RoomRule.wind && def.type == CardType.kick
      ? t.windDiscount
      : 0;

  /// Turnos que faltan para que repique la campana (0: al terminar este
  /// turno); null si la sala no tiene campana.
  int? bellIn(CombatState s) {
    final t = s.trial;
    if (t.room != RoomRule.bell || t.bellEvery <= 0) return null;
    return (t.bellEvery - s.turn % t.bellEvery) % t.bellEvery;
  }

  /// Lugar del arma entre los talismanes del combate.
  static const _weaponSlot = '#weapon';

  /// Los talismanes del combate y, si hay, el arma (que cuenta como uno).
  List<String> _slots(List<String> ids, TalismanEffect? weapon) =>
      weapon == null ? ids : [...ids, _weaponSlot];

  TalismanEffect _fx(String id, TalismanEffect? weapon) =>
      id == _weaponSlot ? weapon! : data.talisman(id).effect;

  CombatEvent _trig(String id) =>
      id == _weaponSlot ? const WeaponTriggered() : TalismanTriggered(id);

  /// Suma un efecto de los talismanes del combate (y del arma).
  int _tal(
    List<String> ids,
    int Function(TalismanEffect e) of, [
    TalismanEffect? weapon,
  ]) =>
      ids.fold(0, (a, id) => a + of(data.talisman(id).effect)) +
      (weapon == null ? 0 : of(weapon));

  /// Al filo: con el 70% de la Vida o menos se activan los efectos de
  /// filo (más daño y Aliento).
  static bool onEdge(int hp, int maxHp) => hp > 0 && hp * 10 <= maxHp * 7;

  /// Daño extra de filo de los ataques, si el discípulo está al filo.
  int _edgeDamage(List<String> ids, TalismanEffect? weapon, int hp, int maxHp) =>
      onEdge(hp, maxHp) ? _tal(ids, (e) => e.edgeDamage, weapon) : 0;

  /// Talismán Vacío: la primera carta del turno cuesta menos.
  int _firstCardDiscount(
    List<String> talismans,
    int cards, [
    TalismanEffect? weapon,
  ]) =>
      cards == 0 ? _tal(talismans, (e) => e.firstCardDiscount, weapon) : 0;

  /// Lo que cuesta el Paso en T (algunos talismanes lo abaratan).
  int dingbuCost(CombatState s) => math.max(
    0,
    data.transition.cost -
        _tal(s.talismans, (e) => e.dingbuDiscount, s.weaponEffect),
  );

  /// Talismán Cambio: cada cambio de postura da Guardia.
  void _stanceChanged(_Draft d, List<CombatEvent> events) {
    events.add(StanceChanged(d.stance));
    for (final id in _slots(d.talismans, d.weaponEffect)) {
      final g = _fx(id, d.weaponEffect).stanceGuard;
      if (g <= 0) continue;
      d.guard += g;
      events.add(_trig(id));
      events.add(GuardGained(g, d.guardHeight));
    }
  }

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
    int heavy = 0,
    int flow = 0,
    int edge = 0,
  }) {
    if (!def.type.isAttack || def.damage == 0) return 0;
    return flowDamageOf(flow) +
        (attacks == 0 ? edge : 0) +
        (def.cost >= 2 ? heavy : 0) +
        (attacks == 0 ? firstStrike : 0) +
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
    int perAttack = 0,
  }) {
    if (!def.type.isAttack) return 0;
    return (def.damage > 0 ? perAttack : 0) +
        (def.chainStructure + awakened.chainStructure) * attacks +
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
    if (def.chainsFrom(stance)) {
      if (dmg > 0) dmg += def.fromDamage;
      str += def.fromStructure;
    }
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
    if (def.chainsFrom(stance)) {
      if (def.damage > 0) dmg += def.fromDamage;
      str += def.fromStructure;
    }
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

  /// Daño efectivo sobre el enemigo: ×2 desequilibrado (`enemyBreak`); si no, ½ inamovible
  /// y menos sus escamas.
  int _enemyDamageTaken(EnemyDef def, bool staggered, int scales, int dmg) {
    if (staggered) return (dmg * data.balance.enemyBreakDamagePct / 100).round();
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
      heavy: _tal(s.talismans, (e) => e.heavyDamage, s.weaponEffect),
      flow: s.flow,
      edge: _edgeDamage(
          s.talismans, s.weaponEffect, s.player.hp, s.player.maxHp),
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
        perAttack: _tal(s.talismans, (e) => e.attackStructure, s.weaponEffect),
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
      chained: def.chainsFrom(stance),
      closesCircle:
          def.chainsFrom(stance) &&
          _closes(s.chainedStances, stance),
    );
  }

  /// Las fases de un rival. Con [extra] (jefe de los Picos altos) se
  /// levanta una vez más: a la mitad del último umbral vuelve a su primer
  /// ciclo, recompuesto como en cualquier cambio de fase.
  List<EnemyPhase> phasesOf(String id, bool extra) {
    final phases = data.enemy(id).phases;
    if (!extra) return phases;
    return _extraPhases[id] ??= [
      ...phases,
      EnemyPhase(
        pattern: phases.first.pattern,
        hpThreshold: (phases.last.hpThreshold ?? 0.5) / 2,
        scales: phases.last.scales,
      ),
    ];
  }

  final _extraPhases = <String, List<EnemyPhase>>{};

  IntentDef currentIntent(EnemyCombat e) {
    final def = data.enemy(e.id);
    final r = e.reaction == null ? null : def.reactions[e.reaction];
    return r ?? phasesOf(e.id, e.extraPhase)[e.phaseIndex].pattern[e.patternIndex];
  }

  /// Lo que va a hacer el enemigo apuntado (o el de la posición [index]).
  IntentView intentView(CombatState s, [int? index]) {
    final e = index == null ? s.enemy : s.enemies[index];
    final def = data.enemy(e.id);
    final intent = currentIntent(e);
    final punish = s.punishPending && def.sameStancePunishDamage > 0 ? 1 : 0;
    final pattern = phasesOf(e.id, e.extraPhase)[e.phaseIndex].pattern;
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
                  e.fury +
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
      guardBlocks: intent.mirror ? s.lastAttackType : intent.blocks,
      hidden: (s.trial.room == RoomRule.fog && s.turn.isOdd) ||
          (s.trial.fogOpening && s.turn == 1),
      reaction: e.reaction,
    );
  }

  // --------------------------------------------------------------- jugar

  /// Premio por cerrar el círculo de posturas en un turno.
  static const circleBreath = 1;
  static const circleDraw = 2;

  /// Flujo: tope y lo que da cada nivel.
  static const flowMax = 3;

  /// Daño extra de cada ataque con Flujo 1 o más.
  static const flowDamage = 1;

  /// Con Flujo 2 o más, una carta más al empezar el turno.
  static const flowDrawAt = 2;

  /// Con Flujo 3, un Aliento más al empezar el turno.
  static const flowBreathAt = 3;

  static int flowDamageOf(int flow) => flow >= 1 ? flowDamage : 0;

  void _flow(_Draft d, int delta, FlowCause cause, List<CombatEvent> events) {
    final next = (d.flow + delta).clamp(0, flowMax);
    if (next == d.flow) return;
    final real = next - d.flow;
    d.flow = next;
    events.add(FlowChanged(next, real, cause));
  }

  /// Un paso de carga de Respirar. Con las cargas al tope no avanza.
  void _charge(_Draft d, ChargeCause cause, List<CombatEvent> events) {
    final b = data.balance;
    if (d.breathesLeft >= b.breatheMax) return;
    d.breathCharge++;
    final ready = d.breathCharge >= b.breatheChargeAt;
    if (ready) {
      d.breathCharge = 0;
      d.breathesLeft++;
    }
    events.add(BreatheCharged(d.breathCharge, d.breathesLeft, cause, ready: ready));
  }

  /// Encadenar desde [from] completa las tres posturas (y antes faltaba esa).
  static bool _closes(int mask, Stance from) {
    final all = (1 << Stance.values.length) - 1;
    final bit = 1 << from.index;
    return mask & bit == 0 && (mask | bit) == all;
  }

  void _playCard(_Draft d, int uid, List<CombatEvent> events) {
    final card = d.hand.firstWhere((c) => c.uid == uid);
    final def = data.card(card.cardId);
    final wasRetained = d.retained.remove(uid);
    final combo = d.attacksThisTurn >= CardDef.comboAt;
    if (d.counterFree) {
      // Contragolpe: esta carta sale gratis.
      d.counterFree = false;
    } else {
      d.breath -= _cost(
        def,
        d.stance,
        (wasRetained ? d.retainedDiscount : 0) +
            _firstStrikeDiscount(def, d.attacksThisTurn, d.awakened) +
            _firstCardDiscount(d.talismans, d.cardsThisTurn, d.weaponEffect) +
            windDiscount(d.trial, def),
      );
    }
    if (d.cardsThisTurn == 0) {
      for (final id in _slots(d.talismans, d.weaponEffect)) {
        if (_fx(id, d.weaponEffect).firstCardDiscount > 0) {
          events.add(_trig(id));
        }
      }
    }
    d.cardsThisTurn++;
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
        heavy: _tal(d.talismans, (e) => e.heavyDamage, d.weaponEffect),
        flow: d.flow,
        edge: _edgeDamage(d.talismans, d.weaponEffect, d.hp, d.maxHp),
      ),
      _styleStructure(
        def,
        attacks: d.attacksThisTurn,
        retained: wasRetained,
        awakened: d.awakened,
        perAttack: _tal(d.talismans, (e) => e.attackStructure, d.weaponEffect),
      ),
    );
    if (def.type.isAttack) {
      // Filo: el talismán suma daño al primer ataque del turno.
      if (def.damage > 0 && d.attacksThisTurn == 0 && onEdge(d.hp, d.maxHp)) {
        for (final id in _slots(d.talismans, d.weaponEffect)) {
          if (_fx(id, d.weaponEffect).edgeDamage > 0) events.add(_trig(id));
        }
      }
      d.attacksThisTurn++;
      d.lastAttackType = def.type;
      // Despertar de la Serpiente: el tercer ataque del turno roba.
      if (d.attacksThisTurn == 3 && d.awakened.thirdAttackDraw > 0) {
        _draw(d, d.awakened.thirdAttackDraw, events);
      }
      // Escama de la Serpiente: también.
      if (d.attacksThisTurn == 3) {
        for (final id in _slots(d.talismans, d.weaponEffect)) {
          final n = _fx(id, d.weaponEffect).thirdAttackDraw;
          if (n <= 0) continue;
          events.add(_trig(id));
          _draw(d, n, events);
        }
      }
    }
    final target = d.enemy;
    final wasStaggered = target.staggered;
    if (dmg > 0 && d.enemy.parryReady && !d.enemy.staggered) {
      _parry(d, str, events);
    } else if (dmg > 0 || str > 0) {
      final staggered = d.enemy.staggered;
      _hitEnemy(d, dmg, str, events, def.type);
      if (dmg > 0 && !staggered && !d.halted) _thorns(d, events);
    }
    if (d.isOver) return;

    if (def.clearGuard) {
      d.guard = 0;
      d.guardHeight = null;
    }
    final chained = def.chainsFrom(d.stance);
    if (chained) {
      events.add(StanceChained(def.id, def.chainFrom!));
      _flow(d, 1, FlowCause.chain, events);
      // Rueda de las Posturas: cada cadena da Aliento.
      for (final id in _slots(d.talismans, d.weaponEffect)) {
        final n = _fx(id, d.weaponEffect).chainBreath;
        if (n <= 0) continue;
        events.add(_trig(id));
        d.breath += n;
        events.add(BreathGained(n));
      }
      // Círculo: encadenar desde las tres posturas en un mismo turno.
      final closes = _closes(d.chainedStances, d.stance);
      d.chainedStances |= 1 << d.stance.index;
      if (closes) {
        // Despertar de la Serpiente (Muda): el círculo da más.
        final breath = circleBreath + d.awakened.circleBreath;
        final draw = circleDraw + d.awakened.circleDraw;
        events.add(StanceCircle(breath, draw));
        d.breath += breath;
        events.add(BreathGained(breath));
        _draw(d, draw, events);
      }
    }

    // Pega con la postura en la que estabas; recién después te deja en la
    // de la carta. Así preparar la postura (con otra carta o Paso en T) paga.
    if (def.stance != null && def.stance != d.stance) {
      d.stance = def.stance!;
      _stanceChanged(d, events);
    }
    d.breath +=
        def.gainBreath +
        (combo ? def.comboBreath : 0) +
        (wasRetained ? def.retainedBreath : 0) +
        (chained ? def.fromBreath : 0);
    d.turnStructureBonus += def.turnStructureBonus;
    // Quiebre (Tigre): la carta que lo desequilibra premia.
    if (!wasStaggered && target.staggered && def.breakBreath > 0) {
      d.breath += def.breakBreath;
      events.add(BreathGained(def.breakBreath));
    }

    (def.exhaust ? d.exhausted : d.discard).add(card);
    final draw =
        def.draw +
        (combo ? def.comboDraw : 0) +
        (wasRetained ? def.retainedDraw : 0) +
        (!wasStaggered && target.staggered ? def.breakDraw : 0) +
        (chained ? def.fromDraw : 0);
    if (draw > 0) _draw(d, draw, events);

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
          _flow(d, 1, FlowCause.form, events);
          _charge(d, ChargeCause.form, events);
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
    for (final id in _slots(d.talismans, d.weaponEffect)) {
      final heal = _fx(id, d.weaponEffect).formHeal;
      if (heal <= 0) continue;
      final healed = math.min(heal, d.maxHp - d.hp);
      events.add(_trig(id));
      if (healed > 0) {
        d.hp += healed;
        events.add(PlayerHealed(healed));
      }
    }
  }

  /// Técnica del Camino: gasta todo el Flujo en el remate del camino.
  void _technique(_Draft d, List<CombatEvent> events) {
    final b = data.balance;
    final style = d.style!;
    _flow(d, -flowMax, FlowCause.technique, events);
    events.add(TechniqueUsed(style));
    switch (style) {
      case Style.tiger:
        _hitEnemy(d, b.techTigerDamage, b.techTigerStructure, events);
      case Style.snake:
        for (var i = 0; i < b.techSnakeHits; i++) {
          if (d.enemyDown || d.phase == CombatPhase.won) break;
          _hitEnemy(d, b.techSnakeDamage, b.techSnakeStructure, events);
        }
      case Style.crane:
        _hitEnemy(d, b.techCraneDamage, 0, events);
        d.guard += b.techCraneGuard;
        events.add(GuardGained(b.techCraneGuard, d.guardHeight));
        _draw(d, b.techCraneDraw, events);
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
    // El enemigo ya cayó y el siguiente todavía no entró: el resto de la
    // carta no le pega a nadie.
    if (d.enemyDown) return;
    final e = d.enemy;
    final def = data.enemy(e.id);
    var taken = dmg == 0
        ? 0
        : _enemyDamageTaken(def, e.staggered, e.scales, dmg);
    final covers =
        e.guardBlocks == null || type == null || type == e.guardBlocks;
    if (!covers && e.guard > 0 && taken > 0) events.add(const GuardBypassed());
    // Espada: los ataques de carta atraviesan parte de la Guardia, que no se
    // gasta.
    final pierce = type != null && type.isAttack
        ? _tal(d.talismans, (x) => x.guardPierce, d.weaponEffect)
        : 0;
    if (covers && pierce > 0 && e.guard > 0 && taken > 0) {
      events.add(const WeaponTriggered());
    }
    final absorbed = covers ? math.min(math.max(0, e.guard - pierce), taken) : 0;
    e.guard -= absorbed;
    taken -= absorbed;
    // Fases como barreras: el golpe no pasa del próximo umbral (lo que
    // sobra se pierde) y el turno en que cambió de fase no puede caer.
    final floor = _phaseFloor(d, e, def);
    if (e.hp - taken < floor) taken = math.max(0, e.hp - floor);
    e.hp = math.max(0, e.hp - taken);
    final strTaken = e.staggered ? 0 : math.min(str, e.structure);
    e.structure -= strTaken;
    events.add(EnemyDamaged(taken, strTaken, absorbed: absorbed));
    if (e.hp == 0) {
      final others = d.enemies.any((x) => !identical(x, e) && x.hp > 0);
      if (others || d.reserve.isNotEmpty) {
        d.enemyDown = true;
        events.add(EnemyDefeated(e.id));
        for (var i = 0; i < d.enemies.length; i++) {
          if (d.enemies[i].hp > 0) _react(d, i, Reaction.allyDown, events);
        }
        return;
      }
      d.phase = CombatPhase.won;
      _judgeChallenge(d, finishedOnBreak: e.staggered, events: events);
      events.add(const Victory());
      return;
    }
    if (!e.staggered && e.structure == 0) _breakEnemy(d, events);
    _checkEnemyPhase(d, events);
  }

  /// Espinas: golpearlo con una carta te lastima.
  void _thorns(_Draft d, List<CombatEvent> events) {
    final n = data.enemy(d.enemy.id).thorns + d.enemy.thorns;
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
    _react(d, d.cur, Reaction.broken, events);
    // Despertar del Tigre: desequilibrar roba.
    if (d.awakened.breakDraw > 0) _draw(d, d.awakened.breakDraw, events);
    // Talismán Quiebre: también roba.
    for (final id in _slots(d.talismans, d.weaponEffect)) {
      final n = _fx(id, d.weaponEffect).breakDraw;
      if (n <= 0) continue;
      events.add(_trig(id));
      _draw(d, n, events);
    }
    // Garra del Tigre: el desequilibrio duele (y entra doble).
    for (final id in _slots(d.talismans, d.weaponEffect)) {
      final n = _fx(id, d.weaponEffect).breakDamage;
      if (n <= 0 || d.enemyDown) continue;
      events.add(_trig(id));
      _hitEnemy(d, n, 0, events);
    }
    if (e.wrath > 0) {
      e.wrath = 0;
      events.add(const WrathCalmed());
    }
    if (e.scales > 0) {
      e.scales--;
      events.add(ScaleShed(e.scales));
    }
    // Una guardia que frena un solo tipo de golpe (Qilin, máscaras) se cae
    // al desequilibrarlo.
    if (e.guardBlocks != null) {
      e.guard = 0;
      e.guardBlocks = null;
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

  /// Vida mínima que puede dejarle un golpe: el próximo umbral de fase; si
  /// ya cambió de fase en este turno, uno más que el siguiente (o 1 si era
  /// la última), así no saltea fases ni cae el mismo turno.
  int _phaseFloor(_Draft d, _EnemyDraft e, EnemyDef def) {
    final phases = phasesOf(def.id, e.extraPhase);
    final changed = e.phaseTurn == d.turn;
    for (var i = e.phaseIndex + 1; i < phases.length; i++) {
      final t = phases[i].hpThreshold;
      if (t == null) continue;
      final at = (e.maxHp * t).floor();
      return changed ? at + 1 : at;
    }
    return changed ? 1 : 0;
  }

  void _checkEnemyPhase(_Draft d, List<CombatEvent> events) {
    final e = d.enemy;
    final phases = phasesOf(e.id, e.extraPhase);
    for (var i = e.phaseIndex + 1; i < phases.length; i++) {
      final t = phases[i].hpThreshold;
      if (t != null && e.hp <= e.maxHp * t) {
        e.phaseIndex = i;
        e.patternIndex = 0;
        e.phaseTurn = d.turn;
        events.add(EnemyPhaseChanged(i));
        // Se recompone: sale del desequilibrio, recupera la Estructura y
        // se cubre.
        if (e.staggered) {
          e.staggered = false;
          e.skipNextAction = false;
          events.add(const EnemyRecovered());
        }
        e.structure = e.maxStructure;
        final g = data.balance.phaseGuard;
        if (g > 0) e.guard += g;
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
    if (d.cardsThisTurn == 0) _flow(d, -1, FlowCause.idle, events);
    // Aliento contenido: terminar con Aliento sin gastar carga Respirar.
    if (d.breath > 0) _charge(d, ChargeCause.held, events);
    // El contragolpe que no se usó se pierde.
    d.counterReady = false;
    d.counterFree = false;
    final kept = d.hand.where((c) => retain.contains(c.uid)).toList();
    d.discard.addAll(d.hand.where((c) => !retain.contains(c.uid)));
    d.hand
      ..clear()
      ..addAll(kept);
    d.retained
      ..clear()
      ..addAll(kept.map((c) => c.uid));

    final punishes = d.enemies.any(
      (e) => e.hp > 0 && data.enemy(e.id).sameStancePunishDamage > 0,
    );
    final repeated =
        d.lastTurnEndStance != null && d.lastTurnEndStance == d.stance;
    if (punishes && repeated) d.punishPending = true;
    if (repeated && d.trial.challenge == Challenge.noRepeat) {
      _failChallenge(d, events);
    }
    d.lastTurnEndStance = d.stance;
    d.turnStructureBonus = 0;

    final duo = d.enemies.length > 1;
    for (var i = 0; i < d.enemies.length; i++) {
      final e = d.enemies[i];
      if (e.hp == 0) continue;
      d.cur = i;
      if (duo) events.add(EnemyActing(i));
      if (e.staggered && e.staggerEndsTurn <= d.turn) {
        e.staggered = false;
        e.structure = e.maxStructure;
        events.add(const EnemyRecovered());
      }
      _enemyAct(d, events);
      if (d.isOver) return;
      // Con dos en escena, que caiga uno (por un desvío) no frena al otro.
      if (duo) d.enemyDown = false;
      // Repetiste postura: lo nota para su próxima acción.
      if (repeated && e.hp > 0) _react(d, i, Reaction.repeat, events);
    }
    _roles(d, events);
    _bell(d, events);
    if (d.isOver) return;
    d.cur = d.target;
    if (duo && d.enemies[d.target].hp == 0) {
      d.target = d.cur = d.enemies.indexWhere((e) => e.hp > 0);
      events.add(TargetChanged(d.target));
    }
    _startPlayerTurn(d, events);
  }

  /// El rival [i] reacciona a [r] si tiene esa reacción (y no está ya
  /// reaccionando a otra cosa).
  void _react(_Draft d, int i, Reaction r, List<CombatEvent> events) {
    final e = d.enemies[i];
    if (e.hp == 0 || e.reaction != null) return;
    if (!data.enemy(e.id).reactions.containsKey(r)) return;
    e.reaction = r;
    events.add(EnemyReacted(i, r));
  }

  /// Roles de grupo: al terminar el turno enemigo, el protector cubre a su
  /// compañero y el sanador cura al más herido. Desequilibrado no hace nada.
  void _roles(_Draft d, List<CombatEvent> events) {
    if (d.enemies.length < 2) return;
    for (var i = 0; i < d.enemies.length; i++) {
      final e = d.enemies[i];
      final def = data.enemy(e.id);
      if (e.hp == 0 || e.staggered || def.role == null) continue;
      final allies = [
        for (var j = 0; j < d.enemies.length; j++)
          if (j != i && d.enemies[j].hp > 0) j,
      ];
      if (allies.isEmpty) continue;
      switch (def.role!) {
        case EnemyRole.guardian:
          for (final j in allies) {
            d.enemies[j].guard += def.roleValue;
            events.add(EnemyShielded(i, j, def.roleValue));
          }
        case EnemyRole.healer:
          final pool = [i, ...allies]
            ..sort((a, b) {
              final x = d.enemies[a], y = d.enemies[b];
              return (y.maxHp - y.hp).compareTo(x.maxHp - x.hp);
            });
          final j = pool.first;
          final t = d.enemies[j];
          final n = math.min(def.roleValue, t.maxHp - t.hp);
          if (n <= 0) continue;
          t.hp += n;
          events.add(EnemyHealedAlly(i, j, n));
      }
    }
  }

  /// Campana: cada tantos turnos repica y golpea a todos. Tu Guardia
  /// frena el golpe; a ellos no los deja por debajo de 1 de Vida.
  void _bell(_Draft d, List<CombatEvent> events) {
    final t = d.trial;
    if (t.room != RoomRule.bell || t.bellEvery <= 0) return;
    if (d.turn % t.bellEvery != 0 || t.bellDamage <= 0) return;
    final blocked = math.min(d.guard, t.bellDamage);
    final taken = t.bellDamage - blocked;
    d.hp = math.max(0, d.hp - taken);
    for (final e in d.enemies) {
      if (e.hp <= 0) continue;
      // Tampoco le hace saltear una fase al jefe (Picos con campana).
      final floor = _phaseFloor(d, e, data.enemy(e.id));
      final hp = math.max(1, e.hp - t.bellDamage);
      e.hp = floor > 0 && hp < floor ? math.min(e.hp, floor) : hp;
    }
    events.add(BellTolled(taken, t.bellDamage));
    if (d.hp == 0) {
      d.phase = CombatPhase.lost;
      events.add(const Defeat());
    }
  }

  /// Después de cada acción: los retos que se pierden por el camino.
  void _watchChallenge(_Draft d, List<CombatEvent> events) {
    final t = d.trial;
    if (!t.pending || d.phase == CombatPhase.won) return;
    final lost = switch (t.challenge!) {
      Challenge.flawless => d.hp < t.startHp,
      Challenge.swift => d.turn > t.swiftTurns,
      _ => false,
    };
    if (lost) _failChallenge(d, events);
  }

  /// El reto ya no se puede cumplir.
  void _failChallenge(_Draft d, List<CombatEvent> events) {
    if (!d.trial.pending) return;
    d.trial = d.trial.copyWith(failed: true);
    events.add(ChallengeFailed(d.trial.challenge!));
  }

  /// Al ganar: se cumplió el reto o no.
  void _judgeChallenge(
    _Draft d, {
    required bool finishedOnBreak,
    required List<CombatEvent> events,
  }) {
    final t = d.trial;
    if (!t.pending) return;
    final ok = switch (t.challenge!) {
      Challenge.flawless => d.hp >= t.startHp,
      Challenge.breakFinish => finishedOnBreak,
      Challenge.swift => d.turn <= t.swiftTurns,
      Challenge.noRepeat => true,
    };
    if (ok) {
      d.trial = t.copyWith(met: true);
      events.add(ChallengeMet(t.challenge!));
    } else {
      _failChallenge(d, events);
    }
  }

  void _enemyAct(_Draft d, List<CombatEvent> events) {
    final e = d.enemy;
    final def = data.enemy(e.id);
    e.guard = 0;
    e.guardBlocks = null;
    final phaseBefore = e.phaseIndex;
    final reacting = e.reaction != null;
    if (e.skipNextAction) {
      e.skipNextAction = false;
      events.add(const EnemyActionSkipped());
      // La reacción espera a que se recupere; su ciclo tampoco avanza.
      if (reacting) return;
    } else {
      final healed = math.min(def.regen + e.regen, e.maxHp - e.hp);
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
          e.guardBlocks = intent.mirror ? d.lastAttackType : intent.blocks;
          events.add(EnemyGuarded(intent.value, e.guardBlocks));
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
      if (def.wrath > 0 && !d.halted) {
        e.wrath += def.wrath;
        events.add(EnemyEnraged(e.wrath));
      }
      if (e.furyStep > 0 && !d.halted) {
        e.fury += e.furyStep;
        events.add(EnemyFurious(e.fury));
      }
    }
    if (d.isOver) return;
    // La reacción reemplazó una acción: el ciclo sigue donde estaba.
    if (reacting) {
      e.reaction = null;
      return;
    }
    // Si cambió de fase durante su acción, la nueva fase arranca en el paso 0.
    if (e.phaseIndex != phaseBefore) return;
    final pattern = phasesOf(e.id, e.extraPhase)[e.phaseIndex].pattern;
    e.patternIndex = (e.patternIndex + 1) % pattern.length;
  }

  void _enemyAttack(
    _Draft d,
    EnemyDef def,
    IntentDef intent,
    List<CombatEvent> events,
  ) {
    final e = d.enemy;
    var damage = intent.damage + e.chargeBonus + e.wrath + e.fury;
    var structure = intent.structure;
    e.chargeBonus = 0;
    if (d.punishPending && def.sameStancePunishDamage > 0) {
      damage += def.sameStancePunishDamage;
      structure += def.sameStancePunishStructure;
      d.punishPending = false;
    }
    damage = _enemyDamage(damage, d.enemyDamagePct);
    if (intent.wear) {
      _wearingAttack(d, def, intent, damage, structure, events);
      return;
    }
    final match = d.guard > 0 && d.guardHeight == intent.height;
    // La Guardia no se consume (salvo con `wear`): en un ataque doble se
    // aplica a cada golpe, así que si desvía uno los desvía todos. El desvío premia una vez por acción.
    if (match && d.guard >= damage) {
      _rewardDeflect(d, events);
      return;
    }
    final absorb = d.guard == 0 ? 0 : (match ? d.guard : d.guard ~/ 2);
    final blocked = d.guard > 0;
    for (var hit = 0; hit < intent.hits; hit++) {
      if (_landHit(d, def, damage - absorb, structure, blocked, events)) {
        return;
      }
    }
    _afterLandedAttack(d, intent, events);
  }

  /// Desvío: Aliento extra el próximo turno y el enemigo pierde estructura.
  void _rewardDeflect(_Draft d, List<CombatEvent> events) {
    final stance = data.stance(d.stance);
    d.deflects++;
    events.add(const Deflected());
    _flow(d, 1, FlowCause.deflect, events);
    _charge(d, ChargeCause.deflect, events);
    // Contragolpe: uno por turno del rival, se elige en el turno propio.
    if (!d.counterReady) {
      d.counterReady = true;
      events.add(const CounterReady());
    }
    d.nextTurnBreathMod += data.balance.deflectBreathBonus +
        stance.deflectBreathBonus +
        d.awakened.deflectBreath;
    var back = 0;
    for (final id in _slots(d.talismans, d.weaponEffect)) {
      final fx = _fx(id, d.weaponEffect);
      if (fx.deflectBreath > 0) d.nextTurnBreathMod += fx.deflectBreath;
      back += fx.deflectDamage;
      if (fx.deflectBreath > 0 || fx.deflectDamage > 0) {
        events.add(_trig(id));
      }
    }
    _hitEnemy(
      d,
      d.deflectBonusDamage + back,
      data.balance.deflectEnemyStructureLoss + d.deflectBonusStructure,
      events,
    );
  }

  /// Un golpe que entra. Devuelve true si el combate terminó (derrota).
  bool _landHit(
    _Draft d,
    EnemyDef def,
    int rawTaken,
    int structure,
    bool blocked,
    List<CombatEvent> events,
  ) {
    final stance = data.stance(d.stance);
    final e = d.enemy;
    final taken = math.max(0, rawTaken);
    var s = blocked ? structure ~/ 2 : structure;
    s = (s * stance.incomingStructureMultiplier).floor();
    if (s > 0) s += stance.incomingStructureBonus;
    d.hp = math.max(0, d.hp - taken);
    d.structure = math.max(0, d.structure - s);
    events.add(PlayerHit(taken, s, blocked: blocked));
    if (!blocked && taken > 0) _flow(d, -1, FlowCause.hit, events);
    if (taken > 0 && def.steal > 0) {
      e.stolen += def.steal;
      events.add(JadeStolen(def.steal, e.stolen));
    }
    if (d.hp == 0) {
      d.phase = CombatPhase.lost;
      events.add(const Defeat());
      return true;
    }
    if (d.structure == 0) {
      d.nextTurnBreathMod -= data.balance.playerBreakBreathPenalty;
      d.structure = d.maxStructure;
      events.add(const PlayerBroken());
    }
    return false;
  }

  /// Ataque que desgasta la Guardia: cada golpe se resuelve contra lo que
  /// queda de ella y le resta su daño. El desvío premia una vez por acción;
  /// los efectos (interrumpir, repique, escarcha) entran si algún golpe entró.
  void _wearingAttack(
    _Draft d,
    EnemyDef def,
    IntentDef intent,
    int damage,
    int structure,
    List<CombatEvent> events,
  ) {
    var rewarded = false;
    var landed = false;
    for (var hit = 0; hit < intent.hits; hit++) {
      final match = d.guard > 0 && d.guardHeight == intent.height;
      if (match && d.guard >= damage) {
        if (!rewarded) {
          rewarded = true;
          _rewardDeflect(d, events);
          if (d.isOver) return;
        }
        d.guard -= damage;
        continue;
      }
      final absorb = d.guard == 0 ? 0 : (match ? d.guard : d.guard ~/ 2);
      final blocked = d.guard > 0;
      d.guard = math.max(0, d.guard - damage);
      landed = true;
      if (_landHit(d, def, damage - absorb, structure, blocked, events)) {
        return;
      }
    }
    if (landed) _afterLandedAttack(d, intent, events);
  }

  void _afterLandedAttack(
    _Draft d,
    IntentDef intent,
    List<CombatEvent> events,
  ) {
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
    // Talismán Montaña: parte de la Guardia se queda (con su altura).
    final keep = math.min(
      100,
      _tal(d.talismans, (e) => e.guardKeepPct, d.weaponEffect),
    );
    final kept = d.turn > 1 ? d.guard * keep ~/ 100 : 0;
    if (kept > 0) {
      for (final id in _slots(d.talismans, d.weaponEffect)) {
        if (_fx(id, d.weaponEffect).guardKeepPct > 0) {
          events.add(_trig(id));
        }
      }
    }
    d.guard = kept;
    if (kept == 0) d.guardHeight = null;
    // Pluma de la Grulla: cada carta retenida cubre.
    if (d.retained.isNotEmpty) {
      for (final id in _slots(d.talismans, d.weaponEffect)) {
        final n = _fx(id, d.weaponEffect).retainedGuard;
        if (n <= 0) continue;
        final g = n * d.retained.length;
        events.add(_trig(id));
        d.guard += g;
        events.add(GuardGained(g, d.guardHeight));
      }
    }
    d.cardsThisTurn = 0;
    d.chainedStances = 0;
    d.deflectBonusDamage = 0;
    d.deflectBonusStructure = 0;
    d.dingbuUsed = false;
    d.attacksThisTurn = 0;
    for (final e in d.enemies) {
      e.parryReady = e.hp > 0 && data.enemy(e.id).parry > 0;
    }
    d.breath = math.max(
          0,
          d.breathPerTurn + d.nextTurnBreathMod - d.trial.thinAir,
        ) +
        (d.flow >= flowBreathAt ? 1 : 0);
    d.nextTurnBreathMod = 0;
    // Filo: al filo, algunos talismanes dan Aliento al empezar el turno.
    if (onEdge(d.hp, d.maxHp)) {
      for (final id in _slots(d.talismans, d.weaponEffect)) {
        final n = _fx(id, d.weaponEffect).edgeBreath;
        if (n <= 0) continue;
        events.add(_trig(id));
        d.breath += n;
      }
    }
    events.add(TurnStarted(d.turn, d.breath));
    // Las cartas retenidas son extra: siempre se roba la mano completa
    // (menos la escarcha, pero nunca menos de una carta). El Flujo alto
    // suma una.
    _draw(
      d,
      math.max(1, d.handSize - d.drawPenalty) +
          (d.flow >= flowDrawAt ? 1 : 0),
      events,
    );
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
    this.thorns = 0,
    this.fury = 0,
    this.furyStep = 0,
    this.phaseTurn = -1,
    this.reaction,
    this.regen = 0,
    this.extraPhase = false,
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
    thorns: e.thorns,
    fury: e.fury,
    furyStep: e.furyStep,
    phaseTurn: e.phaseTurn,
    reaction: e.reaction,
    regen: e.regen,
    extraPhase: e.extraPhase,
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
  final int thorns;
  int fury;
  final int furyStep;
  int phaseTurn;
  Reaction? reaction;
  final int regen;
  final bool extraPhase;

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
    thorns: thorns,
    fury: fury,
    furyStep: furyStep,
    phaseTurn: phaseTurn,
    reaction: reaction,
    regen: regen,
    extraPhase: extraPhase,
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
    required this.enemies,
    this.target = 0,
    required this.drawPile,
    required this.hand,
    required this.discard,
    required this.exhausted,
    required this.breathesLeft,
    required this.formProgress,
    required this.rng,
    List<EnemyCombat>? reserve,
    this.wave = 0,
    this.flow = 0,
    this.breathCharge = 0,
    this.counterReady = false,
    this.counterFree = false,
    this.style,
    this.nextTurnBreathMod = 0,
    this.dingbuUsed = false,
    this.turnStructureBonus = 0,
    this.deflectBonusDamage = 0,
    this.deflectBonusStructure = 0,
    this.lastTurnEndStance,
    this.lastAttackType,
    this.punishPending = false,
    this.pendingDiscard = 0,
    Map<String, int>? formsCompleted,
    this.deflects = 0,
    this.enemyDamagePct = 100,
    this.fistBonus = 0,
    this.talismans = const [],
    this.weapon,
    this.weaponLevel = 0,
    this.weaponEffect,
    this.firstStrike = 0,
    this.chain = 0,
    this.retainedDiscount = 0,
    this.attacksThisTurn = 0,
    this.cardsThisTurn = 0,
    this.chainedStances = 0,
    this.drawPenalty = 0,
    this.awakened = AwakeningEffect.none,
    List<int>? retained,
    this.trial = Trial.none,
  }) : formsCompleted = formsCompleted ?? {},
       retained = retained ?? [],
       reserve = reserve ?? [];

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
    enemies: [for (final e in s.enemies) _EnemyDraft.of(e)],
    target: s.target,
    drawPile: [...s.drawPile],
    hand: [...s.hand],
    discard: [...s.discard],
    exhausted: [...s.exhausted],
    breathesLeft: s.breathesLeft,
    formProgress: {...s.formProgress},
    rng: s.rng,
    reserve: [...s.reserve],
    wave: s.wave,
    flow: s.flow,
    breathCharge: s.breathCharge,
    counterReady: s.counterReady,
    counterFree: s.counterFree,
    style: s.style,
    nextTurnBreathMod: s.nextTurnBreathMod,
    dingbuUsed: s.dingbuUsed,
    turnStructureBonus: s.turnStructureBonus,
    deflectBonusDamage: s.deflectBonusDamage,
    deflectBonusStructure: s.deflectBonusStructure,
    lastTurnEndStance: s.lastTurnEndStance,
    lastAttackType: s.lastAttackType,
    punishPending: s.punishPending,
    pendingDiscard: s.pendingDiscard,
    formsCompleted: {...s.formsCompleted},
    deflects: s.deflects,
    enemyDamagePct: s.enemyDamagePct,
    fistBonus: s.fistBonus,
    talismans: s.talismans,
    weapon: s.weapon,
    weaponLevel: s.weaponLevel,
    weaponEffect: s.weaponEffect,
    firstStrike: s.firstStrike,
    chain: s.chain,
    retainedDiscount: s.retainedDiscount,
    attacksThisTurn: s.attacksThisTurn,
    cardsThisTurn: s.cardsThisTurn,
    chainedStances: s.chainedStances,
    drawPenalty: s.drawPenalty,
    awakened: s.awakened,
    retained: [...s.retained],
    trial: s.trial,
  );

  Trial trial;
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
  final List<_EnemyDraft> enemies;
  int target;

  /// El enemigo en juego ahora: el apuntado mientras jugás; el que actúa en
  /// el turno enemigo.
  late int cur = target;
  _EnemyDraft get enemy => enemies[cur];
  set enemy(_EnemyDraft e) => enemies[cur] = e;
  final List<EnemyCombat> reserve;
  int wave;
  int flow;
  int breathCharge;
  bool counterReady;
  bool counterFree;
  final Style? style;

  /// El enemigo cayó en esta acción y queda otro esperando.
  bool enemyDown = false;
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
  CardType? lastAttackType;
  bool punishPending;
  int pendingDiscard;
  final Map<String, int> formsCompleted;
  int deflects;
  final int enemyDamagePct;
  int fistBonus;
  final List<String> talismans;
  final String? weapon;
  final int weaponLevel;
  final TalismanEffect? weaponEffect;
  final int firstStrike;
  final int chain;
  final int retainedDiscount;
  int attacksThisTurn;
  int cardsThisTurn;
  int chainedStances;
  int drawPenalty;
  final AwakeningEffect awakened;
  final List<int> retained;

  bool get isOver => phase == CombatPhase.won || phase == CombatPhase.lost;

  /// Ya no hay a quién pegarle en esta acción.
  bool get halted => isOver || enemyDown;

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
    enemies: List.unmodifiable([for (final e in enemies) e.freeze()]),
    target: target,
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
    lastAttackType: lastAttackType,
    punishPending: punishPending,
    formProgress: Map.unmodifiable(formProgress),
    pendingDiscard: pendingDiscard,
    formsCompleted: Map.unmodifiable(formsCompleted),
    deflects: deflects,
    rng: rng,
    enemyDamagePct: enemyDamagePct,
    fistBonus: fistBonus,
    talismans: talismans,
    weapon: weapon,
    weaponLevel: weaponLevel,
    weaponEffect: weaponEffect,
    firstStrike: firstStrike,
    chain: chain,
    retainedDiscount: retainedDiscount,
    attacksThisTurn: attacksThisTurn,
    cardsThisTurn: cardsThisTurn,
    chainedStances: chainedStances,
    retained: List.unmodifiable(retained),
    drawPenalty: drawPenalty,
    awakened: awakened,
    reserve: List.unmodifiable(reserve),
    wave: wave,
    flow: flow,
    breathCharge: breathCharge,
    counterReady: counterReady,
    counterFree: counterFree,
    style: style,
    trial: trial,
  );
}
