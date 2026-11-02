import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../feel.dart';
import '../theme.dart';
import 'game_icon.dart';

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
      builder: (context, child) {
        // Con "reducir movimiento" del sistema, la pantalla no se sacude.
        if (!_c.isAnimating || MediaQuery.disableAnimationsOf(context)) {
          return child!;
        }
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
    if (widget.trigger != old.trigger && !calm(context)) _c.forward(from: 0);
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
    this.heavy = false,
  });

  final String text;
  final Color color;
  final double size;
  final IconData? icon;
  final double rise;

  /// Golpe fuerte: salta más, se tuerce un instante, lleva borde dorado y
  /// queda más tiempo a la vista.
  final bool heavy;

  @override
  State<PopText> createState() => _PopTextState();
}

class _PopTextState extends State<PopText> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: widget.heavy ? 1300 : 1000),
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
    final still = calm(context);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final opacity = t < 0.65 ? 1.0 : 1 - (t - 0.65) / 0.35;
        // Sin movimiento: aparece en su lugar y se desvanece.
        if (still) return Opacity(opacity: opacity.clamp(0, 1), child: child);
        final peak = widget.heavy ? 1.7 : 1.35;
        final pop = t < 0.18
            ? Curves.easeOutBack.transform(t / 0.18) * peak
            : peak -
                  (peak - 1) *
                      Curves.easeOut.transform(math.min(1, (t - 0.18) / 0.2));
        // El fuerte sube menos: pesa.
        final rise =
            -widget.rise *
            (widget.heavy ? 0.6 : 1) *
            Curves.easeOutCubic.transform(t);
        final tilt = widget.heavy && t < 0.3
            ? math.sin(t / 0.3 * math.pi * 2) * 0.09 * (1 - t / 0.3)
            : 0.0;
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Transform.translate(
            offset: Offset(0, rise),
            child: Transform.rotate(
              angle: tilt,
              child: Transform.scale(scale: pop, child: child),
            ),
          ),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.icon != null)
            Padding(
              padding: const EdgeInsets.only(right: 2),
              child: GameIcon(
                widget.icon,
                size: widget.size * 0.7,
                color: widget.color,
              ),
            ),
          if (widget.heavy)
            Stack(
              children: [
                Text(
                  widget.text,
                  style: style.copyWith(
                    color: null,
                    shadows: const [
                      Shadow(color: Color(0x66FFFFFF), blurRadius: 14),
                    ],
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = widget.size * 0.14
                      ..strokeJoin = StrokeJoin.round
                      ..color = Palette.gold,
                  ),
                ),
                Text(widget.text, style: style.copyWith(shadows: const [])),
              ],
            )
          else
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
    if (widget.trigger != old.trigger && !calm(context)) _c.forward(from: 0);
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

/// Una pintura de efecto (`assets/art/vfx/`) que aparece, crece, gira un poco
/// y se desvanece cada vez que cambia [trigger]. La imagen queda siempre
/// cargada (invisible) para que el primer golpe no espere a decodificarla; si
/// el archivo falta, no se dibuja nada.
class ArtBurst extends StatefulWidget {
  const ArtBurst({
    super.key,
    required this.trigger,
    required this.asset,
    required this.size,
    this.duration = const Duration(milliseconds: 600),
    this.from = 0.55,
    this.to = 1.1,
    this.spin = 0.35,
    this.hold = 0.35,
  });

  final int trigger;
  final String asset;
  final double size;
  final Duration duration;

  /// Escala al aparecer y al terminar.
  final double from;
  final double to;

  /// Cuánto gira en total (radianes).
  final double spin;

  /// Parte de la animación en que se ve entera antes de desvanecerse.
  final double hold;

  @override
  State<ArtBurst> createState() => _ArtBurstState();
}

