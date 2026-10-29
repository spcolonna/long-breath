import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../feel.dart';

/// Dos capas de nubes que cruzan el escenario a distinta velocidad: las de
/// atrás, chicas y lentas; las de adelante, grandes, más transparentes y más
/// rápidas. Da profundidad (parallax) sin arte nuevo.
///
/// Cada capa se dibuja una sola vez (bordes suaves con degradados, sin blur)
/// y después solo se desplaza. Con movimiento reducido quedan quietas.
class CloudDrift extends StatefulWidget {
  const CloudDrift({super.key, this.seed = 0});

  /// Cambia el reparto de las nubes (por ejemplo, según el escenario).
  final int seed;

  @override
  State<CloudDrift> createState() => _CloudDriftState();
}

class _CloudDriftState extends State<CloudDrift>
    with SingleTickerProviderStateMixin {
  // Una vuelta completa de la capa lenta; la rápida da casi dos.
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 120),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _CloudPainter(_c, widget.seed),
      ),
    ),
  );
}

/// Una capa: dónde va en altura, cuánto mide cada nube, cuán visible es y
/// cuántas vueltas da por ciclo.
typedef _Layer = ({
  double top,
  double bottom,
  double scale,
  double alpha,
  int laps,
  int count,
});

const _layers = <_Layer>[
  (top: 0.04, bottom: 0.26, scale: 0.7, alpha: 0.55, laps: 1, count: 4),
  (top: 0.30, bottom: 0.52, scale: 1.25, alpha: 0.32, laps: 2, count: 3),
];

class _CloudPainter extends CustomPainter {
  _CloudPainter(this.t, this.seed) : super(repaint: t);

  final Animation<double> t;
  final int seed;

  Size? _size;
  final _pictures = <ui.Picture>[];

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;
    if (_size != size) {
      for (final p in _pictures) {
        p.dispose();
      }
      _pictures
        ..clear()
        ..addAll([
          for (final (i, l) in _layers.indexed) _record(size, l, seed * 7 + i),
        ]);
      _size = size;
    }
    for (final (i, l) in _layers.indexed) {
      // Cada capa mide dos anchos: se dibuja dos veces seguidas y da la
      // vuelta sin corte.
      final dx = -((t.value * l.laps) % 1) * size.width * 2;
      for (final off in [dx, dx + size.width * 2]) {
        canvas.save();
        canvas.translate(off, 0);
        canvas.drawPicture(_pictures[i]);
        canvas.restore();
      }
    }
  }

  /// Las nubes de una capa repartidas en dos anchos de pantalla.
  ui.Picture _record(Size size, _Layer l, int seed) {
    final rnd = math.Random(seed);
    final rec = ui.PictureRecorder();
    final c = Canvas(rec);
    final unit = size.width * 0.16 * l.scale;
    for (var i = 0; i < l.count; i++) {
      final x = (i + 0.2 + rnd.nextDouble() * 0.6) / l.count * size.width * 2;
      final y = size.height * (l.top + rnd.nextDouble() * (l.bottom - l.top));
      _cloud(
        c,
        Offset(x, y),
        unit * (0.8 + rnd.nextDouble() * 0.5),
        l.alpha,
        rnd,
      );
    }
    return rec.endRecording();
  }

  /// Un cúmulo: varias bolas de borde suave sobre una base achatada.
  void _cloud(Canvas c, Offset at, double u, double alpha, math.Random rnd) {
    void puff(Offset p, double r) {
      final rect = Rect.fromCircle(center: p, radius: r);
      c.drawCircle(
        p,
        r,
        Paint()
          ..shader = RadialGradient(
            colors: [
              Colors.white.withValues(alpha: alpha),
              Colors.white.withValues(alpha: alpha * 0.8),
              Colors.white.withValues(alpha: 0),
            ],
            stops: const [0, 0.6, 1],
          ).createShader(rect),
      );
    }

    // Una fila baja de bolas bien encimadas y, arriba, dos o tres más
    // grandes que le dan la cresta del cúmulo.
    final n = 4 + rnd.nextInt(3);
    for (var i = 0; i < n; i++) {
      final f = i / (n - 1) - 0.5;
      puff(
        at + Offset(f * u * 2.2, rnd.nextDouble() * u * 0.15),
        u * (0.7 + rnd.nextDouble() * 0.3),
      );
    }
    final tops = 2 + rnd.nextInt(2);
    for (var i = 0; i < tops; i++) {
      final f = tops == 1 ? 0.0 : i / (tops - 1) - 0.5;
      puff(
        at +
            Offset(
              (f + (rnd.nextDouble() - 0.5) * 0.2) * u * 1.2,
              -u * (0.45 + rnd.nextDouble() * 0.25),
            ),
        u * (0.85 + rnd.nextDouble() * 0.3),
      );
    }
    // Base ancha y baja para que no parezcan bolitas sueltas.
    // Un círculo estirado: el degradado se achata junto con la forma.
    c.save();
    c.translate(at.dx, at.dy + u * 0.35);
    c.scale(4.6, 1);
    final r = u * 0.45;
    c.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.white.withValues(alpha: alpha * 0.9),
            Colors.white.withValues(alpha: 0),
          ],
        ).createShader(Rect.fromCircle(center: Offset.zero, radius: r)),
    );
    c.restore();
  }

  @override
  bool shouldRepaint(_CloudPainter old) => old.t != t || old.seed != seed;
}
