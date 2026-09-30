import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/combat_event.dart';
import '../../domain/combat/combat_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import 'tutorial_anchor.dart';
import 'tutorial_steps.dart';

/// Guía del entrenamiento: oscurece la pantalla menos la zona que explica el
/// maestro y, en los pasos que esperan una jugada, solo deja tocar esa zona.
class TutorialOverlay extends ConsumerStatefulWidget {
  const TutorialOverlay({super.key});

  @override
  ConsumerState<TutorialOverlay> createState() => _TutorialOverlayState();
}

class _TutorialOverlayState extends ConsumerState<TutorialOverlay>
    with SingleTickerProviderStateMixin {
  int _step = 0;
  bool _visible = true;
  Timer? _delay;
  Rect? _hole;

  /// Al ganar, el globo espera a que termine la celebración.
  bool _wonReady = false;
  Timer? _wonTimer;

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
    _ticker.dispose();
    _delay?.cancel();
    _wonTimer?.cancel();
    super.dispose();
  }

  void _track() {
    final steps = tutorialSteps(AppLocalizations.of(context));
    final me = context.findRenderObject();
    Rect? hole, tapHole;
    if (_step < steps.length && steps[_step].anchor != null && me is RenderBox) {
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
    final delay = next < steps.length ? steps[next].delayMs : 0;
    _delay?.cancel();
    setState(() {
      _step = next;
      _visible = delay == 0;
    });
    if (delay > 0) {
      _delay = Timer(Duration(milliseconds: delay), () {
        if (mounted) setState(() => _visible = true);
      });
    }
  }

  Future<void> _leave({required bool climb}) async {
    await ref.read(tutorialStorageProvider).markDone();
    ref.invalidate(tutorialDoneProvider);
    if (!mounted) return;
    ref.read(combatControllerProvider.notifier).finish();
    if (climb) {
      ref.read(runControllerProvider.notifier).newRun();
      context.go('/map');
    } else {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final steps = tutorialSteps(t);
    final view = ref.watch(combatControllerProvider);
    if (view == null) return const SizedBox();

    ref.listen(combatControllerProvider, (prev, next) {
      if (next == null || next.seq == prev?.seq || _step >= steps.length) return;
      final step = steps[_step];
      final played = step.waitCard != null &&
          next.events.any((e) => e is CardPlayed && e.cardId == step.waitCard);
      final turned = step.waitTurn != null && next.state.turn >= step.waitTurn!;
      if (played || turned) _advance(steps);
    });

    final s = view.state;
    if (s.phase == CombatPhase.won) {
      _wonTimer ??= Timer(const Duration(milliseconds: 2600), () {
        if (mounted) setState(() => _wonReady = true);
      });
      if (!_wonReady) return const SizedBox();
      return _Layer(
        hole: null,
        blockAll: true,
        bottom: true,
        bubble: _Bubble(
          text: t.tutDone,
          actions: [
            TextButton(onPressed: () => _leave(climb: false), child: Text(t.tutHome)),
            FilledButton(onPressed: () => _leave(climb: true), child: Text(t.tutClimb)),
          ],
        ),
      );
    }

    final skip = Positioned(
      top: 4,
      right: 8,
      child: TextButton(
        onPressed: () => _leave(climb: false),
        style: TextButton.styleFrom(
          backgroundColor: Palette.surface.withValues(alpha: 0.9),
          visualDensity: VisualDensity.compact,
        ),
        child: Text(t.tutSkip, style: const TextStyle(color: Palette.textDim)),
      ),
    );
    // Juego libre: solo queda el botón de saltear.
    if (_step >= steps.length || !_visible) return Stack(children: [skip]);

    final step = steps[_step];
    final last = _step == steps.length - 1;
    return Stack(
      children: [
        _Layer(
          hole: step.anchor == null ? null : _hole,
          tapHole: _tapHole,
          blockAll: !step.waits,
          bubble: _Bubble(
            text: step.text,
            actions: step.waits
                ? const []
                : [
                    FilledButton(
                      onPressed: () => _advance(steps),
                      child: Text(last ? t.tutGo : t.tutNext),
                    ),
                  ],
          ),
        ),
        skip,
      ],
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
    this.bottom = false,
  });

  final Rect? hole;

  /// Sin foco, el globo va abajo en vez de al centro (deja ver la victoria).
  final bool bottom;
  final Rect? tapHole;
  final bool blockAll;
  final Widget bubble;

  @override
  Widget build(BuildContext context) {
    final h = hole?.inflate(6);
    return LayoutBuilder(builder: (context, box) {
      final below = h != null && h.center.dy < box.maxHeight / 2;
      return Stack(
        children: [
          Positioned.fill(
            child: _Blocker(hole: blockAll ? null : tapHole?.inflate(6)),
          ),
          if (!bottom)
            Positioned.fill(
              child: IgnorePointer(child: CustomPaint(painter: _VeilPainter(h))),
            ),
          if (h == null)
            Align(
              alignment: bottom ? const Alignment(0, 0.92) : Alignment.center,
              child: Padding(padding: const EdgeInsets.all(16), child: bubble),
            )
          else
            Positioned(
              left: 12,
              right: 12,
              top: below ? h.bottom + 10 : null,
              bottom: below ? null : box.maxHeight - h.top + 10,
              child: bubble,
            ),
        ],
      );
    });
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.text, required this.actions});

  final String text;
  final List<Widget> actions;

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
            BoxShadow(color: Palette.text.withValues(alpha: 0.25), blurRadius: 16),
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
                      color: Palette.lacquer, shape: BoxShape.circle),
                  child: const Text('师',
                      style: TextStyle(color: Palette.onColor, fontSize: 15, height: 1)),
                ),
                const SizedBox(width: 8),
                Text(t.tutMaster,
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, color: Palette.lacquer)),
              ],
            ),
            const SizedBox(height: 6),
            Text(text, style: const TextStyle(fontSize: 14, height: 1.35)),
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
        Path.combine(PathOperation.difference, veil, Path()..addRRect(r)), paint);
    canvas.drawRRect(
        r,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..color = Palette.gold);
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
