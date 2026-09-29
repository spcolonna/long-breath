import 'enums.dart';

class AgeStats {
  const AgeStats({
    required this.name,
    required this.draw,
    required this.breath,
    required this.retain,
  });

  final String name;
  final int draw;
  final int breath;
  final int retain;

  factory AgeStats.fromJson(Map<String, dynamic> j) => AgeStats(
        name: j['name'] as String,
        draw: j['draw'] as int,
        breath: j['breath'] as int,
        retain: j['retain'] as int,
      );
}

enum NodeType {
  combat,
  fountain;

  static NodeType parse(String s) => NodeType.values.byName(s);
}

class StageDef {
  const StageDef({required this.name, required this.hanzi, required this.pinyin});

  final String name;
  final String hanzi;
  final String pinyin;

  factory StageDef.fromJson(Map<String, dynamic> j) => StageDef(
        name: j['name'] as String,
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

class GameBalance {
  const GameBalance({
    required this.playerHp,
    required this.playerStructure,
    required this.startStance,
    required this.breathesPerCombat,
    required this.ages,
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
  });

  final int playerHp;
  final int playerStructure;
  final Stance startStance;
  final int breathesPerCombat;
  final Map<Age, AgeStats> ages;
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

  factory GameBalance.fromJson(Map<String, dynamic> j) {
    final player = j['player'] as Map<String, dynamic>;
    final ages = j['ages'] as Map<String, dynamic>;
    final deflect = j['deflect'] as Map<String, dynamic>;
    final rewards = j['rewards'] as Map<String, dynamic>;
    final fountain = j['fountain'] as Map<String, dynamic>;
    final run = j['run'] as Map<String, dynamic>;
    return GameBalance(
      playerHp: player['hp'] as int,
      playerStructure: player['structure'] as int,
      startStance: Stance.parse(player['startStance'] as String)!,
      breathesPerCombat: player['breathesPerCombat'] as int,
      ages: {
        for (final e in ages.entries)
          Age.parse(e.key): AgeStats.fromJson(e.value as Map<String, dynamic>),
      },
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
    );
  }
}
