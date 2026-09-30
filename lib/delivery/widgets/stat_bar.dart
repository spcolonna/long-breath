import 'package:flutter/material.dart';

import '../theme.dart';
import 'juice.dart';

/// Barra horizontal con valor actual / máximo.
class StatBar extends StatelessWidget {
  const StatBar({
    super.key,
    required this.label,
    required this.value,
    required this.max,
    required this.color,
    this.height = 14,
  });

  final String label;
  final int value;
  final int max;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        SizedBox(
          width: 74,
          child: Text(label,
              style: const TextStyle(fontSize: 12, color: Palette.textDim)),
        ),
        Expanded(child: TrailBar(ratio: ratio, color: color, height: height)),
        SizedBox(
          width: 56,
          child: Text('$value/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 13, fontFeatures: [FontFeature.tabularFigures()])),
        ),
      ],
    );
  }
}
