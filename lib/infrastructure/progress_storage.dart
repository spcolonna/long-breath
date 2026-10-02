import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/enums.dart';

/// Recuerda en qué dificultades ganó el jugador una subida completa.
class ProgressStorage {
  static const _key = 'long_breath.winsByDifficulty';
  static const _picoKey = 'long_breath.picoUnlocked';

  /// Último Pico que se puede elegir: 10 es la cima.
  static const maxPico = 10;

  Future<Set<Difficulty>> wins() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      for (final s in prefs.getStringList(_key) ?? const <String>[])
        if (Difficulty.values.any((d) => d.name == s)) Difficulty.parse(s),
    };
  }

  Future<void> markWin(Difficulty d) async {
    final prefs = await SharedPreferences.getInstance();
    final done = await wins();
    await prefs.setStringList(_key, {...done, d}.map((d) => d.name).toList());
  }

  /// Pico más alto abierto (0 = todavía ninguno). Quien ganó antes de que
  /// existieran los Picos ya tiene el 1.
  Future<int> picoUnlocked() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_picoKey);
    if (saved != null) return saved.clamp(0, maxPico);
    final won = (await wins()).any((d) => d != Difficulty.easy);
    return won ? 1 : 0;
  }

  /// Ganar en Normal (o más difícil) abre el Pico siguiente al jugado.
  Future<void> markPicoWin(Difficulty d, int pico) async {
    if (d == Difficulty.easy) return;
    final prefs = await SharedPreferences.getInstance();
    final open = await picoUnlocked();
    final next = (pico + 1).clamp(0, maxPico);
    if (next > open) await prefs.setInt(_picoKey, next);
  }
}

/// Shifu se gana: hace falta haber subido completa la montaña en Difícil.
bool isUnlocked(Difficulty d, Set<Difficulty> wins) =>
    d != Difficulty.shifu ||
    wins.contains(Difficulty.hard) ||
    wins.contains(Difficulty.shifu);
