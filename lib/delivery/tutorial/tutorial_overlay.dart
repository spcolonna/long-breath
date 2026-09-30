import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_event.dart';
import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../providers.dart';
import '../theme.dart';
import 'illustrations.dart';
import 'lessons.dart';
import 'tutorial_anchor.dart';
import 'tutorial_steps.dart';

/// Guía de una lección: oscurece la pantalla menos la zona que explica el
/// maestro y, en los pasos que esperan una jugada, solo deja tocar esa zona.
class TutorialOverlay extends ConsumerStatefulWidget {
  const TutorialOverlay({super.key});

  /// Postura que pide el paso actual: Paso en T solo ofrece esa, para que
  /// no se pueda elegir otra y trabar la lección.
  static final stanceGate = ValueNotifier<Stance?>(null);

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _visible = true;
  Timer? _delay;
  Rect? _hole;

  /// Solo la primera zona del paso recibe toques (la carta, no su vista previa).
  Rect? _tapHole;

  // Las cartas se reacomodan con animación: el foco las sigue cuadro a cuadro.
  late final Ticker _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((_) => _track())..start();
  }

  @override
  void dispose() {
    TutorialOverlay.stanceGate.value = null;
    _ticker.dispose();
    _delay?.cancel();
    super.dispose();
  }

  List<TutorialStep> _steps() {
    final id = ref.read(combatControllerProvider)?.lessonId;
    if (id == null) return const [];
    return lessonById(id).steps?.call(AppLocalizations.of(context)) ?? const [];
  }

  void _track() {
    final steps = _steps();
    final me = context.findRenderObject();
    Rect? hole, tapHole;
    if (_visible &&
        _step < steps.length &&
        steps[_step].anchor != null &&
        me is RenderBox) {
      // La vista previa de una carta solo existe mientras está seleccionada.
      for (final id in steps[_step].anchor!.split('+')) {
        final r = TutorialAnchor.rectOf(id, me);
        if (r == null || r.isEmpty) continue;
        tapHole ??= r;
        hole = hole?.expandToInclude(r) ?? r;
      }
    }
    if (hole != _hole || tapHole != _tapHole) {
      setState(() {
        _hole = hole;
        _tapHole = tapHole;
      });
    }
  }

  void _advance(List<TutorialStep> steps) {
    final next = _step + 1;
    TutorialOverlay.stanceGate.value = next < steps.length ? steps[next].waitStance : null;
    final delay = next < steps.length ? steps[next].delayMs : 0;
    _delay?.cancel();
    setState(() {
      _step = next;
      _visible = delay == 0;
    });
    ref.read(audioProvider).play(Sfx.uiButton);
    if (delay > 0) {
      _delay = Timer(Duration(milliseconds: delay), () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  /// ¿La jugada que acaba de pasar es la que el paso esperaba?
  bool _fulfilled(TutorialStep step, CombatView? prev, CombatView next) {
    final s = next.state;
    if (step.waitSelect != null && next.selected != null) {
      if (s.handCard(next.selected!)?.cardId == step.waitSelect) return true;
    }
    if (next.seq == prev?.seq) return false;
    final ev = next.events;
    return (step.waitCard != null &&
            ev.any((e) => e is CardPlayed && e.cardId == step.waitCard)) ||
        (step.waitTurn != null && s.turn >= step.waitTurn!) ||
        (step.waitStance != null &&
            ev.any((e) => e is StanceChanged && e.stance == step.waitStance)) ||
        (step.waitBreathe &&
            prev != null &&
            s.breathesLeft < prev.state.breathesLeft);
  }

  @override
  Widget build(BuildContext context) {
    final steps = _steps();
    final view = ref.watch(combatControllerProvider);
    if (view == null) return const SizedBox();

    ref.listen(combatControllerProvider, (prev, next) {
      if (next == null || _step >= steps.length) return;
      if (_fulfilled(steps[_step], prev, next)) _advance(steps);
    });

    // Al terminar el combate manda el cartel final; en juego libre, nada.
    if (view.state.isOver || _step >= steps.length || !_visible) {
      return const SizedBox();
    }

    final t = AppLocalizations.of(context);
    final step = steps[_step];
    final last = _step == steps.length - 1;
    return _Layer(
      hole: step.anchor == null ? null : _hole,
      tapHole: _tapHole,
      blockAll: !step.waits,
      bubble: _Bubble(
        text: step.text,
        illustration: step.illustration,
        progress: (_step + 1) / steps.length,
        actions: step.waits
            ? const []
            : [
                FilledButton(
                  onPressed: () => _advance(steps),
                  child: Text(last ? t.tutGo : t.tutNext),
                ),
              ],
      ),
    );
  }
}

/// Velo con un hueco sobre la zona explicada y el globo del maestro al lado.
class _Layer extends StatelessWidget {
  const _Layer({
    required this.hole,
    this.tapHole,
    required this.blockAll,
    required this.bubble,
  });

  final Rect? hole;

  final Rect? tapHole;
  final bool blockAll;
  final Widget bubble;

  @override
  Widget build(BuildContext context) {
    final focus = hole?.inflate(6);
    return LayoutBuilder(
      builder: (context, box) {
        // Si no queda lugar ni arriba ni abajo del foco, el globo va al centro.
        final fits = focus != null &&
            (focus.top > 180 || box.maxHeight - focus.bottom > 180);
        final h = fits ? focus : null;
        final below = h != null && h.center.dy < box.maxHeight / 2;
        return Stack(
          children: [
            Positioned.fill(
              child: _Blocker(hole: blockAll ? null : tapHole?.inflate(6)),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: CustomPaint(painter: _VeilPainter(focus)),
              ),
            ),
            if (h == null)
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: box.maxHeight * 0.8),
                    child: bubble,
                  ),
                ),
              )
            else
              Positioned(
                left: 12,
                right: 12,
                top: below ? h.bottom + 10 : null,
                bottom: below ? null : box.maxHeight - h.top + 10,
                // Si no entra, el texto se desplaza dentro del globo.
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: math.max(
                      160,
                      (below ? box.maxHeight - h.bottom : h.top) - 26,
                    ),
                  ),
                  child: bubble,
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({
    required this.text,
    required this.actions,
    this.illustration,
    this.progress,
  });

  final String text;
  final List<Widget> actions;
  final Illustration? illustration;

  /// Avance dentro de la lección (0–1).
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Palette.gold, width: 2),
          boxShadow: [
            BoxShadow(
              color: Palette.text.withValues(alpha: 0.25),
              blurRadius: 16,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: Palette.lacquer,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '师',
                    style: TextStyle(
                      color: Palette.onColor,
                      fontSize: 15,
                      height: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  t.tutMaster,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Palette.lacquer,
                  ),
                ),
                if (progress != null) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(end: progress),
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        builder: (_, v, _) => LinearProgressIndicator(
                          value: v,
                          minHeight: 4,
                          color: Palette.gold,
                          backgroundColor: Palette.line.withValues(alpha: 0.5),
                        ),
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(fontSize: 14, height: 1.35),
                    ),
                    if (illustration != null) ...[
                      const SizedBox(height: 10),
                      IllustrationView(illustration!),
                    ],
                  ],
                ),
              ),
            ),
            if (actions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Align(
                alignment: Alignment.centerRight,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  children: actions,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VeilPainter extends CustomPainter {
  _VeilPainter(this.hole);

  final Rect? hole;

  @override
  void paint(Canvas canvas, Size size) {
    final veil = Path()..addRect(Offset.zero & size);
    final paint = Paint()..color = Palette.text.withValues(alpha: 0.45);
    if (hole == null) {
      canvas.drawPath(veil, paint);
      return;
    }
    final r = RRect.fromRectAndRadius(hole!, const Radius.circular(14));
    canvas.drawPath(
      Path.combine(PathOperation.difference, veil, Path()..addRRect(r)),
      paint,
    );
    canvas.drawRRect(
      r,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = Palette.gold,
    );
  }

  @override
  bool shouldRepaint(_VeilPainter old) => old.hole != hole;
}

/// Absorbe los toques salvo dentro de [hole].
class _Blocker extends LeafRenderObjectWidget {
  const _Blocker({required this.hole});

  final Rect? hole;

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderBlocker(hole);

  @override
  void updateRenderObject(BuildContext context, _RenderBlocker renderObject) =>
      renderObject.hole = hole;
}

class _RenderBlocker extends RenderBox {
  _RenderBlocker(this.hole);

  Rect? hole;

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  bool hitTestSelf(Offset position) => !(hole?.contains(position) ?? false);
}
