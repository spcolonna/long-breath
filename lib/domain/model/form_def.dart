import 'enums.dart';

class FormEffect {
  const FormEffect({
    this.damage = 0,
    this.structure = 0,
    this.draw = 0,
    this.guard = 0,
    this.height,
    this.breath = 0,
    this.heal = 0,
    this.fistBonus = 0,
  });

  final int damage;
  final int structure;
  final int draw;
  final int guard;
  final Height? height;

  /// Aliento que se gana al completarla.
  final int breath;

  /// Vida que recupera.
  final int heal;

  /// Daño extra de los puños por el resto del combate.
  final int fistBonus;

  factory FormEffect.fromJson(Map<String, dynamic> j) => FormEffect(
        damage: j['damage'] as int? ?? 0,
        structure: j['structure'] as int? ?? 0,
        draw: j['draw'] as int? ?? 0,
        guard: j['guard'] as int? ?? 0,
        height: Height.parse(j['height'] as String?),
        breath: j['breath'] as int? ?? 0,
        heal: j['heal'] as int? ?? 0,
        fistBonus: j['fistBonus'] as int? ?? 0,
      );
}

/// Una forma (套路 tàolù): secuencia fija de cartas por id.
class FormDef {
  const FormDef({
    required this.id,
    required this.pinyin,
    required this.hanzi,
    required this.steps,
    required this.effect,
    this.pool,
  });

  final String id;
  final String pinyin;
  final String hanzi;
  final List<String> steps;
  final FormEffect effect;

  /// Camino que la enseña; null = cualquier camino (o novicio).
  final Style? pool;

  factory FormDef.fromJson(Map<String, dynamic> j) => FormDef(
        id: j['id'] as String,
        pinyin: j['pinyin'] as String,
        hanzi: j['hanzi'] as String,
        steps: (j['steps'] as List).cast<String>(),
        effect: FormEffect.fromJson(j['effect'] as Map<String, dynamic>),
        pool: switch (j['pool']) {
          final String s => Style.parse(s),
          _ => null,
        },
      );
}
