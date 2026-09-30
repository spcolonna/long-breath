import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/combat_engine.dart';
import '../../domain/combat/combat_event.dart';
import '../../domain/combat/combat_state.dart';
import '../../domain/model/enemy_def.dart';
import '../../domain/model/enums.dart';
import '../../domain/model/game_data.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/stat_bar.dart';

class CombatScreen extends ConsumerStatefulWidget {
  const CombatScreen({super.key});

  @override
  ConsumerState<CombatScreen> createState() => _CombatScreenState();
}

class _Fx {
  const _Fx(this.title, this.subtitle, this.color, {this.big = false});
  final String title;
  final String? subtitle;
  final Color color;
  final bool big;
}

class _CombatScreenState extends ConsumerState<CombatScreen> {
  final _queue = <_Fx>[];
  _Fx? _current;
  int _fxKey = 0;
  int _enemyDelta = 0, _playerDelta = 0, _deltaKey = 0;
  int _hitKey = 0, _attackKey = 0, _hurtKey = 0;

  void _onEvents(List<CombatEvent> events) {
    final data = ref.read(dataProvider);
    final text = ref.read(textProvider);
    final t = AppLocalizations.of(context);
    var enemy = 0, player = 0;
    var hit = false, attacked = false, hurt = false;
    for (final e in events) {
      switch (e) {
        case EnemyDamaged(:final damage):
          enemy += damage;
          hit = true;
        case PlayerHit(:final damage):
          player += damage;
          attacked = true;
          hurt = true;
        case Deflected():
          attacked = true;
          HapticFeedback.mediumImpact();
          _queue.add(_Fx(t.deflect, '化', Palette.sky));
        case EnemyBroken():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.broken, t.staggeredDouble, Palette.gold));
        case PlayerBroken():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.playerBroken, '−2 ${t.breath}', Palette.lacquer));
        case FormCompleted(:final formId):
          HapticFeedback.heavyImpact();
          final f = data.forms.firstWhere((f) => f.id == formId);
          _queue.add(_Fx(text.form(f.id), '${f.hanzi} · ${f.pinyin}', Palette.lacquer,
              big: true));
        case FormsResetByEnemy():
          _queue.add(_Fx(t.formsInterrupted, null, Palette.textDim));
        case EnemyPhaseChanged():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.enemyPhase2, null, Palette.gold, big: true));
        default:
      }
    }
    setState(() {
      if (enemy > 0 || player > 0) {
        _enemyDelta = enemy;
        _playerDelta = player;
        _deltaKey++;
      }
      if (hit) _hitKey++;
      if (attacked) _attackKey++;
      if (hurt) _hurtKey++;
    });
    _pump();
  }

  void _pump() {
    if (_current != null || _queue.isEmpty) return;
    setState(() {
      _current = _queue.removeAt(0);
      _fxKey++;
    });
    Timer(Duration(milliseconds: _current!.big ? 1400 : 900), () {
      if (!mounted) return;
      setState(() => _current = null);
      _pump();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(combatControllerProvider, (prev, next) {
      if (next != null && next.seq != prev?.seq) _onEvents(next.events);
    });
    final view = ref.watch(combatControllerProvider);
    if (view == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = ref.watch(dataProvider);
    final engine = ref.watch(combatEngineProvider);
    final s = view.state;

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: _Arena(
                    stageId: data.balance.stage.id,
                    turn: s.turn,
                    style: ref.watch(runControllerProvider)?.style ?? Style.snake,
                    strikeKey: _hitKey,
                    hurtKey: _hurtKey,
                    // Hoy hay un solo enemigo; la arena ya acepta varios.
                    slots: [
                      _EnemySlot(
                        def: data.enemy(s.enemy.id),
                        enemy: s.enemy,
                        intent: engine.intentView(s),
                        delta: _enemyDelta,
                        deltaKey: _deltaKey,
                        hitKey: _hitKey,
                        attackKey: _attackKey,
                      ),
                    ],
                  ),
                ),
                _PlayerStrip(s: s, delta: _playerDelta, deltaKey: _deltaKey),
                _FormsPanel(s: s, data: data),
                _PreviewPanel(view: view, data: data, engine: engine),
                _HandArea(view: view, data: data, engine: engine),
                _ActionBar(view: view, engine: engine, data: data),
              ],
            ),
            if (_current != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: _FxBanner(key: ValueKey(_fxKey), fx: _current!),
                ),
              ),
            if (s.isOver) _EndOverlay(won: s.phase == CombatPhase.won),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------- arena

