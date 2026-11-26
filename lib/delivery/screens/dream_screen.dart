import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/cloud_drift.dart';
import '../widgets/lotus.dart';
import '../widgets/press.dart';

/// 梦: el final verdadero. El Dragón Dormido se calma y su sueño se levanta
/// con la forma del Primer Discípulo; el caldo de Ming cura todo y la hoja
/// de Tie zumba (si se escucharon sus últimos capítulos).
class DreamScreen extends ConsumerWidget {
  const DreamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    final lore = ref.watch(loreProvider).value ?? const <String>{};
    final still = calm(context);
    final lines = [
      t.dreamCalm,
      lore.contains('ming_5') ? t.dreamBroth : t.dreamBreath,
      if (lore.contains('tie_5')) t.dreamBlade,
    ];

    void go() {
      Haptics.heavyImpact();
      ref.read(audioProvider).play(Sfx.fightStart);
      ref.read(combatControllerProvider.notifier).start();
      context.go('/combat');
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          const DecoratedBox(
            decoration: BoxDecoration(gradient: Palette.backdrop),
          ),
          const CloudDrift(seed: 9),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: Column(
                children: [
                  Text(
                    t.dreamTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 26,
                      fontFamily: Fonts.display,
                    ),
                  ),
                  Expanded(
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: still ? 1 : 0, end: 1),
                      duration: const Duration(milliseconds: 1600),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, child) => Opacity(
                        opacity: v,
                        child: Transform.translate(
                          offset: Offset(0, 24 * (1 - v)),
                          child: child,
                        ),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // Un halo dorado: es aliento, no cuerpo.
                          DecoratedBox(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Palette.gold.withValues(alpha: 0.35),
                                  blurRadius: 60,
                                  spreadRadius: 10,
                                ),
                              ],
                            ),
                            child: const SizedBox(width: 160, height: 160),
                          ),
                          Opacity(
                            opacity: 0.85,
                            child: Image.asset(
                              'assets/art/enemies/first_disciple.webp',
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => const SizedBox(),
                            ),
                          ),
                          const Positioned(
                            right: 8,
                            bottom: 8,
                            child: InkSeal(
                              hanzi: '初',
                              color: Palette.gold,
                              size: 52,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  for (final (i, line) in lines.indexed)
                    StaggerIn(
                      index: i + 1,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          line,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.35,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ),
                  if (run != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      '${run.hp}/${run.maxHp}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Palette.jade,
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton.icon(
                      onPressed: run?.dreamFight == true ? go : null,
                      icon: const Icon(Icons.sports_martial_arts_rounded),
                      label: Text(t.dreamGo),
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
