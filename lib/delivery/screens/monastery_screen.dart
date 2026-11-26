import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/school_def.dart';
import '../../domain/run/school_story.dart';
import '../../infrastructure/progress_storage.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../feel.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/system_intro.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/press.dart';
import '../widgets/scroll_panel.dart';

/// Ruta del arte de cada edificio y del fondo en ruinas.
String buildingArt(String id) => 'assets/art/school/$id.webp';
const schoolRuinsArt = 'assets/art/school/school_ruins.webp';

/// Color de acento de cada edificio (el de quien lo cuida).
Color buildingColor(String id) => switch (id) {
  'infirmary' => Palette.sky,
  'tea_house' => Palette.jade,
  'forge' => Palette.lacquer,
  'library' => Palette.structure,
  _ => Palette.gold,
};

/// 修復: el monasterio en ruinas que se restaura con el jade que sobra de las
/// subidas. Cinco edificios de tres niveles; cada nivel suma un don a todos
/// los discípulos que vienen.
class MonasteryScreen extends ConsumerStatefulWidget {
  const MonasteryScreen({super.key});

  @override
  ConsumerState<MonasteryScreen> createState() => _MonasteryScreenState();
}

class _MonasteryScreenState extends ConsumerState<MonasteryScreen> {
  /// El último edificio restaurado (rebota) y cuántas veces.
  String? _restored;
  int _burst = 0;

  Future<void> _restore(String id) async {
    final def = ref.read(dataProvider).balance.school;
    final ok =
        await ref.read(progressStorageProvider).restoreBuilding(def, id);
    if (!ok || !mounted) return;
    Haptics.heavyImpact();
    ref.read(audioProvider).play(Sfx.realmUp);
    ref
      ..invalidate(schoolProvider)
      ..invalidate(metaBonusProvider);
    setState(() {
      _restored = id;
      _burst++;
    });
  }

  /// Lee el próximo capítulo del hilo [thread] y lo desenrolla.
  Future<void> _listen(String thread) async {
    final storage = ref.read(progressStorageProvider);
    final lore = await ref.read(loreProvider.future);
    final ascents = await ref.read(ascentsProvider.future);
    final id = '${thread}_${schoolChapterOf(lore, thread) + 1}';
    await storage.readSchoolChapter(
      thread,
      id,
      ascents.isEmpty ? 0 : ascents.last.n,
    );
    ref
      ..invalidate(loreProvider)
      ..invalidate(schoolStoryProvider);
    if (!mounted) return;
    Haptics.lightImpact();
    ref.read(audioProvider).play(Sfx.scrollOpen);
    await showStoryChapter(context, id);
  }

  void _details(SchoolBuilding b) {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheet) => _BuildingSheet(
        building: b,
        onRestore: () {
          Navigator.of(sheet).pop();
          _restore(b.id);
        },
        onListen: (thread) {
          Navigator.of(sheet).pop();
          _listen(thread);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final def = ref.watch(dataProvider).balance.school;
    final s = ref.watch(schoolProvider).value;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.go('/school')),
        title: Text(t.schoolTitle),
        actions: [
          const IntroHelpButton(intro: SystemIntro.school),
          if (s != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: JadeCount(jade: s.jade, size: 22),
            ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            schoolRuinsArt,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const ColoredBox(color: Palette.bg),
          ),
          // Velo de papel para que se lea encima.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Palette.bg.withValues(alpha: 0.55),
                  Palette.bg.withValues(alpha: 0.15),
                  Palette.bg.withValues(alpha: 0.6),
                ],
              ),
            ),
          ),
          if (s != null)
            SafeArea(
              child: ScrollPanel(
                opacity: 0.8,
                margin: const EdgeInsets.fromLTRB(10, 8, 10, 12),
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 20),
                  children: [
                    Text(
                      t.schoolHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Palette.textDim),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.schoolProgress(def.restored(s.levels), def.maxLevels),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    for (final (i, b) in def.buildings.indexed)
                      StaggerIn(
                        index: i,
                        child: _BuildingCard(
                          building: b,
                          level: def.levelOf(b.id, s.levels),
                          jade: s.jade,
                          burst: _restored == b.id ? _burst : 0,
                          onTap: () => _details(b),
                        ),
                      ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Arte de un edificio: apagado y transparente mientras está en ruinas, y
/// más vivo con cada nivel.
class BuildingImage extends StatelessWidget {
  const BuildingImage({
    super.key,
    required this.id,
    required this.level,
    required this.maxLevel,
    this.size = 96,
  });

  final String id;
  final int level;
  final int maxLevel;
  final double size;

  static const _gray = ColorFilter.matrix([
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0.33, 0.33, 0.33, 0, 0, //
    0, 0, 0, 1, 0,
  ]);

  @override
  Widget build(BuildContext context) {
    final img = Image.asset(
      buildingArt(id),
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => SizedBox(width: size, height: size),
    );
    if (level <= 0) {
      return Opacity(
        opacity: 0.45,
        child: ColorFiltered(colorFilter: _gray, child: img),
      );
    }
    // Un halo cálido que crece con el nivel.
    final glow = level / maxLevel;
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: buildingColor(id).withValues(alpha: 0.18 + 0.22 * glow),
            blurRadius: 12 + 18 * glow,
            spreadRadius: -4,
          ),
        ],
      ),
      child: img,
    );
  }
}

