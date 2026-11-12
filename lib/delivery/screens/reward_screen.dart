import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/game_balance.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/paper_panel.dart';
import '../widgets/card_widget.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/form_scroll.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/lotus.dart';
import 'home_screen.dart';
import 'talisman_screen.dart';
import '../widgets/weapon_widgets.dart';
import '../feel.dart';
import '../widgets/press.dart';

/// El botín de un combate ganado: un cofre sellado que se abre y revela qué
/// trae (cartas, jade, loto, temple, té o talismán). El tipo es sorpresa.
class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> {
  /// Contadores del arriba: adonde vuelan las monedas y las semillas.
  final _jadeKey = GlobalKey();
  final _lotusKey = GlobalKey();
  final _stackKey = GlobalKey();

  /// El premio tal como se abrió (al cobrarlo, la run ya pasa al mapa).
  late final RunState _run = ref.read(runControllerProvider)!;
  bool _open = false;

  /// La página suelta que trajo el cofre (se lee antes del botín).
  late final String? _page = switch (_run.threadLine) {
    final id? when id.startsWith('page_') => id,
    _ => null,
  };
  bool _paged = false;

  /// El cofre ya se está abriendo (tapa, luz y chispas) antes del premio.
  bool _opening = false;
  int _flash = 0;
  final _timers = <Timer>[];

  void _after(int ms, VoidCallback f) => _timers.add(
    Timer(Duration(milliseconds: ms), () => mounted ? f() : null),
  );

  @override
  void initState() {
    super.initState();
    // Se abre solo si no se toca: no hay que esperar a nadie.
    _after(1300, _reveal);
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  /// Primero se abre el cofre (se agacha, salta y suelta la luz) y recién
  /// después aparece lo que trae.
  void _reveal() {
    if (!mounted || _open || _opening) return;
    Haptics.mediumImpact();
    final audio = ref.read(audioProvider);
    audio.play(Sfx.rewardFlip);
    setState(() => _opening = true);
    _after(_ChestState.openMs - 120, () {
      Haptics.heavyImpact();
      audio.play(Sfx.victoryStamp);
      setState(() {
        _open = true;
        _flash++;
      });
    });
  }

  void _leave() {
    if (!mounted) return;
    context.go(routeFor(ref.read(runControllerProvider)!));
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final live = ref.watch(runControllerProvider);
    if (live == null) return const SizedBox();
    final kind = _run.rewardKind;
    final (_, color) = lootLook(kind);
    return Scaffold(
      body: Stack(
        key: _stackKey,
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _Header(
                    jade: live.jade,
                    lotus: live.lotus,
                    jadeKey: _jadeKey,
                    lotusKey: _lotusKey,
                  ),
                  const SizedBox(height: 8),
                  _Spoils(jade: _run.jadeGained, lotus: _run.lotusGained),
                  // La sala de pelea paga con su cofre (el premio que
                  // mostraba la puerta).
                  if (_run.currentNode case final id?
                      when _run.node(id).reward != null) ...[
                    const SizedBox(height: 6),
                    Text(
                      t.chestTitle,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Palette.text,
                      ),
                    ),
                  ],
                  if (_run.ghost case final g?
                      when g.claimedAt == _run.currentNode && g.dropped != null)
                    _Keepsake(n: g.n, card: g.dropped!, upgrades: g.upgrades),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 380),
                      switchInCurve: Curves.easeOutBack,
                      transitionBuilder: (child, a) => FadeTransition(
                        opacity: a,
                        child: ScaleTransition(
                          scale: Tween(begin: 0.92, end: 1.0).animate(a),
                          child: child,
                        ),
                      ),
                      child: !_open
                          ? _Chest(
                              key: const ValueKey('chest'),
                              onOpen: _reveal,
                              opening: _opening,
                              color: color,
                            )
                          : _page != null && !_paged
                          ? KeyedSubtree(
                              key: const ValueKey('page'),
                              child: _PageFound(
                                id: _page,
                                onDone: () => setState(() => _paged = true),
                              ),
                            )
                          : KeyedSubtree(
                              key: const ValueKey('open'),
                              child: _contents(t, kind),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          IgnorePointer(
            child: ScreenFlash(trigger: _flash, color: color),
          ),
        ],
      ),
    );
  }

  Widget _contents(AppLocalizations t, RewardKind kind) {
    final stamp = _KindStamp(kind: kind);
    return switch (kind) {
      RewardKind.cards => _CardsLoot(stamp: stamp, onDone: _leave),
      RewardKind.jade || RewardKind.lotus => _CoinsLoot(
        stamp: stamp,
        kind: kind,
        amount: _run.rewardAmount,
        target: kind == RewardKind.jade ? _jadeKey : _lotusKey,
        stackKey: _stackKey,
        onDone: _leave,
      ),
      RewardKind.tea => _TeaLoot(
        stamp: stamp,
        hp: _run.hp,
        maxHp: _run.maxHp,
        heal: ref.read(runEngineProvider).teaHealOf(_run),
        onDone: _leave,
      ),
      RewardKind.upgrade => _UpgradeLoot(
        stamp: stamp,
        amount: _run.rewardAmount,
        onDone: _leave,
      ),
      RewardKind.talisman => TalismanChoice(
        top: stamp,
        title: t.lootKindTalisman,
        hint: t.lootHintTalisman,
        options: _run.talismanOptions,
        onChosen: (id) {
          ref.read(runControllerProvider.notifier).chooseRewardTalisman(id);
          _leave();
        },
      ),
      RewardKind.weapon => WeaponChoice(
        top: stamp,
        options: _run.weaponOptions,
        onChosen: (id) {
          ref.read(runControllerProvider.notifier).chooseRewardWeapon(id);
          _leave();
        },
      ),
    };
  }
}

