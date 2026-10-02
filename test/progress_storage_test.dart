import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('Shifu se desbloquea al ganar en Difícil', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    expect(await storage.wins(), isEmpty);
    expect(isUnlocked(Difficulty.shifu, await storage.wins()), isFalse);
    expect(isUnlocked(Difficulty.hard, await storage.wins()), isTrue);

    await storage.markWin(Difficulty.normal);
    expect(isUnlocked(Difficulty.shifu, await storage.wins()), isFalse);

    await storage.markWin(Difficulty.hard);
    expect(await storage.wins(), {Difficulty.normal, Difficulty.hard});
    expect(isUnlocked(Difficulty.shifu, await storage.wins()), isTrue);
  });

  test('ganar abre el Pico siguiente al jugado, hasta el 10', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    expect(await storage.picoUnlocked(), 0);
    // Ganar en Fácil no abre Picos.
    await storage.markPicoWin(Difficulty.easy, 0);
    expect(await storage.picoUnlocked(), 0);
    await storage.markPicoWin(Difficulty.normal, 0);
    expect(await storage.picoUnlocked(), 1);
    await storage.markPicoWin(Difficulty.normal, 1);
    expect(await storage.picoUnlocked(), 2);
    // Ganar un Pico más bajo no cierra los abiertos.
    await storage.markPicoWin(Difficulty.hard, 0);
    expect(await storage.picoUnlocked(), 2);
    await storage.markPicoWin(Difficulty.normal, 10);
    expect(await storage.picoUnlocked(), ProgressStorage.maxPico);
  });

  test('quien ganó antes de los Picos ya tiene el 1', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.winsByDifficulty': ['normal'],
    });
    expect(await ProgressStorage().picoUnlocked(), 1);
  });

  test('ignora valores desconocidos guardados', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.winsByDifficulty': ['hard', 'legend'],
    });
    expect(await ProgressStorage().wins(), {Difficulty.hard});
  });
}
