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

    // Héroe y enemigo respiran en bucle: no se puede esperar a que se asiente.
    Future<void> settle() async {
      await tester.pump(const Duration(seconds: 1));
      await tester.pump(const Duration(seconds: 1));
    }

    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await settle();
    expect(find.text('Nueva run'), findsOneWidget);

    expect(find.text('Serpiente'), findsOneWidget);

    await tester.tap(find.text('Tigre'));
    await settle();
    expect(find.text('Golpea primero, golpea fuerte.'), findsOneWidget);

    await tester.tap(find.text('Nueva run'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);

    await tester.tap(find.text('Eco de Murciélago'));
    await settle();
    expect(find.text('Terminar turno'), findsOneWidget);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text('Eco de Murciélago'), findsOneWidget);
    expect(find.text('Puño en arco'), findsWidgets);
  });
}