/// Una página suelta entre el botín: se lee ahí mismo y queda en el
/// registro.
class _PageFound extends StatelessWidget {
  const _PageFound({required this.id, required this.onDone});

  final String id;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            StaggerIn(
              index: 0,
              child: Text(
                t.chestPage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Palette.text,
                ),
              ),
            ),
            const SizedBox(height: 12),
            StaggerIn(
              index: 1,
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 700),
                curve: Curves.easeOutCubic,
                builder: (_, v, _) => LoreScroll(id: id, fresh: true, open: v),
              ),
            ),
            const SizedBox(height: 16),
            StaggerIn(
              index: 3,
              child: Press(
                child: FilledButton(
                  onPressed: onDone,
                  child: Text(t.chestPageGo),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Título del botín y lo que lleva la run (jade y loto).
class _Header extends StatelessWidget {
  const _Header({
    required this.jade,
    required this.lotus,
    required this.jadeKey,
    required this.lotusKey,
  });

  final int jade;
  final int lotus;
  final GlobalKey jadeKey;
  final GlobalKey lotusKey;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Row(
      children: [
        Text(
          t.lootTitle,
          style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
        ),
        const Spacer(),
        KeyedSubtree(
          key: jadeKey,
          child: JadeCount(jade: jade, size: 22),
        ),
        const SizedBox(width: 14),
        KeyedSubtree(
          key: lotusKey,
          child: LotusCount(lotus: lotus, size: 22),
        ),
      ],
    );
  }
}

/// Lo que dejó el combate en sí (jade y loto), antes del cofre.
class _Spoils extends StatelessWidget {
  const _Spoils({required this.jade, required this.lotus});

  final int jade;
  final int lotus;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget chip(int i, Widget icon, String label, Color color) =>
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(milliseconds: 520 + 160 * i),
          curve: Interval(0.3 * i, 1, curve: Curves.elasticOut),
          builder: (_, v, child) => Transform.scale(scale: v, child: child),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                icon,
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontWeight: FontWeight.w800, color: color),
                  ),
                ),
              ],
            ),
          ),
        );
    return Wrap(
      spacing: 8,
      runSpacing: 6,
      alignment: WrapAlignment.center,
      children: [
        if (jade != 0)
          chip(
            0,
            const JadeCoin(),
            jade > 0 ? t.jadeGained(jade) : t.jadeLost(-jade),
            jade > 0 ? Palette.jade : Palette.gold,
          ),
        if (lotus > 0)
          chip(1, const LotusSeed(), t.lotusGained(lotus), Palette.blossom),
      ],
    );
  }
}

/// Lo que dejó el Discípulo Perdido: la carta del caído cuya cinta
/// llevaba. Ya está en el mazo; acá solo se muestra.
class _Keepsake extends ConsumerWidget {
  const _Keepsake({
    required this.n,
    required this.card,
    required this.upgrades,
  });

