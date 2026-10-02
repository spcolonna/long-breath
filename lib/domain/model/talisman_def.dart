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

  /// Se aplica al empezar el combate (para la animación de aviso).
  bool get atStart =>
      startStance != null ||
      firstTurnBreath > 0 ||
      structure > 0 ||
      enemyHp > 0 ||
      enemyStructure > 0;

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
  );
}

/// Talismán (护符 hùfú): objeto pasivo que dura toda la subida.
class TalismanDef {
  const TalismanDef({
    required this.id,
    required this.hanzi,
    required this.rare,
    required this.effect,
  });

  final String id;

  /// Carácter que lo dibuja (no hace falta arte).
  final String hanzi;

  /// Los raros solo salen en el élite y en algunos eventos.
  final bool rare;
  final TalismanEffect effect;

  factory TalismanDef.fromJson(Map<String, dynamic> j) => TalismanDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    rare: j['rarity'] == 'rare',
    effect: TalismanEffect.fromJson(j['effect'] as Map<String, dynamic>),
  );
}
