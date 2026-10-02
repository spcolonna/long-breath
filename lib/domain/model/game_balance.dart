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
  shrine,

  /// Escena con una decisión (ermitaño, puente, manantial…).
  event,

  /// Mercader de pergaminos: se compra con jade.
  merchant,

  /// Maestro errante: enseña una forma o mejora una carta.
  master;

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

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        if (enemy != null) 'enemy': enemy,
        'next': next,
      };
}

/// Un piso del mapa generado: cuántos nodos tiene, de qué tipo pueden ser
/// (con su peso) y qué enemigos pueden salir en sus combates.
class FloorDef {
  const FloorDef({
    required this.minWidth,
    required this.maxWidth,
    required this.types,
    this.enemies = const [],
  });

  final int minWidth;
  final int maxWidth;
  final Map<NodeType, int> types;
  final List<String> enemies;

  factory FloorDef.fromJson(Map<String, dynamic> j) {
    final width = j['width'];
    final (min, max) = switch (width) {
      final List w => (w[0] as int, w[1] as int),
      final int w => (w, w),
      _ => (1, 1),
    };
    return FloorDef(
      minWidth: min,
      maxWidth: max,
      types: {
        for (final e in (j['types'] as Map<String, dynamic>).entries)
          NodeType.parse(e.key): e.value as int,
      },
      enemies: ((j['enemies'] as List?) ?? const []).cast<String>(),
    );
  }
}

/// Precios del mercader, en jade.
class MerchantDef {
  const MerchantDef({
    this.cards = 3,
    this.card = 25,
    this.talisman = 60,
    this.remove = 35,
    this.upgrade = 30,
  });

  /// Cartas en venta.
  final int cards;
  final int card;
  final int talisman;
  final int remove;
  final int upgrade;

  factory MerchantDef.fromJson(Map<String, dynamic> j) => MerchantDef(
        cards: j['cards'] as int? ?? 3,
        card: j['card'] as int? ?? 25,
        talisman: j['talisman'] as int? ?? 60,
        remove: j['remove'] as int? ?? 35,
        upgrade: j['upgrade'] as int? ?? 30,
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
    this.talismanChoices = 3,
    required this.fountainHeal,
    required this.fountainUpgrade,
    required this.stage,
    this.fixedMap,
    this.floors = const [],
    this.jadeCommon = 0,
    this.jadeElite = 0,
    this.jadeSpread = 0,
    this.merchant = const MerchantDef(),
    this.masterForms = 2,
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

  /// Talismanes que ofrece el élite al vencerlo.
  final int talismanChoices;
  final int fountainHeal;
  final int fountainUpgrade;
  /// Etapa que recorre la run (nombre visible en el mapa).
  final StageDef stage;

  /// Mapa fijo (solo para el simulador); si no hay, se genera por run.
  final List<MapNodeDef>? fixedMap;

  /// Pisos del mapa generado, de abajo hacia arriba.
  final List<FloorDef> floors;

  /// Jade que se gana al vencer a un común o a un élite (más 0..spread).
  final int jadeCommon;
  final int jadeElite;
  final int jadeSpread;
  final MerchantDef merchant;

  /// Formas que ofrece el maestro errante.
  final int masterForms;
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
    final jade = (j['jade'] as Map<String, dynamic>?) ?? const {};
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
      talismanChoices: rewards['talismanChoices'] as int? ?? 3,
      fountainHeal: fountain['heal'] as int,
      fountainUpgrade: fountain['upgrade'] as int,
      stage: StageDef.fromJson(run['stage'] as Map<String, dynamic>),
      fixedMap: switch (run['nodes']) {
        final List nodes => [
            for (final n in nodes) MapNodeDef.fromJson(n as Map<String, dynamic>),
          ],
        _ => null,
      },
      floors: [
        for (final f in (run['floors'] as List?) ?? const [])
          FloorDef.fromJson(f as Map<String, dynamic>),
      ],
      jadeCommon: jade['common'] as int? ?? 0,
      jadeElite: jade['elite'] as int? ?? 0,
      jadeSpread: jade['spread'] as int? ?? 0,
      merchant: MerchantDef.fromJson(
        (j['merchant'] as Map<String, dynamic>?) ?? const {},
      ),
      masterForms:
          ((j['master'] as Map<String, dynamic>?) ?? const {})['forms'] as int? ??
              2,
      difficulties: {
        for (final e in (j['difficulties'] as Map<String, dynamic>).entries)
          Difficulty.parse(e.key):
              DifficultyDef.fromJson(e.value as Map<String, dynamic>),
      },
    );
  }
}
