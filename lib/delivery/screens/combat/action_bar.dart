part of '../combat_screen.dart';

class _ActionBar extends ConsumerWidget {
  const _ActionBar({
    required this.view,
    required this.engine,
    required this.data,
    this.locked = false,
  });

  final CombatView view;
  final CombatEngine engine;
  final GameData data;

  /// Hay una animación en curso: los botones se ven apagados.
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final s = view.state;
    final ctl = ref.read(combatControllerProvider.notifier);
    final busy = locked || s.isOver || s.phase == CombatPhase.discarding;

    if (view.retaining) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: ctl.cancelRetain,
                child: Text(t.cancel),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: ctl.confirmRetain,
                child: Text(
                  '${t.confirm} (${view.retain.length}/${s.retainMax})',
                ),
              ),
            ),
          ],
        ),
      );
    }

    final canDingbu =
        !busy && !s.dingbuUsed && s.player.breath >= engine.dingbuCost(s);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          TutorialAnchor(
            id: 'breath',
            child: _BreathPips(
              breath: s.player.breath,
              perTurn: s.breathPerTurn,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: TutorialAnchor(
              id: 'dingbu',
              child: OutlinedButton(
                onPressed: canDingbu
                    ? () => _pickStance(context, ref, ctl, s)
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: _CostLabel(
                  label: text.dingbu(),
                  cost: engine.dingbuCost(s),
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TutorialAnchor(
              id: 'breathe',
              child: OutlinedButton(
                onPressed: !busy && engine.validate(s, const Breathe()) == null
                    ? ctl.breathe
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: _CostLabel(
                  label: t.breathe,
                  cost: data.balance.breatheCost,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: TutorialAnchor(
              id: 'endTurn',
              child: FilledButton(
                onPressed: busy ? null : ctl.endTurnPressed,
                child: Text(t.endTurn, maxLines: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _pickStance(
    BuildContext context,
    WidgetRef ref,
    CombatController ctl,
    CombatState s,
  ) {
    final t = AppLocalizations.of(context);
    final text = ref.read(textProvider);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                '${text.dingbu()} 丁步 · ${t.changeStance(t.breath)}',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            for (final st in Stance.values)
              if (st != s.player.stance &&
                  (TutorialOverlay.stanceGate.value ?? st) == st)
                ListTile(
                  leading: Text(
                    _stanceHanzi[st]!,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Palette.textDim,
                    ),
                  ),
                  title: Text(
                    text.stance(st),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(t.stanceHint(st)),
                  onTap: () {
                    Navigator.pop(ctx);
                    ctl.dingbu(st);
                  },
                ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

/// Nombre de una acción con lo que cuesta en Aliento, en un punto celeste.
class _CostLabel extends StatelessWidget {
  const _CostLabel({required this.label, required this.cost});

  final String label;
  final int cost;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, maxLines: 1),
          const SizedBox(width: 4),
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.sky,
            ),
            child: Text(
              '$cost',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w800,
                color: Palette.onColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BreathPips extends StatelessWidget {
  const _BreathPips({required this.breath, required this.perTurn});

  final int breath;
  final int perTurn;

  @override
  Widget build(BuildContext context) {
    final n = math.max(breath, perTurn);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < n; i++)
              // Cada punto de Aliento se vacía encogiéndose y vuelve con un rebote.
              AnimatedScale(
                scale: i < breath ? 1 : 0.7,
                duration: Duration(milliseconds: 240 + 60 * i),
                curve: Curves.easeOutBack,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: n > 4 ? 9 : 12,
                  height: n > 4 ? 9 : 12,
                  margin: const EdgeInsets.symmetric(horizontal: 1.5),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: i < breath ? Palette.sky : Colors.transparent,
                    border: Border.all(color: Palette.sky),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameIcon(Icons.air, size: 13, color: Palette.sky),
            const SizedBox(width: 2),
            Text(
              '${AppLocalizations.of(context).breath} $breath',
              style: const TextStyle(fontSize: 10, color: Palette.sky),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- efectos

/// Camino elegido y su ventaja; al tocarlo se explica qué da.
class _StyleChip extends ConsumerStatefulWidget {
  const _StyleChip({required this.style});

  final Style style;

  @override
  ConsumerState<_StyleChip> createState() => _StyleChipState();
}

class _StyleChipState extends ConsumerState<_StyleChip> {
  bool _open = false;
  Timer? _close;

  @override
  void dispose() {
    _close?.cancel();
    super.dispose();
  }

  void _toggle() {
    Haptics.selectionClick();
    _close?.cancel();
    setState(() => _open = !_open);
    if (_open) {
      _close = Timer(const Duration(seconds: 5), () {
        if (mounted) setState(() => _open = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final balance = ref.watch(dataProvider).balance;
    final stats = balance.styles[widget.style]!;
    final text = ref.watch(textProvider);
    final awakenings =
        ref.watch(runControllerProvider)?.awakenings ?? const <String>[];
    final aw = balance.awakeningsEffect(awakenings);
    final color = styleColor(widget.style);
    // El chip muestra la pasiva propia del camino (con sus despertares).
    final edge = stats.firstStrike > 0
        ? t.styleChipFirstStrike(stats.hanzi, stats.firstStrike + aw.firstStrike)
        : stats.chain > 0
        ? t.styleChipChain(stats.hanzi, stats.chain + aw.chain)
        : stats.retainedDiscount > 0
        ? t.styleChipRetained(
            stats.hanzi,
            stats.retainedDiscount + aw.retainedDiscount,
          )
        : stats.retain > 0
        ? t.styleChipRetain(stats.hanzi, stats.retain)
        : t.styleChipDraw(stats.hanzi, stats.draw);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: _toggle,
          child: Bounce(
            trigger: _open,
            child: _Chip(icon: Icons.info_outline, text: edge, color: color),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          alignment: Alignment.topLeft,
          child: !_open
              ? const SizedBox(width: 0)
              : GestureDetector(
                  onTap: _toggle,
                  child: Container(
                    width: 220,
                    margin: const EdgeInsets.only(top: 6),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: color, width: 1.5),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          t.styleBenefit(widget.style),
                          style: const TextStyle(
                            fontSize: 12,
                            height: 1.25,
                            color: Palette.text,
                          ),
                        ),
                        for (final id in awakenings) ...[
                          const SizedBox(height: 6),
                          Text.rich(
                            TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      '${balance.awakening(id).hanzi} ${text.awakening(id)}. ',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                                TextSpan(
                                  text: t.awakeningEffect(
                                    balance.awakening(id).effect,
                                  ),
                                ),
                              ],
                            ),
                            style: const TextStyle(
                              fontSize: 12,
                              height: 1.25,
                              color: Palette.text,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text, required this.color});

  final IconData icon;
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(right: 6),
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      // Opaco: se lee también sobre el arte del fondo.
      color: Color.alphaBlend(color.withValues(alpha: 0.2), Palette.surface),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameIcon(icon, size: 13, color: color),
        const SizedBox(width: 4),
        // En columnas angostas (enemigo) el texto se corta en vez de desbordar.
        Flexible(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 11, color: color),
          ),
        ),
      ],
    ),
  );
}
