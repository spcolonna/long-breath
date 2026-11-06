import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/legacy.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Legado, talismán con costo, fuente seca, eventos con requisito o en dos
/// partes, el élite que es desvío y la vitrina: lo que se ve y se toca.
void main() {
  Future<ProviderContainer> boot(WidgetTester tester) async {
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
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 5; i++) {
      await tester.pump(const Duration(milliseconds: 400));
    }
  }

  void go(WidgetTester tester, String path) =>
      GoRouter.of(tester.element(find.byType(Scaffold).first)).go(path);

  testWidgets('legado, talismán con costo y fuente seca', (tester) async {
    final container = await boot(tester);
    final runs = container.read(runControllerProvider.notifier);

    // El legado elegido se anuncia y se suma.
    runs.newRun(Difficulty.normal);
    var r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(phase: RunPhase.legacy, legacy: const Legacy(n: 3, maxHp: 3)),
    );
    go(tester, '/legacy');
    await settle(tester);
    expect(find.text('+3 de Vida máxima'), findsOneWidget);
    await tester.tap(find.text('+3 de Vida máxima'));
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Heredado: +3 de Vida máxima'), findsOneWidget);
    await settle(tester);
    expect(container.read(runControllerProvider)!.maxHp, r.maxHp + 3);

    // El costo de un talismán de jefe va en su propia línea.
    runs.newRun(Difficulty.normal);
    r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.talisman,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        talismanOptions: ['tambor', 'vida'],
      ),
    );
    go(tester, '/talisman');
    await settle(tester);
    expect(find.text('Tambor de Bronce'), findsOneWidget);
    expect(find.text('pero la fuente cura 15 menos.'), findsOneWidget);

    // La fuente que no cura nada no se puede tocar.
    runs.newRun(Difficulty.shifu);
    r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.fountain,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        talismans: ['tambor'],
        hp: 10,
      ),
    );
    go(tester, '/fountain');
    await settle(tester);
    expect(find.text('La fuente está seca: no cura nada.'), findsOneWidget);
    await tester.tap(find.textContaining('Curar'));
    await settle(tester);
    expect(container.read(runControllerProvider)!.hp, 10);

    // Con la Pluma, el puente se cruza planeando: la opción va primero.
    runs.newRun(Difficulty.normal);
    r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.event,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        eventId: 'bridge',
        talismans: ['pluma'],
      ),
    );
    go(tester, '/event');
    await settle(tester);
    expect(find.text('Planear con la Pluma'), findsOneWidget);
    expect(find.textContaining('Con Pluma de la Grulla'), findsOneWidget);

    // Ayudar al herido deja algo para más arriba (la pantalla de evento se
    // vuelve a armar al pasar por el mapa).
    go(tester, '/map');
    await settle(tester);
    runs.newRun(Difficulty.normal);
    r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.event,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        eventId: 'wounded',
      ),
    );
    go(tester, '/event');
    await settle(tester);
    await tester.tap(find.text('Cargarlo hasta el refugio'));
    await settle(tester);
    expect(find.text('Esto sigue más arriba'), findsOneWidget);
    expect(container.read(runControllerProvider)!.marks, {'wounded': 0});

    // Un élite que comparte piso se marca como desvío en el mapa.
    runs.newRun(Difficulty.normal);
    r = container.read(runControllerProvider)!;
    final data = container.read(dataProvider);
    final elite = data.balance.stages[0].floors[8].enemies.first;
    final first = r.map.firstWhere((n) => n.id == r.starts.first);
    runs.resume(
      r.copyWith(
        phase: RunPhase.map,
        map: [
          for (final n in r.map)
            n.id == first.id
                ? MapNodeDef(
                    id: n.id,
                    type: NodeType.combat,
                    enemy: elite,
                    next: n.next,
                  )
                : n,
        ],
      ),
    );
    go(tester, '/map');
    await settle(tester);
    expect(r.starts.length, greaterThan(1));
    expect(find.text('Desvío'), findsWidgets);

    // Arriba, la vitrina vende un raro aparte, caro.
    runs.newRun(Difficulty.normal);
    r = container.read(runControllerProvider)!;
    final engine = container.read(runEngineProvider);
    runs.resume(
      engine.enter(
        r.copyWith(
          stage: 2,
          jade: 300,
          map: [const MapNodeDef(id: 'm', type: NodeType.merchant, next: [])],
        ),
        'm',
      ),
    );
    go(tester, '/merchant');
    await settle(tester);
    final shop = container.read(runControllerProvider)!;
    expect(find.text('VITRINA'), findsOneWidget);
    expect(find.text('Selecto'), findsOneWidget);
    final rare = find.text(container.read(textProvider).talisman(shop.shopRare!));
    await tester.ensureVisible(rare);
    await tester.pump();
    await tester.tap(rare);
    await tester.pump();
    await tester.tap(find.text('Confirmar'));
    await settle(tester);
    final after = container.read(runControllerProvider)!;
    expect(after.talismans, contains(shop.shopRare));
    expect(after.jade, 300 - engine.merchantOf(shop).rare);
  });
}
