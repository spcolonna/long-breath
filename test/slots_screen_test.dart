import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('borrar una partida con progreso pide dos confirmaciones', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({
      'long_breath.disciple': 4,
      'long_breath.lotus': 16,
      'long_breath.lessonsDone': ['strike'],
    });
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    Future<void> settle() async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    await tester.pumpWidget(
      ProviderScope(
        overrides: [cinematicsProvider.overrideWithValue(false)],
        child: const LongBreathApp(),
      ),
    );
    await settle();
    await tester.tap(find.text('Jugar'));
    await settle();
    // La partida de antes aparece como la 1; las otras dos, libres.
    expect(find.text('Partida 1'), findsOneWidget);
    expect(find.text('Discípulo nº 4'), findsOneWidget);
    expect(find.text('Nueva partida'), findsNWidgets(2));

    await tester.tap(find.byTooltip('Opciones de la partida'));
    await settle();
    await tester.tap(find.text('Borrar partida'));
    await settle();
    expect(find.text('¿Borrar la Partida 1?'), findsOneWidget);
    // Cancelar no borra nada.
    await tester.tap(find.text('Cancelar'));
    await settle();
    expect(find.text('Partida 1'), findsOneWidget);

    await tester.tap(find.byTooltip('Opciones de la partida'));
    await settle();
    await tester.tap(find.text('Borrar partida'));
    await settle();
    await tester.tap(find.text('Borrar'));
    await settle();
    expect(find.text('¿Seguro?'), findsOneWidget);
    await tester.tap(find.text('Sí, borrar para siempre'));
    await settle();
    expect(find.text('Nueva partida'), findsNWidgets(3));
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getInt('long_breath.lotus'), isNull);
    expect(prefs.getStringList('long_breath.lessonsDone'), ['strike']);
  });
}
