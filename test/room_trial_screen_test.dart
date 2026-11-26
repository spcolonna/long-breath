import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/trial_widgets.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La condición y el reto se ven en la puerta y en el combate, también en
/// un teléfono chico.
void main() {
  {
    testWidgets('sala con niebla y reto: puerta y combate', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1320, 2868);
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
      // Los datos del juego se cargan del bundle: esperar a que estén.
      for (var i = 0; i < 20 && find.byType(Scaffold).evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
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
                      type: NodeType.combat,
                      next: n.next,
                      enemy: 'golem',
                      waves: const ['bat'],
                      together: true,
                      scene: n.scene,
                      light: 'niebla',
                      rule: RoomRule.fog,
                      challenge: Challenge.flawless,
                    )
                  : n,
          ],
        ),
      );
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/map');
      await settle();
      expect(find.byType(TrialBadges), findsWidgets);

      runs.enter(start.id);
      container.read(combatControllerProvider.notifier).start();
      router.go('/combat');
      await settle();
      await settle();
      expect(find.byType(TrialChip), findsOneWidget);
      expect(find.text('Sin un rasguño'), findsWidgets);
      // Turno 1 con niebla: no se ve lo que harán.
      expect(find.text('Oculto en la niebla'), findsWidgets);
      expect(tester.takeException(), isNull);

      // En un teléfono chico (iPhone SE) también entra.
      tester.view.physicalSize = const Size(750, 1334);
      tester.view.devicePixelRatio = 2;
      await settle();
      expect(find.byType(TrialChip), findsOneWidget);
      expect(tester.takeException(), isNull);
      router.go('/map');
      await settle();
      expect(tester.takeException(), isNull);
    });
  }
}
