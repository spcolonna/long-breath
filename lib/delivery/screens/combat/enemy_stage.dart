part of '../combat_screen.dart';

class _EnemyStage extends ConsumerWidget {
  const _EnemyStage({required this.slot, required this.fx});

  final _EnemySlot slot;
  final _ArenaFx fx;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final e = slot.enemy;
    final def = slot.def;
    final foe = slot.foe;
    final accent = rankColor(def.rank);
    // La guía del tutorial señala al primero (nunca hay dos en las lecciones).
    Widget anchor(String id, Widget child) =>
        slot.index == 0 ? TutorialAnchor(id: id, child: child) : child;
    final aimed = slot.pair && slot.targeted && !foe.dying;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: slot.pair ? slot.onTap : null,
      // El globo de intención va en su propia capa, detrás del enemigo; en
      // la columna queda un hueco invisible del mismo tamaño y el enemigo se
      // apoya abajo con aire arriba, así en reposo no se tocan.
      child: Stack(
      children: [
      Column(
      children: [
        // Con dos, los globos bajan un poco: arriba a la derecha está la pausa.
        SizedBox(height: slot.pair ? 46 : 16),
        IgnorePointer(
          child: Visibility(
            visible: false,
            maintainSize: true,
            maintainAnimation: true,
            maintainState: true,
            child: foe.dying
                ? const SizedBox(height: 50)
                : _IntentBubble(iv: slot.intent, compact: slot.pair),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              // Apoyado abajo y con aire arriba: la cabeza no llega al
              // globo de intención.
              // Con poco alto el enemigo no baja de un mínimo: crece hacia
              // arriba, debajo del globo.
              final fit = math.min(
                math.min(box.maxHeight - 16, slot.pair ? 220.0 : 260.0),
                box.maxWidth * 1.15,
              );
              // Sin pasarse más de 24 px: la cabeza no se esconde
              // entera bajo el globo.
              final size = math.min(
                math.max(
                  fit,
                  math.min(slot.pair ? 112.0 : 150.0, box.maxWidth * 1.1),
                ),
                box.maxHeight + 24,
              );
              return OverflowBox(
                alignment: Alignment.bottomCenter,
                minHeight: 0,
                maxHeight: math.max(box.maxHeight, size + 16),
                child: Stack(
                alignment: Alignment.bottomCenter,
                clipBehavior: Clip.none,
                children: [
                  // A quién apuntás: un halo de oro a sus pies.
                  if (slot.pair)
                    Positioned(
                      bottom: -4,
                      child: _TargetHalo(on: aimed, width: size * 0.8),
                    ),
                  _Entrance(
                    // El que entra en un grupo también cae desde arriba.
                    key: ValueKey(slot.wave),
                    child: EnemySprite(
                      key: foe.key,
                      def: def,
                      staggered: e.staggered,
                      hitKey: foe.hit,
                      attackKey: foe.attack,
                      pulseKey: foe.pulse,
                      heavyHit: foe.heavy,
                      dying: foe.dying,
                      size: size,
                    ),
                  ),
                  // Tinta de cada golpe, escudo al cubrirse, porcelana rota al
                  // desequilibrarlo y pétalos al vencerlo.
                  Positioned.fill(
                    child: ArtBurst(
                      trigger: foe.spark,
                      asset: 'assets/art/vfx/hit_ink.webp',
                      size: size * (foe.heavy ? 0.95 : 0.7),
                      duration: const Duration(milliseconds: 420),
                      from: 0.5,
                      to: 1.15,
                      spin: 0.6,
                      hold: 0.2,
                    ),
                  ),
                  Positioned.fill(
                    child: ArtBurst(
                      trigger: foe.guard,
                      asset: 'assets/art/vfx/guard_shield.webp',
                      size: size * 0.85,
                      duration: const Duration(milliseconds: 800),
                      from: 0.7,
                      to: 1.05,
                      spin: 0,
                      hold: 0.55,
                    ),
                  ),
                  Positioned.fill(
                    child: ArtBurst(
                      trigger: foe.brk,
                      asset: 'assets/art/vfx/break_shatter.webp',
                      size: size * 1.1,
                      duration: const Duration(milliseconds: 700),
                      from: 0.6,
                      to: 1.35,
                      spin: 0.25,
                      hold: 0.25,
                    ),
                  ),
                  Positioned.fill(
                    child: ArtBurst(
                      trigger: foe.burst,
                      asset: 'assets/art/vfx/lotus_petals.webp',
                      size: size * 1.2,
                      duration: const Duration(milliseconds: 1400),
                      from: 0.4,
                      to: 1.4,
                      spin: 0.5,
                      hold: 0.45,
                    ),
                  ),
                  // Chispas de cada golpe y estallido final.
                  Positioned.fill(
                    child: InkBurst(
                      trigger: foe.spark,
                      colors: [Colors.white, Palette.gold, accent],
                      count: 12,
                      radius: size * 0.45,
                      duration: const Duration(milliseconds: 420),
                    ),
                  ),
                  Positioned.fill(
                    child: InkBurst(
                      trigger: foe.burst,
                      colors: [
                        accent,
                        Palette.gold,
                        Palette.lacquer,
                        Colors.white,
                      ],
                      count: 40,
                      radius: size * 0.9,
                      duration: const Duration(milliseconds: 1100),
                    ),
                  ),
                  Positioned(
                    top: size * 0.3,
                    child: IgnorePointer(child: _PopStack(pops: foe.pops)),
                  ),
                ],
              ),
              );
            },
          ),
        ),
        // Con dos en escena, el caído se apaga y deja su lugar vacío.
        AnimatedOpacity(
          opacity: slot.pair && foe.dying ? 0 : 1,
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOut,
          child: anchor(
          'enemyInfo',
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Placa de nombre: muestra su regla (con dos en escena, el
              // primer toque lo apunta).
              GestureDetector(
                onTap: slot.pair && !slot.targeted
                    ? slot.onTap
                    : () => _showFoeScroll(
                        context,
                        ref,
                        def,
                        e,
                        foe.dying ? null : slot.intent,
                      ),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: aimed ? Palette.gold : accent,
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (aimed ? Palette.gold : accent).withValues(
                          alpha: aimed ? 0.7 : 0.4,
                        ),
                        blurRadius: aimed ? 12 : 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        // Con dos en escena el nombre se achica para entrar
                        // entero.
                        child: Builder(
                          builder: (_) {
                            final name = Text(
                              ref.foe(context, def.id),
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Palette.onColor,
                              ),
                            );
                            return slot.pair
                                ? FittedBox(fit: BoxFit.scaleDown, child: name)
                                : name;
                          },
                        ),
                      ),
                      if (def.rank != EnemyRank.common)
                        Padding(
                          padding: const EdgeInsets.only(left: 6),
                          child: Text(
                            def.rank == EnemyRank.elite
                                ? t.rankElite
                                : t.rankBoss,
                            style: const TextStyle(
                              fontSize: 11,
                              color: Palette.onColor,
                            ),
                          ),
                        ),
                      const SizedBox(width: 4),
                      anchor(
                        'enemyRule',
                        const Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Palette.onColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (slot.waveCount > 1)
                _WavePips(
                  index: slot.wave,
                  total: slot.waveCount,
                  reserve: slot.reserve,
                ),
              const SizedBox(height: 6),
              _MiniBar(
                value: e.hp,
                max: e.maxHp,
                color: Palette.lacquer,
                icon: Icons.favorite,
              ),
              const SizedBox(height: 3),
              _MiniBar(
                value: e.structure,
                max: e.maxStructure,
                color: e.staggered ? Palette.textDim : Palette.structure,
                icon: Icons.hexagon_outlined,
                height: 8,
              ),
            ],
          ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: _hasChips(e, def)
              ? Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    children: [
                      if (e.guard > 0)
                        Bounce(
                          trigger: e.guard,
                          child: _Chip(
                            icon: Icons.shield,
                            text: e.guardBlocks == null
                                ? '${t.guard} ${e.guard}'
                                : t.guardOnlyChip(
                                    e.guard,
                                    t.typeLabel(e.guardBlocks!),
                                  ),
                            color: Palette.sky,
                          ),
                        ),
                      if (def.thorns + e.thorns > 0 && !e.staggered)
                        _Chip(
                          icon: Icons.grass,
                          text: t.thornsChip(def.thorns + e.thorns),
                          color: Palette.lacquer,
                        ),
                      if (def.regen > 0 && e.hp < e.maxHp)
                        _Chip(
                          icon: Icons.favorite_border,
                          text: t.regenChip(def.regen),
                          color: Palette.jade,
                        ),
                      if (e.staggered)
                        _Chip(
                          icon: Icons.blur_on,
                          text: t.staggeredDouble,
                          color: Palette.gold,
                        ),
                      // Escamas: se ignoran mientras está Desequilibrado.
                      if (e.scales > 0 && !e.staggered)
                        GestureDetector(
                          onTap: () => _showFoeScroll(
                            context,
                            ref,
                            def,
                            e,
                            foe.dying ? null : slot.intent,
                          ),
                          child: Bounce(
                            trigger: e.scales,
                            child: _Chip(
                              icon: Icons.texture,
                              text: t.scales(e.scales),
                              color: Palette.jade,
                            ),
                          ),
                        ),
                      if (e.wrath > 0)
                        Bounce(
                          trigger: e.wrath,
                          child: _Chip(
                            icon: Icons.local_fire_department,
                            text: t.wrathChip(e.wrath),
                            color: Palette.lacquer,
                          ),
                        ),
                      if (e.parryReady && !e.staggered)
                        _Chip(
                          icon: Icons.filter_tilt_shift,
                          text: t.parryChip,
                          color: Palette.structure,
                        ),
                      if (e.stolen > 0)
                        Bounce(
                          trigger: e.stolen,
                          child: _Chip(
                            icon: Icons.savings_outlined,
                            text: t.stolenChip(e.stolen),
                            color: Palette.gold,
                          ),
                        ),
                    ],
                  ),
                )
              // Con dos, el lugar de los estados se guarda igual: así las
              // dos placas quedan a la misma altura.
              : SizedBox(
                  width: double.infinity,
                  height: slot.pair && slot.anyChips ? 27 : 0,
                ),
        ),
      ],
      ),
      // El globo va adelante: si falta lugar, tapa apenas la cabeza en vez
      // de achicar al enemigo.
      Positioned(
        top: slot.pair ? 46 : 16,
        left: 0,
        right: 0,
        child: Center(
          child: anchor(
              'intent',
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 280),
                switchInCurve: Curves.easeOutBack,
                transitionBuilder: (child, a) => ScaleTransition(
                  scale: a,
                  child: FadeTransition(opacity: a, child: child),
                ),
                child: foe.dying
                    ? const SizedBox(key: ValueKey('none'), height: 50)
                    : GestureDetector(
                        key: ValueKey('${e.id}-${e.patternIndex}-${e.phaseIndex}'),
                        onTap: slot.pair && !slot.targeted
                            ? slot.onTap
                            : () => _showFoeScroll(
                                context,
                                ref,
                                def,
                                e,
                                slot.intent,
                              ),
                        child: _IntentBubble(
                          iv: slot.intent,
                          compact: slot.pair,
                        ),
                      ),
              ),
            ),
        ),
      ),
      ],
      ),
    );
  }
}

