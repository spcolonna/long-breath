import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/combat/combat_action.dart';
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
import '../../domain/run/ghost.dart';
import '../foe_name.dart';
import '../providers.dart';
import '../theme.dart';
import '../tutorial/illustrations.dart';
import '../tutorial/lessons.dart';
import '../tutorial/tutorial_anchor.dart';
import '../tutorial/tutorial_overlay.dart';
import '../widgets/card_widget.dart';
import '../widgets/cinematic.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/game_icon.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/juice.dart';
import '../widgets/press.dart';
import '../widgets/stage_scene.dart';
import '../widgets/stat_bar.dart';
import '../widgets/talisman_widgets.dart';
import '../feel.dart';

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
    this.strikeKey = 0,
    this.hurtKey = 0,
    this.guardKey = 0,
    this.deflectKey = 0,
    this.turnKey = 0,
    this.qiKey = 0,
    this.victory = false,
    this.defeated = false,
    this.heroPops = const [],
    this.talismanHits = const {},
  });

  final int strikeKey;
  final int hurtKey;
  final int guardKey;
  final int deflectKey;
  final int turnKey;
  final int qiKey;
  final bool victory;
  final bool defeated;
  final List<_Pop> heroPops;

  /// Cuántas veces actuó cada talismán (rebota su ficha).
  final Map<String, int> talismanHits;
}

/// Lo que se anima en cada enemigo en escena (con dos a la vez, cada uno lo
/// suyo): golpe, embestida, pulso, chispas, estallido, guardia, quiebre.
class _FoeFx {
  int hit = 0, attack = 0, pulse = 0, spark = 0, burst = 0, guard = 0;
  int brk = 0;
  bool heavy = false, dying = false;
  final pops = <_Pop>[];

  /// Marca dónde está la figura, para que las cartas vuelen hacia ella.
  final key = GlobalKey();
}

class _CombatScreenState extends ConsumerState<_CombatBody> {
  final _queue = <_Fx>[];
  _Fx? _current;
  int _fxKey = 0;
  final _timers = <Timer>[];
  final _rnd = math.Random();
  final _heroKey = GlobalKey();

  /// Mazo por robar y descarte: de ahí salen y ahí caen las cartas.
  final _drawKey = GlobalKey();
  final _discardKey = GlobalKey();

  /// Crece al rebarajar el descarte: las cartas vuelan de un mazo al otro.
  int _shuffleKey = 0;

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

  int _strikeKey = 0,
      _hurtKey = 0,
      _guardKey = 0,
      _deflectKey = 0,
      _turnKey = 0;
  int _shakeKey = 0, _flashKey = 0, _formBurstKey = 0, _popId = 0;
  int _qiKey = 0;
  double _shakeStrength = 8;
  bool _victory = false, _defeated = false;

  /// Animaciones de cada enemigo en escena, por su lugar.
  final _foes = <_FoeFx>[];
  _FoeFx _foe(int i) {
    while (_foes.length <= i) {
      _foes.add(_FoeFx());
    }
    return _foes[i];
  }
  final _heroPops = <_Pop>[];
  final _talismanHits = <String, int>{};

  GameAudio get _audio => ref.read(audioProvider);

  /// Presentación de la élite o el jefe antes de la arena.
  bool _intro = false;

  @override
  void initState() {
    super.initState();
    // Entrada: música según el rival, cae el enemigo, cartel y reparto.
    final live = ref.read(combatControllerProvider);
    if (live == null) return;
    final rank = ref.read(dataProvider).enemy(live.state.enemy.id).rank;
    // El Discípulo Perdido que lleva la cinta de un caído también se
    // presenta: dice quién fue.
    final ghost = live.state.enemy.id == ghostEnemy &&
        ref.read(runControllerProvider)?.ghost != null;
    _intro =
        !live.tutorial &&
        (rank != EnemyRank.common || ghost) &&
        live.state.turn <= 1 &&
        live.state.wave == 0 &&
        ref.read(cinematicsProvider);
    _audio.music(
      live.tutorial
          ? Music.training
          : switch (rank) {
              EnemyRank.boss => Music.boss,
              EnemyRank.elite => Music.elite,
              _ => Music.combat,
            },
    );
    if (!_intro) _begin();
  }

  /// La arena aparece: cae el enemigo, cartel, reparto y talismanes.
  void _begin() {
    final live = ref.read(combatControllerProvider);
    if (live == null) return;
    _after(120, () => _audio.play(Sfx.enemyDrop));
    _after(300, () => _audio.play(Sfx.fightStart));
    _dealSounds(450, live.state.hand.length);
    // Los talismanes que actúan al empezar se anuncian uno por uno.
    for (final (i, e) in live.events.whereType<TalismanTriggered>().indexed) {
      _after(1500 + 420 * i, () => setState(() => _talismanActs(e.talismanId)));
    }
  }

