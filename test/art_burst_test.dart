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
}
