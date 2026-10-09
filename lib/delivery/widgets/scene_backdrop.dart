import 'package:flutter/material.dart';

import '../theme.dart';
import 'ken_burns.dart';

/// Rutas de un fondo de etapa, de la etapa pedida a la primera (la que
/// siempre tiene arte). Así una etapa sin su propio fondo usa el de la base.
List<String> stageArt(String stageId, String file) => [
  'assets/art/stages/$stageId/$file',
  if (stageId != 'qianyunshan') 'assets/art/stages/qianyunshan/$file',
];

/// Fondo pintado de una pantalla tranquila (fuente, santuario, muro de la
/// escuela). Aparece con un fundido suave, se mueve despacio y lleva un velo
/// de papel para que el texto se lea; si no hay asset, queda el papel.
class SceneBackdrop extends StatelessWidget {
  const SceneBackdrop({
    super.key,
    required this.assets,
    required this.child,
    this.veil = 0.6,
    this.alignment = Alignment.center,
    this.motion = true,
  });

  /// Rutas en orden de preferencia: si una falta, se prueba la siguiente.
  final List<String> assets;
  final Widget child;

  /// Cuánto papel cubre el centro (0 = imagen pura, 1 = papel liso).
  final double veil;
  final Alignment alignment;

  /// Paneo y zoom lentos (Ken Burns).
  final bool motion;

  Widget _image(int i) {
    if (i >= assets.length) return const SizedBox();
    return Image.asset(
      assets[i],
      fit: BoxFit.cover,
      alignment: alignment,
      frameBuilder: (_, img, frame, sync) => sync
          ? img
          : AnimatedOpacity(
              opacity: frame == null ? 0 : 1,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: img,
            ),
      errorBuilder: (_, _, _) => _image(i + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (motion) KenBurns(child: _image(0)) else _image(0),
        // Más velo donde van el título y la interfaz; los bordes respiran.
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Palette.bg.withValues(alpha: veil * 0.4),
                Palette.bg.withValues(alpha: veil),
                Palette.bg.withValues(alpha: veil),
                Palette.bg.withValues(alpha: veil),
                Palette.bg.withValues(alpha: veil * 0.7),
              ],
              stops: const [0, 0.14, 0.3, 0.7, 1],
            ),
          ),
        ),
        child,
      ],
    );
  }
}
