import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../labels.dart';
import '../../infrastructure/progress_storage.dart';
import '../providers.dart';
import '../theme.dart';
import 'juice.dart';

/// Color de cada dificultad: de jade (tranquila) a laca (maestro).
Color difficultyColor(Difficulty d) => switch (d) {
  Difficulty.easy => Palette.jade,
  Difficulty.normal => Palette.sky,
  Difficulty.hard => Palette.gold,
  Difficulty.shifu => Palette.lacquer,
};

/// Tono de una dificultad bloqueada: casi blanco, como papel sin tinta.
const _lockedTone = Color(0xFFEFE9DD);

/// Color de los Picos: el morado de la Estructura, distinto a las cuatro.
const picoColor = Palette.structure;

/// Lo que se elige antes de subir: la dificultad y, sobre Normal, un Pico.
typedef RunChoice = ({Difficulty difficulty, int pico});

/// Pregunta la dificultad de la subida nueva. Null si se cierra sin elegir.
Future<RunChoice?> pickDifficulty(
  BuildContext context, {
  Difficulty initial = Difficulty.normal,
  int initialPico = 0,
}) => showModalBottomSheet<RunChoice>(
  context: context,
  backgroundColor: Palette.bg,
  isScrollControlled: true,
  shape: const RoundedRectangleBorder(
    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
  ),
  builder: (_) => _DifficultySheet(initial: initial, initialPico: initialPico),
);

class _DifficultySheet extends ConsumerStatefulWidget {
  const _DifficultySheet({required this.initial, required this.initialPico});

  final Difficulty initial;
  final int initialPico;

  @override
  ConsumerState<_DifficultySheet> createState() => _DifficultySheetState();
}

class _DifficultySheetState extends ConsumerState<_DifficultySheet> {
  /// Toques sobre una dificultad bloqueada: sacuden la opción y muestran
  /// cómo se desbloquea.
  int _lockedTaps = 0;
  int _picoTaps = 0;

  /// Pico elegido en el selector (null = el último jugado o el más alto).
  int? _pico;

  void _deny(VoidCallback count) {
    HapticFeedback.lightImpact();
    ref.read(audioProvider).play(Sfx.cardDeny);
    setState(count);
  }

  void _choose(Difficulty d, [int pico = 0]) {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    Navigator.pop(context, (difficulty: d, pico: pico));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final balance = ref.watch(dataProvider).balance;
    // Mientras carga se asume bloqueada: nunca se muestra Shifu abierta de más.
    final wins = ref.watch(winsProvider).value ?? const <Difficulty>{};
    final picos = ref.watch(picoUnlockedProvider).value ?? 0;
    final pico = (_pico ??
            (widget.initialPico > 0 ? widget.initialPico : picos))
        .clamp(1, picos < 1 ? 1 : picos);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Palette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.difficultyTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            Text(
              t.difficultySubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Palette.textDim),
            ),
            const SizedBox(height: 14),
            for (final d in Difficulty.values) ...[
              if (!isUnlocked(d, wins))
                _LockedOption(
                  hanzi: balance.difficulty(d).hanzi,
                  name: t.difficultyName(d),
                  desc: t.difficultyDesc(d),
                  hint: t.difficultyShifuLocked,
                  taps: _lockedTaps,
                  onTap: () => _deny(() => _lockedTaps++),
                )
              else
                _Option(
                  difficulty: d,
                  hanzi: balance.difficulty(d).hanzi,
                  stats: t.difficultyStats(
                    balance.difficulty(d).playerHp,
                    balance.difficulty(d).fountainHeal,
                    balance.difficulty(d).enemyDamage,
                  ),
                  selected: d == widget.initial && widget.initialPico == 0,
                  onTap: () => _choose(d),
                ),
              const SizedBox(height: 10),
            ],
            // Los Picos van encima de Normal y se abren ganando.
            if (picos < 1)
              _LockedOption(
                color: picoColor,
                hanzi: '峰',
                name: t.picosTitle,
                desc: t.picosDesc,
                hint: t.picosLocked,
                taps: _picoTaps,
                onTap: () => _deny(() => _picoTaps++),
              )
            else
              _PicoOption(
                pico: pico,
                max: picos,
                selected: widget.initialPico > 0,
                onStep: (n) {
                  HapticFeedback.selectionClick();
                  ref.read(audioProvider).play(Sfx.cardSelect);
                  setState(() => _pico = n);
                },
                onTap: () => _choose(Difficulty.normal, pico),
              ),
          ],
        ),
      ),
    );
  }
}

