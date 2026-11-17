import 'dart:math' as math;

import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import '../feel.dart';
import '../theme.dart';

/// Pétalos y viento que cruzan el escenario según el Flujo (0–3): nada en 0,
/// unos pocos pétalos en 1, más pétalos y ráfagas en 2, y una tormenta suave
/// con destellos dorados en 3. Entra y sale con un fundido. Con "reducir
/// movimiento" no se dibuja.
class FlowWind extends StatefulWidget {
  const FlowWind({super.key, required this.level, this.color});

  final int level;

  /// Color de los pétalos (el del camino); sin él, flor de cerezo.
  final Color? color;

  /// Cuántos pétalos se ven en cada nivel.
  static const petals = [0, 7, 15, 26];

  @override
  State<FlowWind> createState() => _FlowWindState();
}

class _FlowWindState extends State<FlowWind>
    with TickerProviderStateMixin {
  late final Ticker _ticker = createTicker(_tick);
  final _time = ValueNotifier<double>(0);
  late final _fade = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );
  double _from = 0;
  double _to = 0;
  Duration _last = Duration.zero;

  void _tick(Duration elapsed) {
    final dt = (elapsed - _last).inMicroseconds / 1e6;
    _last = elapsed;
    _time.value += dt;
    // Sin Flujo y ya apagado: no hace falta seguir contando.
    if (_to == 0 && !_fade.isAnimating) {
      _ticker.stop();
      _last = Duration.zero;
    }
  }

  double get _level => _from + (_to - _from) * Curves.easeInOut.transform(_fade.value);

  void _aim() {
    final run = widget.level > 0 && !calm(context);
    final target = run ? widget.level.toDouble() : 0.0;
    if (target == _to) return;
    _from = _level;
    _to = target;
    _fade.forward(from: 0);
    if (target > 0 && !_ticker.isActive) _ticker.start();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _aim();
  }

  @override
  void didUpdateWidget(FlowWind old) {
    super.didUpdateWidget(old);
    if (old.level != widget.level) _aim();
  }

  @override
  void dispose() {
    _ticker.dispose();
    _fade.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _WindPainter(
            time: _time,
            fade: _fade,
            level: () => _level,
            color: widget.color ?? Palette.blossom,
          ),
        ),
      ),
    );
  }
}

class _Petal {
  _Petal(math.Random r)
    : x = r.nextDouble(),
      y = r.nextDouble(),
      speed = 0.05 + r.nextDouble() * 0.07,
      size = 4 + r.nextDouble() * 5,
      phase = r.nextDouble() * math.pi * 2,
      spin = 0.6 + r.nextDouble() * 1.6;

  final double x, y, speed, size, phase, spin;
}

class _WindPainter extends CustomPainter {
  _WindPainter({
    required this.time,
    required Listenable fade,
    required this.level,
    required this.color,
  }) : super(repaint: Listenable.merge([time, fade]));

  final ValueNotifier<double> time;
  final double Function() level;
  final Color color;

  static final _petals = List.generate(26, (_) => _Petal(_rng));
  static final _rng = math.Random(7);

  @override
  void paint(Canvas canvas, Size size) {
    final lv = level();
    if (lv <= 0.01) return;
    final t = time.value;
    // Más Flujo, más viento.
    final wind = 0.7 + 0.35 * lv;
    final count = FlowWind.petals[lv.ceil().clamp(0, 3)];
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final p = _petals[i];
      // Los que entran con el nivel nuevo aparecen de a poco.
      final tier = i < FlowWind.petals[1] ? 1 : (i < FlowWind.petals[2] ? 2 : 3);
      final a = (lv - tier + 1).clamp(0.0, 1.0);
      if (a <= 0) continue;
      final x = ((p.x + t * p.speed * wind) % 1.2 - 0.1) * size.width;
      final y = ((p.y + t * p.speed * 0.35) % 1.0) * size.height * 0.85 +
          math.sin(t * 1.3 + p.phase) * 14;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(t * p.spin + p.phase);
      paint.color = (tier == 3 && i.isEven ? Palette.gold : color)
          .withValues(alpha: 0.55 * a);
      final s = p.size * (0.7 + 0.3 * math.sin(t * p.spin * 2 + p.phase).abs());
      canvas.drawOval(Rect.fromCenter(center: Offset.zero, width: s * 1.8, height: s), paint);
      canvas.restore();
    }
    // Ráfagas: trazos finos que cruzan desde el nivel 2.
    final gust = (lv - 1).clamp(0.0, 2.0) / 2;
    if (gust <= 0) return;
    final line = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 1.6;
    for (var k = 0; k < 4; k++) {
      final cycle = (t * (0.32 + 0.07 * k) + k * 0.27) % 1.0;
      final y0 = size.height * (0.12 + 0.17 * k);
      final x0 = (cycle * 1.6 - 0.4) * size.width;
      final len = size.width * 0.28;
      line.color = Palette.surface.withValues(
          alpha: 0.6 * gust * math.sin(math.pi * cycle));
      final path = Path()
        ..moveTo(x0, y0)
        ..quadraticBezierTo(x0 + len / 2, y0 - 10, x0 + len, y0 + 2);
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(_WindPainter old) => old.color != color;
}
