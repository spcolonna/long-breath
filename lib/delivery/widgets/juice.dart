import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme.dart';

/// Piezas de "feel" reutilizables: sacudidas, rebotes, números que saltan,
/// estallidos de tinta y barras con estela.

/// Sacude a [child] cada vez que cambia [trigger].
class Shake extends StatefulWidget {
  const Shake({
    super.key,
    required this.trigger,
    required this.child,
    this.strength = 8,
  });

  final int trigger;
  final double strength;
  final Widget child;

  @override
  State<Shake> createState() => _ShakeState();
}

class _ShakeState extends State<Shake> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
  );

  @override
  void didUpdateWidget(Shake old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        if (!_c.isAnimating) return child!;
        final t = _c.value;
        final decay = (1 - t) * (1 - t);
        final s = widget.strength * decay;
        return Transform.translate(
          offset: Offset(
            math.sin(t * math.pi * 11) * s,
            math.cos(t * math.pi * 8) * s * 0.5,
          ),
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

/// Rebota (escala) cuando cambia [trigger]. No rebota al aparecer.
class Bounce extends StatefulWidget {
  const Bounce({
    super.key,
    required this.trigger,
    required this.child,
    this.scale = 1.18,
  });

  final Object? trigger;
  final double scale;
  final Widget child;

  @override
  State<Bounce> createState() => _BounceState();
}

class _BounceState extends State<Bounce> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 380),
  );

  @override
  void didUpdateWidget(Bounce old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        // Sube rápido y vuelve con un pequeño rebote.
        final k = t < 0.3
            ? Curves.easeOut.transform(t / 0.3)
            : 1 - Curves.elasticOut.transform((t - 0.3) / 0.7);
        return Transform.scale(scale: 1 + (widget.scale - 1) * k, child: child);
      },
      child: widget.child,
    );
  }
}

/// Número (o texto corto) que salta, sube y se desvanece una sola vez.
class PopText extends StatefulWidget {
  const PopText({
    super.key,
    required this.text,
    required this.color,
    this.size = 30,
    this.icon,
    this.rise = 56,
  });

  final String text;
  final Color color;
  final double size;
  final IconData? icon;
  final double rise;

  @override
  State<PopText> createState() => _PopTextState();
}

class _PopTextState extends State<PopText> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1000),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final style = TextStyle(
      fontSize: widget.size,
      fontWeight: FontWeight.w900,
      color: widget.color,
      height: 1,
      shadows: const [
        Shadow(color: Colors.white, blurRadius: 2),
        Shadow(color: Colors.white, blurRadius: 8),
      ],
    );
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final pop = t < 0.18
            ? Curves.easeOutBack.transform(t / 0.18) * 1.35
            : 1.35 -
                  0.35 *
                      Curves.easeOut.transform(math.min(1, (t - 0.18) / 0.2));
        final rise = -widget.rise * Curves.easeOutCubic.transform(t);
        final opacity = t < 0.65 ? 1.0 : 1 - (t - 0.65) / 0.35;
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, rise),
            child: Transform.scale(scale: pop, child: child),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: Icon(
                widget.icon,
                size: widget.size * 0.7,
                color: widget.color,
              ),
            ),
          Text(widget.text, style: style),
        ],
      ),
    );
  }
}

/// Estallido de gotas de tinta que salen desde el centro, cada vez que cambia
/// [trigger].
class InkBurst extends StatefulWidget {
  const InkBurst({
    super.key,
    required this.trigger,
    required this.colors,
    this.count = 22,
    this.radius = 120,
    this.duration = const Duration(milliseconds: 750),
  });

  final int trigger;
  final List<Color> colors;
  final int count;
  final double radius;
  final Duration duration;

  @override
  State<InkBurst> createState() => _InkBurstState();
}

class _InkBurstState extends State<InkBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(InkBurst old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) => !_c.isAnimating
            ? const SizedBox.expand()
            : CustomPaint(
                size: Size.infinite,
                painter: _BurstPainter(
                  t: _c.value,
                  seed: widget.trigger,
                  colors: widget.colors,
                  count: widget.count,
                  radius: widget.radius,
                ),
              ),
      ),
    );
  }
}

class _BurstPainter extends CustomPainter {
  _BurstPainter({
    required this.t,
    required this.seed,
    required this.colors,
    required this.count,
    required this.radius,
  });

  final double t;
  final int seed;
  final List<Color> colors;
  final int count;
  final double radius;

