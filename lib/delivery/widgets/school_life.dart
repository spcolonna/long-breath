import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/ascent.dart';
import '../../domain/run/feats.dart';
import '../../l10n/app_localizations.dart';
import '../feel.dart';
import '../providers.dart';
import '../theme.dart';
import 'lotus.dart';
import 'press.dart';

/// Motas de aliento que suben alrededor del héroe: más y más brillantes
/// con el cultivo ([level], 0..1). Con movimiento reducido no se dibujan.
class QiMotes extends StatefulWidget {
  const QiMotes({super.key, required this.level});

  final double level;

  @override
  State<QiMotes> createState() => _QiMotesState();
}

class _QiMotesState extends State<QiMotes> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 9),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _c);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.level <= 0 || calm(context)) return const SizedBox.expand();
    return IgnorePointer(
      child: RepaintBoundary(
        child: CustomPaint(
          size: Size.infinite,
          painter: _MotesPainter(_c, widget.level),
        ),
      ),
    );
  }
}

class _MotesPainter extends CustomPainter {
  _MotesPainter(this.t, this.level) : super(repaint: t);

  final Animation<double> t;
  final double level;

  @override
  void paint(Canvas canvas, Size size) {
    final count = (8 + 18 * level).round();
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      // Cada mota tiene su carril, su velocidad y su fase fijos.
      final r = math.Random(i * 7919);
      final lane = 0.2 + 0.6 * r.nextDouble();
      final speed = 0.6 + 0.8 * r.nextDouble();
      final phase = r.nextDouble();
      final p = (t.value * speed + phase) % 1;
      final x =
          size.width * (lane + 0.03 * math.sin((p * 3 + phase) * 2 * math.pi));
      final y = size.height * (0.95 - 0.85 * p);
      // Aparece abajo, brilla a media altura y se apaga arriba.
      final a = math.sin(math.pi * p) * (0.55 + 0.4 * level);
      final radius = 2.2 + 2.6 * r.nextDouble() * (0.6 + 0.4 * level);
      paint.color = Palette.gold.withValues(alpha: a * 0.35);
      canvas.drawCircle(Offset(x, y), radius * 2.4, paint);
      paint.color = Palette.gold.withValues(alpha: a);
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_MotesPainter old) => old.level != level;
}

/// Brillo del aura según el aliento: sube de a poco dentro de cada reino,
/// no solo al cambiar de reino.
double auraLevel(WidgetRef ref) {
  final c = ref.watch(cultivationProvider).value;
  if (c == null || !c.active) return 0;
  final steps = c.def.realms.length - 1;
  if (steps <= 0) return 0;
  return math.min(1, (c.realm + (c.isMax ? 0 : c.progress)) / steps);
}

/// La memoria de la escuela, debajo del discípulo: el último que cayó
/// (con su cinta esperando en el sendero) y el próximo hito.
class SchoolMemory extends ConsumerWidget {
  const SchoolMemory({super.key, required this.difficulty});

  final Difficulty difficulty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ascents = ref.watch(ascentsProvider).value;
    final have = ref.watch(hitosProvider).value;
    if (ascents == null || have == null) return const SizedBox(height: 56);
    final fallen = ascents.lastWhereOrNull((a) => a.fell);
    final next = nextHito(have, difficulty);
    return SizedBox(
      height: 56,
      child: Row(
        children: [
          Expanded(child: _Fallen(fallen: fallen)),
          const SizedBox(width: 8),
          Expanded(
            child: _NextHito(hito: next, ascents: ascents),
          ),
        ],
      ),
    );
  }
}

extension<T> on List<T> {
  T? lastWhereOrNull(bool Function(T) test) {
    for (final x in reversed) {
      if (test(x)) return x;
    }
    return null;
  }
}

/// Una tablilla chica de papel: sello a la izquierda y dos líneas.
class _Tablet extends StatelessWidget {
  const _Tablet({
    required this.seal,
    required this.color,
    required this.title,
    required this.line,
    this.sub,
    this.progress,
    this.onTap,
  });

  final String seal;
  final Color color;
  final String title;
  final String line;

  /// Tercera línea chica y en cursiva (por ejemplo, la cinta que espera).
  final String? sub;
  final double? progress;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final body = Container(
      padding: const EdgeInsets.fromLTRB(6, 4, 8, 4),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Row(
        children: [
          InkSeal(hanzi: seal, color: color, size: 30),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Flexible(
                  child: Text(
                    line,
                    maxLines: progress == null && sub == null ? 2 : 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      height: 1.15,
                      color: Palette.text,
                    ),
                  ),
                ),
                if (sub != null)
                  Text(
                    sub!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 10.5,
                      height: 1.15,
                      fontStyle: FontStyle.italic,
                      color: Palette.blossom,
                    ),
                  ),
                if (progress != null) ...[
                  const SizedBox(height: 3),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => LinearProgressIndicator(
                        value: v,
                        minHeight: 3,
                        color: color,
                        backgroundColor: color.withValues(alpha: 0.15),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
    if (onTap == null) return body;
    return Press(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          Haptics.selectionClick();
          onTap!();
        },
        child: body,
      ),
    );
  }
}

class _Fallen extends ConsumerWidget {
  const _Fallen({required this.fallen});

  final Ascent? fallen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final a = fallen;
    if (a == null) {
      return _Tablet(
        seal: '新',
        color: Palette.jade,
        title: t.schoolNoFallen,
        line: t.schoolNoFallenSub,
      );
    }
    final text = ref.watch(textProvider);
    final enemy = a.ghost != null
        ? t.ghostName(a.ghost!)
        : a.enemy == null
        ? null
        : text.enemy(a.enemy!);
    final where = enemy == null
        ? t.schoolFellAt(a.floor)
        : t.schoolFellTo(enemy, a.floor);
    // El último caído vuelve como el Discípulo Perdido (ver `ghostFrom`).
    return _Tablet(
      seal: '香',
      color: Palette.lacquer,
      title: t.schoolLastFallen(a.n),
      line: where,
      sub: t.schoolGhostWaits,
      onTap: () => context.go('/registry'),
    );
  }
}

class _NextHito extends ConsumerWidget {
  const _NextHito({required this.hito, required this.ascents});

  final HitoDef? hito;
  final List<Ascent> ascents;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final h = hito;
    if (h == null) {
      return _Tablet(
        seal: '功',
        color: Palette.gold,
        title: t.schoolAllHitos,
        line: '',
        onTap: () => context.go('/registry?tab=3'),
      );
    }
    final text = ref.watch(textProvider);
    final name = text.hito(h.id, 'name');
    final best = hitoBest(h.id, ascents);
    return _Tablet(
      seal: h.hanzi,
      color: Palette.gold,
      title: t.schoolNextHito(h.breath),
      line: best == null
          ? name
          : t.schoolHitoBest(name, math.min(best.$1, best.$2), best.$2),
      progress: best == null ? null : math.min(1, best.$1 / best.$2),
      onTap: () => context.go('/registry?tab=3'),
    );
  }
}
