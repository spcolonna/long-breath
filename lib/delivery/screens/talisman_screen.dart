import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/juice.dart';
import '../widgets/talisman_widgets.dart';

/// Después de vencer al élite: elegir 1 de 3 talismanes. Después viene la
/// recompensa de siempre.
class TalismanScreen extends ConsumerStatefulWidget {
  const TalismanScreen({super.key});

  @override
  ConsumerState<TalismanScreen> createState() => _TalismanScreenState();
}

class _TalismanScreenState extends ConsumerState<TalismanScreen> {
  String? _picked;
  bool _taking = false;
  int _burst = 0;

  void _select(String id) {
    if (_taking) return;
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    setState(() => _picked = id);
  }

  void _take() {
    final id = _picked;
    if (id == null || _taking) return;
    HapticFeedback.heavyImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    setState(() {
      _taking = true;
      _burst++;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      ref.read(runControllerProvider.notifier).chooseTalisman(id);
      context.go('/reward');
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(t.talismanPickTitle, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                t.talismanPickHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textDim),
              ),
              const Spacer(),
              for (final (i, id) in run.talismanOptions.indexed)
                _Arrive(
                  delayMs: 150 + 160 * i,
                  onArrive: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: GestureDetector(
                      onTap: () => _select(id),
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          _Option(
                            id: id,
                            picked: _picked == id,
                            dimmed: _picked != null && _picked != id,
                            taking: _taking && _picked == id,
                          ),
                          Positioned.fill(
                            child: InkBurst(
                              trigger: _picked == id ? _burst : 0,
                              colors: [
                                talismanColor(data.talisman(id).rare),
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
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: _taking && _picked != null
                    ? Bounce(
                        trigger: _burst,
                        scale: 1.25,
                        child: Text(
                          t.talismanGained(text.talisman(_picked!)),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Palette.lacquer,
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
    );
  }
}

/// Tarjeta de un talismán: la elegida sube y brilla, las otras se apagan.
class _Option extends StatelessWidget {
  const _Option({
    required this.id,
    required this.picked,
    required this.dimmed,
    required this.taking,
  });

  final String id;
  final bool picked;
  final bool dimmed;
  final bool taking;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
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
              color: picked ? Palette.lacquer : Palette.line,
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
          child: TalismanTile(id: id, badgeSize: 52),
        ),
      ),
    );
  }
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
