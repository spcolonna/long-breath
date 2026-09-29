import 'package:flutter/material.dart';

import '../domain/model/enums.dart';

/// Paleta: tinta, papel, laca roja y oro.
abstract final class Palette {
  static const ink = Color(0xFF15110E);
  static const inkSoft = Color(0xFF231C17);
  static const inkLine = Color(0xFF3A2F27);
  static const paper = Color(0xFFF1E6CF);
  static const paperDim = Color(0xFFB9AC95);
  static const lacquer = Color(0xFFB8322A);
  static const gold = Color(0xFFD9A441);
  static const jade = Color(0xFF4F9A7E);
  static const sky = Color(0xFF5B8DB8);
  static const structure = Color(0xFFC98A3A);
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lacquer,
      brightness: Brightness.dark,
      surface: Palette.ink,
      primary: Palette.gold,
      secondary: Palette.lacquer,
    ),
    scaffoldBackgroundColor: Palette.ink,
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Palette.paper,
      displayColor: Palette.paper,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.lacquer,
        foregroundColor: Palette.paper,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

String heightLabel(Height? h) => switch (h) {
      Height.high => 'alto',
      Height.mid => 'medio',
      Height.low => 'bajo',
      null => '—',
    };

IconData heightIcon(Height? h) => switch (h) {
      Height.high => Icons.north,
      Height.mid => Icons.east,
      Height.low => Icons.south,
      null => Icons.remove,
    };

String typeLabel(CardType t) => switch (t) {
      CardType.fist => 'Puño',
      CardType.palm => 'Palma',
      CardType.kick => 'Patada',
      CardType.defense => 'Defensa',
      CardType.technique => 'Técnica',
    };

Color typeColor(CardType t) => switch (t) {
      CardType.fist => Palette.lacquer,
      CardType.palm => Palette.structure,
      CardType.kick => Palette.gold,
      CardType.defense => Palette.sky,
      CardType.technique => Palette.jade,
    };
