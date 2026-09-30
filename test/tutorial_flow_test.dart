import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('el entrenamiento guía hasta ganar y queda marcado', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> settle([int seconds = 2]) async {
      for (var i = 0; i < seconds; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    Future<void> next([String label = 'Siguiente']) async {
      await tester.tap(find.text(label));
      await settle();
    }

    // Juega la carta: un toque la selecciona y otro la juega.
    Future<void> play(String name) async {
      await tester.tap(find.text(name).last);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text(name).last);
      await settle(3);
    }

    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await settle();
    await tester.tap(find.text('Empezar entrenamiento'));
    await settle();

    expect(find.text('Muñeco de madera'), findsWidgets);
    expect(find.textContaining('Bienvenido al patio'), findsOneWidget);
    for (var i = 0; i < 5; i++) {
      await next();
    }
    expect(find.textContaining('Tocá Puño en arco'), findsOneWidget);

    // Mientras espera una jugada, lo que está fuera del foco no responde.
    await tester.tap(find.text('Terminar turno'), warnIfMissed: false);
    await settle();
    expect(find.text('Turno 1'), findsOneWidget);

    await play('Puño en arco');
    expect(find.textContaining('postura Arco'), findsOneWidget);
    await next();
    await play('Mostrar la palma');
    await play('Patada de latigazo');
    expect(find.textContaining('Pequeño Puño Rojo'), findsWidgets);
    await next();
    await tester.tap(find.text('Terminar turno'));
    await settle(4);
    expect(find.textContaining('¡Desvío! No recibiste daño'), findsOneWidget);
    await next();
    expect(find.textContaining('Paso en T te cambia'), findsOneWidget);
    await next();
    await next('¡Vamos!');

    await play('Puño en arco');
    await play('Patada de latigazo');
    // La guía espera a que termine la celebración de la victoria.
    await settle(2);
    expect(find.textContaining('¡Bien hecho!'), findsOneWidget);

    await tester.tap(find.text('Empezar la subida'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getBool('long_breath.tutorialDone'), isTrue);
  });
}