class _EnemySlot {
  const _EnemySlot({
    required this.def,
    required this.enemy,
    required this.intent,
    required this.delta,
    required this.deltaKey,
    required this.hitKey,
    required this.attackKey,
  });

  final EnemyDef def;
  final EnemyCombat enemy;
  final IntentView intent;
  final int delta;
  final int deltaKey;
  final int hitKey;
  final int attackKey;
}

/// Escenario del combate: fondo de la etapa, suelo, los enemigos al frente y
/// el héroe de espaldas en primer plano.
class _Arena extends StatelessWidget {
  const _Arena({
    required this.stageId,
    required this.turn,
    required this.style,
    required this.strikeKey,
    required this.hurtKey,
    required this.slots,
  });

  final String stageId;
  final int turn;
  final Style style;
  final int strikeKey;
  final int hurtKey;
  final List<_EnemySlot> slots;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    const fallback = DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFBFE3F2), Color(0xFFE8F4EA), Color(0xFFF3E7C9)],
        ),
      ),
    );
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(24)),
      child: LayoutBuilder(builder: (context, box) {
        final heroH = math.min(box.maxHeight * 0.62, box.maxWidth * 0.54);
        final heroW = heroH * 2 / 3;
        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              'assets/art/stages/$stageId/combat_bg.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => fallback,
            ),
            // Suelo.
            Align(
              alignment: const Alignment(0, 0.62),
              child: FractionallySizedBox(
                widthFactor: 0.75,
                child: Container(
                  height: 34,
                  decoration: BoxDecoration(
                    borderRadius: const BorderRadius.all(Radius.elliptical(200, 34)),
                    gradient: RadialGradient(colors: [
                      Palette.text.withValues(alpha: 0.22),
                      Palette.text.withValues(alpha: 0),
                    ]),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              top: 8,
              child: _Chip(
                  icon: Icons.hourglass_bottom, text: t.turn(turn), color: Palette.text),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(heroW * 0.8, 8, 16, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [for (final slot in slots) Expanded(child: _EnemyStage(slot: slot))],
              ),
            ),
            // Héroe de espaldas, cortado por el borde inferior.
            Positioned(
              left: -heroW * 0.12,
              bottom: -heroH * 0.12,
              child: IgnorePointer(
                child: HeroSprite(
                  style: style,
                  height: heroH,
                  strikeKey: strikeKey,
                  hurtKey: hurtKey,
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}

class _EnemyStage extends ConsumerWidget {
  const _EnemyStage({required this.slot});

  final _EnemySlot slot;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final e = slot.enemy;
    final def = slot.def;
    final accent = rankColor(def.rank);
    return Column(
      children: [
        const SizedBox(height: 26),
        _IntentBubble(iv: slot.intent),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final size = math.min(box.maxHeight, 220.0);
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  EnemySprite(
                    def: def,
                    staggered: e.staggered,
                    hitKey: slot.hitKey,
                    attackKey: slot.attackKey,
                    size: size,
                  ),
                  Positioned(
                    right: 8,
                    top: size * 0.2,
                    child: _FloatingDelta(
                        value: slot.delta, key: ValueKey('e${slot.deltaKey}'), big: true),
                  ),
                ],
              );
            },
          ),
        ),
        // Placa de nombre.
        GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => AlertDialog(
              title: Text(text.enemy(def.id)),
              content: Text(text.enemyRule(def.id)),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.fromLTRB(12, 4, 8, 4),
            decoration: BoxDecoration(
              color: accent,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: accent.withValues(alpha: 0.4), blurRadius: 8)],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(
                  child: Text(text.enemy(def.id),
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Palette.onColor)),
                ),
                if (def.rank != EnemyRank.common)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: Text(
                        def.rank == EnemyRank.elite ? t.rankElite : t.rankBoss,
                        style: const TextStyle(fontSize: 11, color: Palette.onColor)),
                  ),
                const SizedBox(width: 4),
                const Icon(Icons.info_outline, size: 16, color: Palette.onColor),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        _MiniBar(value: e.hp, max: e.maxHp, color: Palette.lacquer, icon: Icons.favorite),
        const SizedBox(height: 3),
        _MiniBar(
          value: e.structure,
          max: e.maxStructure,
          color: e.staggered ? Palette.textDim : Palette.structure,
          icon: Icons.hexagon_outlined,
          height: 8,
        ),
        if (e.guard > 0 || e.staggered)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Wrap(
              alignment: WrapAlignment.center,
              children: [
                if (e.guard > 0)
                  _Chip(icon: Icons.shield, text: '${t.guard} ${e.guard}', color: Palette.sky),
                if (e.staggered)
                  _Chip(icon: Icons.blur_on, text: t.staggeredDouble, color: Palette.gold),
              ],
            ),
          ),
      ],
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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(height / 2),
            child: Stack(
              children: [
                Container(height: height, color: Palette.surface.withValues(alpha: 0.8)),
                TweenAnimationBuilder<double>(
                  tween: Tween(end: ratio),
                  duration: const Duration(milliseconds: 350),
                  builder: (_, v, _) => FractionallySizedBox(
                    widthFactor: v,
                    child: Container(height: height, color: color),
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(
          width: 46,
          child: Text('$value/$max',
              textAlign: TextAlign.right,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  fontFeatures: [FontFeature.tabularFigures()])),
        ),
      ],
    );
  }
}

