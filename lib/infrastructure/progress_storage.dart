import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/enums.dart';
import '../domain/run/ascent.dart';

/// Recuerda en qué dificultades ganó el jugador una subida completa.
class ProgressStorage {
  static const _key = 'long_breath.winsByDifficulty';
  static const _picoKey = 'long_breath.picoUnlocked';
  static const _discipleKey = 'long_breath.disciple';
  static const _ascentsKey = 'long_breath.ascents';
  static const _loreKey = 'long_breath.lore';
  static const _breathKey = 'long_breath.breath';

  /// Subidas que guarda el registro (las más viejas se borran).
  static const maxAscents = 50;

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

extension SchoolRecord on ProgressStorage {
  /// Número del discípulo que sube ahora. Cada subida terminada (se caiga o
  /// se llegue a la cumbre) suma uno: la escuela manda al siguiente. Quien
  /// ya había ganado antes del registro arranca después de esas victorias.
  Future<int> discipleNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(ProgressStorage._discipleKey);
    if (saved != null) return saved;
    return 1 + (await wins()).length;
  }

  Future<List<Ascent>> ascents() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      for (final s in prefs.getStringList(ProgressStorage._ascentsKey) ??
          const <String>[])
        Ascent.fromJson(jsonDecode(s) as Map<String, dynamic>),
    ];
  }

  Future<Set<String>> lore() async {
    final prefs = await SharedPreferences.getInstance();
    return {...?prefs.getStringList(ProgressStorage._loreKey)};
  }

  /// Abre un pergamino; devuelve true si es nuevo.
  Future<bool> unlockLore(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final have = await lore();
    if (have.contains(id)) return false;
    await prefs.setStringList(ProgressStorage._loreKey, [...have, id]);
    return true;
  }

  /// Aliento acumulado por la escuela. La primera vez (guardados de antes
  /// del cultivo) se calcula con las subidas del registro usando [migrate].
  Future<int> breath({int Function(Ascent)? migrate}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(ProgressStorage._breathKey);
    if (saved != null) return saved;
    final past = await ascents();
    final total = migrate == null
        ? 0
        : past.fold(0, (a, x) => a + migrate(x));
    await prefs.setInt(ProgressStorage._breathKey, total);
    return total;
  }

  /// Anota la subida con el número del discípulo actual, abre los
  /// pergaminos que corresponden y pasa al siguiente discípulo. Devuelve la
  /// subida tal como quedó (con su número y sus pergaminos nuevos).
  /// También suma su aliento ([Ascent.breath]) al de la escuela.
  Future<Ascent> recordAscent(
    Ascent a, {
    int Function(Ascent)? migrate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final n = await discipleNumber();
    final had = await breath(migrate: migrate);
    final before = await ascents();
    final have = await lore();
    final numbered = Ascent.fromJson({
      ...a.toJson(),
      'n': n,
      'breathBefore': had,
    });
    final done = numbered.withLore(earnedLore(numbered, before, have));
    final all = [...before, done];
    await prefs.setStringList(ProgressStorage._ascentsKey, [
      for (final x in all.skip(
        all.length > ProgressStorage.maxAscents
            ? all.length - ProgressStorage.maxAscents
            : 0,
      ))
        jsonEncode(x.toJson()),
    ]);
    await prefs.setStringList(ProgressStorage._loreKey, [
      ...have,
      ...done.lore,
    ]);
    await prefs.setInt(ProgressStorage._discipleKey, n + 1);
    await prefs.setInt(ProgressStorage._breathKey, had + done.breath);
    return done;
  }
}

/// Shifu se gana: hace falta haber subido completa la montaña en Difícil.
bool isUnlocked(Difficulty d, Set<Difficulty> wins) =>
    d != Difficulty.shifu ||
    wins.contains(Difficulty.hard) ||
    wins.contains(Difficulty.shifu);
