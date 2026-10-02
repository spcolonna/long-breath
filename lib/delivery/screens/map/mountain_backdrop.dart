import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../theme.dart';
import 'map_layout.dart';

/// Tinta aguada de las cordilleras: siempre clara, nunca un fondo oscuro.
const _inkFar = Color(0xFFA9C2BA);
const _inkMid = Color(0xFF86A597);
const _pine = Color(0xFF5F8E7C);

/// Cielo y cordilleras fijos a la pantalla. Se corren más despacio que el
/// sendero (parallax): las montañas lejanas casi no se mueven y eso da la
/// profundidad. Arriba el cielo se vuelve dorado y rosa, como la cumbre.
class SkyPainter extends CustomPainter {
  SkyPainter({required this.scroll, required this.maxScroll});

  final double scroll;
  final double maxScroll;

  @override
  void paint(Canvas canvas, Size size) {
    final p = maxScroll <= 0 ? 0.0 : (scroll / maxScroll).clamp(0.0, 1.0);
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.lerp(const Color(0xFFEAF3EE), const Color(0xFFFFE1C9), p)!,
            Color.lerp(Palette.bg, const Color(0xFFFCEAE0), p)!,
            Color.lerp(Palette.bgAlt, Palette.bg, p)!,
          ],
          stops: const [0, 0.5, 1],
        ).createShader(rect),
    );
    // Sol de la cumbre: más alto y más fuerte a medida que se sube.
    final sun = Offset(size.width * 0.78, size.height * (0.42 - 0.26 * p));
    canvas.drawCircle(
      sun,
      90,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Palette.gold.withValues(alpha: 0.28 + 0.25 * p),
            Palette.gold.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: sun, radius: 90)),
    );
    canvas.drawCircle(
      sun,
      26,
      Paint()..color = const Color(0xFFFFE7B8).withValues(alpha: 0.5 + 0.3 * p),
    );
    _ranges(
      canvas,
      size,
      factor: 0.25,
      spacing: 260,
      salt: 11,
      ink: _inkFar,
      alpha: 0.34,
      peak: 120,
    );
    _ranges(
      canvas,
      size,
      factor: 0.55,
      spacing: 340,
      salt: 29,
      ink: _inkMid,
      alpha: 0.30,
      peak: 80,
      pines: true,
    );
  }

  void _ranges(
    Canvas canvas,
    Size size, {
    required double factor,
    required double spacing,
    required int salt,
    required Color ink,
    required double alpha,
    required double peak,
    bool pines = false,
  }) {
    final shift = scroll * factor;
    final first = ((shift - 200) / spacing).floor();
    final last = first + (size.height / spacing).ceil() + 3;
    for (var k = first; k <= last; k++) {
      final base = size.height + 60 - k * spacing + shift;
      if (base < -40 || base - peak > size.height + 200) continue;
      final rnd = math.Random(k * 7919 + salt);
      final pts = <Offset>[];
      const steps = 7;
      for (var i = 0; i <= steps; i++) {
        final x = -40 + (size.width + 80) * i / steps;
        final h = peak * (0.25 + 0.75 * rnd.nextDouble());
        pts.add(Offset(x, base - h));
      }
      final ridge = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (var i = 0; i < pts.length - 1; i++) {
        final mid = Offset.lerp(pts[i], pts[i + 1], 0.5)!;
        ridge.quadraticBezierTo(pts[i].dx, pts[i].dy, mid.dx, mid.dy);
      }
      ridge.lineTo(pts.last.dx, pts.last.dy);
      final body = Path.from(ridge)
        ..lineTo(size.width + 40, base + 180)
        ..lineTo(-40, base + 180)
        ..close();
      final top = base - peak;
      canvas.drawPath(
        body,
        Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              ink.withValues(alpha: alpha),
              ink.withValues(alpha: alpha * 0.45),
              ink.withValues(alpha: 0),
            ],
            stops: const [0, 0.4, 1],
          ).createShader(Rect.fromLTRB(0, top, size.width, base + 180)),
      );
      // El filo de la cordillera, como una pincelada que se afina.
      canvas.drawPath(
        ridge,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..color = ink.withValues(alpha: alpha * 1.3),
      );
      if (pines) _pines(canvas, ridge, rnd, alpha);
    }
  }

  void _pines(Canvas canvas, Path ridge, math.Random rnd, double alpha) {
    final paint = Paint()..color = _pine.withValues(alpha: alpha * 1.4);
    for (final m in ridge.computeMetrics()) {
      for (
        var d = rnd.nextDouble() * 40;
        d < m.length;
        d += 26 + rnd.nextDouble() * 70
      ) {
        final at = m.getTangentForOffset(d)!.position;
        final h = 10 + rnd.nextDouble() * 12;
        for (var tier = 0; tier < 3; tier++) {
          final y = at.dy + 4 - tier * h * 0.3;
          final half = h * (0.36 - tier * 0.09);
          canvas.drawPath(
            Path()
              ..moveTo(at.dx - half, y)
              ..lineTo(at.dx, y - h * 0.45)
              ..lineTo(at.dx + half, y)
              ..close(),
            paint,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(SkyPainter old) =>
      old.scroll != scroll || old.maxScroll != maxScroll;
}

/// Los hitos de la subida, dibujados detrás de su lugar: el arco del
/// santuario, el estanque de la fuente, la pagoda del élite y la cumbre.
class LandmarkPainter extends CustomPainter {
  LandmarkPainter(this.layout);

  final MapLayout layout;

  @override
  void paint(Canvas canvas, Size size) {
    for (final MapEntry(key: r, value: mark) in layout.landmarks.entries) {
      final at = layout.pos[layout.rows[r].single.id]!;
      switch (mark) {
        case Landmark.gate:
          _gate(canvas, at);
        case Landmark.pond:
          _pond(canvas, at);
        case Landmark.pagoda:
          _pagoda(canvas, at, size);
        case Landmark.summit:
          _summit(canvas, at);
      }
    }
  }

  void _roof(Canvas canvas, Offset c, double half, double lift, Paint paint) {
    canvas.drawPath(
      Path()
        ..moveTo(c.dx - half, c.dy - lift)
        ..quadraticBezierTo(
          c.dx - half * 0.7,
          c.dy + 2,
          c.dx - half * 0.4,
          c.dy,
        )
        ..lineTo(c.dx + half * 0.4, c.dy)
        ..quadraticBezierTo(
          c.dx + half * 0.7,
          c.dy + 2,
          c.dx + half,
          c.dy - lift,
        )
        ..lineTo(c.dx + half * 0.5, c.dy - lift * 1.6)
        ..lineTo(c.dx - half * 0.5, c.dy - lift * 1.6)
        ..close(),
      paint,
    );
  }

  /// 牌坊: dos columnas laca y un techo de alas levantadas que enmarcan el
  /// santuario.
  void _gate(Canvas canvas, Offset at) {
    final pillar = Paint()..color = Palette.lacquer.withValues(alpha: 0.4);
    final roof = Paint()..color = _inkMid.withValues(alpha: 0.75);
    for (final side in [-1, 1]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: at + Offset(side * 60.0, 14),
            width: 8,
            height: 74,
          ),
          const Radius.circular(2),
        ),
        pillar,
      );
    }
    canvas.drawRect(
      Rect.fromCenter(center: at + const Offset(0, -22), width: 136, height: 5),
      pillar,
    );
    _roof(canvas, at + const Offset(0, -28), 82, 9, roof);
  }

  void _pond(Canvas canvas, Offset at) {
    final c = at + const Offset(0, 46);
    canvas.drawOval(
      Rect.fromCenter(center: c, width: 170, height: 34),
      Paint()..color = Palette.sky.withValues(alpha: 0.16),
    );
    final ripple = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Palette.sky.withValues(alpha: 0.32);
    for (final (dx, wd) in [(-44.0, 36.0), (38.0, 30.0), (0.0, 64.0)]) {
      canvas.drawArc(
        Rect.fromCenter(center: c + Offset(dx, 2), width: wd, height: 8),
        0.2,
        math.pi - 0.4,
        false,
        ripple,
      );
    }
  }

  void _pagoda(Canvas canvas, Offset at, Size size) {
    final side = at.dx < size.width / 2 ? 1 : -1;
    final base = at + Offset(side * 96.0, 40);
    final wall = Paint()..color = Palette.structure.withValues(alpha: 0.16);
    final roof = Paint()..color = _inkMid.withValues(alpha: 0.6);
    for (var tier = 0; tier < 3; tier++) {
      final w = 44.0 - tier * 9;
      final y = base.dy - tier * 26;
      canvas.drawRect(Rect.fromLTWH(base.dx - w / 2, y - 22, w, 22), wall);
      _roof(canvas, Offset(base.dx, y - 20), w * 0.85, 7, roof);
    }
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(base.dx, base.dy - 92),
        width: 2,
        height: 18,
      ),
      roof,
    );
  }

  /// La cumbre entre nubes y, apenas, la silueta del dragón dormido.
  void _summit(Canvas canvas, Offset at) {
    final peak = Path()
      ..moveTo(at.dx - 230, at.dy + 110)
      ..quadraticBezierTo(at.dx - 90, at.dy - 20, at.dx - 18, at.dy - 96)
      ..quadraticBezierTo(at.dx, at.dy - 110, at.dx + 22, at.dy - 92)
      ..quadraticBezierTo(at.dx + 100, at.dy - 10, at.dx + 230, at.dy + 110)
      ..close();
    canvas.drawPath(
      peak,
      Paint()
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(alpha: 0.85),
                const Color(0xFFF3D9B8).withValues(alpha: 0.55),
                const Color(0xFFF3D9B8).withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromLTRB(at.dx - 230, at.dy - 110, at.dx + 230, at.dy + 110),
            ),
    );
    // Solo el filo de la montaña lleva trazo, no la base.
    canvas.drawPath(
      Path()
        ..moveTo(at.dx - 230, at.dy + 110)
        ..quadraticBezierTo(at.dx - 90, at.dy - 20, at.dx - 18, at.dy - 96)
        ..quadraticBezierTo(at.dx, at.dy - 110, at.dx + 22, at.dy - 92)
        ..quadraticBezierTo(at.dx + 100, at.dy - 10, at.dx + 230, at.dy + 110),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..shader =
            LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Palette.gold.withValues(alpha: 0.4),
                Palette.gold.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromLTRB(at.dx - 230, at.dy - 110, at.dx + 230, at.dy + 110),
            ),
    );
    // El dragón: un cuerpo que ondula entre las nubes y se afina hacia la
    // cola, en un solo trazo (sin superposiciones que lo manchen).
    const segs = 48;
    final left = <Offset>[];
    final right = <Offset>[];
    for (var i = 0; i <= segs; i++) {
      final t = i / segs;
      final p = Offset(
        at.dx - 150 + 300 * t,
        at.dy - 128 + math.sin(t * math.pi * 2.4) * 16,
      );
      final slope = math.cos(t * math.pi * 2.4) * 16 * math.pi * 2.4 / 300;
      final n = Offset(-slope, 1) / math.sqrt(1 + slope * slope);
      final half = (1 + 4.5 * (1 - t));
      left.add(p + n * half);
      right.add(p - n * half);
    }
    final body = Path()..addPolygon([...left, ...right.reversed], true);
    canvas.drawPath(
      body,
      Paint()..color = Palette.gold.withValues(alpha: 0.28),
    );
    canvas.drawCircle(
      Offset(at.dx - 152, at.dy - 128),
      7,
      Paint()..color = Palette.gold.withValues(alpha: 0.3),
    );
  }

  @override
  bool shouldRepaint(LandmarkPainter old) => old.layout != layout;
}

