part of '../combat_screen.dart';

// -------------------------------------------------------------------- mano

class _PreviewPanel extends ConsumerWidget {
  const _PreviewPanel({
    required this.view,
    required this.data,
    required this.engine,
  });

  final CombatView view;
  final GameData data;
  final CombatEngine engine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final s = view.state;
    String? banner;
    if (s.phase == CombatPhase.discarding) banner = t.discardHint;
    if (view.retaining) banner = t.retainHint(s.retainMax);
    if (banner != null) {
      return _hint(banner, Palette.gold);
    }
    final uid = view.selected;
    if (uid == null || s.handCard(uid) == null) {
      return const SizedBox(height: 44);
    }
    final c = s.handCard(uid)!;
    final def = data.card(c.cardId);
    final p = engine.preview(s, uid);
    final costOfFresh = engine.costOf(s, def);
    // Abanico: este golpe no entra y te devuelve el suyo.
    final parried =
        p.damage > 0 && s.enemy.parryReady && !s.enemy.staggered;
    final enemyDef = data.enemy(s.enemy.id);
    // Guardia de un solo tipo: un golpe de otro tipo la esquiva.
    final guardNote =
        p.damage > 0 && s.enemy.guard > 0 && s.enemy.guardBlocks != null
        ? (def.type == s.enemy.guardBlocks
              ? t.previewGuardHit
              : t.previewGuardMiss)
        : null;
    // Guardia contra el golpe que viene: a su altura lo cubre entera; a otra
    // altura, solo la mitad. Lo decimos antes de jugarla.
    final incoming = engine.intentView(s);
    final covers = incoming.intent.height == p.height;
    final coverNote =
        p.guard > 0 &&
            !incoming.skipped &&
            incoming.intent.kind == IntentKind.attack &&
            incoming.intent.height != null
        ? (covers && incoming.intent.wear && incoming.intent.hits > 1
              ? t.previewWear(
                  math.min(
                    incoming.intent.hits,
                    (s.player.guard + p.guard) ~/ math.max(1, incoming.damage),
                  ),
                  incoming.intent.hits,
                )
              : covers
              ? t.previewCovers
              : t.previewHalfCover(t.heightLabel(incoming.intent.height!)))
        : null;
    final parts = <String>[
      if (parried)
        t.previewParried(enemyDef.parry)
      else if (p.damage > 0)
        t.previewDamage(p.damage),
      ?guardNote,
      if (p.damage > 0 &&
          !parried &&
          enemyDef.thorns + s.enemy.thorns > 0 &&
          !s.enemy.staggered)
        t.previewThorns(enemyDef.thorns + s.enemy.thorns),
      if (p.structure > 0) t.previewStructure(p.structure),
      if (p.guard > 0) '${t.guard} ${p.guard} ${t.heightLabel(p.height)}',
      if (p.stanceAfter != s.player.stance)
        t.previewThen('→ ${text.stance(p.stanceAfter)}'),
    ];
    String formName(String id) => text.form(id);
    String signed(int v) => v > 0 ? '+$v' : '−${-v}';
    final changes = [
      if (p.stanceDamage != 0) t.stanceDeltaDamage(signed(p.stanceDamage)),
      if (p.stanceStructure != 0)
        t.stanceDeltaStructure(signed(p.stanceStructure)),
      if (p.stanceGuard != 0) t.stanceDeltaGuard(signed(p.stanceGuard)),
      if (p.stanceCost != 0) t.stanceDeltaCost(signed(p.stanceCost)),
    ];
    final stanceNote = changes.isEmpty
        ? null
        : t.stanceDeltaBy(
            changes.join(', '),
            data.stance(s.player.stance).pinyin,
          );
    // Bueno si suma daño/Estructura/guardia o abarata; malo si no.
    final stanceGood =
        p.stanceDamage + p.stanceStructure + p.stanceGuard - p.stanceCost > 0;
    return GestureDetector(
      onTap: () => ref.read(combatControllerProvider.notifier).clearSelection(),
      child: Container(
        height: 44,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text.rich(
                    TextSpan(
                      text: '${text.card(def.id)} · ${def.pinyin}',
                      children: [
                        if (stanceNote != null)
                          TextSpan(
                            text: '  $stanceNote',
                            style: TextStyle(
                              fontSize: 11,
                              color: stanceGood
                                  ? Palette.jade
                                  : Palette.lacquer,
                            ),
                          ),
                        if (p.styleDamage > 0 || p.retained)
                          TextSpan(
                            text:
                                '  ${[if (p.styleDamage > 0) t.styleDeltaDamage(p.styleDamage), if (p.retained && p.cost < costOfFresh) t.retainedCheaper(costOfFresh - p.cost)].join(', ')}',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Palette.jade,
                            ),
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      children: [
                        // El aviso de altura va primero y en color: es lo
                        // que más cuesta leer al defenderse.
                        if (coverNote != null)
                          TextSpan(
                            text: '$coverNote  ',
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: covers ? Palette.jade : Palette.lacquer,
                            ),
                          ),
                        TextSpan(
                          text: [
                      ...parts,
                      for (final f in p.completesForms)
                        t.previewCompletes(formName(f)),
                      for (final f in p.advancesForms)
                        t.previewAdvances(formName(f)),
                      for (final f in p.interruptsForms)
                        t.previewInterrupts(formName(f)),
                    ].join(' · '),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Palette.textDim,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              p.playable
                  ? t.tapAgain
                  : (p.reason == null ? '' : t.invalidLabel(p.reason!)),
              style: TextStyle(
                fontSize: 10,
                color: p.playable ? Palette.gold : Palette.lacquer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _hint(String text, Color color) => Container(
    height: 44,
    alignment: Alignment.center,
    child: Text(text, style: TextStyle(color: color, fontSize: 13)),
  );
}

class _HandArea extends ConsumerStatefulWidget {
  const _HandArea({
    required this.view,
    required this.hand,
    required this.data,
    required this.engine,
    required this.playedUid,
    required this.enemyKey,
    required this.heroKey,
    required this.drawKey,
    required this.discardKey,
  });

  final CombatView view;
  final List<CombatCard> hand;
  final GameData data;
  final CombatEngine engine;

  /// La carta recién jugada vuela hacia su blanco en vez de descartarse.
  final int? playedUid;
  final GlobalKey enemyKey;
  final GlobalKey heroKey;
  final GlobalKey drawKey;
  final GlobalKey discardKey;

  @override
  ConsumerState<_HandArea> createState() => _HandAreaState();
}

/// Carta que sale de la mano: vuela a su blanco o cae al descarte.
class _Leaving {
  _Leaving(
    this.id,
    this.card,
    this.pos,
    this.angle,
    this.width,
    this.target, {
    this.scale = 1,
    this.burn = false,
    this.pile,
  });
  final int id;
  final CombatCard card;
  final Offset pos;
  final double angle;
  final double width;
  final Offset? target;

  /// Escala con la que arranca (la jugada sale agrandada).
  final double scale;

  /// Se agota: se quema en el lugar en vez de ir al descarte.
  final bool burn;

  /// Dónde está el descarte (si se pudo medir): la carta cae ahí.
  final Offset? pile;
}

/// Posición de cada carta en el abanico.
class _Fan {
  _Fan(this.n, double width) {
    final avail = width - 24;
    // Un poco más grandes que lo que entra justo: se solapan apenas y el
    // arte se aprecia mejor.
    w = n == 0
        ? maxW
        : ((avail - 4 * (n - 1)) / n * 1.1).clamp(72.0, maxW);
    step = n <= 1 ? 0.0 : math.min(w + 6, (avail - w) / (n - 1));
    final total = n == 0 ? 0.0 : w + step * (n - 1);
    left0 = (width - total) / 2;
  }

  /// Ancho máximo de una carta en la mano.
  static const maxW = 100.0;

  final int n;
  late final double w;
  late final double step;
  late final double left0;

  double get _mid => (n - 1) / 2;
  double left(int i) => left0 + step * i;
  double angle(int i) => n <= 1 ? 0.0 : (i - _mid) * 0.05;
  double top(int i, bool isSelected) =>
      16 + (isSelected ? -10.0 : (i - _mid).abs() * 3);

  /// Aumento de la carta seleccionada.
  static const zoom = 1.75;

  /// Desde dónde crece la carta [i]: los extremos, hacia adentro.
  double growX(int i) => n <= 1 ? 0.0 : ((i - _mid) / _mid).clamp(-1.0, 1.0);
}

class _HandAreaState extends ConsumerState<_HandArea> {
  Set<int> _known = {};
  final _leaving = <_Leaving>[];
  double _width = 0;
  int _leaveId = 0;
  int? _denyUid;
  int _denyKey = 0;

  @override
  void didUpdateWidget(_HandArea old) {
    super.didUpdateWidget(old);
    _known = {for (final c in old.hand) c.uid};
    final now = {for (final c in widget.hand) c.uid};
    final fan = _Fan(old.hand.length, _width);
    for (final (i, c) in old.hand.indexed) {
      if (now.contains(c.uid)) continue;
      final played = c.uid == widget.playedUid;
      final burn =
          !played && widget.view.state.exhausted.any((e) => e.uid == c.uid);
      _leaving.add(
        _Leaving(
          _leaveId++,
          c,
          // La jugada estaba agrandada desde abajo: se arranca con su mismo
          // centro visual, escalando desde el centro.
          Offset(fan.left(i), fan.top(i, played)) +
              (played
                  ? Offset(-fan.growX(i) * fan.w / 2, -fan.w * 0.75) *
                        (_Fan.zoom - 1)
                  : Offset.zero),
          played ? 0 : fan.angle(i),
          fan.w,
          played ? _targetFor(c, fan.w) : null,
          scale: played ? _Fan.zoom : 1,
          burn: burn,
          pile: played || burn ? null : _centerOf(widget.discardKey, fan.w),
        ),
      );
    }
  }

  /// Centro del enemigo (ataques) o del héroe (defensas), en coordenadas de la mano.
  Offset? _targetFor(CombatCard c, double w) {
    final def = widget.data.card(c.cardId);
    final toHero = !def.type.isAttack && def.damage == 0;
    return _centerOf(toHero ? widget.heroKey : widget.enemyKey, w);
  }

  /// Dónde poner una carta de ancho [w] para que quede centrada sobre [key].
  Offset? _centerOf(GlobalKey key, double w) {
    final target = key.currentContext?.findRenderObject();
    final me = context.findRenderObject();
    if (target is! RenderBox || me is! RenderBox || !target.attached) {
      return null;
    }
    final center = target.localToGlobal(target.size.center(Offset.zero));
    return me.globalToLocal(center) - Offset(w / 2, w * 0.75);
  }

  @override
  Widget build(BuildContext context) {
    final hand = widget.hand;
    final fresh = [
      for (final c in hand)
        if (!_known.contains(c.uid)) c.uid,
    ];
    // Primer reparto del combate: espera a que entre el enemigo.
    final base = _known.isEmpty && _width == 0 ? 450 : 0;
    return LayoutBuilder(
      builder: (context, box) {
        _width = box.maxWidth;
        final fan = _Fan(hand.length, box.maxWidth);
        return SizedBox(
          height: _Fan.maxW * 1.5 + 28, // fija: la arena no salta al cambiar la mano
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // La seleccionada va última para quedar por encima de las demás.
              for (final i in [
                for (var i = 0; i < hand.length; i++)
                  if (hand[i].uid != widget.view.selected) i,
                for (var i = 0; i < hand.length; i++)
                  if (hand[i].uid == widget.view.selected) i,
              ])
                _positioned(
                  context,
                  i,
                  fan,
                  hand[i],
                  fresh.contains(hand[i].uid)
                      ? base + 75 * fresh.indexOf(hand[i].uid)
                      : null,
                ),
              for (final l in _leaving)
                _LeaveCard(
                  key: ValueKey('leave${l.id}'),
                  leaving: l,
                  def: widget.data.card(l.card.cardId),
                  onDone: () => setState(() => _leaving.remove(l)),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _positioned(
    BuildContext context,
    int i,
    _Fan fan,
    CombatCard c,
    int? dealDelay,
  ) {
    final view = widget.view;
    final s = view.state;
    final def = widget.data.card(c.cardId);
    final p = widget.engine.preview(s, c.uid);
    final selected = view.selected == c.uid;
    final advances = p.advancesForms.isNotEmpty || p.completesForms.isNotEmpty;
    final free = view.retaining || s.phase == CombatPhase.discarding;
    final left = fan.left(i);
    return AnimatedPositioned(
      key: ValueKey(c.uid),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      left: left,
      top: fan.top(i, selected),
      child: _DealIn(
        delayMs: dealDelay,
        from: Offset(-left - fan.w, 90),
        pile: widget.drawKey,
        child: Shake(
          trigger: _denyUid == c.uid ? _denyKey : 0,
          strength: 7,
          // Seleccionada crece desde abajo para leerla bien; en los bordes
          // crece hacia adentro para no salirse de la pantalla.
          child: AnimatedScale(
            scale: selected ? _Fan.zoom : 1,
            alignment: Alignment(fan.growX(i), 1),
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutBack,
            child: Transform.rotate(
              angle: selected ? 0 : fan.angle(i),
              child: TutorialAnchor(
                id: 'card:${c.cardId}',
                child: GestureDetector(
                  onTap: () {
                    if (selected && !free && !p.playable) {
                      // Segundo toque sobre una carta que no se puede jugar: "no".
                      Haptics.heavyImpact();
                      ref.read(audioProvider).play(Sfx.cardDeny);
                      setState(() {
                        _denyUid = c.uid;
                        _denyKey++;
                      });
                    } else {
                      Haptics.selectionClick();
                      ref.read(audioProvider).play(Sfx.cardSelect);
                    }
                    ref.read(combatControllerProvider.notifier).tapCard(c.uid);
                  },
                  child: CardWidget(
                    def: def,
                    upgrades: c.upgrades,
                    preview: p,
                    width: fan.w,
                    selected: selected,
                    advancesForm: advances,
                    interruptsForm: p.interruptsForms.isNotEmpty,
                    playable: free || p.playable,
                    marked: view.retain.contains(c.uid),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Un mazo chico en la esquina: el que queda por robar (laca) o el descarte
/// (papel). Muestra cuántas hay y, al tocarlo, cuáles son.
class _Pile extends StatelessWidget {
  const _Pile({super.key, required this.cards, required this.discard});

  final List<CombatCard> cards;
  final bool discard;

  static const w = 26.0;
  static const h = 36.0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final n = cards.length;
    final color = discard ? Palette.textDim : Palette.lacquer;
    return Tooltip(
      message: discard ? t.discardPile(n) : t.drawPile(n),
      child: Press(
        enabled: n > 0,
        child: GestureDetector(
          onTap: n == 0 ? null : () => showDeckSheet(context, cards),
          child: SizedBox(
            width: w + 8,
            height: 44,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (n == 0)
                  Positioned(
                    left: 0,
                    top: 4,
                    child: Container(
                      width: w,
                      height: h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        border: Border.all(
                          color: color.withValues(alpha: 0.35),
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                // Hasta tres dorsos corridos, para que se lea como pila.
                for (var k = math.min(n, 3) - 1; k >= 0; k--)
                  Positioned(
                    left: 2.0 * k,
                    top: 4 - 2.0 * k,
                    child: _CardBack(discard: discard, tilt: discard ? 0.08 * k : 0),
                  ),
                Positioned(
                  right: -2,
                  bottom: -2,
                  child: Bounce(
                    trigger: n,
                    scale: 1.3,
                    child: Container(
                      constraints: const BoxConstraints(minWidth: 18),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.surface,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: color, width: 1.2),
                      ),
                      child: Text(
                        '$n',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: color,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
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

/// Dorso de una carta en miniatura.
class _CardBack extends StatelessWidget {
  const _CardBack({this.discard = false, this.tilt = 0});

  final bool discard;
  final double tilt;

  @override
  Widget build(BuildContext context) => Transform.rotate(
    angle: tilt,
    child: Container(
      width: _Pile.w,
      height: _Pile.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: discard ? Palette.surface : Palette.lacquer,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: discard ? Palette.line : Palette.gold,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.text.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Text(
        '息',
        style: TextStyle(
          fontSize: 13,
          height: 1,
          color: discard ? Palette.textDim : Palette.onColor,
        ),
      ),
    ),
  );
}

/// Al rebarajar, unos dorsos vuelan en arco del descarte (derecha) al mazo
/// (izquierda).
class _Reshuffle extends StatefulWidget {
  const _Reshuffle({required this.trigger});

  final int trigger;

  @override
  State<_Reshuffle> createState() => _ReshuffleState();
}

class _ReshuffleState extends State<_Reshuffle>
    with SingleTickerProviderStateMixin {
  static const _cards = 5;
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
  }

  @override
  void didUpdateWidget(_Reshuffle old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, box) => AnimatedBuilder(
      animation: _c,
      builder: (_, _) {
        if (!_c.isAnimating) return const SizedBox.shrink();
        // Los mismos lugares que los mazos (8 del borde, arriba).
        final from = Offset(box.maxWidth - 8 - _Pile.w - 8, 4);
        const to = Offset(8, 4);
        return Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < _cards; i++)
              Builder(
                builder: (_) {
                  final t = ((_c.value - i * 0.08) / 0.6).clamp(0.0, 1.0);
                  if (t == 0 || t == 1) return const SizedBox.shrink();
                  final k = Curves.easeInOutCubic.transform(t);
                  final p =
                      Offset.lerp(from, to, k)! +
                      Offset(0, -46 * math.sin(math.pi * k));
                  return Positioned(
                    left: p.dx,
                    top: p.dy,
                    child: Transform.rotate(
                      angle: -math.pi * 2 * k * 0.5,
                      child: Opacity(
                        opacity: math.min(1, math.min(t, 1 - t) * 6),
                        child: _CardBack(discard: k < 0.5),
                      ),
                    ),
                  );
                },
              ),
          ],
        );
      },
    ),
  );
}

/// Entrada de una carta repartida: sale del mazo (abajo a la izquierda) y se
/// acomoda con un pequeño rebote. Sin [delayMs] aparece sin animar.
class _DealIn extends StatefulWidget {
  const _DealIn({
    required this.delayMs,
    required this.from,
    required this.child,
    this.pile,
  });

  final int? delayMs;
  final Offset from;
  final Widget child;

  /// El mazo por robar: si se puede medir, la carta sale de ahí (chica) en
  /// vez de entrar desde el borde.
  final GlobalKey? pile;

  @override
  State<_DealIn> createState() => _DealInState();
}

class _DealInState extends State<_DealIn> with SingleTickerProviderStateMixin {
  static const _fly = 380;
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: _fly + (widget.delayMs ?? 0)),
    value: widget.delayMs == null ? 1 : 0,
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  /// Desde el mazo hasta este lugar; se mide al arrancar el vuelo.
  Offset? _fromPile;

  Offset? _measure() {
    final pile = widget.pile?.currentContext?.findRenderObject();
    final me = context.findRenderObject();
    if (pile is! RenderBox || me is! RenderBox || !pile.attached) return null;
    final c = pile.localToGlobal(pile.size.center(Offset.zero));
    return me.globalToLocal(c) - me.size.center(Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    final start = (widget.delayMs ?? 0) / (_fly + (widget.delayMs ?? 0));
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        if (_c.value >= 1) return child!;
        final raw = _c.value <= start ? 0.0 : (_c.value - start) / (1 - start);
        // Se mide recién cuando sale: el mazo ya está en pantalla.
        if (raw > 0) _fromPile ??= _measure();
        final v = Curves.easeOutBack.transform(raw);
        final from = _fromPile;
        return Opacity(
          opacity: math.min(1, raw * (from == null ? 3 : 6)),
          child: Transform.translate(
            offset: (from ?? widget.from) * (1 - v),
            child: Transform.rotate(
              angle: -0.5 * (1 - v),
              child: Transform.scale(
                scale: from == null ? 1 : 0.35 + 0.65 * v,
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

class _LeaveCard extends StatefulWidget {
  const _LeaveCard({
    super.key,
    required this.leaving,
    required this.def,
    required this.onDone,
  });

  final _Leaving leaving;
  final CardDef def;
  final VoidCallback onDone;

  @override
  State<_LeaveCard> createState() => _LeaveCardState();
}

class _LeaveCardState extends State<_LeaveCard>
    with SingleTickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: Duration(
            milliseconds: widget.leaving.target != null
                ? 260
                : widget.leaving.burn
                ? 520
                : 380,
          ),
        )
        ..addStatusListener((s) {
          if (s == AnimationStatus.completed) widget.onDone();
        })
        ..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = widget.leaving;
    final color = typeColor(widget.def.type);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final Offset pos;
        final double angle, scale, opacity;
        if (l.target != null) {
          final k = Curves.easeInCubic.transform(t);
          pos = Offset.lerp(l.pos, l.target!, k)!;
          angle = l.angle + 0.6 * k;
          scale = l.scale - (l.scale - 0.45) * k;
          opacity = t < 0.8 ? 1 : (1 - t) / 0.2;
        } else if (l.burn) {
          // Agotada: sube un poco y se deshace.
          final k = Curves.easeOut.transform(t);
          pos = l.pos + Offset(0, -40 * k);
          angle = l.angle;
          scale = l.scale + 0.1 * k;
          opacity = 1 - Curves.easeIn.transform(t);
        } else if (l.pile != null) {
          // Al descarte: un arco corto hasta la esquina, achicándose.
          final k = Curves.easeInOutCubic.transform(t);
          pos =
              Offset.lerp(l.pos, l.pile!, k)! +
              Offset(0, -40 * math.sin(math.pi * k));
          angle = l.angle + 0.9 * k;
          scale = l.scale - (l.scale - 0.32) * k;
          opacity = t < 0.85 ? 1 : (1 - t) / 0.15;
        } else {
          final k = Curves.easeIn.transform(t);
          pos = l.pos + Offset(50 * k, 150 * k);
          angle = l.angle + 0.5 * k;
          scale = l.scale - (l.scale - 0.8) * k;
          opacity = 1 - k;
        }
        return Positioned(
          left: pos.dx,
          top: pos.dy,
          child: IgnorePointer(
            child: Opacity(
              opacity: opacity.clamp(0, 1),
              child: Transform.rotate(
                angle: angle,
                child: Transform.scale(scale: scale, child: child),
              ),
            ),
          ),
        );
      },
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          boxShadow: l.target == null
              ? const []
              : [
                  BoxShadow(
                    color: color.withValues(alpha: 0.7),
                    blurRadius: 22,
                    spreadRadius: 2,
                  ),
                ],
        ),
        child: l.burn
            ? AnimatedBuilder(
                animation: _c,
                builder: (_, child) => ColorFiltered(
                  colorFilter: ColorFilter.mode(
                    Palette.lacquer.withValues(alpha: 0.6 * _c.value),
                    BlendMode.srcATop,
                  ),
                  child: child,
                ),
                child: CardWidget(
                  def: widget.def,
                  upgrades: l.card.upgrades,
                  width: l.width,
                ),
              )
            : CardWidget(
                def: widget.def,
                upgrades: l.card.upgrades,
                width: l.width,
              ),
      ),
    );
  }
}
