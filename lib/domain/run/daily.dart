import '../model/enums.dart';

/// El desafío diario: la misma montaña para todos cada día. La semilla y el
/// camino salen de la fecha; no lleva nada de la partida (ni meridianos, ni
/// escuela, ni hilos), así que dos jugadores suben lo mismo.

/// El día como aaaammdd (hora local).
int dailyDay(DateTime d) => d.year * 10000 + d.month * 100 + d.day;

DateTime _date(int day) => DateTime.utc(day ~/ 10000, day ~/ 100 % 100, day % 100);

/// Días desde el primer desafío (1/1/2026).
int dailyIndex(int day) => _date(day).difference(DateTime.utc(2026)).inDays;

/// El día anterior, en aaaammdd.
int dailyBefore(int day) =>
    dailyDay(_date(day).subtract(const Duration(days: 1)));

/// Semilla del día: mezcla de enteros (splitmix) para que días seguidos no
/// den montañas parecidas.
int dailySeed(int day) {
  var z = (day * 0x9E3779B1) & 0x7FFFFFFF;
  z = ((z ^ (z >> 15)) * 0x2C1B3C6D) & 0x7FFFFFFF;
  z = ((z ^ (z >> 12)) * 0x297A2D39) & 0x7FFFFFFF;
  return (z ^ (z >> 15)) & 0x7FFFFFFF;
}

/// El camino del día: los tres se turnan.
Style dailyStyle(int day) =>
    Style.values[dailyIndex(day) % Style.values.length];

/// Cómo terminó el desafío de un día. Se guarda al empezar (como caída en
/// el primer piso) y se corrige al terminar: abandonarlo no da otro intento.
class DailyResult {
  const DailyResult({
    required this.day,
    required this.style,
    this.won = false,
    this.floor = 0,
    this.floors = 0,
    this.done = false,
  });

  final int day;
  final Style style;
  final bool won;
  final int floor;
  final int floors;

  /// Terminó (ganó o cayó); si no, quedó a medias o abandonado.
  final bool done;

  Map<String, dynamic> toJson() => {
    'd': day,
    's': style.name,
    if (won) 'w': true,
    'f': floor,
    'n': floors,
    if (done) 'x': true,
  };

  static DailyResult? fromJson(Map<String, dynamic> j) {
    final day = (j['d'] as num?)?.toInt();
    final s = Style.values.where((v) => v.name == j['s']).firstOrNull;
    if (day == null || s == null) return null;
    return DailyResult(
      day: day,
      style: s,
      won: j['w'] as bool? ?? false,
      floor: (j['f'] as num?)?.toInt() ?? 0,
      floors: (j['n'] as num?)?.toInt() ?? 0,
      done: j['x'] as bool? ?? false,
    );
  }
}

/// Lo que llevás con un camino en los desafíos.
class DailyPathStats {
  const DailyPathStats({this.played = 0, this.won = 0, this.best = 0});
  final int played;
  final int won;

  /// Piso más alto alcanzado.
  final int best;
}

class DailyStats {
  const DailyStats({required this.paths, required this.streak});

  final Map<Style, DailyPathStats> paths;

  /// Días seguidos jugados, contando hoy o (si hoy todavía no) ayer.
  final int streak;

  int get played => paths.values.fold(0, (a, p) => a + p.played);
  int get won => paths.values.fold(0, (a, p) => a + p.won);
}

DailyStats dailyStats(Iterable<DailyResult> results, int today) {
  final paths = <Style, DailyPathStats>{};
  final days = <int>{};
  for (final r in results) {
    days.add(r.day);
    final p = paths[r.style] ?? const DailyPathStats();
    paths[r.style] = DailyPathStats(
      played: p.played + 1,
      won: p.won + (r.won ? 1 : 0),
      best: r.floor > p.best ? r.floor : p.best,
    );
  }
  var day = days.contains(today) ? today : dailyBefore(today);
  var streak = 0;
  while (days.contains(day)) {
    streak++;
    day = dailyBefore(day);
  }
  return DailyStats(paths: paths, streak: streak);
}
