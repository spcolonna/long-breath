import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../foe_name.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/lotus.dart';
import '../widgets/node_kit.dart';
import '../widgets/paper_panel.dart';
import '../widgets/press.dart';
import '../widgets/scene_backdrop.dart';

/// Paso de montaña: se venció a uno de la cadena. Arriba espera el
/// siguiente; se sigue (sin curarse, por más botín) o se vuelve al mapa con
/// lo ganado.
class PassScreen extends ConsumerWidget {
  const PassScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null || run.currentNode == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final chain = engine.passChain(run.node(run.currentNode!));
    final done = run.passStep + 1;
    final total = chain.length;
    final next = chain[done];
    final last = done == total - 1;
    final jade = engine.passBonus(run, done);

    void go() {
      Haptics.mediumImpact();
      ref.read(audioProvider).play(Sfx.fightStart);
      ref.read(runControllerProvider.notifier).passContinue();
      ref.read(combatControllerProvider.notifier).start();
      context.go('/combat');
    }

    void leave() {
      Haptics.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
      ref.read(runControllerProvider.notifier).passRetreat();
      context.go('/map');
    }

    return Scaffold(
      body: SceneBackdrop(
        assets: stageArt(data.balance.stages[run.stage].id, 'map_bg.webp'),
        veil: 0.38,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                StaggerIn(
                  index: 0,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < total; i++)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5),
                          child: InkSeal(
                            hanzi: i < done ? '破' : '隘',
                            color: i < done ? Palette.lacquer : Palette.textDim,
                            size: 40,
                            dim: i >= done,
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                StaggerIn(
                  index: 1,
                  child: SizedBox(
                    height: 190,
                    child: Center(
                      child: EnemySprite(
                        def: data.enemy(next),
                        staggered: false,
                        hitKey: 0,
                        attackKey: 0,
                        size: 180,
                      ),
                    ),
                  ),
                ),
                StaggerIn(
                  index: 2,
                  child: PaperPanel(
                    padding: const EdgeInsets.fromLTRB(20, 12, 20, 14),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          t.passTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: Palette.text,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          t.passProgress(done, total),
                          style: const TextStyle(
                            fontSize: 14,
                            color: Palette.text,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.passNext(ref.foe(context, next)),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Palette.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          last ? t.passLootLast(jade) : t.passLoot(jade),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.text,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          t.passHp(run.hp, run.maxHp),
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: run.hp * 2 < run.maxHp
                                ? Palette.lacquer
                                : Palette.jade,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                StaggerIn(
                  index: 3,
                  delay: const Duration(milliseconds: 250),
                  child: ChoiceTile(
                    leading: Icons.terrain_rounded,
                    title: t.passGo,
                    accent: Palette.lacquer,
                    onTap: go,
                  ),
                ),
                const SizedBox(height: 10),
                StaggerIn(
                  index: 4,
                  delay: const Duration(milliseconds: 250),
                  child: ChoiceTile(
                    leading: Icons.map_outlined,
                    title: t.passLeave,
                    onTap: leave,
                  ),
                ),
                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
