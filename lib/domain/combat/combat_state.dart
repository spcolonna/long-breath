import '../model/enums.dart';
import '../rng.dart';

/// Una carta concreta dentro de un mazo (uid único por run).
class CombatCard {
  const CombatCard({required this.uid, required this.cardId, this.upgrades = 0});

  final int uid;
  final String cardId;

  /// Mejoras de la fuente: +N a su daño o a su Guardia.
  final int upgrades;

  Map<String, dynamic> toJson() =>
      {'uid': uid, 'cardId': cardId, 'upgrades': upgrades};

  factory CombatCard.fromJson(Map<String, dynamic> j) => CombatCard(
        uid: j['uid'] as int,
        cardId: j['cardId'] as String,
        upgrades: j['upgrades'] as int? ?? 0,
      );

  @override
  String toString() => '$cardId#$uid';
}

enum CombatPhase { playerTurn, discarding, won, lost }

class PlayerCombat {
  const PlayerCombat({
    required this.hp,
    required this.maxHp,
    required this.structure,
    required this.maxStructure,
    required this.guard,
    required this.guardHeight,
    required this.stance,
    required this.breath,
  });

  final int hp;
  final int maxHp;
  final int structure;
  final int maxStructure;
  final int guard;
  final Height? guardHeight;
  final Stance stance;
  final int breath;

  PlayerCombat copyWith({int? hp, int? structure, int? breath, Stance? stance}) =>
      PlayerCombat(
        hp: hp ?? this.hp,
        maxHp: maxHp,
        structure: structure ?? this.structure,
        maxStructure: maxStructure,
        guard: guard,
        guardHeight: guardHeight,
        stance: stance ?? this.stance,
        breath: breath ?? this.breath,
      );
}

class EnemyCombat {
  const EnemyCombat({
    required this.id,
    required this.hp,
    required this.maxHp,
    required this.structure,
    required this.maxStructure,
    required this.guard,
    required this.phaseIndex,
    required this.patternIndex,
    required this.staggered,
    required this.staggerEndsTurn,
    required this.skipNextAction,
    required this.chargeBonus,
    this.scales = 0,
  });

  final String id;
  final int hp;
  final int maxHp;
  final int structure;
  final int maxStructure;
  final int guard;
  final int phaseIndex;
  final int patternIndex;

  /// Desequilibrado: recibe el doble de daño y pierde la acción anunciada.
  final bool staggered;

  /// Turno del jugador al final del cual se recupera del desequilibrio.
  final int staggerEndsTurn;
  final bool skipNextAction;

  /// Bonus acumulado para su próximo ataque (Carga del Gólem).
  final int chargeBonus;

  /// Escamas que le quedan (resta daño a cada golpe).
  final int scales;

  EnemyCombat copyWith({
    int? hp,
    int? structure,
    int? phaseIndex,
    int? patternIndex,
    int? scales,
  }) =>
      EnemyCombat(
        id: id,
        hp: hp ?? this.hp,
        maxHp: maxHp,
        structure: structure ?? this.structure,
        maxStructure: maxStructure,
        guard: guard,
        phaseIndex: phaseIndex ?? this.phaseIndex,
        patternIndex: patternIndex ?? this.patternIndex,
        staggered: staggered,
        staggerEndsTurn: staggerEndsTurn,
        skipNextAction: skipNextAction,
        chargeBonus: chargeBonus,
        scales: scales ?? this.scales,
      );
}

/// Estado inmutable de un combate. Solo el [CombatEngine] produce estados nuevos.
class CombatState {
  const CombatState({
    required this.turn,
    required this.phase,
    required this.handSize,
    required this.breathPerTurn,
    required this.retainMax,
    required this.player,
    required this.enemy,
    required this.drawPile,
    required this.hand,
    required this.discard,
    required this.exhausted,
    required this.nextTurnBreathMod,
    required this.dingbuUsed,
    required this.breathesLeft,
    required this.turnStructureBonus,
    required this.deflectBonusDamage,
    required this.deflectBonusStructure,
    required this.lastTurnEndStance,
    required this.punishPending,
    required this.formProgress,
    required this.pendingDiscard,
    required this.formsCompleted,
    required this.deflects,
    required this.rng,
    this.enemyDamagePct = 100,
  });

  final int turn;
  final CombatPhase phase;
  final int handSize;
  final int breathPerTurn;
  final int retainMax;
  final PlayerCombat player;
  final EnemyCombat enemy;
  final List<CombatCard> drawPile;
  final List<CombatCard> hand;
  final List<CombatCard> discard;
  final List<CombatCard> exhausted;

  /// Ajuste de Aliento para el próximo turno (+desvíos, −Estructura rota).
  final int nextTurnBreathMod;
  final bool dingbuUsed;
  final int breathesLeft;

  /// Bonus a todo daño a Estructura este turno (Hǔ Xiào).
  final int turnStructureBonus;
  final int deflectBonusDamage;
  final int deflectBonusStructure;
  final Stance? lastTurnEndStance;

  /// Castigo del Discípulo pendiente para su próximo ataque.
  final bool punishPending;
  final Map<String, int> formProgress;
  final int pendingDiscard;
  final Map<String, int> formsCompleted;
  final int deflects;
  final Rng rng;

  /// Daño de los ataques enemigos según la dificultad (100 = normal).
  final int enemyDamagePct;

  /// Copia con jugador o enemigo reemplazados (tests y herramientas).
  CombatState copyWith({PlayerCombat? player, EnemyCombat? enemy}) =>
      CombatState(
        turn: turn,
        phase: phase,
        handSize: handSize,
        breathPerTurn: breathPerTurn,
        retainMax: retainMax,
        player: player ?? this.player,
        enemy: enemy ?? this.enemy,
        drawPile: drawPile,
        hand: hand,
        discard: discard,
        exhausted: exhausted,
        nextTurnBreathMod: nextTurnBreathMod,
        dingbuUsed: dingbuUsed,
        breathesLeft: breathesLeft,
        turnStructureBonus: turnStructureBonus,
        deflectBonusDamage: deflectBonusDamage,
        deflectBonusStructure: deflectBonusStructure,
        lastTurnEndStance: lastTurnEndStance,
        punishPending: punishPending,
        formProgress: formProgress,
        pendingDiscard: pendingDiscard,
        formsCompleted: formsCompleted,
        deflects: deflects,
        rng: rng,
        enemyDamagePct: enemyDamagePct,
      );

  bool get isOver => phase == CombatPhase.won || phase == CombatPhase.lost;

  CombatCard? handCard(int uid) {
    for (final c in hand) {
      if (c.uid == uid) return c;
    }
    return null;
  }
}