  final int n;
  final String card;
  final int upgrades;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: const Interval(0.35, 1, curve: Curves.easeOutBack),
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, 14 * (1 - v)), child: child),
      ),
      child: Container(
        margin: const EdgeInsets.only(top: 8),
        padding: const EdgeInsets.fromLTRB(8, 6, 14, 6),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Palette.blossom.withValues(alpha: 0.55)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const InkSeal(hanzi: '遗', color: Palette.blossom, size: 34),
            const SizedBox(width: 10),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    t.ghostDrop(n),
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                  Text.rich(
                    TextSpan(
                      text: text.card(card),
                      children: [
                        if (upgrades > 0)
                          TextSpan(
                            text: ' +$upgrades',
                            style: const TextStyle(color: Palette.gold),
                          ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Palette.text,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// El cofre de laca sellado: respira, tiembla y se abre al tocarlo.
class _Chest extends StatefulWidget {
  const _Chest({
    super.key,
    required this.onOpen,
    this.opening = false,
    this.color = Palette.gold,
  });

  final VoidCallback onOpen;

  /// Se está abriendo: se agacha, salta y suelta rayos y chispas.
  final bool opening;

  /// Color de la luz (el del tipo de premio).
  final Color color;

  @override
  State<_Chest> createState() => _ChestState();
}

class _ChestState extends State<_Chest> with TickerProviderStateMixin {
  /// Cuánto dura la apertura antes de mostrar el premio.
  static const openMs = 820;

  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1300),
  )..forward();
  late final _o = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: openMs),
  );

  @override
  void didUpdateWidget(_Chest old) {
    super.didUpdateWidget(old);
    if (widget.opening && !old.opening) _o.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    _o.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Press(child: GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onOpen,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedBuilder(
            animation: Listenable.merge([_c, _o]),
            builder: (_, child) {
              final v = _c.value;
              final o = _o.value;
              // Cae, se asienta y tiembla cada vez más antes de abrirse.
              final drop = Curves.bounceOut.transform(math.min(1, v * 2.2));
              final shake = widget.opening
                  ? 0.0
                  : v < 0.5
                  ? 0.0
                  : math.sin(v * 70) * (v - 0.5) * 0.18;
              // Apertura: se agacha (0–25 %), salta y crece mientras la luz
              // sale de adentro.
              final squash = o < 0.25 ? math.sin(math.pi * o / 0.25) : 0.0;
              final pop = o < 0.25
                  ? 0.0
                  : Curves.easeOutBack.transform((o - 0.25) / 0.75);
              final light = o < 0.2 ? 0.0 : Curves.easeOut.transform((o - 0.2) / 0.8);
              return SizedBox(
                width: 320,
                height: 300,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  children: [
                    if (widget.opening)
                      Positioned.fill(
                        child: CustomPaint(
                          painter: _OpenLightPainter(
                            t: light,
                            spin: o,
                            color: widget.color,
                          ),
                        ),
                      ),
                    Transform.translate(
                      offset: Offset(0, -140 * (1 - drop) - 22 * pop),
                      child: Transform.rotate(
                        angle: shake,
                        child: Transform(
                          alignment: Alignment.bottomCenter,
                          transform: Matrix4.diagonal3Values(
                            1 + 0.08 * squash + 0.1 * pop,
                            1 - 0.12 * squash + 0.1 * pop,
                            1,
                          ),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: const _ChestArt(),
          ),
          const SizedBox(height: 28),
          Text(t.lootOpenHint, style: const TextStyle(color: Palette.textDim)),
        ],
      ),
    ));
  }
}

/// La luz que sale del cofre al abrirse: un sol de rayos que gira y crece,
/// un resplandor y chispas que salen disparadas hacia arriba.
class _OpenLightPainter extends CustomPainter {
  const _OpenLightPainter({
    required this.t,
    required this.spin,
    required this.color,
  });

  final double t;
  final double spin;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (t <= 0) return;
    final c = Offset(size.width / 2, size.height * 0.42);
    final r = size.width * (0.25 + 0.55 * t);
    // Resplandor.
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          Colors.white.withValues(alpha: 0.9 * t),
          color.withValues(alpha: 0.45 * t),
          color.withValues(alpha: 0),
        ], stops: const [0, 0.35, 1])
            .createShader(Rect.fromCircle(center: c, radius: r)),
    );
    // Rayos.
    final rays = Paint()..color = Palette.gold.withValues(alpha: 0.35 * t);
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = spin * 0.8 + i * 2 * math.pi / n;
      final w = 0.09;
      final path = Path()
        ..moveTo(c.dx, c.dy)
        ..lineTo(c.dx + math.cos(a - w) * r * 1.3, c.dy + math.sin(a - w) * r * 1.3)
        ..lineTo(c.dx + math.cos(a + w) * r * 1.3, c.dy + math.sin(a + w) * r * 1.3)
        ..close();
      canvas.drawPath(path, rays);
    }
    // Chispas hacia arriba, en abanico.
    final spark = Paint();
    for (var i = 0; i < 18; i++) {
      final a = -math.pi / 2 + (i - 8.5) * 0.16;
      final d = size.height * (0.15 + 0.5 * t) * (0.7 + 0.3 * ((i * 37) % 10) / 10);
      final p = c + Offset(math.cos(a) * d, math.sin(a) * d + 40 * t * t);
      spark.color = (i.isEven ? Palette.gold : Colors.white)
          .withValues(alpha: (1 - t * 0.7).clamp(0, 1));
      canvas.drawCircle(p, 3.5 * (1 - t * 0.5), spark);
    }
  }

  @override
  bool shouldRepaint(_OpenLightPainter old) =>
      old.t != t || old.spin != spin || old.color != color;
}

/// El cofre de laca pintado (`ui/reward_chest.webp`) con el sello 赏 en la
/// tapa. Si falta el arte, una caja dibujada.
class _ChestArt extends StatelessWidget {
  const _ChestArt();

  @override
  Widget build(BuildContext context) => SizedBox(
    width: 250,
    height: 240,
    child: Stack(
      alignment: Alignment.center,
      children: [
        Positioned(
          bottom: 26,
          child: Container(
            width: 200,
            height: 16,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Palette.text.withValues(alpha: 0.12),
            ),
          ),
        ),
        Positioned.fill(
          child: Image.asset(
            'assets/art/ui/reward_chest.webp',
            cacheWidth: (MediaQuery.devicePixelRatioOf(context) * 250).ceil(),
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const _DrawnChest(),
          ),
        ),
        const Positioned(
          top: 40,
          child: InkSeal(hanzi: '赏', color: Palette.gold, size: 40),
        ),
      ],
    ),
  );
}

class _DrawnChest extends StatelessWidget {
  const _DrawnChest();

  @override
  Widget build(BuildContext context) => Center(
    child: Container(
      width: 156,
      height: 116,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFF0625A), Palette.lacquer],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Palette.gold, width: 5),
        boxShadow: [
          BoxShadow(
            color: Palette.lacquer.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
    ),
  );
}

