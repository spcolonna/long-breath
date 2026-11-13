part of '../combat_screen.dart';

// ---------------------------------------------------------------- jugador

/// Placa del héroe: Guardia, Vida y Estructura en una sola pieza de papel,
/// con el sello de la postura a la derecha (tocarlo es el Paso en T).
class _PlayerStrip extends ConsumerWidget {
  const _PlayerStrip({
    required this.s,
    required this.engine,
    this.locked = false,
  });

  final CombatState s;
  final CombatEngine engine;

  /// Hay una animación en curso: el sello no responde.
  final bool locked;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final p = s.player;
    final cost = engine.dingbuCost(s);
    final canDingbu = !locked &&
        !s.isOver &&
        s.phase != CombatPhase.discarding &&
        !s.dingbuUsed &&
        p.breath >= cost;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.fromLTRB(8, 6, 12, 8),
              decoration: BoxDecoration(
                color: Palette.surface.withValues(alpha: 0.94),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Palette.gold.withValues(alpha: 0.55),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF8A5A1E).withValues(alpha: 0.16),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Bounce(
                    trigger: p.guard,
                    scale: 1.25,
                    child: TutorialAnchor(
                      id: 'guard',
                      child: _GuardBadge(
                        guard: p.guard,
                        height: p.guardHeight,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              t.life,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Palette.textDim,
                              ),
                            ),
                            const Spacer(),
                            CountUp(
                              value: p.hp,
                              format: (v) => '$v/${p.maxHp}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        TrailBar(
                          ratio: p.maxHp == 0
                              ? 0
                              : (p.hp / p.maxHp).clamp(0.0, 1.0),
                          color: Palette.jade,
                          height: 13,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                t.structure,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Palette.structure,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: TrailBar(
                                ratio: p.maxStructure == 0
                                    ? 0
                                    : (p.structure / p.maxStructure)
                                          .clamp(0.0, 1.0),
                                color: Palette.structure,
                                height: 6,
                              ),
                            ),
                            const SizedBox(width: 6),
                            CountUp(
                              value: p.structure,
                              format: (v) => '$v/${p.maxStructure}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: Palette.structure,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 10),
          TutorialAnchor(
            id: 'dingbu',
            child: _StanceSeal(
              stance: p.stance,
              name: text.stance(p.stance),
              action: text.dingbu(),
              cost: cost,
              enabled: canDingbu,
              onTap: () => _pickStance(context, ref, s),
            ),
          ),
        ],
      ),
    );
  }
}

/// Escudo con la Guardia adentro; con altura marcada, la flecha al pie.
class _GuardBadge extends StatelessWidget {
  const _GuardBadge({required this.guard, this.height});

  final int guard;
  final Height? height;

  @override
  Widget build(BuildContext context) {
    final on = guard > 0;
    return Semantics(
      label: '${AppLocalizations.of(context).guard} $guard',
      child: SizedBox(
        width: 40,
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 36,
              height: 40,
              decoration: ShapeDecoration(
                color: on ? Palette.sky : Palette.bgAlt,
                shape: const _ShieldBorder(),
                shadows: on
                    ? [
                        BoxShadow(
                          color: Palette.sky.withValues(alpha: 0.35),
                          blurRadius: 8,
                        ),
                      ]
                    : null,
              ),
            ),
            ExcludeSemantics(
              child: Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  '$guard',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: on ? Palette.onColor : Palette.textDim,
                  ),
                ),
              ),
            ),
            if (height != null)
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: Palette.sky),
                  ),
                  child: Icon(heightIcon(height), size: 11, color: Palette.sky),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Contorno de escudo: arriba recto con hombros redondeados y punta abajo.
class _ShieldBorder extends ShapeBorder {
  const _ShieldBorder();

  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.zero;

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) =>
      getOuterPath(rect);

  @override
  Path getOuterPath(Rect r, {TextDirection? textDirection}) => Path()
    ..moveTo(r.left + r.width * 0.5, r.top)
    ..quadraticBezierTo(r.left + r.width * 0.78, r.top + r.height * 0.1,
        r.right, r.top + r.height * 0.08)
    ..lineTo(r.right, r.top + r.height * 0.45)
    ..quadraticBezierTo(r.right - r.width * 0.06, r.top + r.height * 0.8,
        r.left + r.width * 0.5, r.bottom)
    ..quadraticBezierTo(r.left + r.width * 0.06, r.top + r.height * 0.8,
        r.left, r.top + r.height * 0.45)
    ..lineTo(r.left, r.top + r.height * 0.08)
    ..quadraticBezierTo(r.left + r.width * 0.22, r.top + r.height * 0.1,
        r.left + r.width * 0.5, r.top)
    ..close();

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {}

  @override
  ShapeBorder scale(double t) => this;
}

