import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  // Bug real: el remate de la Serpiente mató al rival, el motor dio la pelea
  // por ganada y la pantalla quedó trabada (sin cartel ni Continuar).
  testWidgets('la Técnica que gana la pelea muestra la victoria', (
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
    runs.enter(r.starts.first);
    final combat = container.read(combatControllerProvider.notifier)..start();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/combat');
    await settle();

    final s = container.read(combatControllerProvider)!.state;
    combat.debugReplace(
      s.copyWith(
        style: Style.snake,
        flow: CombatEngine.flowMax,
        enemy: s.enemy.copyWith(hp: 1),
      ),
    );
    await settle();
    combat.technique();
    await settle();
    await settle();
    expect(container.read(combatControllerProvider)!.state.isOver, isTrue);
    expect(find.text('Continuar'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
