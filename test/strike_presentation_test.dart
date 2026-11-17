import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/widgets/flow_wind.dart';
import 'package:long_breath/delivery/widgets/ink_dissolve.dart';
import 'package:long_breath/delivery/widgets/juice.dart';

Widget _app(Widget child, {bool calm = false}) => MaterialApp(
  home: Builder(
    builder: (context) => MediaQuery(
      data: MediaQuery.of(context).copyWith(disableAnimations: calm),
      child: Center(child: child),
    ),
  ),
);

double _zoom(WidgetTester tester) {
  final t = tester.widget<Transform>(
    find.descendant(of: find.byType(PunchZoom), matching: find.byType(Transform)),
  );
  return t.transform.getMaxScaleOnAxis();
}

Widget _punch(int trigger, {bool calm = false}) => _app(
  PunchZoom(
    trigger: trigger,
    amount: 0.1,
    child: const SizedBox(width: 100, height: 100),
  ),
  calm: calm,
);

void main() {
  group('PunchZoom', () {
    testWidgets('se acerca con el remate y vuelve', (tester) async {
      await tester.pumpWidget(_punch(0));
      expect(_zoom(tester), 1);
      await tester.pumpWidget(_punch(1));
      await tester.pump(const Duration(milliseconds: 250));
      expect(_zoom(tester), closeTo(1.1, 0.001));
      await tester.pump(const Duration(milliseconds: 700));
      expect(_zoom(tester), 1);
    });

    testWidgets('con movimiento reducido no se mueve', (tester) async {
      await tester.pumpWidget(_punch(0, calm: true));
      await tester.pumpWidget(_punch(1, calm: true));
      await tester.pump(const Duration(milliseconds: 250));
      expect(_zoom(tester), 1);
    });
  });

  group('InkTrail', () {
    testWidgets('solo se dibuja mientras dura la embestida', (tester) async {
      Widget trail(double p) => _app(
        InkTrail(
          progress: p,
          color: Colors.red,
          direction: const Offset(1, -1),
          length: 40,
        ),
      );
      await tester.pumpWidget(trail(0));
      expect(
        find.descendant(of: find.byType(InkTrail), matching: find.byType(CustomPaint)),
        findsNothing,
      );
      await tester.pumpWidget(trail(0.4));
      expect(
        find.descendant(of: find.byType(InkTrail), matching: find.byType(CustomPaint)),
        findsOneWidget,
      );
      await tester.pumpWidget(trail(1));
      expect(
        find.descendant(of: find.byType(InkTrail), matching: find.byType(CustomPaint)),
        findsNothing,
      );
    });
  });

  group('InkDissolve', () {
    testWidgets('sin shader se desvanece con opacidad', (tester) async {
      Widget dissolve(double p) =>
          _app(InkDissolve(progress: p, child: const SizedBox(width: 50, height: 50)));
      await tester.pumpWidget(dissolve(0));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 1);
      await tester.pumpWidget(dissolve(1));
      expect(tester.widget<Opacity>(find.byType(Opacity)).opacity, 0);
    });
  });

  group('FlowWind', () {
    testWidgets('los pétalos crecen con el nivel de Flujo', (tester) async {
      expect(FlowWind.petals, [0, 7, 15, 26]);
      for (var i = 1; i < FlowWind.petals.length; i++) {
        expect(FlowWind.petals[i], greaterThan(FlowWind.petals[i - 1]));
      }
    });

    testWidgets('sube y se apaga sin dejar el reloj corriendo', (tester) async {
      Widget wind(int lv) =>
          _app(SizedBox(width: 300, height: 300, child: FlowWind(level: lv)));
      await tester.pumpWidget(wind(0));
      expect(tester.hasRunningAnimations, isFalse);
      await tester.pumpWidget(wind(3));
      await tester.pump(const Duration(milliseconds: 500));
      expect(tester.hasRunningAnimations, isTrue);
      await tester.pumpWidget(wind(0));
      await tester.pump(const Duration(milliseconds: 1000));
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });

    testWidgets('con movimiento reducido no arranca', (tester) async {
      await tester.pumpWidget(
        _app(const SizedBox(width: 300, height: 300, child: FlowWind(level: 3)), calm: true),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(tester.hasRunningAnimations, isFalse);
    });
  });
}
