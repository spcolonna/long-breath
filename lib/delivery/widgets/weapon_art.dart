import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers.dart';
import '../theme.dart';

/// Color de la borla según el nivel: jade, cobalto y oro.
Color weaponColor(int level) => switch (level) {
  >= 3 => Palette.gold,
  2 => Palette.sky,
  _ => Palette.jade,
};

/// Cómo está hecha la imagen de cada arma (vertical 1:3, punta arriba):
/// dónde la toma la mano (fracción de su alto), dónde cuelga la borla, su
/// largo respecto del alto del héroe y cuánto se inclina hacia el rival.
class WeaponShape {
  const WeaponShape({
    required this.grip,
    required this.tassel,
    required this.length,
    required this.angle,
  });

  final double grip;
  final double tassel;
  final double length;
  final double angle;
}

const weaponShapes = <String, WeaponShape>{
  'gun': WeaponShape(grip: 0.58, tassel: 0.14, length: 0.95, angle: 0.75),
  'jian': WeaponShape(grip: 0.74, tassel: 0.88, length: 0.62, angle: 0.4),
  'pudao': WeaponShape(grip: 0.72, tassel: 0.40, length: 0.95, angle: 0.35),
};

WeaponShape weaponShapeOf(String id) =>
    weaponShapes[id] ??
    const WeaponShape(grip: 0.7, tassel: 0.8, length: 0.8, angle: 0.4);

/// Dónde está la mano adelantada del héroe, en fracciones de su sprite (los
/// cuatro sprites comparten silueta; si alguno cambia, va acá).
const heroHand = Offset(0.72, 0.40);

/// Un arma de pie, de alto [height]: su imagen si existe y, si no, dibujada
/// por código. La borla (del color del nivel) se mece con [sway] (−1 a 1) y
/// el nivel 3 brilla.
class WeaponArt extends ConsumerWidget {
  const WeaponArt({
    super.key,
    required this.id,
    required this.level,
    required this.height,
    this.sway = 0,
  });

  final String id;
  final int level;
  final double height;
  final double sway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final art = ref.watch(weaponArtProvider).value?.contains(id) ?? false;
    final width = height / 3;
    final shape = weaponShapeOf(id);
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _AuraPainter(level: level),
        foregroundPainter: _TasselPainter(
          at: shape.tassel,
          level: level,
          sway: sway,
        ),
        child: art
            ? Image.asset(
                'assets/art/weapons/$id.webp',
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
              )
            : CustomPaint(painter: WeaponPainter(id)),
      ),
    );
  }
}

/// Las tres armas dibujadas a pincel liso, con la punta arriba.
class WeaponPainter extends CustomPainter {
  const WeaponPainter(this.id);

  final String id;

  static const _steel = [Color(0xFFF4F7FA), Color(0xFFB7C1CC)];
  static const _wood = [Color(0xFF9C4A2E), Color(0xFFC9714A)];
  static const _wrap = Color(0xFF3A2F2A);

  @override
  void paint(Canvas canvas, Size size) {
    final h = size.height;
    final cx = size.width / 2;
    switch (id) {
      case 'gun':
        _staff(canvas, cx, h);
      case 'jian':
        _sword(canvas, cx, h);
      case 'pudao':
        _pudao(canvas, cx, h);
    }
  }

  Paint _fill(Rect r, List<Color> colors) => Paint()
    ..shader = LinearGradient(colors: colors).createShader(r);

  Paint get _outline => Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2
    ..color = Palette.text.withValues(alpha: 0.55);

  void _ring(Canvas canvas, double cx, double y, double w, double h) {
    final r = Rect.fromCenter(center: Offset(cx, y), width: w, height: h);
    final rr = RRect.fromRectAndRadius(r, Radius.circular(h / 2));
    canvas.drawRRect(rr, Paint()..color = Palette.gold);
    canvas.drawRRect(rr, _outline);
  }

  void _staff(Canvas canvas, double cx, double h) {
    final t = h * 0.034;
    final r = Rect.fromLTRB(cx - t / 2, h * 0.02, cx + t / 2, h * 0.98);
    final rr = RRect.fromRectAndRadius(r, Radius.circular(t / 2));
    canvas.drawRRect(rr, _fill(r, _wood));
    canvas.drawRRect(rr, _outline);
    for (final y in const [0.06, 0.94]) {
      _ring(canvas, cx, h * y, t * 1.35, h * 0.03);
    }
    for (final y in const [0.36, 0.46]) {
      _ring(canvas, cx, h * y, t * 1.25, h * 0.014);
    }
  }

