import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/hero_sprite.dart';
import 'package:long_breath/delivery/widgets/weapon_art.dart';
import 'package:long_breath/domain/model/enums.dart';

Widget _hero(
  String weapon,
  int level, {
  bool calm = false,
  Set<String> art = const {},
}) => ProviderScope(
  key: ValueKey('$weapon $art'),
  overrides: [weaponArtProvider.overrideWith((ref) async => art)],
  child: MaterialApp(
    home: MediaQuery(
      data: MediaQueryData(disableAnimations: calm),
      child: Center(
        child: HeroSprite(
          style: Style.snake,
          height: 300,
          weapon: weapon,
          weaponLevel: level,
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('el héroe lleva el arma dibujada por código, en cada nivel', (
    tester,
  ) async {
    for (final id in weaponShapes.keys) {
      for (final level in [1, 2, 3]) {
        await tester.pumpWidget(_hero(id, level));
        await tester.pump(const Duration(milliseconds: 100));
        expect(find.byType(WeaponArt), findsOneWidget, reason: '$id $level');
        expect(
          find.byWidgetPredicate(
            (w) => w is CustomPaint && w.painter is WeaponPainter,
          ),
          findsOneWidget,
          reason: 'sin imagen, se dibuja',
        );
      }
    }
  });

  testWidgets('con imagen, el arma usa su webp', (tester) async {
    for (final id in weaponShapes.keys) {
      await tester.pumpWidget(_hero(id, 2, art: {id}));
      await tester.pump(const Duration(milliseconds: 100));
      expect(
        find.byWidgetPredicate(
          (w) =>
              w is Image &&
              w.image is AssetImage &&
              (w.image as AssetImage).assetName ==
                  'assets/art/weapons/$id.webp',
        ),
        findsOneWidget,
        reason: id,
      );
    }
  });

  testWidgets('con movimiento reducido el arma queda quieta', (tester) async {
    await tester.pumpWidget(_hero('pudao', 2, calm: true));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(WeaponArt), findsOneWidget);
    expect(tester.hasRunningAnimations, isFalse);
  });
}
