import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('inicio → mapa → combate', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await tester.pumpAndSettle();
    expect(find.text('Nueva run'), findsOneWidget);

    await tester.tap(find.text('Nueva run'));
    await tester.pumpAndSettle();
    expect(find.text('La cueva del dragón'), findsOneWidget);

    await tester.tap(find.text('Eco de Murciélago'));
    await tester.pumpAndSettle();
    expect(find.text('Terminar turno'), findsOneWidget);
    expect(find.text('Turno 1'), findsOneWidget);
  });
}
