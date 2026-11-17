import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Disuelve a [child] en manchas de tinta (shaders/ink_dissolve.frag) según
/// [progress] 0..1. Sin el shader (tests, plataforma sin soporte) o con
/// "reducir movimiento" se desvanece con opacidad.
class InkDissolve extends StatelessWidget {
  const InkDissolve({super.key, required this.progress, required this.child});

  final double progress;
  final Widget child;

  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram?>? _loading;

  /// Carga el shader una vez (se llama antes de necesitarlo).
  static Future<ui.FragmentProgram?> load() =>
      _loading ??= ui.FragmentProgram.fromAsset('shaders/ink_dissolve.frag')
          .then<ui.FragmentProgram?>((p) => _program = p)
          .catchError((Object _) => null);

  @override
  Widget build(BuildContext context) {
    final program = _program;
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0 || program == null || MediaQuery.disableAnimationsOf(context)) {
      return Opacity(
        opacity: (1 - Curves.easeIn.transform(p)).clamp(0.0, 1.0),
        child: child,
      );
    }
    return ShaderMask(
      blendMode: BlendMode.dstIn,
      shaderCallback: (rect) => program.fragmentShader()
        ..setFloat(0, rect.width)
        ..setFloat(1, rect.height)
        ..setFloat(2, p),
      child: child,
    );
  }
}
