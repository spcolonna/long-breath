import 'enums.dart';

/// Lo que hace un talismán. Cada campo en 0 (o null) no hace nada.
class TalismanEffect {
  const TalismanEffect({
    this.startStance,
    this.firstTurnBreath = 0,
    this.structure = 0,
    this.enemyHp = 0,
    this.enemyStructure = 0,
    this.maxHp = 0,
    this.fountainHeal = 0,
    this.winHeal = 0,
    this.deflectBreath = 0,
    this.formHeal = 0,
    this.stanceGuard = 0,
    this.dingbuDiscount = 0,
    this.winJade = 0,
    this.firstCardDiscount = 0,
    this.breakDraw = 0,
    this.deflectDamage = 0,
    this.turnBreath = 0,
    this.handSize = 0,
    this.guardKeepPct = 0,
    this.breakDamage = 0,
    this.thirdAttackDraw = 0,
    this.retainedGuard = 0,
    this.shopDiscountPct = 0,
    this.attackStructure = 0,
    this.guardPierce = 0,
    this.heavyDamage = 0,
    this.chainBreath = 0,
  });

  static const none = TalismanEffect();

  /// Postura con la que se empieza cada combate.
  final Stance? startStance;

  /// Aliento extra en el turno 1.
  final int firstTurnBreath;

  /// Estructura máxima extra en cada combate.
  final int structure;

  /// Vida que el rival tiene de menos al empezar.
  final int enemyHp;

  /// Estructura que el rival tiene de menos al empezar.
  final int enemyStructure;

  /// Vida máxima extra en la run (se suma al conseguirlo).
  final int maxHp;

  /// Vida extra que cura la fuente.
  final int fountainHeal;

  /// Vida que se recupera al ganar un combate.
  final int winHeal;

  /// Aliento extra por cada desvío.
  final int deflectBreath;

  /// Vida que cura cada forma completa.
  final int formHeal;

  // Los que cambian reglas.

  /// Guardia que se gana cada vez que se cambia de postura.
  final int stanceGuard;

  /// Aliento de menos que cuesta el Paso en T.
  final int dingbuDiscount;

  /// Jade extra al ganar un combate.
  final int winJade;

  /// Aliento de menos que cuesta la primera carta de cada turno.
  final int firstCardDiscount;

  /// Cartas que se roban al desequilibrar a un rival.
  final int breakDraw;

  /// Daño que devuelve cada desvío.
  final int deflectDamage;

  /// Aliento extra en cada turno (talismán de jefe).
  final int turnBreath;

  /// Cartas de más (o de menos, si es negativo) en cada mano.
  final int handSize;

  /// Porcentaje de la Guardia que queda al empezar el turno.
  final int guardKeepPct;

  // Los de camino y los del mercader.

  /// Daño que recibe el rival al quedar desequilibrado (Tigre).
  final int breakDamage;

  /// Cartas que roba el tercer ataque de cada turno (Serpiente).
  final int thirdAttackDraw;

  /// Guardia al empezar el turno por cada carta retenida (Grulla).
  final int retainedGuard;

  /// Porcentaje de descuento en el mercader.
  final int shopDiscountPct;

  /// Aliento por cada cadena de postura.
  final int chainBreath;

  // Los de las armas.

  /// Estructura extra que quita cada ataque con daño (Palo).
  final int attackStructure;

  /// Guardia del rival que atraviesan los ataques de carta (Espada).
  final int guardPierce;

  /// Daño extra de los ataques que cuestan 2 o más de Aliento (Pudao).
  final int heavyDamage;

  TalismanEffect operator +(TalismanEffect o) => TalismanEffect(
    startStance: startStance ?? o.startStance,
    firstTurnBreath: firstTurnBreath + o.firstTurnBreath,
    structure: structure + o.structure,
    enemyHp: enemyHp + o.enemyHp,
    enemyStructure: enemyStructure + o.enemyStructure,
    maxHp: maxHp + o.maxHp,
    fountainHeal: fountainHeal + o.fountainHeal,
    winHeal: winHeal + o.winHeal,
    deflectBreath: deflectBreath + o.deflectBreath,
    formHeal: formHeal + o.formHeal,
    stanceGuard: stanceGuard + o.stanceGuard,
    dingbuDiscount: dingbuDiscount + o.dingbuDiscount,
    winJade: winJade + o.winJade,
    firstCardDiscount: firstCardDiscount + o.firstCardDiscount,
    breakDraw: breakDraw + o.breakDraw,
    deflectDamage: deflectDamage + o.deflectDamage,
    turnBreath: turnBreath + o.turnBreath,
    handSize: handSize + o.handSize,
    guardKeepPct: guardKeepPct + o.guardKeepPct,
    breakDamage: breakDamage + o.breakDamage,
    thirdAttackDraw: thirdAttackDraw + o.thirdAttackDraw,
    retainedGuard: retainedGuard + o.retainedGuard,
    shopDiscountPct: shopDiscountPct + o.shopDiscountPct,
    attackStructure: attackStructure + o.attackStructure,
    guardPierce: guardPierce + o.guardPierce,
    heavyDamage: heavyDamage + o.heavyDamage,
    chainBreath: chainBreath + o.chainBreath,
  );

