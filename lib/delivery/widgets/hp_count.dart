import 'package:flutter/material.dart';

import '../theme.dart';
import 'juice.dart';
import 'press.dart';

/// Vida de la run: corazón con la cifra, que cuenta hasta el valor nuevo y
/// rebota al cambiar (como el jade y el loto).
class HpCount extends StatelessWidget {
  const HpCount({super.key, required this.hp, required this.maxHp});

  final int hp;
  final int maxHp;

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      const Icon(Icons.favorite, color: Palette.jade, size: 18),
      const SizedBox(width: 4),
      Bounce(
        trigger: '$hp/$maxHp',
        scale: 1.3,
        child: CountUp(
          value: hp,
          format: (v) => '$v/$maxHp',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    ],
  );
}