/// El sello del tipo de premio: cae desde grande y se estampa.
class _KindStamp extends StatelessWidget {
  const _KindStamp({required this.kind});

  final RewardKind kind;

  @override
  Widget build(BuildContext context) {
    final (hanzi, color) = lootLook(kind);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 520),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0, 1),
        child: Transform.scale(
          scale: 2.2 - 1.2 * v,
          child: Transform.rotate(angle: (1 - v) * -0.35, child: child),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 12),
        child: InkSeal(hanzi: hanzi, color: color, size: 72),
      ),
    );
  }
}

/// Título y explicación del premio, debajo del sello.
class _KindTitle extends StatelessWidget {
  const _KindTitle({required this.kind, required this.hint});

  final RewardKind kind;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        const SizedBox(height: 10),
        Text(t.lootKind(kind), style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(
          hint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Palette.textDim),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ cartas

/// Pergaminos: 3 cartas (o más) y la forma, como siempre; con los
/// meridianos se pueden volver a tirar.
class _CardsLoot extends ConsumerStatefulWidget {
  const _CardsLoot({required this.stamp, required this.onDone});

  final Widget stamp;
  final VoidCallback onDone;

  @override
  ConsumerState<_CardsLoot> createState() => _CardsLootState();
}

class _CardsLootState extends ConsumerState<_CardsLoot> {
  String? _picked;

  /// Se eligió la forma ofrecida (en vez de una carta).
  bool _formPicked = false;

  /// La elegida vuela al mazo antes de volver al mapa.
  bool _taking = false;
  int _burst = 0;

  /// Cada tirada nueva vuelve a dar vuelta las cartas.
  int _roll = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null || run.phase != RunPhase.reward) return const SizedBox();
    final data = ref.watch(dataProvider);
    final ctl = ref.read(runControllerProvider.notifier);

    void choose(String? id) {
      if (_taking) return;
      if (id == null) {
        ctl.chooseReward(null);
        widget.onDone();
        return;
      }
      Haptics.mediumImpact();
      ref.read(audioProvider).play(Sfx.rewardTake);
      setState(() {
        _taking = true;
        _burst++;
      });
      Future.delayed(const Duration(milliseconds: 650), () {
        if (!mounted) return;
        ctl.chooseReward(id);
        widget.onDone();
      });
    }

    void learn(String formId) {
      if (_taking) return;
      Haptics.heavyImpact();
      ref.read(audioProvider).play(Sfx.formComplete);
      setState(() {
        _taking = true;
        _burst++;
      });
      Future.delayed(const Duration(milliseconds: 1400), () {
        if (!mounted) return;
        ctl.chooseForm(formId);
        widget.onDone();
      });
    }

    void select({String? card, bool form = false}) {
      if (_taking) return;
      Haptics.selectionClick();
      ref.read(audioProvider).play(Sfx.cardSelect);
      setState(() {
        _picked = card;
        _formPicked = form;
      });
    }

    void reroll() {
      if (_taking) return;
      Haptics.mediumImpact();
      ctl.rerollReward();
      setState(() {
        _picked = null;
        _formPicked = false;
        _roll++;
      });
    }

    final text = ref.watch(textProvider);
    final offered = run.rewardForm == null
        ? null
        : data.forms.firstWhere((f) => f.id == run.rewardForm);
    final deckIds = {for (final c in run.deck) c.cardId};
    final picked = _picked == null ? null : data.card(_picked!);
    final n = run.rewardOptions.length;
    final cardWidth = n > 3 ? 84.0 : 104.0;
    return Column(
      children: [
        widget.stamp,
        _KindTitle(kind: RewardKind.cards, hint: t.lootHintCards),
        const Spacer(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final (i, id) in run.rewardOptions.indexed)
              _Reveal(
                key: ValueKey('$_roll-$id'),
                delayMs: 250 + 140 * i,
                onFlip: () => ref.read(audioProvider).play(Sfx.rewardFlip),
                child: Press(child: GestureDetector(
                  onTap: () => select(card: id),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      _Choice(
                        picked: _picked == id,
                        dimmed:
                            (_picked != null || _formPicked) && _picked != id,
                        taking: _taking && _picked == id,
                        child: CardWidget(
                          def: data.card(id),
                          width: cardWidth,
                          selected: _picked == id,
                        ),
                      ),
                      Positioned.fill(
                        child: InkBurst(
                          trigger: _picked == id ? _burst : 0,
                          colors: const [
                            Palette.gold,
                            Palette.lacquer,
                            Colors.white,
                          ],
                          count: 30,
                          radius: 130,
                        ),
                      ),
                    ],
                  ),
                )),
              ),
          ],
        ),
        if (offered != null) ...[
          const SizedBox(height: 16),
          _Reveal(
            key: ValueKey('$_roll-${offered.id}'),
            delayMs: 250 + 140 * n,
            onFlip: () => ref.read(audioProvider).play(Sfx.rewardFlip),
            child: Press(child: GestureDetector(
              onTap: () => select(form: true),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  _Choice(
                    picked: _formPicked,
                    dimmed: _picked != null,
                    taking: false,
                    child: FormScroll(
                      form: offered,
                      name: text.form(offered.id),
                      steps: [
                        for (final id in offered.steps)
                          (text.card(id), deckIds.contains(id)),
                      ],
                      effect: t.formEffect(offered.effect),
                      selected: _formPicked,
                    ),
                  ),
                  Positioned.fill(
                    child: InkBurst(
                      trigger: _formPicked ? _burst : 0,
                      colors: const [
                        Palette.gold,
                        Palette.lacquer,
                        Colors.white,
                      ],
                      count: 44,
                      radius: 180,
                    ),
                  ),
                ],
              ),
            )),
          ),
        ],
        const SizedBox(height: 12),
        SizedBox(
          height: 72,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _formPicked && offered != null
                ? (_taking
                      ? Bounce(
                          key: const ValueKey('learned'),
                          trigger: _burst,
                          scale: 1.25,
                          child: Text(
                            t.formLearned(text.form(offered.id)),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Palette.lacquer,
                            ),
                          ),
                        )
                      : PaperPanel(
                          key: const ValueKey('form'),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 8,
                          ),
                          child: Text(
                            t.formScrollHint,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 14.5),
                          ),
                        ))
                : picked == null
                ? const SizedBox()
                : PaperPanel(
                    key: ValueKey(picked.id),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    child: Text(
                      '${text.card(picked.id)} · ${picked.pinyin} ${picked.hanzi}\n'
                      '${t.cardEffect(picked, text)}'
                      '${data.forms.any((f) => (run.knownForms.contains(f.id) || f.id == run.rewardForm) && f.steps.contains(picked.id)) ? '\n${t.partOfForm}' : ''}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 14.5, height: 1.3),
                    ),
                  ),
          ),
        ),
        if (run.rerollsLeft > 0)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                backgroundColor: Palette.surface.withValues(alpha: 0.9),
                foregroundColor: Palette.text,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ).merge(Theme.of(context).textButtonTheme.style),
              onPressed: _taking ? null : reroll,
              icon: const Icon(Icons.autorenew, size: 18),
              label: Text(t.lootReroll(run.rerollsLeft)),
            ),
          ),
        const Spacer(),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => choose(null),
                child: Text(t.skip),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: _formPicked && offered != null
                    ? () => learn(offered.id)
                    : _picked == null
                    ? null
                    : () => choose(_picked),
                child: Text(t.confirm),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ------------------------------------------------------------ jade y loto

