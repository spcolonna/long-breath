import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/combat/combat_state.dart';
import '../../l10n/app_localizations.dart';
import '../feel.dart';
import '../theme.dart';
import 'lotus.dart';
import 'paper_panel.dart';
import 'press.dart';

/// Tregua entre oleadas: cae un rival del grupo y, antes de que entre el
/// siguiente, el jugador elige un premio chico. Cubre la arena y la mano
/// (nada se juega hasta elegir) con un velo claro, nunca oscuro.
class BreatherSheet extends StatelessWidget {
  const BreatherSheet({
    super.key,
    required this.options,
    required this.nextName,
    required this.heal,
    required this.draw,
    required this.breath,
    required this.fist,
    required this.onPick,
  });

  final List<Breather> options;
  final String nextName;
  final int heal;
  final int draw;
  final int breath;
  final int fist;
  final ValueChanged<Breather> onPick;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final still = calm(context);
    return Stack(
      children: [
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: still ? 1 : 0, end: 1),
            duration: const Duration(milliseconds: 380),
            builder: (_, v, _) =>
                ColoredBox(color: Palette.bg.withValues(alpha: 0.55 * v)),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: _Rise(
                index: 0,
                still: still,
                child: PaperPanel(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                  radius: 20,
                  opacity: 0.97,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        t.breatherTitle,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Palette.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        t.breatherSub(nextName),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14.5,
                          color: Palette.text,
                        ),
                      ),
                      const SizedBox(height: 12),
                      for (final (i, b) in options.indexed)
                        _Rise(
                          index: i + 1,
                          still: still,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: BreatherOption(
                              key: ValueKey(b),
                              hanzi: hanziOf(b),
                              color: colorOf(b),
                              title: titleOf(t, b),
                              hint: _hint(t, b),
                              onTap: () => onPick(b),
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
      ],
    );
  }

  static String hanziOf(Breather b) => switch (b) {
    Breather.rest => '息',
    Breather.focus => '凝',
    Breather.fist => '拳',
  };

  static Color colorOf(Breather b) => switch (b) {
    Breather.rest => Palette.jade,
    Breather.focus => Palette.gold,
    Breather.fist => Palette.lacquer,
  };

  static String titleOf(AppLocalizations t, Breather b) => switch (b) {
    Breather.rest => t.breatherRest,
    Breather.focus => t.breatherFocus,
    Breather.fist => t.breatherFist,
  };

  String _hint(AppLocalizations t, Breather b) => switch (b) {
    Breather.rest => t.breatherRestHint(heal),
    Breather.focus => t.breatherFocusHint(draw, breath),
    Breather.fist => t.breatherFistHint(fist),
  };
}

class BreatherOption extends StatelessWidget {
  const BreatherOption({
    super.key,
    required this.hanzi,
    required this.color,
    required this.title,
    required this.hint,
    required this.onTap,
  });

  final String hanzi;
  final Color color;
  final String title;
  final String hint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Press(
    child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.55), width: 1.4),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 12, 10),
          child: Row(
            children: [
              InkSeal(hanzi: hanzi, color: color, size: 46),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                        color: Palette.text,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hint,
                      style: const TextStyle(fontSize: 14, color: Palette.text),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Entra subiendo y aclarándose, de a uno.
class _Rise extends StatelessWidget {
  const _Rise({required this.index, required this.still, required this.child});

  final int index;
  final bool still;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (still) return child;
    final start = math.min(0.12 * index, 0.5);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 700),
      curve: Interval(start, 1, curve: Curves.easeOutBack),
      builder: (_, v, c) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: c),
      ),
      child: child,
    );
  }
}
