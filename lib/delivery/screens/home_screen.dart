import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../tutorial/lessons.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/npc_portrait.dart';
import '../../infrastructure/progress_storage.dart';
import '../../domain/model/enums.dart';

String routeFor(RunState r) => switch (r.phase) {
  RunPhase.map => '/map',
  RunPhase.combat => '/map',
  RunPhase.talisman => '/talisman',
  RunPhase.reward => '/reward',
  RunPhase.event => '/event',
  RunPhase.merchant => '/merchant',
  RunPhase.master => '/master',
  RunPhase.fountain => '/fountain',
  RunPhase.shrine => '/shrine',
  RunPhase.stageClear => '/stage',
  RunPhase.victory || RunPhase.defeat => '/result',
};

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(audioProvider).music(Music.menu);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final saved = ref.watch(savedRunProvider).value;
    final stats = ref.watch(dataProvider).balance.novice;
    final done = ref.watch(lessonsDoneProvider).value ?? const <String>{};
    final fresh = done.isEmpty;
    final resumable =
        saved != null &&
        saved.phase != RunPhase.victory &&
        saved.phase != RunPhase.defeat;

    void tap() {
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
    }

    Future<void> climb() async {
      tap();
      if (resumable) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.menuReplaceRunTitle),
            content: Text(t.menuReplaceRunBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.cancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.menuReplaceRunOk),
              ),
            ],
          ),
        );
        if (ok != true || !context.mounted) return;
      }
      // La primera vez, antes de subir, la escuela cuenta por qué se sube.
      final lore = await ref.read(loreProvider.future);
      if (!context.mounted) return;
      if (!lore.contains('prologue')) {
        if (!context.mounted) return;
        final go = await _prologue(context);
        if (go != true || !context.mounted) return;
        await ref.read(progressStorageProvider).unlockLore('prologue');
        ref.invalidate(loreProvider);
        if (!context.mounted) return;
      }
      final choice = await pickDifficulty(
        context,
        initial: saved?.difficulty ?? Difficulty.normal,
        initialPico: saved?.pico ?? 0,
      );
      if (choice == null || !context.mounted) return;
      ref
          .read(runControllerProvider.notifier)
          .newRun(choice.difficulty, pico: choice.pico);
      context.go('/map');
    }

    void resume() {
      tap();
      // Un combate a medias se reinicia desde el mapa.
      final r = ref.read(runEngineProvider).retreat(saved!);
      ref.read(runControllerProvider.notifier).resume(r);
      context.go(routeFor(r));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const Align(
                alignment: Alignment.centerRight,
                child: _AudioToggles(),
              ),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '龙 ',
                      style: TextStyle(
                        fontSize: 30,
                        color: Palette.lacquer,
                        height: 1,
                      ),
                    ),
                    Text(
                      'LONG BREATH',
                      style: TextStyle(
                        fontSize: 22,
                        letterSpacing: 6,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Text(
                      '  长息',
                      style: TextStyle(fontSize: 13, color: Palette.textDim),
                    ),
                  ],
                ),
              ),
              // El héroe empieza de lino crudo: el camino se elige en la montaña.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => HeroSprite(
                    style: null,
                    height: math.min(box.maxHeight, box.maxWidth * 1.3),
                    glyph: stats.hanzi,
                  ),
                ),
              ),
              Text(
                t.homeTagline,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontStyle: FontStyle.italic,
                  color: Palette.text,
                ),
              ),
              const SizedBox(height: 8),
              const _SchoolLine(),
              const SizedBox(height: 14),
              _MenuButton(
                icon: Icons.school_rounded,
                title: t.menuLearn,
                subtitle: t.menuLearnProgress(done.length, lessons.length),
                badge: fresh ? t.menuStartHere : null,
                primary: fresh,
                onTap: () {
                  tap();
                  context.go('/lessons');
                },
              ),
              const SizedBox(height: 12),
              _MenuButton(
                icon: Icons.landscape_rounded,
                title: t.menuClimb,
                subtitle: t.menuClimbSubtitle,
                primary: !fresh && !resumable,
                onTap: climb,
              ),
              if (resumable) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: resume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      t.continueRun,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Quién sube ahora y, si ya hubo subidas, el registro de la escuela.
class _SchoolLine extends ConsumerWidget {
  const _SchoolLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final n = ref.watch(discipleProvider).value;
    final ascents = ref.watch(ascentsProvider).value ?? const [];
    if (n == null) return const SizedBox(height: 32);
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.gold.withValues(alpha: 0.6)),
              ),
              child: Text(
                t.discipleN(n),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Palette.gold,
                ),
              ),
            ),
            if (ascents.isNotEmpty) ...[
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/registry');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '名册 ',
                        style: TextStyle(fontSize: 13, color: Palette.lacquer),
                      ),
                      Text(
                        t.registryTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Palette.lacquer,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Palette.lacquer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La primera subida empieza con el prólogo: un pergamino y "Subir".
Future<bool?> _prologue(BuildContext context) => showModalBottomSheet<bool>(
  context: context,
  backgroundColor: Palette.bg,
  isScrollControlled: true,
  builder: (ctx) {
    final t = AppLocalizations.of(ctx);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // El maestro de la escuela despide al novicio.
            NpcPortrait(
              asset: 'assets/art/npc/master.png',
              color: Palette.gold,
              height: 180,
              badge: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Palette.lacquer.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '师',
                  style: TextStyle(
                    fontSize: 30,
                    color: Palette.onColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LoreScroll(id: 'prologue', open: v),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.prologueClimb),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

/// Botón grande del menú, con ícono, subtítulo y una marca opcional.
class _MenuButton extends StatelessWidget {
  const _MenuButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Palette.onColor : Palette.text;
    return Material(
      color: primary ? Palette.lacquer : Palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: primary ? Palette.lacquer : Palette.line,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                color: primary ? Palette.onColor : Palette.lacquer,
                size: 30,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: fg,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: fg.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Palette.gold,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badge!,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w800,
                      color: Palette.onColor,
                    ),
                  ),
                ),
              Icon(
                Icons.chevron_right_rounded,
                color: fg.withValues(alpha: 0.7),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Interruptores de efectos y música; se recuerdan entre sesiones.
class _AudioToggles extends ConsumerStatefulWidget {
  const _AudioToggles();

  @override
  ConsumerState<_AudioToggles> createState() => _AudioTogglesState();
}

class _AudioTogglesState extends ConsumerState<_AudioToggles> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final audio = ref.watch(audioProvider);
    Widget toggle(
      bool on,
      IconData onIcon,
      IconData offIcon,
      String tip,
      Future<void> Function(bool) set,
    ) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      color: on ? Palette.text : Palette.textDim,
      icon: Icon(on ? onIcon : offIcon, size: 22),
      onPressed: () async {
        await set(!on);
        if (!on) audio.play(Sfx.uiButton);
        setState(() {});
      },
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        toggle(
          audio.sfxOn,
          Icons.volume_up_rounded,
          Icons.volume_off_rounded,
          t.soundEffects,
          audio.setSfxOn,
        ),
        toggle(
          audio.musicOn,
          Icons.music_note_rounded,
          Icons.music_off_rounded,
          t.music,
          audio.setMusicOn,
        ),
      ],
    );
  }
}
