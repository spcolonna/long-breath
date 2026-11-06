import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../feel.dart';
import '../theme.dart';

/// Envuelve una lista desplazable: mientras quede contenido abajo, el borde
/// inferior se funde con [fade] y aparece una píldora «Hay más abajo» que
/// sube y baja. Al tocarla, baja un tramo. Desaparece al empezar a bajar.
class MoreBelowHint extends StatefulWidget {
  const MoreBelowHint({
    super.key,
    required this.controller,
    required this.label,
    required this.child,
    this.fade,
    this.fadeHeight = 70,
  });

  final ScrollController controller;
  final String label;
  /// Color del fundido. Sin color (sobre un fondo con imagen), el contenido
  /// mismo se desvanece hacia abajo.
  final Color? fade;
  final double fadeHeight;

  /// La lista; debe usar [controller].
  final Widget child;

  @override
  State<MoreBelowHint> createState() => _MoreBelowHintState();
}

class _MoreBelowHintState extends State<MoreBelowHint> {
  bool _more = false;

  void _check(ScrollMetrics m) {
    final more = m.extentAfter > 40 && m.pixels < 30;
    if (more != _more) setState(() => _more = more);
  }

  void _down() {
    Haptics.selectionClick();
    final c = widget.controller;
    if (!c.hasClients) return;
    c.animateTo(
      math.min(c.position.maxScrollExtent, c.offset + 320),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        NotificationListener<ScrollMetricsNotification>(
          onNotification: (n) {
            _check(n.metrics);
            return false;
          },
          child: NotificationListener<ScrollNotification>(
            onNotification: (n) {
              _check(n.metrics);
              return false;
            },
            child: widget.fade != null
                ? widget.child
                : ShaderMask(
                    blendMode: BlendMode.dstIn,
                    shaderCallback: (r) => LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: const [Colors.white, Colors.white, Colors.transparent],
                      stops: [
                        0,
                        _more ? 1 - widget.fadeHeight * 1.4 / r.height : 1,
                        1,
                      ],
                    ).createShader(r),
                    child: widget.child,
                  ),
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: IgnorePointer(
            ignoring: !_more,
            child: AnimatedOpacity(
              opacity: _more ? 1 : 0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                height: widget.fadeHeight,
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: 8),
                decoration: widget.fade == null
                    ? null
                    : BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [widget.fade!.withValues(alpha: 0), widget.fade!],
                        ),
                      ),
                child: MoreBelowPill(label: widget.label, onTap: _down),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Píldora verde con flecha doble que late hacia abajo.
class MoreBelowPill extends StatefulWidget {
  const MoreBelowPill({super.key, required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  State<MoreBelowPill> createState() => _MoreBelowPillState();
}

class _MoreBelowPillState extends State<MoreBelowPill>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _c, reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, child) => Transform.translate(
          offset: Offset(0, 4 * Curves.easeInOut.transform(_c.value)),
          child: child,
        ),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 6, 10, 6),
          decoration: BoxDecoration(
            color: Palette.jade,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Palette.jade.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.label,
                style: const TextStyle(
                  color: Palette.onColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              const Icon(
                Icons.keyboard_double_arrow_down,
                color: Palette.onColor,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
