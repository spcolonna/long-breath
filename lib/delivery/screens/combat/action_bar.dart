part of '../combat_screen.dart';

/// Pie de la pelea: el medallón de Aliento con Respirar al lado y el sello
/// grande de Terminar turno. El Paso en T vive en el sello de postura.
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
          TutorialAnchor(
            id: 'breathe',
            child: OutlinedButton(
              onPressed: !busy && engine.validate(s, const Breathe()) == null
                  ? ctl.breathe
                  : null,
              style: OutlinedButton.styleFrom(
                shape: const StadiumBorder(),
                minimumSize: const Size(0, 44),
                padding: const EdgeInsets.symmetric(horizontal: 14),
              ),
              child: _CostLabel(
                label: t.breathe,
                cost: data.balance.breatheCost,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: TutorialAnchor(
              id: 'endTurn',
              child: FilledButton(
                onPressed: busy ? null : ctl.endTurnPressed,
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 52),
                  side: BorderSide(
                    color: Palette.gold.withValues(alpha: busy ? 0.3 : 0.9),
                    width: 1.5,
                  ),
                  elevation: busy ? 0 : 3,
                  shadowColor: Palette.lacquer.withValues(alpha: 0.5),
                  textStyle: const TextStyle(
                    fontFamily: Fonts.display,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: Text(t.endTurn, maxLines: 1),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Nombre de una acción con lo que cuesta en Aliento, en un punto celeste.
class _CostLabel extends StatelessWidget {
  const _CostLabel({
    required this.label,
    required this.cost,
    this.small = false,
  });

  final String label;
  final int cost;
  final bool small;

  @override
  Widget build(BuildContext context) {
    final dot = small ? 14.0 : 16.0;
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            maxLines: 1,
            style: small
                ? const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Palette.text,
                  )
                : null,
          ),
          const SizedBox(width: 4),
          Container(
            width: dot,
            height: dot,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.sky,
            ),
            child: Text(
              '$cost',
              style: TextStyle(
                fontSize: small ? 9 : 10,
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

/// Medallón de Aliento: el número grande al centro y un punto por cada
/// Aliento alrededor del aro, que se vacía encogiéndose.
class _BreathPips extends StatelessWidget {
  const _BreathPips({required this.breath, required this.perTurn});

  final int breath;
  final int perTurn;

  static const _size = 60.0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final n = math.max(breath, perTurn);
    final pip = n > 6 ? 7.0 : 9.0;
    // Los puntos se reparten por el arco de arriba, de izquierda a derecha.
    const r = _size / 2 - 1;
    final span = math.min(math.pi * 1.4, n * 0.42);
    return Semantics(
      label: '${t.breath} $breath',
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned.fill(
              child: Container(
                margin: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.surface,
                  border: Border.all(color: Palette.sky, width: 2.5),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.sky.withValues(alpha: 0.25),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: ExcludeSemantics(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CountUp(
                        value: breath,
                        duration: const Duration(milliseconds: 300),
                        style: const TextStyle(
                          fontFamily: Fonts.display,
                          fontSize: 24,
                          height: 1,
                          fontWeight: FontWeight.w700,
                          color: Palette.sky,
                        ),
                      ),
                      Text(
                        t.breath,
                        style: const TextStyle(
                          fontSize: 9,
                          height: 1.1,
                          color: Palette.sky,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            for (var i = 0; i < n; i++)
              Builder(
                builder: (_) {
                  final a = n == 1
                      ? -math.pi / 2
                      : -math.pi / 2 - span / 2 + span * i / (n - 1);
                  return Positioned(
                    left: _size / 2 + r * math.cos(a) - pip / 2,
                    top: _size / 2 + r * math.sin(a) - pip / 2,
                    child: AnimatedScale(
                      scale: i < breath ? 1 : 0.7,
                      duration: Duration(milliseconds: 240 + 60 * i),
                      curve: Curves.easeOutBack,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: pip,
                        height: pip,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: i < breath ? Palette.sky : Palette.surface,
                          border: Border.all(color: Palette.sky, width: 1.5),
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
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
