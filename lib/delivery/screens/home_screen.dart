import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/hero_sprite.dart';

String routeFor(RunState r) => switch (r.phase) {
      RunPhase.map => '/map',
      RunPhase.combat => '/map',
      RunPhase.reward => '/reward',
      RunPhase.fountain => '/fountain',
      RunPhase.shrine => '/shrine',
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
    final trained = ref.watch(tutorialDoneProvider).value ?? true;
    void newRun() {
      ref.read(runControllerProvider.notifier).newRun();
      context.go('/map');
    }

    void train() {
      ref.read(combatControllerProvider.notifier).startTutorial();
      context.go('/combat');
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const Align(alignment: Alignment.centerRight, child: _AudioToggles()),
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('龙 ',
                        style: TextStyle(fontSize: 30, color: Palette.lacquer, height: 1)),
                    Text('LONG BREATH',
                        style: TextStyle(
                            fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w300)),
                    Text('  长息', style: TextStyle(fontSize: 13, color: Palette.textDim)),
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
              Text(t.homeTagline,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      fontSize: 15, fontStyle: FontStyle.italic, color: Palette.text)),
              const SizedBox(height: 2),
              Text(t.styleSummary(stats.draw, stats.breath, stats.retain),
                  style: const TextStyle(fontSize: 12, color: Palette.textDim)),
              const SizedBox(height: 24),
              // La primera vez se propone el entrenamiento antes que la run.
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: trained ? newRun : train,
                  child: Text(trained ? t.newRun : t.tutStart,
                      style: const TextStyle(fontSize: 17)),
                ),
              ),
              if (saved != null &&
                  saved.phase != RunPhase.victory &&
                  saved.phase != RunPhase.defeat) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      // Un combate a medias se reinicia desde el mapa.
                      final r = saved.phase == RunPhase.combat
                          ? saved.copyWith(
                              phase: RunPhase.map,
                              visited: saved.visited
                                  .sublist(0, saved.visited.length - 1),
                              currentNode: saved.visited.length > 1
                                  ? saved.visited[saved.visited.length - 2]
                                  : null,
                            )
                          : saved;
                      ref.read(runControllerProvider.notifier).resume(r);
                      context.go(routeFor(r));
                    },
                    child: Text(t.continueRun),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              TextButton(
                onPressed: trained ? train : newRun,
                child: Text(trained ? t.tutReplay : t.tutSkipToRun,
                    style: const TextStyle(color: Palette.textDim)),
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
    Widget toggle(bool on, IconData onIcon, IconData offIcon, String tip,
            Future<void> Function(bool) set) =>
        IconButton(
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
        toggle(audio.sfxOn, Icons.volume_up_rounded, Icons.volume_off_rounded,
            t.soundEffects, audio.setSfxOn),
        toggle(audio.musicOn, Icons.music_note_rounded, Icons.music_off_rounded,
            t.music, audio.setMusicOn),
      ],
    );
  }
}
