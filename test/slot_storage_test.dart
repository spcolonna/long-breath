import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:long_breath/infrastructure/slot_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('el progreso de antes de las partidas es la Partida 1', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.disciple': 4,
      'long_breath.lotus': 16,
      'long_breath.lessonsDone': ['strike'],
    });
    final store = SlotStorage();
    final slots = await store.slots();
    expect(slots.keys, [1]);
    expect(slots[1]!.difficulty, Difficulty.normal);
    expect(await store.progress(1).discipleNumber(), 4);
    expect(await store.progress(1).lotus(), 16);
  });

  test('sin progreso no hay partidas', () async {
    SharedPreferences.setMockInitialValues({'long_breath.sfxOn': true});
    expect(await SlotStorage().slots(), isEmpty);
  });

  test('cada partida guarda lo suyo y borrar no toca las otras', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.lessonsDone': ['strike'],
      'long_breath.musicOn': false,
    });
    final store = SlotStorage();
    await store.create(1, Difficulty.easy);
    await store.create(2, Difficulty.hard);
    await store.progress(2).markWin(Difficulty.hard);
    await store.progress(2).addLotus(7);
    expect(await store.progress(1).lotus(), 0);
    expect(await store.progress(2).lotus(), 7);
    // Lo ganado en cualquier partida abre Shifu para crear otra.
    expect(await store.allWins(), {Difficulty.hard});

    await store.delete(2);
    final slots = await store.slots();
    expect(slots.keys, [1]);
    expect(slots[1]!.difficulty, Difficulty.easy);
    expect(await store.progress(2).lotus(), 0);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('long_breath.lessonsDone'), ['strike']);
    expect(prefs.getBool('long_breath.musicOn'), isFalse);
  });

  test('empezar de cero borra lo de antes de esa partida', () async {
    SharedPreferences.setMockInitialValues({'long_breath.lotus': 30});
    final store = SlotStorage();
    expect((await store.slots()).keys, [1]);
    await store.create(1, Difficulty.shifu);
    expect(await store.progress(1).lotus(), 0);
    expect((await store.slots())[1]!.difficulty, Difficulty.shifu);
    expect(ProgressStorage.slotKeys, contains('run'));
  });
}
