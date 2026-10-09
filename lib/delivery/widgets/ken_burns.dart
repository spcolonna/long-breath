import 'package:flutter/material.dart';

/// Paneo y zoom lentos sobre un fondo, ida y vuelta: el escenario respira
/// sin distraer. Quieto si el sistema pide reducir el movimiento.
class KenBurns extends StatefulWidget {
  const KenBurns({
    super.key,
    required this.child,
    this.zoom = 1.08,
    this.from = const Alignment(-0.3, 0.2),
    this.to = const Alignment(0.3, -0.2),
    this.duration = const Duration(seconds: 26),
  });

  final Widget child;

  /// Escala máxima (1 = sin zoom).
  final double zoom;

  /// Hacia dónde se acerca la cámara al principio y al final del paneo.
  final Alignment from;
  final Alignment to;
  final Duration duration;

  @override
  State<KenBurns> createState() => _KenBurnsState();
}

class _KenBurnsState extends State<KenBurns>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c.stop();
    } else if (!_c.isAnimating) {
      _c.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: ClipRect(
        child: AnimatedBuilder(
          animation: _c,
          child: widget.child,
          builder: (_, child) {
            final t = Curves.easeInOut.transform(_c.value);
            return Transform.scale(
              scale: 1 + (widget.zoom - 1) * (0.35 + 0.65 * t),
              alignment: Alignment.lerp(widget.from, widget.to, t)!,
              child: child,
            );
          },
        ),
      ),
    );
  }
}
