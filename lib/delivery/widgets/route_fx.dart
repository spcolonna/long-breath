import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Entradas especiales para las pantallas que marcan un momento: el combate
/// entra con dos pinceladas de laca que se cruzan, y la etapa superada se
/// abre como un rollo colgante.

/// Dos trazos de pincel cruzan la pantalla en X; detrás aparece el combate,
/// que se asienta desde un poco más cerca.
Widget brushSlash(Animation<double> animation, Widget child) {
  final first = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.32, curve: Curves.easeOutCubic),
  );
  final second = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.14, 0.46, curve: Curves.easeOutCubic),
  );
  final show = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
  );
  return Stack(
    children: [
      FadeTransition(
        opacity: show,
        child: ScaleTransition(
          scale: Tween(begin: 1.06, end: 1.0).animate(show),
          child: child,
        ),
      ),
      Positioned.fill(
        child: IgnorePointer(
          child: CustomPaint(painter: _SlashPainter(first, second, show)),
        ),
      ),
    ],
  );
}

class _SlashPainter extends CustomPainter {
  _SlashPainter(this.first, this.second, this.show)
    : super(repaint: Listenable.merge([first, second, show]));

  final Animation<double> first;
  final Animation<double> second;
  final Animation<double> show;

  @override
  void paint(Canvas canvas, Size size) {
    final fade = 1 - show.value;
    if (fade <= 0) return;
    final w = size.shortestSide * 0.22;
    _stroke(
      canvas,
      Offset(-w, size.height * 0.22),
      Offset(size.width + w, size.height * 0.62),
      first.value,
      w,
      Palette.lacquer.withValues(alpha: 0.9 * fade),
    );
    _stroke(
      canvas,
      Offset(size.width + w, size.height * 0.3),
      Offset(-w, size.height * 0.74),
      second.value,
      w * 0.8,
      Palette.gold.withValues(alpha: 0.85 * fade),
    );
  }

  /// Trazo de pincel de [a] a [b] hasta la fracción [t]: entra grueso y se
  /// afina en la punta, con el borde un poco irregular.
  void _stroke(Canvas c, Offset a, Offset b, double t, double w, Color color) {
    if (t <= 0) return;
    final dir = b - a;
    final len = dir.distance;
    final u = dir / len;
    final n = Offset(-u.dy, u.dx);
    const steps = 40;
    final top = <Offset>[];
    final bottom = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final f = i / steps * t;
      final p = a + u * (len * f);
      // Grosor: sube rápido, se sostiene y se afina al final del trazo.
      final body = math.sin(math.min(1, f / t) * math.pi * 0.92 + 0.12);
      final wob = 1 + 0.08 * math.sin(f * 37) + 0.05 * math.sin(f * 91);
      final half = w * 0.5 * body * wob;
      top.add(p + n * half);
      bottom.add(p - n * half * 0.85);
    }
    final path = Path()..moveTo(top.first.dx, top.first.dy);
    for (final p in top.skip(1)) {
      path.lineTo(p.dx, p.dy);
    }
    for (final p in bottom.reversed) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();
    c.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(_SlashPainter old) =>
      old.first != first || old.second != second || old.show != show;
}

/// La pantalla se abre desde el centro como un rollo que se desenrolla: dos
/// varillas doradas se separan hacia arriba y abajo y después se desvanecen.
Widget scrollUnroll(Animation<double> animation, Widget child) {
  final open = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.1, 0.8, curve: Curves.easeInOutCubic),
  );
  final rods = CurvedAnimation(
    parent: animation,
    curve: const Interval(0, 0.15, curve: Curves.easeOut),
  );
  final rodsOut = CurvedAnimation(
    parent: animation,
    curve: const Interval(0.8, 1, curve: Curves.easeIn),
  );
  return AnimatedBuilder(
    animation: animation,
    child: child,
    builder: (context, child) => LayoutBuilder(
      builder: (_, box) {
        final h = box.maxHeight;
        final half = h / 2 * open.value;
        final top = h / 2 - half;
        final bottom = h / 2 + half;
        final rodAlpha = rods.value * (1 - rodsOut.value);
        Widget rod(double y) => Positioned(
          left: 14,
          right: 14,
          top: y - 6,
          height: 12,
          child: Opacity(
            opacity: rodAlpha,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFFF6C35A), Palette.gold, Color(0xFFC77F0A)],
                ),
                borderRadius: BorderRadius.circular(6),
                boxShadow: [
                  BoxShadow(
                    color: Palette.gold.withValues(alpha: 0.35),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
          ),
        );
        return Stack(
          children: [
            ClipRect(
              clipper: _BandClipper(top, bottom),
              child: Opacity(opacity: 0.3 + 0.7 * open.value, child: child),
            ),
            if (rodAlpha > 0) ...[rod(top), rod(bottom)],
          ],
        );
      },
    ),
  );
}

class _BandClipper extends CustomClipper<Rect> {
  const _BandClipper(this.top, this.bottom);

  final double top;
  final double bottom;

  @override
  Rect getClip(Size size) => Rect.fromLTRB(0, top, size.width, bottom);

  @override
  bool shouldReclip(_BandClipper old) =>
      old.top != top || old.bottom != bottom;
}
