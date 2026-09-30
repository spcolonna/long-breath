import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/model/enums.dart';

/// Paleta de día: papel de arroz, jade claro y acentos saturados.
/// Nada de fondos oscuros: el color da la personalidad.
abstract final class Palette {
  static const bg = Color(0xFFF6EEDC);
  static const bgAlt = Color(0xFFE3F1EC);
  static const surface = Color(0xFFFFFBF2);
  static const line = Color(0xFFD9CBB0);
  static const text = Color(0xFF2B2A33);
  static const textDim = Color(0xFF7A7468);

  /// Texto e íconos sobre rellenos saturados.
  static const onColor = Colors.white;
  static const lacquer = Color(0xFFE8453C);
  static const gold = Color(0xFFE59A12);
  static const jade = Color(0xFF1FA38A);
  static const sky = Color(0xFF3E7BE0);
  static const structure = Color(0xFF9B5DE5);

  /// Degradado de fondo global (papel → jade claro).
  static const backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4DE), bg, bgAlt],
    stops: [0, 0.45, 1],
  );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: Palette.lacquer,
      brightness: Brightness.light,
      surface: Palette.surface,
      onSurface: Palette.text,
      primary: Palette.lacquer,
      onPrimary: Palette.onColor,
      secondary: Palette.jade,
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Palette.text,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: Palette.text,
      displayColor: Palette.text,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.lacquer,
        foregroundColor: Palette.onColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
  );
}

/// Envuelve toda la app con el degradado de fondo (y barra de estado oscura).
Widget backdrop(BuildContext context, Widget? child) =>
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: Palette.backdrop),
        child: child,
      ),
    );

IconData heightIcon(Height? h) => switch (h) {
      Height.high => Icons.north,
      Height.mid => Icons.east,
      Height.low => Icons.south,
      null => Icons.remove,
    };

Color typeColor(CardType t) => switch (t) {
      CardType.fist => Palette.lacquer,
      CardType.palm => Palette.structure,
      CardType.kick => Palette.gold,
      CardType.defense => Palette.sky,
      CardType.technique => Palette.jade,
    };

/// Color de acento según el rango del enemigo (mapa, aura y placa de nombre).
/// Color del camino: tiñe la ropa del héroe, su aura y el selector. El
/// novicio (sin camino) usa el oro del aliento.
Color styleColor(Style? s) => switch (s) {
      null => Palette.gold,
      Style.tiger => Palette.lacquer,
      Style.snake => Palette.structure,
      Style.crane => Palette.sky,
    };

Color rankColor(EnemyRank r) => switch (r) {
      EnemyRank.common => Palette.jade,
      EnemyRank.elite => Palette.structure,
      EnemyRank.boss => Palette.lacquer,
    };