  /// Se aplica al empezar el combate (para la animación de aviso).
  bool get atStart =>
      startStance != null ||
      firstTurnBreath > 0 ||
      structure > 0 ||
      enemyHp > 0 ||
      enemyStructure > 0 ||
      turnBreath != 0 ||
      handSize != 0;

  factory TalismanEffect.fromJson(Map<String, dynamic> j) => TalismanEffect(
    startStance: Stance.parse(j['startStance'] as String?),
    firstTurnBreath: j['firstTurnBreath'] as int? ?? 0,
    structure: j['structure'] as int? ?? 0,
    enemyHp: j['enemyHp'] as int? ?? 0,
    enemyStructure: j['enemyStructure'] as int? ?? 0,
    maxHp: j['maxHp'] as int? ?? 0,
    fountainHeal: j['fountainHeal'] as int? ?? 0,
    winHeal: j['winHeal'] as int? ?? 0,
    deflectBreath: j['deflectBreath'] as int? ?? 0,
    formHeal: j['formHeal'] as int? ?? 0,
    stanceGuard: j['stanceGuard'] as int? ?? 0,
    dingbuDiscount: j['dingbuDiscount'] as int? ?? 0,
    winJade: j['winJade'] as int? ?? 0,
    firstCardDiscount: j['firstCardDiscount'] as int? ?? 0,
    breakDraw: j['breakDraw'] as int? ?? 0,
    deflectDamage: j['deflectDamage'] as int? ?? 0,
    turnBreath: j['turnBreath'] as int? ?? 0,
    handSize: j['handSize'] as int? ?? 0,
    guardKeepPct: j['guardKeepPct'] as int? ?? 0,
    breakDamage: j['breakDamage'] as int? ?? 0,
    thirdAttackDraw: j['thirdAttackDraw'] as int? ?? 0,
    retainedGuard: j['retainedGuard'] as int? ?? 0,
    shopDiscountPct: j['shopDiscountPct'] as int? ?? 0,
    attackStructure: j['attackStructure'] as int? ?? 0,
    guardPierce: j['guardPierce'] as int? ?? 0,
    heavyDamage: j['heavyDamage'] as int? ?? 0,
    chainBreath: j['chainBreath'] as int? ?? 0,
  );
}

/// De dónde sale un talismán: los comunes de cualquier lado, los raros del
/// élite, el mercader de arriba y algunos eventos, y los de jefe solo del
/// jefe de etapa (cambian una regla grande, a veces con un costo). Aparte,
/// los raros de camino solo le salen a ese camino y los del mercader solo se
/// compran.
enum TalismanTier {
  common,
  rare,
  boss;

  static TalismanTier parse(String? s) =>
      values.firstWhere((t) => t.name == s, orElse: () => common);
}

/// Talismán (护符 hùfú): objeto pasivo que dura toda la subida.
class TalismanDef {
  const TalismanDef({
    required this.id,
    required this.hanzi,
    required this.tier,
    required this.effect,
    this.pool,
    this.shop = false,
  });

  final String id;

  /// Carácter que lo dibuja (no hace falta arte).
  final String hanzi;

  final TalismanTier tier;
  final TalismanEffect effect;

  /// Camino al que pertenece (null = de todos).
  final Style? pool;

  /// Solo lo vende el mercader.
  final bool shop;

  bool get rare => tier == TalismanTier.rare;
  bool get boss => tier == TalismanTier.boss;

  factory TalismanDef.fromJson(Map<String, dynamic> j) => TalismanDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    tier: TalismanTier.parse(j['rarity'] as String?),
    effect: TalismanEffect.fromJson(j['effect'] as Map<String, dynamic>),
    pool: switch (j['pool']) {
      final String s => Style.parse(s),
      _ => null,
    },
    shop: j['shop'] as bool? ?? false,
  );
}
