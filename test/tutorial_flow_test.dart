import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
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

  // Un toque selecciona la carta y otro la juega.
  Future<void> select(String name) async {
    await tester.tap(find.text(name).last);
    await tester.pump(const Duration(milliseconds: 400));
  }

  Future<void> play(String name) async {
    await select(name);
    await tester.tap(find.text(name).last);
    await settle(3);
  }

  Future<void> open() async {
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
    await settle();
    await tester.tap(find.text('Aprender a jugar'));
    await settle();
  }

  testWidgets('la lección 1 guía paso a paso hasta ganar y habilita la 2', (t) async {
    tester = t;
    await open();
    // La 2 está bloqueada hasta completar la 1.
    expect(find.text('Completá la lección anterior'), findsNWidgets(5));
    await tester.tap(find.text('Tu primer golpe'));
    await settle();
    expect(find.textContaining('Bienvenido. Esto es un combate'), findsOneWidget);
    for (var i = 0; i < 6; i++) {
      await next();
    }
    expect(find.textContaining('Tocá Puñetazo firme UNA'), findsOneWidget);

    // Solo se puede tocar la zona resaltada.
    await tester.tap(find.text('Terminar turno'));
    await settle();
    expect(find.textContaining('Tocá Puñetazo firme UNA'), findsOneWidget);

    await select('Puñetazo firme');
    expect(find.textContaining('Esta es la vista previa'), findsOneWidget);
    await tester.tap(find.text('Puñetazo firme').last);
    await settle(3);
    expect(find.textContaining('Le sacaste 7 de Vida'), findsOneWidget);
    await next();
    await play('Empujón de palma');
    expect(find.textContaining('jugá el otro Puñetazo'), findsOneWidget);
    await play('Puñetazo firme');
    expect(find.textContaining('Te quedaste sin Aliento'), findsOneWidget);
    await next();
    expect(find.textContaining('mirá este globo'), findsOneWidget);
    await next();
    await tester.tap(find.text('Terminar turno'));
    await settle(4);
    expect(find.textContaining('Te pegó'), findsOneWidget);
    await next();
    expect(find.textContaining('Empezó tu turno 2'), findsOneWidget);
    await next();
    await next('¡Vamos!');

    await play('Puñetazo firme');
    await play('Puñetazo firme');
    await settle(3);
    expect(find.text('Siguiente lección'), findsOneWidget);
    expect(find.textContaining('Aprendiste a leer una carta'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('long_breath.lessonsDone'), contains('strike'));

    await tester.tap(find.text('Volver a las lecciones'));
    await settle();
    expect(find.text('Leer el globo del rival, la Guardia, las alturas y el desvío.'),
        findsOneWidget);
  });
}
