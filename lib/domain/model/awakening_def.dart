/// Lo que cambia un despertar en la regla del camino. Cada campo en 0 no
/// hace nada; los despertares de una run se suman.
class AwakeningEffect {
  const AwakeningEffect({
    this.firstStrike = 0,
    this.chain = 0,
    this.retain = 0,
    this.draw = 0,
    this.retainedDiscount = 0,
    this.firstStrikeStructure = 0,
    this.firstStrikeDiscount = 0,
    this.breakDraw = 0,
    this.chainStructure = 0,
    this.thirdAttackDraw = 0,
    this.retainedDamage = 0,
    this.deflectBreath = 0,
    this.guardBonus = 0,
  });

  /// Se suman a la pasiva del camino (Tigre, Serpiente y Grulla).
  final int firstStrike;
  final int chain;
  final int retain;
  final int draw;
  final int retainedDiscount;

  /// El primer ataque del turno quita esta Estructura extra.
  final int firstStrikeStructure;

  /// El primer ataque del turno cuesta esto menos.
  final int firstStrikeDiscount;

  /// Cartas que se roban al desequilibrar al rival.
  final int breakDraw;

  /// Estructura extra de cada ataque por cada ataque anterior del turno.
  final int chainStructure;

  /// Cartas que se roban al jugar el tercer ataque del turno.
  final int thirdAttackDraw;

  /// Daño extra de los ataques que venían retenidos.
  final int retainedDamage;

  /// Aliento extra por cada desvío.
  final int deflectBreath;

  /// Guardia extra de cada defensa.
  final int guardBonus;

  static const none = AwakeningEffect();

  AwakeningEffect operator +(AwakeningEffect o) => AwakeningEffect(
    firstStrike: firstStrike + o.firstStrike,
    chain: chain + o.chain,
    retain: retain + o.retain,
    draw: draw + o.draw,
    retainedDiscount: retainedDiscount + o.retainedDiscount,
    firstStrikeStructure: firstStrikeStructure + o.firstStrikeStructure,
    firstStrikeDiscount: firstStrikeDiscount + o.firstStrikeDiscount,
    breakDraw: breakDraw + o.breakDraw,
    chainStructure: chainStructure + o.chainStructure,
    thirdAttackDraw: thirdAttackDraw + o.thirdAttackDraw,
    retainedDamage: retainedDamage + o.retainedDamage,
    deflectBreath: deflectBreath + o.deflectBreath,
    guardBonus: guardBonus + o.guardBonus,
  );

  factory AwakeningEffect.fromJson(Map<String, dynamic> j) => AwakeningEffect(
    firstStrike: j['firstStrike'] as int? ?? 0,
    chain: j['chain'] as int? ?? 0,
    retain: j['retain'] as int? ?? 0,
    draw: j['draw'] as int? ?? 0,
    retainedDiscount: j['retainedDiscount'] as int? ?? 0,
    firstStrikeStructure: j['firstStrikeStructure'] as int? ?? 0,
    firstStrikeDiscount: j['firstStrikeDiscount'] as int? ?? 0,
    breakDraw: j['breakDraw'] as int? ?? 0,
    chainStructure: j['chainStructure'] as int? ?? 0,
    thirdAttackDraw: j['thirdAttackDraw'] as int? ?? 0,
    retainedDamage: j['retainedDamage'] as int? ?? 0,
    deflectBreath: j['deflectBreath'] as int? ?? 0,
    guardBonus: j['guardBonus'] as int? ?? 0,
  );
}

/// Despertar (觉醒 juéxǐng): al superar una etapa, el espíritu del camino
/// enseña algo más y la regla del camino cambia por el resto de la subida.
class AwakeningDef {
  const AwakeningDef({
    required this.id,
    required this.hanzi,
    required this.effect,
  });

  final String id;

  /// Carácter que lo dibuja (no hace falta arte).
  final String hanzi;
  final AwakeningEffect effect;

  factory AwakeningDef.fromJson(Map<String, dynamic> j) => AwakeningDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    effect: AwakeningEffect.fromJson(j['effect'] as Map<String, dynamic>),
  );
}
