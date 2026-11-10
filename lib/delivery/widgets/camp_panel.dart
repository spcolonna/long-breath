import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../theme.dart';
import 'lore_scroll.dart';
import 'node_kit.dart';
import 'paper_panel.dart';
import 'press.dart';
import 'talisman_widgets.dart';

/// El campamento entre etapas: alrededor de la fogata llega una carta del
/// maestro o un sueño del dragón, y se puede hacer un voto (una ventaja con
/// un costo) que rige solo la etapa que viene.
class CampPanel extends ConsumerWidget {
  const CampPanel({
    super.key,
    required this.lore,
    required this.vows,
    required this.picked,
    required this.onPick,
  });

  /// La carta o el sueño de esta noche (null: una noche tranquila).
  final String? lore;
  final List<String> vows;
  final String? picked;
  final ValueChanged<String?> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final letter = lore?.startsWith('letter_') ?? false;
    return SingleChildScrollView(
      child: Column(
        children: [
          StaggerIn(
            index: 0,
            child: Column(
              children: [
                const Text(
                  '火',
                  style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w700,
                    color: Palette.gold,
                  ),
                ),
                Text(
                  t.campTitle,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Palette.text,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  lore == null
                      ? t.campQuiet
                      : letter
                      ? t.campLetter
                      : t.campDream,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Palette.text),
                ),
              ],
            ),
          ),
          if (lore != null) ...[
            const SizedBox(height: 10),
            StaggerIn(
              index: 1,
              delay: const Duration(milliseconds: 200),
              child: LoreScroll(id: lore!, fresh: true),
            ),
          ],
          if (vows.isNotEmpty) ...[
            const SizedBox(height: 16),
            StaggerIn(
              index: 2,
              delay: const Duration(milliseconds: 350),
              child: PaperPanel(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
                child: Column(
                  children: [
                    Text(
                      t.campVowTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Palette.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t.campVowHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            for (final (i, id) in vows.indexed)
              StaggerIn(
                index: 3 + i,
                delay: const Duration(milliseconds: 400),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Press(
                    child: GestureDetector(
                      key: ValueKey('vow_$id'),
                      onTap: () => onPick(picked == id ? null : id),
                      child: PickCard(
                        picked: picked == id,
                        dimmed: picked != null && picked != id,
                        taking: false,
                        accent: Palette.sky,
                        child: TalismanTile(id: id, badgeSize: 44),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
