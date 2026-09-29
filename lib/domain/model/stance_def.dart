import 'enums.dart';

class StanceDef {
  const StanceDef({
    required this.id,
    required this.pinyin,
    required this.hanzi,
    required this.es,
    this.damageBonus = const {},
    this.structureBonus = const {},
    this.costModifier = const {},
    this.guardModifier = 0,
    this.incomingStructureMultiplier = 1,
    this.incomingStructureBonus = 0,
    this.deflectBreathBonus = 0,
  });

  final Stance id;
  final String pinyin;
  final String hanzi;
  final String es;
  final Map<CardType, int> damageBonus;
  final Map<CardType, int> structureBonus;
  final Map<CardType, int> costModifier;
  final int guardModifier;
  final double incomingStructureMultiplier;
  final int incomingStructureBonus;
  final int deflectBreathBonus;

  static Map<CardType, int> _typeMap(Object? o) => {
        for (final e in ((o as Map<String, dynamic>?) ?? const {}).entries)
          CardType.parse(e.key): e.value as int,
      };

  factory StanceDef.fromJson(Map<String, dynamic> j) => StanceDef(
        id: Stance.parse(j['id'] as String)!,
        pinyin: j['pinyin'] as String,
        hanzi: j['hanzi'] as String,
        es: j['es'] as String,
        damageBonus: _typeMap(j['damageBonus']),
        structureBonus: _typeMap(j['structureBonus']),
        costModifier: _typeMap(j['costModifier']),
        guardModifier: j['guardModifier'] as int? ?? 0,
        incomingStructureMultiplier:
            (j['incomingStructureMultiplier'] as num?)?.toDouble() ?? 1,
        incomingStructureBonus: j['incomingStructureBonus'] as int? ?? 0,
        deflectBreathBonus: j['deflectBreathBonus'] as int? ?? 0,
      );
}

class TransitionDef {
  const TransitionDef({
    required this.pinyin,
    required this.hanzi,
    required this.cost,
    required this.usesPerTurn,
  });

  final String pinyin;
  final String hanzi;
  final int cost;
  final int usesPerTurn;

  factory TransitionDef.fromJson(Map<String, dynamic> j) => TransitionDef(
        pinyin: j['pinyin'] as String,
        hanzi: j['hanzi'] as String,
        cost: j['cost'] as int,
        usesPerTurn: j['usesPerTurn'] as int,
      );
}
