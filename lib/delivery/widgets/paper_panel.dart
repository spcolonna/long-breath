import 'package:flutter/material.dart';

import '../theme.dart';

/// Papel claro para todo texto que va sobre arte pintado: sin él, la letra
/// fina se pierde en el fondo. Regla de la casa (docs/feel.md): nada de texto
/// suelto sobre una ilustración.
class PaperPanel extends StatelessWidget {
  const PaperPanel({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.radius = 16,
    this.opacity = 0.93,
    this.accent,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final double opacity;

  /// Color del borde; por defecto el dorado suave del papel.
  final Color? accent;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Palette.surface.withValues(alpha: opacity),
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(
        color: (accent ?? Palette.gold).withValues(alpha: 0.45),
        width: 1.2,
      ),
      boxShadow: [
        BoxShadow(
          color: Palette.text.withValues(alpha: 0.10),
          blurRadius: 14,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Padding(padding: padding, child: child),
  );
}
