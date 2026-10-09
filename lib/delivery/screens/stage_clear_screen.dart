import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/lotus.dart';
import '../widgets/scene_backdrop.dart';

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

  /// Después de la etapa sellada, el camino ofrece sus despertares.
  bool _choosing = false;
  String? _picked;
  int _pickBurst = 0;

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
    final run = ref.read(runControllerProvider);
    if (run == null) return;
    if (run.awakeningOptions.isNotEmpty && !_choosing) {
      HapticFeedback.mediumImpact();
      ref.read(audioProvider).play(Sfx.shrineOath);
      setState(() => _choosing = true);
      return;
    }
    if (run.awakeningOptions.isNotEmpty && _picked == null) return;
    _leaving = true;
    HapticFeedback.heavyImpact();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(runControllerProvider.notifier).advanceStage(_picked);
    context.go('/map');
  }

  void _pick(String id) {
    if (_picked == id) return;
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    setState(() {
      _picked = id;
      _pickBurst++;
    });
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
      body: SceneBackdrop(
        assets: const ['assets/art/ui/stage_clear_bg.png'],
        veil: 0.4,
        child: SafeArea(
          child: AnimatedBuilder(
            animation: _c,
            builder: (context, _) {
              final stamp = _span(0.12, 0.3, Curves.easeOutBack);
              final rise = _span(0.32, 0.55);
              final reveal = _span(0.45, 0.68);
              final healed = _span(0.7, 0.9);
              final button = _span(0.85, 1);
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Column(
                  children: [
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, a) => FadeTransition(
                          opacity: a,
                          child: SlideTransition(
                            position: Tween(
                              begin: const Offset(0, 0.04),
                              end: Offset.zero,
                            ).animate(a),
                            child: child,
                          ),
                        ),
                        child: _choosing
                            ? _AwakeningPanel(
                                key: const ValueKey('awakening'),
                                options: run.awakeningOptions,
                                picked: _picked,
                                burst: _pickBurst,
                                color: styleColor(run.style),
                                onPick: _pick,
                              )
                            : Column(
                                key: const ValueKey('clear'),
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
                                                  opacity: stamp.clamp(
                                                    0.0,
                                                    1.0,
                                                  ),
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
                                                  colors: const [
                                                    Palette.lacquer,
                                                    Palette.gold,
                                                  ],
                                                  count: 18,
                                                  radius: 90,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Text(
                                          text.stage(done.id),
                                          style: const TextStyle(
                                            color: Palette.textDim,
                                          ),
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
                                            offset: Offset(
                                              0,
                                              24 * (1 - reveal),
                                            ),
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
                                            duration: const Duration(
                                              milliseconds: 1000,
                                            ),
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
                                          style: const TextStyle(
                                            color: Palette.textDim,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          text.stageIntro(next.id),
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            height: 1.4,
                                          ),
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
                                          style: const TextStyle(
                                            color: Palette.textDim,
                                          ),
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
                                  const SizedBox(height: 16),
                                  // Lo que dejó la etapa, contado de a uno.
                                  _StageLoot(
                                    t: healed,
                                    wins: run.stageWins,
                                    jade: run.stageJade,
                                    lotus: run.stageLotus,
                                  ),
                                  const Spacer(),
                                ],
                              ),
                      ),
                    ),
                    Opacity(
                      opacity: button,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - button)),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: FilledButton.icon(
                            onPressed:
                                button > 0.5 && (!_choosing || _picked != null)
                                ? _climb
                                : null,
                            icon: const Icon(Icons.terrain),
                            label: Text(
                              !_choosing
                                  ? t.stageClimb
                                  : _picked == null
                                  ? t.awakeningPick
                                  : t.awakeningConfirm,
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
      ),
    );
  }
}

/// Los despertares que ofrece el camino: uno se aprende para el resto de
/// la subida.
class _AwakeningPanel extends ConsumerWidget {
  const _AwakeningPanel({
    super.key,
    required this.options,
    required this.picked,
    required this.burst,
    required this.color,
    required this.onPick,
  });

  final List<String> options;
  final String? picked;
  final int burst;
  final Color color;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final balance = ref.watch(dataProvider).balance;
    return LayoutBuilder(
      builder: (context, box) => SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 12),
              Text(
                '觉醒',
                style: TextStyle(fontSize: 44, color: color, height: 1.1),
              ),
              Text(
                t.awakeningTitle,
                style: const TextStyle(
                  color: Palette.textDim,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                t.awakeningHint,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, height: 1.4),
              ),
              const SizedBox(height: 18),
              for (final (i, id) in options.indexed)
                _Rise(
                  delay: 120 * i,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _AwakeningTile(
                      hanzi: balance.awakening(id).hanzi,
                      name: text.awakening(id),
                      effect: t.awakeningEffect(balance.awakening(id).effect),
                      flavor: text.awakeningText(id),
                      color: color,
                      selected: picked == id,
                      burst: picked == id ? burst : 0,
                      onTap: () => onPick(id),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aparece subiendo un poco, con [delay] ms de espera.
class _Rise extends StatelessWidget {
  const _Rise({required this.delay, required this.child});

  final int delay;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final total = 420 + delay;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: total),
      builder: (context, v, child) {
        final p = Curves.easeOutCubic.transform(
          ((v * total - delay) / 420).clamp(0.0, 1.0),
        );
        return Opacity(
          opacity: p,
          child: Transform.translate(
            offset: Offset(0, 18 * (1 - p)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class _AwakeningTile extends StatelessWidget {
  const _AwakeningTile({
    required this.hanzi,
    required this.name,
    required this.effect,
    required this.flavor,
    required this.color,
    required this.selected,
    required this.burst,
    required this.onTap,
  });

  final String hanzi;
  final String name;
  final String effect;
  final String flavor;
  final Color color;
  final bool selected;
  final int burst;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: selected ? 1.02 : 1,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
          decoration: BoxDecoration(
            color: selected
                ? Color.lerp(Palette.surface, color, 0.12)
                : Palette.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: color, width: selected ? 2 : 1),
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: color.withValues(alpha: 0.3),
                      blurRadius: 14,
                    ),
                  ]
                : null,
          ),
          child: Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 52,
                      height: 52,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? color : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(color: color, width: 1.5),
                      ),
                      child: Text(
                        hanzi,
                        style: TextStyle(
                          fontSize: 26,
                          color: selected ? Palette.onColor : color,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: InkBurst(
                        trigger: burst,
                        colors: [color, Palette.gold],
                        count: 14,
                        radius: 60,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(effect, style: const TextStyle(height: 1.3)),
                    const SizedBox(height: 4),
                    Text(
                      flavor,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
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

/// Botín de la etapa: combates ganados, jade y semillas de loto, que suben
/// con [t] (0..1) uno detrás del otro.
class _StageLoot extends StatelessWidget {
  const _StageLoot({
    required this.t,
    required this.wins,
    required this.jade,
    required this.lotus,
  });

  final double t;
  final int wins;
  final int jade;
  final int lotus;

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context);
    Widget cell(int i, Widget icon, int value, String label, Color color) {
      final v = ((t - i * 0.2) / 0.6).clamp(0.0, 1.0);
      return Expanded(
        child: Opacity(
          opacity: v,
          child: Transform.scale(
            scale: 0.8 + 0.2 * Curves.easeOutBack.transform(v),
            child: Column(
              children: [
                icon,
                const SizedBox(height: 4),
                Text(
                  '${(value * v).round()}',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: color,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: Palette.textDim),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Opacity(
      opacity: t > 0 ? 1 : 0,
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 10, 8, 10),
        decoration: BoxDecoration(
          color: Palette.surface.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Palette.gold.withValues(alpha: 0.5)),
        ),
        child: Column(
          children: [
            Text(
              l.stageLootTitle,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                cell(
                  0,
                  const InkSeal(hanzi: '武', color: Palette.lacquer, size: 26),
                  wins,
                  l.stageLootWins,
                  Palette.lacquer,
                ),
                cell(1, const JadeCoin(size: 26), jade, l.stageLootJade,
                    Palette.jade),
                cell(2, const LotusSeed(size: 26), lotus, l.stageLootLotus,
                    Palette.blossom),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
