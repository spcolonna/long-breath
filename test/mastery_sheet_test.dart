import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/mastery_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('la hoja de maestría entra en un teléfono angosto y nombra lo '
      'que abre cada nivel', (tester) async {
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'long_breath.mastery': ['tiger:70', 'crane:300'],
    });
    await tester.pumpWidget(
      ProviderScope(
        overrides: [cinematicsProvider.overrideWithValue(false)],
        child: const LongBreathApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    showMasterySheet(tester.element(find.byType(Scaffold).first));
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 300));
    }
    expect(find.text('Maestría de los caminos'), findsOneWidget);
    expect(find.textContaining('Nivel 2 de 5'), findsOneWidget);
    expect(find.text('Maestría completa'), findsOneWidget);
    expect(find.textContaining('Pudao nivel 3'), findsOneWidget);
    expect(find.textContaining('Despertar'), findsNWidgets(3));
    await tester.drag(
      find.byType(SingleChildScrollView).last,
      const Offset(0, -2000),
    );
    await tester.pump(const Duration(milliseconds: 500));
  });
}