/// Nubes que flotan entre los pisos y van y vienen despacio.
class CloudPainter extends CustomPainter {
  CloudPainter({required this.layout, required this.drift})
    : super(repaint: drift);

  final MapLayout layout;
  final Animation<double> drift;

  @override
  void paint(Canvas canvas, Size size) {
    final t = drift.value * 2 * math.pi;
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.62);
    final ys = layout.rowY;
    for (var r = 0; r < ys.length; r++) {
      if (mapHash('cloud$r') < 0.35) continue;
      final y = r + 1 < ys.length ? (ys[r] + ys[r + 1]) / 2 : ys[r] - 80;
      final left = mapHash('side$r') < 0.5;
      final x =
          (left ? size.width * 0.08 : size.width * 0.92) + math.sin(t + r) * 26;
      _cloud(canvas, Offset(x, y), 0.8 + mapHash('size$r') * 0.6, paint);
    }
    // La cumbre siempre entre nubes.
    _cloud(
      canvas,
      Offset(size.width * 0.25 + math.sin(t) * 18, 70),
      1.3,
      paint,
    );
    _cloud(canvas, Offset(size.width * 0.8 - math.sin(t) * 18, 40), 1.1, paint);
  }

  void _cloud(Canvas canvas, Offset c, double s, Paint paint) {
    for (final (dx, dy, r) in [
      (-30.0, 6.0, 16.0),
      (-10.0, -4.0, 22.0),
      (16.0, 0.0, 18.0),
      (36.0, 8.0, 12.0),
    ]) {
      canvas.drawCircle(c + Offset(dx * s, dy * s), r * s, paint);
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: c + Offset(2 * s, 12 * s),
          width: 86 * s,
          height: 14 * s,
        ),
        Radius.circular(7 * s),
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(CloudPainter old) => old.layout != layout;
}

/// Lo que todavía no se ve: los pisos lejanos quedan detrás de la niebla
/// y se despejan a medida que el discípulo sube.
class FogPainter extends CustomPainter {
  FogPainter(this.edge);

  /// Desde esta altura hacia arriba hay niebla.
  final double edge;

  @override
  void paint(Canvas canvas, Size size) {
    if (edge <= 0) return;
    final fog = Palette.surface.withValues(alpha: 0.62);
    canvas.drawRect(
      Rect.fromLTRB(0, 0, size.width, edge - 90),
      Paint()..color = fog,
    );
    canvas.drawRect(
      Rect.fromLTRB(0, edge - 90, size.width, edge),
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fog, fog.withValues(alpha: 0)],
        ).createShader(Rect.fromLTRB(0, edge - 90, size.width, edge)),
    );
  }

  @override
  bool shouldRepaint(FogPainter old) => old.edge != edge;
}
