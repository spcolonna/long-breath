import 'enums.dart';

class FormEffect {
  const FormEffect({
    this.damage = 0,
    this.structure = 0,
    this.draw = 0,
    this.guard = 0,
    this.height,
  });

  final int damage;
  final int structure;
  final int draw;
  final int guard;
  final Height? height;

  factory FormEffect.fromJson(Map<String, dynamic> j) => FormEffect(
        damage: j['damage'] as int? ?? 0,
        structure: j['structure'] as int? ?? 0,
        draw: j['draw'] as int? ?? 0,
        guard: j['guard'] as int? ?? 0,
        height: Height.parse(j['height'] as String?),
      );
}

/// Una forma (套路 tàolù): secuencia fija de cartas por id.
class FormDef {
  const FormDef({
    required this.id,
    required this.pinyin,
    required this.hanzi,
    required this.es,
    required this.steps,
    required this.effect,
  });

  final String id;
  final String pinyin;
  final String hanzi;
  final String es;
  final List<String> steps;
  final FormEffect effect;

  factory FormDef.fromJson(Map<String, dynamic> j) => FormDef(
        id: j['id'] as String,
        pinyin: j['pinyin'] as String,
        hanzi: j['hanzi'] as String,
        es: j['es'] as String,
        steps: (j['steps'] as List).cast<String>(),
        effect: FormEffect.fromJson(j['effect'] as Map<String, dynamic>),
      );
}
