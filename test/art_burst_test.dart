import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/widgets/juice.dart';

Widget _burst(int trigger) => MaterialApp(
  home: Center(
    child: ArtBurst(
      trigger: trigger,
      asset: 'assets/art/vfx/hit_ink.webp',
      size: 200,
    ),
  ),
);

double _opacity(WidgetTester tester) => tester
    .widget<Opacity>(
      find.ancestor(of: find.byType(Image), matching: find.byType(Opacity)),
    )
    .opacity;

void main() {
  testWidgets('ArtBurst: invisible hasta el golpe, se ve y se desvanece', (
    tester,
  ) async {
    await tester.pumpWidget(_burst(0));
    expect(find.byType(Image), findsOneWidget);
    expect(_opacity(tester), 0);

    await tester.pumpWidget(_burst(1));
    await tester.pump(const Duration(milliseconds: 150));
    expect(_opacity(tester), greaterThan(0.9));

    await tester.pump(const Duration(milliseconds: 600));
    expect(_opacity(tester), 0);
  });

  testWidgets('FinisherSeal: el sello cae con el remate y se va', (
    tester,
  ) async {
    await tester.pumpWidget(_seal(0));
    expect(find.text('破'), findsNothing);
    await tester.pumpWidget(_seal(1));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('破'), findsOneWidget);
    await tester.pump(FinisherSeal.duration);
    expect(find.text('破'), findsNothing);
  });

  testWidgets('FinisherSeal: con movimiento reducido solo aparece el sello', (
    tester,
  ) async {
    await tester.pumpWidget(_seal(0, calm: true));
    await tester.pumpWidget(_seal(1, calm: true));
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('破'), findsOneWidget);
    expect(
      find
          .byType(CustomPaint)
          .evaluate()
          .where((e) => (e.widget as CustomPaint).painter != null),
      isEmpty,
    );
  });

  testWidgets('PopText fuerte: borde dorado y dura más', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Center(
          child: PopText(text: '−24', color: Colors.red, heavy: true),
        ),
      ),
    );
    expect(find.text('−24'), findsNWidgets(2), reason: 'borde y relleno');
    await tester.pump(const Duration(milliseconds: 1100));
    final op = tester.widget<Opacity>(find.byType(Opacity).first).opacity;
    expect(op, greaterThan(0));
  });

  testWidgets('ComboCounter: desde el segundo golpe, crece y se apaga', (
    tester,
  ) async {
    double opacity() =>
        tester.widget<AnimatedOpacity>(find.byType(AnimatedOpacity)).opacity;
    double fontOf(String n) =>
        tester.widget<Text>(find.text(n).last).style!.fontSize!;

    await tester.pumpWidget(_combo(1));
    expect(opacity(), 0, reason: 'un golpe solo no es cadena');
    await tester.pumpWidget(_combo(2));
    await tester.pump(const Duration(milliseconds: 500));
    expect(opacity(), 1);
    final small = fontOf('2');
    await tester.pumpWidget(_combo(5));
    await tester.pump(const Duration(milliseconds: 500));
    expect(fontOf('5'), greaterThan(small));
    expect(find.text('5'), findsNWidgets(2), reason: 'de 5 en adelante, borde');
    expect(ComboCounter.colorOf(5), isNot(ComboCounter.colorOf(2)));

    // Cierra el turno: se desvanece mostrando todavía el último número.
    await tester.pumpWidget(_combo(0));
    expect(opacity(), 0);
    expect(find.text('5'), findsWidgets);
  });
}

Widget _combo(int n) => MaterialApp(
  home: Center(
    child: ComboCounter(count: n, label: 'golpes'),
  ),
);

Widget _seal(int trigger, {bool calm = false}) => MaterialApp(
  home: MediaQuery(
    data: MediaQueryData(disableAnimations: calm),
    child: Stack(
      children: [Positioned.fill(child: FinisherSeal(trigger: trigger))],
    ),
  ),
);
