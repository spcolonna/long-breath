import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> boot(WidgetTester tester) async {
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
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }


  testWidgets('la escuela restaura un edificio con el jade guardado',
      (tester) async {
    SharedPreferences.setMockInitialValues({'long_breath.schoolJade': 120});
    final container = await boot(tester);
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/monastery');
    await settle(tester);
    expect(find.text('La escuela'), findsOneWidget);
    expect(find.text('0 de 15 niveles restaurados'), findsOneWidget);
    await tester.tap(find.textContaining('Enfermería').first);
    await settle(tester);
    await tester.tap(find.textContaining('Restaurar ·'));
    await settle(tester);
    final s = await container.read(schoolProvider.future);
    expect(s.levels, {'infirmary': 1});
    final cost = container
        .read(dataProvider)
        .balance
        .school
        .building('infirmary')!
        .levels
        .first
        .cost;
    expect(s.jade, 120 - cost);
    expect(find.text('1 de 15 niveles restaurados'), findsOneWidget);
    final meta = await container.read(metaBonusProvider.future);
    expect(meta.fountainHeal, greaterThan(0));
  });

}
