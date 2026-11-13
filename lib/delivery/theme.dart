import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../domain/model/enums.dart';
import 'widgets/paper_grain.dart';
import 'widgets/press.dart';

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

  /// Flor de durazno: los eventos del mapa.
  static const blossom = Color(0xFFE76F9A);

  /// Halo de papel para letras cortas que van sobre una ilustración.
  static const halo = [
    Shadow(color: Color(0xF2FFFBF2), blurRadius: 4),
    Shadow(color: Color(0xCCFFFBF2), blurRadius: 12),
  ];

  /// Degradado de fondo global (papel → jade claro).
  static const backdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFFFFF4DE), bg, bgAlt],
    stops: [0, 0.45, 1],
  );
}

/// Tipografías de la casa: serif caligráfica para leer, romana de títulos y
/// pincel para los hanzi (entra sola como respaldo de cualquier texto).
abstract final class Fonts {
  static const body = 'Alegreya';
  static const display = 'Cormorant';
  static const brush = 'MaShanZheng';
  static const fallback = [brush];
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    fontFamily: Fonts.body,
    fontFamilyFallback: Fonts.fallback,
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
    textTheme: base.textTheme
        .apply(
          bodyColor: Palette.text,
          displayColor: Palette.text,
          fontFamily: Fonts.body,
        )
        .copyWith(
          displayLarge: base.textTheme.displayLarge?.copyWith(
            fontFamily: Fonts.display,
          ),
          displayMedium: base.textTheme.displayMedium?.copyWith(
            fontFamily: Fonts.display,
          ),
          displaySmall: base.textTheme.displaySmall?.copyWith(
            fontFamily: Fonts.display,
          ),
          headlineLarge: base.textTheme.headlineLarge?.copyWith(
            fontFamily: Fonts.display,
          ),
          headlineMedium: base.textTheme.headlineMedium?.copyWith(
            fontFamily: Fonts.display,
          ),
          headlineSmall: base.textTheme.headlineSmall?.copyWith(
            fontFamily: Fonts.display,
          ),
        ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: Palette.lacquer,
        foregroundColor: Palette.onColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ).copyWith(foregroundBuilder: pressedContent),
    ),
    // Botones secundarios con cuerpo de papel: sobre una ilustración nunca
    // quedan transparentes (docs/feel.md).
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        backgroundColor: Palette.surface.withValues(alpha: 0.95),
        foregroundColor: Palette.text,
        side: BorderSide(
          color: Palette.gold.withValues(alpha: 0.6),
          width: 1.3,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        elevation: 2,
        shadowColor: Palette.text.withValues(alpha: 0.25),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ).copyWith(foregroundBuilder: pressedContent),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        backgroundColor: Palette.surface.withValues(alpha: 0.88),
        shape: const StadiumBorder(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ).copyWith(foregroundBuilder: pressedContent),
    ),
    elevatedButtonTheme: const ElevatedButtonThemeData(
      style: ButtonStyle(foregroundBuilder: pressedContent),
    ),
  );
}

/// Desplazamiento de la casa: barra fina dorada que aparece al mover (solo
/// en vertical) y rebote al llegar al borde en todas las plataformas.
class GameScrollBehavior extends MaterialScrollBehavior {
  const GameScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) =>
      const BouncingScrollPhysics();

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    if (axisDirectionToAxis(details.direction) != Axis.vertical) return child;
    return RawScrollbar(
      controller: details.controller,
      thumbColor: Palette.gold.withValues(alpha: 0.7),
      thickness: 3,
      radius: const Radius.circular(3),
      mainAxisMargin: 6,
      crossAxisMargin: 2,
      fadeDuration: const Duration(milliseconds: 250),
      timeToFade: const Duration(milliseconds: 700),
      child: child,
    );
  }
}

/// Envuelve toda la app con el degradado de fondo (y barra de estado oscura).
Widget backdrop(BuildContext context, Widget? child) =>
    AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: DecoratedBox(
        decoration: const BoxDecoration(gradient: Palette.backdrop),
        // Grano de papel entre el degradado y las pantallas.
        child: Stack(
          fit: StackFit.expand,
          children: [const PaperGrain(), ?child],
        ),
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