/// Una bolsa de jade o un puñado de semillas: la cifra sube y, al tomarla,
/// vuelan hasta el contador de arriba.
class _CoinsLoot extends ConsumerStatefulWidget {
  const _CoinsLoot({
    required this.stamp,
    required this.kind,
    required this.amount,
    required this.target,
    required this.stackKey,
    required this.onDone,
  });

  final Widget stamp;
  final RewardKind kind;
  final int amount;
  final GlobalKey target;
  final GlobalKey stackKey;
  final VoidCallback onDone;

  @override
  ConsumerState<_CoinsLoot> createState() => _CoinsLootState();
}

class _CoinsLootState extends ConsumerState<_CoinsLoot> {
  final _from = GlobalKey();
  (Offset, Offset)? _flight;
  bool _taken = false;

  /// Lo que se llevaba antes de este premio (para mostrar a cuánto llega).
  late final int _before = widget.kind == RewardKind.jade
      ? ref.read(runControllerProvider)!.jade
      : ref.read(runControllerProvider)!.lotus;

  Offset? _center(GlobalKey k) {
    final box = k.currentContext?.findRenderObject() as RenderBox?;
    final stack =
        widget.stackKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || stack == null) return null;
    return box.localToGlobal(box.size.center(Offset.zero), ancestor: stack);
  }

  void _take() {
    if (_taken) return;
    Haptics.mediumImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    final from = _center(_from);
    final to = _center(widget.target);
    setState(() {
      _taken = true;
      if (from != null && to != null) _flight = (from, to);
    });
    // Llegan las primeras: el contador sube y rebota.
    Future.delayed(const Duration(milliseconds: 650), () {
      if (!mounted) return;
      ref.read(audioProvider).play(Sfx.breathGain);
      ref.read(runControllerProvider.notifier).collectReward();
    });
    Future.delayed(const Duration(milliseconds: 1500), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final jade = widget.kind == RewardKind.jade;
    final color = jade ? Palette.jade : Palette.blossom;
    Widget coin(double size) =>
        jade ? JadeCoin(size: size) : LotusSeed(size: size);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Column(
          children: [
            widget.stamp,
            _KindTitle(
              kind: widget.kind,
              hint: jade
                  ? t.lootHintJade(widget.amount)
                  : t.lootHintLotus(widget.amount),
            ),
            // Se achica si la pantalla es baja, en vez de desbordar.
            Expanded(
              child: Center(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: AnimatedOpacity(
              opacity: _taken ? 0.25 : 1,
              duration: const Duration(milliseconds: 400),
              child: Column(
                children: [
                  _Treasure(
                    color: color,
                    coin: coin,
                    count: math.min(9, math.max(4, widget.amount ~/ 4)),
                    center: KeyedSubtree(key: _from, child: coin(108)),
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    tween: Tween(begin: 0, end: widget.amount.toDouble()),
                    duration: const Duration(milliseconds: 900),
                    curve: Curves.easeOutCubic,
                    builder: (_, v, _) => Text(
                      '+${v.round()}',
                      style: TextStyle(
                        fontSize: 44,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        coin(18),
                        const SizedBox(width: 6),
                        Text(
                          t.lootTotal(_before, _before + widget.amount),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _taken ? null : _take,
                child: Text(t.lootTake),
              ),
            ),
          ],
        ),
        if (_flight != null)
          Positioned.fill(
            child: IgnorePointer(
              child: _Flight(
                // Las posiciones son del Stack de la pantalla; este Stack
                // está corrido por el margen y el SafeArea.
                from: _flight!.$1,
                to: _flight!.$2,
                origin: _center(_stackOrigin) ?? Offset.zero,
                count: math.min(10, math.max(5, widget.amount ~/ 3)),
                particle: () => coin(26),
              ),
            ),
          ),
        Positioned(
          left: 0,
          top: 0,
          child: KeyedSubtree(key: _stackOrigin, child: const SizedBox()),
        ),
      ],
    );
  }

  final _stackOrigin = GlobalKey();
}

/// El tesoro del premio: un sol de rayos que gira despacio, un halo, un
/// montoncito de monedas que caen una por una alrededor de la principal y
/// destellos que titilan. Llena la pantalla en vez de una moneda sola.
class _Treasure extends StatefulWidget {
  const _Treasure({
    required this.color,
    required this.coin,
    required this.count,
    required this.center,
  });

  final Color color;
  final Widget Function(double size) coin;
  final int count;
  final Widget center;

  @override
  State<_Treasure> createState() => _TreasureState();
}

class _TreasureState extends State<_Treasure> with TickerProviderStateMixin {
  late final _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  );
  late final _in = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  int _landed = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _spin);
  }

  @override
  void initState() {
    super.initState();
    // Cada moneda que cae tintinea en la mano.
    _in.addListener(() {
      final n = (widget.count * ((_in.value - 0.15) / 0.7)).floor().clamp(
        0,
        widget.count,
      );
      if (n > _landed) {
        _landed = n;
        Haptics.selectionClick();
      }
    });
  }

  @override
  void dispose() {
    _spin.dispose();
    _in.dispose();
    super.dispose();
  }

  // Lugares del montón, alrededor de la moneda principal (x, y, tamaño).
  static const _spots = [
    (-78.0, 46.0, 44.0),
    (80.0, 42.0, 46.0),
    (-46.0, 70.0, 38.0),
    (50.0, 72.0, 40.0),
    (-108.0, 74.0, 32.0),
    (110.0, 70.0, 34.0),
    (0.0, 84.0, 36.0),
    (-62.0, -40.0, 28.0),
    (66.0, -46.0, 30.0),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 250,
      child: AnimatedBuilder(
        animation: Listenable.merge([_spin, _in]),
        builder: (_, _) {
          final v = _in.value;
          final halo = Curves.easeOut.transform(math.min(1, v * 2));
          return Stack(
            alignment: Alignment.center,
            clipBehavior: Clip.none,
            children: [
              Positioned.fill(
                child: CustomPaint(
                  painter: _SunburstPainter(
                    turn: _spin.value,
                    alpha: halo,
                    color: widget.color,
                  ),
                ),
              ),
              for (var i = 0; i < widget.count && i < _spots.length; i++)
                Builder(
                  builder: (_) {
                    final (x, y, size) = _spots[i];
                    final start = 0.15 + 0.7 * i / widget.count;
                    final p = ((v - start) / 0.25).clamp(0.0, 1.0);
                    final fall = Curves.bounceOut.transform(p);
                    return Transform.translate(
                      offset: Offset(x, y - 120 * (1 - fall)),
                      child: Opacity(
                        opacity: p == 0 ? 0 : 1,
                        child: Transform.rotate(
                          angle: (i.isEven ? -1 : 1) * 0.25,
                          child: widget.coin(size),
                        ),
                      ),
                    );
                  },
                ),
              // La principal flota despacio sobre el montón.
              Transform.translate(
                offset: Offset(0, -10 + 4 * math.sin(_spin.value * math.pi * 8)),
                child: Transform.scale(
                  scale: Curves.easeOutBack.transform(math.min(1, v * 2.5)),
                  child: widget.center,
                ),
              ),
              // Destellos.
              for (var i = 0; i < 5; i++)
                Builder(
                  builder: (_) {
                    final ph = (_spin.value * 6 + i * 0.37) % 1;
                    final a = math.sin(math.pi * ph);
                    final ang = i * 1.3 + 0.4;
                    return Transform.translate(
                      offset: Offset(
                        math.cos(ang) * (70 + 12 * i),
                        math.sin(ang) * (50 + 8 * i) - 20,
                      ),
                      child: Opacity(
                        opacity: (a * halo).clamp(0, 1),
                        child: Icon(
                          Icons.auto_awesome,
                          size: 14 + 6 * a,
                          color: i.isEven ? Palette.gold : Colors.white,
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
}

/// Rayos suaves detrás del tesoro, del color del premio.
class _SunburstPainter extends CustomPainter {
  const _SunburstPainter({
    required this.turn,
    required this.alpha,
    required this.color,
  });

  final double turn;
  final double alpha;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2 - 10);
    final r = size.width * 0.55;
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..shader = RadialGradient(colors: [
          color.withValues(alpha: 0.28 * alpha),
          color.withValues(alpha: 0),
        ]).createShader(Rect.fromCircle(center: c, radius: r)),
    );
    final ray = Paint()
      ..shader = RadialGradient(colors: [
        Palette.gold.withValues(alpha: 0.32 * alpha),
        Palette.gold.withValues(alpha: 0),
      ]).createShader(Rect.fromCircle(center: c, radius: r));
    const n = 16;
    for (var i = 0; i < n; i++) {
      final a = turn * 2 * math.pi + i * 2 * math.pi / n;
      const w = 0.07;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(a - w) * r, c.dy + math.sin(a - w) * r)
          ..lineTo(c.dx + math.cos(a + w) * r, c.dy + math.sin(a + w) * r)
          ..close(),
        ray,
      );
    }
  }

  @override
  bool shouldRepaint(_SunburstPainter old) =>
      old.turn != turn || old.alpha != alpha || old.color != color;
}

/// Monedas que vuelan en curva de [from] a [to], una detrás de la otra.
class _Flight extends StatefulWidget {
  const _Flight({
    required this.from,
    required this.to,
    required this.origin,
    required this.count,
    required this.particle,
  });

  final Offset from;
  final Offset to;

  /// Dónde está este widget dentro del Stack de la pantalla.
  final Offset origin;
  final int count;
  final Widget Function() particle;

  @override
  State<_Flight> createState() => _FlightState();
}

class _FlightState extends State<_Flight> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1100),
  )..forward();
  final _rnd = math.Random();
  late final _spread = [
    for (var i = 0; i < widget.count; i++)
      Offset(_rnd.nextDouble() * 80 - 40, _rnd.nextDouble() * 40 - 20),
  ];

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    builder: (_, _) {
      final from = widget.from - widget.origin;
      final to = widget.to - widget.origin;
      return Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = 0; i < widget.count; i++)
            () {
              final start = i * 0.05;
              final raw = ((_c.value - start) / 0.6).clamp(0.0, 1.0);
              if (raw <= 0 || raw >= 1) return const SizedBox();
              final v = Curves.easeInCubic.transform(raw);
              final a = from + _spread[i];
              // Curva: sale hacia un costado y sube al contador.
              final ctrl = Offset(a.dx + _spread[i].dx * 2, a.dy - 160);
              final p = Offset(
                (1 - v) * (1 - v) * a.dx +
                    2 * (1 - v) * v * ctrl.dx +
                    v * v * to.dx,
                (1 - v) * (1 - v) * a.dy +
                    2 * (1 - v) * v * ctrl.dy +
                    v * v * to.dy,
              );
              return Positioned(
                left: p.dx - 13,
                top: p.dy - 13,
                child: Transform.scale(
                  scale: 1.2 - 0.5 * v,
                  child: widget.particle(),
                ),
              );
            }(),
        ],
      );
    },
  );
}

