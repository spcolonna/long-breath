import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/enums.dart';
import '../theme.dart';
import 'juice.dart';

String heroAsset(Style? s) => 'assets/art/player/hero_${s?.name ?? 'novice'}.png';

/// El héroe de espaldas, con la ropa y el aura de su camino (o de lino crudo
/// si todavía es novicio).
///
/// Respira en reposo, avanza al golpear ([strikeKey]), se sacude con un
/// destello rojo al recibir daño ([hurtKey]), brilla al ganar Guardia
/// ([guardKey]), festeja al ganar ([victory]) y cae al perder ([defeated]).
class HeroSprite extends StatefulWidget {
  const HeroSprite({
    super.key,
    required this.style,
    required this.height,
    this.strikeKey = 0,
    this.hurtKey = 0,
    this.guardKey = 0,
    this.victory = false,
    this.defeated = false,
    this.glyph,
  });

  final Style? style;
  final double height;
  final int strikeKey;
  final int hurtKey;
  final int guardKey;
  final bool victory;
  final bool defeated;

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
      vsync: this, duration: const Duration(milliseconds: 480));
  late final _guard = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  late final _end = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void didUpdateWidget(HeroSprite old) {
    super.didUpdateWidget(old);
    if (widget.strikeKey != old.strikeKey) _strike.forward(from: 0);
    if (widget.hurtKey != old.hurtKey) _hurt.forward(from: 0);
    if (widget.guardKey != old.guardKey) _guard.forward(from: 0);
    if ((widget.victory && !old.victory) || (widget.defeated && !old.defeated)) {
      _end.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _idle.dispose();
    _strike.dispose();
    _hurt.dispose();
    _guard.dispose();
    _end.dispose();
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
      animation: Listenable.merge([_idle, _strike, _hurt, _guard, _end]),
      builder: (context, child) {
        final idle = Curves.easeInOut.transform(_idle.value);
        final st = _strike.value;
        // Carga un instante hacia atrás y sale disparado.
        final s = st < 0.25
            ? -0.3 * Curves.easeOut.transform(st / 0.25)
            : math.sin(math.pi * (st - 0.25) / 0.75);
        final hv = _hurt.value;
        final hurting = _hurt.isAnimating;
        const stop = 0.15;
        final after = hv < stop ? 0.0 : (hv - stop) / (1 - stop);
        final shake = hurting && hv >= stop ? math.sin(after * math.pi * 6) * 9 * (1 - after) : 0.0;
        final knock = hurting ? (hv < stop ? 1.0 : 1 - Curves.easeOut.transform(after)) : 0.0;
        final flash = hurting ? (hv < stop ? 0.6 : 0.6 * (1 - after)) : 0.0;
        final g = _guard.isAnimating ? math.sin(math.pi * _guard.value) : 0.0;
        final e = Curves.easeInOut.transform(_end.value);
        // Victoria: un salto corto. Derrota: se hunde y pierde el color.
        final hop = widget.victory ? -math.sin(math.pi * math.min(1, _end.value * 1.6)) * 26 : 0.0;
        final fall = widget.defeated ? e : 0.0;
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Aura del camino.
              Opacity(
                opacity: 1 - fall * 0.8,
                child: Container(
                  width: w * (1.25 + 0.2 * g + (widget.victory ? 0.25 * e : 0)),
                  height: w * (1.25 + 0.2 * g + (widget.victory ? 0.25 * e : 0)),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      accent.withValues(
                          alpha: 0.32 + 0.12 * idle + (widget.victory ? 0.3 * e : 0)),
                      accent.withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
              // Escudo de Guardia que se enciende y se apaga.
              if (g > 0)
                Container(
                  width: w * 1.05,
                  height: w * 1.05,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: Palette.sky.withValues(alpha: 0.85 * g), width: 4 + 4 * g),
                    gradient: RadialGradient(colors: [
                      Palette.sky.withValues(alpha: 0),
                      Palette.sky.withValues(alpha: 0.3 * g),
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
                offset: Offset(shake + 26 * s - 14 * knock - 10 * fall,
                    -16 * s + 6 * knock + hop + h * 0.08 * fall),
                child: Transform.rotate(
                  angle: -0.18 * fall,
                  alignment: Alignment.bottomCenter,
                  child: Transform.scale(
                    scale: 1 + 0.015 * idle + 0.07 * s.clamp(0, 1),
                    alignment: Alignment.bottomCenter,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.matrix(saturationMatrix(1 - 0.8 * fall)),
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                            Palette.lacquer.withValues(alpha: flash), BlendMode.srcATop),
                        child: child,
                      ),
                    ),
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
