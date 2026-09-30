import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Recorre las lecciones 2 a 6 como las jugaría alguien que sigue al maestro.
void main() {
  testWidgets('las lecciones 2 a 6 se pueden seguir de punta a punta', (tester) async {
    SharedPreferences.setMockInitialValues({
      'long_breath.lessonsDone': ['strike', 'defend', 'stances', 'structure', 'forms'],
    });
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    Future<void> settle([int seconds = 2]) async {
      for (var i = 0; i < seconds; i++) {
        await tester.pump(const Duration(seconds: 1));
      }
    }

    Future<void> tap(String text) async {
      await tester.tap(find.text(text).last);
      await settle();
    }

    Future<void> select(String name) async {
      await tester.tap(find.text(name).last);
      await tester.pump(const Duration(milliseconds: 400));
    }

    Future<void> play(String name) async {
      await select(name);
      await tester.tap(find.text(name).last);
      await settle(3);
    }

    Future<void> endTurn() async {
      await tester.tap(find.text('Terminar turno'));
      await settle(4);
    }

    void sees(String text) => expect(find.textContaining(text), findsOneWidget, reason: text);

    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await settle();
    await tap('Aprender a jugar');

    // 2. El rival avisa.
    await tap('El rival avisa');
    sees('leer el globo del rival');
    await tap('Siguiente');
    sees('Cada defensa protege una ALTURA');
    await tap('Siguiente');
    await play('Bloqueo alto');
    sees('Esta es tu Guardia: 9');
    await tap('Siguiente');
    await play('Puñetazo firme');
    await endTurn();
    sees('¡Desvío!');
    await tap('Siguiente');
    sees('tenés 4 de Aliento');
    await tap('Siguiente');
    await tap('Siguiente');
    await play('Bloqueo bajo');
    await endTurn();
    sees('Altura equivocada');
    await tap('Siguiente');
    await tap('Siguiente');
    await tap('¡Vamos!');
    await play('Bloqueo bajo');
    await play('Puñetazo firme');
    await play('Puñetazo firme');
    await settle(3);
    sees('Aprendiste a leer al rival');
    await tap('Siguiente lección');

    // 3. Posturas.
    sees('tres posturas');
    await tap('Siguiente');
    await select('Puñetazo a fondo');
    sees('la vista previa dice 9');
    await tester.tap(find.text('Puñetazo a fondo').last);
    await settle(3);
    sees('Ahora estás en Arco');
    await tap('Siguiente');
    await tap('Paso en T');
    await tap('Vacía');
    await settle();
    sees('Patada látigo ahora cuesta 0');
    await play('Patada látigo');
    await tap('Siguiente');
    await tap('¡Vamos!');
    await play('Puñetazo firme');
    await endTurn();
    await play('Puñetazo a fondo');
    await settle(3);
    sees('Aprendiste a usar las posturas');
    await tap('Siguiente lección');

    // 4. Estructura.
    sees('poca Estructura');
    await tap('Siguiente');
    await play('Empujón de palma');
    await play('Empujón de palma');
    sees('¡Desequilibrado!');
    await tap('Siguiente');
    await play('Puñetazo firme');
    await tap('Siguiente');
    await tap('Siguiente');
    await endTurn();
    sees('Perdió su acción');
    await tap('Siguiente');
    await tap('¡Vamos!');
    await play('Puñetazo firme');
    await settle(3);
    sees('Aprendiste a desequilibrar');
    await tap('Siguiente lección');

    // 5. Formas.
    sees('secuencia fija de cartas');
    await tap('Siguiente');
    await play('Puñetazo a fondo');
    await play('Patada látigo');
    sees('Dos pasos marcados');
    await tap('Siguiente');
    await select('Empujón de palma');
    sees('triángulo de aviso');
    await tap('Siguiente');
    await endTurn();
    await play('Bloqueo y contragolpe');
    await tap('Respirar');
    await settle();
    await play('Paso atrás');
    await settle();
    sees('¡Forma completa!');

    // 6. La subida: diapositivas y a la montaña.
    await tester.tap(find.byTooltip('Pausa'));
    await settle();
    await tap('Salir a las lecciones');
    await tester.scrollUntilVisible(find.text('La subida'), 200);
    await tap('La subida');
    sees('camino de combates');
    for (var i = 0; i < 5; i++) {
      await tap('Siguiente');
    }
    sees('Si perdés toda la Vida');
    await tap('Empezar la subida');
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('long_breath.lessonsDone'), contains('climb'));
  });
}
