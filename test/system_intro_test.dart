import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:long_breath/delivery/theme.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:long_breath/delivery/content_text.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/delivery/screens/progress_screen.dart';
import 'package:long_breath/delivery/widgets/system_intro.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Teléfono chico (iPhone SE: 375 × 667).
void _phone(WidgetTester tester) {
  tester.view.physicalSize = const Size(750, 1334);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
}

Future<void> _settle(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

late WidgetRef _ref;
final _data = loadGameDataFromDir();
final _text = ContentText(
  jsonDecode(File('assets/l10n/content/es.json').readAsStringSync())
      as Map<String, dynamic>,
);

/// La app mínima: datos cargados y [home] (sin el router global, que no
/// sobrevive a varias apps en un mismo archivo).
Future<BuildContext> _app(
  WidgetTester tester,
  Map<String, Object> prefs, {
  Widget? home,
}) async {
  SharedPreferences.setMockInitialValues(prefs);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        gameDataProvider.overrideWith((_) => _data),
        contentTextProvider.overrideWith((_) => _text),
      ],
      child: MaterialApp(
        theme: buildTheme(),
        locale: const Locale('es'),
        supportedLocales: const [Locale('es')],
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: Consumer(
          builder: (context, ref, _) {
            _ref = ref;
            final ready =
                ref.watch(gameDataProvider).hasValue &&
                ref.watch(contentTextProvider).hasValue;
            if (!ready) return const Scaffold();
            return home ?? const Scaffold(body: SizedBox.expand());
          },
        ),
      ),
    ),
  );
  for (var i = 0; i < 3; i++) {
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 400)),
    );
    await _settle(tester, 4);
  }
  return tester.element(find.byType(Scaffold).first);
}

void main() {
  test('el progreso promedia las partes', () {
    const p = (
      realm: ProgressPart(1, 4),
      meridians: ProgressPart(0, 30),
      school: ProgressPart(15, 15),
      mastery: ProgressPart(0, 15),
      summits: ProgressPart(0, 3),
      picos: ProgressPart(0, 10),
      story: ProgressPart(0, 10),
    );
    // (0,25 + 1) / 7 = 17,8 %
    expect(progressPercent(p), 17);
    expect(const ProgressPart(3, 0).fraction, 0);
  });

  for (final s in SystemIntro.values) {
    testWidgets('la presentación de ${s.name} entra en un teléfono chico y '
        'se muestra una sola vez', (tester) async {
      _phone(tester);
      final context = await _app(tester, {});
      final container = ProviderScope.containerOf(context);
      Future<void> open({bool force = false}) async {
        showSystemIntro(context, _ref, s, force: force);
        await _settle(tester);
      }

      await open();
      expect(find.byType(SystemIntroSheet), findsOneWidget);
      expect(tester.takeException(), isNull);
      expect(
        tester.getRect(find.text('Entendido')).bottom,
        lessThan(667),
        reason: 'el botón se ve sin desplazar',
      );
      await tester.tap(find.text('Entendido'));
      await _settle(tester);
      expect(find.byType(SystemIntroSheet), findsNothing);
      expect(await container.read(seenProvider.future), contains(s.id));

      await open();
      expect(find.byType(SystemIntroSheet), findsNothing);
      await open(force: true);
      expect(find.byType(SystemIntroSheet), findsOneWidget);
    });
  }

  testWidgets('la pantalla de progreso muestra cada parte y entra en un '
      'teléfono chico', (tester) async {
    _phone(tester);
    await _app(tester, {
      'long_breath.mastery': ['tiger:70'],
      'long_breath.lore': ['prologue', 'ending_crane'],
      'long_breath.cinematics': [SystemIntro.progress.id],
    }, home: const ProgressScreen());
    expect(find.text('Camino recorrido'), findsOneWidget);
    expect(find.byType(SystemIntroSheet), findsNothing);
    expect(find.text('Cultivo'), findsOneWidget);
    expect(find.text('Árbol de meridianos'), findsOneWidget);
    expect(
      find.textContaining('niveles entre los tres caminos'),
      findsOneWidget,
    );
    expect(find.textContaining('1 de 3 caminos'), findsOneWidget);
    await tester.drag(find.byType(ListView).last, const Offset(0, -1500));
    await _settle(tester, 3);
    expect(find.textContaining('pergaminos'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('la primera vez, la pantalla de progreso se presenta', (
    tester,
  ) async {
    _phone(tester);
    await _app(tester, {}, home: const ProgressScreen());
    expect(find.byType(SystemIntroSheet), findsOneWidget);
    expect(find.text('MAESTRO SONG'), findsOneWidget);
  });
}
