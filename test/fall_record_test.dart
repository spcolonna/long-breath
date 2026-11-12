import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('caer en la primera sala anota a ese rival, no al guardián', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cinematicsProvider.overrideWithValue(false)],
        child: const LongBreathApp(),
      ),
    );
    for (var i = 0; i < 3; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final runs = container.read(runControllerProvider.notifier)
      ..newRun(Difficulty.normal);
    final r = container.read(runControllerProvider)!;
    final start = r.node(r.starts.first);
    runs.resume(
      r.copyWith(
        map: [
          for (final n in r.map)
            n.id == start.id
                ? MapNodeDef(
                    id: n.id,
                    type: n.type,
                    next: n.next,
                    enemy: 'salamander',
                    waves: const ['bat'],
                    scene: n.scene,
                    light: n.light,
                  )
                : n,
        ],
      ),
    );
    runs.enter(start.id);
    runs.beginCombat();
    runs.finishCombat(won: false, hp: 0, foe: 'bat');
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 200));
    }
    final last = container.read(lastAscentProvider);
    expect(last, isNotNull);
    expect(last!.fell, isTrue);
    expect(last.enemy, 'bat');
  });

}
