import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/widgets/enemy_sprite.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('dos a la vez: se apunta tocando y actúan los dos', (
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
                    together: true,
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

    expect(find.text('Salamandra de Brasa'), findsOneWidget);
    expect(find.text('Murciélago de Jade'), findsOneWidget);
    expect(find.byType(EnemySprite), findsNWidgets(2));
    expect(view().state.target, 0);

    // Tocar al segundo lo apunta.
    await tester.tap(find.byType(EnemySprite).at(1));
    await settle();
    expect(view().state.target, 1);

    // Al terminar el turno actúan los dos.
    final hp = view().state.player.hp;
    combat.endTurnPressed();
    if (view().retaining) combat.confirmRetain();
    await settle();
    await settle();
    expect(view().state.enemies.every((e) => e.patternIndex == 1), isTrue);
    expect(view().state.player.hp, lessThanOrEqualTo(hp));
    expect(tester.takeException(), isNull);
  });
}
