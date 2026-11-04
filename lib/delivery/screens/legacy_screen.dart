import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/legacy.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/lotus.dart';
import '../widgets/node_kit.dart';
import 'home_screen.dart' show routeFor;
import '../feel.dart';
import '../widgets/press.dart';

/// Al empezar la subida: el discípulo anterior deja su carta o algo de lo
/// que alcanzó, y el nuevo elige una de las dos.
class LegacyScreen extends ConsumerStatefulWidget {
  const LegacyScreen({super.key});

  @override
  ConsumerState<LegacyScreen> createState() => _LegacyScreenState();
}

class _LegacyScreenState extends ConsumerState<LegacyScreen> {
  LegacyPick? _picked;
  bool _taking = false;
  int _burst = 0;

  void _select(LegacyPick p) {
    if (_taking) return;
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    setState(() => _picked = p);
  }

  void _take() {
    final p = _picked;
    if (p == null || _taking) return;
    Haptics.heavyImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    setState(() {
      _taking = true;
      _burst++;
    });
    // Con movimiento reducido no hay vuelo que esperar: solo el «heredado».
    Future.delayed(Duration(milliseconds: calm(context) ? 700 : 1100), () {
      if (!mounted) return;
      ref.read(runControllerProvider.notifier).chooseLegacy(p);
      context.go(routeFor(ref.read(runControllerProvider)!));
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final legacy = ref.watch(runControllerProvider)?.legacy;
    if (legacy == null) return const SizedBox();
    final picks = [if (legacy.card != null) LegacyPick.card, LegacyPick.stat];
    return Scaffold(
      body: NodeBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const SizedBox(height: 12),
                // El sello baja como estampado, con su golpe.
                StaggerIn(
                  index: 0,
                  scaleFrom: 1.6,
                  rise: 0,
                  onShow: () {
                    Haptics.lightImpact();
                    ref.read(audioProvider).play(Sfx.legacySeal);
                  },
                  child: const InkSeal(
                    hanzi: '承',
                    color: Palette.blossom,
                    size: 56,
                  ),
                ),
                const SizedBox(height: 12),
                StaggerIn(
                  index: 1,
                  step: const Duration(milliseconds: 90),
                  child: Text(
                    t.legacyTitle,
                    style: const TextStyle(fontSize: 26),
                  ),
                ),
                const SizedBox(height: 6),
                StaggerIn(
                  index: 2,
                  step: const Duration(milliseconds: 90),
                  child: Text(
                    t.legacyHint(legacy.n),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Palette.textDim),
                  ),
                ),
                const Spacer(),
                for (final (i, p) in picks.indexed)
                  StaggerIn(
                    index: i,
                    delay: const Duration(milliseconds: 380),
                    step: const Duration(milliseconds: 180),
                    rise: 40,
                    onShow: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Press(
                        child: GestureDetector(
                          onTap: () => _select(p),
                          child: RepaintBoundary(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                PickCard(
                                  picked: _picked == p,
                                  dimmed: _picked != null && _picked != p,
                                  taking: _taking && _picked == p,
                                  accent: Palette.blossom,
                                  child: _content(t, legacy, p),
                                ),
                                Positioned.fill(
                                  child: InkBurst(
                                    trigger: _picked == p ? _burst : 0,
                                    colors: const [
                                      Palette.blossom,
                                      Palette.gold,
                                      Colors.white,
                                    ],
                                    count: 36,
                                    radius: 160,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 12),
                // Lo heredado, dicho en grande al confirmar.
                SizedBox(
                  height: 40,
                  child: _taking && _picked != null
                      ? Bounce(
                          trigger: _burst,
                          scale: 1.25,
                          child: Text(
                            t.legacyGained(_gained(t, legacy, _picked!)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Palette.blossom,
                            ),
                          ),
                        )
                      : null,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _picked == null ? null : _take,
                    child: Text(t.confirm),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _gained(AppLocalizations t, Legacy l, LegacyPick p) => switch (p) {
    LegacyPick.card => ref.read(textProvider).card(l.card!),
    LegacyPick.stat when l.maxHp > 0 => t.legacyHp(l.maxHp),
    LegacyPick.stat => t.legacyJade(l.jade),
  };

  Widget _content(AppLocalizations t, Legacy l, LegacyPick p) {
    final text = ref.watch(textProvider);
    final data = ref.watch(dataProvider);
    final (Widget art, String title, String body) = switch (p) {
      LegacyPick.card => (
        CardWidget(def: data.card(l.card!), upgrades: l.upgrades, width: 64),
        t.legacyCard,
        l.upgrades > 0
            ? t.legacyCardUp(text.card(l.card!), l.upgrades)
            : text.card(l.card!),
      ),
      LegacyPick.stat when l.maxHp > 0 => (
        const InkSeal(hanzi: '命', color: Palette.lacquer, size: 52),
        t.legacyStat,
        t.legacyHp(l.maxHp),
      ),
      LegacyPick.stat => (
        const JadeCoin(size: 44),
        t.legacyStat,
        t.legacyJade(l.jade),
      ),
    };
    return Row(
      children: [
        SizedBox(width: 72, child: Center(child: art)),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Palette.textDim),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: Palette.text,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
