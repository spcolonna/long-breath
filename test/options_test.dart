import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/feel.dart';
import 'package:long_breath/delivery/widgets/options_sheet.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Opciones: movimiento reducido y vibración se aplican y se '
      'guardan', (tester) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    addTearDown(() => Haptics.enabled = true);

    late bool calmNow;
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (_, child) => MotionScope(child: child!),
          home: Scaffold(
            body: Builder(
              builder: (context) {
                calmNow = calm(context);
                return const Center(child: OptionsButton());
              },
            ),
          ),
        ),
      ),
    );
    expect(calmNow, isFalse);

    await tester.tap(find.byType(OptionsButton));
    await tester.pumpAndSettle();
    expect(find.text('Opciones'), findsOneWidget);

    await tester.tap(find.text('Reducido'));
    await tester.pumpAndSettle();
    expect(calmNow, isTrue);

    await tester.tap(find.byType(Switch).last);
    await tester.pumpAndSettle();
    expect(Haptics.enabled, isFalse);

    final prefs = await SharedPreferences.getInstance();
    final saved = FeelSettings.read(prefs);
    expect(saved.motion, MotionPref.reduced);
    expect(saved.haptics, isFalse);
  });
}
