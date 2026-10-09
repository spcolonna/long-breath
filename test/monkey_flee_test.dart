import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('el Mono Ladrón se escapa con el jade', (tester) async {
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
        jade: 30,
        map: [
          for (final n in r.map)
            n.id == start.id
                ? MapNodeDef(
                    id: n.id,
                    type: n.type,
                    next: n.next,
                    enemy: 'monkey',
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
    expect(find.text('Mono Ladrón'), findsWidgets);
    // Dos acciones con manotazos y en la tercera se escapa.
    for (var i = 0; i < 3; i++) {
      combat.endTurnPressed();
      if (container.read(combatControllerProvider)!.retaining) {
        combat.confirmRetain();
      }
      await settle();
      await settle();
    }
    final stolen = container.read(combatControllerProvider)!.state.enemy.stolen;
    expect(stolen, greaterThan(0));
    expect(find.text('Se escapó'), findsOneWidget);
    expect(
      find.text('Mono Ladrón se escapó con $stolen de jade'),
      findsOneWidget,
    );
    await tester.tap(find.text('Continuar'));
    await settle();
    expect(container.read(runControllerProvider)!.jade, 30 - stolen);
    expect(find.text('−$stolen de jade · se lo llevó'), findsOneWidget);
  });
}
