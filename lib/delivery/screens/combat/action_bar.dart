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
            child: GlossaryTap(
              term: Term.breath,
              child: _BreathPips(
                breath: s.player.breath,
                perTurn: s.breathPerTurn,
              ),
            ),
          ),
          const SizedBox(width: 8),
          TutorialAnchor(
            id: 'breathe',
            child: _BreatheButton(
              state: s,
              chargeAt: data.balance.breatheChargeAt,
              onPressed: !busy &&
                      BreatheMode.values.any(
                        (m) => engine.validate(s, Breathe(m)) == null,
                      )
                  ? () => _pickBreathe(
                      context,
                      ref,
                      engine,
                      s,
                      lesson: view.lessonId != null,
                    )
                  : null,
            ),
          ),
          // Contragolpe: aparece solo cuando un desvío lo dejó listo.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: s.counterReady
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _SealButton(
                      hanzi: '反',
                      label: t.counter,
                      color: Palette.gold,
                      onPressed: busy
                          ? null
                          : () => _pickCounter(context, ref, engine, s),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
          // Técnica del Camino: con el Flujo lleno, el sello del camino late.
          AnimatedSize(
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOutBack,
            child: s.style != null && s.flow >= CombatEngine.flowMax
                ? Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: _SealButton(
                      hanzi: engine.data.balance.statsOf(s.style).hanzi,
                      label: t.technique,
                      color: styleColor(s.style),
                      onPressed: busy ||
                              engine.validate(s, const Technique()) != null
                          ? null
                          : () => _pickTechnique(context, ref, engine, s),
                    ),
                  )
                : const SizedBox.shrink(),
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


/// Respirar en píldora: el anillo de carga a la izquierda (un arco por paso,
/// el número de cargas listas al centro) y el nombre. Al cargarse rebota.
class _BreatheButton extends StatelessWidget {
  const _BreatheButton({
    required this.state,
    required this.chargeAt,
    required this.onPressed,
  });

  final CombatState state;
  final int chargeAt;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final charges = state.breathesLeft;
    final ready = charges > 0;
    return Semantics(
      button: true,
      label: t.breatheCharges(charges, state.breathCharge, chargeAt),
      excludeSemantics: true,
      child: Bounce(
        trigger: charges,
        scale: 1.12,
        child: OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            shape: const StadiumBorder(),
            minimumSize: const Size(0, 44),
            padding: const EdgeInsets.fromLTRB(6, 0, 14, 0),
            side: BorderSide(
              color: ready ? Palette.sky : Palette.line,
              width: ready ? 1.8 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _ChargeRing(
                charges: charges,
                progress: state.breathCharge,
                steps: chargeAt,
              ),
              const SizedBox(width: 6),
              Text(t.breathe, maxLines: 1),
            ],
          ),
        ),
      ),
    );
  }
}

/// Aro de carga de Respirar: [steps] arcos que se llenan de celeste y, al
/// centro, las cargas listas.
class _ChargeRing extends StatelessWidget {
  const _ChargeRing({
    required this.charges,
    required this.progress,
    required this.steps,
  });

