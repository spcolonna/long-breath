import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_state.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../providers.dart';
import '../theme.dart';
import 'deck_sheet.dart';
import 'press.dart';
import 'scene_backdrop.dart';

/// Piezas comunes de las pantallas de un lugar del camino (mercader, maestro,
/// fuente, evento, santuario): el fondo de la etapa, las opciones que se
/// tocan y la elección de una carta del mazo. Lo nuevo se arma con esto y
/// sale con el mismo feel (ver `docs/feel.md`).

/// Fondo de un lugar del camino: [file] de la etapa (o de la base), con el
/// velo de papel justo para leer encima.
class NodeBackdrop extends ConsumerWidget {
  const NodeBackdrop({
    super.key,
    required this.child,
    this.file = 'map_bg.webp',
    this.extra = const [],
    this.veil = 0.62,
  });

  final Widget child;
  final String file;

  /// Rutas que se prueban antes del fondo de la etapa.
  final List<String> extra;
  final double veil;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final run = ref.watch(runControllerProvider);
    final stages = ref.watch(dataProvider).balance.stages;
    final stage = stages[(run?.stage ?? 0).clamp(0, stages.length - 1)].id;
    return SceneBackdrop(
      assets: [...extra, ...stageArt(stage, file)],
      veil: veil,
      child: child,
    );
  }
}

/// Opción de papel que se toca: título, una línea de detalle y un ícono a la
/// derecha. Se hunde al tocarla; apagada, el detalle dice por qué.
class ChoiceTile extends StatelessWidget {
  const ChoiceTile({
    super.key,
    required this.title,
    required this.onTap,
    this.detail,
    this.blocked,
    this.leading,
    this.trailing = Icons.chevron_right_rounded,
    this.accent,
    this.enabled = true,
  });

  final String title;
  final String? detail;

  /// Lo que se muestra en lugar de [detail] cuando está apagada.
  final String? blocked;
  final IconData? leading;
  final IconData trailing;

  /// Borde y ícono resaltados (por ejemplo, una opción con riesgo).
  final Color? accent;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dim = !enabled;
    final line = enabled ? detail : blocked ?? detail;
    return Press(
      enabled: enabled,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            // Papel translúcido: se lee sobre el fondo pintado.
            color: Palette.surface.withValues(alpha: dim ? 0.6 : 0.9),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: dim ? Palette.line : accent ?? Palette.line,
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              if (leading != null) ...[
                Icon(
                  leading,
                  color: dim ? Palette.textDim : accent ?? Palette.lacquer,
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: dim ? Palette.textDim : Palette.text,
                      ),
                    ),
                    if (line != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        line,
                        style: TextStyle(
                          fontSize: 13,
                          color: dim ? Palette.lacquer : Palette.textDim,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                trailing,
                color: dim ? Palette.line : accent ?? Palette.textDim,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Elegir una carta del mazo para quitarla o mejorarla, a pantalla completa:
/// encabezado de papel con volver, una línea de ayuda y la grilla animada.
class DeckPickScreen extends ConsumerWidget {
  const DeckPickScreen({
    super.key,
    required this.title,
    required this.cards,
    required this.fx,
    required this.onPick,
    required this.onBack,
    this.hint,
    this.enabled,
  });

  final String title;
  final String? hint;
  final List<CombatCard> cards;
  final DeckPick fx;
  final void Function(CombatCard) onPick;
  final VoidCallback onBack;
  final bool Function(CombatCard)? enabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = fx == DeckPick.remove ? Palette.lacquer : Palette.gold;
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 4),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      Haptics.selectionClick();
                      ref.read(audioProvider).play(Sfx.uiButton);
                      onBack();
                    },
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    fx == DeckPick.remove
                        ? Icons.local_fire_department_rounded
                        : Icons.auto_awesome_rounded,
                    color: color,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (hint != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                child: Text(
                  hint!,
                  style: const TextStyle(fontSize: 13, color: Palette.textDim),
                ),
              ),
            Container(
              height: 2,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0),
                    color.withValues(alpha: 0.6),
                    color.withValues(alpha: 0),
                  ],
                ),
              ),
            ),
            Expanded(
              child: DeckGrid(
                cards: cards,
                enabled: enabled,
                pickFx: fx,
                onPick: onPick,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
