import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/screens/event_screen.dart';
import 'package:long_breath/delivery/widgets/npc_portrait.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('los eventos de los hilos muestran el retrato del personaje', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cinematicsProvider.overrideWithValue(false)],
        child: const LongBreathApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final data = container.read(dataProvider);
    expect(eventPortrait(data.event('shuang_3')), 'assets/art/npc/shuang.webp');
    expect(eventPortrait(data.event('wounded')), 'assets/art/npc/ming.webp');
    expect(
      eventPortrait(data.event('smith_delivery')),
      'assets/art/npc/tie.webp',
    );

    final runs = container.read(runControllerProvider.notifier);
    runs.newRun(Difficulty.normal);
    final r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.event,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        eventId: 'shuang_1',
      ),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/event');
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final portrait = tester.widget<NpcPortrait>(find.byType(NpcPortrait));
    expect(portrait.asset, 'assets/art/npc/shuang.webp');
  });
}
