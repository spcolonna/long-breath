import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/widgets/breather_sheet.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('oleadas: al caer uno se elige un respiro y entra el siguiente', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> settle() async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [cinematicsProvider.overrideWithValue(false)],
        child: const LongBreathApp(),
      ),
    );
    await settle();
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
    final combat = container.read(combatControllerProvider.notifier)..start();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/combat');
    await settle();
    CombatView view() => container.read(combatControllerProvider)!;
    final engine = container.read(combatEngineProvider);

    // El primero queda a un golpe.
    final s = view().state;
    combat.debugReplace(s.copyWith(enemy: s.enemy.copyWith(hp: 1)));
    final uid = view().state.hand
        .firstWhere((c) {
          final p = engine.preview(view().state, c.uid);
          return p.playable && p.damage > 0;
        })
        .uid;
    combat.tapCard(uid);
    combat.tapCard(uid);
    await settle();
    await settle();
    expect(view().state.phase, CombatPhase.breather);
    expect(find.byType(BreatherSheet), findsOneWidget);
    expect(find.text('Respiro'), findsOneWidget);

    await tester.tap(find.text('Concentrarte'));
    await settle();
    await settle();
    expect(find.byType(BreatherSheet), findsNothing);
    expect(view().state.phase, CombatPhase.playerTurn);
    expect(view().state.enemy.id, 'bat');
    expect(tester.takeException(), isNull);
  });
}
