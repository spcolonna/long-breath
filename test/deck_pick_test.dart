import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/card_widget.dart';
import 'package:long_breath/delivery/widgets/deck_sheet.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/l10n/app_localizations.dart';

void main() {
  testWidgets('la carta elegida se anima y recién después se avisa', (
    tester,
  ) async {
    final data = loadGameDataFromDir('assets/data');
    final container = ProviderContainer(
      overrides: [dataProvider.overrideWithValue(data)],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(contentTextProvider.future));
    final ids = data.cards.keys.take(3);
    final cards = [
      for (final (i, id) in ids.indexed) CombatCard(uid: i, cardId: id),
    ];
    final picked = <CombatCard>[];
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: DeckGrid(
              cards: cards,
              pickFx: DeckPick.remove,
              onPick: picked.add,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byType(CardWidget).first);
    await tester.pump(const Duration(milliseconds: 200));
    expect(picked, isEmpty, reason: 'todavía se está quemando');

    // Mientras tanto, las demás no se pueden tocar.
    await tester.tap(find.byType(CardWidget).last, warnIfMissed: false);
    await tester.pump(const Duration(seconds: 1));
    expect(picked, hasLength(1));
    expect(tester.takeException(), isNull);
  });
}
