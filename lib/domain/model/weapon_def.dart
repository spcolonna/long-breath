import 'enums.dart';
import 'talisman_def.dart';

/// Lo que da un arma en un nivel: su efecto (absoluto, no acumulado) y las
/// cartas que ese nivel suma al botín.
class WeaponLevelDef {
  const WeaponLevelDef({required this.effect, this.cards = const []});

  final TalismanEffect effect;
  final List<String> cards;

  factory WeaponLevelDef.fromJson(Map<String, dynamic> j) => WeaponLevelDef(
    effect: TalismanEffect.fromJson(
      (j['effect'] as Map<String, dynamic>?) ?? const {},
    ),
    cards: [for (final c in (j['cards'] as List?) ?? const []) c as String],
  );
}

/// Arma (兵器 bīngqì): una sola por subida, con niveles que se templan en el
/// botín, el mercader o con el maestro. Suma sus cartas al botín y da un
/// bonus extra a su camino afín.
class WeaponDef {
  const WeaponDef({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    required this.levels,
    this.path,
    this.pathBonus = TalismanEffect.none,
  });

  final String id;
  final String hanzi;
  final String pinyin;

  /// Camino afín (recibe [pathBonus]).
  final Style? path;
  final TalismanEffect pathBonus;
  final List<WeaponLevelDef> levels;

  int get maxLevel => levels.length;

  TalismanEffect effectAt(int level, Style? style) =>
      levels[level.clamp(1, maxLevel) - 1].effect +
      (style != null && style == path ? pathBonus : TalismanEffect.none);

  /// Cartas que suman los niveles hasta [level] inclusive.
  List<String> cardsUpTo(int level) => [
    for (final l in levels.take(level)) ...l.cards,
  ];

  factory WeaponDef.fromJson(Map<String, dynamic> j) => WeaponDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    pinyin: j['pinyin'] as String? ?? '',
    path: switch (j['path']) {
      final String s => Style.parse(s),
      _ => null,
    },
    pathBonus: TalismanEffect.fromJson(
      (j['pathBonus'] as Map<String, dynamic>?) ?? const {},
    ),
    levels: [
      for (final l in j['levels'] as List)
        WeaponLevelDef.fromJson(l as Map<String, dynamic>),
    ],
  );
}
