import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/widgets/enemy_sprite.dart';
import 'package:long_breath/domain/model/enemy_def.dart';
import 'package:long_breath/domain/model/enums.dart';

/// El reporte de la +5: en la oleada 2 de un grupo el enemigo salía más
/// grande y más arriba, con la cabeza bajo el globo. La caída del anterior
/// quedaba aplicada al que entraba (mismo estado por la GlobalKey).
void main() {
  EnemyDef foe(String id) => EnemyDef(
    id: id,
    rank: EnemyRank.common,
    hp: 10,
    structure: 5,
    phases: const [],
  );

  Widget sprite(GlobalKey key, EnemyDef def, {required bool dying}) =>
      MaterialApp(
        home: Center(
          child: EnemySprite(
            key: key,
            def: def,
            staggered: false,
            hitKey: 0,
            attackKey: 0,
            dying: dying,
            size: 150,
          ),
        ),
      );

  Offset offsetOf(WidgetTester tester) {
    final t = tester.widget<Transform>(
      find
          .descendant(
            of: find.byType(EnemySprite),
            matching: find.byType(Transform),
          )
          .first,
    );
    return Offset(
      t.transform.getTranslation().x,
      t.transform.getTranslation().y,
    );
  }

  testWidgets('el que entra en la oleada 2 no hereda la caída', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(sprite(key, foe('a'), dying: false));
    final fresh = offsetOf(tester);
    await tester.pumpWidget(sprite(key, foe('a'), dying: true));
    await tester.pump(const Duration(milliseconds: 1200));
    await tester.pumpWidget(sprite(key, foe('b'), dying: false));
    await tester.pump();
    expect(offsetOf(tester), fresh);
  });
}
