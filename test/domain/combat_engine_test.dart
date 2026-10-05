import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enemy_def.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

final data = loadGameDataFromDir();
final engine = CombatEngine(data);

/// Combate con el mazo en el orden dado (sin barajar): la mano son las
/// primeras cartas.
CombatState setup(
  List<String> ids, {
  String enemy = 'salamander',
  // Grulla: su pasiva solo toca cartas retenidas, así los números de las
  // pruebas son los de la carta y la postura.
  Style style = Style.crane,
  int hp = 50,
  List<String>? forms,
  List<String> talismans = const [],
}) => engine
    .start(
      deck: [
        for (var i = 0; i < ids.length; i++) CombatCard(uid: i, cardId: ids[i]),
      ],
      enemyId: enemy,
      style: style,
      playerHp: hp,
      seed: 1,
      shuffle: false,
      forms: forms,
      talismans: talismans,
    )
    .state;

int uidOf(CombatState s, String cardId) =>
    s.hand.firstWhere((c) => c.cardId == cardId).uid;

CombatResult play(CombatState s, String cardId) =>
    engine.reduce(s, PlayCard(uidOf(s, cardId)));

CombatResult endTurn(CombatState s, [List<int> retain = const []]) =>
    engine.reduce(s, EndTurn(retain: retain));

const filler = ['ge_dang', 'ge_dang', 'an_zhang', 'tui_zhang', 'tan_tui'];

