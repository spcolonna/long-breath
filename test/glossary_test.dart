import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/card_widget.dart';
import 'package:long_breath/delivery/widgets/deck_sheet.dart';
import 'package:long_breath/delivery/widgets/glossary.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:long_breath/l10n/app_localizations_es.dart';

List<Term> terms(String s) => [
  for (final (_, t) in splitTerms(s)) ?t,
];

void main() {
  group('splitTerms', () {
    test('encuentra los términos con sus variantes', () {
      expect(terms('Si desviás, el enemigo pierde 2 E extra'), [Term.deflect]);
      expect(terms('+3 si el enemigo está Desequilibrado'), [Term.staggered]);
      expect(terms('Si lo desequilibra, robás 1'), [Term.staggered]);
      expect(terms('Si la retuviste, +2 Aliento'), [Term.retain, Term.breath]);
      expect(terms('+2 Guardia. Agotar'), [Term.guard, Term.exhaust]);
    });

    test('«Paso en T» gana a «postura» y no hay falsos positivos', () {
      expect(terms('Paso en T te cambia de postura'), [
        Term.dingbu,
        Term.stance,
      ]);
      expect(terms('Pasás a Caballo. Robás 2'), isEmpty);
      expect(terms('Una transformación informal'), isEmpty);
    });

    test('reconstruye el texto completo y respeta skip', () {
      const s = 'Tu Guardia absorbe el golpe; la Estructura no.';
      expect(splitTerms(s).map((e) => e.$1).join(), s);
      expect(terms(s), [Term.guard, Term.structure]);
      expect(splitTerms(s, skip: {Term.guard}).map((e) => e.$1).join(), s);
      expect(
        [for (final (_, t) in splitTerms(s, skip: {Term.guard})) ?t],
        [Term.structure],
      );
    });
  });

  test('cada término tiene nombre, explicación y hanzi', () {
    final t = AppLocalizationsEs();
    for (final term in Term.values) {
      expect(t.termTitle(term, dingbu: 'Paso en T'), isNotEmpty);
      expect(t.termBody(term).length, greaterThan(30), reason: '$term');
      expect(term.hanzi.runes, hasLength(1));
      expect(term.related, isNot(contains(term)));
    }
  });

  testWidgets(
    'pulsación larga abre la ficha; sus términos abren el glosario',
    (tester) async {
      final data = loadGameDataFromDir('assets/data');
      final container = ProviderContainer(
        overrides: [dataProvider.overrideWithValue(data)],
      );
      addTearDown(container.dispose);
      await tester.runAsync(() => container.read(contentTextProvider.future));
      final def = data.cards.values.firstWhere((c) => c.guard > 0);
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: Scaffold(
              body: DeckGrid(cards: [CombatCard(uid: 0, cardId: def.id)]),
            ),
          ),
        ),
      );
      await tester.pump();

      await tester.longPress(find.byType(CardWidget));
      await tester.pumpAndSettle();
      final text = container.read(textProvider);
      expect(find.text(text.card(def.id)), findsWidgets);
      expect(find.byType(CardWidget), findsNWidgets(2));

      // La pastilla de Guardia abre su explicación.
      final t = AppLocalizationsEs();
      await tester.tap(find.widgetWithText(TermPill, t.guard));
      await tester.pumpAndSettle();
      expect(find.text(t.glossGuard, findRichText: true), findsOneWidget);

      // «Ver también» cambia el contenido en el lugar.
      await tester.tap(find.widgetWithText(TermPill, t.termDeflect).last);
      await tester.pumpAndSettle();
      expect(find.text(t.glossDeflect, findRichText: true), findsOneWidget);
      expect(find.text(t.glossGuard, findRichText: true), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}
