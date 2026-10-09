import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enemy_def.dart';
import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../../infrastructure/progress_storage.dart';
import '../audio/game_audio.dart';
import '../providers.dart';
import '../theme.dart';
import 'hero_sprite.dart';
import 'juice.dart';
import 'stage_scene.dart';

/// Tramo [a, b] de la línea de tiempo llevado a 0..1, con curva.
double span(
  double t,
  double a,
  double b, [
  Curve curve = Curves.easeOutCubic,
]) => curve.transform(((t - a) / (b - a)).clamp(0.0, 1.0));

/// Armazón de una presentación: barras de cine de papel que entran y salen,
/// la escena en el medio y un toque en cualquier lado para saltarla.
class Cinematic extends StatefulWidget {
  const Cinematic({
    super.key,
    required this.duration,
    required this.builder,
    required this.onDone,
    this.beats = const {},
  });

  final Duration duration;

  /// La escena en el instante `t` (0..1).
  final Widget Function(BuildContext context, double t) builder;
  final VoidCallback onDone;

  /// Golpes de sonido o vibración en milisegundos desde el principio. Si se
  /// salta, los que faltan no suenan.
  final Map<int, VoidCallback> beats;

  @override
  State<Cinematic> createState() => _CinematicState();
}

class _CinematicState extends State<Cinematic>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: widget.duration)
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _finish();
    })
    ..forward();
  final _timers = <Timer>[];
  bool _done = false;

  /// Al saltar, la escena se va con un fundido corto desde este punto.
  double? _skipFrom;

  @override
  void initState() {
    super.initState();
    for (final MapEntry(key: ms, value: f) in widget.beats.entries) {
      _timers.add(Timer(Duration(milliseconds: ms), f));
    }
  }

  void _finish() {
    if (_done) return;
    _done = true;
    for (final t in _timers) {
      t.cancel();
    }
    widget.onDone();
  }

  void _skip() {
    if (_skipFrom != null || _done) return;
    for (final t in _timers) {
      t.cancel();
    }
    setState(() => _skipFrom = _c.value);
    final total = widget.duration.inMilliseconds;
    final left = ((1 - _c.value) * total).round();
    _c.animateTo(1, duration: Duration(milliseconds: math.min(left, 320)));
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final ms = widget.duration.inMilliseconds;
    // Puede ir encima de la pantalla entera, fuera del Scaffold.
    return Material(
      type: MaterialType.transparency,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _skip,
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            final v = _c.value;
            // Entrada y salida: las barras se cierran y todo se funde al final.
            final edge = 240 / ms;
            final bars = span(v, 0, edge * 1.4) * (1 - span(v, 1 - edge, 1));
            final from = _skipFrom;
            final fade = from == null ? 1.0 : 1 - span(v, from, 1);
            final out = 1 - span(v, 1 - edge, 1, Curves.easeIn);
            return Opacity(
              opacity: (out * fade).clamp(0, 1),
              child: LayoutBuilder(
                builder: (context, box) {
                  final barH = box.maxHeight * 0.09 * bars;
                  return Stack(
                    fit: StackFit.expand,
                    children: [
                      const ColoredBox(color: Palette.bg),
                      ClipRect(child: widget.builder(context, v)),
                      _Bar(height: barH, top: true),
                      _Bar(height: barH, top: false),
                      Positioned(
                        right: 18,
                        bottom: math.max(10, barH / 2 - 9),
                        child: Opacity(
                          opacity: span(v * ms, 600, 900),
                          child: Text(
                            t.cinematicSkip,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: Palette.textDim,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Barra de cine de papel con un filo dorado.
class _Bar extends StatelessWidget {
  const _Bar({required this.height, required this.top});

  final double height;
  final bool top;

  @override
  Widget build(BuildContext context) {
    final side = BorderSide(
      color: Palette.gold.withValues(alpha: 0.7),
      width: 1.5,
    );
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : null,
      bottom: top ? null : 0,
      height: height,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Palette.surface,
          border: Border(
            top: top ? BorderSide.none : side,
            bottom: top ? side : BorderSide.none,
          ),
        ),
      ),
    );
  }
}

/// Sello del título: el hanzi cae grande, se asienta y suelta tinta.
class _TitleSeal extends StatelessWidget {
  const _TitleSeal({
    required this.t,
    required this.hanzi,
    required this.title,
    required this.subtitle,
    required this.color,
    this.size = 96,
  });

  /// Avance de la caída (0..1).
  final double t;
  final String hanzi;
  final String title;
  final String subtitle;
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    final drop = Curves.easeOutBack.transform(t.clamp(0, 1));
    // Los nombres de tres caracteres van más chicos.
    final glyph = hanzi.characters.length > 2 ? size * 0.62 : size;
    final words = span(t, 0.45, 1);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Opacity(
          opacity: span(t, 0, 0.25),
          child: Transform.scale(
            scale: 1.8 - 0.8 * drop,
            child: Container(
              padding: EdgeInsets.symmetric(
                horizontal: glyph * 0.22,
                vertical: glyph * 0.08,
              ),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(size * 0.16),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: 0.45),
                    blurRadius: 28,
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: Text(
                hanzi,
                style: TextStyle(
                  fontSize: glyph,
                  height: 1.1,
                  fontWeight: FontWeight.w900,
                  color: Palette.onColor,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Opacity(
          opacity: words,
          child: Transform.translate(
            offset: Offset(0, 12 * (1 - words)),
            child: _Plate(title: title, subtitle: subtitle, color: color),
          ),
        ),
      ],
    );
  }
}

/// Nombre sobre una faja de papel, legible encima de cualquier fondo.
class _Plate extends StatelessWidget {
  const _Plate({
    required this.title,
    required this.subtitle,
    required this.color,
  });

  final String title;
  final String subtitle;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(22, 10, 22, 12),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.6), width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w900,
              color: Palette.text,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle.toUpperCase(),
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 2.4,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Presentación de una etapa: la cámara sube por la montaña pintada del
/// mapa, el héroe la mira de espaldas y cae el sello con el nombre. La
/// primera vez entera; después, solo el sello sobre el paisaje.
class StageIntro extends ConsumerWidget {
  const StageIntro({
    super.key,
    required this.stageId,
    required this.hanzi,
    required this.name,
    required this.subtitle,
    required this.style,
    required this.full,
    required this.onDone,
  });

  final String stageId;
  final String hanzi;
  final String name;
  final String subtitle;
  final Style? style;
  final bool full;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final audio = ref.read(audioProvider);
    final sealAt = full ? 0.48 : 0.12;
    final ms = full ? 4600 : 1900;
    return Cinematic(
      duration: Duration(milliseconds: ms),
      onDone: onDone,
      beats: {
        0: () => audio.play(Sfx.screenTransition),
        (ms * sealAt).round() + 120: () => audio.play(Sfx.victoryStamp),
      },
      builder: (context, t) {
        final pan = span(t, 0, 0.85, Curves.easeInOutSine);
        final seal = span(
          t,
          sealAt,
          sealAt + (full ? 0.16 : 0.3),
          Curves.linear,
        );
        final hero = span(t, 0.1, 0.42);
        return LayoutBuilder(
          builder: (context, box) {
            final heroH = box.maxHeight * 0.4;
            return Stack(
              fit: StackFit.expand,
              children: [
                // La cámara sube desde el pie de la montaña hasta la cumbre.
                Transform.scale(
                  scale: full ? 1.18 - 0.12 * pan : 1.08 - 0.06 * pan,
                  child: Image.asset(
                    'assets/art/stages/$stageId/map_bg.png',
                    fit: BoxFit.cover,
                    alignment: full
                        ? Alignment(0, 1 - 1.7 * pan)
                        : Alignment(0, -0.4 - 0.3 * pan),
                    errorBuilder: (_, _, _) => StageScene(
                      stageId: stageId,
                      scene: null,
                      motion: false,
                    ),
                  ),
                ),
                // Un velo tibio arriba para que el sello resalte.
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(0, -0.25),
                      radius: 0.8,
                      colors: [
                        Palette.surface.withValues(alpha: 0.55 * seal),
                        Palette.surface.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                if (full)
                  Positioned(
                    left: -heroH * 0.1,
                    bottom: -heroH * 0.12 - heroH * 0.5 * (1 - hero),
                    child: Opacity(
                      opacity: hero,
                      child: Image.asset(
                        heroAsset(style),
                        height: heroH,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, -0.3),
                  child: _TitleSeal(
                    t: seal,
                    hanzi: hanzi,
                    title: name,
                    subtitle: subtitle,
                    color: Palette.lacquer,
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.36),
                  child: SizedBox.square(
                    dimension: 300,
                    child: InkBurst(
                      trigger: seal > 0.2 ? 1 : 0,
                      colors: const [
                        Palette.lacquer,
                        Palette.gold,
                        Palette.lacquer,
                      ],
                      count: 26,
                      radius: 150,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Presentación de un jefe o una élite: la cámara se acerca al rival en su
/// escenario, la silueta toma color con su aura, cae el sello y el héroe
/// entra al plano. La versión corta deja solo la revelación y el nombre.
class FoeIntro extends ConsumerWidget {
  const FoeIntro({
    super.key,
    required this.def,
    required this.name,
    required this.stageId,
    required this.scene,
    required this.light,
    required this.style,
    required this.full,
    required this.onDone,
  });

  final EnemyDef def;
  final String name;
  final String stageId;
  final String? scene;
  final String? light;
  final Style? style;
  final bool full;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final audio = ref.read(audioProvider);
    final boss = def.rank == EnemyRank.boss;
    final color = rankColor(def.rank);
    final ms = full ? 4000 : 2000;
    final revealAt = full ? 0.22 : 0.08;
    final sealAt = full ? 0.5 : 0.36;
    return Cinematic(
      duration: Duration(milliseconds: ms),
      onDone: onDone,
      beats: {
        0: () => audio.play(Sfx.enemyWindup),
        (ms * revealAt).round(): () =>
            audio.play(boss ? Sfx.phaseTwo : Sfx.enemyDrop),
        (ms * sealAt).round() + 100: () => audio.play(Sfx.fightStart),
        if (full) (ms * 0.72).round(): () => audio.play(Sfx.stanceChange),
      },
      builder: (context, v) {
        final cam = span(v, 0, 0.9, Curves.easeInOutSine);
        final reveal = span(v, revealAt, revealAt + 0.2);
        final rise = span(v, 0, revealAt + 0.15);
        final seal = span(
          v,
          sealAt,
          sealAt + (full ? 0.18 : 0.3),
          Curves.linear,
        );
        final hero = full ? span(v, 0.68, 0.86) : 0.0;
        return LayoutBuilder(
          builder: (context, box) {
            final foeH = math.min(box.maxHeight * 0.5, box.maxWidth * 1.05);
            final heroH = box.maxHeight * 0.42;
            return Stack(
              fit: StackFit.expand,
              children: [
                Transform.scale(
                  scale: 1.0 + (full ? 0.16 : 0.08) * cam,
                  alignment: const Alignment(0.2, -0.1),
                  child: StageScene(
                    stageId: stageId,
                    scene: scene,
                    light: light,
                    motion: false,
                  ),
                ),
                // Aura del rango detrás del rival.
                Align(
                  alignment: const Alignment(0, -0.18),
                  child: Opacity(
                    opacity: reveal,
                    child: Container(
                      width: foeH * 1.1,
                      height: foeH * 1.1,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            color.withValues(alpha: 0.55),
                            color.withValues(alpha: 0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                // El rival: primero sombra de tinta, después a color.
                Align(
                  alignment: const Alignment(0, -0.18),
                  child: Opacity(
                    opacity: span(v, 0, 0.08),
                    child: Transform.translate(
                      offset: Offset(0, 40 * (1 - rise)),
                      child: Transform.scale(
                        scale: 0.92 + 0.08 * rise + 0.04 * cam,
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Palette.text.withValues(alpha: 0.88 * (1 - reveal)),
                            BlendMode.srcATop,
                          ),
                          child: Image.asset(
                            'assets/art/enemies/${def.art}.png',
                            height: foeH,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) => Image.asset(
                              'assets/art/enemies/placeholder.png',
                              height: foeH,
                              fit: BoxFit.contain,
                              errorBuilder: (_, _, _) => SizedBox(height: foeH),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const Alignment(0, -0.22),
                  child: SizedBox.square(
                    dimension: foeH,
                    child: InkBurst(
                      trigger: reveal > 0.3 ? 1 : 0,
                      colors: [color, Palette.gold, Colors.white],
                      count: 30,
                      radius: foeH * 0.55,
                    ),
                  ),
                ),
                // Contraplano: el héroe entra de espaldas en primer plano.
                if (full)
                  Positioned(
                    left: -heroH * 0.12 - heroH * 0.5 * (1 - hero),
                    bottom: -heroH * 0.16,
                    child: Opacity(
                      opacity: hero,
                      child: Image.asset(
                        heroAsset(style),
                        height: heroH,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      ),
                    ),
                  ),
                Align(
                  alignment: const Alignment(0, 0.7),
                  child: _TitleSeal(
                    t: seal,
                    hanzi: def.hanzi ?? (boss ? '王' : '强'),
                    title: name,
                    subtitle: boss ? t.introBoss : t.introElite,
                    color: color,
                    size: 64,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

/// Decide si una presentación va entera (la primera vez) o corta, y la
/// anota como vista. Mientras consulta, papel liso.
class CinematicGate extends ConsumerStatefulWidget {
  const CinematicGate({
    super.key,
    required this.id,
    required this.builder,
    this.fullFirstTime = true,
  });

  /// Identificador de lo que se presenta (`stage_<id>`, `foe_<id>`).
  final String id;
  final bool fullFirstTime;
  final Widget Function(bool full) builder;

  @override
  ConsumerState<CinematicGate> createState() => _CinematicGateState();
}

class _CinematicGateState extends ConsumerState<CinematicGate> {
  bool? _full;

  @override
  void initState() {
    super.initState();
    if (!widget.fullFirstTime) {
      _full = false;
      return;
    }
    final storage = ref.read(progressStorageProvider);
    storage.cinematicSeen(widget.id).then((seen) {
      if (!mounted) return;
      setState(() => _full = !seen);
      if (!seen) storage.markCinematicSeen(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final full = _full;
    if (full == null) return const ColoredBox(color: Palette.bg);
    return widget.builder(full);
  }
}
