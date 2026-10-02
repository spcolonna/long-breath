import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
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
    // Antes de subir se elige la dificultad.
    expect(find.text('Shifu'), findsOneWidget);
    // Shifu está bloqueada: tocarla explica cómo se gana y no arranca nada.
    expect(find.text('Bloqueada'), findsOneWidget);
    await tester.tap(find.text('Shifu'));
    await settle();
    expect(
      find.text('Se desbloquea al ganar una subida en Difícil.'),
      findsOneWidget,
    );
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsNothing);
    await tester.tap(find.text('Normal'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
    final run = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(runControllerProvider)!;
    expect(run.difficulty, Difficulty.normal);

    await tester.tap(find.text('Murciélago de Jade'));
    await settle();
    expect(find.text('Terminar turno'), findsOneWidget);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text('Murciélago de Jade'), findsWidgets);
    // La mano sale de una run con semilla al azar: se busca la primera carta.
    final scope = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final first = scope.read(combatControllerProvider)!.state.hand.first;
    expect(
      find.text(scope.read(textProvider).card(first.cardId)),
      findsWidgets,
    );

    // Pausa → volver al menú: la subida queda guardada y se retoma del mapa.
    await tester.tap(find.byTooltip('Pausa'));
    await settle();
    await tester.tap(find.text('Volver al menú'));
    await settle();
    expect(find.text('Continuar run'), findsOneWidget);
    await tester.tap(find.text('Continuar run'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
    await tester.tap(find.text('Murciélago de Jade'));
    await settle();
    expect(find.text('Turno 1'), findsOneWidget);

    // Saltamos al santuario: ofrece 2 caminos y el elegido queda en la run.
    final context = tester.element(find.byType(CombatScreen));
    final container = ProviderScope.containerOf(context);
    final runs = container.read(runControllerProvider.notifier);
    runs.resume(
      container
          .read(runEngineProvider)
          .enter(
            container
                .read(runControllerProvider)!
                .copyWith(phase: RunPhase.map, currentNode: 'n2'),
            'ns',
          ),
    );
    GoRouter.of(context).go('/shrine');
    await settle();
    expect(find.text('Santuario de los animales'), findsOneWidget);
    final offered = container.read(runControllerProvider)!.pathOptions;
    final names = {
      Style.tiger: 'Tigre',
      Style.snake: 'Serpiente',
      Style.crane: 'Grulla',
    };
    for (final s in Style.values) {
      expect(
        find.text(names[s]!),
        offered.contains(s) ? findsOneWidget : findsNothing,
      );
    }
    expect(find.text('Tocá un camino para ver qué te da.'), findsOneWidget);
    await tester.tap(find.text(names[offered.first]!));
    await settle();
    expect(
      find.textContaining(
        offered.first == Style.tiger ? 'Robás 5 cartas' : 'retenés hasta',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('Tomar este camino'));
    await settle();
    expect(container.read(runControllerProvider)!.style, offered.first);
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);

    // Evento: la escena, lo que promete cada opción y lo que pasó.
    runs.resume(
      container
          .read(runControllerProvider)!
          .copyWith(phase: RunPhase.event, eventId: 'tea'),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/event');
    await settle();
    expect(find.text('El maestro de té'), findsOneWidget);
    expect(find.text('+4 Vida máxima'), findsOneWidget);
    expect(find.text('una carta nueva al azar'), findsOneWidget);
    await tester.tap(find.text('Tomar el té con calma'));
    await settle();
    expect(find.textContaining('El té te calienta'), findsOneWidget);
    expect(container.read(runControllerProvider)!.maxHp, 54);
    await tester.tap(find.text('Seguir subiendo'));
    await settle();
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);

    // Talismán del élite: se elige uno y después viene la recompensa.
    runs.resume(
      container.read(runControllerProvider)!.copyWith(
        phase: RunPhase.talisman,
        talismanOptions: ['vida', 'roca', 'grieta'],
      ),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/talisman');
    await settle();
    expect(find.text('Elegí un talismán'), findsOneWidget);
    expect(find.text('Sello de la Grieta'), findsOneWidget);
    expect(find.text('Raro'), findsOneWidget);
    await tester.tap(find.text('Hilo de Vida'));
    await settle();
    await tester.tap(find.text('Confirmar'));
    await settle();
    final after = container.read(runControllerProvider)!;
    expect(after.talismans, ['vida']);
    expect(after.phase, RunPhase.reward);

    // El combate siguiente arranca con los talismanes de la run.
    runs.resume(after.copyWith(phase: RunPhase.map, currentNode: 'n4'));
    runs.enter('n5');
    container.read(combatControllerProvider.notifier).start();
    expect(container.read(combatControllerProvider)!.state.talismans, ['vida']);
  });
}