const _stanceHanzi = {
  Stance.mabu: '马步',
  Stance.gongbu: '弓步',
  Stance.xubu: '虚步',
};

/// Sello de laca con la postura actual. Debajo, el Paso en T con su costo:
/// tocar cualquiera de los dos abre el cambio de postura.
class _StanceSeal extends StatelessWidget {
  const _StanceSeal({
    required this.stance,
    required this.name,
    required this.action,
    required this.cost,
    required this.enabled,
    required this.onTap,
  });

  final Stance stance;
  final String name;
  final String action;
  final int cost;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: '$name. $action',
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: enabled ? onTap : null,
        child: Press(
          enabled: enabled,
          child: ExcludeSemantics(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TutorialAnchor(
                  id: 'stances',
                  child: Bounce(
                    trigger: stance,
                    scale: 1.12,
                    child: Container(
                      width: 58,
                      height: 50,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Palette.lacquer,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: Palette.gold, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Palette.lacquer.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _stanceHanzi[stance]!,
                            style: const TextStyle(
                              fontFamily: Fonts.brush,
                              fontSize: 20,
                              height: 1.05,
                              color: Palette.onColor,
                            ),
                          ),
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 11,
                              height: 1.1,
                              fontWeight: FontWeight.w700,
                              color: Palette.onColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // Ancho fijo: un nombre largo se achica en vez de empujar la placa.
                SizedBox(
                  width: 66,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 200),
                    opacity: enabled ? 1 : 0.45,
                    child: _CostLabel(label: action, cost: cost, small: true),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Hoja para elegir la postura nueva del Paso en T.
void _pickStance(BuildContext context, WidgetRef ref, CombatState s) {
  final t = AppLocalizations.of(context);
  final text = ref.read(textProvider);
  final ctl = ref.read(combatControllerProvider.notifier);
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

// ------------------------------------------------------------------ formas

class _FormsPanel extends ConsumerWidget {
  const _FormsPanel({required this.s, required this.data, this.flash});

  final CombatState s;
  final GameData data;

  /// Forma recién completada: se ve entera en dorado un momento.
  final String? flash;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(textProvider);
    final t = AppLocalizations.of(context);
    // Todas las formas aprendidas, siempre a la vista. Los pasos cuya carta
    // no está en el mazo se ven apagados con un candado: hay que conseguirla.
    final owned = {
      for (final c in [...s.drawPile, ...s.hand, ...s.discard, ...s.exhausted])
        c.cardId,
    };
    final known = data.forms.where((f) => s.formProgress.containsKey(f.id));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          for (final f in known)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          text.form(f.id),
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 10,
                            height: 1.1,
                            fontWeight: FontWeight.w700,
                            color: Palette.gold,
                          ),
                        ),
                        Text(
                          owned.containsAll(f.steps)
                              ? f.hanzi
                              : t.formMissingShort,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9,
                            color: owned.containsAll(f.steps)
                                ? Palette.textDim
                                : Palette.lacquer,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < f.steps.length; i++)
                    Expanded(
                      child: Bounce(
                        trigger: i < _progress(f),
                        scale: 1.15,
                        child: _FormStep(
                          label: text.card(f.steps[i]),
                          done: i < _progress(f),
                          next: flash != f.id && i == _progress(f),
                          owned: owned.contains(f.steps[i]),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

extension on _FormsPanel {
  int _progress(FormDef f) =>
      flash == f.id ? f.steps.length : s.formProgress[f.id]!;
}

class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.label,
    required this.done,
    required this.next,
    this.owned = true,
  });

  final String label;
  final bool done;
  final bool next;

  /// La carta del paso está en el mazo; si no, el paso no se puede dar.
  final bool owned;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 26,
      margin: const EdgeInsets.only(right: 3),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: done ? Palette.gold : Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: next ? Palette.gold : Palette.line,
          width: next ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
      child: Opacity(
        opacity: owned ? 1 : 0.5,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!owned)
              const Padding(
                padding: EdgeInsets.only(right: 1),
                child: Icon(
                  Icons.lock_outline,
                  size: 9,
                  color: Palette.textDim,
                ),
              ),
            Flexible(
              child: Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8.5,
                  height: 1.05,
                  fontWeight: FontWeight.w600,
                  color: done ? Palette.onColor : Palette.textDim,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
