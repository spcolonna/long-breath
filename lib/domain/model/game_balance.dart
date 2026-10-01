import 'enums.dart';

/// Cómo se juega la mano: el del novicio o el del camino animal elegido.
class StyleStats {
  const StyleStats({
    required this.hanzi,
    required this.pinyin,
    required this.draw,
    required this.breath,
    required this.retain,
  });

  final String hanzi;
  final String pinyin;
  final int draw;
  final int breath;
  final int retain;

  factory StyleStats.fromJson(Map<String, dynamic> j) => StyleStats(
        hanzi: j['hanzi'] as String,
        pinyin: j['pinyin'] as String,
        draw: j['draw'] as int,
        breath: j['breath'] as int,
        retain: j['retain'] as int,
      );
}

enum NodeType {
  combat,
  fountain,

  /// Santuario de los animales: se elige el camino.
  shrine;

  static NodeType parse(String s) => NodeType.values.byName(s);
}

class StageDef {
  const StageDef({required this.id, required this.hanzi, required this.pinyin});

  final String id;
  final String hanzi;
  final String pinyin;

  factory StageDef.fromJson(Map<String, dynamic> j) => StageDef(
        id: j['id'] as String,
        hanzi: j['hanzi'] as String,
        pinyin: j['pinyin'] as String,
      );
}

class MapNodeDef {
  const MapNodeDef({
    required this.id,
    required this.type,
    required this.next,
    this.enemy,
  });

  final String id;
  final NodeType type;
  final String? enemy;
  final List<String> next;

  factory MapNodeDef.fromJson(Map<String, dynamic> j) => MapNodeDef(
        id: j['id'] as String,
        type: NodeType.parse(j['type'] as String),
        enemy: j['enemy'] as String?,
        next: (j['next'] as List).cast<String>(),
      );
}

/// Ajustes de una dificultad. Los porcentajes se aplican a los enemigos
/// de la subida (no a los muñecos de las lecciones).
class DifficultyDef {
  const DifficultyDef({
    required this.hanzi,
    required this.playerHp,
    required this.fountainHeal,
    this.enemyHp = 100,
    this.enemyDamage = 100,
    this.enemyStructure = 100,
  });

  final String hanzi;
  final int playerHp;
  final int fountainHeal;
  final int enemyHp;
  final int enemyDamage;
  final int enemyStructure;

  factory DifficultyDef.fromJson(Map<String, dynamic> j) => DifficultyDef(
        hanzi: j['hanzi'] as String,
        playerHp: j['playerHp'] as int,
        fountainHeal: j['fountainHeal'] as int,
        enemyHp: j['enemyHp'] as int? ?? 100,
        enemyDamage: j['enemyDamage'] as int? ?? 100,
        enemyStructure: j['enemyStructure'] as int? ?? 100,
      );
}

class GameBalance {
  const GameBalance({
    required this.playerHp,
    required this.playerStructure,
    required this.startStance,
    required this.breathesPerCombat,
    required this.novice,
    required this.styles,
    required this.pathChoices,
    required this.deflectEnemyStructureLoss,
    required this.deflectBreathBonus,
    required this.playerBreakBreathPenalty,
    required this.enemyBreakDamageMultiplier,
    required this.rewardChoices,
    required this.rewardPools,
    required this.fountainHeal,
    required this.fountainUpgrade,
    required this.runStart,
    required this.stage,
    required this.runNodes,
    required this.difficulties,
  });

  final int playerHp;
  final int playerStructure;
  final Stance startStance;
  final int breathesPerCombat;
  final StyleStats novice;
  final Map<Style, StyleStats> styles;

  /// Cuántos caminos (al azar) ofrece el santuario.
  final int pathChoices;
  final int deflectEnemyStructureLoss;
  final int deflectBreathBonus;
  final int playerBreakBreathPenalty;
  final int enemyBreakDamageMultiplier;
  final int rewardChoices;
  final List<String> rewardPools;
  final int fountainHeal;
  final int fountainUpgrade;
  final String runStart;

  /// Etapa que recorre la run (nombre visible en el mapa).
  final StageDef stage;
  final List<MapNodeDef> runNodes;
  final Map<Difficulty, DifficultyDef> difficulties;

  DifficultyDef difficulty(Difficulty d) => difficulties[d]!;

  /// Estadísticas del camino, o las del novicio si todavía no eligió.
  StyleStats statsOf(Style? s) => s == null ? novice : styles[s]!;

  factory GameBalance.fromJson(Map<String, dynamic> j) {
    final player = j['player'] as Map<String, dynamic>;
    final styles = j['styles'] as Map<String, dynamic>;
    final deflect = j['deflect'] as Map<String, dynamic>;
    final rewards = j['rewards'] as Map<String, dynamic>;
    final fountain = j['fountain'] as Map<String, dynamic>;
    final run = j['run'] as Map<String, dynamic>;
    return GameBalance(
      playerHp: player['hp'] as int,
      playerStructure: player['structure'] as int,
      startStance: Stance.parse(player['startStance'] as String)!,
      breathesPerCombat: player['breathesPerCombat'] as int,
      novice: StyleStats.fromJson(j['novice'] as Map<String, dynamic>),
      styles: {
        for (final e in styles.entries)
          Style.parse(e.key): StyleStats.fromJson(e.value as Map<String, dynamic>),
      },
      pathChoices: (j['paths'] as Map<String, dynamic>)['choices'] as int,
      deflectEnemyStructureLoss: deflect['enemyStructureLoss'] as int,
      deflectBreathBonus: deflect['breathBonus'] as int,
      playerBreakBreathPenalty:
          (j['playerBreak'] as Map<String, dynamic>)['breathPenalty'] as int,
      enemyBreakDamageMultiplier:
          (j['enemyBreak'] as Map<String, dynamic>)['damageMultiplier'] as int,
      rewardChoices: rewards['choices'] as int,
      rewardPools: (rewards['pools'] as List).cast<String>(),
      fountainHeal: fountain['heal'] as int,
      fountainUpgrade: fountain['upgrade'] as int,
      runStart: run['start'] as String,
      stage: StageDef.fromJson(run['stage'] as Map<String, dynamic>),
      runNodes: [
        for (final n in run['nodes'] as List)
          MapNodeDef.fromJson(n as Map<String, dynamic>),
      ],
      difficulties: {
        for (final e in (j['difficulties'] as Map<String, dynamic>).entries)
          Difficulty.parse(e.key):
              DifficultyDef.fromJson(e.value as Map<String, dynamic>),
      },
    );
  }
}
