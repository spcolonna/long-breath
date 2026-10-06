import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/juice.dart';

/// Se venció al jefe de una etapa: la etapa queda sellada, el discípulo
/// respira hondo (recupera Vida) y la siguiente aparece más arriba.
class StageClearScreen extends ConsumerStatefulWidget {
  const StageClearScreen({super.key});

  @override
  ConsumerState<StageClearScreen> createState() => _StageClearScreenState();
}

class _StageClearScreenState extends ConsumerState<StageClearScreen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3000),
  );
  int _stampBurst = 0;
  int _revealBurst = 0;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();
    _c.forward();
    final audio = ref.read(audioProvider);
    _at(0.2, () {
      HapticFeedback.heavyImpact();
      audio.play(Sfx.victoryStamp);
      setState(() => _stampBurst++);
    });
    _at(0.5, () {
      HapticFeedback.mediumImpact();
      audio.play(Sfx.shrineOath);
      setState(() => _revealBurst++);
    });
    _at(0.72, () {
      HapticFeedback.lightImpact();
      audio.play(Sfx.fountainHeal);
    });
  }

  void _at(double t, VoidCallback f) =>
      Future.delayed(_c.duration! * t, () => mounted ? f() : null);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Un tramo de la animación (de 0 a 1 entre [a] y [b]).
  double _span(double a, double b, [Curve curve = Curves.easeOutCubic]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  void _climb() {
    if (_leaving) return;
    _leaving = true;
    HapticFeedback.mediumImpact();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(runControllerProvider.notifier).advanceStage();
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final engine = ref.watch(runEngineProvider);
    final stages = data.balance.stages;
    final done = stages[run.stage];
    final next = stages[math.min(run.stage + 1, stages.length - 1)];
    final heal = engine.stageHealOf(run);

    return Scaffold(
      body: SafeArea(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final stamp = _span(0.12, 0.3, Curves.easeOutBack);
            final rise = _span(0.32, 0.55);
            final reveal = _span(0.45, 0.68);
            final healed = _span(0.7, 0.9);
            final button = _span(0.85, 1);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                children: [
                  const Spacer(),
                  // La etapa vencida, sellada.
                  Opacity(
                    opacity: 1 - 0.45 * rise,
                    child: Column(
                      children: [
                        Text(
                          t.stageCleared,
                          style: const TextStyle(
                            color: Palette.textDim,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          height: 74,
                          child: Stack(
                            alignment: Alignment.center,
                            clipBehavior: Clip.none,
                            children: [
                              Text(
                                done.hanzi,
                                style: const TextStyle(
                                  fontSize: 52,
                                  color: Palette.text,
                                ),
                              ),
                              Positioned(
                                right: -18,
                                top: -6,
                                child: Opacity(
                                  opacity: stamp.clamp(0.0, 1.0),
                                  child: Transform.rotate(
                                    angle: -0.18,
                                    child: Transform.scale(
                                      scale: 2.2 - 1.2 * stamp,
                                      child: const _Seal('顶'),
                                    ),
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: InkBurst(
                                  trigger: _stampBurst,
                                  colors: const [Palette.lacquer, Palette.gold],
                                  count: 18,
                                  radius: 90,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          text.stage(done.id),
                          style: const TextStyle(color: Palette.textDim),
                        ),
                      ],
                    ),
                  ),
                  // Sendero de tinta que sube hacia la próxima etapa.
                  SizedBox(
                    height: 70,
                    child: CustomPaint(
                      size: const Size(40, 70),
                      painter: _TrailPainter(rise),
                    ),
                  ),
                  // La etapa que viene.
                  SizedBox(
                    height: 120,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Opacity(
                          opacity: reveal,
                          child: Transform.translate(
                            offset: Offset(0, 24 * (1 - reveal)),
                            child: Text(
                              next.hanzi,
                              style: const TextStyle(
                                fontSize: 84,
                                color: Palette.jade,
                              ),
                            ),
                          ),
                        ),
                        Positioned.fill(
                          child: InkBurst(
                            trigger: _revealBurst,
                            colors: const [
                              Palette.jade,
                              Palette.sky,
                              Colors.white,
                            ],
                            count: 26,
                            radius: 140,
                            duration: const Duration(milliseconds: 1000),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Opacity(
                    opacity: reveal,
                    child: Column(
                      children: [
                        Text(
                          text.stage(next.id),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          next.pinyin,
                          style: const TextStyle(color: Palette.textDim),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          text.stageIntro(next.id),
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, height: 1.4),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Respirar hondo: la Vida sube antes de seguir.
                  Opacity(
                    opacity: healed > 0 ? 1 : 0,
                    child: Column(
                      children: [
                        Text(
                          t.stageBreath,
                          style: const TextStyle(color: Palette.textDim),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.favorite,
                              color: Palette.lacquer,
                              size: 20,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '${t.life}: ${(run.hp + heal * healed).round()}/${run.maxHp}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                color: healed >= 1 && heal > 0
                                    ? Palette.jade
                                    : Palette.text,
                                fontFeatures: const [
                                  FontFeature.tabularFigures(),
                                ],
                              ),
                            ),
                            if (heal > 0) ...[
                              const SizedBox(width: 8),
                              Text(
                                '+$heal',
                                style: const TextStyle(
                                  color: Palette.jade,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Opacity(
                    opacity: button,
                    child: Transform.translate(
                      offset: Offset(0, 16 * (1 - button)),
                      child: SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: FilledButton.icon(
                          onPressed: button > 0.5 ? _climb : null,
                          icon: const Icon(Icons.terrain),
                          label: Text(
                            t.stageClimb,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
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
}

/// Sello rojo de laca con un carácter.
class _Seal extends StatelessWidget {
  const _Seal(this.char);

  final String char;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Palette.lacquer,
        borderRadius: BorderRadius.circular(6),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        char,
        style: const TextStyle(fontSize: 24, color: Palette.onColor),
      ),
    );
  }
}

/// Pinceladas cortas que suben de abajo hacia arriba según [progress].
class _TrailPainter extends CustomPainter {
  _TrailPainter(this.progress);

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    const steps = 6;
    final paint = Paint()
      ..color = Palette.gold
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 3;
    for (var i = 0; i < steps; i++) {
      final p = (progress * steps - i).clamp(0.0, 1.0);
      if (p == 0) continue;
      final y = size.height - (i + 0.5) * size.height / steps;
      final x = size.width / 2 + math.sin(i * 1.3) * 6;
      paint.color = Palette.gold.withValues(alpha: p);
      canvas.drawLine(Offset(x - 7 * p, y), Offset(x + 7 * p, y), paint);
    }
  }

  @override
  bool shouldRepaint(_TrailPainter old) => old.progress != progress;
}
