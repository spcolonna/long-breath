import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/daily.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../providers.dart';
import '../screens/home_screen.dart' show routeFor;
import '../theme.dart';
import 'confirm_dialog.dart';

/// El desafío de hoy en la escuela: el camino del día y, si ya se jugó,
/// cómo salió. Tocarlo (si falta) explica el desafío y sube.
class DailyLine extends ConsumerWidget {
  const DailyLine({super.key, this.replacing = false});

  /// Hay una subida a medias: empezar el desafío la reemplaza.
  final bool replacing;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final balance = ref.watch(dataProvider).balance;
    final today = ref.watch(todayProvider);
    final results = ref.watch(dailyResultsProvider).value;
    if (results == null) return const SizedBox.shrink();
    final style = dailyStyle(today);
    final color = styleColor(style);
    final path = t.tabletPath(text.style(style));
    final mine = results.where((r) => r.day == today).firstOrNull;
    final streak = dailyStats(results, today).streak;
    final status = mine == null
        ? t.dailySub(path)
        : !mine.done
        ? t.dailyStarted
        : mine.won
        ? t.dailyWon
        : t.dailyDone(mine.floor, mine.floors);

    Future<void> start() async {
      final ok = await confirmDialog(
        context,
        title: t.dailyStartTitle,
        body: replacing
            ? '${t.dailyStartBody(path)}\n\n${t.menuReplaceRunBody}'
            : t.dailyStartBody(path),
        ok: t.dailyStartOk,
        seal: '日',
      );
      if (!ok || !context.mounted) return;
      ref.read(runControllerProvider.notifier).newDaily(today);
      context.go(routeFor(ref.read(runControllerProvider)!));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Material(
        color: Palette.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: mine == null ? start : () => Haptics.selectionClick(),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 10, 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: color.withValues(alpha: 0.6)),
            ),
            child: Row(
              children: [
                Text(
                  balance.statsOf(style).hanzi,
                  style: TextStyle(
                    fontSize: 22,
                    height: 1,
                    fontFamily: Fonts.display,
                    color: color,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        t.dailyTitle,
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Palette.text,
                        ),
                      ),
                      Text(
                        status,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: mine == null ? color : Palette.textDim,
                        ),
                      ),
                      if (mine != null)
                        Text(
                          streak > 1
                              ? '${t.dailyStreak(streak)} · ${t.dailyTomorrow}'
                              : t.dailyTomorrow,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Palette.textDim,
                          ),
                        ),
                    ],
                  ),
                ),
                if (mine == null)
                  FilledButton(
                    style: FilledButton.styleFrom(
                      backgroundColor: color,
                      visualDensity: VisualDensity.compact,
                    ),
                    onPressed: start,
                    child: Text(t.dailyGo),
                  )
                else
                  Icon(
                    mine.won
                        ? Icons.emoji_events_rounded
                        : Icons.check_circle_outline_rounded,
                    color: mine.won ? Palette.gold : Palette.textDim,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
