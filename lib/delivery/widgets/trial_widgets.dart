import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/room.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';

/// Color de las condiciones de sala y de los retos.
const roomColor = Palette.sky;
const challengeColor = Palette.gold;

/// Color y carácter de las reglas de los Picos que se ven en el combate.
const picoRuleColor = Palette.structure;
const thinAirHanzi = '薄';

/// Color y carácter de las marcas de la memoria: la revancha (仇) y el
/// atajo de Shuang (霜, su cinta celeste).
Color markColor(NodeMark m) => switch (m) {
  NodeMark.revenge => Palette.lacquer,
  NodeMark.shuang => Palette.sky,
};
String markHanzi(NodeMark m) => switch (m) {
  NodeMark.revenge => '仇',
  NodeMark.shuang => '霜',
};

/// Las marcas de la puerta en el mapa: el carácter de la condición de la
/// sala (雾 风 桥 钟) y una estrella si trae reto.
class TrialBadges extends ConsumerWidget {
  const TrialBadges({
    super.key,
    required this.rule,
    required this.challenge,
    this.mark,
    this.dim = false,
  });

  final RoomRule? rule;
  final Challenge? challenge;
  final NodeMark? mark;
  final bool dim;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rule == null && challenge == null && mark == null) {
      return const SizedBox.shrink();
    }
    final text = ref.watch(textProvider);
    Widget chip(Color c, Widget child) {
      final color = dim ? c.withValues(alpha: 0.5) : c;
      return Container(
        width: 20,
        height: 20,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.surface,
          border: Border.all(color: color, width: 1.4),
        ),
        child: IconTheme(
          data: IconThemeData(color: color, size: 12),
          child: DefaultTextStyle.merge(
            style: TextStyle(
              color: color,
              fontSize: 11,
              height: 1,
              fontFamily: Fonts.display,
              fontWeight: FontWeight.w700,
            ),
            child: child,
          ),
        ),
      );
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      spacing: 3,
      children: [
        if (mark != null) chip(markColor(mark!), Text(markHanzi(mark!))),
        if (rule != null) chip(roomColor, Text(text.room(rule!, 'hanzi'))),
        if (challenge != null)
          chip(challengeColor, const Icon(Icons.star_rounded)),
      ],
    );
  }
}

/// Lo que dice el panel de la puerta elegida: la condición y el reto, con
/// su premio.
class TrialLines extends ConsumerWidget {
  const TrialLines({
    super.key,
    required this.rule,
    required this.challenge,
    required this.jade,
    this.mark,
    this.markLine,
    this.thinAir = 0,
  });

  /// Aire fino de los Picos (Aliento de menos por turno hasta respirar).
  final int thinAir;

  final RoomRule? rule;
  final Challenge? challenge;
  final int jade;

  /// La marca de la memoria y lo que dice (revancha, atajo de Shuang).
  final NodeMark? mark;
  final String? markLine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (rule == null && challenge == null && markLine == null && thinAir <= 0) {
      return const SizedBox.shrink();
    }
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    const style = TextStyle(fontSize: 13, height: 1.25, color: Palette.text);
    Widget line(Color c, Widget lead, String s) => Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 18,
            child: IconTheme(
              data: IconThemeData(color: c, size: 15),
              child: DefaultTextStyle.merge(
                style: TextStyle(
                  color: c,
                  fontSize: 14,
                  height: 1.1,
                  fontFamily: Fonts.display,
                  fontWeight: FontWeight.w700,
                ),
                child: lead,
              ),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(child: Text(s, style: style)),
        ],
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (mark != null && markLine != null)
          line(markColor(mark!), Text(markHanzi(mark!)), markLine!),
        if (rule != null)
          line(
            roomColor,
            Text(text.room(rule!, 'hanzi')),
            '${text.room(rule!, 'name')}: ${text.room(rule!, 'text')}',
          ),
        if (thinAir > 0)
          line(picoRuleColor, const Text(thinAirHanzi), t.thinAirLine(thinAir)),
        if (challenge != null)
          line(
            challengeColor,
            const Icon(Icons.star_rounded),
            t.trialChallenge(text.challenge(challenge!, 'text'), jade),
          ),
      ],
    );
  }
}

/// Ficha del combate: la condición de la sala (con la cuenta de la
/// campana) y cómo va el reto. Tocarla explica las dos cosas.
class TrialChip extends ConsumerWidget {
  const TrialChip({super.key, required this.trial, this.bellIn});

  final Trial trial;

  /// Turnos que faltan para la campana (0: repica al terminar este turno).
  final int? bellIn;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rule = trial.room;
    final challenge = trial.challenge;
    final thin = trial.thinAir;
    if (!trial.shown) return const SizedBox.shrink();
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final cColor = trial.failed
        ? Palette.textDim
        : trial.met
        ? Palette.jade
        : challengeColor;
    final bell = bellIn == null
        ? null
        : bellIn == 0
        ? t.bellNow
        : t.bellIn(bellIn!);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => showModalBottomSheet<void>(
        context: context,
        backgroundColor: Palette.surface,
        builder: (_) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
            child: TrialLines(
              rule: rule,
              challenge: challenge,
              jade: 0,
              thinAir: thin,
            ),
          ),
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Palette.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: (rule != null
                    ? roomColor
                    : challenge != null
                    ? cColor
                    : picoRuleColor)
                .withValues(alpha: 0.7),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (rule != null) ...[
              Text(
                text.room(rule, 'hanzi'),
                style: const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 15,
                  height: 1,
                  color: roomColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                bell ?? text.room(rule, 'name'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: bellIn == 0 ? Palette.lacquer : Palette.text,
                ),
              ),
            ],
            if (thin > 0) ...[
              if (rule != null) const SizedBox(width: 8),
              const Text(
                thinAirHanzi,
                style: TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 15,
                  height: 1,
                  color: picoRuleColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 4),
              Text(
                t.thinAirName,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Palette.text,
                ),
              ),
            ],
            if ((rule != null || thin > 0) && challenge != null)
              const SizedBox(width: 8),
            if (challenge != null) ...[
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 260),
                transitionBuilder: (c, a) => ScaleTransition(scale: a, child: c),
                child: Icon(
                  trial.met
                      ? Icons.check_circle_rounded
                      : trial.failed
                      ? Icons.cancel_outlined
                      : Icons.star_rounded,
                  key: ValueKey((trial.met, trial.failed)),
                  size: 14,
                  color: cColor,
                ),
              ),
              const SizedBox(width: 3),
              Text(
                text.challenge(challenge, 'name'),
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: trial.failed ? Palette.textDim : Palette.text,
                  decoration: trial.failed ? TextDecoration.lineThrough : null,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
