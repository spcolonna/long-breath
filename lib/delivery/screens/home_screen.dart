import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../providers.dart';
import '../theme.dart';
import '../tutorial/lessons.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/menu_button.dart';
import '../widgets/scene_backdrop.dart';

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

/// Menú principal, común a las tres partidas: aprender y jugar.
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
    final stats = ref.watch(dataProvider).balance.novice;
    final done = ref.watch(lessonsDoneProvider).value ?? const <String>{};
    final slots = ref.watch(slotsProvider).value ?? const {};
    final fresh = done.isEmpty;

    void tap() {
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
    }

    return Scaffold(
      // Montañas al amanecer con el dragón de nubes arriba; el centro queda
      // libre para el héroe y los botones.
      body: SceneBackdrop(
        assets: const ['assets/art/ui/title_bg.webp'],
        veil: 0.3,
        alignment: Alignment.topCenter,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              children: [
                const Align(
                  alignment: Alignment.centerRight,
                  child: AudioToggles(),
                ),
                // El sello pintado del dragón; si faltara, el carácter.
                Image.asset(
                  'assets/art/ui/logo.webp',
                  height: 88,
                  errorBuilder: (_, _, _) => const Text(
                    '龙',
                    style: TextStyle(
                      fontSize: 44,
                      color: Palette.lacquer,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                const FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
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
                const SizedBox(height: 14),
                MenuButton(
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
                MenuButton(
                  icon: Icons.landscape_rounded,
                  title: t.menuPlay,
                  subtitle: t.menuPlaySubtitle(slots.length),
                  primary: !fresh,
                  onTap: () {
                    tap();
                    context.go('/slots');
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
