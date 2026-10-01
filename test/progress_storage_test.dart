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

  test('ignora valores desconocidos guardados', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.winsByDifficulty': ['hard', 'legend'],
    });
    expect(await ProgressStorage().wins(), {Difficulty.hard});
  });
}