/// Puntos de nivel: llenos los restaurados.
class _Pips extends StatelessWidget {
  const _Pips({required this.level, required this.max, required this.color});

  final int level;
  final int max;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      for (var i = 0; i < max; i++)
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          margin: const EdgeInsets.only(right: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: i < level ? color : Colors.transparent,
            border: Border.all(color: color, width: 1.5),
          ),
        ),
    ],
  );
}

class _BuildingCard extends ConsumerWidget {
  const _BuildingCard({
    required this.building,
    required this.level,
    required this.jade,
    required this.burst,
    required this.onTap,
  });

  final SchoolBuilding building;
  final int level;
  final int jade;
  final int burst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final b = building;
    final color = buildingColor(b.id);
    final next = level < b.maxLevel ? b.levels[level] : null;
    final ready = next != null && jade >= next.cost;
    final thread = threadOfBuilding(b.id);
    final story =
        thread != null &&
        ref.watch(schoolStoryProvider).value?[thread] == StoryWait.none;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Press(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(6, 6, 12, 6),
            decoration: BoxDecoration(
              color: Palette.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: color.withValues(alpha: ready ? 0.9 : 0.35),
                width: ready ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                Bounce(
                  trigger: burst,
                  scale: 1.25,
                  child: BuildingImage(
                    id: b.id,
                    level: level,
                    maxLevel: b.maxLevel,
                    size: 84,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              '${text.buildingHanzi(b.id)} ${text.building(b.id)}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontFamily: Fonts.display,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          _Pips(level: level, max: b.maxLevel, color: color),
                          if (story) const _StoryTag(),
                        ],
                      ),
                      Text(
                        level == 0
                            ? '${text.buildingWho(b.id)} · ${t.schoolRuined}'
                            : '${text.buildingWho(b.id)} · ${t.schoolLevel(level, b.maxLevel)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Palette.textDim,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (next == null)
                        Text(
                          t.schoolDone,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        )
                      else
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                t.bonusLines(next.effect).join(' · '),
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Opacity(
                              opacity: ready ? 1 : 0.55,
                              child: JadeCount(jade: next.cost, size: 16),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Detalle de un edificio: su historia, qué da cada nivel y el botón para
/// restaurar el próximo.
class _BuildingSheet extends ConsumerWidget {
  const _BuildingSheet({
    required this.building,
    required this.onRestore,
    required this.onListen,
  });

  final SchoolBuilding building;
  final VoidCallback onRestore;
  final void Function(String thread) onListen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = ref.watch(dataProvider).balance.school;
    final s = ref.watch(schoolProvider).value;
    if (s == null) return const SizedBox();
    final b = building;
    final color = buildingColor(b.id);
    final level = def.levelOf(b.id, s.levels);
    final next = def.nextLevel(b.id, s.levels);
    final missing = next == null ? 0 : next.cost - s.jade;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BuildingImage(
              id: b.id,
              level: level,
              maxLevel: b.maxLevel,
              size: 150,
            ),
            Text(
              '${text.buildingHanzi(b.id)} ${text.building(b.id)}',
              style: const TextStyle(
                fontSize: 22,
                fontFamily: Fonts.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              text.buildingWho(b.id),
              style: TextStyle(color: color, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 6),
            Text(
              text.buildingText(b.id),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textDim),
            ),
            if (threadOfBuilding(b.id) case final thread?)
              _StoryPanel(
                thread: thread,
                who: text.buildingWho(b.id),
                color: color,
                onListen: () => onListen(thread),
              ),
            const SizedBox(height: 14),
            for (final (i, l) in b.levels.indexed)
              _LevelRow(
                n: i + 1,
                lore: text.buildingLevel(b.id, i + 1),
                lines: t.bonusLines(l.effect),
                done: i < level,
                current: i == level,
                color: color,
              ),
            const SizedBox(height: 6),
            Text(
              t.meridianNextRun,
              style: const TextStyle(fontSize: 12, color: Palette.textDim),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: next == null
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(t.schoolDone),
                    )
                  : FilledButton.icon(
                      onPressed: missing <= 0 ? onRestore : null,
                      icon: const JadeCoin(size: 18),
                      label: Text(
                        missing > 0
                            ? t.schoolNeedsJade(missing)
                            : t.schoolRestore(next.cost),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LevelRow extends StatelessWidget {
  const _LevelRow({
    required this.n,
    required this.lore,
    required this.lines,
    required this.done,
    required this.current,
    required this.color,
  });

  final int n;
  final String lore;
  final List<String> lines;
  final bool done;
  final bool current;
  final Color color;

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: done || current ? 1 : 0.5,
    child: Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done ? color : Colors.transparent,
              border: Border.all(color: color, width: 1.5),
            ),
            child: done
                ? const Icon(Icons.check, size: 14, color: Palette.onColor)
                : Text(
                    '$n',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lines.join(' · '),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  lore,
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
    ),
  );
}

/// Cartelito «Historia» en un edificio con un capítulo nuevo para contar.
class _StoryTag extends StatelessWidget {
  const _StoryTag();

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 2),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: Palette.gold,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.auto_stories_rounded, size: 12, color: Palette.onColor),
        const SizedBox(width: 3),
        Text(
          AppLocalizations.of(context).storyNew,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: Palette.onColor,
          ),
        ),
      ],
    ),
  );
}

/// La historia de quien cuida el edificio: cuántos capítulos contó y el
/// botón para escuchar el próximo (o qué le falta).
class _StoryPanel extends ConsumerWidget {
  const _StoryPanel({
    required this.thread,
    required this.who,
    required this.color,
    required this.onListen,
  });