void main() {
  group('posturas', () {
    test('la carta pega con tu postura y después te deja en la suya', () {
      var s = setup(['gongbu_chongquan', 'gongbu_chongquan', ...filler]);
      var p = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
      expect(p.damage, 8, reason: 'pega desde mǎbù: puño +2');
      expect(p.stanceAfter, Stance.gongbu);
      s = play(s, 'gongbu_chongquan').state;
      expect(s.player.stance, Stance.gongbu);
      expect(s.enemy.hp, 63 - 8);
      expect(s.enemy.structure, 14 - 1);
      expect(s.player.breath, 3);
      // El segundo ya pega desde gōngbù: +3 y +1 de Estructura.
      s = play(s, 'gongbu_chongquan').state;
      expect(s.enemy.hp, 63 - 8 - 9);
      expect(s.enemy.structure, 14 - 1 - 2);
    });

    test('mǎbù: puños +2; patadas cuestan +1', () {
      var s = setup([
        'mabu_chongquan',
        'tan_tui',
        'gongbu_chongquan',
        ...filler,
      ]);
      s = play(s, 'mabu_chongquan').state;
      expect(s.enemy.hp, 63 - 7);
      final p = engine.preview(s, uidOf(s, 'tan_tui'));
      expect(p.cost, 2);
      expect(p.damage, 5);
      expect(p.stanceCost, 1, reason: 'la UI lo marca ▼');
      expect(p.stanceDamage, 0);
      final fist = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
      expect(fist.stanceDamage, 2, reason: 'la UI lo marca ▲');
    });

    test('xūbù: patadas cuestan 1 menos y hacen +2; defensas −2', () {
      var s = setup(['xubu_liangzhang', 'tan_tui', ...filler]);
      s = play(s, 'xubu_liangzhang').state;
      expect(s.player.stance, Stance.xubu);
      expect(s.player.guard, 7, reason: 'se jugó desde mǎbù');
      final p = engine.preview(s, uidOf(s, 'tan_tui'));
      expect(p.cost, 0);
      expect(p.damage, 7);
      expect(p.stanceCost, -1);
      expect(p.stanceDamage, 2);
      final def = engine.preview(s, uidOf(s, 'ge_dang'));
      expect(def.stanceGuard, -2);
    });

    test('Dīngbù: 1 Aliento, una vez por turno', () {
      var s = setup(filler);
      s = engine.reduce(s, const Dingbu(Stance.gongbu)).state;
      expect(s.player.stance, Stance.gongbu);
      expect(s.player.breath, 3);
      expect(engine.validate(s, const Dingbu(Stance.xubu)), isNotNull);
    });
  });

  group('guardia y altura', () {
    test('altura incorrecta absorbe la mitad', () {
      // Salamandra: bajo 8 (E2). Gé Dǎng es medio 7 → absorbe 3.
      var s = play(setup(filler), 'ge_dang').state;
      s = endTurn(s).state;
      expect(s.player.hp, 50 - 5);
      // bloqueado: 2 → 1, mǎbù ½ → 0
      expect(s.player.structure, 10);
    });

    test('sin guardia en gōngbù recibís +2 a Estructura', () {
      var s = engine.reduce(setup(filler), const Dingbu(Stance.gongbu)).state;
      s = endTurn(s).state;
      expect(s.player.hp, 42);
      expect(s.player.structure, 10 - 4);
    });

    test('desvío: sin daño, enemigo −3 Estructura, +1 Aliento', () {
      var s = setup(['an_zhang', 'ti_xi', ...filler]);
      s = play(s, 'an_zhang').state;
      s = play(s, 'ti_xi').state; // Guardia 14 baja ≥ 8
      final r = endTurn(s);
      s = r.state;
      expect(r.events.whereType<Deflected>(), hasLength(1));
      expect(s.player.hp, 50);
      expect(s.player.structure, 10);
      expect(s.enemy.structure, 14 - 3);
      expect(s.enemy.hp, 63 - 5); // Tí Xī: 5 de daño al desviar
      expect(s.player.breath, 5);
    });

    test('ataque doble: la guardia se aplica a cada golpe', () {
      // Murciélago: alto 3×2. Gé Dǎng es medio → absorbe 3 por golpe.
      var s = setup(filler, enemy: 'bat');
      s = play(s, 'ge_dang').state;
      s = endTurn(s).state;
      expect(s.player.hp, 50);
    });

    test('desvío en xūbù da +1 Aliento extra', () {
      var s = setup(['xubu_liangzhang', ...filler], enemy: 'bat');
      s = play(s, 'xubu_liangzhang').state; // Guardia 7 alta ≥ 3
      s = endTurn(s).state;
      expect(s.player.breath, 6);
      expect(s.enemy.structure, 11 - 3);
    });

    test('Hǔ Bào Tóu: el desvío quita 3 de Estructura extra', () {
      var s = setup(['hu_bao_tou', ...filler], enemy: 'bat');
      s = s.copyWith(enemy: s.enemy.copyWith(structure: 6));
      s = play(s, 'hu_bao_tou').state;
      s = endTurn(s).state;
      expect(s.enemy.structure, 6 - 3 - 3); // se desequilibra
      expect(s.enemy.staggered, isTrue);
    });
  });

  group('estructura y desequilibrio', () {
    test('enemigo desequilibrado pierde su acción y recibe ×2', () {
      var s = setup([
        'tui_zhang', 'mabu_chongquan', 'ge_dang', 'ge_dang', 'an_zhang', //
        'gongbu_chongquan', 'tan_tui', 'ge_dang', 'ge_dang', 'an_zhang',
      ], enemy: 'bat');
      s = s.copyWith(enemy: s.enemy.copyWith(hp: 18, structure: 6));
      s = play(s, 'tui_zhang').state; // 4 daño, 4 E
      final r1 = play(s, 'mabu_chongquan'); // 7 daño, 2 E → rota
      s = r1.state;
      expect(r1.events.whereType<EnemyBroken>(), hasLength(1));
      expect(s.enemy.hp, 7);
      final r2 = endTurn(s);
      s = r2.state;
      expect(r2.events.whereType<EnemyActionSkipped>(), hasLength(1));
      expect(s.player.hp, 50);
      expect(s.enemy.staggered, isTrue);
      final p = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
      expect(p.damage, 16, reason: '(6 + 2 de mǎbù) ×2');
      s = play(s, 'gongbu_chongquan').state;
      expect(s.phase, CombatPhase.won);
    });

    test('se recupera al final de tu próximo turno', () {
      var s = setup([...filler, ...filler], enemy: 'golem');
      s = s.copyWith(enemy: s.enemy.copyWith(structure: 2));
      s = play(s, 'tui_zhang').state; // 4 E → rota
      expect(s.enemy.staggered, isTrue);
      s = endTurn(s).state; // pierde la acción
      final r = endTurn(s);
      expect(r.events.whereType<EnemyRecovered>(), hasLength(1));
      expect(r.state.enemy.structure, 16);
      expect(r.state.enemy.staggered, isFalse);
      // reanuda el ciclo: la acción perdida era el ataque, ahora Carga
      expect(r.events.whereType<EnemyCharged>(), hasLength(1));
    });

    test('jugador con Estructura rota empieza con 2 de Aliento menos', () {
      var s = setup(filler);
      s = s.copyWith(player: s.player.copyWith(structure: 1));
      final r = endTurn(s); // bajo 8 E2 → mǎbù 1
      expect(r.events.whereType<PlayerBroken>(), hasLength(1));
      expect(r.state.player.breath, 2);
      expect(r.state.player.structure, 10);
    });

    test('Gólem inamovible: mitad de daño', () {
      final s = play(
        setup(['gongbu_chongquan', ...filler], enemy: 'golem'),
        'gongbu_chongquan',
      ).state;
      expect(s.enemy.hp, 70 - 4);
    });
  });

  group('cartas', () {
    test('Pī Quán +6 contra enemigo desequilibrado', () {
      var s = setup(['pi_quan', 'tui_zhang', ...filler], enemy: 'golem');
      s = s.copyWith(enemy: s.enemy.copyWith(structure: 1));
      s = play(s, 'tui_zhang').state;
      final p = engine.preview(s, uidOf(s, 'pi_quan'));
      expect(p.damage, (8 + 2 + 6) * 2);
    });

    test('Tiáo Xī: +1 Aliento, roba 1 y se agota', () {
      var s = setup(['tiao_xi', ...filler, 'ge_dang']);
      s = play(s, 'tiao_xi').state;
      expect(s.player.breath, 5);
      expect(s.hand.length, 4);
      expect(s.exhausted.map((c) => c.cardId), ['tiao_xi']);
    });

    test('Bàoquán Lǐ: roba 2 y se agota', () {
      var s = setup(['baoquan_li', ...filler]);
      s = play(s, 'baoquan_li').state;
      expect(s.player.breath, 4);
      expect(s.hand.length, 3 + 2);
      expect(s.exhausted.map((c) => c.cardId), ['baoquan_li']);
    });

    test('Hǔ Xiào: +2 a todo daño a Estructura este turno', () {
      var s = setup(['hu_xiao', 'hu_zhao', ...filler], enemy: 'golem');
      s = play(s, 'hu_xiao').state;
      s = play(s, 'hu_zhao').state; // 5 + 2 (mǎbù) + 2
      expect(s.enemy.structure, 16 - 9);
    });

    test('Hǔ Pū: perdés toda tu Guardia', () {
      var s = setup(['ge_dang', 'hu_pu', ...filler]);
      s = play(s, 'ge_dang').state;
      s = play(s, 'hu_pu').state;
      expect(s.player.guard, 0);
      expect(s.player.stance, Stance.gongbu);
    });
  });

  group('mano', () {
    test('retener según el camino', () {
      var s = setup([...filler, ...filler], style: Style.snake);
      final keep = s.hand.first.uid;
      expect(
        engine.validate(
          s,
          EndTurn(retain: [keep, s.hand[1].uid, s.hand[2].uid]),
        ),
        isNotNull,
      );
      s = endTurn(s, [keep]).state;
      // La retenida es extra: se roba la mano completa igual.
      expect(s.hand.length, 5);
      expect(s.hand.any((c) => c.uid == keep), isTrue);
    });

    test('respirar una vez por combate', () {
      var s = setup([...filler, ...filler]);
      final before = s.player.breath;
      s = engine.reduce(s, const Breathe()).state;
      expect(s.hand.map((c) => c.uid), [4, 5, 6, 7]);
      expect(s.player.breath, before - data.balance.breatheCost);
      expect(engine.validate(s, const Breathe()), isNotNull);
    });

    test('respirar sin Aliento no se puede', () {
      var s = setup([...filler, ...filler]);
      while (s.player.breath > 0) {
        s = engine.reduce(s, PlayCard(s.hand.first.uid)).state;
      }
      expect(engine.validate(s, const Breathe()), Invalid.noBreath);
    });

    test('mismo seed, misma mano', () {
      CombatState start(int seed) => engine
          .start(
            deck: [
              for (final (i, id) in data.starterDeck.indexed)
                CombatCard(uid: i, cardId: id),
            ],
            enemyId: 'bat',
            style: Style.snake,
            playerHp: 50,
            seed: seed,
          )
          .state;
      expect(
        start(42).hand.map((c) => c.uid),
        start(42).hand.map((c) => c.uid),
      );
    });
  });

  group('formas', () {
    const xhq = 'xiao_hong_quan';

    test('Xiǎo Hóng Quán completa en dos turnos', () {
      var s = setup(
        [
          'gongbu_chongquan', 'tan_tui', 'mabu_jiada', 'ge_dang', 'ge_dang',
          'an_zhang', //
          'xubu_liangzhang', 'tui_zhang', 'tui_zhang', 'tui_zhang', 'tui_zhang',
          'tui_zhang', 'tui_zhang', 'tui_zhang',
        ],
        enemy: 'golem',
        style: Style.tiger,
      );
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'tan_tui').state;
      s = play(s, 'mabu_jiada').state;
      expect(s.formProgress[xhq], 3);
      s = endTurn(s).state;
      final hpBefore = s.enemy.hp;
      final p = engine.preview(s, uidOf(s, 'xubu_liangzhang'));
      expect(p.completesForms, [xhq]);
      final r = play(s, 'xubu_liangzhang');
      expect(r.events.whereType<FormCompleted>(), hasLength(1));
      expect(r.state.formProgress[xhq], 0);
      expect(r.state.enemy.hp, hpBefore - 7); // 14 a la mitad (Gólem)
      expect(r.state.formsCompleted[xhq], 1);
    });

    test('una forma que no se aprendió no avanza', () {
      var s = setup(['gongbu_chongquan', 'tan_tui', ...filler], forms: []);
      expect(s.formProgress, isEmpty);
      final p = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
      expect(p.advancesForms, isEmpty);
      final r = play(s, 'gongbu_chongquan');
      expect(r.events.whereType<FormAdvanced>(), isEmpty);
    });

    test('Puño de los cinco pasos: +2 Aliento y roba 1', () {
      var s = setup(
        ['gongbu_chongquan', 'tan_tui', 'mabu_chongquan', ...filler],
        forms: ['wu_bu_quan'],
      );
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'tan_tui').state;
      final before = s.player.breath;
      final hand = s.hand.length;
      final r = play(s, 'mabu_chongquan');
      expect(r.events.whereType<BreathGained>().single.amount, 2);
      expect(r.state.player.breath, before - 1 + 2);
      expect(r.state.hand.length, hand - 1 + 1);
    });

    test('Puño de la Serpiente: cura y da guardia', () {
      var s = setup(
        ['tui_zhang', 'she_tu_xin', 'she_xing_shou', ...filler],
        hp: 30,
        forms: ['she_quan'],
        style: Style.snake,
      );
      s = play(s, 'tui_zhang').state;
      s = play(s, 'she_tu_xin').state;
      final r = play(s, 'she_xing_shou');
      expect(r.events.whereType<FormCompleted>(), isNotEmpty);
      expect(r.events.whereType<PlayerHealed>().single.amount, 6);
      expect(r.state.player.hp, 36);
      expect(r.state.player.guard, s.player.guard + 6);
    });

    test('Puño encadenado: los puños pegan +2 el resto del combate', () {
      var s = setup(
        ['gongbu_chongquan', 'pi_quan', 'mabu_chongquan', 'gongbu_chongquan',
          'ge_dang'],
        forms: ['lian_huan_quan'],
      );
      final before = engine.preview(s, uidOf(s, 'gongbu_chongquan')).damage;
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'pi_quan').state;
      final r = play(s, 'mabu_chongquan');
      expect(r.events.whereType<FistBonusGained>().single.total, 2);
      expect(r.state.fistBonus, 2);
      // Mismo puño, misma postura (mǎbù) que al principio: +2.
      final after =
          engine.preview(r.state, uidOf(r.state, 'gongbu_chongquan')).damage;
      expect(after, before + 2);
    });

    test('un ataque fuera de secuencia interrumpe; una defensa no', () {
      var s = setup(['gongbu_chongquan', 'ge_dang', 'tui_zhang', ...filler]);
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'ge_dang').state;
      expect(s.formProgress[xhq], 1);
      final p = engine.preview(s, uidOf(s, 'tui_zhang'));
      expect(p.interruptsForms, contains(xhq));
      s = play(s, 'tui_zhang').state;
      expect(s.formProgress[xhq], 0);
    });

    test('si la carta es el primer paso, la forma reinicia en 1', () {
      var s = setup([
        'gongbu_chongquan',
        'tan_tui',
        'gongbu_chongquan',
        'ge_dang',
        'ge_dang',
      ]);
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'tan_tui').state;
      expect(s.formProgress[xhq], 2);
      s = play(s, 'gongbu_chongquan').state;
      expect(s.formProgress[xhq], 1);
    });

    test('reiniciar en el paso 1 no se marca como interrupción', () {
      var s = setup(['gongbu_chongquan', 'gongbu_chongquan', ...filler]);
      s = play(s, 'gongbu_chongquan').state;
      final p = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
      expect(p.interruptsForms, isNot(contains(xhq)));
    });

    test('Interrumpir del Monje reinicia las formas si no se desvía', () {
      var s = setup(['gongbu_chongquan', ...filler], enemy: 'monk');
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 1));
      s = play(s, 'gongbu_chongquan').state;
      expect(s.formProgress[xhq], 1);
      final r = endTurn(s);
      expect(r.events.whereType<FormsResetByEnemy>(), hasLength(1));
      expect(r.state.formProgress[xhq], 0);
    });
  });

  group('enemigos', () {
    test('Salamandra: su Guardia absorbe daño pero no Estructura', () {
      var s = setup(['tan_tui', 'ge_dang', 'ge_dang', 'an_zhang', ...filler]);
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 1));
      s = endTurn(s).state;
      expect(s.enemy.guard, 9);
      s = play(s, 'tui_zhang').state; // 4 daño, 4 E
      expect(s.enemy.hp, 63);
      expect(s.enemy.guard, 5);
      expect(s.enemy.structure, 14 - 4);
    });

    test('Gólem: Carga suma +6 al próximo ataque', () {
      var s = setup([...filler, ...filler], enemy: 'golem');
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 1));
      s = endTurn(s).state;
      expect(engine.intentView(s).damage, 18);
    });

    test('Discípulo: misma postura dos turnos → +5 daño y +2 E', () {
      var s = setup([...filler, ...filler, ...filler], enemy: 'disciple');
      s = endTurn(s).state; // alto 7 (E2): 50 → 43
      expect(engine.intentView(s).punishIfSameStance, isTrue);
      s = endTurn(s).state; // medio 9 + 5
      expect(s.player.hp, 43 - 14);
    });

    test('Murciélago: Chillido obliga a descartar', () {
      var s = setup([...filler, ...filler, ...filler, ...filler], enemy: 'bat');
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 2));
      s = endTurn(s).state;
      expect(s.phase, CombatPhase.discarding);
      expect(engine.validate(s, const EndTurn()), isNotNull);
      s = engine.reduce(s, ChooseDiscard(s.hand.first.uid)).state;
      expect(s.phase, CombatPhase.playerTurn);
      expect(s.hand.length, 3);
    });

    test('Eco del Dragón: fase 2 al 50% con cuenta regresiva', () {
      var s = setup(['gongbu_chongquan', ...filler], enemy: 'dragon');
      s = s.copyWith(enemy: s.enemy.copyWith(hp: 88));
      final r = play(s, 'gongbu_chongquan');
      s = r.state;
      expect(r.events.whereType<EnemyPhaseChanged>(), hasLength(1));
      expect(s.enemy.phaseIndex, 1);
      expect(engine.intentView(s).countdown, 2);
      s = endTurn(s).state;
      expect(engine.intentView(s).countdown, 1);
    });

    test(
      'Eco del Dragón: fase 3 al 30%, le crecen escamas y el Aliento llega antes',
      () {
        var s = setup(['gongbu_chongquan', ...filler], enemy: 'dragon');
        // En fase 2, sin escamas y apenas arriba del 30% (52,5 de 175).
        s = s.copyWith(
          enemy: s.enemy.copyWith(hp: 55, phaseIndex: 1, scales: 0),
        );
        final r = play(s, 'gongbu_chongquan');
        s = r.state;
        expect(r.events.whereType<EnemyPhaseChanged>().single.phase, 2);
        expect(r.events.whereType<ScalesRegrown>().single.scales, 2);
        expect(s.enemy.scales, 2);
        // Barrido doble y después el Aliento: una acción de aviso.
        expect(engine.intentView(s).countdown, 1);
      },
    );

    test(
      'Eco del Dragón: las escamas restan daño y se caen al desequilibrarlo',
      () {
        final deck = ['gongbu_chongquan', ...filler];
        final vsSalamander = setup(deck);
        var s = setup(deck, enemy: 'dragon');
        expect(s.enemy.scales, 4);
        final plain = engine.preview(
          vsSalamander,
          uidOf(vsSalamander, 'gongbu_chongquan'),
        );
        final scaled = engine.preview(s, uidOf(s, 'gongbu_chongquan'));
        expect(scaled.damage, plain.damage - 4);
        // A un punto de Estructura: el golpe lo desequilibra y pierde una escama.
        s = s.copyWith(enemy: s.enemy.copyWith(structure: 1));
        final r = play(s, 'gongbu_chongquan');
        expect(r.events.whereType<EnemyBroken>(), hasLength(1));
        expect(r.events.whereType<ScaleShed>().single.remaining, 3);
        expect(r.state.enemy.scales, 3);
      },
    );
  });

  group('dificultad', () {
    CombatState start(
      Difficulty d, {
      int pico = 0,
      String enemy = 'salamander',
    }) => engine
        .start(
          deck: [
            for (final (i, id) in filler.indexed)
              CombatCard(uid: i, cardId: id),
          ],
          enemyId: enemy,
          pico: pico,
          style: Style.snake,
          playerHp: 50,
          seed: 1,
          shuffle: false,
          difficulty: d,
        )
        .state;

    test('Normal deja los números de los datos', () {
      final s = start(Difficulty.normal);
      expect(s.enemy.maxHp, 63);
      expect(
        engine.intentView(s).damage,
        data.enemy('salamander').phases.first.pattern.first.damage,
      );
    });

    test('los Picos se acumulan y separan por rango', () {
      // Pico 1: solo las élites.
      expect(start(Difficulty.normal, pico: 1).enemy.maxHp, 63);
      expect(
        start(Difficulty.normal, pico: 1, enemy: 'monk').enemy.maxHp,
        (128 * 1.15).round(),
      );
      // Pico 6: daño del 4 y Estructura del 6, sin tocar la Vida común.
      final s = start(Difficulty.normal, pico: 6);
      expect(s.enemy.maxHp, 63);
      expect(s.enemy.maxStructure, (14 * 1.1).round());
      expect(
        engine.intentView(s).damage,
        (engine.intentView(start(Difficulty.normal)).damage * 1.05).round(),
      );
      // Pico 10 sobre las reglas anteriores: jefe +10 +10 +8.
      expect(
        start(Difficulty.normal, pico: 10, enemy: 'dragon').enemy.maxHp,
        (193 * 1.28).round(),
      );
    });

    test('Shifu sube Vida, Estructura y daño enemigos', () {
      final normal = start(Difficulty.normal);
      final s = start(Difficulty.shifu);
      expect(s.enemy.maxHp, (63 * 1.2).round());
      expect(s.enemy.maxStructure, (14 * 1.1).round());
      expect(
        engine.intentView(s).damage,
        (engine.intentView(normal).damage * 1.2).round(),
      );
    });
  });

  group('talismanes', () {
    test('al empezar: postura, Estructura, Aliento y rival debilitado', () {
      final r = engine.start(
        deck: [
          for (final (i, id) in filler.indexed) CombatCard(uid: i, cardId: id),
        ],
        enemyId: 'salamander',
        style: Style.snake,
        playerHp: 50,
        seed: 1,
        shuffle: false,
        talismans: ['arco', 'roca', 'aliento', 'primer', 'grieta', 'fuente'],
      );
      final s = r.state;
      expect(s.player.stance, Stance.gongbu);
      expect(s.player.structure, 14);
      expect(s.player.maxStructure, 14);
      expect(s.player.breath, 5, reason: 'Serpiente 4 + 1 del talismán');
      expect(s.enemy.hp, 63 - 6);
      expect(s.enemy.maxHp, 63);
      expect(s.enemy.structure, 14 - 3);
      expect(
        r.events.whereType<TalismanTriggered>().map((e) => e.talismanId),
        ['arco', 'roca', 'aliento', 'primer', 'grieta'],
        reason: 'la fuente actúa en el mapa, no en el combate',
      );
      // El Aliento extra es solo del primer turno.
      expect(endTurn(s).state.player.breath, 4);
    });

    test('desvío: el talismán suma Aliento al turno siguiente', () {
      var s = setup(['an_zhang', 'ti_xi', ...filler], talismans: ['desvio']);
      s = play(s, 'an_zhang').state;
      s = play(s, 'ti_xi').state;
      final r = endTurn(s);
      expect(r.events.whereType<TalismanTriggered>(), hasLength(1));
      expect(r.state.player.breath, 5 + 2);
    });

    test('forma completa: el talismán cura', () {
      var s = setup(
        ['gongbu_chongquan', 'tan_tui', 'mabu_chongquan', ...filler],
        forms: ['wu_bu_quan'],
        talismans: ['formas'],
        hp: 30,
      );
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'tan_tui').state;
      final r = play(s, 'mabu_chongquan');
      expect(r.events.whereType<FormCompleted>(), hasLength(1));
      expect(r.events.whereType<TalismanTriggered>(), hasLength(1));
      expect(r.state.player.hp, 38);
    });
  });

  group('pasivas de los caminos', () {
    int dmg(CombatState s, String id) =>
        engine.preview(s, uidOf(s, id)).damage;

    test('Tigre: el primer ataque del turno pega +3', () {
      final base = setup(['tan_tui', 'tan_tui', ...filler], style: Style.crane);
      var s = setup(['tan_tui', 'tan_tui', ...filler], style: Style.tiger);
      expect(dmg(s, 'tan_tui'), dmg(base, 'tan_tui') + 3);
      expect(engine.preview(s, uidOf(s, 'tan_tui')).styleDamage, 3);
      s = play(s, 'tan_tui').state;
      expect(dmg(s, 'tan_tui'), dmg(base, 'tan_tui'));
    });

    test('Serpiente: cada ataque suma +1 por los anteriores del turno', () {
      var s = setup(['tan_tui', 'tan_tui', 'tan_tui', ...filler],
          style: Style.snake);
      final first = dmg(s, 'tan_tui');
      s = play(s, 'tan_tui').state;
      expect(dmg(s, 'tan_tui'), first + 1);
      s = play(s, 'tan_tui').state;
      expect(dmg(s, 'tan_tui'), first + 2);
      // Las defensas no cuentan ni reciben la cadena.
      expect(s.attacksThisTurn, 2);
      s = endTurn(s).state;
      expect(s.attacksThisTurn, 0);
    });

    test('Mano de serpiente: +2 por cada ataque anterior, más la cadena', () {
      var s = setup(['tan_tui', 'tan_tui', 'she_xing_shou', ...filler],
          style: Style.snake);
      final alone = dmg(s, 'she_xing_shou');
      s = play(s, 'tan_tui').state;
      s = play(s, 'tan_tui').state;
      expect(dmg(s, 'she_xing_shou'), alone + 2 * (2 + 1));
    });

    test('Grulla: la carta retenida cuesta 1 menos y Pico pega +6', () {
      var s = setup(['he_zui', 'mabu_jiada', ...filler, ...filler],
          style: Style.crane);
      final zui = uidOf(s, 'he_zui');
      final jiada = uidOf(s, 'mabu_jiada');
      final fresh = dmg(s, 'he_zui');
      final jiadaCost = engine.preview(s, jiada).cost;
      s = endTurn(s, [zui, jiada]).state;
      expect(engine.preview(s, jiada).cost, jiadaCost - 1);
      expect(engine.preview(s, jiada).retained, isTrue);
      expect(dmg(s, 'he_zui'), fresh + 6);
      // Al siguiente fin de turno, lo no retenido deja de serlo.
      s = endTurn(s).state;
      expect(s.retained, isEmpty);
    });

    test('Respirar borra las retenidas', () {
      var s = setup(['he_zui', ...filler, ...filler], style: Style.crane);
      s = endTurn(s, [uidOf(s, 'he_zui')]).state;
      s = engine.reduce(s, const Breathe()).state;
      expect(s.retained, isEmpty);
    });
  });

  group('élites y comunes nuevos', () {
    test('Abanico: el primer golpe del turno no hace daño y te devuelve 3', () {
      var s = setup([
        'gongbu_chongquan',
        'gongbu_chongquan',
        ...filler,
      ], enemy: 'fan');
      expect(s.enemy.parryReady, isTrue);
      final r = play(s, 'gongbu_chongquan');
      s = r.state;
      expect(r.events.whereType<Parried>().single.damage, 3);
      expect(s.enemy.hp, 100, reason: 'no le entra daño');
      expect(s.enemy.structure, 19 - 1, reason: 'la Estructura sí');
      expect(s.player.hp, 47);
      expect(s.enemy.parryReady, isFalse);
      s = play(s, 'gongbu_chongquan').state;
      expect(s.enemy.hp, 100 - 9, reason: 'el segundo golpe entra');
    });

    test('León: despierta +3 por acción y lo suma a sus golpes', () {
      var s = setup([...filler, ...filler, ...filler], enemy: 'lion');
      final base = engine.intentView(s).damage;
      s = endTurn(s).state;
      expect(s.enemy.wrath, 3);
      s = endTurn(s).state; // Piel de piedra: también despierta.
      expect(s.enemy.wrath, 6);
      final iv = engine.intentView(s);
      expect(iv.intent.labelKey, 'pounce');
      expect(iv.damage, greaterThan(base));
    });

    test('Bandido: tantea y al turno siguiente avisa el bastonazo', () {
      var s = setup([...filler, ...filler, ...filler], enemy: 'bandit');
      var iv = engine.intentView(s);
      expect(iv.intent.labelKey, 'staff_jab');
      expect(iv.countdown, 1);
      s = endTurn(s).state;
      iv = engine.intentView(s);
      expect(iv.intent.labelKey, 'staff_smash');
      expect(iv.countdown, 0);
      expect(iv.damage, 15);
    });

    test('Mono: roba jade con cada golpe y en su tercera acción se escapa', () {
      var s = setup(
        [...filler, ...filler, ...filler, ...filler],
        enemy: 'monkey',
        hp: 80,
      );
      for (var i = 0; i < 2; i++) {
        s = endTurn(s).state;
      }
      expect(s.enemy.stolen, 4 * 4, reason: '2 + 2 golpes');
      expect(engine.intentView(s).intent.kind, IntentKind.flee);
      final r = endTurn(s);
      expect(r.events.whereType<EnemyFled>().single.stolen, 16);
      expect(r.state.phase, CombatPhase.won);
      expect(r.state.enemy.fled, isTrue);
    });
  });
}
