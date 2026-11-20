import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Al superar una etapa, si la siguiente trae (o sube) la furia de la
/// montaña, la pantalla lo avisa antes del primer combate.
void main() {
  testWidgets('Bosque → Monasterio presenta la furia; → Cumbre avisa que sube',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1179, 2556);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> settle() async {
      for (var i = 0; i < 4; i++) {
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
    final ctrl = container.read(runControllerProvider.notifier);
    ctrl.newRun(Difficulty.normal);
    final base = container.read(runControllerProvider)!;

    Future<String?> warningAt(int stage) async {
      ctrl.resume(base.copyWith(stage: stage));
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/map');
      await settle();
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/stage');
      await settle();
      final w = find.byKey(const ValueKey('fury_warning'));
      if (w.evaluate().isEmpty) return null;
      return find
          .descendant(of: w, matching: find.byType(Text))
          .evaluate()
          .map((e) => (e.widget as Text).data)
          .join(' ');
    }

    final monastery = await warningAt(0);
    expect(monastery, contains('+3 por acción'));
    expect(monastery, contains('Desde acá'));

    final summit = await warningAt(1);
    expect(summit, contains('+4 por acción'));
    expect(summit, contains('en vez de 3'));
  });
}
