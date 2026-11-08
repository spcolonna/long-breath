import 'package:flutter/material.dart';

import '../theme.dart';

/// Marco para toda zona desplazable: delimita dónde empieza y termina la
/// lista y funde los bordes mientras quede contenido arriba o abajo, así nada
/// se corta en seco contra el borde de la pantalla.
///
/// Con [framed] (por defecto) dibuja una tablilla de papel con borde dorado y
/// recorta el contenido adentro. Sin marco, solo funde los bordes (para
/// pantallas que desplazan apenas en teléfonos chicos).
class ScrollPanel extends StatefulWidget {
  const ScrollPanel({
    super.key,
    required this.child,
    this.framed = true,
    this.opacity = 0.72,
    this.radius = 18,
    this.margin = EdgeInsets.zero,
    this.fade = 28,
    this.hug = false,
  });

  /// La lista o el `SingleChildScrollView`.
  final Widget child;
  final bool framed;

  /// Opacidad del papel del marco.
  final double opacity;
  final double radius;
  final EdgeInsetsGeometry margin;

  /// Alto del fundido en cada borde.
  final double fade;

  /// El marco abraza el contenido cuando es corto (arriba, sin hueco vacío
  /// abajo). La lista tiene que usar `shrinkWrap: true`.
  final bool hug;

  @override
  State<ScrollPanel> createState() => _ScrollPanelState();
}

class _ScrollPanelState extends State<ScrollPanel> {
  bool _above = false;
  bool _below = false;

  bool _check(ScrollMetrics m) {
    if (m.axis != Axis.vertical) return false;
    final above = m.extentBefore > 2;
    final below = m.extentAfter > 2;
    if (above != _above || below != _below) {
      setState(() {
        _above = above;
        _below = below;
      });
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final fadeStops = widget.fade;
    Widget list = NotificationListener<ScrollMetricsNotification>(
      onNotification: (n) => n.depth == 0 && _check(n.metrics),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) => n.depth == 0 && _check(n.metrics),
        child: widget.child,
      ),
    );
    list = ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (r) {
        final f = r.height <= 0 ? 0.0 : (fadeStops / r.height).clamp(0.0, 0.3);
        return LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            _above ? Colors.transparent : Colors.white,
            Colors.white,
            Colors.white,
            _below ? Colors.transparent : Colors.white,
          ],
          stops: [0, f, 1 - f, 1],
        ).createShader(r);
      },
      child: list,
    );
    if (!widget.framed) return Padding(padding: widget.margin, child: list);
    final radius = BorderRadius.circular(widget.radius);
    final framed = Padding(
      padding: widget.margin,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.surface.withValues(alpha: widget.opacity),
          borderRadius: radius,
          border: Border.all(
            color: Palette.gold.withValues(alpha: 0.5),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: Palette.text.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(borderRadius: radius, child: list),
      ),
    );
    return widget.hug
        ? Align(alignment: Alignment.topCenter, child: framed)
        : framed;
  }
}
