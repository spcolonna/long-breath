import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/paper_panel.dart';
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

  /// Cartas ya elegidas para templar (la fuente templa varias de una vez).
  final List<int> _tempered = [];

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final ctl = ref.read(runControllerProvider.notifier);

    void done() => context.go('/map');

    final temper = engine.fountainTemperOf(run);
    final removeMaxHp = data.balance.fountainRemoveMaxHp;

    if (_mode != _Mode.choose) {
      final upgrading = _mode == _Mode.upgrade;
      return DeckPickScreen(
        key: ValueKey('pick-${_tempered.length}'),
        title: upgrading
            ? t.fountainUpgradePick(_tempered.length + 1, temper)
            : t.fountainRemove(removeMaxHp),
        hint: upgrading ? null : t.fountainRemovePick,
        cards: run.deck,
        enabled: upgrading
            ? (c) => engine.canUpgrade(c) && !_tempered.contains(c.uid)
            : null,
        fx: upgrading ? DeckPick.upgrade : DeckPick.remove,
        onBack: () => setState(() {
          _tempered.clear();
          _mode = _Mode.choose;
        }),
        onPick: (c) {
          if (!upgrading) {
            ctl.removeCard(c.uid);
            done();
            return;
          }
          _tempered.add(c.uid);
          if (_tempered.length < temper) {
            setState(() {});
            return;
          }
          ctl.upgradeCards(List.of(_tempered));
          done();
        },
      );
    }

    void pickMode(_Mode m) {
      Haptics.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
      setState(() => _mode = m);
    }

    Widget option(
      int i,
      IconData icon,
      String label,
      VoidCallback onTap, {
      String? blocked,
    }) => StaggerIn(
      index: i,
      delay: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: ChoiceTile(
          leading: icon,
          title: label,
          onTap: onTap,
          enabled: blocked == null,
          blocked: blocked,
        ),
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
                          style: TextStyle(fontSize: 96, fontFamily: Fonts.display, color: Palette.sky),
                        ),
                      ),
                      Positioned.fill(
                        child: InkBurst(
                          trigger: _burst,
                          colors: const [
                            Palette.sky,
                            Palette.jade,
                            Colors.white,
                          ],
                          count: 26,
                          radius: 130,
                          duration: const Duration(milliseconds: 900),
                        ),
                      ),
                    ],
                  ),
                ),
                PaperPanel(
                  padding: const EdgeInsets.fromLTRB(24, 10, 24, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                Text(
                  t.fountain,
                  style: const TextStyle(
                    fontSize: 24, fontFamily: Fonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
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
                          fontSize: 15,
                          color: _healedFrom == null
                              ? Palette.text
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
                    ],
                  ),
                ),
                const Spacer(),
                option(
                  0,
                  Icons.favorite,
                  t.fountainHeal(engine.healOf(run)),
                  // Un talismán que cobra en la fuente puede dejarla seca.
                  blocked: engine.healOf(run) == 0 ? t.fountainDry : null,
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
                  t.fountainRemove(removeMaxHp),
                  () => pickMode(_Mode.remove),
                ),
                option(
                  2,
                  Icons.upgrade,
                  t.fountainUpgrade(temper, data.balance.fountainUpgrade),
                  blocked: temper == 0 ? t.fountainNoUpgrade : null,
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
