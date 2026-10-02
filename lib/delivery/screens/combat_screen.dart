import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/combat_engine.dart';
import '../../domain/combat/combat_event.dart';
import '../../domain/combat/combat_state.dart';
import '../../domain/model/card_def.dart';
import '../../domain/model/enemy_def.dart';
import '../../domain/model/enums.dart';
import '../../domain/model/game_data.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../tutorial/illustrations.dart';
import '../tutorial/lessons.dart';
import '../tutorial/tutorial_anchor.dart';
import '../tutorial/tutorial_overlay.dart';
import '../widgets/card_widget.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/juice.dart';
import '../widgets/stat_bar.dart';

class CombatScreen extends ConsumerWidget {
  const CombatScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cada combate (o lección reiniciada) arranca con la pantalla de cero.
    final instance = ref.watch(
      combatControllerProvider.select((v) => v?.instance),
    );
    return _CombatBody(key: ValueKey(instance));
  }
}

class _CombatBody extends ConsumerStatefulWidget {
  const _CombatBody({super.key});

  @override
  ConsumerState<_CombatBody> createState() => _CombatScreenState();
}

class _Fx {
  const _Fx(this.title, this.subtitle, this.color, {this.big = false});
  final String title;
  final String? subtitle;
  final Color color;
  final bool big;
}

/// Número o texto que salta sobre un personaje.
class _Pop {
  _Pop(
    this.id,
    this.text,
    this.color, {
    this.size = 30,
    this.icon,
    this.dx = 0,
    this.dy = 0,
  });
  final int id;
  final String text;
  final Color color;
  final double size;
  final IconData? icon;
  final double dx;
  final double dy;
}

/// Efectos de la arena en un instante: qué se animó y qué números hay en vuelo.
class _ArenaFx {
  const _ArenaFx({
    this.hitKey = 0,
    this.heavy = false,
    this.attackKey = 0,
    this.pulseKey = 0,
    this.sparkKey = 0,
    this.burstKey = 0,
    this.strikeKey = 0,
    this.hurtKey = 0,
    this.guardKey = 0,
    this.deflectKey = 0,
    this.turnKey = 0,
    this.dying = false,
    this.victory = false,
    this.defeated = false,
    this.enemyPops = const [],
    this.heroPops = const [],
  });

  final int hitKey;
  final bool heavy;
  final int attackKey;
  final int pulseKey;
  final int sparkKey;
  final int burstKey;
  final int strikeKey;
  final int hurtKey;
  final int guardKey;
  final int deflectKey;
  final int turnKey;
  final bool dying;
  final bool victory;
  final bool defeated;
  final List<_Pop> enemyPops;
  final List<_Pop> heroPops;
}

class _CombatScreenState extends ConsumerState<_CombatBody> {
  final _queue = <_Fx>[];
  _Fx? _current;
  int _fxKey = 0;
  final _timers = <Timer>[];
  final _rnd = math.Random();
  final _enemyKey = GlobalKey();
  final _heroKey = GlobalKey();

  /// Lo que se ve en la arena. Va un paso detrás del estado real para que los
  /// números y las barras cambien cuando el golpe llega, no antes.
  CombatView? _shown;

  /// Mientras corre una secuencia (turno enemigo, remate) no se aceptan toques.
  bool _busy = false;

  /// Durante el turno enemigo la mano se descarta; solo quedan las retenidas.
  bool _hideHand = false;
  Set<int> _keep = const {};
  int? _playedUid;
  bool _endShown = false;

  int _hitKey = 0, _attackKey = 0, _pulseKey = 0, _sparkKey = 0, _burstKey = 0;
  int _strikeKey = 0,
      _hurtKey = 0,
      _guardKey = 0,
      _deflectKey = 0,
      _turnKey = 0;
  int _shakeKey = 0, _flashKey = 0, _formBurstKey = 0, _popId = 0;
  double _shakeStrength = 8;
  bool _heavy = false, _dying = false, _victory = false, _defeated = false;
  final _enemyPops = <_Pop>[];
  final _heroPops = <_Pop>[];

  GameAudio get _audio => ref.read(audioProvider);

  @override
  void initState() {
    super.initState();
    // Entrada: música según el rival, cae el enemigo, cartel y reparto.
    final live = ref.read(combatControllerProvider);
    if (live == null) return;
    final rank = ref.read(dataProvider).enemy(live.state.enemy.id).rank;
    _audio.music(
      live.tutorial
          ? Music.training
          : switch (rank) {
              EnemyRank.boss => Music.boss,
              EnemyRank.elite => Music.elite,
              _ => Music.combat,
            },
    );
    _after(120, () => _audio.play(Sfx.enemyDrop));
    _after(300, () => _audio.play(Sfx.fightStart));
    _dealSounds(450, live.state.hand.length);
  }

  /// Un "flic" por carta, al ritmo del reparto de la mano.
  void _dealSounds(int at, int cards) {
    for (var i = 0; i < cards; i++) {
      _after(at + 75 * i, () => _audio.play(Sfx.cardDeal));
    }
  }

  @override
  void dispose() {
    for (final t in _timers) {
      t.cancel();
    }
    super.dispose();
  }

  void _after(int ms, VoidCallback f) {
    _timers.add(
      Timer(Duration(milliseconds: ms), () {
        if (mounted) f();
      }),
    );
  }

  void _pop(
    List<_Pop> into,
    String text,
    Color color, {
    double size = 30,
    IconData? icon,
    double dx = 0,
    double dy = 0,
  }) {
    final p = _Pop(
      _popId++,
      text,
      color,
      size: size,
      icon: icon,
      dx: dx + (_rnd.nextDouble() - 0.5) * 24,
      dy: dy,
    );
    into.add(p);
    _after(1100, () => setState(() => into.remove(p)));
  }

