import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../domain/model/game_data.dart';
import '../../l10n/app_localizations.dart';
import '../content_text.dart';
import '../providers.dart';
import '../theme.dart';

/// Nombre de algo que abre la maestría: una carta, un despertar del camino o
/// la carta del nivel 3 de su arma (se muestra como el arma).
String masteryUnlockName(
  AppLocalizations t,
  ContentText text,
  GameData data,
  Style s,
  String id,
) {
  if (data.balance.statsOf(s).awakenings.any((a) => a.id == id)) {
    return t.masteryAwakening(text.awakening(id));
  }
  for (final w in data.weapons.values) {
    if (w.levels.length >= 3 && w.levels[2].cards.contains(id)) {
      return t.masteryWeapon(text.weapon(w.id));
    }
  }
  return text.card(id);
}

/// Abre la hoja con la maestría de los tres caminos.
void showMasterySheet(BuildContext context) => showModalBottomSheet<void>(
  context: context,
  backgroundColor: Palette.surface,
  showDragHandle: true,
  isScrollControlled: true,
  builder: (_) => const MasterySheet(),
);

/// Los tres caminos con su nivel, su experiencia y lo que abre cada nivel.
class MasterySheet extends ConsumerWidget {
  const MasterySheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final xp = ref.watch(masteryProvider).value ?? const {};
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.85,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.masteryTitle,
              style: const TextStyle(fontSize: 22, fontFamily: Fonts.display),
            ),
            const SizedBox(height: 4),
            Text(
              t.masteryHint,
              style: const TextStyle(
                fontSize: 13.5,
                height: 1.3,
                color: Palette.textDim,
              ),
            ),
            for (final s in Style.values) ...[
              const SizedBox(height: 16),
              _PathMastery(style: s, xp: xp[s] ?? 0),
            ],
          ],
        ),
      ),
    );
  }
}

class _PathMastery extends ConsumerWidget {
  const _PathMastery({required this.style, required this.xp});

  final Style style;
  final int xp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final def = data.balance.mastery;
    final level = def.levelOf(xp);
    final next = def.nextXp(xp);
    final color = styleColor(style);
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                data.balance.statsOf(style).hanzi,
                style: TextStyle(
                  fontSize: 26,
                  fontFamily: Fonts.display,
                  height: 1.1,
                  color: color,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text.style(style),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      next == null
                          ? t.masteryFull
                          : '${t.masteryLevel(level, def.maxLevel)} · '
                                '${t.masteryXp(xp, next)}',
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: def.progress(xp),
              minHeight: 6,
              color: color,
              backgroundColor: color.withValues(alpha: 0.15),
            ),
          ),
          const SizedBox(height: 8),
          for (final (i, l) in def.levels.indexed)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    i < level
                        ? Icons.check_circle_rounded
                        : Icons.radio_button_unchecked_rounded,
                    size: 16,
                    color: i < level ? color : Palette.line,
                  ),
                  const SizedBox(width: 6),
                  SizedBox(
                    width: 30,
                    child: Text(
                      '${i + 1}',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: i < level ? Palette.text : Palette.textDim,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      [
                        for (final id in l.of(style))
                          masteryUnlockName(t, text, data, style, id),
                      ].join(' · '),
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.25,
                        color: i < level ? Palette.text : Palette.textDim,
                      ),
                    ),
                  ),
                  Text(
                    '${l.xp}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Lo que ganó el camino en la subida que terminó y, si subió de nivel, lo
/// que se abre.
class MasteryResultLine extends ConsumerWidget {
  const MasteryResultLine({super.key, required this.style, required this.xp});

  final Style style;
  final int xp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final def = data.balance.mastery;
    final total = ref.watch(masteryProvider).value?[style];
    if (def.isEmpty || total == null) return const SizedBox.shrink();
    final before = def.levelOf(total - xp);
    final now = def.levelOf(total);
    final color = styleColor(style);
    return Column(
      children: [
        Text(
          t.masteryGained(text.style(style), xp, now),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (now > before)
          Text(
            t.masteryUp(
              [
                for (final l in def.levels.sublist(before, now))
                  for (final id in l.of(style))
                    masteryUnlockName(t, text, data, style, id),
              ].join(' · '),
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              height: 1.25,
              color: Palette.gold,
              fontWeight: FontWeight.w600,
            ),
          ),
      ],
    );
  }
}
