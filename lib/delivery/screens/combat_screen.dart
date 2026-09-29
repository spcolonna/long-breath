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
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
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

  void _onEvents(List<CombatEvent> events) {
    final data = ref.read(dataProvider);
    final t = AppLocalizations.of(context);
    var enemy = 0, player = 0;
    for (final e in events) {
      switch (e) {
        case EnemyDamaged(:final damage):
          enemy += damage;
        case PlayerHit(:final damage):
          player += damage;
        case Deflected():
          HapticFeedback.mediumImpact();
          _queue.add(_Fx(t.deflect, null, Palette.sky));
        case EnemyBroken():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.broken, t.staggered, Palette.gold));
        case PlayerBroken():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.playerBroken, '−2 ${t.breath}', Palette.lacquer));
        case FormCompleted(:final formId):
          HapticFeedback.heavyImpact();
          final f = data.forms.firstWhere((f) => f.id == formId);
          _queue.add(_Fx(f.hanzi, f.pinyin, Palette.lacquer, big: true));
        case FormsResetByEnemy():
          _queue.add(const _Fx('套路 ✕', 'Formas interrumpidas', Palette.textDim));
        case EnemyPhaseChanged():
          HapticFeedback.heavyImpact();
          _queue.add(const _Fx('龙', 'El dragón despierta', Palette.gold, big: true));
        default:
      }
    }
    setState(() {
      if (enemy > 0 || player > 0) {
        _enemyDelta = enemy;
        _playerDelta = player;
        _deltaKey++;
      }
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
                _EnemyPanel(
                  s: s,
                  data: data,
                  delta: _enemyDelta,
                  deltaKey: _deltaKey,
                ),
                _IntentPanel(s: s, engine: engine),
                _PlayerPanel(
                  s: s,
                  delta: _playerDelta,
                  deltaKey: _deltaKey,
                ),
                _FormsPanel(s: s, data: data, view: view, engine: engine),
                const Spacer(),
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

// ------------------------------------------------------------------ enemigo

class _EnemyPanel extends StatelessWidget {
  const _EnemyPanel({
    required this.s,
    required this.data,
    required this.delta,
    required this.deltaKey,
  });

  final CombatState s;
  final GameData data;
  final int delta;
  final int deltaKey;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final e = s.enemy;
    final def = data.enemy(e.id);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              _EnemyFigure(def: def, staggered: e.staggered),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(def.name,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 17, fontWeight: FontWeight.w600)),
                        ),
                        if (def.rank != EnemyRank.common)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: Text(
                                def.rank == EnemyRank.elite ? 'Élite' : 'Guardián',
                                style: const TextStyle(
                                    fontSize: 11, color: Palette.gold)),
                          ),
                        IconButton(
                          visualDensity: VisualDensity.compact,
                          icon: const Icon(Icons.info_outline, size: 18),
                          onPressed: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(def.name),
                              content: Text(def.rule),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Text(t.turn(s.turn),
                        style: const TextStyle(
                            fontSize: 11, color: Palette.textDim)),
                  ],
                ),
              ),
              _FloatingDelta(value: delta, key: ValueKey('e$deltaKey')),
            ],
          ),
          const SizedBox(height: 6),
          StatBar(
              label: t.life, value: e.hp, max: e.maxHp, color: Palette.lacquer),
          const SizedBox(height: 4),
          StatBar(
            label: t.structure,
            value: e.structure,
            max: e.maxStructure,
            color: e.staggered ? Palette.textDim : Palette.structure,
            height: 10,
          ),
          if (e.guard > 0 || e.staggered)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                children: [
                  if (e.guard > 0)
                    _Chip(icon: Icons.shield, text: '${t.guard} ${e.guard}',
                        color: Palette.sky),
                  if (e.staggered)
                    _Chip(icon: Icons.blur_on, text: '${t.staggered} · daño ×2',
                        color: Palette.gold),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Figura placeholder: círculo de tinta con el carácter del enemigo.
class _EnemyFigure extends StatelessWidget {
  const _EnemyFigure({required this.def, required this.staggered});

  final EnemyDef def;
  final bool staggered;

  static const _glyphs = {
    'bat': '蝠',
    'salamander': '蜥',
    'golem': '石',
    'disciple': '徒',
    'monk': '僧',
    'dragon': '龙',
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedRotation(
      turns: staggered ? -0.03 : 0,
      duration: const Duration(milliseconds: 300),
      child: Container(
        width: 56,
        height: 56,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.surface,
          border: Border.all(
              color: def.rank == EnemyRank.boss ? Palette.gold : Palette.line,
              width: 2),
        ),
        child: Text(_glyphs[def.id] ?? '？',
            style: const TextStyle(fontSize: 28, color: Palette.text)),
      ),
    );
  }
}

