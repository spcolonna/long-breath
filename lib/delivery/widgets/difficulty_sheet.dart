import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';

/// Color de cada dificultad: de jade (tranquila) a laca (maestro).
Color difficultyColor(Difficulty d) => switch (d) {
      Difficulty.easy => Palette.jade,
      Difficulty.normal => Palette.sky,
      Difficulty.hard => Palette.gold,
      Difficulty.shifu => Palette.lacquer,
    };

/// Pregunta la dificultad de la subida nueva. Null si se cierra sin elegir.
Future<Difficulty?> pickDifficulty(
  BuildContext context, {
  Difficulty initial = Difficulty.normal,
}) =>
    showModalBottomSheet<Difficulty>(
      context: context,
      backgroundColor: Palette.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _DifficultySheet(initial: initial),
    );

class _DifficultySheet extends ConsumerWidget {
  const _DifficultySheet({required this.initial});

  final Difficulty initial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final balance = ref.watch(dataProvider).balance;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Palette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.difficultyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              t.difficultySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Palette.textDim),
            ),
            const SizedBox(height: 14),
            for (final d in Difficulty.values) ...[
              _Option(
                difficulty: d,
                hanzi: balance.difficulty(d).hanzi,
                stats: t.difficultyStats(
                  balance.difficulty(d).playerHp,
                  balance.difficulty(d).fountainHeal,
                  balance.difficulty(d).enemyDamage,
                ),
                selected: d == initial,
                onTap: () {
                  HapticFeedback.selectionClick();
                  ref.read(audioProvider).play(Sfx.uiButton);
                  Navigator.pop(context, d);
                },
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.difficulty,
    required this.hanzi,
    required this.stats,
    required this.selected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final String hanzi;
  final String stats;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = difficultyColor(difficulty);
    return Material(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Palette.line,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  hanzi,
                  style: const TextStyle(fontSize: 24, color: Palette.onColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.difficultyName(difficulty),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      t.difficultyDesc(difficulty),
                      style: const TextStyle(fontSize: 13, color: Palette.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stats,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}
