import 'package:flutter/material.dart';

import '../../domain/model/game_balance.dart';
import '../../domain/model/meta_bonus.dart';
import '../theme.dart';
import 'juice.dart';

/// Semilla de loto dibujada con su carácter (莲): no hace falta arte.
class LotusSeed extends StatelessWidget {
  const LotusSeed({super.key, this.size = 18});

  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const RadialGradient(
        colors: [Color(0xFFF7A8C4), Palette.blossom],
        center: Alignment(-0.3, -0.4),
      ),
      border: Border.all(color: Palette.surface, width: size / 12),
      boxShadow: [
        BoxShadow(
          color: Palette.blossom.withValues(alpha: 0.35),
          blurRadius: 4,
        ),
      ],
    ),
    child: Text(
      '莲',
      style: TextStyle(
        fontSize: size * 0.55,
        height: 1,
        fontWeight: FontWeight.w700,
        color: Palette.onColor,
      ),
    ),
  );
}

/// Semillas de loto; la cifra cuenta hacia el valor nuevo y rebota.
class LotusCount extends StatelessWidget {
  const LotusCount({super.key, required this.lotus, this.size = 18});

  final int lotus;
  final double size;

  @override
  Widget build(BuildContext context) => Bounce(
    trigger: lotus,
    scale: 1.2,
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        LotusSeed(size: size),
        const SizedBox(width: 4),
        TweenAnimationBuilder<double>(
          tween: Tween(end: lotus.toDouble()),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Text(
            '${v.round()}',
            style: TextStyle(
              fontSize: size * 0.85,
              fontWeight: FontWeight.w700,
              color: Palette.blossom,
            ),
          ),
        ),
      ],
    ),
  );
}

/// Carácter y color de cada tipo de premio (los sellos del botín).
(String, Color) lootLook(RewardKind k) => switch (k) {
  RewardKind.cards => ('卷', Palette.lacquer),
  RewardKind.jade => ('玉', Palette.jade),
  RewardKind.lotus => ('莲', Palette.blossom),
  RewardKind.upgrade => ('炼', Palette.gold),
  RewardKind.tea => ('茶', Palette.sky),
  RewardKind.talisman => ('符', Palette.structure),
};

/// Carácter y color de cada rama del árbol de meridianos.
(String, Color) branchLook(MeridianBranch b) => switch (b) {
  MeridianBranch.body => ('身', Palette.lacquer),
  MeridianBranch.spirit => ('神', Palette.sky),
  MeridianBranch.technique => ('技', Palette.jade),
};

/// Sello cuadrado de laca con un carácter (premios, ramas, reinos).
class InkSeal extends StatelessWidget {
  const InkSeal({
    super.key,
    required this.hanzi,
    required this.color,
    this.size = 64,
    this.dim = false,
  });

  final String hanzi;
  final Color color;
  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: dim ? Palette.line : color,
      borderRadius: BorderRadius.circular(size * 0.18),
      border: Border.all(
        color: Palette.surface.withValues(alpha: 0.9),
        width: size / 22,
      ),
      boxShadow: dim
          ? null
          : [
              BoxShadow(
                color: color.withValues(alpha: 0.4),
                blurRadius: size / 5,
                offset: Offset(0, size / 16),
              ),
            ],
    ),
    // Varios caracteres (los puntos del árbol) entran en una línea.
    padding: EdgeInsets.all(size * 0.12),
    child: FittedBox(
      child: Text(
        hanzi,
        maxLines: 1,
        style: TextStyle(
          fontSize: size * 0.52,
          height: 1,
          fontWeight: FontWeight.w800,
          color: dim ? Palette.textDim : Palette.onColor,
        ),
      ),
    ),
  );
}
