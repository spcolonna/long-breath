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
  });

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
  );
}

/// De dónde sale un talismán: los comunes de cualquier lado, los raros del
/// élite, el mercader de arriba y algunos eventos, y los de jefe solo del
/// jefe de etapa (cambian una regla grande, a veces con un costo).
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
  });

  final String id;

  /// Carácter que lo dibuja (no hace falta arte).
  final String hanzi;

  final TalismanTier tier;
  final TalismanEffect effect;

  bool get rare => tier == TalismanTier.rare;
  bool get boss => tier == TalismanTier.boss;

  factory TalismanDef.fromJson(Map<String, dynamic> j) => TalismanDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    tier: TalismanTier.parse(j['rarity'] as String?),
    effect: TalismanEffect.fromJson(j['effect'] as Map<String, dynamic>),
  );
}