  final int charges;
  final int progress;
  final int steps;

  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.disableAnimationsOf(context);
    return TweenAnimationBuilder<double>(
      tween: Tween(end: progress.toDouble()),
      duration: reduce ? Duration.zero : const Duration(milliseconds: 420),
      curve: Curves.easeOutCubic,
      builder: (context, p, _) => SizedBox(
        width: 32,
        height: 32,
        child: CustomPaint(
          painter: _ChargePainter(progress: p, steps: steps, full: charges > 0),
          child: Center(
            child: Text(
              '$charges',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w800,
                color: charges > 0 ? Palette.sky : Palette.textDim,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChargePainter extends CustomPainter {
  _ChargePainter({
    required this.progress,
    required this.steps,
    required this.full,
  });

  final double progress;
  final int steps;
  final bool full;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final r = rect.deflate(3);
    const gap = 0.32;
    final seg = 2 * math.pi / steps;
    final base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.2
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(
      rect.center,
      r.width / 2 + 1,
      Paint()..color = (full ? Palette.sky : Palette.line).withValues(alpha: 0.14),
    );
    for (var i = 0; i < steps; i++) {
      final start = -math.pi / 2 + i * seg + gap / 2;
      final sweep = seg - gap;
      canvas.drawArc(
        r,
        start,
        sweep,
        false,
        base..color = Palette.line.withValues(alpha: 0.6),
      );
      final f = (progress - i).clamp(0.0, 1.0);
      if (f > 0) {
        canvas.drawArc(r, start, sweep * f, false, base..color = Palette.sky);
      }
    }
  }

  @override
  bool shouldRepaint(_ChargePainter old) =>
      old.progress != progress || old.steps != steps || old.full != full;
}

/// Hoja para elegir cómo gastar la carga de Respirar. En las lecciones solo
/// se puede cambiar la mano (los otros modos se ven, apagados).
void _pickBreathe(
  BuildContext context,
  WidgetRef ref,
  CombatEngine engine,
  CombatState s, {
  bool lesson = false,
}) {
  final t = AppLocalizations.of(context);
  final b = engine.data.balance;
  final ctl = ref.read(combatControllerProvider.notifier);
  Haptics.selectionClick();
  final modes = [
    (BreatheMode.hand, '换', t.breatheModeHand, t.breatheModeHandSub(b.breatheMinDraw), b.breatheCost),
    (BreatheMode.breath, '气', t.breatheModeBreath, t.breatheModeBreathSub(b.breatheBreath), 0),
    (BreatheMode.structure, '稳', t.breatheModeStructure, t.breatheModeStructureSub(b.breatheStructure), 0),
  ];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Palette.text.withValues(alpha: 0.22),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PaperPanel(
          opacity: 0.98,
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.breatheModeTitle,
                style: const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              for (final (mode, hanzi, title, sub, cost) in modes)
                Builder(
                  builder: (_) {
                    final invalid = engine.validate(s, Breathe(mode));
                    final ok =
                        invalid == null && (!lesson || mode == BreatheMode.hand);
                    return ListTile(
                      enabled: ok,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Text(
                        hanzi,
                        style: TextStyle(
                          fontFamily: Fonts.brush,
                          fontSize: 26,
                          color: ok ? Palette.sky : Palette.textDim,
                        ),
                      ),
                      title: cost > 0
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: _CostLabel(label: title, cost: cost),
                            )
                          : Text(
                              title,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                      subtitle: Text(
                        invalid != null ? t.invalidLabel(invalid) : sub,
                      ),
                      onTap: () {
                        Navigator.pop(ctx);
                        ctl.breathe(mode);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Sello dorado del Contragolpe (反) que late mientras está listo.
/// Sello redondo que late: Contragolpe (反) y Técnica del Camino (虎 蛇 鹤).
class _SealButton extends StatefulWidget {
  const _SealButton({
    required this.hanzi,
    required this.label,
    required this.color,
    required this.onPressed,
  });

  final String hanzi;
  final String label;

  /// Borde y brillo.
  final Color color;
  final VoidCallback? onPressed;

  @override
  State<_SealButton> createState() => _SealButtonState();
}

class _SealButtonState extends State<_SealButton>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _pulse.value = 0.5;
    } else if (!_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final on = widget.onPressed != null;
    final c = widget.color;
    return Semantics(
      button: true,
      label: widget.label,
      excludeSemantics: true,
      child: GestureDetector(
        onTap: widget.onPressed,
        child: AnimatedBuilder(
          animation: _pulse,
          builder: (_, child) {
            final v = Curves.easeInOut.transform(_pulse.value);
            return Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Palette.surface,
                border: Border.all(
                  color: c.withValues(alpha: on ? 0.95 : 0.35),
                  width: 2,
                ),
                boxShadow: on
                    ? [
                        BoxShadow(
                          color: c.withValues(alpha: 0.25 + 0.3 * v),
                          blurRadius: 6 + 8 * v,
                          spreadRadius: 1 * v,
                        ),
                      ]
                    : null,
              ),
              child: child,
            );
          },
          child: Text(
            widget.hanzi,
            style: TextStyle(
              fontFamily: Fonts.brush,
              fontSize: 26,
              height: 1,
              color: on ? Palette.lacquer : Palette.textDim,
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja para elegir el Contragolpe.
void _pickCounter(
  BuildContext context,
  WidgetRef ref,
  CombatEngine engine,
  CombatState s,
) {
  final t = AppLocalizations.of(context);
  final b = engine.data.balance;
  final ctl = ref.read(combatControllerProvider.notifier);
  Haptics.selectionClick();
  final modes = [
    (CounterMode.free, '免', t.counterFree, t.counterFreeSub),
    (CounterMode.draw, '读', t.counterDraw, t.counterDrawSub(b.counterDraw)),
    (CounterMode.flow, '流', t.counterFlow, t.counterFlowSub),
  ];
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Palette.text.withValues(alpha: 0.22),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PaperPanel(
          opacity: 0.98,
          padding: const EdgeInsets.fromLTRB(8, 14, 8, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.counterTitle,
                style: const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 6),
                child: Text(
                  t.counterSub,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Palette.textDim, fontSize: 13),
                ),
              ),
              for (final (mode, hanzi, title, sub) in modes)
                Builder(
                  builder: (_) {
                    final invalid = engine.validate(s, Counter(mode));
                    final ok = invalid == null;
                    return ListTile(
                      enabled: ok,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      leading: Text(
                        hanzi,
                        style: TextStyle(
                          fontFamily: Fonts.brush,
                          fontSize: 26,
                          color: ok ? Palette.lacquer : Palette.textDim,
                        ),
                      ),
                      title: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      subtitle: Text(ok ? sub : t.invalidLabel(invalid)),
                      onTap: () {
                        Navigator.pop(ctx);
                        ctl.counter(mode);
                      },
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// Hoja de la Técnica del Camino: qué hace y el botón para usarla.
void _pickTechnique(
  BuildContext context,
  WidgetRef ref,
  CombatEngine engine,
  CombatState s,
) {
  final t = AppLocalizations.of(context);
  final b = engine.data.balance;
  final ctl = ref.read(combatControllerProvider.notifier);
  final style = s.style!;
  final color = styleColor(style);
  final (name, sub) = switch (style) {
    Style.tiger => (
      t.techTiger,
      t.techTigerSub(b.techTigerDamage, b.techTigerStructure),
    ),
    Style.snake => (
      t.techSnake,
      t.techSnakeSub(b.techSnakeHits, b.techSnakeDamage, b.techSnakeStructure),
    ),
    Style.crane => (
      t.techCrane,
      t.techCraneSub(b.techCraneDamage, b.techCraneGuard, b.techCraneDraw),
    ),
  };
  Haptics.selectionClick();
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Palette.text.withValues(alpha: 0.22),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PaperPanel(
          opacity: 0.98,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                t.technique,
                style: const TextStyle(color: Palette.textDim, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                b.statsOf(style).hanzi,
                style: TextStyle(
                  fontFamily: Fonts.brush,
                  fontSize: 54,
                  height: 1.1,
                  color: color,
                ),
              ),
              Text(
                name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: Fonts.display,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              Text(sub, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text(
                t.techniqueSub,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textDim, fontSize: 13),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    backgroundColor: color,
                  ),
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctl.technique();
                  },
                  child: Text(t.techniqueUse),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
