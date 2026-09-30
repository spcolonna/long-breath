import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/juice.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

/// Fin de la run: el carácter cae como un sello, salpica tinta y después
/// entran el resumen y los botones.
class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 1600),
        )
        ..addListener(_onTick)
        ..forward();
  static const _landAt = 0.35;
  int _burst = 0;

  void _onTick() {
    if (_burst == 0 && _c.value >= _landAt) {
      HapticFeedback.heavyImpact();
      setState(() => _burst++);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _span(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  Widget _enter(double a, double b, Widget child) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) {
      final v = _span(a, b);
      return Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 20 * (1 - v)),
          child: child,
        ),
      );
    },
    child: child,
  );

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final won = run.phase == RunPhase.victory;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              SizedBox(
                height: 170,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedBuilder(
                      animation: _c,
                      builder: (_, child) {
                        final v = _span(0.05, _landAt, Curves.easeInCubic);
                        final settle = _span(_landAt, 0.5, Curves.easeOutBack);
                        return Opacity(
                          opacity: v,
                          child: Transform.scale(
                            scale: 2.8 - 1.8 * v + 0.05 * (1 - settle) * v,
                            child: child,
                          ),
                        );
                      },
                      child: Text(
                        won ? '龙' : '败',
                        style: TextStyle(
                          fontSize: 120,
                          height: 1.2,
                          color: won ? Palette.gold : Palette.lacquer,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: InkBurst(
                        trigger: _burst,
                        colors: won
                            ? const [
                                Palette.gold,
                                Palette.lacquer,
                                Colors.white,
                              ]
                            : const [Palette.lacquer, Palette.textDim],
                        count: 34,
                        radius: 150,
                        duration: const Duration(milliseconds: 1000),
                      ),
                    ),
                  ],
                ),
              ),
              _enter(
                0.45,
                0.7,
                Text(
                  won ? t.runWon : t.runLost,
                  style: const TextStyle(fontSize: 24),
                ),
              ),
              const SizedBox(height: 8),
              _enter(
                0.55,
                0.8,
                Text(
                  '${run.visited.length} / 7 · ${t.deckCount(run.deck.length)}',
                  style: const TextStyle(color: Palette.textDim),
                ),
              ),
              const Spacer(),
              _enter(
                0.7,
                1,
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton(
                    onPressed: () {
                      ref.read(runControllerProvider.notifier).newRun();
                      context.go('/map');
                    },
                    child: Text(t.tryAgain),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _enter(
                0.8,
                1,
                TextButton(
                  onPressed: () {
                    ref.read(runControllerProvider.notifier).abandon();
                    ref.invalidate(savedRunProvider);
                    context.go('/');
                  },
                  child: Text(t.backHome),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
