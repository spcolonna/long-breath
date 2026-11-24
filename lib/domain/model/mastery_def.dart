import 'enums.dart';

/// Un nivel de maestría de camino: la experiencia que pide y lo que abre en
/// cada camino (cartas, despertares o la carta del nivel 3 de su arma).
class MasteryLevel {
  const MasteryLevel({required this.xp, this.unlocks = const {}});

  /// Experiencia acumulada del camino para llegar a este nivel.
  final int xp;
  final Map<Style, List<String>> unlocks;

  List<String> of(Style s) => unlocks[s] ?? const [];

  factory MasteryLevel.fromJson(Map<String, dynamic> j) => MasteryLevel(
    xp: j['xp'] as int,
    unlocks: {
      for (final s in Style.values)
        if (j[s.name] is List)
          s: [for (final id in j[s.name] as List) id as String],
    },
  );
}

/// Maestría por camino: cada camino sube de nivel con lo que se pelea con él
/// y abre lo suyo. Lo que todavía no abrió queda cerrado como lo del cultivo.
class MasteryDef {
  const MasteryDef({
    this.perCombat = 0,
    this.elite = 0,
    this.boss = 0,
    this.victory = 0,
    this.levels = const [],
  });

  /// Experiencia por pelea ganada, extra por élite y jefe, y por la cumbre.
  final int perCombat;
  final int elite;
  final int boss;
  final int victory;
  final List<MasteryLevel> levels;

  static const none = MasteryDef();

  bool get isEmpty => levels.isEmpty;
  int get maxLevel => levels.length;

  /// Nivel con [xp] de experiencia (0 = nada abierto).
  int levelOf(int xp) => levels.where((l) => xp >= l.xp).length;

  /// Experiencia que pide el nivel siguiente (null en el último).
  int? nextXp(int xp) {
    final lv = levelOf(xp);
    return lv < levels.length ? levels[lv].xp : null;
  }

  /// Progreso hacia el nivel siguiente (0..1; 1 en el último).
  double progress(int xp) {
    final lv = levelOf(xp);
    if (lv >= levels.length) return 1;
    final from = lv == 0 ? 0 : levels[lv - 1].xp;
    return ((xp - from) / (levels[lv].xp - from)).clamp(0, 1).toDouble();
  }

  /// Experiencia de una pelea ganada.
  int xpFor({bool elite = false, bool boss = false, bool victory = false}) =>
      perCombat +
      (elite ? this.elite : 0) +
      (boss ? this.boss : 0) +
      (victory ? this.victory : 0);

  /// Lo que sigue cerrado con la experiencia de cada camino.
  List<String> lockedFor(Map<Style, int> xp) => [
    for (final s in Style.values)
      for (final l in levels.skip(levelOf(xp[s] ?? 0))) ...l.of(s),
  ];

  factory MasteryDef.fromJson(Map<String, dynamic>? j) {
    if (j == null) return none;
    final xp = j['xp'] as Map<String, dynamic>? ?? const {};
    return MasteryDef(
      perCombat: xp['perCombat'] as int? ?? 0,
      elite: xp['elite'] as int? ?? 0,
      boss: xp['boss'] as int? ?? 0,
      victory: xp['victory'] as int? ?? 0,
      levels: [
        for (final l in j['levels'] as List? ?? const [])
          MasteryLevel.fromJson(l as Map<String, dynamic>),
      ],
    );
  }
}
