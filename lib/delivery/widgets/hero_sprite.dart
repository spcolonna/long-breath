import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/enums.dart';
import '../theme.dart';
import 'juice.dart';
import 'weapon_art.dart';
import '../feel.dart';

String heroAsset(Style? s) => 'assets/art/player/hero_${s?.name ?? 'novice'}.webp';

/// El héroe de espaldas, con la ropa y el aura de su camino (o de lino crudo
/// si todavía es novicio).
///
/// Respira en reposo, avanza al golpear ([strikeKey]), se sacude con un
/// destello rojo al recibir daño ([hurtKey]), brilla al ganar Guardia
/// ([guardKey]), festeja al ganar ([victory]) y cae al perder ([defeated]).
/// Con [weapon], la lleva en la mano adelantada y la blande al golpear.
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
    this.aura = 0,
    this.weapon,
    this.weaponLevel = 0,
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

  /// Cuánto creció el aura con el cultivo (0 = recién llegado, 1 = el
  /// reino más alto). Solo en la pantalla de inicio.
  final double aura;

  /// Arma en la mano y su nivel (la borla y el brillo).
  final String? weapon;
  final int weaponLevel;

  @override
  State<HeroSprite> createState() => _HeroSpriteState();
}

class _HeroSpriteState extends State<HeroSprite> with TickerProviderStateMixin {
  late final _idle = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 2800));
  // Mantiene el cuerpo (y su imagen) al poner o quitar los filtros.
  final _body = GlobalKey();
  late final _strike = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final _hurt = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 480));
  late final _guard = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
  late final _end = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 1000));

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _idle, reverse: true);
  }

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
        // Un solo empuje: sale rápido y vuelve despacio. Sin amague hacia
        // atrás, que con la vuelta se leía como dos idas y venidas.
        final s = 0.5 *
            (st < 0.3
                ? Curves.easeOutCubic.transform(st / 0.3)
                : 1 - Curves.easeInOutSine.transform((st - 0.3) / 0.7));
        final hv = _hurt.value;
        final hurting = _hurt.isAnimating;
        const stop = 0.15;
        final after = hv < stop ? 0.0 : (hv - stop) / (1 - stop);
        final shake = hurting && hv >= stop ? math.sin(after * math.pi * 4) * 5 * (1 - after) : 0.0;
        final knock = hurting ? (hv < stop ? 1.0 : 1 - Curves.easeOut.transform(after)) : 0.0;
        final flash = hurting ? (hv < stop ? 0.6 : 0.6 * (1 - after)) : 0.0;
        final g = _guard.isAnimating ? math.sin(math.pi * _guard.value) : 0.0;
        final e = Curves.easeInOut.transform(_end.value);
        // Victoria: un salto corto. Derrota: se hunde y pierde el color.
        final hop = widget.victory ? -math.sin(math.pi * math.min(1, _end.value * 1.6)) * 12 : 0.0;
        final fall = widget.defeated ? e : 0.0;
        // El arma va dentro del cuerpo: hereda el paso, el retroceso y los
        // filtros, y además se blande al golpear.
        Widget body = KeyedSubtree(key: _body, child: child!);
        final weapon = widget.weapon;
        if (weapon != null) {
          final shape = weaponShapeOf(weapon);
          final len = h * shape.length;
          body = Stack(
            clipBehavior: Clip.none,
            children: [
              // Detrás del cuerpo: el héroe la sostiene delante suyo.
              Positioned(
                left: w * heroHand.dx - len / 6,
                top: h * heroHand.dy - len * shape.grip,
                child: Transform.rotate(
                  angle: shape.angle + 1.1 * s + 0.04 * (idle - 0.5),
                  alignment: Alignment(0, shape.grip * 2 - 1),
                  child: WeaponArt(
                    id: weapon,
                    level: widget.weaponLevel,
                    height: len,
                    sway: ((idle - 0.5) * 2 - s).clamp(-1.0, 1.0),
                  ),
                ),
              ),
              body,
            ],
          );
        }
        return SizedBox(
          width: w,
          height: h,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Halo dorado del cultivo: crece con cada reino.
              if (widget.aura > 0)
                Container(
                  width: w * (1.3 + 0.45 * widget.aura + 0.04 * idle),
                  height: w * (1.3 + 0.45 * widget.aura + 0.04 * idle),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(colors: [
                      Palette.gold.withValues(alpha: 0),
                      Palette.gold.withValues(
                          alpha: (0.1 + 0.08 * idle) * widget.aura),
                      Palette.gold.withValues(alpha: 0),
                    ], stops: const [0.55, 0.8, 1]),
                  ),
                ),
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
                    // Los filtros cuestan una capa por cuadro: solo cuando
                    // hacen algo (al caer o al recibir un golpe).
                    child: _filtered(
                      fall > 0 ? saturationMatrix(1 - 0.8 * fall) : null,
                      flash > 0
                          ? Palette.lacquer.withValues(alpha: flash)
                          : null,
                      body,
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

/// [child] con desaturación y tinte solo si hacen falta.
Widget _filtered(List<double>? matrix, Color? tint, Widget child) {
  var w = child;
  if (tint != null) {
    w = ColorFiltered(
      colorFilter: ColorFilter.mode(tint, BlendMode.srcATop),
      child: w,
    );
  }
  if (matrix != null) {
    w = ColorFiltered(colorFilter: ColorFilter.matrix(matrix), child: w);
  }
  return w;
}
