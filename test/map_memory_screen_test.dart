import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:long_breath/domain/run/memorial.dart';
import 'package:long_breath/delivery/widgets/memorial_tablet.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// La tablilla del caído y las marcas de la memoria se ven en el mapa,
/// también en un teléfono chico.
void main() {
  {
    testWidgets('tablilla, revancha y atajo de Shuang en el mapa', (
      tester,
    ) async {
      SharedPreferences.setMockInitialValues({});
      tester.view.physicalSize = const Size(1320, 2868);
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
      // Los datos del juego se cargan del bundle: esperar a que estén.
      for (var i = 0; i < 20 && find.byType(Scaffold).evaluate().isEmpty; i++) {
        await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 50)),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }
      final container = ProviderScope.containerOf(
        tester.element(find.byType(Scaffold).first),
      );
      final runs = container.read(runControllerProvider.notifier)
        ..newRun(Difficulty.normal);
      final r = container.read(runControllerProvider)!;
      final start = r.node(r.starts.first);
      runs.resume(
        r.copyWith(
          memorial: const Memorial(n: 3, stage: 0, depth: 0, enemy: 'golem'),
          map: [
            for (final n in r.map)
              n.id == start.id
                  ? MapNodeDef(
                      id: n.id,
                      type: NodeType.combat,
                      next: n.next,
                      enemy: 'golem',
                      scene: n.scene,
                      light: n.light,
                      mark: NodeMark.revenge,
                    )
                  : n.depth == 0
                  ? MapNodeDef(
                      id: n.id,
                      type: NodeType.combat,
                      next: n.next,
                      enemy: 'bat',
                      scene: n.scene,
                      light: n.light,
                      mark: NodeMark.shuang,
                    )
                  : n,
          ],
        ),
      );
      final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
      router.go('/map');
      await settle();
      expect(find.byType(MemorialTablet), findsOneWidget);
      expect(find.textContaining('Aquí cayó el discípulo 3'), findsOneWidget);
      expect(find.text('仇'), findsOneWidget);
      expect(tester.takeException(), isNull);

      // En un teléfono chico (iPhone SE) también entra.
      tester.view.physicalSize = const Size(750, 1334);
      tester.view.devicePixelRatio = 2;
      await settle();
      expect(find.byType(MemorialTablet), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
