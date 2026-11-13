part of '../combat_screen.dart';

// ---------------------------------------------------------------- jugador

class _PlayerStrip extends ConsumerWidget {
  const _PlayerStrip({required this.s});

  final CombatState s;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final p = s.player;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Column(
        children: [
          StatBar(
            label: t.life,
            value: p.hp,
            max: p.maxHp,
            color: Palette.jade,
          ),
          const SizedBox(height: 3),
          StatBar(
            label: t.structure,
            value: p.structure,
            max: p.maxStructure,
            color: Palette.structure,
            height: 8,
          ),
          const SizedBox(height: 6),
          TutorialAnchor(
            id: 'stances',
            child: Row(
              children: [
                for (final st in Stance.values)
                  Expanded(
                    child: Bounce(
                      trigger: st == p.stance,
                      scale: 1.1,
                      child: _StanceChip(
                        name: text.stance(st),
                        hanzi: _stanceHanzi[st]!,
                        active: st == p.stance,
                      ),
                    ),
                  ),
                const SizedBox(width: 2),
                Bounce(
                  trigger: p.guard,
                  scale: 1.25,
                  child: TutorialAnchor(
                    id: 'guard',
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: p.guard > 0 ? Palette.sky : Palette.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: p.guard > 0 ? Palette.sky : Palette.line,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          GameIcon(
                            Icons.shield,
                            size: 16,
                            color: p.guard > 0 ? Palette.onColor : Palette.sky,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${p.guard}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: p.guard > 0
                                  ? Palette.onColor
                                  : Palette.text,
                            ),
                          ),
                          if (p.guardHeight != null)
                            Icon(
                              heightIcon(p.guardHeight),
                              size: 14,
                              color: Palette.onColor,
                            ),
                        ],
                      ),
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

const _stanceHanzi = {
  Stance.mabu: '马步',
  Stance.gongbu: '弓步',
  Stance.xubu: '虚步',
};

class _StanceChip extends StatelessWidget {
  const _StanceChip({
    required this.name,
    required this.hanzi,
    required this.active,
  });

  final String name;
  final String hanzi;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final fg = active ? Palette.onColor : Palette.textDim;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      margin: const EdgeInsets.only(right: 4),
      padding: const EdgeInsets.symmetric(vertical: 4),
      decoration: BoxDecoration(
        color: active ? Palette.lacquer : Palette.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: active ? Palette.gold : Palette.line),
      ),
      child: Column(
        children: [
          Text(
            name,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: fg,
            ),
          ),
          Text(hanzi, style: TextStyle(fontSize: 9, color: fg)),
        ],
      ),
    );
  }
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