  /// La ficha del talismán rebota y su nombre sale del héroe.
  void _talismanActs(String id) {
    final def = ref.read(dataProvider).talisman(id);
    _talismanHits[id] = (_talismanHits[id] ?? 0) + 1;
    Haptics.lightImpact();
    _audio.play(Sfx.breathGain);
    _pop(
      _heroPops,
      '${def.hanzi} ${ref.read(textProvider).talisman(id)}',
      def.rare ? Palette.gold : Palette.jade,
      size: 16,
      dx: 70,
      dy: -70,
    );
  }

  /// El descarte vuelve al mazo: vuelan las cartas y suena el barajado.
  void _reshuffle(int at) {
    _after(at, () {
      setState(() => _shuffleKey++);
      Haptics.lightImpact();
      for (var i = 0; i < 4; i++) {
        _after(60 * i, () => _audio.play(Sfx.cardDeal));
      }
    });
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
    timeDilation = 1;
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
    if (strength >= 9) _hitStop(strength >= 14 ? 110 : 70);
  }

  /// Pausa de impacto: en los golpes fuertes todo se congela un instante
  /// (las animaciones van casi quietas) y después sigue. Da peso al golpe.
  void _hitStop(int ms) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    timeDilation = 8;
    _after(ms, () => timeDilation = 1);
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
          e is EnemyCharged ||
          e is EnemyFled,
    );
    if (enemyTurn) return _enemyTurn(prev, next);
    if (!ev.any((e) => e is CardPlayed)) {
      for (final e in ev) {
        switch (e) {
          case TargetChanged():
            Haptics.selectionClick();
            _audio.play(Sfx.cardSelect);
          case StanceChanged():
            _audio.play(Sfx.stanceChange);
          case CardsDrawn(:final count):
            _audio.play(Sfx.breathGain);
            _dealSounds(250, count);
          case DeckShuffled():
            _reshuffle(0);
          default:
        }
      }
      setState(() => _shown = next);
      _banners(ev, next.state.target);
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
    final wave = ev.whereType<WaveStarted>().firstOrNull;
    // La carta le pega al que estaba apuntado (si cae, ya se apunta al otro).
    final slot = prev.state.target;
    _after(hits.isEmpty ? 150 : 240, () {
      _impactOnEnemy(wave == null ? next : _fallen(prev, next), ev, slot);
      _banners(ev, slot);
      if (ev.any((e) => e is Victory)) {
        _win(slot);
      } else if (ev.any((e) => e is Defeat)) {
        _lose();
      } else if (wave != null) {
        _nextWave(next, wave);
      } else {
        if (ev.any((e) => e is EnemyDefeated)) _foeDown(slot);
        setState(() => _busy = false);
      }
    });
  }

  /// El estado nuevo, pero con el enemigo que acaba de caer todavía en
  /// escena: así se lo ve caer antes de que entre el siguiente.
  CombatView _fallen(CombatView prev, CombatView next) => next.copyWith(
    state: next.state.copyWith(enemy: prev.state.enemy.copyWith(hp: 0)),
  );

  /// Cae el enemigo del grupo (estallido, sin el cartel de victoria) y, ya
  /// despejada la arena, entra el siguiente con su nombre y "2/3".
  void _nextWave(CombatView next, WaveStarted w, {bool unlock = true}) {
    Haptics.heavyImpact();
    _audio.play(Sfx.enemyDeath);
    setState(() {
      _queue.clear();
      _current = null;
      _foe(0)
        ..dying = true
        ..burst += 1;
      _shake(12);
    });
    _after(_waveGap, () {
      setState(() {
        _foe(0).dying = false;
        _shown = next;
      });
      Haptics.mediumImpact();
      _audio.play(Sfx.enemyDrop);
      final t = AppLocalizations.of(context);
      _queue.add(
        _Fx(
          ref.foe(context, w.enemyId),
          t.waveOf(w.index, w.total),
          Palette.lacquer,
        ),
      );
      _pump();
    });
    if (unlock) _after(_waveGap + 500, () => setState(() => _busy = false));
  }

  /// Lo que tarda en despejarse la arena entre un enemigo del grupo y otro.
  static const _waveGap = 950;

  /// Cae uno de los dos en escena: estalla y su lugar queda vacío.
  void _foeDown(int slot) {
    Haptics.heavyImpact();
    _audio.play(Sfx.enemyDeath);
    setState(() {
      _foe(slot)
        ..dying = true
        ..burst += 1;
      _shake(12);
    });
  }

  void _impactOnEnemy(CombatView next, List<CombatEvent> ev, int slot) {
    final f = _foe(slot);
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
        f.hit++;
        f.spark++;
        f.heavy = dmg >= 10 || broken;
        if (dmg > 0) {
          _pop(f.pops, '−$dmg', Palette.lacquer, size: dmg >= 10 ? 42 : 34);
        }
        if (str > 0) {
          _pop(
            f.pops,
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
            f.pops,
            dmg == 0 ? t.blocked : '−$absorbed',
            Palette.sky,
            size: 18,
            icon: Icons.shield,
            dx: -40,
            dy: 26,
          );
        }
        if (broken) f.brk++;
        if (f.heavy) _shake(broken ? 14 : 9);
      }
      if (guard > 0) {
        _guardKey++;
        _pop(_heroPops, '+$guard', Palette.sky, size: 26, icon: Icons.shield);
      }
      for (final e in ev) {
        switch (e) {
          case PlayerHealed(:final amount) when amount > 0:
            _qiKey++;
            _pop(
              _heroPops,
              '+$amount',
              Palette.jade,
              size: 26,
              icon: Icons.favorite,
              dx: -30,
              dy: -20,
            );
          case BreathGained(:final amount):
            _qiKey++;
            _pop(
              _heroPops,
              '+$amount ${t.breath}',
              Palette.gold,
              size: 20,
              icon: Icons.air,
              dx: 20,
              dy: -40,
            );
          default:
        }
      }
    });
    if (hits.isNotEmpty) {
      f.heavy ? Haptics.heavyImpact() : Haptics.mediumImpact();
      _audio.play(
        f.heavy
            ? Sfx.hitHeavy
            : dmg == 0
            ? Sfx.block
            : Sfx.hitLight,
      );
    } else if (guard > 0) {
      Haptics.lightImpact();
    }
    if (guard > 0) _audio.play(Sfx.guardUp);
    if (ev.any((e) => e is StanceChanged)) _audio.play(Sfx.stanceChange);
  }

  void _enemyTurn(CombatView prev, CombatView next) {
    final ev = next.events;
    // Si un desvío voltea al enemigo de un grupo, se lo ve caer al final.
    final wave = ev.whereType<WaveStarted>().firstOrNull;
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

    // 1. La mano se descarta. 2. Actúa cada enemigo, de a uno. 3. Se
    // reparte la mano nueva.
    final segs = _actors(ev);
    var at = 300;
    var slot = 0;
    for (final (k, (who, sev)) in segs.indexed) {
      slot = who;
      final last = k == segs.length - 1;
      final view = !last
          ? _partial(prev, next, [for (final x in segs.take(k + 1)) x.$1],
              [for (final x in segs.take(k + 1)) ...x.$2])
          : wave == null
          ? next
          : _fallen(prev, next);
      at = _enemyActs(who, sev, view, next, at);
      if (!last && sev.any((e) => e is EnemyDefeated)) {
        _after(at, () => _foeDown(who));
        at += 450;
      }
    }

    if (ev.any((e) => e is Victory)) {
      _after(at - 300, () => _win(slot));
      return;
    }
    if (ev.any((e) => e is Defeat)) {
      _after(at - 300, _lose);
      return;
    }
    if (ev.any((e) => e is EnemyFled)) {
      _after(at - 300, _fled);
      return;
    }
    if (wave != null) {
      _after(at, () => _nextWave(next, wave, unlock: false));
      at += _waveGap + 200;
    } else if (segs.length > 1 && segs.last.$2.any((e) => e is EnemyDefeated)) {
      _after(at, () => _foeDown(segs.last.$1));
      at += 450;
    }
    _after(at, () {
      setState(() {
        _hideHand = false;
        _turnKey++;
      });
      Haptics.selectionClick();
      _audio.play(Sfx.turnStart);
    });
    if (ev.any((e) => e is DeckShuffled)) _reshuffle(at - 200);
    _dealSounds(at + 320, next.state.hand.length);
    _after(
      at + 70 * next.state.hand.length + 320,
      () => setState(() => _busy = false),
    );
  }

  /// Los eventos del turno enemigo partidos por quién actúa: con uno solo,
  /// todo es suyo; con dos, cada [EnemyActing] abre el tramo de ese.
  List<(int, List<CombatEvent>)> _actors(List<CombatEvent> ev) {
    final out = <(int, List<CombatEvent>)>[];
    for (final e in ev) {
      if (e is EnemyActing) {
        out.add((e.index, []));
      } else if (out.isEmpty) {
        out.add((0, [e]));
      } else {
        out.last.$2.add(e);
      }
    }
    if (out.length > 1 && out.first.$2.isEmpty) out.removeAt(0);
    return out.isEmpty ? [(0, const [])] : out;
  }

  /// Cómo se ve la arena a mitad del turno enemigo: los que ya actuaron, en
  /// su estado nuevo; los que faltan, como estaban; la Vida, con lo que
  /// pegaron hasta ahora.
  CombatView _partial(
    CombatView prev,
    CombatView next,
    List<int> acted,
    List<CombatEvent> sofar,
  ) {
    final lost = sofar.whereType<PlayerHit>().fold(0, (a, e) => a + e.damage);
    final s = next.state;
    return next.copyWith(
      state: s.copyWith(
        player: s.player.copyWith(
          hp: math.max(s.player.hp, prev.state.player.hp - lost),
        ),
        enemies: [
          for (final (i, e) in s.enemies.indexed)
            acted.contains(i) ? e : prev.state.enemies[i],
        ],
      ),
    );
  }

  /// Un enemigo actúa desde [at] (ms): embiste y pega, o se cubre, carga o
  /// pierde el turno. Devuelve cuándo terminó.
  int _enemyActs(
    int slot,
    List<CombatEvent> ev,
    CombatView view,
    CombatView next,
    int at,
  ) {
    final t = AppLocalizations.of(context);
    final f = _foe(slot);
    final outcomes = ev.where((e) => e is PlayerHit || e is Deflected).toList();
    if (outcomes.isNotEmpty) {
      _after(at, () {
        setState(() => f.attack++);
        _audio.play(Sfx.enemyWindup);
        _audio.voice(next.state.enemies[slot].id);
      });
      at += EnemySprite.impactDelay.inMilliseconds;
      for (final (i, o) in outcomes.indexed) {
        final last = i == outcomes.length - 1;
        _after(at + i * 240, () {
          setState(() {
            _shown = view;
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
                    ? Haptics.heavyImpact()
                    : Haptics.mediumImpact();
                _audio.play(damage > 0 ? Sfx.playerHurt : Sfx.block);
              case Deflected():
                _audio.play(Sfx.deflect);
                _deflectKey++;
                _shake(5);
              default:
            }
          });
          if (last) {
            // El contragolpe del desvío se ve en el que atacó.
            final back = ev.whereType<EnemyDamaged>().toList();
            if (back.isNotEmpty) {
              setState(() {
                f.hit++;
                f.spark++;
              });
            }
            _banners(ev, slot);
          }
        });
      }
      return at + (outcomes.length - 1) * 240 + 450;
    }
    // Guardia, carga o turno perdido: el enemigo se infla o tambalea.
    _after(at, () {
      setState(() {
        _shown = view;
        for (final e in ev) {
          switch (e) {
            case EnemyGuarded(:final amount):
              _audio.play(Sfx.enemyGuard);
              f.pulse++;
              f.guard++;
              _pop(f.pops, '+$amount', Palette.sky, size: 26, icon: Icons.shield);
            case EnemyCharged(:final amount):
              _audio.play(Sfx.enemyCharge);
              f.pulse++;
              _pop(f.pops, '+$amount', Palette.gold, size: 26, icon: Icons.bolt);
            case EnemyActionSkipped():
              _audio.play(Sfx.enemySkip);
              _pop(f.pops, t.losesAction, Palette.gold, size: 18);
            default:
          }
        }
      });
      Haptics.lightImpact();
      _banners(ev, slot);
    });
    return at + 650;
  }

  /// Victoria: estalla el último en caer ([slot]).
  void _win([int slot = 0]) {
    Haptics.heavyImpact();
    _audio.play(Sfx.enemyDeath);
    setState(() {
      _queue.clear();
      _current = null;
      for (final f in _foes) {
        f.dying = true;
      }
      _foe(slot).burst++;
      _shake(16);
    });
    _after(450, () {
      setState(() => _victory = true);
      _audio.play(Sfx.heroVictory);
    });
    _after(1150, () {
      Haptics.mediumImpact();
      _audio.jingle(Music.victory);
      setState(() => _endShown = true);
    });
  }

  /// Se escapó: sale de escena sin la explosión de la victoria.
  void _fled() {
    Haptics.mediumImpact();
    _audio.play(Sfx.enemySkip);
    setState(() {
      _queue.clear();
      _current = null;
      for (final f in _foes) {
        f.dying = true;
      }
    });
    _after(900, () => setState(() => _endShown = true));
  }

  void _lose() {
    Haptics.heavyImpact();
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

  /// Carteles y números de los eventos; los del enemigo salen sobre el de
  /// la posición [slot].
  void _banners(List<CombatEvent> events, [int slot = 0]) {
    final enemyPops = _foe(slot).pops;
    final data = ref.read(dataProvider);
    final text = ref.read(textProvider);
    final t = AppLocalizations.of(context);
    for (final e in events) {
      switch (e) {
        case Deflected():
          Haptics.mediumImpact();
          _queue.add(_Fx(t.deflect, '化', Palette.sky));
        case EnemyBroken():
          Haptics.heavyImpact();
          _audio.play(Sfx.broken);
          _queue.add(_Fx(t.broken, t.staggeredDouble, Palette.gold));
        case ScaleShed(:final remaining):
          _queue.add(_Fx(t.scaleShed, t.scalesLeft(remaining), Palette.jade));
        case Parried(:final damage):
          Haptics.heavyImpact();
          _audio.play(Sfx.block);
          _flashKey++;
          _shake(8);
          _pop(_heroPops, '−$damage', Palette.lacquer, size: 34);
          _queue.add(_Fx(t.parried, t.parriedDetail(damage), Palette.structure));
        case WrathCalmed():
          _queue.add(_Fx(t.wrathCalmed, null, Palette.gold));
        case EnemyEnraged(:final total):
          _pop(
            enemyPops,
            '+$total',
            Palette.lacquer,
            size: 22,
            icon: Icons.local_fire_department,
          );
        case ThornsHurt(:final damage):
          Haptics.mediumImpact();
          _audio.play(Sfx.playerHurt);
          _flashKey++;
          _pop(
            _heroPops,
            '−$damage',
            Palette.lacquer,
            size: 26,
            icon: Icons.grass,
            dx: 36,
            dy: -10,
          );
        case EnemyRegenerated(:final amount):
          _pop(
            enemyPops,
            '+$amount',
            Palette.jade,
            size: 24,
            icon: Icons.favorite,
            dx: -36,
            dy: -16,
          );
        case GuardBypassed():
          Haptics.lightImpact();
          _queue.add(_Fx(t.guardBypassed, t.guardBypassedDetail, Palette.sky));
        case BreathDrained(:final amount):
          _audio.play(Sfx.breathSpend);
          _queue.add(
            _Fx(t.breathDrained, t.breathDrainedDetail(amount), Palette.gold),
          );
        case HandFrozen(:final amount):
          _audio.play(Sfx.breathSpend);
          _queue.add(_Fx(t.handFrozen, t.handFrozenDetail(amount), Palette.sky));
        case JadeStolen(:final amount):
          _pop(
            _heroPops,
            '−$amount',
            Palette.gold,
            size: 20,
            icon: Icons.savings_outlined,
            dx: -44,
            dy: 30,
          );
        case PlayerBroken():
          Haptics.heavyImpact();
          _queue.add(_Fx(t.playerBroken, '−2 ${t.breath}', Palette.lacquer));
        case FormAdvanced(:final progress):
          _audio.play(Sfx.formStep, variant: progress - 1);
        case FormInterrupted():
          _audio.play(Sfx.formBroken);
        case FormCompleted(:final formId):
          Haptics.heavyImpact();
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
        case FistBonusGained(:final total):
          _queue.add(
            _Fx(t.fistBonusTitle, t.fistBonusNow(total), Palette.lacquer),
          );
        case FormsResetByEnemy():
          _audio.play(Sfx.formBroken);
          _queue.add(_Fx(t.formsInterrupted, null, Palette.textDim));
        case EnemyPhaseChanged(:final phase):
          Haptics.heavyImpact();
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
          Haptics.mediumImpact();
          _audio.play(Sfx.enemyGuard);
          _queue.add(_Fx(t.scalesRegrown, t.scalesNow(scales), Palette.jade));
        case TalismanTriggered(:final talismanId):
          setState(() => _talismanActs(talismanId));
        default:
      }
    }
    if (events.any((e) => e is Victory || e is Defeat)) _queue.clear();
    setState(() {});
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
      strikeKey: _strikeKey,
      hurtKey: _hurtKey,
      guardKey: _guardKey,
      deflectKey: _deflectKey,
      turnKey: _turnKey,
      qiKey: _qiKey,
      victory: _victory,
      defeated: _defeated,
      heroPops: _heroPops,
      talismanHits: {..._talismanHits},
    );
    final run = live.tutorial ? null : ref.watch(runControllerProvider);
    final node = run?.currentNode == null ? null : run!.node(run.currentNode!);
    final stageId = run == null
        ? data.balance.stage.id
        : data.balance.stages[run.stage].id;

    if (_intro) {
      final def = data.enemy(s.enemy.id);
      final ghost = def.id == ghostEnemy ? run?.ghost : null;
      final ghostPath = ghost?.style == null
          ? null
          : ref.watch(textProvider).style(ghost!.style!);
      return Scaffold(
        body: CinematicGate(
          // Cada caído se presenta entero la primera vez que vuelve.
          id: ghost != null ? 'ghost_${ghost.n}' : 'foe_${def.id}',
          // Los jefes se presentan enteros la primera vez; las élites, cortas.
          fullFirstTime: def.rank == EnemyRank.boss || ghost != null,
          builder: (full) => FoeIntro(
            def: def,
            name: ref.foe(context, def.id),
            intro: ghost == null
                ? ref.watch(textProvider).enemyLine(def.id, 'intro')
                : ghostPath == null
                ? AppLocalizations.of(context).ghostIntro(ghost.n, ghost.floor)
                : AppLocalizations.of(context)
                      .ghostIntroPath(ghost.n, ghostPath, ghost.floor),
            reply: ghost != null
                ? AppLocalizations.of(context).ghostReply
                : ref.watch(textProvider).enemyLine(def.id, 'reply'),
            rankLine: ghost == null
                ? null
                : AppLocalizations.of(context).ghostRank,
            sealHanzi: ghost == null ? null : '忆',
            tint: ghost == null ? null : Palette.blossom,
            escort: s.enemies.length > 1 && def.rank == EnemyRank.elite
                ? ref.foe(context, s.enemies[1].id)
                : null,
            stageId: stageId,
            scene: node?.scene,
            light: node?.light,
            style: run?.style,
            full: full,
            onDone: () {
              setState(() => _intro = false);
              _begin();
            },
          ),
        ),
      );
    }

    final column = Column(
      children: [
        Expanded(
          child: _Arena(
            stageId: stageId,
            scene: node?.scene,
            light: node?.light,
            turn: s.turn,
            style: live.tutorial
                ? null
                : ref.watch(runControllerProvider)?.style,
            talismans: s.talismans,
            fx: fx,
            heroKey: _heroKey,
            introTitle: [
              for (final e in s.enemies) ref.foe(context, e.id),
            ].join(' · '),
            // Con dos a la vez, cada uno en su lugar; tocarlo lo apunta.
            slots: [
              for (final (i, e) in s.enemies.indexed)
                _EnemySlot(
                  def: data.enemy(e.id),
                  enemy: e,
                  intent: engine.intentView(s, i),
                  foe: _foe(i),
                  wave: s.wave,
                  waveCount: s.waveCount,
                  index: i,
                  pair: s.enemies.length > 1,
                  targeted: i == s.target,
                  onTap: () {
                    if (_busy) return;
                    ref.read(combatControllerProvider.notifier).target(i);
                  },
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
              SizedBox(
                width: double.infinity,
                child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // El panel deja lugar a los dos mazos en las esquinas.
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: TutorialAnchor(
                      id: 'preview',
                      child: _PreviewPanel(
                        view: live,
                        data: data,
                        engine: engine,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 8,
                    top: 0,
                    child: _Pile(
                      key: _drawKey,
                      cards: live.state.drawPile,
                      discard: false,
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 0,
                    child: _Pile(
                      key: _discardKey,
                      cards: live.state.discard,
                      discard: true,
                    ),
                  ),
                  Positioned.fill(
                    child: IgnorePointer(
                      child: _Reshuffle(trigger: _shuffleKey),
                    ),
                  ),
                ],
              ),
              ),
              TutorialAnchor(
                id: 'hand',
                child: _HandArea(
                  view: live,
                  hand: hand,
                  data: data,
                  engine: engine,
                  playedUid: _playedUid,
                  enemyKey: _foe(live.state.target).key,
                  heroKey: _heroKey,
                  drawKey: _drawKey,
                  discardKey: _discardKey,
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
          // El escenario sube detrás de la barra de estado.
          clipBehavior: Clip.none,
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
                enemyName: ref.foe(context, live.state.enemy.id),
                enemyHp: live.state.enemy.hp,
                quote: live.lessonId != null
                    ? null
                    : ref
                          .watch(textProvider)
                          .enemyLine(
                            live.state.enemy.id,
                            won ? 'defeat' : 'triumph',
                          ),
                fledWith: live.state.enemy.fled
                    ? live.state.enemy.stolen
                    : null,
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
    required this.foe,
    required this.onTap,
    this.wave = 0,
    this.waveCount = 1,
    this.index = 0,
    this.pair = false,
    this.targeted = true,
  });

  final EnemyDef def;
  final EnemyCombat enemy;
  final IntentView intent;

  /// Lugar en el grupo (0 = el primero) y cuántos son.
  final int wave;
  final int waveCount;

  /// Sus animaciones (y la marca de dónde está la figura).
  final _FoeFx foe;

  /// Su lugar en escena; con [pair] hay dos a la vez y [targeted] dice si
  /// las cartas van a él.
  final int index;
  final bool pair;
  final bool targeted;
  final VoidCallback onTap;
}

/// Escenario del combate: fondo de la etapa, suelo, los enemigos al frente y
/// el héroe de espaldas en primer plano.
class _Arena extends StatelessWidget {
  const _Arena({
    required this.stageId,
    required this.scene,
    required this.light,
    required this.turn,
    required this.style,
    required this.talismans,
    required this.fx,
    required this.heroKey,
    required this.introTitle,
    required this.slots,
  });

  final String stageId;

  /// Escenario y luz del camino (null en las lecciones: la terraza al alba).
  final String? scene;
  final String? light;
  final int turn;
  final Style? style;
  final List<String> talismans;
  final _ArenaFx fx;
  final GlobalKey heroKey;
  final String introTitle;
  final List<_EnemySlot> slots;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Dentro del SafeArea el padding ya es 0: se mide el de la pantalla.
    final top = MediaQueryData.fromView(View.of(context)).padding.top;
    return LayoutBuilder(
      builder: (context, box) {
        final heroH = math.min(box.maxHeight * 0.62, box.maxWidth * 0.54);
        final heroW = heroH * 2 / 3;
        final heroLeft = -heroW * 0.12;
        final heroBottom = -heroH * 0.12;
        // El escenario sigue debajo de la mano y llega hasta el borde de
        // arriba: los paneles de abajo lo tapan con papel de a poco.
        final sceneH = top + box.maxHeight * 1.55;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -top,
              left: 0,
              right: 0,
              height: sceneH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StageScene(stageId: stageId, scene: scene, light: light),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Palette.bg.withValues(alpha: 0),
                          Palette.bg.withValues(alpha: 0),
                          Palette.bg.withValues(alpha: 0.78),
                          Palette.bg,
                        ],
                        stops: [
                          0,
                          (top + box.maxHeight * 0.86) / sceneH,
                          (top + box.maxHeight * 1.04) / sceneH,
                          1,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
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
              // Entra desde la izquierda al empezar el combate.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v.clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(-heroW * 0.7 * (1 - v), heroH * 0.06 * (1 - v)),
                    child: child,
                  ),
                ),
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
          // Aliento o vida que vuelve: un remolino detrás del héroe.
          Positioned(
            left: heroLeft - heroW * 0.15,
            bottom: heroBottom + heroH * 0.1,
            width: heroW * 1.3,
            height: heroW * 1.3,
            child: ArtBurst(
              trigger: fx.qiKey,
              asset: 'assets/art/vfx/qi_swirl.webp',
              size: heroW * 1.3,
              duration: const Duration(milliseconds: 900),
              from: 0.4,
              to: 1,
              spin: 2.4,
              hold: 0.4,
            ),
          ),
          // Números sobre el héroe.
          Positioned(
            left: heroLeft + heroW * 0.62,
            bottom: heroBottom + heroH * 0.62,
            child: IgnorePointer(child: _PopStack(pops: fx.heroPops)),
          ),
          // Turno, camino y talismanes: encima de todo, para que su
          // globo de ayuda no quede tapado por el héroe ni el rival.
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
                if (talismans.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 100,
                    child: TalismanRow(
                      ids: talismans,
                      size: 26,
                      triggers: fx.talismanHits,
                    ),
                  ),
                ],
              ],
            ),
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
    final foe = slot.foe;
    final accent = rankColor(def.rank);
    // La guía del tutorial señala al primero (nunca hay dos en las lecciones).
    Widget anchor(String id, Widget child) =>
        slot.index == 0 ? TutorialAnchor(id: id, child: child) : child;
    final aimed = slot.pair && slot.targeted && !foe.dying;
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: slot.pair ? slot.onTap : null,
      child: Column(
      children: [
        // Con dos, los globos bajan un poco: arriba a la derecha está la pausa.
        SizedBox(height: slot.pair ? 46 : 26),
        anchor(
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
                : _IntentBubble(
                    key: ValueKey('${e.id}-${e.patternIndex}-${e.phaseIndex}'),
                    iv: slot.intent,
                    compact: slot.pair,
                  ),
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, box) {
              final size = math.min(
                math.min(box.maxHeight, 220.0),
                box.maxWidth * 1.15,
              );
              return Stack(
                alignment: Alignment.center,
                clipBehavior: Clip.none,
                children: [
                  // A quién apuntás: un halo de oro a sus pies.
                  if (slot.pair)
                    Positioned(
                      bottom: (box.maxHeight - size) / 2 - 4,
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
                    : () => showDialog<void>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: Text(ref.foe(context, def.id)),
                          content: Text(text.enemyRule(def.id)),
                        ),
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
                _WavePips(index: slot.wave, total: slot.waveCount),
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
          child:
              e.guard > 0 ||
                  e.staggered ||
                  e.scales > 0 ||
                  e.wrath > 0 ||
                  e.parryReady ||
                  e.stolen > 0 ||
                  def.thorns + e.thorns > 0 ||
                  def.regen > 0
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
                          onTap: () => showDialog<void>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: Text(ref.foe(context, def.id)),
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
              : SizedBox(width: double.infinity, height: slot.pair ? 27 : 0),
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
  const _WavePips({required this.index, required this.total});

  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
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

/// Globo de intención sobre la cabeza del enemigo.
class _IntentBubble extends ConsumerWidget {
  const _IntentBubble({super.key, required this.iv, this.compact = false});

  final IntentView iv;

  /// Con dos en escena el globo es más angosto: letra más chica y el nombre
  /// en hasta dos renglones.
  final bool compact;

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
                      maxLines: compact ? 2 : 1,
                      style: TextStyle(
                        fontSize: compact ? 12.5 : 14,
                        height: compact ? 1.15 : null,
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
                    if (i.drain > 0 && i.kind == IntentKind.attack)
                      Text(
                        t.intentDrain(i.drain),
                        style: const TextStyle(
                          fontSize: 10,
                          color: Palette.textDim,
                        ),
                      ),
                    if (i.freeze > 0 && i.kind == IntentKind.attack)
                      Text(
                        t.intentFreeze(i.freeze),
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
  const _FormsPanel({required this.s, required this.data});

  final CombatState s;
  final GameData data;

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
                        trigger: i < s.formProgress[f.id]!,
                        scale: 1.15,
                        child: _FormStep(
                          label: text.card(f.steps[i]),
                          done: i < s.formProgress[f.id]!,
                          next: i == s.formProgress[f.id]!,
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
                child: _CostLabel(
                  label: text.dingbu(),
                  cost: data.transition.cost,
                ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: TutorialAnchor(
              id: 'breathe',
              child: OutlinedButton(
                onPressed: !busy && engine.validate(s, const Breathe()) == null
                    ? ctl.breathe
                    : null,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                ),
                child: _CostLabel(
                  label: t.breathe,
                  cost: data.balance.breatheCost,
                ),
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

/// Nombre de una acción con lo que cuesta en Aliento, en un punto celeste.
class _CostLabel extends StatelessWidget {
  const _CostLabel({required this.label, required this.cost});

  final String label;
  final int cost;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, maxLines: 1),
          const SizedBox(width: 4),
          Container(
            width: 16,
            height: 16,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.sky,
            ),
            child: Text(
              '$cost',
              style: const TextStyle(
                fontSize: 10,
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
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const GameIcon(Icons.air, size: 13, color: Palette.sky),
            const SizedBox(width: 2),
            Text(
              '${AppLocalizations.of(context).breath} $breath',
              style: const TextStyle(fontSize: 10, color: Palette.sky),
            ),
          ],
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
    this.quote,
    this.fledWith,
  });

  final bool won;

  /// Últimas palabras del jefe o la élite (o lo que dice si ganó).
  final String? quote;

  /// El enemigo se escapó con este jade (null si lo venciste).
  final int? fledWith;

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
      Haptics.heavyImpact();
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
    final fled = widget.fledWith;
    final String summaryText = switch ((lesson, won)) {
      (null, true) when fled != null => t.endSummaryFled(
        widget.enemyName,
        fled,
      ),
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
                if (won && fled == null)
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
                if (won && fled == null)
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
                                fled != null
                                    ? t.fledTitle
                                    : won
                                    ? t.victory
                                    : t.defeat,
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
                    if (widget.quote != null && fled == null)
                      Opacity(
                        opacity: summary,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                          child: Text(
                            '«${widget.quote}»',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontStyle: FontStyle.italic,
                              color: Palette.text,
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
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    final ctl = ref.read(combatControllerProvider.notifier)..finish();
    if (lessonById(id).isCombat) {
      ctl.startLesson(id);
    } else {
      context.go('/lessons/climb');
    }
  }

  void _toLessons() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    context.go('/lessons');
  }

  void _continue() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    final run = ref.read(runControllerProvider)!;
    context.go(switch (run.phase) {
      RunPhase.talisman => '/talisman',
      RunPhase.reward => '/reward',
      RunPhase.stageClear => '/stage',
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
          Haptics.selectionClick();
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
                  onPressed: () => leave('/school'),
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
