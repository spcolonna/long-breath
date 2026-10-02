import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/ascent.dart';
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

  Ascent fell(String enemy, {Style? style}) => Ascent(
    n: 0,
    fell: true,
    floor: 3,
    floors: 9,
    difficulty: Difficulty.normal,
    enemy: enemy,
    style: style,
  );

  test('cada subida terminada pasa al discípulo siguiente', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    expect(await storage.discipleNumber(), 1);
    final first = await storage.recordAscent(fell('bat'));
    expect(first.n, 1);
    expect(await storage.discipleNumber(), 2);
    final second = await storage.recordAscent(
      const Ascent(
        n: 0,
        fell: false,
        floor: 9,
        floors: 9,
        difficulty: Difficulty.normal,
        enemy: 'dragon',
      ),
    );
    expect(second.n, 2);
    expect(await storage.discipleNumber(), 3);
    expect([for (final a in await storage.ascents()) a.n], [1, 2]);
  });

  test('quien ya había ganado arranca después de sus victorias', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    await storage.markWin(Difficulty.normal);
    await storage.markWin(Difficulty.hard);
    expect(await storage.discipleNumber(), 3);
  });

  test('caer abre pergaminos, una sola vez cada uno', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    final a = await storage.recordAscent(fell('disciple', style: Style.snake));
    expect(a.lore, ['reach_shrine', 'first_fall', 'fell_disciple']);
    final b = await storage.recordAscent(fell('disciple'));
    expect(b.lore, isEmpty);
    for (var i = 0; i < 3; i++) {
      await storage.recordAscent(fell('bat'));
    }
    expect(await storage.lore(), contains('fallen_5'));
    expect(await storage.lore(), isNot(contains('fallen_10')));
    expect(await storage.unlockLore('prologue'), isTrue);
    expect(await storage.unlockLore('prologue'), isFalse);
  });

  test('el registro sobrevive guardar y leer', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    await storage.recordAscent(
      const Ascent(
        n: 0,
        fell: true,
        floor: 8,
        floors: 9,
        difficulty: Difficulty.hard,
        pico: 3,
        enemy: 'monk',
        scene: 'campanas',
        light: 'niebla',
        style: Style.crane,
        maxHp: 54,
        deck: 15,
      ),
    );
    final a = (await storage.ascents()).single;
    expect(a.difficulty, Difficulty.hard);
    expect(a.pico, 3);
    expect(a.style, Style.crane);
    expect(a.scene, 'campanas');
    expect(a.lore, contains('fell_monk'));
  });
}
