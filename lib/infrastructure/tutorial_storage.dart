import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda qué lecciones del tutorial completó el jugador.
class TutorialStorage {
  static const _key = 'long_breath.lessonsDone';

  /// El entrenamiento viejo, de un solo combate, equivale a la primera lección.
  static const _legacyKey = 'long_breath.tutorialDone';

  Future<Set<String>> lessonsDone() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      ...?prefs.getStringList(_key),
      if (prefs.getBool(_legacyKey) ?? false) 'strike',
    };
  }

  Future<void> markDone(String lessonId) async {
    final prefs = await SharedPreferences.getInstance();
    final done = await lessonsDone();
    await prefs.setStringList(_key, {...done, lessonId}.toList());
  }
}
