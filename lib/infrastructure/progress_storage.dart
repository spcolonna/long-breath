import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/enums.dart';

/// Recuerda en qué dificultades ganó el jugador una subida completa.
class ProgressStorage {
  static const _key = 'long_breath.winsByDifficulty';

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
}

/// Shifu se gana: hace falta haber subido completa la montaña en Difícil.
bool isUnlocked(Difficulty d, Set<Difficulty> wins) =>
    d != Difficulty.shifu ||
    wins.contains(Difficulty.hard) ||
    wins.contains(Difficulty.shifu);
