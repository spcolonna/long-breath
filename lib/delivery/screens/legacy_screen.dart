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
    Future.delayed(const Duration(milliseconds: 1000), () {
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
    final picks = [
      if (legacy.card != null) LegacyPick.card,
      LegacyPick.stat,
    ];
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 12),
              const InkSeal(hanzi: '承', color: Palette.blossom, size: 56),
              const SizedBox(height: 12),
              Text(t.legacyTitle, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                t.legacyHint(legacy.n),
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textDim),
              ),
              const Spacer(),
              for (final (i, p) in picks.indexed)
                _Arrive(
                  delayMs: 200 + 180 * i,
                  onArrive: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Press(
                      child: GestureDetector(
                        onTap: () => _select(p),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _Option(
                              picked: _picked == p,
                              dimmed: _picked != null && _picked != p,
                              taking: _taking && _picked == p,
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
    );
  }

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

/// La herencia elegida sube y brilla; la otra se apaga.
class _Option extends StatelessWidget {
  const _Option({
    required this.picked,
    required this.dimmed,
    required this.taking,
    required this.child,
  });

  final bool picked;
  final bool dimmed;
  final bool taking;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: taking ? 1.06 : (picked ? 1.03 : (dimmed ? 0.96 : 1)),
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutBack,
    child: AnimatedOpacity(
      opacity: dimmed ? (taking ? 0 : 0.55) : 1,
      duration: const Duration(milliseconds: 220),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: picked ? Palette.blossom : Palette.line,
            width: picked ? 3 : 1.5,
          ),
          boxShadow: picked
              ? [
                  BoxShadow(
                    color: Palette.gold.withValues(alpha: 0.45),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    ),
  );
}

/// Entra desde abajo con un pequeño rebote, una opción después de la otra.
class _Arrive extends StatefulWidget {
  const _Arrive({
    required this.delayMs,
    required this.onArrive,
    required this.child,
  });

  final int delayMs;
  final VoidCallback onArrive;
  final Widget child;

  @override
  State<_Arrive> createState() => _ArriveState();
}

class _ArriveState extends State<_Arrive> {
  bool _in = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: widget.delayMs), () {
      if (!mounted) return;
      widget.onArrive();
      setState(() => _in = true);
    });
  }

  @override
  Widget build(BuildContext context) => AnimatedSlide(
    offset: _in ? Offset.zero : const Offset(0, 0.6),
    duration: const Duration(milliseconds: 420),
    curve: Curves.easeOutBack,
    child: AnimatedOpacity(
      opacity: _in ? 1 : 0,
      duration: const Duration(milliseconds: 260),
      child: widget.child,
    ),
  );
}
