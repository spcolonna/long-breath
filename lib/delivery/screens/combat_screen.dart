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
import '../../domain/model/form_def.dart';
import '../../domain/model/game_data.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../content_text.dart';
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
import '../widgets/breather_sheet.dart';
import '../widgets/card_widget.dart';
import '../widgets/cinematic.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/enemy_scroll.dart';
import '../widgets/altitude_bar.dart';
import '../widgets/enemy_sprite.dart';
import '../widgets/game_icon.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/juice.dart';
import '../widgets/press.dart';
import '../widgets/stage_scene.dart';
import '../widgets/talisman_widgets.dart';
import '../widgets/weapon_art.dart';
import '../widgets/weapon_widgets.dart';
import '../feel.dart';

part 'combat/arena.dart';
part 'combat/enemy_stage.dart';
part 'combat/player.dart';
part 'combat/hand.dart';
part 'combat/action_bar.dart';
part 'combat/end_overlay.dart';

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
  const _Fx(
    this.title,
    this.subtitle,
    this.color, {
    this.big = false,
    this.header,
    this.detail,
    this.ms,
  });
  final String title;
  final String? subtitle;
  final Color color;
  final bool big;

  /// Rótulo chico sobre el título (p. ej. «¡Forma completa!»).
  final String? header;

  /// Lo que hizo, en una píldora debajo (p. ej. «+2 Aliento · roba 1»).
  final String? detail;

  /// Duración propia; si no, la de su tamaño.
  final int? ms;

  int get duration => ms ?? (big ? 1400 : 950);
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
    this.heavy = false,
  });
  final int id;
  final String text;
  final Color color;
  final double size;
  final IconData? icon;
  final double dx;
  final double dy;
  final bool heavy;
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
    this.weaponHits = 0,
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

  /// Cuántas veces actuó el arma (rebota su ficha).
  final int weaponHits;
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

  /// Cayó un rival del grupo y se está eligiendo el respiro.
  bool _breatherOpen = false;

  int _strikeKey = 0,
      _hurtKey = 0,
      _guardKey = 0,
      _deflectKey = 0,
      _turnKey = 0;
  int _shakeKey = 0, _flashKey = 0, _formBurstKey = 0, _popId = 0;

  /// Destello dorado (desequilibrio, forma, remate) y sello del remate.
  int _goldFlashKey = 0, _finishKey = 0;

  /// Forma recién completada: sus pasos quedan dorados un momento en el
  /// panel antes de volver a cero.
  String? _formFlash;

  /// Golpes seguidos en este turno (el contador de la arena).
  int _combo = 0;

  /// Cada cambio de velocidad invalida los anteriores (el último manda).
  int _dilation = 0;
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
  int _weaponHits = 0;

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
    final ghost = isGhostFoe(live.state.enemy.id) &&
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
    // Grupo en oleadas: que se sepa desde el principio cuántos vienen.
    if (live.state.waveCount > 1) {
      final n = live.state.waveCount;
      _after(700, () {
        if (!mounted) return;
        final t = AppLocalizations.of(context);
        Haptics.mediumImpact();
        _queue.add(_Fx(t.waveGroupTitle(n), t.waveGroupSub, Palette.lacquer));
        _pump();
      });
    }
    // Los talismanes que actúan al empezar se anuncian uno por uno.
    for (final (i, e) in live.events.whereType<TalismanTriggered>().indexed) {
      _after(1500 + 420 * i, () => setState(() => _talismanActs(e.talismanId)));
    }
    if (live.events.any((e) => e is WeaponTriggered)) {
      final n = live.events.whereType<TalismanTriggered>().length;
      _after(1500 + 420 * n, () => setState(_weaponActs));
    }
  }

  /// La ficha del arma rebota y su nombre sale del héroe.
  void _weaponActs() {
    final s = ref.read(combatControllerProvider)?.state;
    final id = s?.weapon;
    if (id == null) return;
    _weaponHits++;
    Haptics.lightImpact();
    _audio.play(Sfx.weaponTrigger);
    _pop(
      _heroPops,
      '${ref.read(dataProvider).weapon(id).hanzi} '
          '${ref.read(textProvider).weapon(id)}',
      weaponColor(s!.weaponLevel),
      size: 15,
      dx: 60,
      dy: -95,
    );
  }

  /// La ficha del talismán rebota y su nombre sale del héroe.
  void _talismanActs(String id) {
    final def = ref.read(dataProvider).talisman(id);
    _talismanHits[id] = (_talismanHits[id] ?? 0) + 1;
    Haptics.lightImpact();
    _audio.play(Sfx.talismanTrigger);
    _pop(
      _heroPops,
      '${def.hanzi} ${ref.read(textProvider).talisman(id)}',
      talismanColor(def),
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
    bool heavy = false,
  }) {
    final p = _Pop(
      _popId++,
      text,
      color,
      size: size,
      icon: icon,
      dx: dx + (_rnd.nextDouble() - 0.5) * 24,
      dy: dy,
      heavy: heavy,
    );
    into.add(p);
    _after(heavy ? 1400 : 1100, () => setState(() => into.remove(p)));
  }

  void _shake(double strength) {
    // La cámara se sacude menos que antes: el héroe va dentro de la escena y
    // con tanto temblor parecía entrar y salir.
    _shakeStrength = strength * 0.55;
    _shakeKey++;
    if (strength >= 9) _hitStop(strength >= 14 ? 110 : 70);
  }

  /// Pausa de impacto: en los golpes fuertes todo se congela un instante
  /// (las animaciones van casi quietas) y después sigue. Da peso al golpe.
  void _hitStop(int ms) => _dilate([(8, ms)]);

  /// Cambios de velocidad en tramos (factor, ms): primero casi quieto y
  /// después cámara lenta, y vuelve a la normal. Un tramo nuevo reemplaza
  /// a los que quedaban. Con movimiento reducido no hace nada.
  void _dilate(List<(double, int)> steps) {
    if (MediaQuery.disableAnimationsOf(context)) return;
    final token = ++_dilation;
    var at = 0;
    for (final (factor, ms) in steps) {
      if (at == 0) {
        timeDilation = factor;
      } else {
        _after(at, () {
          if (_dilation == token) timeDilation = factor;
        });
      }
      at += ms;
    }
    _after(at, () {
      if (_dilation == token) timeDilation = 1;
    });
  }

  void _present(CombatView prev, CombatView next) {
    // La arena arranca mostrando el estado anterior y se pone al día en el impacto.
    _shown ??= prev;
    final ev = next.events;
    if (ev.any((e) => e is BreatherTaken)) return _afterBreather(next);
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
    final rest = ev.any((e) => e is BreatherOffered);
    // La carta le pega al que estaba apuntado (si cae, ya se apunta al otro).
    final slot = prev.state.target;
    _after(hits.isEmpty ? 150 : 240, () {
      _impactOnEnemy(wave == null ? next : _fallen(prev, next), ev, slot);
      _banners(ev, slot);
      if (ev.any((e) => e is Victory)) {
        _win(slot);
      } else if (ev.any((e) => e is Defeat)) {
        _lose();
      } else if (rest) {
        _offerBreather();
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
    _waveFalls();
    _after(_waveGap, () => _waveIn(next, w));
    if (unlock) _after(_waveGap + 500, () => setState(() => _busy = false));
  }

  /// El rival del grupo estalla y la arena queda despejada.
  void _waveFalls() {
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
  }

  /// Entra el siguiente del grupo, con su nombre y "2 de 3".
  void _waveIn(CombatView next, WaveStarted w) {
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
  }

  /// Cae un rival del grupo y, ya despejada la arena, se ofrece el respiro.
  void _offerBreather() {
    _waveFalls();
    _after(_waveGap, () {
      setState(() => _breatherOpen = true);
      _audio.play(Sfx.scrollOpen);
    });
  }

  void _pickBreather(Breather b) {
    if (!_breatherOpen) return;
    Haptics.mediumImpact();
    _audio.play(Sfx.rewardTake);
    setState(() => _breatherOpen = false);
    ref.read(combatControllerProvider.notifier).breather(b);
  }

  /// Ya elegido el respiro: se ve lo que dio y entra el siguiente.
  void _afterBreather(CombatView next) {
    final ev = next.events;
    final t = AppLocalizations.of(context);
    setState(() {
      _busy = true;
      for (final e in ev) {
        switch (e) {
          case PlayerHealed(:final amount) when amount > 0:
            _qiKey++;
            _audio.play(Sfx.heal);
            _pop(_heroPops, '+$amount', Palette.jade,
                size: 26, icon: Icons.favorite, dx: -30, dy: -20);
          case BreathGained(:final amount):
            _qiKey++;
            _audio.play(Sfx.breathGain);
            _pop(_heroPops, '+$amount ${t.breath}', Palette.gold,
                size: 20, icon: Icons.air, dx: 20, dy: -40);
          default:
        }
      }
    });
    _banners(ev, 0);
    final count = ev.whereType<CardsDrawn>().fold(0, (a, e) => a + e.count);
    if (count > 0) _dealSounds(250, count);
    final w = ev.whereType<WaveStarted>().first;
    _after(450, () => _waveIn(next, w));
    _after(950, () => setState(() => _busy = false));
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
    // Le pegó desequilibrado: el daño vino doble.
    final before = _shown?.state.enemies;
    final doubled =
        before != null && slot < before.length && before[slot].staggered;
    final kill = ev.any(
      (e) => e is Victory || e is EnemyDefeated || e is WaveStarted,
    );
    final combo = next.state.attacksThisTurn;
    if (combo > _combo && combo >= ComboCounter.shownFrom) {
      // Si la carta avanzó una forma, ya suena su nota: no se pisan.
      final form = ev.any((e) => e is FormAdvanced || e is FormCompleted);
      _comboUp(combo, sound: !form);
    }
    setState(() {
      _shown = next;
      _combo = combo;
      if (hits.isNotEmpty) {
        f.hit++;
        f.spark++;
        f.heavy = dmg >= 10 || broken || kill;
        if (dmg > 0) {
          // Tres tamaños: común, fuerte y brutal (o el que tumba).
          final brutal = dmg >= 18 || kill || doubled;
          _pop(
            f.pops,
            '−$dmg',
            Palette.lacquer,
            size: brutal ? 54 : (f.heavy ? 44 : 34),
            heavy: brutal || f.heavy,
          );
          if (doubled) {
            _pop(f.pops, '×2', Palette.gold, size: 24, dx: 52, dy: -38);
          }
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
        if (f.heavy) _shake(broken || kill ? 14 : 9);
      }
      if (guard > 0) {
        _guardKey++;
        _pop(_heroPops, '+$guard', Palette.sky, size: 26, icon: Icons.shield);
      }
      for (final e in ev) {
        switch (e) {
          case PlayerHealed(:final amount) when amount > 0:
            _qiKey++;
            _audio.play(Sfx.heal);
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

  /// Un golpe más en la cadena: una nota que sube y un toque más fuerte.
  void _comboUp(int n, {bool sound = true}) {
    if (sound) {
      _after(90, () => _audio.play(Sfx.formStep, variant: math.min(n - 2, 4)));
    }
    if (n >= 4) {
      Haptics.mediumImpact();
    } else {
      Haptics.lightImpact();
    }
  }

  void _enemyTurn(CombatView prev, CombatView next) {
    final ev = next.events;
    // Si un desvío voltea al enemigo de un grupo, se lo ve caer al final.
    final wave = ev.whereType<WaveStarted>().firstOrNull;
    final nowUids = {for (final c in next.state.hand) c.uid};
    setState(() {
      _combo = 0;
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
    if (ev.any((e) => e is BreatherOffered)) {
      _after(at, _offerBreather);
      at += _waveGap + 200;
    } else if (wave != null) {
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

  /// Victoria: estalla el último en caer ([slot]). A una élite o a un jefe
  /// se lo remata: trazo de pincel, sello 破 y cámara lenta más larga.
  void _win([int slot = 0]) {
    final enemies =
        (_shown ?? ref.read(combatControllerProvider))?.state.enemies;
    final id =
        enemies != null && slot < enemies.length ? enemies[slot].id : null;
    final grand = id != null &&
        ref.read(dataProvider).enemy(id).rank != EnemyRank.common;
    Haptics.heavyImpact();
    _audio.play(Sfx.enemyDeath);
    if (grand) _audio.play(Sfx.broken);
    setState(() {
      _queue.clear();
      _current = null;
      for (final f in _foes) {
        f.dying = true;
      }
      _foe(slot).burst++;
      _goldFlashKey++;
      _shake(grand ? 14 : 10);
      if (grand) _finishKey++;
    });
    // El último golpe se ve en cámara lenta.
    _dilate(grand ? [(10, 160), (4, 650)] : [(8, 110), (3, 300)]);
    if (grand) {
      _after(380, () {
        Haptics.heavyImpact();
        _audio.play(Sfx.victoryStamp);
      });
    }
    final wait = grand ? 600 : 0;
    _after(450 + wait, () {
      setState(() => _victory = true);
      _audio.play(Sfx.heroVictory);
    });
    _after(1150 + wait, () {
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
          // Se quiebra: congela, cámara lenta y vuelve.
          _goldFlashKey++;
          _dilate([(9, 110), (3, 320)]);
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
          // Tres golpes que bajan, como el eco de la forma.
          Haptics.heavyImpact();
          _after(140, Haptics.mediumImpact);
          _after(300, Haptics.lightImpact);
          _audio.play(Sfx.formComplete);
          _formFlash = formId;
          _after(1600, () {
            if (_formFlash == formId) setState(() => _formFlash = null);
          });
          _formBurstKey++;
          _goldFlashKey++;
          final f = data.forms.firstWhere((f) => f.id == formId);
          // La forma larga se siente más: más lenta y con temblor.
          if (f.isLong) {
            _dilate([(10, 140), (3, 600)]);
            _shake(12);
          } else {
            _dilate([(8, 90), (2.5, 400)]);
          }
          // Pasa adelante de los demás carteles y se queda lo bastante
          // para leer el nombre y lo que dio.
          _queue.insert(
            0,
            _Fx(
              text.form(f.id),
              '${f.hanzi} · ${f.pinyin}',
              Palette.lacquer,
              big: true,
              header: f.isLong
                  ? '${t.formCompleted} · ${t.formLong}'
                  : t.formCompleted,
              detail: t.formEffect(f.effect),
              ms: f.isLong ? 3000 : 2600,
            ),
          );
        case StanceChained(:final cardId, :final from):
          // Cadena de postura: un toque doble y la cinta dorada.
          Haptics.mediumImpact();
          _after(110, Haptics.lightImpact);
          _audio.play(Sfx.formStep, variant: 2);
          final to = data.card(cardId).stance;
          _queue.add(
            _Fx(
              t.chainedFloat,
              to == null
                  ? text.stance(from)
                  : '${text.stance(from)} → ${text.stance(to)}',
              Palette.gold,
            ),
          );
        case StanceCircle(:final breath, :final draw):
          // Círculo cerrado: tres toques que suben, la cinta grande.
          Haptics.heavyImpact();
          _after(120, Haptics.mediumImpact);
          _after(240, Haptics.lightImpact);
          _audio.play(Sfx.formComplete);
          _queue.add(
            _Fx(
              t.circleFloat,
              t.circleSub(breath, draw),
              Palette.gold,
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
        case WeaponTriggered():
          setState(_weaponActs);
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
    // Se quita al terminar su propia animación (ver _FxBanner.onDone): con
    // la cámara lenta de los golpes grandes, un reloj de pared lo cortaba
    // antes de tiempo y sin salida.
  }

  void _fxDone() {
    setState(() => _current = null);
    _pump();
  }

  /// La altura del sendero: metros y sala de la etapa («1.240 m · 4/13»).
  String? _room(CombatView live) {
    final run = ref.read(runControllerProvider);
    if (run == null || run.duel != null || run.currentNode == null) {
      return null;
    }
    if (live.tutorial) return null;
    final engine = ref.read(runEngineProvider);
    return AppLocalizations.of(context).combatAltitude(
      meters(engine.altitudeOf(run)),
      engine.climbed(run),
      engine.depthsOf(run),
    );
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
      weaponHits: _weaponHits,
    );
    final run = live.tutorial ? null : ref.watch(runControllerProvider);
    final node = run?.currentNode == null ? null : run!.node(run.currentNode!);
    final stageId = run == null
        ? data.balance.stage.id
        : data.balance.stages[run.stage].id;

    if (_intro) {
      final def = data.enemy(s.enemy.id);
      final ghost = isGhostFoe(def.id) ? run?.ghost : null;
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
            room: _room(live),
            turn: s.turn,
            style: live.tutorial
                ? null
                : ref.watch(runControllerProvider)?.style,
            talismans: s.talismans,
            weapon: s.weapon,
            weaponLevel: s.weaponLevel,
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
                  reserve: [for (final r in s.reserve) data.enemy(r.id)],
                  index: i,
                  pair: s.enemies.length > 1,
                  targeted: i == s.target,
                  anyChips: s.enemies.any((x) => _hasChips(x, data.enemy(x.id))),
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
          child: _PlayerStrip(s: s, engine: engine, locked: _busy),
        ),
        TutorialAnchor(
          id: 'forms',
          child: _FormsPanel(s: s, data: data, flash: _formFlash),
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
    final inset = MediaQuery.paddingOf(context);
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
              child: ScreenFlash(trigger: _goldFlashKey, color: Palette.gold),
            ),
            Positioned.fill(child: FinisherSeal(trigger: _finishKey)),
            Align(
              alignment: const Alignment(0, -0.62),
              child: ComboCounter(
                count: _combo,
                label: AppLocalizations.of(context).comboHits,
              ),
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
                  child: _FxBanner(
                    key: ValueKey(_fxKey),
                    fx: _current!,
                    onDone: _fxDone,
                  ),
                ),
              ),
            if (_breatherOpen &&
                live.state.phase == CombatPhase.breather &&
                live.state.reserve.isNotEmpty)
              Positioned.fill(
                child: BreatherSheet(
                  options: engine.breathers,
                  nextName: ref.foe(context, live.state.reserve.first.id),
                  heal: engine.breatherHeal(live.state),
                  draw: data.balance.breather.draw,
                  breath: data.balance.breather.breath,
                  fist: data.balance.breather.fist,
                  onPick: _pickBreather,
                ),
              ),
            if (_endShown)
              _EndOverlay(
                won: won,
                inset: inset,
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
