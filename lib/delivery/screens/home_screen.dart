import 'dart:math' as math;

import 'package:flutter/material.dart';
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
import '../widgets/press.dart';
import '../widgets/scene_backdrop.dart';
import '../feel.dart';
import '../widgets/options_sheet.dart';

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
  /// La primera vez que se abre la app, la portada entra despacio, pieza por
  /// pieza; al volver desde otra pantalla, ligero.
  static bool _introShown = false;
  late final bool _intro = !_introShown;

  @override
  void initState() {
    super.initState();
    _introShown = true;
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
      Haptics.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
    }

    Widget enter(int i, Widget child, {double scaleFrom = 1}) => StaggerIn(
      index: i,
      step: Duration(milliseconds: _intro ? 170 : 45),
      delay: Duration(milliseconds: _intro ? 250 : 0),
      scaleFrom: scaleFrom,
      child: child,
    );

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
                  child: OptionsButton(),
                ),
                // El sello pintado del dragón; si faltara, el carácter.
                enter(
                  0,
                  scaleFrom: _intro ? 1.35 : 1,
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
                ),
                const SizedBox(height: 4),
                enter(
                  1,
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
                          style: TextStyle(
                            fontSize: 13,
                            color: Palette.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // El héroe empieza de lino crudo: el camino se elige en la montaña.
                Expanded(
                  child: LayoutBuilder(
                    builder: (context, box) => enter(
                      2,
                      HeroSprite(
                        style: null,
                        height: math.min(box.maxHeight, box.maxWidth * 1.3),
                        glyph: stats.hanzi,
                      ),
                    ),
                  ),
                ),
                enter(
                  3,
                  Text(
                    t.homeTagline,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      fontStyle: FontStyle.italic,
                      color: Palette.text,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                enter(
                  4,
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
                ),
                const SizedBox(height: 12),
                enter(
                  5,
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
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
