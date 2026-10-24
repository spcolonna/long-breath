import 'package:flutter/material.dart';

/// Íconos pintados (`assets/art/icons/`) para los conceptos del combate. Se
/// usa en lugar de [Icon]: si el ícono tiene pintura se ve la pintura, si no
/// (o si falta el archivo) el de Material con su color.
final _painted = {
  Icons.air: 'breath',
  Icons.shield: 'guard',
  Icons.hexagon_outlined: 'structure',
  Icons.filter_tilt_shift: 'deflect',
  Icons.blur_on: 'stagger',
  Icons.water_drop: 'fountain',
};

class GameIcon extends StatelessWidget {
  const GameIcon(this.icon, {super.key, this.size, this.color});

  final IconData? icon;
  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(icon, size: size, color: color);
    final name = _painted[icon];
    if (name == null) return fallback;
    final s = size ?? IconTheme.of(context).size ?? 24;
    return SizedBox.square(
      dimension: s,
      // La pintura deja aire alrededor: se agranda sin ocupar más lugar.
      child: Transform.scale(
        scale: 1.2,
        child: Image.asset(
          'assets/art/icons/$name.webp',
          cacheWidth: (MediaQuery.devicePixelRatioOf(context) * s * 1.2).ceil(),
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, _, _) => fallback,
        ),
      ),
    );
  }
}