  void _shake(double strength) {
    _shakeStrength = strength;
    _shakeKey++;
  }

  void _present(CombatView prev, CombatView next) {
    // La arena arranca mostrando el estado anterior y se pone al día en el impacto.
    _shown ??= prev;
    final ev = next.events;
    final enemyTurn = ev.any(
      (e) =>
          e is TurnStarted ||
          e is PlayerHit ||
          e is Deflected ||
          e is EnemyActionSkipped ||
          e is EnemyGuarded ||
          e is EnemyCharged,
    );
    if (enemyTurn) return _enemyTurn(prev, next);
    if (!ev.any((e) => e is CardPlayed)) {
      for (final e in ev) {
        switch (e) {
          case StanceChanged():
            _audio.play(Sfx.stanceChange);
          case CardsDrawn(:final count):
            _audio.play(Sfx.breathGain);
            _dealSounds(250, count);
          default:
        }
      }
      setState(() => _shown = next);
      _banners(ev);
      return;
    }
    // La carta vuela hacia su blanco; el golpe se ve cuando llega.
    final hits = ev.whereType<EnemyDamaged>().toList();
    setState(() {
      _playedUid = prev.selected;
      _busy = true;
      if (hits.isNotEmpty) _strikeKey++;
    });
    _audio.play(Sfx.cardPlay);
    _after(hits.isEmpty ? 150 : 240, () {
      _impactOnEnemy(next, ev);
      _banners(ev);
      if (ev.any((e) => e is Victory)) {
        _win();
      } else {
        setState(() => _busy = false);
      }
    });
  }

  void _impactOnEnemy(CombatView next, List<CombatEvent> ev) {
    final hits = ev.whereType<EnemyDamaged>();
    final dmg = hits.fold(0, (a, e) => a + e.damage);
    final str = hits.fold(0, (a, e) => a + e.structure);
    final absorbed = hits.fold(0, (a, e) => a + e.absorbed);
    final guard = ev.whereType<GuardGained>().fold(0, (a, e) => a + e.amount);
    final broken = ev.any((e) => e is EnemyBroken);
    final t = AppLocalizations.of(context);
    setState(() {
      _shown = next;
      if (hits.isNotEmpty) {
        _hitKey++;
        _sparkKey++;
        _heavy = dmg >= 10 || broken;
        if (dmg > 0) {
          _pop(_enemyPops, '−$dmg', Palette.lacquer, size: dmg >= 10 ? 42 : 34);
        }
        if (str > 0) {
          _pop(
            _enemyPops,
            '−$str',
            Palette.structure,
            size: 20,
            icon: Icons.hexagon_outlined,
            dx: 38,
            dy: 30,
          );
        }
        if (absorbed > 0) {
          _pop(
            _enemyPops,
            dmg == 0 ? t.blocked : '−$absorbed',
            Palette.sky,
            size: 18,
            icon: Icons.shield,
            dx: -40,
            dy: 26,
          );
        }
        if (_heavy) _shake(broken ? 14 : 9);
      }
      if (guard > 0) {
        _guardKey++;
        _pop(_heroPops, '+$guard', Palette.sky, size: 26, icon: Icons.shield);
      }
    });
    if (hits.isNotEmpty) {
      _heavy ? HapticFeedback.heavyImpact() : HapticFeedback.mediumImpact();
      _audio.play(
        _heavy
            ? Sfx.hitHeavy
            : dmg == 0
            ? Sfx.block
            : Sfx.hitLight,
      );
    } else if (guard > 0) {
      HapticFeedback.lightImpact();
    }
    if (guard > 0) _audio.play(Sfx.guardUp);
    if (ev.any((e) => e is StanceChanged)) _audio.play(Sfx.stanceChange);
  }

  void _enemyTurn(CombatView prev, CombatView next) {
    final ev = next.events;
    final t = AppLocalizations.of(context);
    final nowUids = {for (final c in next.state.hand) c.uid};
    setState(() {
      _busy = true;
      _hideHand = true;
      _playedUid = null;
      _keep = {
        for (final c in prev.state.hand)
          if (nowUids.contains(c.uid)) c.uid,
      };
    });

    // 1. La mano se descarta. 2. El enemigo actúa. 3. Se reparte la mano nueva.
    var at = 300;
    final outcomes = ev.where((e) => e is PlayerHit || e is Deflected).toList();
    if (outcomes.isNotEmpty) {
      _after(at, () {
        setState(() => _attackKey++);
        _audio.play(Sfx.enemyWindup);
        _audio.voice(next.state.enemy.id);
      });
      at += EnemySprite.impactDelay.inMilliseconds;
      for (final (i, o) in outcomes.indexed) {
        final last = i == outcomes.length - 1;
        _after(at + i * 240, () {
          setState(() {
            _shown = next;
            switch (o) {
              case PlayerHit(:final damage, :final structure, :final blocked):
                _hurtKey++;
                if (damage > 0) {
                  _flashKey++;
                  _pop(
                    _heroPops,
                    '−$damage',
                    Palette.lacquer,
                    size: damage >= 10 ? 42 : 34,
                  );
                } else if (blocked) {
                  _pop(
                    _heroPops,
                    t.blocked,
                    Palette.sky,
                    size: 22,
                    icon: Icons.shield,
                  );
                }
                if (structure > 0) {
                  _pop(
                    _heroPops,
                    '−$structure',
                    Palette.structure,
                    size: 20,
                    icon: Icons.hexagon_outlined,
                    dx: 44,
                    dy: 30,
                  );
                }
                _shake(damage == 0 ? 4 : math.min(16, 6 + damage * 0.6));
                damage >= 8
                    ? HapticFeedback.heavyImpact()
                    : HapticFeedback.mediumImpact();
                _audio.play(damage > 0 ? Sfx.playerHurt : Sfx.block);
              case Deflected():
                _audio.play(Sfx.deflect);
                _deflectKey++;
                _shake(5);
              default:
            }
          });
          if (last) _banners(ev);
        });
      }
      at += (outcomes.length - 1) * 240 + 450;
    } else {
      // Guardia, carga o turno perdido: el enemigo se infla o tambalea.
      _after(at, () {
        setState(() {
          _shown = next;
          for (final e in ev) {
            switch (e) {
              case EnemyGuarded(:final amount):
                _audio.play(Sfx.enemyGuard);
                _pulseKey++;
                _pop(
                  _enemyPops,
                  '+$amount',
                  Palette.sky,
                  size: 26,
                  icon: Icons.shield,
                );
              case EnemyCharged(:final amount):
                _audio.play(Sfx.enemyCharge);
                _pulseKey++;
                _pop(
                  _enemyPops,
                  '+$amount',
                  Palette.gold,
                  size: 26,
                  icon: Icons.bolt,
                );
              case EnemyActionSkipped():
                _audio.play(Sfx.enemySkip);
                _pop(_enemyPops, t.losesAction, Palette.gold, size: 18);
              default:
            }
          }
        });
        HapticFeedback.lightImpact();
        _banners(ev);
      });
      at += 650;
    }

    if (ev.any((e) => e is Defeat)) {
      _after(at - 300, _lose);
      return;
    }
    _after(at, () {
      setState(() {
        _hideHand = false;
        _turnKey++;
      });
      HapticFeedback.selectionClick();
      _audio.play(Sfx.turnStart);
    });
    _dealSounds(at + 320, next.state.hand.length);
    _after(
      at + 70 * next.state.hand.length + 320,
      () => setState(() => _busy = false),
    );
  }