/// Globo de intención sobre la cabeza del enemigo.
class _IntentBubble extends ConsumerWidget {
  const _IntentBubble({required this.iv});

  final IntentView iv;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final i = iv.intent;
    final named = i.labelKey == null ? null : text.intent(i.labelKey!);
    final (IconData icon, String title, String detail) = switch (i.kind) {
      IntentKind.attack => (
          heightIcon(i.height),
          named == null
              ? t.intentAttack(t.heightLabel(i.height))
              : t.intentNamedAttack(named, t.heightLabel(i.height)),
          '${iv.damage}${i.hits > 1 ? '×${i.hits}' : ''} · E ${iv.structure}',
        ),
      IntentKind.guard => (Icons.shield, named ?? t.guard, '${t.guard} ${i.value}'),
      IntentKind.charge => (Icons.bolt, named ?? t.intentCharge, t.intentChargeDetail(i.value)),
      IntentKind.discard =>
        (Icons.graphic_eq, named ?? t.intentDiscard, t.intentDiscardDetail(i.count)),
    };
    final color = iv.skipped ? Palette.textDim : Palette.lacquer;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.fromLTRB(6, 5, 12, 5),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: iv.skipped ? Palette.gold : color, width: 2),
            boxShadow: const [
              BoxShadow(color: Color(0x22000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                child: Icon(icon, size: 22, color: Palette.onColor),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(title,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            decoration: iv.skipped ? TextDecoration.lineThrough : null)),
                    Text(iv.skipped ? t.losesAction : detail,
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: iv.skipped ? Palette.gold : Palette.lacquer)),
                    if (i.interrupt)
                      Text(t.intentInterrupt,
                          style: const TextStyle(fontSize: 10, color: Palette.textDim)),
                    if (iv.punishIfSameStance)
                      Text(t.intentSameStance,
                          style: const TextStyle(fontSize: 10, color: Palette.textDim)),
                  ],
                ),
              ),
              if (iv.countdown != null) ...[
                const SizedBox(width: 8),
                Column(
                  children: [
                    Text('${iv.countdown}',
                        style: const TextStyle(
                            fontSize: 20, color: Palette.gold, fontWeight: FontWeight.bold)),
                    Text(t.countdown,
                        style: const TextStyle(fontSize: 9, color: Palette.gold)),
                  ],
                ),
              ],
            ],
          ),
        ),
        // Cola del globo.
        CustomPaint(size: const Size(16, 8), painter: _TailPainter(iv.skipped ? Palette.gold : color)),
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
        Paint()..color = color);
  }

  @override
  bool shouldRepaint(_TailPainter old) => old.color != color;
}

