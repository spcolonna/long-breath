import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../infrastructure/slot_storage.dart';
import '../../l10n/app_localizations.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import 'difficulty_sheet.dart';

/// Sello de la dificultad de una partida: un círculo de su color con el
/// hanzi.
class DifficultySeal extends ConsumerWidget {
  const DifficultySeal({super.key, required this.difficulty, this.size = 28});

  final Difficulty difficulty;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hanzi = ref.watch(dataProvider).balance.difficulty(difficulty).hanzi;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: difficultyColor(difficulty),
        shape: BoxShape.circle,
      ),
      child: Text(
        hanzi,
        style: TextStyle(
          fontSize: size * 0.5,
          height: 1,
          color: Palette.onColor,
        ),
      ),
    );
  }
}

/// "Partida 2 · Normal": qué partida se está jugando, arriba de la escuela.
class SlotBadge extends StatelessWidget {
  const SlotBadge({super.key, required this.slot, required this.info});

  final int slot;
  final SlotInfo info;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return FittedBox(
      fit: BoxFit.scaleDown,
      alignment: Alignment.centerLeft,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DifficultySeal(difficulty: info.difficulty, size: 26),
          const SizedBox(width: 8),
          Text(
            t.slotName(slot),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
          ),
          Text(
            ' · ${t.difficultyName(info.difficulty)}',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: difficultyColor(info.difficulty),
            ),
          ),
        ],
      ),
    );
  }
}
