import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cadena de postura: la carta que sale de tu postura se marca en la mano y,
/// al jugarla, se anuncia.
void main() {
  testWidgets('la carta que encadena se marca y se anuncia', (tester) async {
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
        deck: [
          for (var i = 0; i < 10; i++)
            CombatCard(uid: i, cardId: 'ma_zhuan_gong'),
        ],
        map: [
          for (final n in r.map)
            n.id == start.id
                ? MapNodeDef(
                    id: n.id,
                    type: NodeType.combat,
                    next: n.next,
                    enemy: 'salamander',
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
    final view = container.read(combatControllerProvider)!;
    expect(view.state.player.stance, Stance.mabu);

    // Desde Caballo, todas encadenan.
    expect(find.text('Encadena'), findsWidgets);
    expect(find.text('Caballo → Arco'), findsWidgets);

    final uid = view.state.hand.first.uid;
    combat.tapCard(uid);
    await tester.pump();
    combat.tapCard(uid);
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.text('¡Cadena!'), findsOneWidget);
    await settle();

    // Ya en Arco, no encadenan más.
    expect(
      container.read(combatControllerProvider)!.state.player.stance,
      Stance.gongbu,
    );
    expect(find.text('Encadena'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
