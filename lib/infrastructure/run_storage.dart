import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/run/run_state.dart';

/// Guardado local de la run en curso.
class RunStorage {
  static const _key = 'long_breath.run';

  Future<RunState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return RunState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object {
      await prefs.remove(_key);
      return null;
    }
  }

  Future<void> save(RunState? run) async {
    final prefs = await SharedPreferences.getInstance();
    if (run == null) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, jsonEncode(run.toJson()));
    }
  }
}
