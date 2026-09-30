import 'package:shared_preferences/shared_preferences.dart';

/// Recuerda si el jugador ya hizo el entrenamiento.
class TutorialStorage {
  static const _key = 'long_breath.tutorialDone';

  Future<bool> isDone() async =>
      (await SharedPreferences.getInstance()).getBool(_key) ?? false;

  Future<void> markDone() async =>
      (await SharedPreferences.getInstance()).setBool(_key, true);
}