class _ArtBurstState extends State<ArtBurst>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration);

  @override
  void didUpdateWidget(ArtBurst old) {
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
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final image = Image.asset(
      widget.asset,
      width: widget.size,
      height: widget.size,
      cacheWidth: (widget.size * dpr).ceil(),
      gaplessPlayback: true,
      errorBuilder: (_, _, _) => const SizedBox(),
    );
    // Centrada en el espacio que le den, sin estirarse ni empujar a nadie.
    return IgnorePointer(
      child: AnimatedBuilder(
        animation: _c,
        child: Center(
          child: OverflowBox(
            minWidth: widget.size,
            maxWidth: widget.size,
            minHeight: widget.size,
            maxHeight: widget.size,
            child: image,
          ),
        ),
        builder: (context, child) {
          final t = _c.value;
          final on = _c.isAnimating;
          // Sin movimiento: el efecto se ve quieto y se desvanece.
          final e = calm(context) ? 1.0 : Curves.easeOutCubic.transform(t);
          final fadeIn = (t / 0.12).clamp(0.0, 1.0);
          final fadeOut = t < widget.hold
              ? 1.0
              : 1 - (t - widget.hold) / (1 - widget.hold);
          return Opacity(
            opacity: on ? (fadeIn * fadeOut).clamp(0.0, 1.0) : 0,
            child: Transform.rotate(
              angle: widget.spin * e,
              child: Transform.scale(
                scale: widget.from + (widget.to - widget.from) * e,
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
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
        builder: (context, _) {
          if (!_c.isAnimating || MediaQuery.disableAnimationsOf(context)) {
            return const SizedBox.expand();
          }
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

/// Remate: un trazo de pincel cruza la pantalla en diagonal y un sello con
/// [hanzi] cae en el centro, cada vez que cambia [trigger]. Para el golpe
/// que tumba a una élite o a un jefe. Sin movimiento, solo aparece el sello.
class FinisherSeal extends StatefulWidget {
  const FinisherSeal({
    super.key,
    required this.trigger,
    this.hanzi = '破',
    this.color = Palette.lacquer,
    this.size = 120,
  });

  final int trigger;
  final String hanzi;
  final Color color;
  final double size;

  static const duration = Duration(milliseconds: 1250);

  @override
  State<FinisherSeal> createState() => _FinisherSealState();
}

class _FinisherSealState extends State<FinisherSeal>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: FinisherSeal.duration,
  );

  @override
  void didUpdateWidget(FinisherSeal old) {
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
    final still = calm(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            if (!_c.isAnimating) return const SizedBox.expand();
            final t = _c.value;
            final fade = t < 0.75 ? 1.0 : 1 - (t - 0.75) / 0.25;
            // El sello cae después del trazo: grande, y asienta con rebote.
            final st = ((t - 0.12) / 0.22).clamp(0.0, 1.0);
            final scale = still
                ? 1.0
                : 2.4 - 1.4 * Curves.easeOutBack.transform(st);
            return Opacity(
              opacity: fade.clamp(0, 1),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (!still)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _SlashPainter(
                          progress: Curves.easeOutCubic.transform(
                            (t / 0.16).clamp(0, 1),
                          ),
                          color: widget.color,
                        ),
                      ),
                    ),
                  if (still || st > 0)
                    Opacity(
                      opacity: still ? 1 : st.clamp(0, 1),
                      child: Transform.scale(
                        scale: scale,
                        child: Transform.rotate(
                          angle: -0.08,
                          child: _sealBox(),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _sealBox() {
    final s = widget.size;
    return Container(
      width: s,
      height: s,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: widget.color,
        borderRadius: BorderRadius.circular(s * 0.14),
        border: Border.all(color: Palette.gold, width: s * 0.04),
        boxShadow: [
          BoxShadow(
            color: widget.color.withValues(alpha: 0.45),
            blurRadius: s * 0.35,
          ),
        ],
      ),
      child: Text(
        widget.hanzi,
        style: TextStyle(
          fontSize: s * 0.62,
          height: 1,
          fontWeight: FontWeight.w900,
          color: Colors.white,
        ),
      ),
    );
  }
}

/// Trazo de pincel de esquina a esquina: grueso en el medio, fino en las
/// puntas, que avanza con [progress].
class _SlashPainter extends CustomPainter {
  _SlashPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0) return;
    final a = Offset(size.width * -0.1, size.height * 0.62);
    final b = Offset(size.width * 1.1, size.height * 0.30);
    final dir = b - a;
    final n = Offset(-dir.dy, dir.dx) / dir.distance;
    const steps = 24;
    final w = size.shortestSide * 0.07;
    final top = <Offset>[];
    final bottom = <Offset>[];
    for (var i = 0; i <= steps; i++) {
      final u = i / steps * progress;
      final p = a + dir * u;
      final k = math.sin(math.pi * (i / steps)) * w;
      top.add(p + n * k);
      bottom.add(p - n * k * 0.6);
    }
    final path = Path()..addPolygon([...top, ...bottom.reversed], true);
    canvas.drawPath(path, Paint()..color = color.withValues(alpha: 0.85));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = Palette.gold.withValues(alpha: 0.7),
    );
  }

  @override
  bool shouldRepaint(_SlashPainter old) => old.progress != progress;
}

/// Contador de golpes seguidos en el turno: aparece desde el segundo, salta
/// y crece con cada golpe (tinta, laca y oro) y se apaga al cerrar el turno.
/// Sin movimiento, solo cambia el número.
class ComboCounter extends StatefulWidget {
  const ComboCounter({super.key, required this.count, required this.label});

  /// Golpes del turno; por debajo de 2 no se muestra.
  final int count;

  /// Lo que va debajo del número («golpes»).
  final String label;

  static const shownFrom = 2;

  /// Color del contador según la cadena: más larga, más caliente.
  static Color colorOf(int n) =>
      n >= 5 ? Palette.gold : (n >= 4 ? Palette.lacquer : Palette.text);

  @override
  State<ComboCounter> createState() => _ComboCounterState();
}

class _ComboCounterState extends State<ComboCounter>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 420),
    value: 1,
  );

  /// El último número mostrado: queda mientras el contador se desvanece.
  late int _last = widget.count;

  @override
  void didUpdateWidget(ComboCounter old) {
    super.didUpdateWidget(old);
    if (widget.count >= ComboCounter.shownFrom) {
      _last = widget.count;
      if (widget.count > old.count) _c.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final shown = widget.count >= ComboCounter.shownFrom;
    final n = math.max(_last, ComboCounter.shownFrom);
    final color = ComboCounter.colorOf(n);
    final size = math.min(30.0 + (n - 2) * 7, 58.0);
    final still = calm(context);
    final stroke = n >= 5
        ? (Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = size * 0.12
            ..color = Colors.white)
        : null;
    final number = TextStyle(
      fontSize: size,
      fontWeight: FontWeight.w900,
      height: 1,
      color: color,
      shadows: const [
        Shadow(color: Colors.white, blurRadius: 2),
        Shadow(color: Colors.white, blurRadius: 8),
      ],
    );
    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: shown ? 1 : 0,
        duration: Duration(milliseconds: shown ? 120 : 500),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, child) {
            if (still) return child!;
            // Salta grande y asienta; de 5 en adelante tiembla un poco.
            final t = _c.value;
            final scale = 1 + 0.6 * (1 - Curves.easeOutBack.transform(t));
            final wobble = n >= 5
                ? math.sin(t * math.pi * 4) * 0.08 * (1 - t)
                : 0.0;
            return Transform.rotate(
              angle: wobble,
              child: Transform.scale(scale: scale, child: child),
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                children: [
                  if (stroke != null)
                    Text(
                      '$n',
                      style: number.copyWith(
                        foreground: stroke,
                        color: null,
                        shadows: const [],
                      ),
                    ),
                  Text('$n', style: number),
                ],
              ),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                  color: color,
                  shadows: const [Shadow(color: Colors.white, blurRadius: 6)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