// ---------------------------------------------------------------- jugador

class _PlayerStrip extends ConsumerWidget {
  const _PlayerStrip({required this.s, required this.delta, required this.deltaKey});

  final CombatState s;
  final int delta;
  final int deltaKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final p = s.player;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    StatBar(
                        label: t.life, value: p.hp, max: p.maxHp, color: Palette.jade),
                    const SizedBox(height: 3),
                    StatBar(
                      label: t.structure,
                      value: p.structure,
                      max: p.maxStructure,
                      color: Palette.structure,
                      height: 8,
                    ),
                  ],
                ),
              ),
              _FloatingDelta(value: delta, key: ValueKey('p$deltaKey')),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final st in Stance.values)
                Expanded(
                  child: _StanceChip(
                      name: text.stance(st),
                      hanzi: _stanceHanzi[st]!,
                      active: st == p.stance),
                ),
              const SizedBox(width: 2),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                decoration: BoxDecoration(
                  color: p.guard > 0 ? Palette.sky : Palette.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: p.guard > 0 ? Palette.sky : Palette.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.shield,
                        size: 16, color: p.guard > 0 ? Palette.onColor : Palette.sky),
                    const SizedBox(width: 4),
                    Text('${p.guard}',
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: p.guard > 0 ? Palette.onColor : Palette.text)),
                    if (p.guardHeight != null)
                      Icon(heightIcon(p.guardHeight), size: 14, color: Palette.onColor),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

const _stanceHanzi = {Stance.mabu: '马步', Stance.gongbu: '弓步', Stance.xubu: '虚步'};

class _StanceChip extends StatelessWidget {
  const _StanceChip({required this.name, required this.hanzi, required this.active});

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
          Text(name,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: fg)),
          Text(hanzi, style: TextStyle(fontSize: 9, color: fg)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ formas

class _FormsPanel extends ConsumerWidget {
  const _FormsPanel({required this.s, required this.data});

  final CombatState s;
  final GameData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(textProvider);
    // Solo formas cuyas cartas están todas en el mazo del combate.
    final owned = {
      for (final c in [...s.drawPile, ...s.hand, ...s.discard, ...s.exhausted])
        c.cardId,
    };
    final forms = data.forms.where((f) => owned.containsAll(f.steps));
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      child: Column(
        children: [
          for (final f in forms)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(text.form(f.id),
                            maxLines: 2,
                            style: const TextStyle(
                                fontSize: 10,
                                height: 1.1,
                                fontWeight: FontWeight.w700,
                                color: Palette.gold)),
                        Text(f.hanzi,
                            style: const TextStyle(fontSize: 9, color: Palette.textDim)),
                      ],
                    ),
                  ),
                  for (var i = 0; i < f.steps.length; i++)
                    Expanded(
                      child: _FormStep(
                        label: text.card(f.steps[i]),
                        done: i < s.formProgress[f.id]!,
                        next: i == s.formProgress[f.id]!,
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

class _FormStep extends StatelessWidget {
  const _FormStep({required this.label, required this.done, required this.next});

  final String label;
  final bool done;
  final bool next;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      height: 30,
      margin: const EdgeInsets.only(right: 3),
      padding: const EdgeInsets.symmetric(horizontal: 2),
      decoration: BoxDecoration(
        color: done ? Palette.gold : Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: next ? Palette.gold : Palette.line, width: next ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: Text(label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
              fontSize: 8.5,
              height: 1.05,
              fontWeight: FontWeight.w600,
              color: done ? Palette.onColor : Palette.textDim)),
    );
  }
}

// -------------------------------------------------------------------- mano

class _PreviewPanel extends ConsumerWidget {
  const _PreviewPanel({required this.view, required this.data, required this.engine});

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
    if (uid == null || s.handCard(uid) == null) return const SizedBox(height: 44);
    final c = s.handCard(uid)!;
    final def = data.card(c.cardId);
    final p = engine.preview(s, uid);
    final parts = <String>[
      if (p.damage > 0) t.previewDamage(p.damage),
      if (p.structure > 0) t.previewStructure(p.structure),
      if (p.guard > 0) '${t.guard} ${p.guard} ${t.heightLabel(p.height)}',
      if (p.stanceAfter != s.player.stance) '→ ${text.stance(p.stanceAfter)}',
    ];
    String formName(String id) => text.form(id);
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
                  Text('${text.card(def.id)} · ${def.pinyin}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(
                    [
                      ...parts,
                      for (final f in p.completesForms) t.previewCompletes(formName(f)),
                      for (final f in p.advancesForms) t.previewAdvances(formName(f)),
                      for (final f in p.interruptsForms) t.previewInterrupts(formName(f)),
                    ].join(' · '),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Palette.textDim),
                  ),
                ],
              ),
            ),
            Text(p.playable ? t.tapAgain : (p.reason == null ? '' : t.invalidLabel(p.reason!)),
                style: TextStyle(
                    fontSize: 10,
                    color: p.playable ? Palette.gold : Palette.lacquer)),
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

