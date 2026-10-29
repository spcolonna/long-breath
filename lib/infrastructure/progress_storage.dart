import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/enums.dart';
import '../domain/model/meta_bonus.dart';
import '../domain/run/ascent.dart';
import '../domain/run/feats.dart';

/// Progreso de una partida: en qué dificultades ganó, la escuela, el
/// registro, el loto y lo que ya vio. Cada partida guarda sus claves con su
/// propio [prefix] (la 1 usa las de siempre, sin prefijo de partida).
class ProgressStorage {
  ProgressStorage([this.prefix = 'long_breath.']);

  final String prefix;

  /// Claves (sin prefijo) que son de una partida; borrarla las quita todas.
  static const slotKeys = [
    'winsByDifficulty',
    'picoUnlocked',
    'disciple',
    'ascents',
    'lore',
    'breath',
    'lotus',
    'meridians',
    'cinematics',
    'run',
    'hitos',
  ];

  String get _key => '${prefix}winsByDifficulty';
  String get _picoKey => '${prefix}picoUnlocked';
  String get _discipleKey => '${prefix}disciple';
  String get _ascentsKey => '${prefix}ascents';
  String get _loreKey => '${prefix}lore';
  String get _breathKey => '${prefix}breath';
  String get _lotusKey => '${prefix}lotus';
  String get _meridiansKey => '${prefix}meridians';
  String get _cinematicsKey => '${prefix}cinematics';
  String get _hitosKey => '${prefix}hitos';

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
    final saved = prefs.getInt(_discipleKey);
    if (saved != null) return saved;
    return 1 + (await wins()).length;
  }

  Future<List<Ascent>> ascents() async {
    final prefs = await SharedPreferences.getInstance();
    return [
      for (final s in prefs.getStringList(_ascentsKey) ??
          const <String>[])
        Ascent.fromJson(jsonDecode(s) as Map<String, dynamic>),
    ];
  }

  Future<Set<String>> lore() async {
    final prefs = await SharedPreferences.getInstance();
    return {...?prefs.getStringList(_loreKey)};
  }

  /// Abre un pergamino; devuelve true si es nuevo.
  Future<bool> unlockLore(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final have = await lore();
    if (have.contains(id)) return false;
    await prefs.setStringList(_loreKey, [...have, id]);
    return true;
  }

  /// Aliento acumulado por la escuela. La primera vez (guardados de antes
  /// del cultivo) se calcula con las subidas del registro usando [migrate].
  Future<int> breath({int Function(Ascent)? migrate}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getInt(_breathKey);
    if (saved != null) return saved;
    final past = await ascents();
    final total = migrate == null
        ? 0
        : past.fold(0, (a, x) => a + migrate(x));
    await prefs.setInt(_breathKey, total);
    return total;
  }

  /// Hitos cumplidos en la partida. La primera vez (partidas de antes de
  /// los hitos) se revisan las subidas del registro y su aliento se suma.
  Future<Set<String>> hitos({int Function(Ascent)? migrate}) async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_hitosKey);
    if (saved != null) return {...saved};
    final had = await breath(migrate: migrate);
    final past = await ascents();
    final got = <String>{};
    for (final (i, a) in past.indexed) {
      got.addAll(earnedHitos(a, past.take(i).toList(), got));
    }
    await prefs.setStringList(_hitosKey, got.toList());
    await prefs.setInt(_breathKey, had + hitoBreath(got));
    return got;
  }

  /// Anota la subida con el número del discípulo actual, abre los
  /// pergaminos y los hitos que corresponden y pasa al siguiente discípulo.
  /// Devuelve la subida tal como quedó (con su número, sus pergaminos y sus
  /// hitos nuevos). También suma su aliento ([Ascent.breath], con el extra
  /// de los hitos) al de la escuela.
  Future<Ascent> recordAscent(
    Ascent a, {
    int Function(Ascent)? migrate,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final n = await discipleNumber();
    final got = await hitos(migrate: migrate);
    final had = await breath(migrate: migrate);
    final seeds = await lotus();
    final before = await ascents();
    final have = await lore();
    final numbered = Ascent.fromJson({
      ...a.toJson(),
      'n': n,
      'breathBefore': had,
      'lotusBefore': seeds,
    });
    final fresh = earnedHitos(numbered, before, got);
    final done = Ascent.fromJson({
      ...numbered.toJson(),
      'breath': numbered.breath + hitoBreath(fresh),
      'hitos': fresh,
    }).withLore(earnedLore(numbered, before, have));
    final all = [...before, done];
    await prefs.setStringList(_ascentsKey, [
      for (final x in all.skip(
        all.length > ProgressStorage.maxAscents
            ? all.length - ProgressStorage.maxAscents
            : 0,
      ))
        jsonEncode(x.toJson()),
    ]);
    await prefs.setStringList(_loreKey, [
      ...have,
      ...done.lore,
    ]);
    await prefs.setStringList(_hitosKey, [...got, ...fresh]);
    await prefs.setInt(_discipleKey, n + 1);
    await prefs.setInt(_breathKey, had + done.breath);
    await prefs.setInt(_lotusKey, seeds + done.lotus);
    return done;
  }

  /// Semillas de loto de la escuela (para el árbol de meridianos).
  Future<int> lotus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_lotusKey) ?? 0;
  }

  /// Suma loto a mano (menú de pruebas).
  Future<void> addLotus(int n) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lotusKey, await lotus() + n);
  }

  /// Puntos del árbol de meridianos ya abiertos.
  Future<List<String>> meridians() async {
    final prefs = await SharedPreferences.getInstance();
    return [...?prefs.getStringList(_meridiansKey)];
  }

  /// Abre un punto del árbol si se puede y alcanza el loto.
  Future<bool> openMeridian(MeridianDef def, MeridianNode n, int realm) async {
    final prefs = await SharedPreferences.getInstance();
    final owned = await meridians();
    final seeds = await lotus();
    if (!def.canOpen(n, realm, owned) || seeds < n.cost) return false;
    await prefs.setInt(_lotusKey, seeds - n.cost);
    await prefs.setStringList(_meridiansKey, [...owned, n.id]);
    return true;
  }

  /// Presentaciones (etapas y jefes) que ya se vieron completas: después
  /// se muestran en versión corta.
  Future<bool> cinematicSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_cinematicsKey)?.contains(id) ??
        false;
  }

  Future<void> markCinematicSeen(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final seen = prefs.getStringList(_cinematicsKey) ?? [];
    if (seen.contains(id)) return;
    await prefs.setStringList(_cinematicsKey, [...seen, id]);
  }
}

/// Shifu se gana: hace falta haber subido completa la montaña en Difícil.
bool isUnlocked(Difficulty d, Set<Difficulty> wins) =>
    d != Difficulty.shifu ||
    wins.contains(Difficulty.hard) ||
    wins.contains(Difficulty.shifu);
