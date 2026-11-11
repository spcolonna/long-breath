import 'package:flutter/material.dart';

import '../../domain/model/enums.dart';
import '../feel.dart';
import '../theme.dart';
import 'hero_sprite.dart';

/// Metros con separador de miles («1.240 m»).
String meters(int m) {
  final s = m.abs().toString();
  final out = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) out.write('.');
    out.write(s[i]);
  }
  return '${m < 0 ? '-' : ''}$out m';
}

/// La subida de la etapa: una regla vertical de oro con una marca por sala,
/// los hitos (élite, fuente, jefe) tallados a su altura y la cabeza del
/// discípulo donde está. Al volver de una sala, la cabeza sube desde la
/// marca anterior.
class AltitudeBar extends StatelessWidget {
  const AltitudeBar({
    super.key,
    required this.depths,
    required this.climbed,
    required this.altitude,
    required this.summit,
    this.milestones = const {},
    this.style,
  });

  /// Salas de la etapa.
  final int depths;

  /// Salas ya pisadas.
  final int climbed;

  /// Metros de ahora y de la cima de la etapa.
  final int altitude;
  final int summit;

  /// Profundidad (0 = la primera) → carácter del hito (精 泉 龙).
  final Map<int, String> milestones;
  final Style? style;

  @override
  Widget build(BuildContext context) {
    final target = depths <= 0 ? 0.0 : climbed / depths;
    final from = depths <= 0 ? 0.0 : (climbed - 1).clamp(0, depths) / depths;
    return LayoutBuilder(
      builder: (context, box) {
        final h = box.maxHeight;
        const top = 22.0;
        const bottom = 10.0;
        final track = h - top - bottom;
        double yOf(double p) => top + track * (1 - p);
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: calm(context) ? target : from, end: target),
          duration: const Duration(milliseconds: 1100),
          curve: Curves.easeInOutCubic,
          builder: (context, p, _) => Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Text(
                  meters(summit),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Palette.textDim,
                  ),
                ),
              ),
              Positioned(
                top: top,
                bottom: bottom,
                left: 0,
                right: 0,
                child: CustomPaint(
                  painter: _TrackPainter(
                    depths: depths,
                    climbed: climbed,
                    progress: p,
                  ),
                ),
              ),
              for (final m in milestones.entries)
                Positioned(
                  top: yOf((m.key + 1) / depths) - 11,
                  right: 0,
                  child: _Milestone(hanzi: m.value, reached: m.key < climbed),
                ),
              Positioned(
                top: yOf(p) - 15,
                left: 0,
                child: _Head(style: style),
              ),
              Positioned(
                top: yOf(p) + 16,
                left: -6,
                right: -30,
                child: Text(
                  meters(altitude),
                  maxLines: 1,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: Palette.text,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Head extends StatelessWidget {
  const _Head({this.style});

  final Style? style;

  @override
  Widget build(BuildContext context) => Container(
    width: 30,
    height: 30,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      color: Palette.surface,
      border: Border.all(color: Palette.gold, width: 2),
      boxShadow: const [
        BoxShadow(
          color: Color(0x33806A45),
          blurRadius: 6,
          offset: Offset(0, 2),
        ),
      ],
    ),
    clipBehavior: Clip.antiAlias,
    child: OverflowBox(
      maxHeight: 60,
      alignment: Alignment.topCenter,
      child: Image.asset(
        heroAsset(style),
        height: 60,
        fit: BoxFit.fitHeight,
        errorBuilder: (_, _, _) =>
            const Icon(Icons.person_rounded, size: 18, color: Palette.text),
      ),
    ),
  );
}

class _Milestone extends StatelessWidget {
  const _Milestone({required this.hanzi, required this.reached});

  final String hanzi;
  final bool reached;

  @override
  Widget build(BuildContext context) => Container(
    width: 22,
    height: 22,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(5),
      color: reached ? Palette.gold : Palette.surface,
      border: Border.all(color: Palette.gold, width: 1.5),
    ),
    child: Text(
      hanzi,
      style: TextStyle(
        fontSize: 13,
        height: 1,
        fontWeight: FontWeight.w700,
        color: reached ? Palette.surface : Palette.gold,
      ),
    ),
  );
}

class _TrackPainter extends CustomPainter {
  _TrackPainter({
    required this.depths,
    required this.climbed,
    required this.progress,
  });

  final int depths;
  final int climbed;
  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const w = 6.0;
    final x = 15.0 - w / 2;
    final track = RRect.fromRectAndRadius(
      Rect.fromLTWH(x, 0, w, size.height),
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = Palette.line);
    final fill = size.height * progress.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(x, size.height - fill, w, fill),
        const Radius.circular(3),
      ),
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Palette.gold, Color(0xFFF2C76B)],
        ).createShader(Rect.fromLTWH(x, 0, w, size.height)),
    );
    if (depths <= 0) return;
    for (var d = 1; d <= depths; d++) {
      final y = size.height * (1 - d / depths);
      canvas.drawCircle(
        Offset(15, y),
        2.6,
        Paint()
          ..color = d <= climbed
              ? Palette.gold
              : Palette.textDim.withValues(alpha: 0.45),
      );
    }
  }

  @override
  bool shouldRepaint(_TrackPainter old) =>
      old.progress != progress ||
      old.climbed != climbed ||
      old.depths != depths;
}