class _HandArea extends ConsumerWidget {
  const _HandArea({required this.view, required this.data, required this.engine});

  final CombatView view;
  final GameData data;
  final CombatEngine engine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = view.state;
    final hand = s.hand;
    return LayoutBuilder(builder: (context, box) {
      // Las cartas se achican para no taparse el nombre; solo se enciman
      // si la mano es muy grande.
      final n = hand.length;
      final avail = box.maxWidth - 24;
      final cardW = n == 0 ? 92.0 : ((avail - 4 * (n - 1)) / n).clamp(66.0, 92.0);
      final step = n <= 1
          ? 0.0
          : math.min(cardW + 6, (avail - cardW) / (n - 1));
      final total = n == 0 ? 0.0 : cardW + step * (n - 1);
      final left0 = (box.maxWidth - total) / 2;
      return SizedBox(
        height: 92 * 1.5 + 28, // fija: la arena no salta al cambiar la mano
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            for (var i = 0; i < n; i++)
              _positioned(context, ref, i, n, left0 + step * i, cardW, hand[i]),
          ],
        ),
      );
    });
  }

  Widget _positioned(BuildContext context, WidgetRef ref, int i, int n,
      double left, double w, CombatCard c) {
    final s = view.state;
    final def = data.card(c.cardId);
    final p = engine.preview(s, c.uid);
    final selected = view.selected == c.uid;
    final mid = (n - 1) / 2;
    final angle = n <= 1 ? 0.0 : (i - mid) * 0.05;
    final lift = selected ? -22.0 : (i - mid).abs() * 3;
    final advances = p.advancesForms.isNotEmpty || p.completesForms.isNotEmpty;
    return AnimatedPositioned(
      key: ValueKey(c.uid),
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOut,
      left: left,
      top: 16 + lift,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(combatControllerProvider.notifier).tapCard(c.uid);
        },
        child: Transform.rotate(
          angle: selected ? 0 : angle,
          child: CardWidget(
            def: def,
            upgrades: c.upgrades,
            preview: p,
            width: w,
            selected: selected,
            advancesForm: advances,
            interruptsForm: p.interruptsForms.isNotEmpty,
            playable: view.retaining ||
                s.phase == CombatPhase.discarding ||
                p.playable,
            marked: view.retain.contains(c.uid),
          ),
        ),
      ),
    );
  }
}

class _ActionBar extends ConsumerWidget {
  const _ActionBar({required this.view, required this.engine, required this.data});

  final CombatView view;
  final CombatEngine engine;
  final GameData data;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final s = view.state;
    final ctl = ref.read(combatControllerProvider.notifier);
    final busy = s.isOver || s.phase == CombatPhase.discarding;

