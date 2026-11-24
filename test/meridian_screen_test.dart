import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('el árbol entra en un teléfono angosto y la elección cierra '
      'el otro punto', (tester) async {
    // 375 de ancho: el teléfono más angosto que soporta el juego.
    tester.view.physicalSize = const Size(1125, 2436);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    SharedPreferences.setMockInitialValues({
      'long_breath.breath': 5000,
      'long_breath.lotus': 1000,
      'long_breath.meridianTree': 2,
      'long_breath.meridians': ['body_1', 'body_2', 'body_3', 'body_4'],
    });
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
    Future<void> settle() async {
      await tester.pump();
      for (var i = 0; i < 4; i++) {
        await tester.pump(const Duration(milliseconds: 500));
      }
    }

    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/meridians');
    await settle();
    // La elección de la fila 5 del Cuerpo: tomar la sangre (血海).
    await tester.ensureVisible(find.text('血海'));
    await settle();
    await tester.tap(find.text('血海'));
    await settle();
    expect(find.textContaining('Elegí uno de los dos'), findsOneWidget);
    await tester.tap(find.textContaining('Abrir punto'));
    await settle();
    var m = await container.read(meridianProvider.future);
    expect(m.owned, contains('body_5b'));
    // El otro queda cerrado para siempre.
    await tester.tap(find.text('肾俞'));
    await settle();
    expect(find.text('Elegiste el otro punto'), findsOneWidget);
    await tester.tapAt(const Offset(10, 10));
    await settle();
    // Hasta abajo del árbol, sin desbordes.
    await tester.ensureVisible(find.text('太阳'));
    await settle();
    m = await container.read(meridianProvider.future);
    expect(m.owned, hasLength(5));
  });
}