class _Option extends StatelessWidget {
  const _Option({
    required this.difficulty,
    required this.hanzi,
    required this.stats,
    required this.selected,
    required this.onTap,
  });

  final Difficulty difficulty;
  final String hanzi;
  final String stats;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final color = difficultyColor(difficulty);
    return Material(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? color : Palette.line,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                child: Text(
                  hanzi,
                  style: const TextStyle(fontSize: 24, color: Palette.onColor),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.difficultyName(difficulty),
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                    Text(
                      t.difficultyDesc(difficulty),
                      style: const TextStyle(fontSize: 13, color: Palette.text),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      stats,
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

/// Opción que existe pero todavía no se puede elegir: tono blanco, candado y,
/// al tocarla, un globo que dice cómo se gana.
class _LockedOption extends StatelessWidget {
  const _LockedOption({
    this.color,
    required this.hanzi,
    required this.name,
    required this.desc,
    required this.hint,
    required this.taps,
    required this.onTap,
  });

  /// Borde punteado del color que tendrá al abrirse (null = sin pista).
  final Color? color;
  final String hanzi;
  final String name;
  final String desc;
  final String hint;
  final int taps;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final open = taps > 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Shake(
          trigger: taps,
          strength: 6,
          child: Material(
            color: Palette.surface.withValues(alpha: 0.6),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Palette.line, width: 1.5),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: _lockedTone,
                        shape: BoxShape.circle,
                        border: Border.all(color: Palette.line, width: 1.5),
                      ),
                      child: Text(
                        hanzi,
                        style: TextStyle(
                          fontSize: 24,
                          color: color?.withValues(alpha: 0.45) ??
                              Palette.textDim,
                        ),
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
                              fontWeight: FontWeight.w800,
                              color: Palette.textDim,
                            ),
                          ),
                          Text(
                            desc,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Palette.textDim,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            t.difficultyLocked,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: Palette.textDim,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Bounce(
                      trigger: taps,
                      child: const Icon(
                        Icons.lock_rounded,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 260),
          curve: Curves.easeOutBack,
          child: !open
              ? const SizedBox(width: double.infinity)
              : Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: _Hint(text: hint),
                ),
        ),
      ],
    );
  }
}

/// Los Picos abiertos: un selector del 1 al más alto ganado, con la regla
/// nueva de ese Pico y cuántas arrastra. Tocar la tarjeta sube en Normal.
class _PicoOption extends StatelessWidget {
  const _PicoOption({
    required this.pico,
    required this.max,
    required this.selected,
    required this.onStep,
    required this.onTap,
  });

  final int pico;
  final int max;
  final bool selected;
  final ValueChanged<int> onStep;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final stack = t.picoStack(pico);
    Widget step(IconData icon, String tip, int? to) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      onPressed: to == null ? null : () => onStep(to),
      icon: Icon(icon),
      color: picoColor,
    );
    return Material(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(12, 8, 4, 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? picoColor : Palette.line,
              width: selected ? 2.5 : 1.5,
            ),
          ),
          child: Row(
            children: [
              Bounce(
                trigger: pico,
                child: Container(
                  width: 48,
                  height: 48,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: picoColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$pico',
                    style: const TextStyle(
                      fontSize: 22,
                      height: 1,
                      fontWeight: FontWeight.w800,
                      color: Palette.onColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${t.picoName(pico)} · 峰',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                        color: picoColor,
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Column(
                        key: ValueKey(pico),
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.picoNew(t.picoRule(pico)),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Palette.text,
                            ),
                          ),
                          if (stack != null)
                            Text(
                              stack,
                              style: const TextStyle(
                                fontSize: 11.5,
                                color: Palette.textDim,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              step(
                Icons.remove_circle_outline_rounded,
                t.picoLower,
                pico > 1 ? pico - 1 : null,
              ),
              step(
                Icons.add_circle_outline_rounded,
                t.picoHigher,
                pico < max ? pico + 1 : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Globo que aparece bajo la opción bloqueada con la condición para abrirla.
class _Hint extends StatelessWidget {
  const _Hint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, -6 * (1 - v)),
          child: child,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Palette.gold, width: 1.5),
        ),
        child: Row(
          children: [
            const Icon(Icons.lock_open_rounded, size: 16, color: Palette.gold),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(fontSize: 13, color: Palette.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
