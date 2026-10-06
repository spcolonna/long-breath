import 'enums.dart';

enum IntentKind {
  attack,
  guard,
  charge,
  discard,

  /// Se escapa: termina el combate y se lleva lo que robó.
  flee;

  static IntentKind parse(String s) => IntentKind.values.byName(s);
}

/// Acción anunciada por un enemigo.
class IntentDef {
  const IntentDef({
    required this.kind,
    this.labelKey,
    this.height,
    this.damage = 0,
    this.structure = 0,
    this.hits = 1,
    this.value = 0,
    this.count = 0,
    this.interrupt = false,
    this.countdown = false,
    this.drain = 0,
    this.freeze = 0,
    this.blocks,
  });

  final IntentKind kind;

  /// Clave del texto de la intención (content/{idioma}.json → intents).
  final String? labelKey;
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

  /// Si el ataque no se desvía: el próximo turno tenés esto menos de Aliento.
  final int drain;

  /// Si el ataque no se desvía: el próximo turno robás esto menos.
  final int freeze;

  /// Guardia que frena un solo tipo de golpe (puño, palma o patada); los
  /// otros la esquivan. null = frena todo.
  final CardType? blocks;

  factory IntentDef.fromJson(Map<String, dynamic> j) => IntentDef(
    kind: IntentKind.parse(j['kind'] as String),
    labelKey: j['labelKey'] as String?,
    height: Height.parse(j['height'] as String?),
    damage: j['damage'] as int? ?? 0,
    structure: j['structure'] as int? ?? 0,
    hits: j['hits'] as int? ?? 1,
    value: j['value'] as int? ?? 0,
    count: j['count'] as int? ?? 0,
    interrupt: j['interrupt'] as bool? ?? false,
    countdown: j['countdown'] as bool? ?? false,
    drain: j['drain'] as int? ?? 0,
    freeze: j['freeze'] as int? ?? 0,
    blocks: switch (j['blocks']) {
      final String b => CardType.parse(b),
      _ => null,
    },
  );
}

class EnemyPhase {
  const EnemyPhase({required this.pattern, this.hpThreshold, this.scales});

  final List<IntentDef> pattern;

  /// Al entrar en la fase, las escamas vuelven a este valor si tiene menos.
  final int? scales;

  /// La fase empieza cuando la Vida cae a este porcentaje o menos.
  final double? hpThreshold;

  factory EnemyPhase.fromJson(Map<String, dynamic> j) => EnemyPhase(
    pattern: [
      for (final i in j['pattern'] as List)
        IntentDef.fromJson(i as Map<String, dynamic>),
    ],
    hpThreshold: (j['hpThreshold'] as num?)?.toDouble(),
    scales: j['scales'] as int?,
  );
}

class EnemyDef {
  const EnemyDef({
    required this.id,
    required this.rank,
    required this.hp,
    required this.structure,
    required this.phases,
    this.hanzi,
    this.pinyin,
    String? art,
    this.immovable = false,
    this.sameStancePunishDamage = 0,
    this.sameStancePunishStructure = 0,
    this.scales = 0,
    this.wrath = 0,
    this.parry = 0,
    this.steal = 0,
    this.thorns = 0,
    this.regen = 0,
  }) : _art = art;

  final String id;
  final EnemyRank rank;
  final int hp;
  final int structure;
  final List<EnemyPhase> phases;
  final String? hanzi;
  final String? pinyin;
  final bool immovable;

  /// Imagen de `assets/art/enemies/`; los muñecos de práctica comparten una.
  String get art => _art ?? id;
  final String? _art;
  final int sameStancePunishDamage;
  final int sameStancePunishStructure;

  /// Escamas: cada golpe pierde este daño, salvo con el enemigo Desequilibrado.
  /// Cada vez que se lo desequilibra pierde una escama.
  final int scales;

  /// Despierta: después de cada acción sus golpes suman esto (se acumula).
  /// Desequilibrarlo lo vuelve a dormir (vuelve a 0).
  final int wrath;

  /// Abanico: el primer golpe con daño de cada turno no le hace daño y te
  /// devuelve esto. No funciona mientras está Desequilibrado.
  final int parry;

  /// Ladrón: cada golpe que te hace daño te roba este jade. Si se escapa,
  /// se lo lleva; si lo vencés, lo recuperás.
  final int steal;

  /// Espinas: cada carta tuya que le hace daño te quita esta Vida (las
  /// formas no). No funciona mientras está Desequilibrado.
  final int thorns;

  /// Antes de cada acción recupera esta Vida. Si está Desequilibrado y
  /// pierde la acción, tampoco se cura.
  final int regen;

  factory EnemyDef.fromJson(Map<String, dynamic> j) {
    final ssp = j['sameStancePunish'] as Map<String, dynamic>?;
    return EnemyDef(
      id: j['id'] as String,
      rank: EnemyRank.parse(j['rank'] as String),
      hp: j['hp'] as int,
      structure: j['structure'] as int,
      phases: [
        for (final p in j['phases'] as List)
          EnemyPhase.fromJson(p as Map<String, dynamic>),
      ],
      hanzi: j['hanzi'] as String?,
      pinyin: j['pinyin'] as String?,
      art: j['art'] as String?,
      immovable: j['immovable'] as bool? ?? false,
      sameStancePunishDamage: ssp?['damage'] as int? ?? 0,
      sameStancePunishStructure: ssp?['structure'] as int? ?? 0,
      scales: j['scales'] as int? ?? 0,
      wrath: j['wrath'] as int? ?? 0,
      parry: j['parry'] as int? ?? 0,
      steal: j['steal'] as int? ?? 0,
      thorns: j['thorns'] as int? ?? 0,
      regen: j['regen'] as int? ?? 0,
    );
  }
}
