import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/run_state.dart';
import '../../infrastructure/progress_storage.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/scene_backdrop.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/juice.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/cultivation_view.dart';

class ResultScreen extends ConsumerStatefulWidget {
  const ResultScreen({super.key});

  @override
  ConsumerState<ResultScreen> createState() => _ResultScreenState();
}

/// Fin de la subida, contado como una escena: una pincelada cruza el papel,
/// cae el sello (败 o 龙), se narra qué pasó en tres líneas, queda la tablilla
/// del discípulo, se abre un pergamino si tocaba y la escuela manda al
/// siguiente. Tocar en cualquier lado adelanta la escena.
class _ResultScreenState extends ConsumerState<ResultScreen>
    with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 7600),
        )
        ..addListener(_onTick)
        ..forward();
  static const _landAt = 0.12;
  static const _stampAt = 0.72;
  bool _stamped = false;
  int _burst = 0;
  final _lines = <double>[];

  void _onTick() {
    if (_burst == 0 && _c.value >= _landAt) {
      HapticFeedback.heavyImpact();
      final audio = ref.read(audioProvider)..play(Sfx.runResult);
      if (ref.read(runControllerProvider)?.phase == RunPhase.victory) {
        audio.jingle(Music.runWon);
      }
      setState(() => _burst++);
    }
    // El reino nuevo se estampa con un golpe.
    final a = ref.read(lastAscentProvider);
    if (!_stamped && a != null && _c.value >= _stampAt) {
      final def = ref.read(dataProvider).balance.cultivation;
      if (def.realmOf(a.breathBefore + a.breath) > def.realmOf(a.breathBefore)) {
        _stamped = true;
        HapticFeedback.heavyImpact();
        ref.read(audioProvider).play(Sfx.victoryStamp);
      }
    }
    // Cada línea de la narración llega con un toque suave.
    for (final at in const [0.26, 0.36, 0.46]) {
      if (_c.value >= at && !_lines.contains(at)) {
        _lines.add(at);
        HapticFeedback.selectionClick();
      }
    }
  }

  void _skip() {
    if (_c.value < 1) {
      _c.animateTo(1, duration: const Duration(milliseconds: 350));
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  double _span(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  Widget _enter(double a, double b, Widget child) => AnimatedBuilder(
    animation: _c,
    builder: (_, child) {
      final v = _span(a, b);
      return Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 16 * (1 - v)),
          child: child,
        ),
      );
    },
    child: child,
  );

  Future<void> _again(RunState run) async {
    final choice = await pickDifficulty(
      context,
      initial: run.difficulty,
      initialPico: run.pico,
    );
    if (choice == null || !mounted) return;
    final locked = (await ref.read(cultivationProvider.future)).locked;
    if (!mounted) return;
    ref
        .read(runControllerProvider.notifier)
        .newRun(choice.difficulty, pico: choice.pico, locked: locked);
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final won = run.phase == RunPhase.victory;
    final ascent = ref.watch(lastAscentProvider);
    final n = ascent?.n;
    final node = run.currentNode == null ? null : run.node(run.currentNode!);
    final place = node?.scene == null
        ? null
        : text.path(node!.scene!, node.light ?? 'alba');
    final enemy = node?.enemy == null ? null : text.enemy(node!.enemy!);
    final ink = won ? Palette.gold : Palette.lacquer;
    final lines = [
      if (place != null) won ? t.resultSummitAt(place) : t.resultFellAt(place),
      if (enemy != null) won ? t.resultSummitTo(enemy) : t.resultFellTo(enemy),
      if (n != null) won ? t.resultSummitNo(n) : t.resultFellNo(n),
    ];
    const lineAt = [0.26, 0.36, 0.46];

    return Scaffold(
      body: SceneBackdrop(
        // Perder frente al muro de la escuela; ganar, frente a la cumbre.
        assets: won
            ? stageArt('wolongding', 'map_bg.png')
            : stageArt('qianyunshan', 'school_wall.png'),
        veil: 0.62,
        alignment: won ? Alignment.topCenter : Alignment.center,
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: _skip,
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 12),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 124,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              // La pincelada que cruza el papel antes del sello.
                              Positioned.fill(
                                child: AnimatedBuilder(
                                  animation: _c,
                                  builder: (_, _) => CustomPaint(
                                    painter: _BrushPainter(
                                      _span(0, 0.12, Curves.easeOutCubic),
                                      Color.lerp(ink, Palette.bg, 0.62)!,
                                    ),
                                  ),
                                ),
                              ),
                              AnimatedBuilder(
                                animation: _c,
                                builder: (_, child) {
                                  final v = _span(
                                    0.05,
                                    _landAt,
                                    Curves.easeInCubic,
                                  );
                                  final settle = _span(
                                    _landAt,
                                    0.22,
                                    Curves.easeOutBack,
                                  );
                                  return Opacity(
                                    opacity: v,
                                    child: Transform.scale(
                                      scale:
                                          2.8 -
                                          1.8 * v +
                                          0.05 * (1 - settle) * v,
                                      child: child,
                                    ),
                                  );
                                },
                                child: Text(
                                  won ? '龙' : '败',
                                  style: TextStyle(
                                    fontSize: 92,
                                    height: 1.2,
                                    color: ink,
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: InkBurst(
                                  trigger: _burst,
                                  colors: won
                                      ? const [
                                          Palette.gold,
                                          Palette.lacquer,
                                          Colors.white,
                                        ]
                                      : const [
                                          Palette.lacquer,
                                          Palette.textDim,
                                        ],
                                  count: 34,
                                  radius: 150,
                                  duration: const Duration(milliseconds: 1000),
                                ),
                              ),
                            ],
                          ),
                        ),
                        _enter(
                          0.16,
                          0.24,
                          Text(
                            won ? t.runWon : t.runLost,
                            style: const TextStyle(fontSize: 24),
                          ),
                        ),
                        const SizedBox(height: 14),
                        for (var i = 0; i < lines.length; i++)
                          _enter(
                            lineAt[i],
                            lineAt[i] + 0.07,
                            Padding(
                              padding: const EdgeInsets.only(bottom: 6),
                              child: Text(
                                lines[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 16,
                                  height: 1.35,
                                  fontStyle: FontStyle.italic,
                                  fontWeight: i == lines.length - 1 && n != null
                                      ? FontWeight.w700
                                      : FontWeight.w400,
                                  color: i == lines.length - 1 && n != null
                                      ? Palette.text
                                      : Palette.textDim,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: 14),
                        _enter(0.55, 0.64, _Tablet(run: run, n: n, won: won)),
                        // Ganar en Normal o más difícil abre el Pico siguiente.
                        if (won && run.difficulty != Difficulty.easy) ...[
                          const SizedBox(height: 14),
                          _enter(0.6, 0.68, _PicoPill(run: run)),
                        ],
                        // Lo que el discípulo deja a la escuela.
                        if (ascent != null && ascent.breath > 0) ...[
                          const SizedBox(height: 14),
                          _enter(
                            0.58,
                            0.64,
                            AnimatedBuilder(
                              animation: _c,
                              builder: (_, _) => BreathGain(
                                breath: ascent.breath,
                                before: ascent.breathBefore,
                                fill: _span(0.62, 0.72, Curves.easeInOutCubic),
                                stamp: _span(_stampAt, 0.78),
                              ),
                            ),
                          ),
                        ],
                        for (final (i, id)
                            in (ascent?.lore ?? const <String>[]).indexed) ...[
                          const SizedBox(height: 16),
                          AnimatedBuilder(
                            animation: _c,
                            builder: (_, _) {
                              final v = _span(0.74 + i * 0.05, 0.84 + i * 0.05);
                              return Opacity(
                                opacity: math.min(1, v * 3),
                                child: LoreScroll(id: id, fresh: true, open: v),
                              );
                            },
                          ),
                        ],
                        AnimatedBuilder(
                          animation: _c,
                          builder: (_, child) => Opacity(
                            opacity: _c.value < 0.8 && _c.value > 0.2 ? 0.6 : 0,
                            child: child,
                          ),
                          child: Text(
                            t.tapToSkip,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Palette.textDim,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // La escuela manda al siguiente: siempre a mano, abajo.
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                  child: Column(
                    children: [
                      _enter(
                        0.8,
                        0.88,
                        Text(
                          won ? t.relaySummit : t.relayLine,
                          style: const TextStyle(color: Palette.textDim),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _enter(
                        0.86,
                        0.95,
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: FilledButton(
                            onPressed: () => _again(run),
                            child: Text(
                              n == null ? t.tryAgain : t.relayButton(n + 1),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _enter(
                        0.9,
                        1,
                        TextButton(
                          onPressed: () {
                            ref.read(runControllerProvider.notifier).abandon();
                            ref.invalidate(savedRunProvider);
                            context.go('/');
                          },
                          child: Text(t.backSchool),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// La tablilla del discípulo: madera clara con su número, su camino, hasta
/// dónde llegó y con qué.
class _Tablet extends ConsumerWidget {
  const _Tablet({required this.run, required this.n, required this.won});

  final RunState run;
  final int? n;
  final bool won;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final data = ref.watch(dataProvider);
    final ascent = ref.watch(lastAscentProvider);
    final color = styleColor(run.style);
    final hanzi = data.balance.statsOf(run.style).hanzi;
    final floor = ascent?.floor ?? 0;
    final floors = ascent?.floors ?? 0;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 16, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFF3E2C2), Color(0xFFE6CC9E)],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC9A46A), width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: Color(0x26806A45),
            offset: Offset(0, 3),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Palette.surface,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2.5),
            ),
            child: Text(
              hanzi,
              style: TextStyle(fontSize: 26, color: color, height: 1),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (n != null)
                  Text(
                    t.discipleN(n!),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                Text(
                  run.style == null
                      ? t.tabletNovice
                      : t.tabletPath(text.style(run.style!)),
                  style: TextStyle(color: color, fontWeight: FontWeight.w700),
                ),
                if (floors > 0)
                  Text(
                    '${t.tabletFloor(floor, floors)} · '
                    '${run.pico > 0 ? '${t.difficultyName(run.difficulty)} · ${t.picoName(run.pico)}' : t.difficultyName(run.difficulty)}',
                    style: const TextStyle(fontSize: 13),
                  ),
                Text(
                  t.tabletStats(run.maxHp, run.deck.length),
                  style: const TextStyle(fontSize: 13, color: Palette.textDim),
                ),
              ],
            ),
          ),
          Transform.rotate(
            angle: -0.15,
            child: Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: (won ? Palette.gold : Palette.lacquer).withValues(
                  alpha: 0.9,
                ),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                won ? '顶' : '败',
                style: const TextStyle(
                  color: Palette.onColor,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PicoPill extends StatelessWidget {
  const _PicoPill({required this.run});

  final RunState run;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: picoColor, width: 1.5),
      ),
      child: Text(
        run.pico >= ProgressStorage.maxPico
            ? t.picoTop
            : t.picoOpened(run.pico + 1),
        style: const TextStyle(fontWeight: FontWeight.w800, color: picoColor),
      ),
    );
  }
}

/// Una pincelada ancha que se afina en las puntas y cruza de izquierda a
/// derecha, como la de un calígrafo.
class _BrushPainter extends CustomPainter {
  _BrushPainter(this.p, this.color);

  final double p;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (p <= 0) return;
    final paint = Paint()..color = color;
    const steps = 60;
    final upTo = (steps * p).round();
    final top = <Offset>[];
    final bottom = <Offset>[];
    for (var i = 0; i <= upTo; i++) {
      final t = i / steps;
      final x = size.width * (0.04 + 0.92 * t);
      final y = size.height * (0.6 - 0.18 * t) + math.sin(t * math.pi * 2) * 6;
      final w = 30 * math.sin(math.pi * math.min(1, t * 1.05)) + 3;
      top.add(Offset(x, y - w / 2));
      bottom.add(Offset(x + 2, y + w / 2));
    }
    if (top.length < 2) return;
    canvas.drawPath(
      Path()..addPolygon([...top, ...bottom.reversed], true),
      paint,
    );
  }

  @override
  bool shouldRepaint(_BrushPainter old) => old.p != p;
}
