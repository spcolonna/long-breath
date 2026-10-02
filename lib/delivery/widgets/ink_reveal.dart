import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Se pasa como `extra` al navegar para que la pantalla nueva entre con una
/// mancha de tinta que se abre desde [center] (en coordenadas globales).
class InkFrom {
  const InkFrom(this.center, this.color);

  final Offset center;
  final Color color;
}

/// Transición de tinta: una mancha del color del lugar crece desde donde se
/// tocó hasta cubrir la pantalla y, mientras se aclara, aparece la nueva.
Widget inkReveal(Animation<double> animation, Widget child, InkFrom from) {
  final spread = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.6, curve: Curves.easeInCubic),
  );
  final show = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.5, 1, curve: Curves.easeOutCubic),
  );
  return Stack(
    children: [
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(painter: _InkPainter(from, spread, show)),
        ),
      ),
      FadeTransition(
        opacity: show,
        child: ScaleTransition(
          scale: Tween(begin: 1.04, end: 1.0).animate(show),
          child: child,
        ),
      ),
    ],
  );
}

class _InkPainter extends CustomPainter {
  _InkPainter(this.from, this.spread, this.show)
    : super(repaint: Listenable.merge([spread, show]));

  final InkFrom from;
  final Animation<double> spread;
  final Animation<double> show;

  @override
  void paint(Canvas canvas, Size size) {
    if (spread.value <= 0 || show.value >= 1) return;
    final far = [
      Offset.zero,
      Offset(size.width, 0),
      Offset(0, size.height),
      Offset(size.width, size.height),
    ].map((c) => (c - from.center).distance).reduce(math.max);
    final r = far * 1.1 * spread.value;
    // Borde irregular, como tinta que se corre en el papel.
    final blob = Path();
    const n = 48;
    for (var i = 0; i <= n; i++) {
      final a = i / n * 2 * math.pi;
      final wob = 1 + 0.06 * math.sin(a * 5 + 1.3) + 0.04 * math.sin(a * 9);
      final p = from.center + Offset(math.cos(a), math.sin(a)) * r * wob;
      i == 0 ? blob.moveTo(p.dx, p.dy) : blob.lineTo(p.dx, p.dy);
    }
    blob.close();
    final fade = 1 - show.value;
    final ink = Color.lerp(from.color, Palette.bg, 0.55)!;
    canvas.drawPath(blob, Paint()..color = ink.withValues(alpha: 0.95 * fade));
    canvas.drawPath(
      blob,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6
        ..color = from.color.withValues(alpha: 0.5 * fade),
    );
  }

  @override
  bool shouldRepaint(_InkPainter old) => false;
}