    if (view.retaining) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                  onPressed: ctl.cancelRetain, child: Text(t.cancel)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                onPressed: ctl.confirmRetain,
                child: Text('${t.confirm} (${view.retain.length}/${s.retainMax})'),
              ),
            ),
          ],
        ),
      );
    }

    final canDingbu = !busy &&
        !s.dingbuUsed &&
        s.player.breath >= data.transition.cost;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
      child: Row(
        children: [
          _BreathPips(breath: s.player.breath, perTurn: s.breathPerTurn),
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: canDingbu ? () => _pickStance(context, ref, ctl, s) : null,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              child: FittedBox(child: Text(text.dingbu(), maxLines: 1)),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: OutlinedButton(
              onPressed: !busy && s.breathesLeft > 0 ? ctl.breathe : null,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              child: Text(t.breathe, maxLines: 1),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: busy ? null : ctl.endTurnPressed,
              child: Text(t.endTurn, maxLines: 1),
            ),
          ),
        ],
      ),
    );
  }

  void _pickStance(
      BuildContext context, WidgetRef ref, CombatController ctl, CombatState s) {
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
              child: Text('${text.dingbu()} 丁步 · ${t.changeStance(t.breath)}',
                  style: const TextStyle(fontSize: 16)),
            ),
            for (final st in Stance.values)
              if (st != s.player.stance)
                ListTile(
                  leading: Text(_stanceHanzi[st]!,
                      style: const TextStyle(fontSize: 16, color: Palette.textDim)),
                  title: Text(text.stance(st),
                      style: const TextStyle(fontWeight: FontWeight.w700)),
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
              AnimatedContainer(
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
          ],
        ),
        const SizedBox(height: 2),
        Text('${AppLocalizations.of(context).breath} $breath',
            style: const TextStyle(fontSize: 10, color: Palette.sky)),
      ],
    );
  }
}

// ----------------------------------------------------------------- efectos

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
          color: color.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
            Text(text, style: TextStyle(fontSize: 11, color: color)),
          ],
        ),
      );
}

/// Número de daño que sube y se desvanece.
class _FloatingDelta extends StatelessWidget {
  const _FloatingDelta({super.key, required this.value, this.big = false});

  final int value;
  final bool big;

  @override
  Widget build(BuildContext context) {
    if (value <= 0) return const SizedBox(width: 40);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, _) => Opacity(
        opacity: 1 - v,
        child: Transform.translate(
          offset: Offset(0, (big ? -40 : -16) * v),
          child: SizedBox(
            width: big ? 64 : 40,
            child: Text('−$value',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: big ? 32 : 18,
                    fontWeight: FontWeight.w900,
                    color: Palette.lacquer,
                    shadows: const [Shadow(color: Colors.white, blurRadius: 6)])),
          ),
        ),
      ),
    );
  }
}

class _FxBanner extends StatelessWidget {
  const _FxBanner({super.key, required this.fx});

  final _Fx fx;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: fx.big ? 1400 : 900),
      builder: (_, v, _) {
        final opacity = v < 0.2 ? v / 0.2 : (v > 0.75 ? (1 - v) / 0.25 : 1.0);
        final scale = 0.8 + 0.25 * Curves.easeOutBack.transform(math.min(1, v * 3));
        return Opacity(
          opacity: opacity.clamp(0, 1),
          child: Container(
            color: Palette.surface.withValues(alpha: 0.55 * opacity),
            alignment: const Alignment(0, -0.2),
            child: Transform.scale(
              scale: scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(fx.title,
                      style: TextStyle(
                        fontSize: fx.big ? 72 : 40,
                        fontWeight: FontWeight.bold,
                        color: fx.color,
                        shadows: const [Shadow(color: Colors.white, blurRadius: 16)],
                      )),
                  if (fx.subtitle != null)
                    Text(fx.subtitle!,
                        style: const TextStyle(fontSize: 18, color: Palette.text)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EndOverlay extends ConsumerWidget {
  const _EndOverlay({required this.won});

  final bool won;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Positioned.fill(
      child: Container(
        color: Palette.surface.withValues(alpha: 0.88),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(won ? t.victory : t.defeat,
                style: TextStyle(
                    fontSize: 44,
                    fontWeight: FontWeight.w800,
                    color: won ? Palette.gold : Palette.lacquer)),
            Text(won ? '胜' : '败',
                style: const TextStyle(fontSize: 22, color: Palette.textDim)),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () {
                ref.read(combatControllerProvider.notifier).finish();
                final run = ref.read(runControllerProvider)!;
                context.go(switch (run.phase) {
                  RunPhase.reward => '/reward',
                  RunPhase.victory || RunPhase.defeat => '/result',
                  _ => '/map',
                });
              },
              child: Text(t.continueLabel),
            ),
          ],
        ),
      ),
    );
  }
}