  final String thread;
  final String who;
  final Color color;
  final VoidCallback onListen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final lore = ref.watch(loreProvider).value ?? const <String>{};
    final wait = ref.watch(schoolStoryProvider).value?[thread];
    if (wait == null) return const SizedBox.shrink();
    final n = schoolChapterOf(lore, thread);
    final status = switch (wait) {
      StoryWait.none => null,
      StoryWait.done => t.storyDone,
      StoryWait.ascent => t.storyWaitAscent,
      StoryWait.level => t.storyWaitLevel(schoolChapterLevel[n]),
      StoryWait.summit => t.storyWaitSummit,
    };
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_rounded, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  t.storyTitle(who),
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Text(
                t.storyCount(n, schoolChapters),
                style: const TextStyle(fontSize: 12, color: Palette.textDim),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (status == null)
            FilledButton.icon(
              onPressed: onListen,
              icon: const Icon(Icons.record_voice_over_rounded),
              label: Text(t.storyListen(who)),
            )
          else
            Text(
              status,
              style: const TextStyle(fontSize: 13, color: Palette.textDim),
            ),
        ],
      ),
    );
  }
}

/// Desenrolla el capítulo [id] de un hilo de la escuela.
Future<void> showStoryChapter(BuildContext context, String id) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.bg,
      isScrollControlled: true,
      builder: (ctx) => ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(ctx).height * 0.92,
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: 1),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) =>
                        LoreScroll(id: id, fresh: true, open: v),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                child: SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(AppLocalizations.of(ctx).introOk),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
