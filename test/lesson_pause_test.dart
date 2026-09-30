import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late WidgetTester tester;

  Future<void> settle([int seconds = 2]) async {
    for (var i = 0; i < seconds; i++) {
      await tester.pump(const Duration(seconds: 1));
    }
  }

  Future<void> next([String label = 'Siguiente']) async {
    await tester.tap(find.text(label));
    await settle();
  }

  Future<void> open() async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await settle();
    await tester.tap(find.text('Aprender a jugar'));
    await settle();
  }

  testWidgets('la pausa de una lección reinicia o sale a la lista', (t) async {
    tester = t;
    await open();
    await tester.tap(find.text('Tu primer golpe'));
    await settle();
    await next();
    await next();
    expect(find.textContaining('Este es el rival'), findsOneWidget);

    await tester.tap(find.byTooltip('Pausa'));
    await settle();
    await tester.tap(find.text('Reiniciar lección'));
    await settle();
    expect(find.textContaining('Bienvenido. Esto es un combate'), findsOneWidget);

    await tester.tap(find.byTooltip('Pausa'));
    await settle();
    await tester.tap(find.text('Salir a las lecciones'));
    await settle();
    expect(find.text('Aprender a jugar'), findsOneWidget);
    expect(find.text('Tu primer golpe'), findsOneWidget);
  });
}
