import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/controllers/combat_controller.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/widgets/enemy_sprite.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Con dos a la vez, globos largos y tres formas aprendidas, los enemigos no
/// se achican hasta perderse (el reporte de la Dama del Viento).
void main() {
  testWidgets('dos élites a la vez siguen viéndose grandes', (tester) async {
    SharedPreferences.setMockInitialValues({});
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
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final runs = container.read(runControllerProvider.notifier)
      ..newRun(Difficulty.normal);
    final r = container.read(runControllerProvider)!;
    final data = container.read(dataProvider);
    final start = r.node(r.starts.first);
    runs.resume(
      r.copyWith(
        knownForms: [for (final f in data.forms.take(3)) f.id],
        map: [
          for (final n in r.map)
            n.id == start.id
                ? MapNodeDef(
                    id: n.id,
                    type: n.type,
                    next: n.next,
                    enemy: 'wind_lady',
                    waves: const ['frost_bat'],
                    together: true,
                    scene: n.scene,
                    light: n.light,
                  )
                : n,
        ],
      ),
    );
    runs.enter(start.id);
    container.read(combatControllerProvider.notifier).start();
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/combat');
    await settle();

    final sprites = find.byType(EnemySprite);
    expect(sprites, findsNWidgets(2));
    for (var i = 0; i < 2; i++) {
      final size = tester.getSize(sprites.at(i));
      expect(size.height, greaterThanOrEqualTo(100), reason: 'enemigo $i: $size');
    }
  });
}
