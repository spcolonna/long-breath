import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/content_text.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/screens/monastery_screen.dart';
import 'package:long_breath/delivery/theme.dart';
import 'package:long_breath/delivery/widgets/school_life.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/school_story.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

final _json =
    jsonDecode(File('assets/l10n/content/es.json').readAsStringSync())
        as Map<String, dynamic>;
final _text = ContentText(_json);
final _data = loadGameDataFromDir();

StoryWait _wait({
  Set<String> lore = const {},
  int level = 0,
  int last = 1,
  int readAt = 0,
}) => schoolStoryWait(
  thread: 'ming',
  lore: lore,
  level: level,
  lastDisciple: last,
  readAt: readAt,
);

Future<void> _settle(WidgetTester tester, [int n = 6]) async {
  for (var i = 0; i < n; i++) {
    await tester.pump(const Duration(milliseconds: 300));
  }
}

Future<void> _app(
  WidgetTester tester,
  Map<String, Object> prefs,
  Widget home,
) async {
  tester.view.physicalSize = const Size(750, 1334);
  tester.view.devicePixelRatio = 2;
  addTearDown(tester.view.reset);
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
            final ready =
                ref.watch(gameDataProvider).hasValue &&
                ref.watch(contentTextProvider).hasValue;
            return ready ? home : const Scaffold();
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
}

String _ascent(int n, {bool fell = true, int stage = 0, String? enemy}) =>
    jsonEncode(
      Ascent.fromJson({
        'n': n,
        'fell': fell,
        'floor': 5,
        'floors': 13,
        'difficulty': 'normal',
        'stage': stage,
        'enemy': ?enemy,
        'lore': <String>[],
      }).toJson(),
    );

void main() {
  group('hilos de la escuela', () {
    test('el primer capítulo pide haber bajado de una subida', () {
      expect(_wait(last: 0), StoryWait.ascent);
      expect(_wait(), StoryWait.none);
    });

    test('un capítulo por vuelta y el edificio marca el ritmo', () {
      final one = {'ming_1'};
      expect(_wait(lore: one, last: 3, readAt: 3), StoryWait.ascent);
      expect(_wait(lore: one, last: 4, readAt: 3), StoryWait.level);
      expect(_wait(lore: one, level: 1, last: 4, readAt: 3), StoryWait.none);
    });

    test('el último capítulo pide cumbre', () {
      final four = {'ming_1', 'ming_2', 'ming_3', 'ming_4'};
      expect(_wait(lore: four, level: 3, last: 9, readAt: 8), StoryWait.summit);
      expect(
        _wait(lore: {...four, 'summit'}, level: 3, last: 9, readAt: 8),
        StoryWait.none,
      );
      expect(
        _wait(lore: {...four, 'ming_5'}, level: 3, last: 9),
        StoryWait.done,
      );
    });

    test('cada capítulo tiene texto y está en el registro', () {
      final lore = _json['lore'] as Map<String, dynamic>;
      for (final id in schoolStoryLore) {
        expect(loreOrder, contains(id));
        expect(lore[id], containsPair('hint', isA<String>()), reason: id);
      }
      expect(threadOfBuilding('forge'), 'tie');
      expect(threadOfBuilding('library'), isNull);
    });
  });

  group('el maestro comenta la subida', () {
    test('elige la línea según cómo terminó', () {
      expect(masterRecapKey(fell: false, stage: 2, n: 4), 'won_a');
      expect(
        masterRecapKey(fell: true, stage: 1, n: 3, enemy: 'x', ghost: true),
        'ghost',
      );
      expect(
        masterRecapKey(fell: true, stage: 2, n: 3, enemy: 'x', boss: true),
        'fell_boss',
      );
      expect(
        masterRecapKey(fell: true, stage: 1, n: 3, enemy: 'x'),
        'fell_1_b',
      );
      expect(masterRecapKey(fell: true, stage: 1, n: 3), 'fell_1_a');
    });

    test('todas las líneas tienen texto', () {
      final keys = {
        for (final fell in [true, false])
          for (final stage in [0, 1, 2])
            for (final n in [1, 2])
              for (final enemy in [null, 'x'])
                for (final ghost in [true, false])
                  for (final boss in [true, false])
                    masterRecapKey(
                      fell: fell,
                      stage: stage,
                      n: n,
                      enemy: enemy,
                      ghost: ghost,
                      boss: boss,
                    ),
      };
      for (final k in keys) {
        expect(_text.has('masterRecap', k), isTrue, reason: k);
      }
    });

    testWidgets('el globo nombra al rival de la última subida', (tester) async {
      await _app(tester, {
        'long_breath.ascents': [_ascent(3, stage: 1, enemy: 'bell_abbot')],
      }, const Scaffold(body: Center(child: MasterRecap())));
      expect(find.textContaining('Abad de la Gran Campana'), findsOneWidget);
      await tester.tap(find.byType(MasterRecap));
      await _settle(tester, 3);
      expect(find.textContaining('Abad de la Gran Campana'), findsNothing);
    });
  });

  testWidgets('Ming cuenta su capítulo en la enfermería', (tester) async {
    await _app(tester, {
      'long_breath.ascents': [_ascent(1)],
    }, const MonasteryScreen());
    expect(find.text('Historia'), findsWidgets);
    await tester.tap(find.textContaining('Enfermería').first);
    await _settle(tester);
    expect(find.text('Historia de Hermano Ming'), findsOneWidget);
    await tester.tap(find.text('Escuchar a Hermano Ming'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await _settle(tester);
    expect(find.text('Hierbas de la montaña'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('Entendido'));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await _settle(tester);
    final container = ProviderScope.containerOf(
      tester.element(find.byType(MonasteryScreen)),
    );
    final waits = await tester.runAsync(
      () => container.read(schoolStoryProvider.future),
    );
    expect(waits!['ming'], StoryWait.ascent, reason: 'uno por vuelta');
    expect(waits['tie'], StoryWait.none);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('long_breath.lore'), contains('ming_1'));
  });
}
