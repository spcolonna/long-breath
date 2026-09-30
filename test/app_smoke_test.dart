import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/screens/combat_screen.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('inicio → mapa → combate → santuario', (tester) async {
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
    // Menú principal: aprender (marcado la primera vez) o subir.
    expect(find.text('Aprender a jugar'), findsOneWidget);
    expect(find.text('Empezá acá'), findsOneWidget);
    // Se empieza como novicio: el camino no se elige en el inicio.
    expect(find.text('Tigre'), findsNothing);

    await tester.tap(find.text('La subida'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);

    await tester.tap(find.text('Eco de Murciélago'));
    await settle();
    expect(find.text('Terminar turno'), findsOneWidget);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text('Eco de Murciélago'), findsWidgets);
    expect(find.text('Puñetazo a fondo'), findsWidgets);

    // Pausa → volver al menú: la subida queda guardada y se retoma del mapa.
    await tester.tap(find.byTooltip('Pausa'));
    await settle();
    await tester.tap(find.text('Volver al menú'));
    await settle();
    expect(find.text('Continuar run'), findsOneWidget);
    await tester.tap(find.text('Continuar run'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
    await tester.tap(find.text('Eco de Murciélago'));
    await settle();
    expect(find.text('Turno 1'), findsOneWidget);

    // Saltamos al santuario: ofrece 2 caminos y el elegido queda en la run.
    final context = tester.element(find.byType(CombatScreen));
    final container = ProviderScope.containerOf(context);
    final runs = container.read(runControllerProvider.notifier);
    runs.resume(container.read(runEngineProvider).enter(
        container.read(runControllerProvider)!
            .copyWith(phase: RunPhase.map, currentNode: 'n2'),
        'ns'));
    GoRouter.of(context).go('/shrine');
    await settle();
    expect(find.text('Santuario de los animales'), findsOneWidget);
    final offered = container.read(runControllerProvider)!.pathOptions;
    final names = {Style.tiger: 'Tigre', Style.snake: 'Serpiente', Style.crane: 'Grulla'};
    for (final s in Style.values) {
      expect(find.text(names[s]!), offered.contains(s) ? findsOneWidget : findsNothing);
    }
    await tester.tap(find.text(names[offered.first]!));
    await settle();
    await tester.tap(find.text('Tomar este camino'));
    await settle();
    expect(container.read(runControllerProvider)!.style, offered.first);
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
  });
}