/// Halo de oro a los pies del enemigo al que apuntás (solo con dos en
/// escena): aparece con un rebote y late despacio.
class _TargetHalo extends StatefulWidget {
  const _TargetHalo({required this.on, required this.width});

  final bool on;
  final double width;

  @override
  State<_TargetHalo> createState() => _TargetHaloState();
}

class _TargetHaloState extends State<_TargetHalo>
    with SingleTickerProviderStateMixin {
  late final AnimationController _beat;

  @override
  void initState() {
    super.initState();
    _beat = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (widget.on) _beat.repeat(reverse: true);
  }

  // Late solo mientras está encendido: apagado no anima nada.
  @override
  void didUpdateWidget(_TargetHalo old) {
    super.didUpdateWidget(old);
    if (widget.on && !_beat.isAnimating) _beat.repeat(reverse: true);
    if (!widget.on && _beat.isAnimating) _beat.stop();
  }

  @override
  void dispose() {
    _beat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: TweenAnimationBuilder<double>(
        tween: Tween(end: widget.on ? 1 : 0),
        duration: const Duration(milliseconds: 320),
        curve: widget.on ? Curves.easeOutBack : Curves.easeIn,
        builder: (_, v, _) => v <= 0.01
            ? SizedBox(width: widget.width)
            : AnimatedBuilder(
                animation: _beat,
                builder: (_, _) {
                  final b = Curves.easeInOut.transform(_beat.value);
                  return Opacity(
                    opacity: v.clamp(0, 1),
                    child: Transform.scale(
                      scale: v * (0.94 + 0.06 * b),
                      child: Container(
                        width: widget.width,
                        height: widget.width * 0.2,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                            Radius.elliptical(
                              widget.width / 2,
                              widget.width * 0.1,
                            ),
                          ),
                          border: Border.all(
                            color: Palette.gold.withValues(
                              alpha: 0.75 + 0.25 * b,
                            ),
                            width: 2.4,
                          ),
                          gradient: RadialGradient(
                            colors: [
                              Palette.gold.withValues(alpha: 0.35 + 0.15 * b),
                              Palette.gold.withValues(alpha: 0),
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Palette.gold.withValues(alpha: 0.5 * b),
                              blurRadius: 14,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

/// Grupo de enemigos: uno por punto; los caídos, tachados en tinta.
class _WavePips extends StatelessWidget {
  const _WavePips({
    required this.index,
    required this.total,
    this.reserve = const [],
  });

  final int index;
  final int total;

  /// Los que vienen después, en miniatura: así se planifica sabiendo quién
  /// entra cuando cae este.
  final List<EnemyDef> reserve;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            t.waveOf(index + 1, total),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Palette.lacquer,
            ),
          ),
          const SizedBox(width: 4),
          for (var i = 0; i < total; i++)
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: i == index ? 18 : 8,
              height: 8,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                color: i < index
                    ? Palette.textDim.withValues(alpha: 0.35)
                    : i == index
                    ? Palette.lacquer
                    : Palette.lacquer.withValues(alpha: 0.3),
              ),
            ),
          if (reserve.isNotEmpty) ...[
            const SizedBox(width: 6),
            Text(
              t.waveNext,
              style: const TextStyle(fontSize: 10.5, color: Palette.textDim),
            ),
            for (final d in reserve)
              Container(
                margin: const EdgeInsets.only(left: 3),
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.surface,
                  border: Border.all(
                    color: rankColor(d.rank).withValues(alpha: 0.7),
                    width: 1.5,
                  ),
                ),
                child: ClipOval(
                  child: Image.asset(
                    'assets/art/enemies/${d.art}.webp',
                    fit: BoxFit.cover,
                    alignment: const Alignment(0, -0.6),
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.person,
                      size: 16,
                      color: Palette.textDim,
                    ),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Entrada del enemigo al empezar el combate: cae desde arriba y se asienta.
class _Entrance extends StatefulWidget {
  const _Entrance({super.key, required this.child});

  final Widget child;

  @override
  State<_Entrance> createState() => _EntranceState();
}

class _EntranceState extends State<_Entrance>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final v = Curves.easeOutBack.transform(_c.value);
        return Opacity(
          opacity: math.min(1, _c.value * 2.5),
          child: Transform.translate(
            offset: Offset(0, -50 * (1 - v)),
            child: Transform.scale(scale: 0.8 + 0.2 * v, child: child),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Barra compacta con ícono y número (enemigo).
class _MiniBar extends StatelessWidget {
  const _MiniBar({
    required this.value,
    required this.max,
    required this.color,
    required this.icon,
    this.height = 12,
  });

  final int value;
  final int max;
  final Color color;
  final IconData icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    final ratio = max == 0 ? 0.0 : (value / max).clamp(0.0, 1.0);
    return Row(
      children: [
        GameIcon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: TrailBar(
            ratio: ratio,
            color: color,
            height: height,
            background: Palette.surface.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(width: 4),
        // Pastilla clara: el número se lee sobre cualquier fondo.
        Container(
          constraints: const BoxConstraints(minWidth: 50),
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: Palette.surface.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            '$value/$max',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

/// El rival muestra fichas de estado (Guardia, espinas, escamas…).
bool _hasChips(EnemyCombat e, EnemyDef def) =>
    e.guard > 0 ||
    e.staggered ||
    e.scales > 0 ||
    e.wrath > 0 ||
    e.parryReady ||
    e.stolen > 0 ||
    def.thorns + e.thorns > 0 ||
    def.regen > 0;

/// Ícono, nombre y números de lo que prepara el rival.
(IconData, String, String) _intentSummary(
  AppLocalizations t,
  ContentText text,
  IntentView iv,
) {
  final i = iv.intent;
  final named = i.labelKey == null ? null : text.intent(i.labelKey!);
  return switch (i.kind) {
      IntentKind.attack => (
        heightIcon(i.height),
        named == null
            ? t.intentAttack(t.heightLabel(i.height))
            : t.intentNamedAttack(named, t.heightLabel(i.height)),
        '${iv.damage}${i.hits > 1 ? '×${i.hits}' : ''} · E ${iv.structure}',
      ),
      IntentKind.guard => (
        Icons.shield,
        named ?? t.guard,
        iv.guardBlocks == null
            ? '${t.guard} ${i.value}'
            : t.guardOnly(t.typeLabel(iv.guardBlocks!), i.value),
      ),
      IntentKind.charge => (
        Icons.bolt,
        named ?? t.intentCharge,
        t.intentChargeDetail(i.value),
      ),
      IntentKind.discard => (
        Icons.graphic_eq,
        named ?? t.intentDiscard,
        t.intentDiscardDetail(i.count),
      ),
      IntentKind.flee => (
        Icons.directions_run,
        named ?? t.intentFlee,
        t.intentFleeDetail(iv.stolen),
      ),
  };
}

/// Las reglas extra del golpe: en corto para el globo y enteras para el
/// pergamino del rival.
List<(String, String)> _intentExtras(AppLocalizations t, IntentView iv) {
  final i = iv.intent;
  final attack = i.kind == IntentKind.attack;
  return [
    if (i.interrupt) (t.intentTagInterrupt, t.intentInterrupt),
    if (i.drain > 0 && attack) (t.intentTagDrain(i.drain), t.intentDrain(i.drain)),
    if (i.freeze > 0 && attack)
      (t.intentTagFreeze(i.freeze), t.intentFreeze(i.freeze)),
    if (i.wear && i.hits > 1 && attack) (t.intentTagWear, t.intentWear),
    if (iv.punishIfSameStance) (t.intentTagSameStance, t.intentSameStance),
  ];
}

/// Abre el pergamino con todo lo del rival.
void _showFoeScroll(
  BuildContext context,
  WidgetRef ref,
  EnemyDef def,
  EnemyCombat e,
  IntentView? iv,
) {
  final t = AppLocalizations.of(context);
  final text = ref.read(textProvider);
  ref.read(audioProvider).play(Sfx.scrollOpen);
  final summary = iv == null ? null : _intentSummary(t, text, iv);
  showEnemyScroll(
    context,
    EnemyScrollInfo(
      def: def,
      name: ref.foe(context, def.id),
      rule: text.enemyRule(def.id),
      hp: e.hp,
      maxHp: e.maxHp,
      structure: e.structure,
      maxStructure: e.maxStructure,
      scales: e.scales,
      quote: text.enemyLine(def.id, 'intro'),
      intentIcon: summary?.$1,
      intentTitle: summary?.$2,
      intentDetail: iv == null
          ? null
          : (iv.skipped ? t.losesAction : summary!.$3),
      intentNotes: iv == null ? const [] : [for (final x in _intentExtras(t, iv)) x.$2],
    ),
  );
}

/// Globo de intención sobre la cabeza del enemigo.
class _IntentBubble extends ConsumerWidget {
  const _IntentBubble({required this.iv, this.compact = false});

  final IntentView iv;

  /// Con dos en escena el globo es más angosto: letra más chica y el nombre
  /// en hasta dos renglones.
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final (IconData icon, String title, String detail) =
        _intentSummary(t, text, iv);
    final extras = _intentExtras(t, iv);
    final color = iv.skipped ? Palette.textDim : Palette.lacquer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: iv.skipped ? Palette.gold : color,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x22000000),
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 28 : 34,
                height: compact ? 28 : 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: GameIcon(
                  icon,
                  size: compact ? 18 : 22,
                  color: Palette.onColor,
                ),
              ),
              SizedBox(width: compact ? 6 : 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontSize: compact ? 13 : 14.5,
                        height: compact ? 1.15 : null,
                        fontWeight: FontWeight.w700,
                        decoration: iv.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Flexible(
                          child: Text(
                            iv.skipped ? t.losesAction : detail,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: iv.skipped ? Palette.gold : Palette.lacquer,
                            ),
                          ),
                        ),
                        // Con dos en escena, las reglas extra se cuentan:
                        // el detalle está en el pergamino (tocá el globo).
                        if (compact && extras.isNotEmpty && !iv.skipped)
                          Container(
                            margin: const EdgeInsets.only(left: 4),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 5,
                              vertical: 0.5,
                            ),
                            decoration: BoxDecoration(
                              color: Palette.gold,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '+${extras.length}',
                              style: const TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: Palette.onColor,
                              ),
                            ),
                          ),
                      ],
                    ),
                    // Las reglas extra, en chips cortos de un renglón: el
                    // detalle entero está en el pergamino del rival.
                    if (extras.isNotEmpty && !compact)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Wrap(
                          spacing: 3,
                          runSpacing: 2,
                          children: [
                            for (final x in extras)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5,
                                  vertical: 1,
                                ),
                                decoration: BoxDecoration(
                                  color: Palette.lacquer.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  x.$1,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    height: 1.2,
                                    fontWeight: FontWeight.w700,
                                    color: Palette.text,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (iv.countdown != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text(
                      '${iv.countdown}',
                      style: const TextStyle(
                        fontSize: 20, fontFamily: Fonts.display,
                        color: Palette.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      t.countdown,
                      style: const TextStyle(fontSize: 9, color: Palette.gold),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Cola del globo.
        CustomPaint(
          size: const Size(16, 8),
          painter: _TailPainter(iv.skipped ? Palette.gold : color),
        ),
      ],
    );
  }
}

class _TailPainter extends CustomPainter {
  _TailPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawPath(
      Path()
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width / 2, size.height)
        ..close(),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}
