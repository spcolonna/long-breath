import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_state.dart';
import '../providers.dart';
import '../theme.dart';
import 'card_widget.dart';

/// Grilla de cartas; con [onPick] se puede elegir una.
class DeckGrid extends ConsumerWidget {
  const DeckGrid({super.key, required this.cards, this.onPick, this.enabled});

  final List<CombatCard> cards;
  final void Function(CombatCard)? onPick;
  final bool Function(CombatCard)? enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final sorted = [...cards]..sort((a, b) => a.cardId.compareTo(b.cardId));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 96,
        childAspectRatio: 1 / 1.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final c = sorted[i];
        final ok = enabled?.call(c) ?? true;
        return GestureDetector(
          onTap: onPick != null && ok ? () => onPick!(c) : null,
          child: FittedBox(
            child: CardWidget(
              def: data.card(c.cardId),
              upgrades: c.upgrades,
              playable: ok,
            ),
          ),
        );
      },
    );
  }
}

void showDeckSheet(BuildContext context, List<CombatCard> deck) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Palette.surface,
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: DeckGrid(cards: deck),
    ),
  );
}
