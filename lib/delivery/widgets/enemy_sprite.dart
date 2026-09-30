import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../domain/model/enemy_def.dart';
import '../theme.dart';

/// Figura del enemigo en la arena.
///
/// Busca `assets/art/enemies/<id>.png`, después el placeholder común y, si no
/// hay imágenes, dibuja una silueta. El aura del color del rango distingue a
/// los enemigos aunque compartan imagen. Reacciona a golpes ([hitKey]), a sus
/// propios ataques ([attackKey]: amague y embestida), a guardias o cargas
/// ([pulseKey]), al Desequilibrio y a la derrota ([dying]).
class EnemySprite extends StatefulWidget {
  const EnemySprite({
    super.key,
    required this.def,
    required this.staggered,
    required this.hitKey,
    required this.attackKey,
    this.pulseKey = 0,
    this.heavyHit = false,
    this.dying = false,
    this.size = 200,
  });

  final EnemyDef def;
  final bool staggered;
  final int hitKey;
  final int attackKey;
  final int pulseKey;

  /// El último golpe fue fuerte: más retroceso.
  final bool heavyHit;
  final bool dying;
  final double size;

  /// Desde que empieza el ataque hasta que el golpe llega al héroe.
  static const impactDelay = Duration(milliseconds: 330);

  @override
  State<EnemySprite> createState() => _EnemySpriteState();
}

class _EnemySpriteState extends State<EnemySprite>
    with TickerProviderStateMixin {
  late final _idle = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat(reverse: true);
  late final _hit = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 480),
  );
  late final _attack = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 620),
  );
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
  );
  late final _death = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didUpdateWidget(EnemySprite old) {
    super.didUpdateWidget(old);
    if (widget.hitKey != old.hitKey) _hit.forward(from: 0);
    if (widget.attackKey != old.attackKey) _attack.forward(from: 0);
    if (widget.pulseKey != old.pulseKey) _pulse.forward(from: 0);
    if (widget.dying && !old.dying) _death.forward(from: 0);
  }

  @override
  void dispose() {
    _idle.dispose();
    _hit.dispose();
    _attack.dispose();
    _pulse.dispose();
    _death.dispose();
    super.dispose();
  }

  /// Amague hacia atrás, embestida rápida hacia el jugador y regreso.
  (double dy, double scale) _attackPose(double t) {
    if (t == 0 || t == 1) return (0, 0);
    if (t < 0.4) {
      final k = Curves.easeOut.transform(t / 0.4);
      return (-10 * k, -0.05 * k);
    }
    if (t < 0.53) {
      final k = Curves.easeIn.transform((t - 0.4) / 0.13);
      return (-10 + 40 * k, -0.05 + 0.25 * k);
    }
    if (t < 0.62) return (30, 0.2);
    final k = Curves.easeOutCubic.transform((t - 0.62) / 0.38);
    return (30 * (1 - k), 0.2 * (1 - k));
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final accent = rankColor(widget.def.rank);
    final figure = _Figure(def: widget.def, size: size, accent: accent);
    return AnimatedBuilder(
      animation: Listenable.merge([_idle, _hit, _attack, _pulse, _death]),
      builder: (context, child) {
        final idle = Curves.easeInOut.transform(_idle.value);
        final h = _hit.value;
        final hitting = _hit.isAnimating;
        // Hit-stop: los primeros cuadros quedan congelados en blanco y aplastados.
        const stop = 0.16;
        final after = h < stop ? 0.0 : (h - stop) / (1 - stop);
        final shake = hitting && h >= stop
            ? math.sin(after * math.pi * 6) *
                  (widget.heavyHit ? 14 : 9) *
                  (1 - after)
            : 0.0;
        final knock = hitting
            ? (h < stop ? 1.0 : 1 - Curves.easeOut.transform(after))
            : 0.0;
        final flash = hitting ? (h < stop ? 0.9 : 0.9 * (1 - after)) : 0.0;
        final squash = hitting ? 0.06 * knock : 0.0;
        final (atkDy, atkScale) = _attackPose(_attack.value);
        final pulse = math.sin(math.pi * _pulse.value);
        final d = _death.value;
        final dying = widget.dying;
        final wobble = widget.staggered
            ? -0.08 + 0.05 * math.sin(_idle.value * math.pi * 2)
            : 0.0;
        final breathe = 1 + 0.02 * idle;
        return SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              // Aura del rango.
              Opacity(
                opacity: dying ? (1 - d).clamp(0, 1) : 1,
                child: Container(
                  width: size * (0.95 + 0.15 * pulse),
                  height: size * (0.95 + 0.15 * pulse),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        accent.withValues(
                          alpha: 0.35 + 0.1 * idle + 0.3 * pulse + 0.3 * flash,
                        ),
                        accent.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
              ),
              Opacity(
                opacity: dying
                    ? (1 - Curves.easeIn.transform(d)).clamp(0, 1)
                    : 1,
                child: Transform.translate(
                  offset: Offset(
                    shake,
                    atkDy - (widget.heavyHit ? 16 : 8) * knock - 26 * d,
                  ),
                  child: Transform.rotate(
                    angle:
                        wobble +
                        (dying ? 0.12 * Curves.easeOut.transform(d) : 0),
                    child: Transform.scale(
                      scaleX:
                          breathe + atkScale + 0.08 * pulse + squash + 0.25 * d,
                      scaleY:
                          breathe + atkScale + 0.08 * pulse - squash + 0.25 * d,
                      alignment: Alignment.bottomCenter,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.white.withValues(
                            alpha: dying ? math.max(flash, d) : flash,
                          ),
                          BlendMode.srcATop,
                        ),
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
              if (widget.staggered && !dying)
                Positioned(
                  top: size * 0.02,
                  child: _DizzyStars(progress: _idle.value, width: size * 0.4),
                ),
            ],
          ),
        );
      },
      child: figure,
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.def, required this.size, required this.accent});

  final EnemyDef def;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final silhouette = _Silhouette(def: def, size: size, accent: accent);
    return Image.asset(
      'assets/art/enemies/${def.art}.png',
      width: size,
      height: size,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) => Image.asset(
        'assets/art/enemies/placeholder.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => silhouette,
      ),
    );
  }
}