  void _win() {
    HapticFeedback.heavyImpact();
    _audio.play(Sfx.enemyDeath);
    setState(() {
      _queue.clear();
      _current = null;
      _dying = true;
      _burstKey++;
      _shake(16);
    });
    _after(450, () {
      setState(() => _victory = true);
      _audio.play(Sfx.heroVictory);
    });
    _after(1150, () {
      HapticFeedback.mediumImpact();
      _audio.jingle(Music.victory);
      setState(() => _endShown = true);
    });
  }

  void _lose() {
    HapticFeedback.heavyImpact();
    _audio.play(Sfx.heroFall);
    setState(() {
      _queue.clear();
      _current = null;
      _defeated = true;
      _flashKey++;
      _shake(18);
    });
    _after(1500, () {
      setState(() => _endShown = true);
      _audio.jingle(Music.defeat);
    });
  }

  void _banners(List<CombatEvent> events) {
    final data = ref.read(dataProvider);
    final text = ref.read(textProvider);
    final t = AppLocalizations.of(context);
    for (final e in events) {
      switch (e) {
        case Deflected():
          HapticFeedback.mediumImpact();
          _queue.add(_Fx(t.deflect, '化', Palette.sky));
        case EnemyBroken():
          HapticFeedback.heavyImpact();
          _audio.play(Sfx.broken);
          _queue.add(_Fx(t.broken, t.staggeredDouble, Palette.gold));
        case ScaleShed(:final remaining):
          _queue.add(_Fx(t.scaleShed, t.scalesLeft(remaining), Palette.jade));
        case PlayerBroken():
          HapticFeedback.heavyImpact();
          _queue.add(_Fx(t.playerBroken, '−2 ${t.breath}', Palette.lacquer));
        case FormAdvanced(:final progress):
          _audio.play(Sfx.formStep, variant: progress - 1);
        case FormInterrupted():
          _audio.play(Sfx.formBroken);
        case FormCompleted(:final formId):
          HapticFeedback.heavyImpact();
          _audio.play(Sfx.formComplete);
          _formBurstKey++;
          final f = data.forms.firstWhere((f) => f.id == formId);
          _queue.add(
            _Fx(
              text.form(f.id),
              '${f.hanzi} · ${f.pinyin}',
              Palette.lacquer,
              big: true,
            ),
          );
        case FormsResetByEnemy():
          _audio.play(Sfx.formBroken);
          _queue.add(_Fx(t.formsInterrupted, null, Palette.textDim));
        case EnemyPhaseChanged(:final phase):
          HapticFeedback.heavyImpact();
          _audio.play(Sfx.phaseTwo);
          _shake(phase >= 2 ? 18 : 14);
          _queue.add(
            _Fx(
              phase >= 2 ? t.enemyPhase3 : t.enemyPhase2,
              null,
              phase >= 2 ? Palette.lacquer : Palette.gold,
              big: true,
            ),
          );
        case ScalesRegrown(:final scales):
          HapticFeedback.mediumImpact();
          _audio.play(Sfx.enemyGuard);
          _queue.add(_Fx(t.scalesRegrown, t.scalesNow(scales), Palette.jade));
        default:
      }
    }
    if (events.any((e) => e is Victory || e is Defeat)) _queue.clear();
    _pump();
  }

