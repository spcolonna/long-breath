import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/form_scroll.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> {
  String? _picked;

  /// Se eligió la forma ofrecida (en vez de una carta).
  bool _formPicked = false;

  /// La elegida vuela al mazo antes de volver al mapa.
  bool _taking = false;
  int _burst = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);

    void choose(String? id) {
      if (_taking) return;
      if (id == null) {
        ref.read(runControllerProvider.notifier).chooseReward(null);
        context.go('/map');
        return;
      }
      HapticFeedback.mediumImpact();
      ref.read(audioProvider).play(Sfx.rewardTake);
      setState(() {
        _taking = true;
        _burst++;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!context.mounted) return;
        ref.read(runControllerProvider.notifier).chooseReward(id);
        context.go('/map');
      });
    }

    void learn(String formId) {
      if (_taking) return;
      HapticFeedback.heavyImpact();
      ref.read(audioProvider).play(Sfx.formComplete);
      setState(() {
        _taking = true;
        _burst++;
      });
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!context.mounted) return;
        ref.read(runControllerProvider.notifier).chooseForm(formId);
        context.go('/map');
      });
    }

    void select({String? card, bool form = false}) {
      if (_taking) return;
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.cardSelect);
      setState(() {
        _picked = card;
        _formPicked = form;
      });
    }

    final text = ref.watch(textProvider);
    final offered = run.rewardForm == null
        ? null
        : data.forms.firstWhere((f) => f.id == run.rewardForm);
    final deckIds = {for (final c in run.deck) c.cardId};
    final picked = _picked == null ? null : data.card(_picked!);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(t.rewardTitle, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(
                t.rewardHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textDim),
              ),
              if (run.jadeGained > 0) ...[
                const SizedBox(height: 10),
                // El jade del combate entra con un rebote.
                TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.3, end: 1),
                  duration: const Duration(milliseconds: 600),
                  curve: Curves.elasticOut,
                  builder: (_, v, child) =>
                      Transform.scale(scale: v, child: child),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.jade.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const JadeCoin(),
                        const SizedBox(width: 6),
                        Text(
                          t.jadeGained(run.jadeGained),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Palette.jade,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final (i, id) in run.rewardOptions.indexed)
                    _Reveal(
                      delayMs: 150 + 140 * i,
                      onFlip: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                      child: GestureDetector(
                        onTap: () => select(card: id),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _Choice(
                              picked: _picked == id,
                              dimmed: (_picked != null || _formPicked) &&
                                  _picked != id,
                              taking: _taking && _picked == id,
                              child: CardWidget(
                                def: data.card(id),
                                width: 104,
                                selected: _picked == id,
                              ),
                            ),
                            Positioned.fill(
                              child: InkBurst(
                                trigger: _picked == id ? _burst : 0,
                                colors: const [
                                  Palette.gold,
                                  Palette.lacquer,
                                  Colors.white,
                                ],
                                count: 30,
                                radius: 130,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              ),
              if (offered != null) ...[
                const SizedBox(height: 16),
                _Reveal(
                  delayMs: 150 + 140 * run.rewardOptions.length,
                  onFlip: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                  child: GestureDetector(
                    onTap: () => select(form: true),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        _Choice(
                          picked: _formPicked,
                          dimmed: _picked != null,
                          taking: false,
                          child: FormScroll(
                            form: offered,
                            name: text.form(offered.id),
                            steps: [
                              for (final id in offered.steps)
                                (text.card(id), deckIds.contains(id)),
                            ],
                            effect: t.formEffect(offered.effect),
                            selected: _formPicked,
                          ),
                        ),
                        Positioned.fill(
                          child: InkBurst(
                            trigger: _formPicked ? _burst : 0,
                            colors: const [
                              Palette.gold,
                              Palette.lacquer,
                              Colors.white,
                            ],
                            count: 44,
                            radius: 180,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _formPicked && offered != null
                      ? (_taking
                          ? Bounce(
                              key: const ValueKey('learned'),
                              trigger: _burst,
                              scale: 1.25,
                              child: Text(
                                t.formLearned(text.form(offered.id)),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w700,
                                  color: Palette.lacquer,
                                ),
                              ),
                            )
                          : Text(
                              t.formScrollHint,
                              key: const ValueKey('form'),
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Palette.textDim),
                            ))
                      : picked == null
                      ? const SizedBox()
                      : Text(
                          '${ref.watch(textProvider).card(picked.id)} · ${picked.pinyin} ${picked.hanzi}\n'
                          '${t.cardEffect(picked, ref.watch(textProvider))}'
                          '${data.forms.any((f) => (run.knownForms.contains(f.id) || f.id == run.rewardForm) && f.steps.contains(picked.id)) ? '\n${t.partOfForm}' : ''}',
                          key: ValueKey(picked.id),
                          textAlign: TextAlign.center,
                        ),
                ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => choose(null),
                      child: Text(t.skip),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _formPicked && offered != null
                          ? () => learn(offered.id)
                          : _picked == null
                          ? null
                          : () => choose(_picked),
                      child: Text(t.confirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// La carta se da vuelta y sube desde abajo al entrar en pantalla.
class _Reveal extends StatefulWidget {
  const _Reveal({required this.delayMs, required this.onFlip, required this.child});

  final int delayMs;
  final VoidCallback onFlip;
  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  static const _flip = 520;
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _flip + widget.delayMs),
  )
    ..addListener(_onTick)
    ..forward();
  bool _flipped = false;

  void _onTick() {
    if (!_flipped && _c.value > widget.delayMs / (_flip + widget.delayMs)) {
      _flipped = true;
      widget.onFlip();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.delayMs / (_flip + widget.delayMs);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final raw = _c.value <= start ? 0.0 : (_c.value - start) / (1 - start);
        if (raw >= 1) return child!;
        final v = Curves.easeOutBack.transform(raw);
        return Opacity(
          opacity: math.min(1, raw * 3),
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - v)),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(math.pi / 2 * (1 - v)),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Estado de una opción: la elegida sube y brilla, las otras se apagan; al
/// confirmar, la elegida crece y se desvanece hacia el mazo.
class _Choice extends StatelessWidget {
  const _Choice({
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
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, taking ? -0.5 : (picked ? -0.08 : 0)),
      duration: Duration(milliseconds: taking ? 550 : 240),
      curve: taking ? Curves.easeInCubic : Curves.easeOutBack,
      child: AnimatedScale(
        scale: taking ? 1.25 : (picked ? 1.08 : (dimmed ? 0.94 : 1)),
        duration: Duration(milliseconds: taking ? 550 : 240),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: taking ? 0 : (dimmed ? 0.55 : 1),
          duration: Duration(milliseconds: taking ? 550 : 200),
          curve: taking ? const Interval(0.5, 1) : Curves.linear,
          child: child,
        ),
      ),
    );
  }
}
