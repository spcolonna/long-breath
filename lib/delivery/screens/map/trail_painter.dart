import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../domain/run/run_state.dart';
import '../../theme.dart';
import 'map_layout.dart';

const _stone = Color(0xFFE9DEC8);
const _stoneShadow = Color(0xFFB9A98A);

/// El sendero entre los lugares: escalones de piedra que siguen una curva.
/// Lo recorrido queda pintado en tinta dorada; los tramos que se pueden
/// tomar ahora respiran; el resto se ve tenue.
class TrailPainter extends CustomPainter {
  TrailPainter({
    required this.layout,
    required this.run,
    required this.available,
    required this.breath,
    required this.reveal,
  }) : super(repaint: Listenable.merge([breath, reveal]));

  final MapLayout layout;
  final RunState run;
  final Set<String> available;
  final Animation<double> breath;

  /// El último tramo andado se pinta de a poco al volver al mapa.
  final Animation<double> reveal;

  /// Tramo recién recorrido (origen → lugar actual), si hay.
  (String, String)? get lastStep {
    final v = run.visited;
    if (v.length < 2) return null;
    final from = v[v.length - 2];
    final to = v.last;
    return run.node(from).next.contains(to) ? (from, to) : null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final pos = layout.pos;
    final visited = run.visited.toSet();
    final here = run.currentNode;
    final last = lastStep;
    final glow =
        0.45 + 0.55 * (0.5 + 0.5 * math.sin(breath.value * 2 * math.pi));
    final walked = <Path>[];

    // Del pie de la montaña al primer piso.
    for (final id in run.starts) {
      final path = trailPath(layout.foot, pos[id]!, 'foot$id');
      final open = here == null;
      _steps(
        canvas,
        path,
        open ? glow : (visited.contains(id) ? 0.9 : 0.4),
        tint: open ? Palette.gold : null,
        skipStart: 0,
      );
      if (visited.contains(id)) walked.add(path);
    }
    for (final n in run.map) {
      for (final next in n.next) {
        final path = trailPath(pos[n.id]!, pos[next]!, '${n.id}>$next');
        final isWalked = visited.contains(n.id) && visited.contains(next);
        final isOpen = n.id == here && available.contains(next);
        _steps(
          canvas,
          path,
          isOpen ? glow : (isWalked ? 0.9 : 0.4),
          tint: isOpen ? Palette.gold : null,
        );
        if (isWalked && (n.id, next) != last) walked.add(path);
      }
    }
    for (final p in walked) {
      _ink(canvas, p, 1);
    }
    if (last != null) {
      _ink(
        canvas,
        trailPath(pos[last.$1]!, pos[last.$2]!, '${last.$1}>${last.$2}'),
        reveal.value,
      );
    }
  }

  /// Escalones perpendiculares a la curva, con su sombra para el relieve.
  void _steps(
    Canvas canvas,
    Path path,
    double alpha, {
    Color? tint,
    double skipStart = 30,
  }) {
    final shadow = Paint()
      ..color = _stoneShadow.withValues(alpha: 0.55 * alpha);
    final face = Paint()
      ..color = Color.lerp(
        _stone,
        tint ?? _stone,
        0.35,
      )!.withValues(alpha: alpha);
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = _stoneShadow.withValues(alpha: 0.6 * alpha);
    for (final m in path.computeMetrics()) {
      for (var d = skipStart + 4; d < m.length - 30; d += 12) {
        final tan = m.getTangentForOffset(d)!;
        final w = 13 + 3 * mapHash('$d', m.length.round());
        canvas.save();
        canvas.translate(tan.position.dx, tan.position.dy);
        canvas.rotate(-tan.angle + math.pi / 2);
        final r = RRect.fromRectAndRadius(
          Rect.fromCenter(center: Offset.zero, width: w, height: 5.5),
          const Radius.circular(2.2),
        );
        canvas.drawRRect(r.shift(const Offset(0, 1.6)), shadow);
        canvas.drawRRect(r, face);
        canvas.drawRRect(r, edge);
        canvas.restore();
      }
    }
  }

  /// Tinta dorada de grosor variable, como un trazo de pincel.
  void _ink(Canvas canvas, Path path, double upTo) {
    if (upTo <= 0) return;
    final paint = Paint()
      ..strokeCap = StrokeCap.round
      ..color = Palette.gold.withValues(alpha: 0.85);
    for (final m in path.computeMetrics()) {
      final end = (m.length - 28) * upTo;
      Offset? prev;
      for (var d = 26.0; d <= 26 + end; d += 4) {
        final p = m.getTangentForOffset(d)!.position;
        if (prev != null) {
          final t = d / m.length;
          canvas.drawLine(
            prev,
            p,
            paint..strokeWidth = 2.6 + 1.6 * math.sin(t * math.pi),
          );
        }
        prev = p;
      }
    }
  }

  @override
  bool shouldRepaint(TrailPainter old) =>
      old.run != run || old.layout != layout || old.available != available;
}