  void _pump() {
    if (_current != null || _queue.isEmpty) return;
    setState(() {
      _current = _queue.removeAt(0);
      _fxKey++;
    });
    _after(_current!.big ? 1400 : 950, () {
      setState(() => _current = null);
      _pump();
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(combatControllerProvider, (prev, next) {
      if (prev != null && next != null && next.seq != prev.seq) {
        _present(prev, next);
      }
    });
    final live = ref.watch(combatControllerProvider);
    if (live == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final data = ref.watch(dataProvider);
    final engine = ref.watch(combatEngineProvider);
    final shown = _shown ?? live;
    final s = shown.state;
    final hand = _hideHand
        ? [
            for (final c in live.state.hand)
              if (_keep.contains(c.uid)) c,
          ]
        : live.state.hand;
    final fx = _ArenaFx(
      hitKey: _hitKey,
      heavy: _heavy,
      attackKey: _attackKey,
      pulseKey: _pulseKey,
      sparkKey: _sparkKey,
      burstKey: _burstKey,
      strikeKey: _strikeKey,
      hurtKey: _hurtKey,
      guardKey: _guardKey,
      deflectKey: _deflectKey,
      turnKey: _turnKey,
      dying: _dying,
      victory: _victory,
      defeated: _defeated,
      enemyPops: _enemyPops,
      heroPops: _heroPops,
    );

    final column = Column(
      children: [
        Expanded(
          child: _Arena(
            stageId: data.balance.stage.id,
            turn: s.turn,
            style: live.tutorial
                ? null
                : ref.watch(runControllerProvider)?.style,
            fx: fx,
            heroKey: _heroKey,
            introTitle: ref.watch(textProvider).enemy(s.enemy.id),
            // Hoy hay un solo enemigo; la arena ya acepta varios.
            slots: [
              _EnemySlot(
                def: data.enemy(s.enemy.id),
                enemy: s.enemy,
                intent: engine.intentView(s),
                key: _enemyKey,
              ),
            ],
          ),
        ),
        TutorialAnchor(
          id: 'player',
          child: _PlayerStrip(s: s),
        ),
        TutorialAnchor(
          id: 'forms',
          child: _FormsPanel(s: s, data: data),
        ),
        IgnorePointer(
          ignoring: _busy,
          child: Column(
            children: [
              TutorialAnchor(
                id: 'preview',
                child: _PreviewPanel(view: live, data: data, engine: engine),
              ),
              TutorialAnchor(
                id: 'hand',
                child: _HandArea(
                  view: live,
                  hand: hand,
                  data: data,
                  engine: engine,
                  playedUid: _playedUid,
                  enemyKey: _enemyKey,
                  heroKey: _heroKey,
                ),
              ),
              TutorialAnchor(
                id: 'actions',
                child: _ActionBar(
                  view: live,
                  engine: engine,
                  data: data,
                  locked: _busy,
                ),
              ),
            ],
          ),
        ),
      ],
    );

    final won = live.state.phase == CombatPhase.won;
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // Al perder, la escena se apaga hacia el gris del papel.
            TweenAnimationBuilder<double>(
              tween: Tween(end: _defeated ? 0.2 : 1),
              duration: const Duration(milliseconds: 1400),
              curve: Curves.easeOut,
              child: Shake(
                trigger: _shakeKey,
                strength: _shakeStrength,
                child: column,
              ),
              builder: (_, sat, child) => sat >= 1
                  ? child!
                  : ColorFiltered(
                      colorFilter: ColorFilter.matrix(saturationMatrix(sat)),
                      child: child,
                    ),
            ),
            Positioned.fill(
              child: ScreenFlash(trigger: _flashKey, color: Palette.lacquer),
            ),
            Positioned.fill(
              child: InkBurst(
                trigger: _formBurstKey,
                colors: const [Palette.gold, Palette.lacquer, Palette.gold],
                count: 36,
                radius: 190,
                duration: const Duration(milliseconds: 1000),
              ),
            ),
            if (_current != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: _FxBanner(key: ValueKey(_fxKey), fx: _current!),
                ),
              ),
            if (_endShown)
              _EndOverlay(
                won: won,
                lessonId: live.lessonId,
                turns: live.state.turn,
                hp: live.state.player.hp,
                maxHp: live.state.player.maxHp,
                enemyName: ref.watch(textProvider).enemy(live.state.enemy.id),
                enemyHp: live.state.enemy.hp,
              ),
            // Con key: los banners de arriba entran y salen sin reiniciar la guía.
            if (live.tutorial)
              const Positioned.fill(
                key: ValueKey('tutorial'),
                child: TutorialOverlay(),
              ),
            // Encima de la guía: siempre se puede pausar y salir.
            if (!_endShown)
              Positioned(
                top: 4,
                right: 8,
                child: _PauseButton(lessonId: live.lessonId),
              ),
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
    required this.key,
  });

  final EnemyDef def;
  final EnemyCombat enemy;
  final IntentView intent;

  /// Marca dónde está la figura, para que las cartas vuelen hacia ella.
  final GlobalKey key;
}

/// Escenario del combate: fondo de la etapa, suelo, los enemigos al frente y
/// el héroe de espaldas en primer plano.
class _Arena extends StatelessWidget {
  const _Arena({
    required this.stageId,
    required this.turn,
    required this.style,
    required this.fx,
    required this.heroKey,
    required this.introTitle,
    required this.slots,
  });

