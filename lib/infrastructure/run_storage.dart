import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../domain/run/run_state.dart';

/// Guardado local de la run en curso de una partida.
class RunStorage {
  RunStorage([String prefix = 'long_breath.']) : _key = '${prefix}run';

  final String _key;

  Future<RunState?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null) return null;
    try {
      return RunState.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } on Object catch (e) {
      // No se pierde: queda aparte para poder recuperarla o mirar qué pasó.
      debugPrint('Guardado de la subida ilegible, respaldado: $e');
      await prefs.setString('${_key}_corrupt', raw);
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
