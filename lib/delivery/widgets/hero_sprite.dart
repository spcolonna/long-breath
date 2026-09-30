import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/enums.dart';
import '../theme.dart';

String heroAsset(Style? s) => 'assets/art/player/hero_${s?.name ?? 'novice'}.png';

/// El héroe de espaldas, con la ropa y el aura de su camino (o de lino crudo
/// si todavía es novicio).
///
/// Respira en reposo, avanza al golpear ([strikeKey]) y se sacude con un
/// destello rojo al recibir daño ([hurtKey]).
class HeroSprite extends StatefulWidget {
  const HeroSprite({
    super.key,
    required this.style,
    required this.height,
    this.strikeKey = 0,
    this.hurtKey = 0,
    this.glyph,
  });

  final Style? style;
  final double height;
  final int strikeKey;
  final int hurtKey;

  /// Carácter del animal detrás del héroe (solo en la pantalla de inicio).
  final String? glyph;

  @override
  State<HeroSprite> createState() => _HeroSpriteState();
}

class _HeroSpriteState extends State<HeroSprite> with TickerProviderStateMixin {
  late final _idle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800))
    ..repeat(reverse: true);
  late final _strike = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final _hurt = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 420));

  @override
  void didUpdateWidget(HeroSprite old) {
    super.didUpdateWidget(old);
    if (widget.strikeKey != old.strikeKey) _strike.forward(from: 0);
    if (widget.hurtKey != old.hurtKey) _hurt.forward(from: 0);
  }

  @override
  void dispose() {
    _idle.dispose();
    _strike.dispose();
    _hurt.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    final w = h * 2 / 3;
    final accent = styleColor(widget.style);
    final image = Image.asset(
      heroAsset(widget.style),
      height: h,
      width: w,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => SizedBox(width: w, height: h),
    );
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _strike, _hurt]),
      builder: (context, child) {
        final idle = Curves.easeInOut.transform(_idle.value);
        final s = math.sin(math.pi * _strike.value);
        final hv = _hurt.value;
        final shake = _hurt.isAnimating ? math.sin(hv * math.pi * 7) * 8 * (1 - hv) : 0.0;
        final flash = _hurt.isAnimating ? (1 - hv) * 0.55 : 0.0;
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Aura del camino.
              Container(
                width: w * 1.25,
                height: w * 1.25,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    accent.withValues(alpha: 0.32 + 0.12 * idle),
                    accent.withValues(alpha: 0),
                  ]),
                ),
              ),
              if (widget.glyph != null)
                Text(widget.glyph!,
                    style: TextStyle(
                        fontSize: h * 0.55,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        color: accent.withValues(alpha: 0.22))),
              Transform.translate(
                offset: Offset(shake + 22 * s, -14 * s),
                child: Transform.scale(
                  scale: 1 + 0.015 * idle + 0.06 * s,
                  alignment: Alignment.bottomCenter,
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        Palette.lacquer.withValues(alpha: flash), BlendMode.srcATop),
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        );
      },
      child: image,
    );
  }
}