  final String stageId;
  final int turn;
  final Style? style;
  final _ArenaFx fx;
  final GlobalKey heroKey;
  final String introTitle;
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
      child: LayoutBuilder(
        builder: (context, box) {
          final heroH = math.min(box.maxHeight * 0.62, box.maxWidth * 0.54);
          final heroW = heroH * 2 / 3;
          final heroLeft = -heroW * 0.12;
          final heroBottom = -heroH * 0.12;
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
                      borderRadius: const BorderRadius.all(
                        Radius.elliptical(200, 34),
                      ),
                      gradient: RadialGradient(
                        colors: [
                          Palette.text.withValues(alpha: 0.22),
                          Palette.text.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 12,
                top: 8,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TutorialAnchor(
                      id: 'turn',
                      child: Bounce(
                        trigger: turn,
                        child: _Chip(
                          icon: Icons.hourglass_bottom,
                          text: t.turn(turn),
                          color: Palette.text,
                        ),
                      ),
                    ),
                    if (style != null) ...[
                      const SizedBox(height: 6),
                      _StyleChip(style: style!),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(heroW * 0.8, 8, 16, 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    for (final slot in slots)
                      Expanded(
                        child: _EnemyStage(slot: slot, fx: fx),
                      ),
                  ],
                ),
              ),
              // Héroe de espaldas, cortado por el borde inferior.
              Positioned(
                left: heroLeft,
                bottom: heroBottom,
                child: IgnorePointer(
                  child: HeroSprite(
                    key: heroKey,
                    style: style,
                    height: heroH,
                    strikeKey: fx.strikeKey,
                    hurtKey: fx.hurtKey,
                    guardKey: fx.guardKey,
                    victory: fx.victory,
                    defeated: fx.defeated,
                  ),
                ),
              ),
              // Desvío: destello de jade sobre el héroe.
              Positioned(
                left: heroLeft,
                bottom: heroBottom + heroH * 0.25,
                width: heroW,
                height: heroH * 0.6,
                child: InkBurst(
                  trigger: fx.deflectKey,
                  colors: const [Palette.jade, Palette.sky, Colors.white],
                  count: 18,
                  radius: heroW * 0.6,
                ),
              ),
              // Números sobre el héroe.
              Positioned(
                left: heroLeft + heroW * 0.62,
                bottom: heroBottom + heroH * 0.62,
                child: IgnorePointer(child: _PopStack(pops: fx.heroPops)),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: fx.turnKey == 0
                      ? _Ribbon(
                          title: introTitle,
                          subtitle: t.fightStart,
                          delayMs: 250,
                        )
                      : _Ribbon(
                          key: ValueKey(fx.turnKey),
                          title: t.yourTurn,
                          subtitle: t.turn(turn),
                        ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Números en vuelo, cada uno con su desplazamiento.
class _PopStack extends StatelessWidget {
  const _PopStack({required this.pops});

  final List<_Pop> pops;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      height: 0,
      child: OverflowBox(
        maxWidth: 240,
        maxHeight: 200,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final p in pops)
              Transform.translate(
                key: ValueKey(p.id),
                offset: Offset(p.dx, p.dy),
                child: PopText(
                  text: p.text,
                  color: p.color,
                  size: p.size,
                  icon: p.icon,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cartel que cruza la arena: presentación del enemigo o "Tu turno".
class _Ribbon extends StatefulWidget {
  const _Ribbon({
    super.key,
    required this.title,
    required this.subtitle,
    this.delayMs = 0,
  });

  final String title;
  final String subtitle;
  final int delayMs;

  @override
  State<_Ribbon> createState() => _RibbonState();
}

class _RibbonState extends State<_Ribbon> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1250 + widget.delayMs),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.delayMs / (1250 + widget.delayMs);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final raw = _c.value;
        if (raw <= start || raw >= 1) return const SizedBox();
        final v = (raw - start) / (1 - start);
        final w = MediaQuery.sizeOf(context).width;
        final inT = Curves.easeOutCubic.transform(math.min(1, v / 0.22));
        final outT = v < 0.8
            ? 0.0
            : Curves.easeInCubic.transform((v - 0.8) / 0.2);
        final dx = -w * (1 - inT) + w * outT;
        return Align(
          alignment: const Alignment(0, -0.05),
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Palette.surface.withValues(alpha: 0),
                    Palette.surface.withValues(alpha: 0.94),
                    Palette.surface.withValues(alpha: 0.94),
                    Palette.surface.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.2, 0.8, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: Palette.lacquer,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EnemyStage extends ConsumerWidget {
  const _EnemyStage({required this.slot, required this.fx});

  final _EnemySlot slot;
  final _ArenaFx fx;

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
        TutorialAnchor(
          id: 'intent',
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 280),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, a) => ScaleTransition(
              scale: a,
              child: FadeTransition(opacity: a, child: child),
            ),
            child: fx.dying
                ? const SizedBox(key: ValueKey('none'), height: 50)
                : _IntentBubble(
                    key: ValueKey('${e.patternIndex}-${e.phaseIndex}'),
                    iv: slot.intent,
                  ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final size = math.min(box.maxHeight, 220.0);
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  _Entrance(
                    child: EnemySprite(
                      key: slot.key,
                      def: def,
                      staggered: e.staggered,
                      hitKey: fx.hitKey,
                      attackKey: fx.attackKey,
                      pulseKey: fx.pulseKey,
                      heavyHit: fx.heavy,
                      dying: fx.dying,
                      size: size,
                    ),
                  ),
                  // Chispas de cada golpe y estallido final.
                  Positioned.fill(
                    child: InkBurst(
                      trigger: fx.sparkKey,
                      colors: [Colors.white, Palette.gold, accent],
                      count: 12,
                      radius: size * 0.45,
                      duration: const Duration(milliseconds: 420),
                    ),
                  ),
                  Positioned.fill(
                    child: InkBurst(
                      trigger: fx.burstKey,
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
                    child: IgnorePointer(child: _PopStack(pops: fx.enemyPops)),
                  ),
                ],
              );
            },
          ),
        ),
        TutorialAnchor(
          id: 'enemyInfo',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                    boxShadow: [
                      BoxShadow(
                        color: accent.withValues(alpha: 0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Flexible(
                        child: Text(
                          text.enemy(def.id),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Palette.onColor,
                          ),
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
                      const TutorialAnchor(
                        id: 'enemyRule',
                        child: Icon(
                          Icons.info_outline,
                          size: 16,
                          color: Palette.onColor,
                        ),
                      ),
                    ],
                  ),
                ),
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
        AnimatedSize(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: e.guard > 0 || e.staggered || e.scales > 0
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
                            text: '${t.guard} ${e.guard}',
                            color: Palette.sky,
                          ),
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
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(text.enemy(def.id)),
                              content: Text(text.enemyRule(def.id)),
                            ),
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
                    ],
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Entrada del enemigo al empezar el combate: cae desde arriba y se asienta.
class _Entrance extends StatefulWidget {
  const _Entrance({required this.child});

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
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Expanded(
          child: TrailBar(
            ratio: ratio,
            color: color,
            height: height,
            background: Palette.surface.withValues(alpha: 0.8),
          ),
        ),
        SizedBox(
          width: 46,
          child: Text(
            '$value/$max',
            textAlign: TextAlign.right,
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

/// Globo de intención sobre la cabeza del enemigo.
class _IntentBubble extends ConsumerWidget {
  const _IntentBubble({super.key, required this.iv});

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
      IntentKind.guard => (
        Icons.shield,
        named ?? t.guard,
        '${t.guard} ${i.value}',
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
                    Text(
                      title,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        decoration: iv.skipped
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    Text(
                      iv.skipped ? t.losesAction : detail,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: iv.skipped ? Palette.gold : Palette.lacquer,
                      ),
                    ),
                    if (i.interrupt)
                      Text(
                        t.intentInterrupt,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Palette.textDim,
                        ),
                      ),
                    if (iv.punishIfSameStance)
                      Text(
                        t.intentSameStance,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Palette.textDim,
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
                        fontSize: 20,
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
                          Icon(
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
                          f.hanzi,
                          style: const TextStyle(
                            fontSize: 9,
                            color: Palette.textDim,
                          ),
                        ),
                      ],
                    ),
                  ),
                  for (var i = 0; i < f.steps.length; i++)
                    Expanded(
                      child: Bounce(
                        trigger: i < s.formProgress[f.id]!,
                        scale: 1.15,
                        child: _FormStep(
                          label: text.card(f.steps[i]),
                          done: i < s.formProgress[f.id]!,
                          next: i == s.formProgress[f.id]!,
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

class _FormStep extends StatelessWidget {
  const _FormStep({
    required this.label,
    required this.done,
    required this.next,
  });

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
          color: next ? Palette.gold : Palette.line,
          width: next ? 2 : 1,
        ),
      ),
      alignment: Alignment.center,
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
    );
  }
}

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
    final parts = <String>[
      if (p.damage > 0) t.previewDamage(p.damage),
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
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    [
                      ...parts,
                      for (final f in p.completesForms)
                        t.previewCompletes(formName(f)),
                      for (final f in p.advancesForms)
                        t.previewAdvances(formName(f)),
                      for (final f in p.interruptsForms)
                        t.previewInterrupts(formName(f)),
                    ].join(' · '),
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
  });

  final CombatView view;
  final List<CombatCard> hand;
  final GameData data;
  final CombatEngine engine;

  /// La carta recién jugada vuela hacia su blanco en vez de descartarse.
  final int? playedUid;
  final GlobalKey enemyKey;
  final GlobalKey heroKey;

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
  });
  final int id;
  final CombatCard card;
  final Offset pos;
  final double angle;
  final double width;
  final Offset? target;

  /// Escala con la que arranca (la jugada sale agrandada).
  final double scale;
}

/// Posición de cada carta en el abanico.
class _Fan {
  _Fan(this.n, double width) {
    final avail = width - 24;
    w = n == 0 ? 92.0 : ((avail - 4 * (n - 1)) / n).clamp(66.0, 92.0);
    step = n <= 1 ? 0.0 : math.min(w + 6, (avail - w) / (n - 1));
    final total = n == 0 ? 0.0 : w + step * (n - 1);
    left0 = (width - total) / 2;
  }

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
  static const zoom = 1.35;

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
        ),
      );
    }
  }

