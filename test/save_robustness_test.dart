import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:long_breath/infrastructure/run_storage.dart';
import 'package:long_breath/infrastructure/slot_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('un guardado de subida ilegible se respalda en vez de perderse',
      () async {
    SharedPreferences.setMockInitialValues({'long_breath.run': '{roto'});
    expect(await RunStorage().load(), isNull);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('long_breath.run'), isNull);
    expect(prefs.getString('long_breath.run_corrupt'), '{roto');
  });

  test('una tablilla rota no tira abajo el registro', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.ascents': [
        'no es json',
        jsonEncode({'n': 3, 'fell': true, 'floor': 4, 'difficulty': 'normal'}),
      ],
    });
    final list = await ProgressStorage().ascents();
    expect(list.map((a) => a.n), [3]);
  });

  test('una ficha de partida rota se saltea y las demás siguen', () async {
    SharedPreferences.setMockInitialValues({
      'long_breath.slots': jsonEncode({
        '1': {'difficulty': 'inexistente'},
        '2': {'difficulty': 'hard'},
        'nope': {},
      }),
    });
    final slots = await SlotStorage().slots();
    expect(slots.keys, [2]);
  });
}
