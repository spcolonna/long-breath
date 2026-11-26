import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/ascent.dart';
import '../../domain/run/true_summit.dart';
import '../../infrastructure/progress_storage.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../feel.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/lotus.dart';
import '../widgets/mastery_view.dart';
import '../widgets/press.dart';
import '../widgets/difficulty_sheet.dart' show picoColor;
import '../widgets/scroll_panel.dart';
import '../widgets/system_intro.dart';

/// Una parte del progreso de la partida: cuánto lleva y cuánto pide.
class ProgressPart {
  const ProgressPart(this.have, this.max);

  final int have;
  final int max;

  double get fraction => max <= 0 ? 0 : (have / max).clamp(0, 1).toDouble();
}

/// Todo lo que se puede completar en la partida, de un vistazo.
typedef ProgressSummary = ({
  ProgressPart realm,
  ProgressPart meridians,
  ProgressPart school,
  ProgressPart mastery,
  ProgressPart summits,
  ProgressPart picos,
  ProgressPart story,
});

/// Promedio de las partes, en porcentaje entero.
int progressPercent(ProgressSummary p) {
  final parts = [
    p.realm,
    p.meridians,
    p.school,
    p.mastery,
    p.summits,
    p.picos,
    p.story,
  ];
  final sum = parts.fold(0.0, (a, x) => a + x.fraction);
  return (sum / parts.length * 100).floor();
}

final progressSummaryProvider = FutureProvider<ProgressSummary>((ref) async {
  final balance = ref.watch(dataProvider).balance;
  final c = await ref.watch(cultivationProvider.future);
  final m = await ref.watch(meridianProvider.future);
  final s = await ref.watch(schoolProvider.future);
  final xp = await ref.watch(masteryProvider.future);
  final lore = await ref.watch(loreProvider.future);
  final pico = await ref.watch(picoUnlockedProvider.future);
  final mastery = balance.mastery;
  return (
    realm: ProgressPart(c.realm, c.def.realms.length - 1),
    meridians: ProgressPart(
      balance.meridians.ownedCount(m.owned),
      balance.meridians.maxOwned,
    ),
    school: ProgressPart(
      balance.school.restored(s.levels),
      balance.school.maxLevels,
    ),
    mastery: ProgressPart(
      Style.values.fold(0, (a, st) => a + mastery.levelOf(xp[st] ?? 0)),
      mastery.maxLevel * Style.values.length,
    ),
    summits: ProgressPart(
      Style.values.where((st) => lore.contains(endingOf(st))).length,
      Style.values.length,
    ),
    picos: ProgressPart(pico, ProgressStorage.maxPico),
    story: ProgressPart(
      loreOrder.where(lore.contains).length,
      loreOrder.length,
    ),
  );
});

