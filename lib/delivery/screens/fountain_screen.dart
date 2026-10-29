import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/scene_backdrop.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/juice.dart';
import '../widgets/press.dart';
import '../feel.dart';
import '../widgets/node_kit.dart';

enum _Mode { choose, remove, upgrade }

class FountainScreen extends ConsumerStatefulWidget {
  const FountainScreen({super.key});

  @override
  ConsumerState<FountainScreen> createState() => _FountainScreenState();
}

class _FountainScreenState extends ConsumerState<FountainScreen> {
  _Mode _mode = _Mode.choose;

  /// Vida antes de curarse: la nueva se cuenta hacia arriba desde acá.
  int? _healedFrom;
  int _burst = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final ctl = ref.read(runControllerProvider.notifier);

    void done() => context.go('/map');

    if (_mode != _Mode.choose) {
      return DeckPickScreen(
        title: _mode == _Mode.remove
            ? t.fountainRemove
            : t.fountainUpgrade(data.balance.fountainUpgrade),
        cards: run.deck,
        enabled: _mode == _Mode.upgrade ? engine.canUpgrade : null,
        fx: _mode == _Mode.remove ? DeckPick.remove : DeckPick.upgrade,
        onBack: () => setState(() => _mode = _Mode.choose),
        onPick: (c) {
          _mode == _Mode.remove ? ctl.removeCard(c.uid) : ctl.upgradeCard(c.uid);
          done();
        },
      );
    }

    void pickMode(_Mode m) {
      Haptics.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
      setState(() => _mode = m);
    }

    Widget option(int i, IconData icon, String label, VoidCallback onTap) =>
        StaggerIn(
      index: i,
      delay: const Duration(milliseconds: 300),
      child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ChoiceTile(leading: icon, title: label, onTap: onTap),
      ),
    );

    return Scaffold(
      body: SceneBackdrop(
        assets: stageArt(data.balance.stages[run.stage].id, 'fountain_bg.webp'),
        veil: 0.38,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 140,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    Bounce(
                      trigger: _burst,
                      scale: 1.2,
                      child: const Text(
                        '泉',
                        style: TextStyle(fontSize: 96, color: Palette.sky),
                      ),
                    ),
                    Positioned.fill(
                      child: InkBurst(
                        trigger: _burst,
                        colors: const [Palette.sky, Palette.jade, Colors.white],
                        count: 26,
                        radius: 130,
                        duration: const Duration(milliseconds: 900),
                      ),
                    ),
                  ],
                ),
              ),
              Text(t.fountain, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  TweenAnimationBuilder<double>(
                    tween: Tween(
                      begin: (_healedFrom ?? run.hp).toDouble(),
                      end: run.hp.toDouble(),
                    ),
                    duration: const Duration(milliseconds: 700),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => Text(
                      '${t.life}: ${v.round()}/${run.maxHp}',
                      style: TextStyle(
                        color: _healedFrom == null
                            ? Palette.textDim
                            : Palette.jade,
                        fontWeight: _healedFrom == null
                            ? null
                            : FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_healedFrom != null && run.hp > _healedFrom!)
                    Positioned(
                      top: -8,
                      child: PopText(
                        text: '+${run.hp - _healedFrom!}',
                        color: Palette.jade,
                        size: 26,
                      ),
                    ),
                ],
              ),
              const Spacer(),
              option(
                0,
                Icons.favorite,
                t.fountainHeal(engine.healOf(run)),
                () {
                  if (_healedFrom != null) return;
                  Haptics.mediumImpact();
                  ref.read(audioProvider).play(Sfx.fountainHeal);
                  setState(() {
                    _healedFrom = run.hp;
                    _burst++;
                  });
                  ctl.heal();
                  Future.delayed(const Duration(milliseconds: 1100), () {
                    if (context.mounted) done();
                  });
                },
              ),
              option(
                1,
                Icons.delete_outline,
                t.fountainRemove,
                () => pickMode(_Mode.remove),
              ),
              option(
                2,
                Icons.upgrade,
                t.fountainUpgrade(data.balance.fountainUpgrade),
                () => pickMode(_Mode.upgrade),
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