// --------------------------------------------------------------------- té

/// Té de montaña: la barra de Vida se llena al beberlo.
class _TeaLoot extends ConsumerStatefulWidget {
  const _TeaLoot({
    required this.stamp,
    required this.hp,
    required this.maxHp,
    required this.heal,
    required this.onDone,
  });

  final Widget stamp;
  final int hp;
  final int maxHp;
  final int heal;
  final VoidCallback onDone;

  @override
  ConsumerState<_TeaLoot> createState() => _TeaLootState();
}

class _TeaLootState extends ConsumerState<_TeaLoot> {
  bool _drunk = false;

  void _drink() {
    if (_drunk) return;
    Haptics.mediumImpact();
    ref.read(audioProvider).play(Sfx.fountainHeal);
    setState(() => _drunk = true);
    Future.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      ref.read(runControllerProvider.notifier).collectReward();
    });
    Future.delayed(const Duration(milliseconds: 1600), widget.onDone);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final hp = _drunk ? widget.hp + widget.heal : widget.hp;
    return Column(
      children: [
        widget.stamp,
        _KindTitle(kind: RewardKind.tea, hint: t.lootHintTea(widget.heal)),
        const Spacer(),
        AnimatedScale(
          scale: _drunk ? 1.12 : 1,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOutBack,
          child: const InkSeal(hanzi: '茶', color: Palette.sky, size: 96),
        ),
        const SizedBox(height: 18),
        TweenAnimationBuilder<double>(
          tween: Tween(end: hp / widget.maxHp),
          duration: const Duration(milliseconds: 900),
          curve: Curves.easeOutCubic,
          builder: (_, v, _) => Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  height: 16,
                  width: 240,
                  child: LinearProgressIndicator(
                    value: v,
                    backgroundColor: Palette.line,
                    color: Palette.lacquer,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '${(v * widget.maxHp).round()} / ${widget.maxHp}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 48,
          child: _drunk
              ? PopText(text: '+${widget.heal}', color: Palette.jade, size: 26)
              : null,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _drunk ? null : _drink,
            child: Text(t.lootDrink),
          ),
        ),
      ],
    );
  }
}