  @override
  void paint(Canvas canvas, Size size) {
    final rnd = math.Random(seed);
    final c = size.center(Offset.zero);
    final e = Curves.easeOutCubic.transform(t);
    // Anillo de onda.
    canvas.drawCircle(
      c,
      radius * 0.9 * e,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6 * (1 - t)
        ..color = colors.first.withValues(alpha: 0.6 * (1 - t)),
    );
    for (var i = 0; i < count; i++) {
      final a = rnd.nextDouble() * math.pi * 2;
      final d = radius * (0.45 + rnd.nextDouble() * 0.7) * e;
      final r = (3 + rnd.nextDouble() * 7) * (1 - t * 0.85);
      final p = c + Offset(math.cos(a) * d, math.sin(a) * d + 30 * t * t);
      canvas.drawCircle(
        p,
        r,
        Paint()
          ..color = colors[i % colors.length].withValues(
            alpha: (1 - t).clamp(0, 1),
          ),
      );
    }
  }

  @override
  bool shouldRepaint(_BurstPainter old) => old.t != t;
}

/// Destello de pantalla completa (viñeta de color) cada vez que cambia [trigger].
class ScreenFlash extends StatefulWidget {
  const ScreenFlash({super.key, required this.trigger, required this.color});

  final int trigger;
  final Color color;

  @override
  State<ScreenFlash> createState() => _ScreenFlashState();
}

class _ScreenFlashState extends State<ScreenFlash>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );

  @override
  void didUpdateWidget(ScreenFlash old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, _) {
          if (!_c.isAnimating) return const SizedBox.expand();
          final a = (1 - _c.value) * 0.4;
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                radius: 0.95,
                colors: [
                  widget.color.withValues(alpha: 0),
                  widget.color.withValues(alpha: a),
                ],
                stops: const [0.55, 1],
              ),
            ),
            child: const SizedBox.expand(),
          );
        },
      ),
    );
  }
}

/// Barra con estela: al bajar, el tramo perdido queda un instante en blanco y
/// después se consume; al subir, se llena con suavidad.
class TrailBar extends StatefulWidget {
  const TrailBar({
    super.key,
    required this.ratio,
    required this.color,
    this.height = 12,
    this.background,
  });

  final double ratio;
  final Color color;
  final double height;
  final Color? background;

  @override
  State<TrailBar> createState() => _TrailBarState();
}

class _TrailBarState extends State<TrailBar> with TickerProviderStateMixin {
  late final _front = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 180),
    value: widget.ratio,
  );
  late final _trail = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 840),
    value: widget.ratio,
  );
  late final _flash = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 300),
  );

  @override
  void didUpdateWidget(TrailBar old) {
    super.didUpdateWidget(old);
    final r = widget.ratio;
    if (r == old.ratio) return;
    if (r < old.ratio) {
      _front.animateTo(r, curve: Curves.easeOut);
      _flash.forward(from: 0);
      // La estela espera un instante antes de consumirse.
      _trail.animateTo(
        r,
        curve: const Interval(0.38, 1, curve: Curves.easeInOut),
      );
    } else {
      _trail.value = r;
      _front.animateTo(
        r,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _front.dispose();
    _trail.dispose();
    _flash.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final h = widget.height;
    return ClipRRect(
      borderRadius: BorderRadius.circular(h / 2),
      child: SizedBox(
        height: h,
        child: AnimatedBuilder(
          animation: Listenable.merge([_front, _trail, _flash]),
          builder: (_, _) {
            final flash = _flash.isAnimating ? 1 - _flash.value : 0.0;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(color: widget.background ?? Palette.line),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: math.max(_trail.value, _front.value).clamp(0, 1),
                  child: ColoredBox(
                    color: Color.lerp(widget.color, Colors.white, 0.65)!,
                  ),
                ),
                FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _front.value.clamp(0, 1),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color.lerp(
                            widget.color,
                            Colors.white,
                            0.25 + 0.5 * flash,
                          )!,
                          Color.lerp(widget.color, Colors.white, 0.6 * flash)!,
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Matriz de saturación para [ColorFilter.matrix] (1 = color normal, 0 = gris).
List<double> saturationMatrix(double s) {
  const r = 0.2126, g = 0.7152, b = 0.0722;
  final i = 1 - s;
  return [
    r * i + s, g * i, b * i, 0, 0, //
    r * i, g * i + s, b * i, 0, 0, //
    r * i, g * i, b * i + s, 0, 0, //
    0, 0, 0, 1, 0,
  ];
}