  void _sword(Canvas canvas, double cx, double h) {
    final w = h * 0.05;
    final base = h * 0.62;
    final blade = Path()
      ..moveTo(cx, h * 0.02)
      ..lineTo(cx + w / 2, h * 0.08)
      ..lineTo(cx + w / 2, base)
      ..lineTo(cx - w / 2, base)
      ..lineTo(cx - w / 2, h * 0.08)
      ..close();
    canvas.drawPath(blade, _fill(blade.getBounds(), _steel));
    canvas.drawPath(blade, _outline);
    canvas.drawLine(
      Offset(cx, h * 0.06),
      Offset(cx, base - h * 0.01),
      Paint()
        ..color = const Color(0xFF8C97A4)
        ..strokeWidth = 1,
    );
    // Guarda, empuñadura con cordón y pomo.
    _ring(canvas, cx, base + h * 0.012, h * 0.15, h * 0.026);
    final grip = Rect.fromLTRB(cx - w * 0.36, base + h * 0.025, cx + w * 0.36,
        h * 0.86);
    canvas.drawRect(grip, Paint()..color = _wrap);
    final cord = Paint()
      ..color = Palette.lacquer.withValues(alpha: 0.8)
      ..strokeWidth = 1.2;
    for (var y = grip.top + 3; y < grip.bottom - 2; y += 5) {
      canvas.drawLine(Offset(grip.left, y), Offset(grip.right, y + 3), cord);
    }
    canvas.drawCircle(Offset(cx, h * 0.88), h * 0.022,
        Paint()..color = Palette.gold);
    canvas.drawCircle(Offset(cx, h * 0.88), h * 0.022, _outline);
  }

  void _pudao(Canvas canvas, double cx, double h) {
    final t = h * 0.03;
    final shaft = Rect.fromLTRB(cx - t / 2, h * 0.38, cx + t / 2, h * 0.98);
    final rr = RRect.fromRectAndRadius(shaft, Radius.circular(t / 2));
    canvas.drawRRect(rr, _fill(shaft, _wood));
    canvas.drawRRect(rr, _outline);
    // Hoja ancha: lomo recto del lado del mango y filo curvo hacia afuera.
    final back = cx - t / 2;
    final blade = Path()
      ..moveTo(back, h * 0.40)
      ..lineTo(back, h * 0.06)
      ..quadraticBezierTo(back + h * 0.03, h * 0.01, back + h * 0.09, h * 0.03)
      ..quadraticBezierTo(back + h * 0.16, h * 0.18, back + h * 0.11, h * 0.36)
      ..lineTo(back + h * 0.05, h * 0.40)
      ..close();
    canvas.drawPath(blade, _fill(blade.getBounds(), _steel));
    canvas.drawPath(blade, _outline);
    canvas.drawLine(
      Offset(back + h * 0.012, h * 0.08),
      Offset(back + h * 0.012, h * 0.38),
      Paint()
        ..color = const Color(0xFF8C97A4)
        ..strokeWidth = 1.4,
    );
    _ring(canvas, cx, h * 0.41, t * 1.6, h * 0.026);
    _ring(canvas, cx, h * 0.97, t * 1.3, h * 0.02);
  }

  @override
  bool shouldRepaint(WeaponPainter old) => old.id != id;
}

/// Borla de seda (穗 suì) colgando del arma, del color del nivel. Desde el
/// nivel 2 suma una cinta.
class _TasselPainter extends CustomPainter {
  const _TasselPainter({
    required this.at,
    required this.level,
    required this.sway,
  });

  final double at;
  final int level;
  final double sway;

  @override
  void paint(Canvas canvas, Size size) {
    if (level <= 0) return;
    final h = size.height;
    final top = Offset(size.width / 2, h * at);
    final len = h * 0.14;
    final angle = sway * 0.35;
    final end = top + Offset(math.sin(angle), math.cos(angle)) * len;
    final color = weaponColor(level);
    canvas.drawLine(
      top,
      end,
      Paint()
        ..color = color
        ..strokeWidth = 1.6,
    );
    if (level >= 2) {
      final ribbon = Path()
        ..moveTo(top.dx, top.dy)
        ..quadraticBezierTo(
          top.dx + len * 0.6 + sway * len * 0.3,
          top.dy + len * 0.5,
          top.dx + len * 0.35 + sway * len * 0.5,
          top.dy + len * 1.15,
        );
      canvas.drawPath(
        ribbon,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.4
          ..strokeCap = StrokeCap.round
          ..color = Palette.lacquer.withValues(alpha: 0.85),
      );
    }
    // El mechón: gota de hilos con un nudo arriba.
    canvas.drawCircle(end, h * 0.012, Paint()..color = color);
    final drop = Path()
      ..moveTo(end.dx - h * 0.012, end.dy)
      ..lineTo(end.dx - h * 0.02 + sway * 2, end.dy + h * 0.07)
      ..lineTo(end.dx + h * 0.02 + sway * 2, end.dy + h * 0.07)
      ..lineTo(end.dx + h * 0.012, end.dy)
      ..close();
    canvas.drawPath(drop, Paint()..color = color.withValues(alpha: 0.9));
  }

  @override
  bool shouldRepaint(_TasselPainter old) =>
      old.sway != sway || old.level != level || old.at != at;
}

/// Halo dorado del nivel 3 (degradado, sin blur).
class _AuraPainter extends CustomPainter {
  const _AuraPainter({required this.level});

  final int level;

  @override
  void paint(Canvas canvas, Size size) {
    if (level < 3) return;
    // Un resplandor angosto a lo largo del arma, no un disco.
    final rect = Rect.fromCenter(
      center: size.center(Offset.zero),
      width: size.width * 1.1,
      height: size.height * 1.05,
    );
    canvas.drawOval(
      rect,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Palette.gold.withValues(alpha: 0.28),
            Palette.gold.withValues(alpha: 0),
          ],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_AuraPainter old) => old.level != level;
}
