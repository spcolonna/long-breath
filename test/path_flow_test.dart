import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/altitude_bar.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/delivery/labels.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// El sendero en pantalla: puertas con su premio, la altitud que sube, la
/// sala con su altura en combate y, al ganar, el cofre y las puertas de
/// arriba.
void main() {
  testWidgets('puerta con premio → sala → cofre → puertas de arriba', (
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
    container.read(runControllerProvider.notifier).newRun(Difficulty.normal);
    var r = container.read(runControllerProvider)!;
    container
        .read(runControllerProvider.notifier)
        .resume(r.copyWith(phase: RunPhase.map));
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/map');
    await settle();

    expect(find.byType(AltitudeBar), findsOneWidget);
    expect(find.text('Sala 1 de 13'), findsOneWidget);
    expect(find.text('0 m'), findsWidgets);
    // Cada puerta de pelea muestra lo que hay del otro lado.
    r = container.read(runControllerProvider)!;
    final doors = container.read(runEngineProvider).available(r).map(r.node);
    final text = lookupAppLocalizations(const Locale('es'));
    for (final d in doors) {
      expect(d.reward, isNotNull);
      expect(find.text(text.lootKind(d.reward!)), findsWidgets);
    }

    // Se mira la puerta y se va: el discípulo trepa y entra a la sala.
    final door = doors.first;
    final label = container.read(textProvider).path(door.scene!, door.light!);
    await tester.tap(find.text(label).first);
    await settle();
    await tester.tap(find.text('Ir'));
    await settle();
    await settle();
    expect(find.text('Terminar turno'), findsOneWidget);
    // La cabecera del combate dice la altura del sendero.
    expect(find.textContaining('· 1/13'), findsOneWidget);

    // Gana la sala de un golpe (a 1 de Vida, todos los del grupo).
    final combat = container.read(combatControllerProvider.notifier);
    final engine = container.read(combatEngineProvider);
    for (var guard = 0; guard < 4; guard++) {
      final v = container.read(combatControllerProvider)!;
      if (v.state.isOver) break;
      if (v.state.phase.name == 'breather') {
        await tester.tap(find.text('Concentrarte'));
        await settle();
        continue;
      }
      combat.debugReplace(
        v.state.copyWith(enemy: v.state.enemy.copyWith(hp: 1)),
      );
      final s = container.read(combatControllerProvider)!.state;
      final uid = s.hand.firstWhere((c) {
        final p = engine.preview(s, c.uid);
        return p.playable && p.damage > 0;
      }).uid;
      combat.tapCard(uid);
      combat.tapCard(uid);
      await settle();
      await settle();
    }
    await tester.tap(find.text('Continuar'));
    await settle();
    final won = container.read(runControllerProvider)!;
    expect(won.phase, RunPhase.reward);
    expect(won.rewardKind, isNotNull);
    expect(tester.takeException(), isNull);
  });
}