// ------------------------------------------------------------------ temple

/// Temple: una carta del mazo gana +N; se ve el antes y el después.
class _UpgradeLoot extends ConsumerStatefulWidget {
  const _UpgradeLoot({
    required this.stamp,
    required this.amount,
    required this.onDone,
  });

  final Widget stamp;
  final int amount;
  final VoidCallback onDone;

  @override
  ConsumerState<_UpgradeLoot> createState() => _UpgradeLootState();
}

class _UpgradeLootState extends ConsumerState<_UpgradeLoot> {
  int? _uid;
  bool _done = false;
  int _burst = 0;

  void _temper() {
    final uid = _uid;
    if (uid == null || _done) return;
    Haptics.heavyImpact();
    ref.read(audioProvider).play(Sfx.formComplete);
    setState(() {
      _done = true;
      _burst++;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      ref.read(runControllerProvider.notifier).chooseRewardUpgrade(uid);
      widget.onDone();
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final card = _uid == null
        ? null
        : run.deck.where((c) => c.uid == _uid).firstOrNull;
    return Column(
      children: [
        widget.stamp,
        _KindTitle(
          kind: RewardKind.upgrade,
          hint: t.lootHintUpgrade(widget.amount),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: card == null
              ? DeckGrid(
                  cards: run.deck,
                  enabled: engine.canUpgrade,
                  onPick: (c) {
                    Haptics.selectionClick();
                    ref.read(audioProvider).play(Sfx.cardSelect);
                    setState(() => _uid = c.uid);
                  },
                )
              : GestureDetector(
                  onTap: _done ? null : () => setState(() => _uid = null),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Opacity(
                        opacity: 0.6,
                        child: CardWidget(
                          def: data.card(card.cardId),
                          upgrades: card.upgrades,
                          width: 100,
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Icon(
                          Icons.arrow_forward,
                          color: Palette.gold,
                          size: 30,
                        ),
                      ),
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Bounce(
                            trigger: _burst,
                            scale: 1.15,
                            child: CardWidget(
                              def: data.card(card.cardId),
                              upgrades: card.upgrades + widget.amount,
                              width: 120,
                              selected: true,
                            ),
                          ),
                          Positioned.fill(
                            child: InkBurst(
                              trigger: _burst,
                              colors: const [
                                Palette.gold,
                                Palette.lacquer,
                                Colors.white,
                              ],
                              count: 36,
                              radius: 150,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _done
                    ? null
                    : () {
                        ref
                            .read(runControllerProvider.notifier)
                            .collectReward();
                        widget.onDone();
                      },
                child: Text(t.skip),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: card == null || _done ? null : _temper,
                child: Text(t.lootTemper),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ----------------------------------------------------------------- comunes

/// La carta se da vuelta y sube desde abajo al entrar en pantalla.
class _Reveal extends StatefulWidget {
  const _Reveal({
    super.key,
    required this.delayMs,
    required this.onFlip,
    required this.child,
  });

  final int delayMs;
  final VoidCallback onFlip;
  final Widget child;

  @override
  State<_Reveal> createState() => _RevealState();
}

class _RevealState extends State<_Reveal> with SingleTickerProviderStateMixin {
  static const _flip = 520;
  late final _c =
      AnimationController(
          vsync: this,
          duration: Duration(milliseconds: _flip + widget.delayMs),
        )
        ..addListener(_onTick)
        ..forward();
  bool _flipped = false;

  void _onTick() {
    if (!_flipped && _c.value > widget.delayMs / (_flip + widget.delayMs)) {
      _flipped = true;
      widget.onFlip();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.delayMs / (_flip + widget.delayMs);
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final raw = _c.value <= start ? 0.0 : (_c.value - start) / (1 - start);
        if (raw >= 1) return child!;
        final v = Curves.easeOutBack.transform(raw);
        return Opacity(
          opacity: math.min(1, raw * 3),
          child: Transform.translate(
            offset: Offset(0, 60 * (1 - v)),
            child: Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.0015)
                ..rotateY(math.pi / 2 * (1 - v)),
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Estado de una opción: la elegida sube y brilla, las otras se apagan; al
/// confirmar, la elegida crece y se desvanece hacia el mazo.
class _Choice extends StatelessWidget {
  const _Choice({
    required this.picked,
    required this.dimmed,
    required this.taking,
    required this.child,
  });

  final bool picked;
  final bool dimmed;
  final bool taking;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedSlide(
      offset: Offset(0, taking ? -0.5 : (picked ? -0.08 : 0)),
      duration: Duration(milliseconds: taking ? 550 : 240),
      curve: taking ? Curves.easeInCubic : Curves.easeOutBack,
      child: AnimatedScale(
        scale: taking ? 1.25 : (picked ? 1.08 : (dimmed ? 0.94 : 1)),
        duration: Duration(milliseconds: taking ? 550 : 240),
        curve: Curves.easeOutBack,
        child: AnimatedOpacity(
          opacity: taking ? 0 : (dimmed ? 0.55 : 1),
          duration: Duration(milliseconds: taking ? 550 : 200),
          curve: taking ? const Interval(0.5, 1) : Curves.linear,
          child: child,
        ),
      ),
    );
  }
}
