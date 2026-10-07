import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/ascent.dart';
import '../../l10n/app_localizations.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/scene_backdrop.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/cultivation_view.dart';

/// 名册: el registro de la escuela. Una tablilla por cada discípulo que
/// subió (los que cayeron y los que llegaron) y los pergaminos que se
/// fueron abriendo.
class RegistryScreen extends ConsumerWidget {
  const RegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ascents = ref.watch(ascentsProvider).value ?? const <Ascent>[];
    final lore = ref.watch(loreProvider).value ?? const <String>{};
    final fallen = ascents.where((a) => a.fell).length;
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: () => context.go('/'),
          ),
          title: Text('${t.registryTitle} · 名册'),
          bottom: TabBar(
            indicatorColor: Palette.lacquer,
            labelColor: Palette.text,
            unselectedLabelColor: Palette.textDim,
            onTap: (_) => HapticFeedback.selectionClick(),
            tabs: [
              for (final label in [
                t.registryAscents,
                '${t.registryScrolls} ${lore.length}/${loreOrder.length}',
                t.registryTabCultivation,
              ])
                Tab(
                  child: FittedBox(fit: BoxFit.scaleDown, child: Text(label)),
                ),
            ],
          ),
        ),
        body: SceneBackdrop(
          assets: stageArt('qianyunshan', 'school_wall.png'),
          veil: 0.7,
          child: TabBarView(
          children: [
            ascents.isEmpty
                ? Center(
                    child: Text(
                      t.registryEmpty,
                      style: const TextStyle(color: Palette.textDim),
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                    children: [
                      Center(
                        child: Text(
                          t.registrySummary(fallen, ascents.length - fallen),
                          style: const TextStyle(color: Palette.textDim),
                        ),
                      ),
                      const SizedBox(height: 10),
                      // La más reciente arriba.
                      for (final (i, a) in ascents.reversed.indexed)
                        TweenAnimationBuilder<double>(
                          tween: Tween(begin: 0, end: 1),
                          duration: Duration(
                            milliseconds: 300 + 60 * i.clamp(0, 8),
                          ),
                          curve: Curves.easeOutCubic,
                          builder: (_, v, child) => Opacity(
                            opacity: v,
                            child: Transform.translate(
                              offset: Offset(0, 14 * (1 - v)),
                              child: child,
                            ),
                          ),
                          child: _AscentTile(a: a),
                        ),
                    ],
                  ),
            ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                for (final id in loreOrder) ...[
                  LoreScroll(id: id, sealed: !lore.contains(id)),
                  const SizedBox(height: 14),
                ],
              ],
            ),
            const RealmList(),
          ],
        ),
      ),
      ),
    );
  }
}

class _AscentTile extends ConsumerWidget {
  const _AscentTile({required this.a});

  final Ascent a;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final hanzi = ref.watch(dataProvider).balance.statsOf(a.style).hanzi;
    final color = styleColor(a.style);
    final outcome = !a.fell
        ? t.registrySummit
        : a.enemy == null
        ? t.registryFellEarly
        : t.registryFell(text.enemy(a.enemy!));
    final place = a.scene == null
        ? null
        : text.path(a.scene!, a.light ?? 'alba');
    final level = a.pico > 0
        ? '${t.difficultyName(a.difficulty)} · ${t.picoName(a.pico)}'
        : t.difficultyName(a.difficulty);
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF6E9CF), Color(0xFFEBD5AC)],
        ),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFC9A46A)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Palette.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
            ),
            child: Text(hanzi, style: TextStyle(fontSize: 19, color: color)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.discipleN(a.n),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
                Text(
                  place == null ? outcome : '$outcome · $place',
                  style: const TextStyle(fontSize: 13),
                ),
                Text(
                  '${t.tabletFloor(a.floor, a.floors)} · $level',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Palette.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Transform.rotate(
            angle: -0.15,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (a.fell ? Palette.lacquer : Palette.gold).withValues(
                  alpha: 0.9,
                ),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                a.fell ? '败' : '顶',
                style: const TextStyle(
                  color: Palette.onColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