/// 进度: cuánto creció la escuela y cuánto falta, con acceso a cada parte.
class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) showSystemIntro(context, ref, SystemIntro.progress);
    });
  }

  void _go(VoidCallback f) {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    f();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = ref.watch(progressSummaryProvider).value;
    final c = ref.watch(cultivationProvider).value;
    final xp = ref.watch(masteryProvider).value ?? const {};
    final balance = ref.watch(dataProvider).balance;
    final text = ref.watch(textProvider);
    final lore = ref.watch(loreProvider).value ?? const <String>{};
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.go('/school')),
        title: Text(t.progressTitle),
        actions: const [IntroHelpButton(intro: SystemIntro.progress)],
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: Palette.backdrop),
        child: p == null || c == null
            ? const SizedBox.expand()
            : SafeArea(
                child: ScrollPanel(
                  margin: const EdgeInsets.fromLTRB(10, 4, 10, 12),
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(12, 16, 12, 20),
                    children: [
                      _Total(percent: progressPercent(p)),
                      const SizedBox(height: 14),
                      _PartCard(
                        index: 0,
                        hanzi: '境',
                        color: Palette.blossom,
                        title: t.progressRealm,
                        subtitle: t.progressRealmSub(
                          text.realm(c.def.realms[c.realm].id),
                          c.realm + 1,
                          c.def.realms.length,
                        ),
                        part: p.realm,
                      ),
                      _PartCard(
                        index: 1,
                        hanzi: '经',
                        color: Palette.jade,
                        title: t.meridiansTitle,
                        subtitle: t.progressMeridiansSub(
                          p.meridians.have,
                          p.meridians.max,
                        ),
                        part: p.meridians,
                        onTap: () => _go(() => context.go('/meridians')),
                      ),
                      _PartCard(
                        index: 2,
                        hanzi: '寺',
                        color: Palette.lacquer,
                        title: t.schoolTitle,
                        subtitle: t.schoolProgress(p.school.have, p.school.max),
                        part: p.school,
                        onTap: () => _go(() => context.go('/monastery')),
                      ),
                      _PartCard(
                        index: 3,
                        hanzi: '道',
                        color: Palette.gold,
                        title: t.masteryTitle,
                        subtitle: t.progressMasterySub(
                          p.mastery.have,
                          p.mastery.max,
                        ),
                        part: p.mastery,
                        trailing: [
                          for (final s in Style.values)
                            _PathChip(
                              hanzi: balance.statsOf(s).hanzi,
                              color: styleColor(s),
                              label: '${balance.mastery.levelOf(xp[s] ?? 0)}',
                              on: balance.mastery.levelOf(xp[s] ?? 0) > 0,
                            ),
                        ],
                        onTap: () => _go(() => showMasterySheet(context)),
                      ),
                      _PartCard(
                        index: 4,
                        hanzi: '峰',
                        color: Palette.sky,
                        title: t.progressSummits,
                        subtitle: t.progressSummitsSub(
                          p.summits.have,
                          p.summits.max,
                        ),
                        part: p.summits,
                        trailing: [
                          for (final s in Style.values)
                            _PathChip(
                              hanzi: balance.statsOf(s).hanzi,
                              color: styleColor(s),
                              on: lore.contains(endingOf(s)),
                            ),
                        ],
                      ),
                      _PartCard(
                        index: 5,
                        hanzi: '巅',
                        color: picoColor,
                        title: t.progressPicos,
                        subtitle: p.picos.have == 0
                            ? t.progressPicosNone
                            : t.progressPicosSub(p.picos.have, p.picos.max),
                        part: p.picos,
                      ),
                      _PartCard(
                        index: 6,
                        hanzi: '卷',
                        color: Palette.structure,
                        title: t.progressStory,
                        subtitle: t.progressStorySub(p.story.have, p.story.max),
                        part: p.story,
                        onTap: () => _go(() => context.go('/registry')),
                      ),
                      _TrueSummitCard(lore: lore),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

/// 真: el final verdadero, con lo que pide (los tres finales, el Pico 5 y
/// la escuela entera). No suma al porcentaje: es la meta de todo lo demás.
class _TrueSummitCard extends ConsumerWidget {
  const _TrueSummitCard({required this.lore});

  final Set<String> lore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final pico = ref.watch(picoUnlockedProvider).value ?? 0;
    final school = ref.watch(schoolProvider).value;
    final def = ref.watch(dataProvider).balance.school;
    final seen = lore.contains(trueEndingLore);
    final p = trueSummitParts(
      lore: lore,
      picoUnlocked: pico,
      schoolDone: school != null && def.isComplete(school.levels),
    );
    final met = [p.endings, p.pico, p.school].where((x) => x).length;
    return _PartCard(
      index: 7,
      hanzi: '真',
      color: Palette.gold,
      title: t.progressTrue,
      subtitle: seen
          ? t.progressTrueDone
          : met == 3
          ? t.progressTrueReady
          : t.progressTrueSub(trueSummitPico),
      part: ProgressPart(seen ? 3 : met, 3),
      trailing: [
        _PathChip(hanzi: '峰', color: Palette.sky, on: seen || p.endings),
        _PathChip(hanzi: '巅', color: picoColor, on: seen || p.pico),
        _PathChip(hanzi: '寺', color: Palette.jade, on: seen || p.school),
      ],
    );
  }
}

/// El porcentaje total en un anillo que se llena al entrar.
class _Total extends StatelessWidget {
  const _Total({required this.percent});

  final int percent;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: percent / 100),
      duration: calm(context)
          ? Duration.zero
          : const Duration(milliseconds: 1100),
      curve: Curves.easeOutCubic,
      builder: (_, v, _) => Column(
        children: [
          SizedBox(
            width: 112,
            height: 112,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox.expand(
                  child: CircularProgressIndicator(
                    value: v,
                    strokeWidth: 8,
                    strokeCap: StrokeCap.round,
                    color: Palette.gold,
                    backgroundColor: Palette.gold.withValues(alpha: 0.15),
                  ),
                ),
                Text(
                  '${(v * 100).round()}%',
                  style: const TextStyle(
                    fontSize: 30,
                    fontFamily: Fonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 6),
          Text(
            t.progressTotal(percent),
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Palette.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.index,
    required this.hanzi,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.part,
    this.trailing = const [],
    this.onTap,
  });

  final int index;
  final String hanzi;
  final Color color;
  final String title;
  final String subtitle;
  final ProgressPart part;
  final List<Widget> trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final done = part.max > 0 && part.have >= part.max;
    final card = Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 12, 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: done ? 0.12 : 0.05),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: done ? 0.9 : 0.45),
          width: done ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          InkSeal(hanzi: hanzi, color: color, size: 40, dim: part.have == 0),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    ...trailing,
                  ],
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12.5,
                    height: 1.25,
                    color: Palette.textDim,
                  ),
                ),
                const SizedBox(height: 6),
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0, end: part.fraction),
                  duration: calm(context)
                      ? Duration.zero
                      : Duration(milliseconds: 700 + 90 * index),
                  curve: Curves.easeOutCubic,
                  builder: (_, v, _) => ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: v,
                      minHeight: 6,
                      color: color,
                      backgroundColor: color.withValues(alpha: 0.15),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (onTap != null)
            const Padding(
              padding: EdgeInsets.only(left: 4),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 20,
                color: Palette.textDim,
              ),
            ),
        ],
      ),
    );
    return StaggerIn(
      index: index,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: onTap == null
            ? Semantics(label: '$title. $subtitle', child: card)
            : Press(
                child: Semantics(
                  button: true,
                  label: '$title. $subtitle',
                  child: Material(
                    type: MaterialType.transparency,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(14),
                      onTap: onTap,
                      child: card,
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

/// Hanzi de un camino, de color si ya cuenta (con un número opcional).
class _PathChip extends StatelessWidget {
  const _PathChip({
    required this.hanzi,
    required this.color,
    required this.on,
    this.label,
  });

  final String hanzi;
  final Color color;
  final bool on;
  final String? label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(left: 6),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          hanzi,
          style: TextStyle(
            fontSize: 16,
            fontFamily: Fonts.display,
            color: on ? color : Palette.line,
          ),
        ),
        if (label != null)
          Text(
            label!,
            style: TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: on ? Palette.text : Palette.textDim,
            ),
          ),
      ],
    ),
  );
}
