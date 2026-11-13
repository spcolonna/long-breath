import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';

/// Grano de papel de arroz pintado por shader (shaders/paper.frag) sobre el
/// degradado global. Se carga una vez; si el shader no está (tests viejos,
/// plataforma sin soporte) no pinta nada.
class PaperGrain extends StatefulWidget {
  const PaperGrain({super.key});

  static ui.FragmentProgram? _program;
  static Future<ui.FragmentProgram?>? _loading;

  static Future<ui.FragmentProgram?> load() =>
      _loading ??= ui.FragmentProgram.fromAsset('shaders/paper.frag')
          .then<ui.FragmentProgram?>((p) => _program = p)
          .catchError((Object _) => null);

  @override
  State<PaperGrain> createState() => _PaperGrainState();
}

class _PaperGrainState extends State<PaperGrain> {
  @override
  void initState() {
    super.initState();
    if (PaperGrain._program == null) {
      PaperGrain.load().then((_) {
        if (mounted) setState(() {});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final program = PaperGrain._program;
    if (program == null) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _PaperPainter(program.fragmentShader()),
        ),
      ),
    );
  }
}

class _PaperPainter extends CustomPainter {
  _PaperPainter(this.shader);

  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, 0.37);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_PaperPainter old) => false;
}
