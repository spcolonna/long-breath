import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/combat_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../foe_name.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/breather_sheet.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/lotus.dart';
import '../widgets/press.dart';
import '../widgets/paper_panel.dart';
import '../widgets/scene_backdrop.dart';

/// Estancia: se ganó una sala y espera la siguiente. No se vuelve al mapa;
/// se elige la tregua (reponerse ahora, o entrar concentrado o con los
/// puños afilados) y se sigue. Al final de la última sala, el cofre.
class StayScreen extends ConsumerWidget {
  const StayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null || run.currentNode == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final stay = run.node(run.currentNode!).stay;
    final done = run.roomStep + 1;
    final total = stay.length;
    if (done >= total) return const SizedBox();
    final next = stay[done];
    final last = done == total - 1;
    final cfg = data.balance.breather;

    void go(Breather b) {
      Haptics.mediumImpact();
      ref.read(audioProvider).play(Sfx.fightStart);
      ref.read(runControllerProvider.notifier).roomContinue(b);
      ref.read(combatControllerProvider.notifier).start();
      context.go('/combat');
    }

    String hint(Breather b) => switch (b) {
      Breather.rest => t.breatherRestHint(engine.restHeal(run)),
      Breather.focus => t.stayFocusHint(cfg.draw, cfg.breath),
      Breather.fist => t.stayFistHint(cfg.fist),
    };

    final name = ref.foe(context, next.enemy);
    return Scaffold(
      body: SceneBackdrop(
        assets: stageArt(data.balance.stages[run.stage].id, 'map_bg.webp'),
        veil: 0.38,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, box) => SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: box.maxHeight - 36),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    StaggerIn(
                      index: 0,
                      child: _Progress(done: done, total: total),
                    ),
                    const SizedBox(height: 6),
                    StaggerIn(
                      index: 1,
                      child: SizedBox(
                        height: 150,
                        child: Center(
                          child: EnemySprite(
                            def: data.enemy(next.enemy),
                            staggered: false,
                            hitKey: 0,
                            attackKey: 0,
                            size: 140,
                          ),
                        ),
                      ),
                    ),
                    StaggerIn(
                      index: 2,
                      child: PaperPanel(
                        padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              t.stayTitle,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: Palette.text,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              t.stayProgress(done, total),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Palette.text,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              last ? t.stayNextLast(name) : t.stayNext(name),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Palette.text,
                              ),
                            ),
                            if (next.waves.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              Text(
                                t.nodeHintPack(next.foes.length),
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Palette.text,
                                ),
                              ),
                            ],
                            const SizedBox(height: 4),
                            Text(
                              t.stayHp(run.hp, run.maxHp),
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
                    const SizedBox(height: 14),
                    StaggerIn(
                      index: 3,
                      delay: const Duration(milliseconds: 200),
                      child: Text(
                        t.stayPick,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Palette.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    for (final (i, b) in Breather.values.indexed)
                      StaggerIn(
                        index: 4 + i,
                        delay: const Duration(milliseconds: 250),
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: PaperPanel(
                            padding: EdgeInsets.zero,
                            child: BreatherOption(
                              key: ValueKey(b),
                              hanzi: BreatherSheet.hanziOf(b),
                              color: BreatherSheet.colorOf(b),
                              title: BreatherSheet.titleOf(t, b),
                              hint: hint(b),
                              onTap: () => go(b),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Las salas de la estancia como sellos: las ganadas con 破, las que faltan
/// apagadas y, al final, el cofre 宝.
class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total});

  final int done;
  final int total;

  @override
  Widget build(BuildContext context) => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 6,
    runSpacing: 6,
    children: [
      for (var i = 0; i < total; i++)
        InkSeal(
          hanzi: i < done ? '破' : '门',
          color: i < done ? Palette.lacquer : Palette.textDim,
          size: 36,
          dim: i >= done,
        ),
      const InkSeal(hanzi: '宝', color: Palette.gold, size: 42),
    ],
  );
}