/// Silueta de respaldo: un luchador en guardia con el hanzi en el pecho.
class _Silhouette extends StatelessWidget {
  const _Silhouette({
    required this.def,
    required this.size,
    required this.accent,
  });

  final EnemyDef def;
  final double size;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final glyph = (def.hanzi ?? '敌').characters.first;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: Size.square(size),
            painter: _FighterPainter(accent),
          ),
          Align(
            alignment: const Alignment(0, 0.02),
            child: Text(
              glyph,
              style: TextStyle(
                fontSize: size * 0.16,
                fontWeight: FontWeight.w700,
                color: Palette.onColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FighterPainter extends CustomPainter {
  _FighterPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final body = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.lerp(color, Colors.white, 0.15)!,
          Color.lerp(color, Palette.text, 0.35)!,
        ],
      ).createShader(Offset.zero & size);
    final limb = Paint()
      ..color = Color.lerp(color, Palette.text, 0.25)!
      ..strokeWidth = w * 0.075
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    // Piernas en postura abierta.
    canvas.drawLine(
      Offset(w * 0.45, w * 0.66),
      Offset(w * 0.3, w * 0.92),
      limb,
    );
    canvas.drawLine(
      Offset(w * 0.55, w * 0.66),
      Offset(w * 0.7, w * 0.92),
      limb,
    );
    // Brazos en guardia.
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.38, w * 0.36)
        ..lineTo(w * 0.24, w * 0.46)
        ..lineTo(w * 0.3, w * 0.3),
      limb,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w * 0.62, w * 0.36)
        ..lineTo(w * 0.78, w * 0.42)
        ..lineTo(w * 0.74, w * 0.26),
      limb,
    );
    // Torso y cabeza.
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.36, w * 0.3, w * 0.28, w * 0.4),
        Radius.circular(w * 0.1),
      ),
      body,
    );
    canvas.drawCircle(Offset(w * 0.5, w * 0.2), w * 0.1, body);
    // Faja.
    canvas.drawRect(
      Rect.fromLTWH(w * 0.36, w * 0.56, w * 0.28, w * 0.04),
      Paint()..color = Palette.gold,
    );
  }

  @override
  bool shouldRepaint(_FighterPainter old) => old.color != color;
}

class _DizzyStars extends StatelessWidget {
  const _DizzyStars({required this.progress, required this.width});

  final double progress;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: Stack(
        children: [
          for (var i = 0; i < 3; i++)
            Builder(
              builder: (_) {
                final a = (progress + i / 3) * 2 * math.pi;
                return Positioned(
                  left: width / 2 - 9 + math.cos(a) * width * 0.4,
                  top: 4 + math.sin(a) * 6,
                  child: const Icon(
                    Icons.star_rounded,
                    size: 18,
                    color: Palette.gold,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
