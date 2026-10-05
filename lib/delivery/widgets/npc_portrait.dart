import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Retrato de un personaje de la montaña (mercader, maestro): entra subiendo
/// sobre una mancha de color, respira despacio y lleva su sello al costado.
/// Si falta la imagen, queda solo el sello.
class NpcPortrait extends StatefulWidget {
  const NpcPortrait({
    super.key,
    required this.asset,
    required this.color,
    required this.badge,
    this.height = 210,
  });

  final String asset;
  final Color color;

  /// El medallón de siempre (商, 师), que pasa a ser el sello del retrato.
  final Widget badge;
  final double height;

  @override
  State<NpcPortrait> createState() => _NpcPortraitState();
}

class _NpcPortraitState extends State<NpcPortrait>
    with TickerProviderStateMixin {
  late final _enter = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();
  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat();

  @override
  void dispose() {
    _enter.dispose();
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    return SizedBox(
      height: h,
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // Mancha de acuarela detrás, como el aura de los enemigos.
          Positioned(
            bottom: h * 0.08,
            child: Container(
              width: h * 0.9,
              height: h * 0.7,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.color.withValues(alpha: 0.22),
                    widget.color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
          ),
          // Sombra en el piso.
          Positioned(
            bottom: 0,
            child: Container(
              width: h * 0.5,
              height: 12,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                color: const Color(0x1F2B2A33),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: Listenable.merge([_enter, _breath]),
            builder: (_, child) {
              final v = Curves.easeOutCubic.transform(_enter.value);
              final b = math.sin(_breath.value * math.pi * 2);
              return Opacity(
                opacity: v,
                child: Transform.translate(
                  offset: Offset(0, 24 * (1 - v)),
                  child: Transform.scale(
                    alignment: Alignment.bottomCenter,
                    scaleY: 1 + 0.012 * b,
                    scaleX: 1 - 0.004 * b,
                    child: child,
                  ),
                ),
              );
            },
            child: Image.asset(
              widget.asset,
              height: h,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => SizedBox(height: h),
            ),
          ),
          Positioned(
            bottom: 4,
            child: Transform.translate(
              offset: Offset(h * 0.42, 0),
              child: Transform.scale(scale: 0.68, child: widget.badge),
            ),
          ),
        ],
      ),
    );
  }
}
