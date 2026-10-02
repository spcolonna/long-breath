import 'package:flutter/material.dart';

import '../theme.dart';
import 'juice.dart';

/// Moneda de jade dibujada con su carácter (玉): no hace falta arte.
class JadeCoin extends StatelessWidget {
  const JadeCoin({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Palette.jade,
      border: Border.all(color: Palette.surface, width: size / 12),
      boxShadow: [
        BoxShadow(color: Palette.jade.withValues(alpha: 0.35), blurRadius: 4),
      ],
    ),
    child: Text(
      '玉',
      style: TextStyle(
        fontSize: size * 0.55,
        height: 1,
        fontWeight: FontWeight.w700,
        color: Palette.onColor,
      ),
    ),
  );
}

/// Jade de la run; la cifra cuenta hacia el valor nuevo y rebota al cambiar.
class JadeCount extends StatelessWidget {
  const JadeCount({super.key, required this.jade, this.size = 18});

  final int jade;
  final double size;

  @override
  Widget build(BuildContext context) => Bounce(
    trigger: jade,
    scale: 1.2,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        JadeCoin(size: size),
        const SizedBox(width: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(end: jade.toDouble()),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Text(
            '${v.round()}',
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w700,
              color: Palette.jade,
            ),
          ),
        ),
      ],
    ),
  );
}
