import 'enums.dart';

enum IntentKind {
  attack,
  guard,
  charge,
  discard;

  static IntentKind parse(String s) => IntentKind.values.byName(s);
}

/// Acción anunciada por un enemigo.
class IntentDef {
  const IntentDef({
    required this.kind,
    this.label,
    this.height,
    this.damage = 0,
    this.structure = 0,
    this.hits = 1,
    this.value = 0,
    this.count = 0,
    this.interrupt = false,
    this.countdown = false,
  });

  final IntentKind kind;
  final String? label;
  final Height? height;
  final int damage;
  final int structure;
  final int hits;

  /// Guardia (guard) o bonus del próximo ataque (charge).
  final int value;

  /// Cartas a descartar (discard).
  final int count;
  final bool interrupt;

  /// Ataque con cuenta regresiva visible (Aliento del Dragón).
  final bool countdown;

  factory IntentDef.fromJson(Map<String, dynamic> j) => IntentDef(
        kind: IntentKind.parse(j['kind'] as String),
        label: j['label'] as String?,
        height: Height.parse(j['height'] as String?),
        damage: j['damage'] as int? ?? 0,
        structure: j['structure'] as int? ?? 0,
        hits: j['hits'] as int? ?? 1,
        value: j['value'] as int? ?? 0,
        count: j['count'] as int? ?? 0,
        interrupt: j['interrupt'] as bool? ?? false,
        countdown: j['countdown'] as bool? ?? false,
      );
}

class EnemyPhase {
  const EnemyPhase({required this.pattern, this.hpThreshold});

  final List<IntentDef> pattern;

  /// La fase empieza cuando la Vida cae a este porcentaje o menos.
  final double? hpThreshold;

  factory EnemyPhase.fromJson(Map<String, dynamic> j) => EnemyPhase(
        pattern: [
          for (final i in j['pattern'] as List)
            IntentDef.fromJson(i as Map<String, dynamic>),
        ],
        hpThreshold: (j['hpThreshold'] as num?)?.toDouble(),
      );
}

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.name,
    required this.rank,
    required this.hp,
    required this.structure,
    required this.phases,
    this.rule = '',
    this.hanzi,
    this.pinyin,
    this.immovable = false,
    this.sameStancePunishDamage = 0,
    this.sameStancePunishStructure = 0,
  });

  final String id;
  final String name;
  final EnemyRank rank;
  final int hp;
  final int structure;
  final List<EnemyPhase> phases;
  final String rule;
  final String? hanzi;
  final String? pinyin;
  final bool immovable;
  final int sameStancePunishDamage;
  final int sameStancePunishStructure;

  factory EnemyDef.fromJson(Map<String, dynamic> j) {
    final ssp = j['sameStancePunish'] as Map<String, dynamic>?;
    return EnemyDef(
      id: j['id'] as String,
      name: j['name'] as String,
      rank: EnemyRank.parse(j['rank'] as String),
      hp: j['hp'] as int,
      structure: j['structure'] as int,
      phases: [
        for (final p in j['phases'] as List)
          EnemyPhase.fromJson(p as Map<String, dynamic>),
      ],
      rule: j['rule'] as String? ?? '',
      hanzi: j['hanzi'] as String?,
      pinyin: j['pinyin'] as String?,
      immovable: j['immovable'] as bool? ?? false,
      sameStancePunishDamage: ssp?['damage'] as int? ?? 0,
      sameStancePunishStructure: ssp?['structure'] as int? ?? 0,
    );
  }
}
