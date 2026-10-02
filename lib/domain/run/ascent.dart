import '../model/enums.dart';

/// Una subida terminada, tal como queda en el registro de la escuela: quién
/// subió (el número de discípulo), hasta dónde llegó y quién lo detuvo.
class Ascent {
  const Ascent({
    required this.n,
    required this.fell,
    required this.floor,
    required this.floors,
    required this.difficulty,
    this.pico = 0,
    this.enemy,
    this.scene,
    this.light,
    this.style,
    this.maxHp = 0,
    this.deck = 0,
    this.lore = const [],
  });

  /// Número del discípulo que subió.
  final int n;

  /// true si cayó en la montaña; false si llegó a la cumbre.
  final bool fell;
  final int floor;
  final int floors;
  final Difficulty difficulty;
  final int pico;

  /// El último rival (el que lo venció, o el jefe si ganó).
  final String? enemy;
  final String? scene;
  final String? light;
  final Style? style;
  final int maxHp;
  final int deck;

  /// Pergaminos que se abrieron con esta subida.
  final List<String> lore;

  Ascent withLore(List<String> ids) => Ascent(
    n: n,
    fell: fell,
    floor: floor,
    floors: floors,
    difficulty: difficulty,
    pico: pico,
    enemy: enemy,
    scene: scene,
    light: light,
    style: style,
    maxHp: maxHp,
    deck: deck,
    lore: ids,
  );

  Map<String, dynamic> toJson() => {
    'n': n,
    'fell': fell,
    'floor': floor,
    'floors': floors,
    'difficulty': difficulty.name,
    'pico': pico,
    'enemy': enemy,
    'scene': scene,
    'light': light,
    'style': style?.name,
    'maxHp': maxHp,
    'deck': deck,
    'lore': lore,
  };

  factory Ascent.fromJson(Map<String, dynamic> j) => Ascent(
    n: j['n'] as int,
    fell: j['fell'] as bool,
    floor: j['floor'] as int? ?? 0,
    floors: j['floors'] as int? ?? 0,
    difficulty: Difficulty.parse(j['difficulty'] as String),
    pico: j['pico'] as int? ?? 0,
    enemy: j['enemy'] as String?,
    scene: j['scene'] as String?,
    light: j['light'] as String?,
    style: switch (j['style']) {
      final String s => Style.parse(s),
      _ => null,
    },
    maxHp: j['maxHp'] as int? ?? 0,
    deck: j['deck'] as int? ?? 0,
    lore: [for (final s in (j['lore'] as List?) ?? const []) s as String],
  );
}

/// Los pergaminos de la escuela, en el orden en que se cuentan.
const loreOrder = [
  'prologue',
  'reach_shrine',
  'first_fall',
  'fell_disciple',
  'fell_monk',
  'fell_dragon',
  'summit',
  'fallen_5',
  'fallen_10',
];

/// Qué pergaminos abre una subida, dado lo que ya se tenía y las subidas
/// anteriores.
List<String> earnedLore(Ascent a, List<Ascent> before, Set<String> have) {
  final fallen = before.where((x) => x.fell).length + (a.fell ? 1 : 0);
  return [
    if (a.style != null) 'reach_shrine',
    if (a.fell) 'first_fall',
    if (a.fell && a.enemy == 'disciple') 'fell_disciple',
    if (a.fell && a.enemy == 'monk') 'fell_monk',
    if (a.fell && a.enemy == 'dragon') 'fell_dragon',
    if (!a.fell) 'summit',
    if (fallen >= 5) 'fallen_5',
    if (fallen >= 10) 'fallen_10',
  ].where((id) => !have.contains(id)).toList();
}
