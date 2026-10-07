import 'enums.dart';

/// Un reino del cultivo (境界 jìngjiè): con [breath] de aliento acumulado la
/// escuela le abre a los discípulos lo que hay en [unlocks] (ids de caminos,
/// cartas, talismanes y formas).
class RealmDef {
  const RealmDef({
    required this.id,
    required this.hanzi,
    required this.breath,
    this.unlocks = const [],
  });

  final String id;
  final String hanzi;

  /// Aliento acumulado que hace falta para llegar.
  final int breath;
  final List<String> unlocks;

  factory RealmDef.fromJson(Map<String, dynamic> j) => RealmDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    breath: j['breath'] as int,
    unlocks: [for (final s in (j['unlocks'] as List?) ?? const []) s as String],
  );
}

/// El cultivo del aliento: cada subida, se gane o se pierda, suma aliento a
/// la escuela; con aliento se sube de reino y se abren caminos, cartas,
/// talismanes y formas. Caer nunca resta. Lo que se abre da variedad, no
/// poder: la dificultad es la misma en cualquier reino.
class CultivationDef {
  const CultivationDef({
    this.realms = const [],
    this.perFloor = 0,
    this.perStage = 0,
    this.win = 0,
    this.difficulty = const {},
    this.perPico = 0,
  });

  /// Sin reinos: todo abierto (datos viejos y pruebas).
  static const none = CultivationDef();

  /// De menor a mayor; el primero arranca en 0.
  final List<RealmDef> realms;

  /// Aliento por piso alcanzado, por etapa superada y por llegar a la cumbre.
  final int perFloor;
  final int perStage;
  final int win;

  /// Porcentaje según la dificultad (100 = Normal).
  final Map<Difficulty, int> difficulty;

  /// Porcentaje extra por cada Pico.
  final int perPico;

  /// Aliento que deja una subida.
  int breathFor({
    required bool fell,
    required int floor,
    required int stage,
    required Difficulty diff,
    int pico = 0,
  }) {
    final base = perFloor * floor + perStage * stage + (fell ? 0 : win);
    final pct = (difficulty[diff] ?? 100) * (100 + perPico * pico) ~/ 100;
    return (base * pct / 100).round();
  }

  /// Índice del reino con [breath] acumulado (0 = el primero).
  int realmOf(int breath) {
    var r = 0;
    for (var i = 0; i < realms.length; i++) {
      if (breath >= realms[i].breath) r = i;
    }
    return r;
  }

  /// Lo que sigue cerrado en el reino [realm]: todo lo de los reinos de
  /// más arriba.
  List<String> lockedAt(int realm) => [
    for (final r in realms.skip(realm + 1)) ...r.unlocks,
  ];

  /// Lo que se abre al pasar del reino [from] al [to].
  List<String> opened(int from, int to) => [
    for (final r in realms.skip(from + 1).take(to - from)) ...r.unlocks,
  ];

  factory CultivationDef.fromJson(Map<String, dynamic> j) => CultivationDef(
    realms: [
      for (final r in (j['realms'] as List?) ?? const [])
        RealmDef.fromJson(r as Map<String, dynamic>),
    ],
    perFloor: j['perFloor'] as int? ?? 0,
    perStage: j['perStage'] as int? ?? 0,
    win: j['win'] as int? ?? 0,
    difficulty: {
      for (final e
          in ((j['difficulty'] as Map<String, dynamic>?) ?? const {}).entries)
        Difficulty.parse(e.key): e.value as int,
    },
    perPico: j['perPico'] as int? ?? 0,
  );
}
