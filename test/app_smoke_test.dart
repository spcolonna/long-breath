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
import 'package:long_breath/domain/model/game_balance.dart';
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
    // El mapa se genera con la semilla: se entra por el primer nodo. El
    // camino tiene nombre de lugar; el enemigo recién se ve al llegar.
    final text = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    ).read(textProvider);
    final firstNode = run.node(run.starts.first);
    final firstEnemy = text.enemy(firstNode.enemy!);
    final pathName = text.path(firstNode.scene!, firstNode.light!);
    expect(find.text(firstEnemy), findsNothing);

    await tester.tap(find.text(pathName).first);
    await settle();
    expect(find.text('Terminar turno'), findsOneWidget);
    expect(find.text('Turno 1'), findsOneWidget);
    expect(find.text(firstEnemy), findsWidgets);
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
    await tester.tap(find.text(pathName).first);
    await settle();
    expect(find.text('Turno 1'), findsOneWidget);

    // Saltamos al santuario: ofrece 2 caminos y el elegido queda en la run.
    final context = tester.element(find.byType(CombatScreen));
    final container = ProviderScope.containerOf(context);
    final runs = container.read(runControllerProvider.notifier);
    final current = container.read(runControllerProvider)!;
    final shrine = current.map.singleWhere((n) => n.type == NodeType.shrine);
    final before = current.map.firstWhere((n) => n.next.contains(shrine.id));
    runs.resume(
      container
          .read(runEngineProvider)
          .enter(
            current.copyWith(phase: RunPhase.map, currentNode: before.id),
            shrine.id,
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
        switch (offered.first) {
          Style.tiger => 'Golpe primero',
          Style.snake => 'Cadena:',
          Style.crane => 'Paciencia:',
        },
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
    final fountain = after.map.singleWhere((n) => n.type == NodeType.fountain);
    runs.resume(after.copyWith(phase: RunPhase.map, currentNode: fountain.id));
    runs.enter(fountain.next.single);
    container.read(combatControllerProvider.notifier).start();
    expect(container.read(combatControllerProvider)!.state.talismans, ['vida']);

    // Mercader: precios, compra con jade y sello de comprado.
    final engine = container.read(runEngineProvider);
    const merchant = MapNodeDef(id: 'm', type: NodeType.merchant, next: []);
    runs.resume(
      engine.enter(
        after.copyWith(
          phase: RunPhase.map,
          currentNode: fountain.id,
          jade: 100,
        ).copyWith(
          map: [
            for (final n in after.map)
              n.id == fountain.id
                  ? MapNodeDef(id: n.id, type: n.type, next: ['m'])
                  : n,
            merchant,
          ],
        ),
        'm',
      ),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/merchant');
    await settle();
    expect(find.text('Mercader de pergaminos'), findsOneWidget);
    expect(find.text('Quitar 1 carta del mazo'), findsOneWidget);
    final shop = container.read(runControllerProvider)!;
    final ware = container.read(textProvider).talisman(shop.shopTalisman!);
    await tester.tap(find.text(ware));
    await settle();
    await tester.tap(find.text('Confirmar'));
    await settle();
    expect(find.text('¡Comprado!'), findsOneWidget);
    expect(
      container.read(runControllerProvider)!.jade,
      100 - container.read(dataProvider).balance.merchant.talisman,
    );
    await tester.tap(find.text('Seguir subiendo'));
    await settle();
    expect(container.read(runControllerProvider)!.phase, RunPhase.map);

    // Maestro errante: una forma o mejorar una carta.
    const master = MapNodeDef(id: 'w', type: NodeType.master, next: []);
    runs.resume(
      engine.enter(
        container.read(runControllerProvider)!.copyWith(
          currentNode: 'm',
          map: [
            for (final n in after.map)
              if (n.id != 'm') n,
            const MapNodeDef(id: 'm', type: NodeType.merchant, next: ['w']),
            master,
          ],
        ),
        'w',
      ),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/master');
    await settle();
    expect(find.text('Maestro errante'), findsOneWidget);
    final taught = container.read(runControllerProvider)!.masterForms.first;
    await tester.tap(find.text(container.read(textProvider).form(taught)));
    await settle();
    await tester.tap(find.text('Confirmar'));
    await settle();
    await settle();
    expect(container.read(runControllerProvider)!.knownForms, contains(taught));
    expect(find.text('Montaña de las Mil Nubes · 千云山'), findsOneWidget);
  });
}
