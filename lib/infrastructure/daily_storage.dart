import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/run/daily.dart';

/// Los desafíos diarios jugados. Son de todo el juego, no de una partida:
/// el diario no usa nada de la partida en juego.
class DailyStorage {
  const DailyStorage([this.key = 'long_breath.daily']);

  final String key;

  /// Días que se guardan (los más viejos se borran).
  static const keep = 400;

  Future<List<DailyResult>> results() async {
    final prefs = await SharedPreferences.getInstance();
    final out = <DailyResult>[];
    for (final s in prefs.getStringList(key) ?? const <String>[]) {
      try {
        final r = DailyResult.fromJson(jsonDecode(s) as Map<String, dynamic>);
        if (r != null) out.add(r);
      } on FormatException {
        continue;
      } on TypeError {
        continue;
      }
    }
    return out;
  }

  /// Guarda (o corrige) el resultado de su día.
  Future<void> save(DailyResult r) async {
    final prefs = await SharedPreferences.getInstance();
    final all = [
      for (final o in await results())
        if (o.day != r.day) o,
      r,
    ]..sort((a, b) => a.day.compareTo(b.day));
    final kept = all.length > keep ? all.sublist(all.length - keep) : all;
    await prefs.setStringList(key, [for (final o in kept) jsonEncode(o.toJson())]);
  }
}
