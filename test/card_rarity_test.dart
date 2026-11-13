import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/delivery/widgets/card_widget.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/l10n/app_localizations.dart';

void main() {
  testWidgets('la carta muestra su tipo por forma y la gema de su rareza', (
    tester,
  ) async {
    final data = loadGameDataFromDir('assets/data');
    final container = ProviderContainer(
      overrides: [dataProvider.overrideWithValue(data)],
    );
    addTearDown(container.dispose);
    await tester.runAsync(() => container.read(contentTextProvider.future));
    Future<void> show(String id) => tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: CardWidget(def: data.card(id))),
        ),
      ),
    );

    await show('hu_pu');
    expect(data.card('hu_pu').rarity, CardRarity.legendary);
    expect(find.byType(TypeMark), findsOneWidget);
    expect(find.bySemanticsLabel('Carta legendaria'), findsOneWidget);
    expect(find.bySemanticsLabel('Palma'), findsOneWidget);

    await show('pi_quan');
    expect(find.bySemanticsLabel('Carta rara'), findsOneWidget);

    // Las comunes no llevan gema.
    await show('deng_tui');
    expect(find.byType(RarityGem), findsNothing);
    expect(find.bySemanticsLabel('Patada'), findsOneWidget);
  });
}
