import 'enums.dart';

/// Definición estática de una carta (valores base, antes de bonus).
class CardDef {
  const CardDef({
    required this.id,
    required this.pinyin,
    required this.hanzi,
    required this.type,
    required this.cost,
    this.stance,
    this.damage = 0,
    this.structure = 0,
    this.guard = 0,
    this.height,
    this.draw = 0,
    this.gainBreath = 0,
    this.exhaust = false,
    this.firstTurnOnly = false,
    this.bonusDamageIfStaggered = 0,
    this.onDeflectDamage = 0,
    this.onDeflectStructure = 0,
    this.stanceStructureBonus,
    this.clearGuard = false,
    this.turnStructureBonus = 0,
    this.chainDamage = 0,
    this.retainedDamage = 0,
    this.chainStructure = 0,
    this.retainedStructure = 0,
    this.pool = 'starter',
    this.copies = 1,
  });

  final String id;
  final String pinyin;
  final String hanzi;
  final CardType type;
  final int cost;
  final Stance? stance;
  final int damage;
  final int structure;
  final int guard;
  final Height? height;
  final int draw;
  final int gainBreath;
  final bool exhaust;
  final bool firstTurnOnly;
  final int bonusDamageIfStaggered;
  final int onDeflectDamage;
  final int onDeflectStructure;
  final (Stance, int)? stanceStructureBonus;
  final bool clearGuard;
  final int turnStructureBonus;

  /// Daño extra por cada ataque jugado antes en el turno (Serpiente).
  final int chainDamage;

  /// Daño extra si la carta viene retenida del turno anterior (Grulla).
  final int retainedDamage;

  /// Estructura extra por cada ataque jugado antes en el turno (Serpiente).
  final int chainStructure;

  /// Estructura extra si la carta viene retenida del turno anterior (Grulla).
  final int retainedStructure;
  final String pool;
  final int copies;

  factory CardDef.fromJson(Map<String, dynamic> j) {
    final ssb = j['stanceStructureBonus'] as Map<String, dynamic>?;
    return CardDef(
      id: j['id'] as String,
      pinyin: j['pinyin'] as String,
      hanzi: j['hanzi'] as String,
      type: CardType.parse(j['type'] as String),
      cost: j['cost'] as int,
      stance: Stance.parse(j['stance'] as String?),
      damage: j['damage'] as int? ?? 0,
      structure: j['structure'] as int? ?? 0,
      guard: j['guard'] as int? ?? 0,
      height: Height.parse(j['height'] as String?),
      draw: j['draw'] as int? ?? 0,
      gainBreath: j['gainBreath'] as int? ?? 0,
      exhaust: j['exhaust'] as bool? ?? false,
      firstTurnOnly: j['firstTurnOnly'] as bool? ?? false,
      bonusDamageIfStaggered: j['bonusDamageIfStaggered'] as int? ?? 0,
      onDeflectDamage: j['onDeflectDamage'] as int? ?? 0,
      onDeflectStructure: j['onDeflectStructure'] as int? ?? 0,
      stanceStructureBonus: ssb == null
          ? null
          : (Stance.parse(ssb['stance'] as String)!, ssb['value'] as int),
      clearGuard: j['clearGuard'] as bool? ?? false,
      turnStructureBonus: j['turnStructureBonus'] as int? ?? 0,
      chainDamage: j['chainDamage'] as int? ?? 0,
      retainedDamage: j['retainedDamage'] as int? ?? 0,
      chainStructure: j['chainStructure'] as int? ?? 0,
      retainedStructure: j['retainedStructure'] as int? ?? 0,
      pool: j['pool'] as String? ?? 'starter',
      copies: j['copies'] as int? ?? 1,
    );
  }
}
