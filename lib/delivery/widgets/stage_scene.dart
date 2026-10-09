import 'package:flutter/material.dart';

import 'ken_burns.dart';

/// Archivo de cada escenario (`combat_bg_<archivo>.png`). Lo que no figura
/// (la terraza, el patio colgado, el paso nevado) usa el fondo común de la
/// etapa, y también lo usa una variante que la etapa todavía no tiene.
const _sceneFiles = {
  'bambu': 'ladera',
  'cristales': 'bifurcacion',
  'campanas': 'templo',
  'cumbre': 'cumbre',
  'pasarela': 'bifurcacion',
  'escalera': 'ladera',
  'campanario': 'templo',
  'gran_campana': 'templo',
  'ventisquero': 'ladera',
  'glaciar': 'bifurcacion',
  'templo_helado': 'templo',
  'lecho_dragon': 'cumbre',
};

/// Altura de la franja visible de cada fondo (-1 arriba, 1 abajo): el suelo
/// tiene que quedar bajo los pies.
const _variantFocus = {'templo': 0.45};

/// Rutas del fondo de combate de un escenario, de la variante al común.
List<String> combatBgAssets(String stageId, String? scene) => [
  if (_sceneFiles[scene] != null)
    'assets/art/stages/$stageId/combat_bg_${_sceneFiles[scene]}.png',
  'assets/art/stages/$stageId/combat_bg.png',
];

/// Escenario de combate a sangre: el fondo de la etapa con la luz del
/// momento, que respira despacio. Si falta el arte, un cielo de degradado.
class StageScene extends StatelessWidget {
  const StageScene({
    super.key,
    required this.stageId,
    required this.scene,
    this.light,
    this.alignment,
    this.motion = true,
  });

  final String stageId;
  final String? scene;
  final String? light;

  /// Qué parte de la imagen queda a la vista cuando se recorta (por defecto,
  /// la del escenario).
  final Alignment? alignment;
  final bool motion;

  static const _sky = DecoratedBox(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFBFE3F2), Color(0xFFE8F4EA), Color(0xFFF3E7C9)],
      ),
    ),
  );

  Widget _image(List<String> assets, int i) {
    if (i >= assets.length) return _sky;
    return Image.asset(
      assets[i],
      fit: BoxFit.cover,
      alignment:
          alignment ?? Alignment(0, _variantFocus[_sceneFiles[scene]] ?? 0),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => _image(assets, i + 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final image = _image(combatBgAssets(stageId, scene), 0);
    return Stack(
      fit: StackFit.expand,
      children: [
        if (motion)
          KenBurns(zoom: 1.06, child: image)
        else
          RepaintBoundary(child: image),
        LightWash(light: light),
      ],
    );
  }
}

/// La luz del momento sobre el fondo: el mismo lugar se siente distinto al
/// alba, entre la niebla o al caer la tarde. Siempre claro, nunca de noche,
/// y liviana: el escenario se tiene que ver.
class LightWash extends StatelessWidget {
  const LightWash({super.key, required this.light});

  final String? light;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: switch (light) {
        'niebla' => Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.30),
                    Colors.white.withValues(alpha: 0.08),
                    Colors.white.withValues(alpha: 0.14),
                  ],
                  stops: const [0, 0.55, 1],
                ),
              ),
            ),
            const _MistDrift(),
          ],
        ),
        'ocaso' => DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFFFF9A62).withValues(alpha: 0.22),
                const Color(0xFFF7A8C4).withValues(alpha: 0.10),
                const Color(0xFFFFD9A0).withValues(alpha: 0.06),
              ],
            ),
          ),
        ),
        // Alba: un brillo tibio que entra por un costado.
        _ => DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: const Alignment(-0.9, -0.9),
              radius: 1.3,
              colors: [
                const Color(0xFFFFE6C2).withValues(alpha: 0.30),
                const Color(0xFFFFE6C2).withValues(alpha: 0),
              ],
            ),
          ),
        ),
      },
    );
  }
}

/// Bancos de niebla que cruzan despacio el escenario.
class _MistDrift extends StatefulWidget {
  const _MistDrift();

  @override
  State<_MistDrift> createState() => _MistDriftState();
}

class _MistDriftState extends State<_MistDrift>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 24),
  )..repeat();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(child: CustomPaint(painter: _MistPainter(_c)));
  }
}

class _MistPainter extends CustomPainter {
  _MistPainter(this.t) : super(repaint: t);

  final Animation<double> t;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 28);
    // Tres bancos a distintas alturas y velocidades; dan la vuelta al salir.
    const banks = [(0.30, 1.0, 0.9), (0.55, 0.6, 1.2), (0.78, 1.4, 1.0)];
    for (final (i, (y, speed, scale)) in banks.indexed) {
      final w = size.width * 0.8 * scale;
      final x = ((t.value * speed + i / 3) % 1) * (size.width + w) - w;
      canvas.drawOval(
        Rect.fromLTWH(x, size.height * y, w, size.height * 0.12 * scale),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_MistPainter old) => false;
}
