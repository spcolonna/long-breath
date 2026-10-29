import 'package:flutter/material.dart';
import '../feel.dart';

/// Respuesta al toque compartida: todo lo que se puede tocar se hunde un poco
/// al apoyar el dedo (con un clic háptico suave) y vuelve con un rebote.

/// Hunde a [child] mientras el dedo está apoyado. No consume el toque: va
/// alrededor de cualquier botón, InkWell o GestureDetector.
class Press extends StatefulWidget {
  const Press({
    super.key,
    required this.child,
    this.scale = 0.95,
    this.enabled = true,
    this.haptic = true,
  });

  final Widget child;
  final double scale;
  final bool enabled;
  final bool haptic;

  @override
  State<Press> createState() => _PressState();
}

class _PressState extends State<Press> {
  bool _down = false;

  void _set(bool down) {
    if (!widget.enabled || down == _down) return;
    if (down && widget.haptic) Haptics.selectionClick();
    setState(() => _down = down);
  }

  @override
  Widget build(BuildContext context) => Listener(
    onPointerDown: (_) => _set(true),
    onPointerUp: (_) => _set(false),
    onPointerCancel: (_) => _set(false),
    child: AnimatedScale(
      scale: _down ? widget.scale : 1,
      duration: Duration(milliseconds: _down ? 80 : 260),
      curve: _down ? Curves.easeOut : Curves.easeOutBack,
      child: widget.child,
    ),
  );
}

/// Para el tema de los botones de Material: el contenido se hunde al
/// apretar y suena un clic háptico. Ver `ButtonStyle.foregroundBuilder`.
Widget pressedContent(BuildContext _, Set<WidgetState> states, Widget? child) =>
    _PressedContent(
      pressed: states.contains(WidgetState.pressed),
      disabled: states.contains(WidgetState.disabled),
      child: child,
    );

class _PressedContent extends StatefulWidget {
  const _PressedContent({
    required this.pressed,
    required this.disabled,
    this.child,
  });

  final bool pressed;
  final bool disabled;
  final Widget? child;

  @override
  State<_PressedContent> createState() => _PressedContentState();
}

class _PressedContentState extends State<_PressedContent> {
  @override
  void didUpdateWidget(_PressedContent old) {
    super.didUpdateWidget(old);
    if (widget.pressed && !old.pressed && !widget.disabled) {
      Haptics.selectionClick();
    }
  }

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: widget.pressed ? 0.9 : 1,
    duration: Duration(milliseconds: widget.pressed ? 70 : 240),
    curve: widget.pressed ? Curves.easeOut : Curves.easeOutBack,
    child: widget.child,
  );
}

/// Aparece subiendo y aclarándose, después de [index] × [step]. Sirve para
/// que las listas y opciones de una pantalla entren de a una.
class StaggerIn extends StatefulWidget {
  const StaggerIn({
    super.key,
    required this.index,
    required this.child,
    this.step = const Duration(milliseconds: 70),
    this.delay = Duration.zero,
    this.rise = 18,
    this.scaleFrom = 1,
  });

  final int index;
  final Widget child;
  final Duration step;
  final Duration delay;
  final double rise;

  /// Escala inicial: más de 1 para que baje hacia su lugar (como un sello).
  final double scaleFrom;

  @override
  State<StaggerIn> createState() => _StaggerInState();
}

class _StaggerInState extends State<StaggerIn>
    with SingleTickerProviderStateMixin {
  static const _run = Duration(milliseconds: 420);

  // La espera va dentro de la animación (y no en un Future.delayed): así no
  // quedan temporizadores colgando si la pantalla se cierra antes.
  late final Duration _wait = widget.delay + widget.step * widget.index;
  late final AnimationController _c;
  late final CurvedAnimation _curve;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: _wait + _run)..forward();
    _curve = CurvedAnimation(
      parent: _c,
      curve: Interval(
        _wait.inMicroseconds / (_wait + _run).inMicroseconds,
        1,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void dispose() {
    _curve.dispose();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _curve,
      builder: (_, child) {
        final t = _curve.value;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.rise * (1 - t)),
            child: Transform.scale(
              scale: widget.scaleFrom + (1 - widget.scaleFrom) * t,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Cifra que cuenta hasta su valor nuevo cada vez que cambia. Con [from]
/// arranca contando desde ahí al aparecer (para los totales de un premio).
class CountUp extends StatelessWidget {
  const CountUp({
    super.key,
    required this.value,
    this.from,
    this.style,
    this.format,
    this.duration = const Duration(milliseconds: 500),
  });

  final int value;
  final int? from;
  final TextStyle? style;
  final String Function(int)? format;
  final Duration duration;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: (from ?? value).toDouble(), end: value.toDouble()),
    duration: duration,
    curve: Curves.easeOutCubic,
    builder: (_, v, _) => Text(
      format?.call(v.round()) ?? '${v.round()}',
      style: (style ?? const TextStyle()).copyWith(
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    ),
  );
}