// ---------------------------------------------------------------- intención

class _IntentPanel extends StatelessWidget {
  const _IntentPanel({required this.s, required this.engine});

  final CombatState s;
  final CombatEngine engine;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final iv = engine.intentView(s);
    final i = iv.intent;
    final (IconData icon, String title, String detail) = switch (i.kind) {
      IntentKind.attack => (
          heightIcon(i.height),
          '${i.label ?? 'Ataque'} ${heightLabel(i.height)}',
          '${iv.damage}${i.hits > 1 ? '×${i.hits}' : ''} · E ${iv.structure}',
        ),
      IntentKind.guard => (Icons.shield, i.label ?? t.guard, '${t.guard} ${i.value}'),
      IntentKind.charge => (Icons.bolt, i.label ?? 'Carga', 'Próximo ataque +${i.value}'),
      IntentKind.discard => (Icons.graphic_eq, i.label ?? 'Descarte', 'Descartás ${i.count}'),
    };
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: iv.skipped ? Palette.gold : Palette.lacquer.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (iv.skipped ? Palette.textDim : Palette.lacquer)
                  .withValues(alpha: 0.25),
            ),
            child: Icon(icon, size: 28, color: Palette.text),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        decoration:
                            iv.skipped ? TextDecoration.lineThrough : null)),
                Text(iv.skipped ? t.losesAction : detail,
                    style: TextStyle(
                        fontSize: 13,
                        color: iv.skipped ? Palette.gold : Palette.textDim)),
                if (i.interrupt)
                  const Text('Interrumpe tus formas si no lo desviás',
                      style: TextStyle(fontSize: 11, color: Palette.lacquer)),
                if (iv.punishIfSameStance)
                  const Text('Si terminás en esta postura: +4 daño, +2 E',
                      style: TextStyle(fontSize: 11, color: Palette.lacquer)),
              ],
            ),
          ),
          if (iv.countdown != null)
            Column(
              children: [
                Text('${iv.countdown}',
                    style: const TextStyle(
                        fontSize: 22,
                        color: Palette.gold,
                        fontWeight: FontWeight.bold)),
                const Text('龙息', style: TextStyle(fontSize: 11, color: Palette.gold)),
              ],
            ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- jugador

class _PlayerPanel extends StatelessWidget {
  const _PlayerPanel({required this.s, required this.delta, required this.deltaKey});

  final CombatState s;
  final int delta;
  final int deltaKey;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final p = s.player;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: StatBar(
                    label: t.life, value: p.hp, max: p.maxHp, color: Palette.jade),
              ),
              _FloatingDelta(value: delta, key: ValueKey('p$deltaKey')),
            ],
          ),
          const SizedBox(height: 4),
          StatBar(
            label: t.structure,
            value: p.structure,
            max: p.maxStructure,
            color: Palette.structure,
            height: 10,
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              for (final st in Stance.values)
                Expanded(child: _StanceChip(stance: st, active: st == p.stance)),
              const SizedBox(width: 6),
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                decoration: BoxDecoration(
                  color: p.guard > 0
                      ? Palette.sky.withValues(alpha: 0.25)
                      : Palette.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                      color: p.guard > 0 ? Palette.sky : Palette.line),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.shield, size: 16, color: Palette.sky),
                    const SizedBox(width: 4),
                    Text('${p.guard}',
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    if (p.guardHeight != null)
                      Icon(heightIcon(p.guardHeight), size: 14, color: Palette.sky),
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

class _StanceChip extends StatelessWidget {
  const _StanceChip({required this.stance, required this.active});

  final Stance stance;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final (name, hanzi) = stanceNames[stance]!;
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
          Text(hanzi,
              style: TextStyle(
                  fontSize: 15,
                  color: active ? Palette.onColor : Palette.textDim)),
          Text(name,
              style: TextStyle(
                  fontSize: 10,
                  color: active ? Palette.onColor : Palette.textDim)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------------ formas

class _FormsPanel extends StatelessWidget {
  const _FormsPanel({
    required this.s,
    required this.data,
    required this.view,
    required this.engine,
  });

  final CombatState s;
  final GameData data;
  final CombatView view;
  final CombatEngine engine;

  @override
  Widget build(BuildContext context) {
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
                    width: 64,
                    child: Text(f.hanzi,
                        style: const TextStyle(fontSize: 14, color: Palette.gold)),
                  ),
                  for (var i = 0; i < f.steps.length; i++)
                    Expanded(
                      child: _FormStep(
                        label: data.card(f.steps[i]).hanzi,
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
      margin: const EdgeInsets.only(right: 3),
      padding: const EdgeInsets.symmetric(vertical: 3),
      decoration: BoxDecoration(
        color: done ? Palette.gold.withValues(alpha: 0.8) : Palette.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
            color: next ? Palette.gold : Palette.line, width: next ? 2 : 1),
      ),
      alignment: Alignment.center,
      child: FittedBox(
        child: Text(label,
            style: TextStyle(
                fontSize: 11, color: done ? Palette.onColor : Palette.textDim)),
      ),
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
      if (p.damage > 0) '${p.damage} daño',
      if (p.structure > 0) '${p.structure} E',
      if (p.guard > 0) '${t.guard} ${p.guard} ${heightLabel(p.height)}',
      if (p.stanceAfter != s.player.stance) '→ ${stanceNames[p.stanceAfter]!.$1}',
    ];
    String formName(String id) => data.forms.firstWhere((f) => f.id == id).pinyin;
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
                  Text('${def.pinyin} · ${def.es}',
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w600)),
                  Text(
                    [
                      ...parts,
                      for (final f in p.completesForms) '¡completa ${formName(f)}!',
                      for (final f in p.advancesForms) 'avanza ${formName(f)}',
                      for (final f in p.interruptsForms) '⚠ interrumpe ${formName(f)}',
                    ].join(' · '),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Palette.textDim),
                  ),
                ],
              ),
            ),
            Text(p.playable ? t.tapAgain : (p.reason ?? ''),
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
      const cardW = 92.0;
      const cardH = cardW * 1.5;
      final n = hand.length;
      final avail = box.maxWidth - 24;
      final step = n <= 1
          ? 0.0
          : math.min(cardW + 6, (avail - cardW) / (n - 1));
      final total = n == 0 ? 0.0 : cardW + step * (n - 1);
      final left0 = (box.maxWidth - total) / 2;
      return SizedBox(
        height: cardH + 28,
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
              onPressed: canDingbu ? () => _pickStance(context, ctl, s) : null,
              style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4)),
              child: const Text('丁步 1', maxLines: 1),
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

  void _pickStance(BuildContext context, CombatController ctl, CombatState s) {
    final t = AppLocalizations.of(context);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text('${t.dingbu} 丁步 · 1 ${t.breath}',
                  style: const TextStyle(fontSize: 16)),
            ),
            for (final st in Stance.values)
              if (st != s.player.stance)
                ListTile(
                  leading: Text(stanceNames[st]!.$2,
                      style: const TextStyle(fontSize: 22)),
                  title: Text(stanceNames[st]!.$1),
                  subtitle: Text(_stanceHint(st)),
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

  String _stanceHint(Stance st) => switch (st) {
        Stance.mabu => 'Puños y palmas +2 · E recibida ½ · patadas +1 costo',
        Stance.gongbu => 'Puños +3 daño y +1 E · recibís +2 E',
        Stance.xubu => 'Patadas −1 costo y +2 · desvío +1 Aliento · defensas −2',
      };
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
        Text('气 $breath', style: const TextStyle(fontSize: 11, color: Palette.sky)),
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
  const _FloatingDelta({super.key, required this.value});

  final int value;

  @override
  Widget build(BuildContext context) {
    if (value <= 0) return const SizedBox(width: 40);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      builder: (_, v, _) => Opacity(
        opacity: 1 - v,
        child: Transform.translate(
          offset: Offset(0, -16 * v),
          child: SizedBox(
            width: 40,
            child: Text('−$value',
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Palette.lacquer)),
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
            Text(won ? '胜' : '败',
                style: TextStyle(
                    fontSize: 96, color: won ? Palette.gold : Palette.lacquer)),
            Text(won ? t.victory : t.defeat, style: const TextStyle(fontSize: 26)),
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
