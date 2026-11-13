import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/chronicle.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';

/// 山志: la crónica de la montaña en el registro. Por etapa, una ficha por
/// rival: sellada si nunca se lo cruzó; si no, su retrato, su historia y
/// cuántas veces se lo venció y te venció.
class ChronicleList extends ConsumerWidget {
  const ChronicleList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final seen = ref.watch(bestiaryProvider).value ?? const {};
    final groups = chronicleByStage(data);
    final stages = data.balance.stages;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: Palette.surface.withValues(alpha: 0.9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            t.chronicleSummary,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Palette.textDim),
          ),
        ),
        for (final (i, ids) in groups.indexed)
          if (ids.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
              child: Text(
                i < stages.length
                    ? '${stages[i].hanzi}  ${text.stage(stages[i].id)}'
                    : t.chronicleLost,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Palette.text,
                ),
              ),
            ),
            for (final id in ids)
              _ChronicleCard(id: id, s: seen[id] ?? const Sighting()),
          ],
      ],
    );
  }
}

class _ChronicleCard extends ConsumerWidget {
  const _ChronicleCard({required this.id, required this.s});

  final String id;
  final Sighting s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final def = ref.watch(dataProvider).enemy(id);
    final text = ref.watch(textProvider);
    final color = switch (def.rank) {
      EnemyRank.boss => Palette.lacquer,
      EnemyRank.elite => Palette.gold,
      _ => Palette.jade,
    };
    final sealed = !s.seen;
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: sealed
              ? const [Color(0xFFEDE3D0), Color(0xFFE2D4BA)]
              : const [Color(0xFFF6E9CF), Color(0xFFEBD5AC)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC9A46A)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.surface,
              border: Border.all(
                color: sealed ? Palette.line : color,
                width: 2.5,
              ),
            ),
            child: sealed
                ? const Center(
                    child: Text(
                      '封',
                      style: TextStyle(
                        fontSize: 24, fontFamily: Fonts.display,
                        fontWeight: FontWeight.w700,
                        color: Palette.textDim,
                      ),
                    ),
                  )
                : ClipOval(
                    child: Image.asset(
                      'assets/art/enemies/${def.art}.webp',
                      cacheWidth: 192,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => Center(
                        child: Text(
                          def.hanzi ?? '?',
                          style: TextStyle(fontSize: 24, fontFamily: Fonts.display, color: color),
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sealed
                      ? '？？？'
                      : [text.enemy(id), ?def.hanzi].join('  '),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: sealed ? Palette.textDim : Palette.text,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  sealed ? t.chronicleSealed : text.enemyLore(id),
                  style: TextStyle(
                    fontSize: 13.5,
                    height: 1.35,
                    fontStyle: sealed ? FontStyle.normal : FontStyle.italic,
                    color: sealed ? Palette.textDim : Palette.text,
                  ),
                ),
                if (!sealed) ...[
                  const SizedBox(height: 4),
                  Text(
                    t.chronicleCount(s.wins, s.falls),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Palette.textDim,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
