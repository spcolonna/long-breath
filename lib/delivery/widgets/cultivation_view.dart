import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/cultivation_def.dart';
import '../../domain/model/enums.dart';
import '../../domain/run/cultivation.dart';
import '../../l10n/app_localizations.dart';
import '../content_text.dart';
import '../providers.dart';
import '../theme.dart';

/// Cómo se nombra algo que abre el cultivo ("Camino de la Grulla", una
/// carta, un talismán o una forma).
String unlockLabel(AppLocalizations t, ContentText text, String id) =>
    Style.values.any((s) => s.name == id)
    ? t.tabletPath(text.unlockName(id))
    : text.unlockName(id);

/// Barra fina de aliento, como una pincelada que se va llenando de oro.
class BreathBar extends StatelessWidget {
  const BreathBar({super.key, required this.value, this.height = 6});

  final double value;
  final double height;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            ColoredBox(color: Palette.gold.withValues(alpha: 0.16)),
            FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: value.clamp(0, 1).toDouble(),
              child: const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFFF2C14E), Palette.gold],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Sello cuadrado con el hanzi del reino.
class RealmSeal extends StatelessWidget {
  const RealmSeal({
    super.key,
    required this.hanzi,
    this.size = 34,
    this.sealed = false,
  });

  final String hanzi;
  final double size;
  final bool sealed;

  @override
  Widget build(BuildContext context) {
    final color = sealed ? Palette.textDim : Palette.lacquer;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: sealed
            ? Palette.surface
            : Palette.lacquer.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(size * 0.18),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        hanzi,
        style: TextStyle(
          fontSize: size * 0.36,
          height: 1,
          fontWeight: FontWeight.w800,
          color: sealed ? Palette.textDim : Colors.white,
        ),
      ),
    );
  }
}

/// El reino de la escuela en el inicio: sello, nombre y cuánto falta.
class RealmLine extends ConsumerWidget {
  const RealmLine({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final c = ref.watch(cultivationProvider).value;
    if (c == null || !c.active) return const SizedBox(height: 40);
    final realm = c.def.realms[c.realm];
    final text = ref.watch(textProvider);
    final left = c.isMax ? 0 : c.def.realms[c.realm + 1].breath - c.breath;
    return SizedBox(
      height: 40,
      child: Center(
        child: SizedBox(
          width: 260,
          child: Row(
            children: [
              RealmSeal(hanzi: realm.hanzi, size: 34),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        '${text.realm(realm.id)} · '
                        '${c.isMax ? t.breathMax : t.breathToNext(left)}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Palette.text,
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    TweenAnimationBuilder<double>(
                      tween: Tween(begin: 0, end: c.progress),
                      duration: const Duration(milliseconds: 900),
                      curve: Curves.easeOutCubic,
                      builder: (_, v, _) => BreathBar(value: v),
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

/// Lo que dejó la subida: "+N de aliento", la barra que se llena desde lo
/// que había y, si alcanza, el sello del reino nuevo y lo que se abrió.
/// [fill] (0..1) llena la barra; [stamp] (0..1) estampa el reino nuevo.
class BreathGain extends ConsumerWidget {
  const BreathGain({
    super.key,
    required this.breath,
    required this.before,
    required this.fill,
    required this.stamp,
  });

  final int breath;
  final int before;
  final double fill;
  final double stamp;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = ref.watch(dataProvider).balance.cultivation;
    if (def.realms.isEmpty) return const SizedBox.shrink();
    final now = (before + breath * fill).round();
    final from = def.realmOf(before);
    final to = def.realmOf(before + breath);
    final shown = Cultivation(def, now);
    final opened = def.opened(from, to);
    final RealmDef realm = def.realms[shown.realm];
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Palette.gold.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Text(
            t.breathEarned(breath),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Palette.gold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            t.breathEarnedHint,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 12, color: Palette.textDim),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              RealmSeal(hanzi: realm.hanzi, size: 28),
              const SizedBox(width: 10),
              Expanded(child: BreathBar(value: shown.progress, height: 8)),
            ],
          ),
          if (to > from && stamp > 0) ...[
            const SizedBox(height: 12),
            Opacity(
              opacity: math.min(1, stamp * 2),
              child: Transform.scale(
                scale: 1 + 0.6 * (1 - Curves.easeOutBack.transform(stamp)),
                child: Column(
                  children: [
                    RealmSeal(hanzi: def.realms[to].hanzi, size: 56),
                    const SizedBox(height: 6),
                    Text(
                      '${t.realmUp}: ${text.realm(def.realms[to].id)}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: Palette.lacquer,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        for (final id in opened)
                          _UnlockChip(label: unlockLabel(t, text, id)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UnlockChip extends StatelessWidget {
  const _UnlockChip({required this.label, this.sealed = false});

  final String label;
  final bool sealed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: sealed
            ? Palette.surface
            : Palette.gold.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: (sealed ? Palette.textDim : Palette.gold).withValues(
            alpha: 0.5,
          ),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: sealed ? Palette.textDim : Palette.text,
        ),
      ),
    );
  }
}

/// Los reinos del cultivo, para el registro: los alcanzados con su frase y
/// lo que abrieron; los de arriba lacrados, con cuánto aliento piden.
class RealmList extends ConsumerWidget {
  const RealmList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final c = ref.watch(cultivationProvider).value;
    if (c == null || !c.active) return const SizedBox.shrink();
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Center(
          child: Text(
            t.breathTotal(c.breath),
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              color: Palette.gold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        for (final (i, r) in c.def.realms.indexed)
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
            decoration: BoxDecoration(
              color: Palette.surface.withValues(alpha: i <= c.realm ? 0.9 : 0.6),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: (i == c.realm ? Palette.lacquer : Palette.line)
                    .withValues(alpha: 0.6),
                width: i == c.realm ? 1.6 : 1,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                RealmSeal(hanzi: r.hanzi, size: 40, sealed: i > c.realm),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.realm(r.id),
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: i > c.realm ? Palette.textDim : Palette.text,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        i > c.realm
                            ? '${t.realmLocked} · ${t.realmNeeds(r.breath)}'
                            : text.realmText(r.id),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Palette.textDim,
                        ),
                      ),
                      if (r.unlocks.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final id in r.unlocks)
                              _UnlockChip(
                                label: unlockLabel(t, text, id),
                                sealed: i > c.realm,
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
