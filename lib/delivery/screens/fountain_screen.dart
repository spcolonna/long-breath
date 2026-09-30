import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/juice.dart';

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
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(
            _mode == _Mode.remove
                ? t.fountainRemove
                : t.fountainUpgrade(data.balance.fountainUpgrade),
          ),
          leading: BackButton(
            onPressed: () => setState(() => _mode = _Mode.choose),
          ),
        ),
        body: DeckGrid(
          cards: run.deck,
          enabled: _mode == _Mode.upgrade ? engine.canUpgrade : null,
          onPick: (c) {
            _mode == _Mode.remove
                ? ctl.removeCard(c.uid)
                : ctl.upgradeCard(c.uid);
            done();
          },
        ),
      );
    }

    Widget option(IconData icon, String label, VoidCallback onTap) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: OutlinedButton.icon(
          onPressed: onTap,
          icon: Icon(icon),
          label: Text(label, style: const TextStyle(fontSize: 16)),
        ),
      ),
    );

    return Scaffold(
      body: SafeArea(
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
                Icons.favorite,
                t.fountainHeal(data.balance.fountainHeal),
                () {
                  if (_healedFrom != null) return;
                  HapticFeedback.mediumImpact();
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
                Icons.delete_outline,
                t.fountainRemove,
                () => setState(() => _mode = _Mode.remove),
              ),
              option(
                Icons.upgrade,
                t.fountainUpgrade(data.balance.fountainUpgrade),
                () => setState(() => _mode = _Mode.upgrade),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
