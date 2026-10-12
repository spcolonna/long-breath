import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/model/enums.dart';
import 'progress_storage.dart';
import 'run_storage.dart';

/// Una partida: su escuela, su registro y su subida, con una dificultad
/// fija que se elige al crearla.
class SlotInfo {
  const SlotInfo({
    required this.slot,
    required this.difficulty,
    this.pico = 0,
    this.createdAt,
  });

  final int slot;
  final Difficulty difficulty;

  /// Pico con el que sube (0 = ninguno). Solo sobre Normal.
  final int pico;
  final DateTime? createdAt;

  SlotInfo copyWith({int? pico}) => SlotInfo(
    slot: slot,
    difficulty: difficulty,
    pico: pico ?? this.pico,
    createdAt: createdAt,
  );

  Map<String, dynamic> toJson() => {
    'difficulty': difficulty.name,
    'pico': pico,
    if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
  };

  factory SlotInfo.fromJson(int slot, Map<String, dynamic> j) => SlotInfo(
    slot: slot,
    difficulty: Difficulty.parse(j['difficulty'] as String?),
    pico: j['pico'] as int? ?? 0,
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? ''),
  );
}

/// Las tres partidas. Lo que no es de una partida (sonido, lecciones) queda
/// fuera: se comparte entre todas.
class SlotStorage {
  static const count = 3;
  static const _key = 'long_breath.slots';

  /// La partida 1 usa las claves de siempre: los guardados de antes de que
  /// hubiera partidas siguen ahí sin migrar nada.
  static String prefixOf(int slot) =>
      slot == 1 ? 'long_breath.' : 'long_breath.slot$slot.';

  ProgressStorage progress(int slot) => ProgressStorage(prefixOf(slot));
  RunStorage runs(int slot) => RunStorage(prefixOf(slot));

  /// Partidas creadas, por número. Si todavía no hay ninguna anotada pero
  /// quedó progreso de antes, ese progreso es la partida 1.
  Future<Map<int, SlotInfo>> slots() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw != null) {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      return {
        for (final e in j.entries)
          int.parse(e.key): SlotInfo.fromJson(
            int.parse(e.key),
            e.value as Map<String, dynamic>,
          ),
      };
    }
    final legacy = ProgressStorage.slotKeys.any(
      (k) => prefs.containsKey('${prefixOf(1)}$k'),
    );
    if (!legacy) return {};
    final run = await runs(1).load();
    final first = SlotInfo(
      slot: 1,
      difficulty: run?.difficulty ?? Difficulty.normal,
      pico: run?.pico ?? 0,
      createdAt: DateTime.now(),
    );
    await _save(prefs, {1: first});
    return {1: first};
  }

  Future<void> _save(SharedPreferences prefs, Map<int, SlotInfo> all) =>
      prefs.setString(
        _key,
        jsonEncode({for (final e in all.entries) '${e.key}': e.value.toJson()}),
      );

  /// Crea la partida [slot] desde cero (si había algo, se borra antes).
  Future<SlotInfo> create(int slot, Difficulty d, {int pico = 0}) async {
    await delete(slot);
    final prefs = await SharedPreferences.getInstance();
    final info = SlotInfo(
      slot: slot,
      difficulty: d,
      pico: pico,
      createdAt: DateTime.now(),
    );
    await _save(prefs, {...await slots(), slot: info});
    return info;
  }

  Future<void> setPico(int slot, int pico) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await slots();
    final info = all[slot];
    if (info == null) return;
    await _save(prefs, {...all, slot: info.copyWith(pico: pico)});
  }

  /// Borra la partida y todo su progreso. Lo compartido no se toca.
  Future<void> delete(int slot) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await slots();
    for (final k in ProgressStorage.slotKeys) {
      await prefs.remove('${prefixOf(slot)}$k');
    }
    all.remove(slot);
    await _save(prefs, all);
  }

  /// Dificultades ganadas en cualquier partida: lo que ya se abrió sirve
  /// para empezar otra.
  Future<Set<Difficulty>> allWins() async => {
    for (final s in (await slots()).keys) ...await progress(s).wins(),
  };

  /// Pico más alto abierto en cualquier partida.
  Future<int> bestPico() async {
    var best = 0;
    for (final s in (await slots()).keys) {
      final p = await progress(s).picoUnlocked();
      if (p > best) best = p;
    }
    return best;
  }
}