  /// Centro del enemigo (ataques) o del héroe (defensas), en coordenadas de la mano.
  Offset? _targetFor(CombatCard c, double w) {
    final def = widget.data.card(c.cardId);
    final toHero = !def.type.isAttack && def.damage == 0;
    final key = toHero ? widget.heroKey : widget.enemyKey;
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
          height: 92 * 1.5 + 28, // fija: la arena no salta al cambiar la mano
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
                      HapticFeedback.heavyImpact();
                      ref.read(audioProvider).play(Sfx.cardDeny);
                      setState(() {
                        _denyUid = c.uid;
                        _denyKey++;
                      });
                    } else {
                      HapticFeedback.selectionClick();
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

/// Entrada de una carta repartida: sale del mazo (abajo a la izquierda) y se
/// acomoda con un pequeño rebote. Sin [delayMs] aparece sin animar.
class _DealIn extends StatefulWidget {
  const _DealIn({
    required this.delayMs,
    required this.from,
    required this.child,
  });

  final int? delayMs;
  final Offset from;
  final Widget child;

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

  @override
  Widget build(BuildContext context) {
    final start = (widget.delayMs ?? 0) / (_fly + (widget.delayMs ?? 0));
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        if (_c.value >= 1) return child!;
        final raw = _c.value <= start ? 0.0 : (_c.value - start) / (1 - start);
        final v = Curves.easeOutBack.transform(raw);
        return Opacity(
          opacity: math.min(1, raw * 3),
          child: Transform.translate(
            offset: widget.from * (1 - v),
            child: Transform.rotate(angle: -0.5 * (1 - v), child: child),
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
            milliseconds: widget.leaving.target == null ? 320 : 260,
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
        child: CardWidget(
          def: widget.def,
          upgrades: l.card.upgrades,
          width: l.width,
        ),
      ),
    );
  }
}

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
        !busy && !s.dingbuUsed && s.player.breath >= data.transition.cost;
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
                child: FittedBox(child: Text(text.dingbu(), maxLines: 1)),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TutorialAnchor(
              id: 'breathe',
              child: OutlinedButton(
                onPressed: !busy && s.breathesLeft > 0 ? ctl.breathe : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: Text(t.breathe, maxLines: 1),
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
        Text(
          '${AppLocalizations.of(context).breath} $breath',
          style: const TextStyle(fontSize: 10, color: Palette.sky),
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
    HapticFeedback.selectionClick();
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
    final stats = ref.watch(dataProvider).balance.styles[widget.style]!;
    final color = styleColor(widget.style);
    final edge = stats.retain > 0
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
                    child: Text(
                      t.styleBenefit(widget.style),
                      style: const TextStyle(
                        fontSize: 12,
                        height: 1.25,
                        color: Palette.text,
                      ),
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
        Icon(icon, size: 13, color: color),
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

/// Cartel de un efecto importante: una franja de color entra barriendo, el
/// título salta y todo sale hacia el otro lado.
class _FxBanner extends StatelessWidget {
  const _FxBanner({super.key, required this.fx});

  final _Fx fx;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: fx.big ? 1400 : 950),
      builder: (_, v, _) {
        final inT = Curves.easeOutCubic.transform(math.min(1, v / 0.18));
        final outT = v < 0.82
            ? 0.0
            : Curves.easeInCubic.transform((v - 0.82) / 0.18);
        final pop = v < 0.1
            ? 0.6
            : 0.6 +
                  0.4 *
                      Curves.easeOutBack.transform(
                        math.min(1, (v - 0.1) / 0.2),
                      );
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Palette.surface.withValues(
                  alpha: 0.35 * inT * (1 - outT),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.2),
              child: Transform.translate(
                offset: Offset(-w * (1 - inT) + w * outT, 0),
                child: Transform(
                  transform: Matrix4.skewX(-0.12),
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: fx.big ? 18 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fx.color.withValues(alpha: 0),
                          fx.color.withValues(alpha: 0.95),
                          fx.color.withValues(alpha: 0.95),
                          fx.color.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.15, 0.85, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: fx.color.withValues(alpha: 0.35),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: pop,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            fx.title,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: fx.big ? 44 : 34,
                              fontWeight: FontWeight.w900,
                              color: Palette.onColor,
                              shadows: [
                                Shadow(
                                  color: fx.color.withValues(alpha: 0.9),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                          ),
                          if (fx.subtitle != null)
                            Text(
                              fx.subtitle!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Palette.onColor,
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Cierre del combate. Victoria: rayos dorados, título que cae como un golpe
/// y el sello rojo 胜. Derrota: todo más lento, en gris, con el sello 败.
class _EndOverlay extends ConsumerStatefulWidget {
  const _EndOverlay({
    required this.won,
    required this.lessonId,
    required this.turns,
    required this.hp,
    required this.maxHp,
    required this.enemyName,
    required this.enemyHp,
  });

  final bool won;

  /// En una lección: botones para seguir, reintentar o volver a la lista.
  final String? lessonId;
  final int turns;
  final int hp;
  final int maxHp;
  final String enemyName;
  final int enemyHp;

  @override
  ConsumerState<_EndOverlay> createState() => _EndOverlayState();
}

class _EndOverlayState extends ConsumerState<_EndOverlay>
    with TickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.won ? 1700 : 2100),
        )
        ..addListener(_onTick)
        ..forward();
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  static const _sealAt = 0.52;
  bool _sealed = false;
  int _sealKey = 0;

  @override
  void initState() {
    super.initState();
    final id = widget.lessonId;
    if (id != null && widget.won) {
      ref.read(tutorialStorageProvider).markDone(id).then((_) {
        if (mounted) ref.invalidate(lessonsDoneProvider);
      });
    }
  }

  void _onTick() {
    if (!_sealed && _c.value >= _sealAt) {
      _sealed = true;
      HapticFeedback.heavyImpact();
      ref
          .read(audioProvider)
          .play(widget.won ? Sfx.victoryStamp : Sfx.defeatStamp);
      if (widget.won) ref.read(audioProvider).play(Sfx.endRays);
      setState(() => _sealKey++);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _span(double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final won = widget.won;
    final accent = won ? Palette.gold : Palette.lacquer;
    final seal = won
        ? Palette.lacquer
        : Color.lerp(Palette.lacquer, Palette.textDim, 0.55)!;
    final lesson = widget.lessonId == null
        ? null
        : lessonById(widget.lessonId!);
    final next = lesson == null ? null : nextLesson(lesson.id);
    final String summaryText = switch ((lesson, won)) {
      (null, true) => t.endSummaryWon(widget.turns, widget.hp, widget.maxHp),
      (null, false) => t.endSummaryLost(widget.enemyName, widget.enemyHp),
      (final l?, true) => l.done!(t),
      (_?, false) => t.lessonLostHint,
    };
    final (String label, VoidCallback onPressed) = switch ((lesson, won)) {
      (null, _) => (t.continueLabel, _continue),
      (_?, true) when next != null => (
        t.lessonNext,
        () => _openLesson(next.id),
      ),
      (_?, true) => (t.lessonBackToList, _toLessons),
      (final l?, false) => (t.lessonRetry, () => _openLesson(l.id)),
    };
    final secondary = lesson != null && !(won && next == null);
    return Positioned.fill(
      child: AnimatedBuilder(
        animation: Listenable.merge([_c, _loop]),
        builder: (context, _) {
          final veil = _span(0, 0.25, Curves.easeOut);
          // El título cae desde grande, como un golpe sobre el papel.
          final title = _span(0.12, 0.4, Curves.easeInCubic);
          final settle = _span(0.4, 0.55, Curves.easeOutBack);
          final sealIn = _span(0.38, _sealAt, Curves.easeInCubic);
          final summary = _span(0.62, 0.82, Curves.easeOutCubic);
          final button = _span(0.78, 1, Curves.easeOutBack);
          return Container(
            color: Palette.surface.withValues(alpha: 0.9 * veil),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (won)
                  Opacity(
                    opacity: veil,
                    child: Transform.rotate(
                      angle: _loop.value * math.pi * 2,
                      child: Transform.scale(
                        scale: 0.4 + 0.6 * _span(0.1, 0.5, Curves.easeOutCubic),
                        child: CustomPaint(
                          size: const Size(520, 520),
                          painter: _RaysPainter(),
                        ),
                      ),
                    ),
                  ),
                if (won)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PetalsPainter(t: _loop.value, fade: summary),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Opacity(
                            opacity: title,
                            child: Transform.scale(
                              scale:
                                  2.6 -
                                  1.6 * title +
                                  0.06 * math.sin(math.pi * settle),
                              child: Text(
                                won ? t.victory : t.defeat,
                                style: TextStyle(
                                  fontSize: 54,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: accent,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.white,
                                      blurRadius: 12,
                                    ),
                                    Shadow(
                                      color: accent.withValues(alpha: 0.5),
                                      blurRadius: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Sello de tinta roja, como el de un pergamino.
                          Positioned(
                            right: -62,
                            bottom: 10,
                            child: Opacity(
                              opacity: sealIn,
                              child: Transform.rotate(
                                angle: -0.12,
                                child: Transform.scale(
                                  scale: 3 - 2 * sealIn,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: seal,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Palette.onColor,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: seal.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      won ? '胜' : '败',
                                      style: const TextStyle(
                                        fontSize: 32,
                                        height: 1,
                                        color: Palette.onColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -102,
                            bottom: -30,
                            width: 136,
                            height: 136,
                            child: InkBurst(
                              trigger: _sealKey,
                              colors: [seal, accent],
                              count: 16,
                              radius: 70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: summary,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - summary)),
                        child: Text(
                          summaryText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textDim,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: button.clamp(0, 1),
                      child: Transform.scale(
                        scale: 0.8 + 0.2 * button,
                        child: IgnorePointer(
                          ignoring: button < 0.5,
                          child: SizedBox(
                            width: 220,
                            height: 52,
                            child: FilledButton(
                              onPressed: onPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: won
                                    ? Palette.gold
                                    : Palette.lacquer,
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (secondary)
                      Opacity(
                        opacity: button.clamp(0, 1),
                        child: IgnorePointer(
                          ignoring: button < 0.5,
                          child: TextButton(
                            onPressed: _toLessons,
                            child: Text(
                              t.lessonBackToList,
                              style: const TextStyle(color: Palette.textDim),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Abre una lección: las de combate reinician esta pantalla, la de la
  /// subida es otra pantalla.
  void _openLesson(String id) {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    final ctl = ref.read(combatControllerProvider.notifier)..finish();
    if (lessonById(id).isCombat) {
      ctl.startLesson(id);
    } else {
      context.go('/lessons/climb');
    }
  }

  void _toLessons() {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    context.go('/lessons');
  }

  void _continue() {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    final run = ref.read(runControllerProvider)!;
    context.go(switch (run.phase) {
      RunPhase.reward => '/reward',
      RunPhase.victory || RunPhase.defeat => '/result',
      _ => '/map',
    });
  }
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Palette.gold.withValues(alpha: 0.26),
          Palette.gold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(a - 0.09) * r, c.dy + math.sin(a - 0.09) * r)
          ..lineTo(c.dx + math.cos(a + 0.09) * r, c.dy + math.sin(a + 0.09) * r)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => false;
}

/// Pétalos dorados y bermellón que caen en loop detrás de la victoria.
class _PetalsPainter extends CustomPainter {
  _PetalsPainter({required this.t, required this.fade});

  final double t;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (fade == 0) return;
    final rnd = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final phase = rnd.nextDouble();
      final y = ((t * 6 * speed + phase) % 1) * (size.height + 40) - 20;
      final x = x0 + math.sin((t * 12 + phase) * math.pi * 2) * 18;
      final color = i.isEven ? Palette.gold : Palette.lacquer;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((t * 20 + phase) * math.pi * 2 * (i.isEven ? 1 : -1));
      canvas.drawOval(
        const Rect.fromLTWH(-5, -2.5, 10, 5),
        Paint()..color = color.withValues(alpha: 0.7 * fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter old) => old.t != t || old.fade != fade;
}

/// Pausa: seguir, repasar las reglas o salir (la subida queda guardada).
class _PauseButton extends ConsumerWidget {
  const _PauseButton({required this.lessonId});

  final String? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Material(
      color: Palette.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(side: BorderSide(color: Palette.line)),
      child: IconButton(
        tooltip: t.pauseTitle,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.pause_rounded, color: Palette.text),
        onPressed: () {
          HapticFeedback.selectionClick();
          ref.read(audioProvider).play(Sfx.uiButton);
          _open(context, ref);
        },
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ctl = ref.read(combatControllerProvider.notifier);
    final lesson = lessonId;
    // El combate queda como está: el próximo que empiece lo reemplaza, y así
    // la pantalla no se vacía mientras se desvanece.
    void leave(String route) {
      Navigator.pop(context);
      ref.invalidate(savedRunProvider);
      context.go(route);
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.pauseTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    t.pauseResume,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Palette.surface,
                  builder: (_) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.85,
                    maxChildSize: 0.95,
                    builder: (_, scroll) => PrimaryScrollController(
                      controller: scroll,
                      child: const HowToPlay(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(t.pauseHowTo),
              ),
              const SizedBox(height: 8),
              if (lesson == null) ...[
                OutlinedButton.icon(
                  onPressed: () => leave('/'),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(t.pauseToMenu),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                  child: Text(
                    t.pauseToMenuHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctl.startLesson(lesson);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(t.pauseRestartLesson),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => leave('/lessons'),
                  icon: const Icon(Icons.school_rounded),
                  label: Text(t.pauseExitLesson),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
