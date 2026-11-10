import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/screens/stay_screen.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('estancia: sala, pausa con tregua, última sala y cofre', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> settle() async {
      for (var i = 0; i < 3; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
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
                    rooms: const [RoomDef('bat', waves: ['monkey'])],
                    scene: n.scene,
                    light: n.light,
                  )
                : n,
        ],
      ),
    );
    runs.enter(start.id);
    final combat = container.read(combatControllerProvider.notifier)..start();
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('/combat');
    await settle();
    expect(find.text('Sala 1/2'), findsWidgets);

    // Gana la sala de un golpe (los dos del grupo, a 1 de Vida).
    Future<void> win() async {
      final engine = container.read(combatEngineProvider);
      for (var guard = 0; guard < 4; guard++) {
        final v = container.read(combatControllerProvider)!;
        if (v.state.isOver) break;
        if (v.state.phase.name != 'breather') {
          combat.debugReplace(
              v.state.copyWith(enemy: v.state.enemy.copyWith(hp: 1)));
        }
        final s = container.read(combatControllerProvider)!.state;
        if (s.phase.name == 'breather') {
          await tester.tap(find.text('Concentrarte'));
          await settle();
          continue;
        }
        final uid = s.hand.firstWhere((c) {
          final p = engine.preview(s, c.uid);
          return p.playable && p.damage > 0;
        }).uid;
        combat.tapCard(uid);
        combat.tapCard(uid);
        await settle();
        await settle();
      }
      expect(container.read(combatControllerProvider)!.state.isOver, isTrue);
      await tester.tap(find.text('Continuar'));
      await settle();
    }

    await win();
    expect(container.read(runControllerProvider)!.phase, RunPhase.roomBreak);
    expect(find.byType(StayScreen), findsOneWidget);
    expect(find.text('Sala superada'), findsOneWidget);
    expect(find.text('Volver al mapa'), findsNothing);
    expect(tester.takeException(), isNull);

    await tester.tap(find.text('Afilar los puños'));
    await settle();
    expect(find.text('Sala 2/2'), findsWidgets);
    expect(container.read(combatControllerProvider)!.state.fistBonus,
        greaterThan(0));

    await win();
    final phase = container.read(runControllerProvider)!.phase;
    expect([RunPhase.reward, RunPhase.talisman], contains(phase));
    if (phase == RunPhase.reward) {
      expect(find.text('El cofre de la estancia'), findsOneWidget);
    }
    expect(tester.takeException(), isNull);
  });
}
