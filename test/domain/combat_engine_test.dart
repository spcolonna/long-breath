import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

final data = loadGameDataFromDir();
final engine = CombatEngine(data);

/// Combate con el mazo en el orden dado (sin barajar): la mano son las
/// primeras cartas.
CombatState setup(
  List<String> ids, {
  String enemy = 'salamander',
  Age age = Age.adult,
  int hp = 50,
}) =>
    engine
        .start(
          deck: [
            for (var i = 0; i < ids.length; i++)
              CombatCard(uid: i, cardId: ids[i]),
          ],
          enemyId: enemy,
          age: age,
          playerHp: hp,
          seed: 1,
          shuffle: false,
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
    test('Gōngbù Chōngquán primero mueve a gōngbù y recibe su bonus', () {
      final s = play(setup(['gongbu_chongquan', ...filler]), 'gongbu_chongquan')
          .state;
      expect(s.player.stance, Stance.gongbu);
      expect(s.enemy.hp, 24 - 9);
      expect(s.enemy.structure, 8 - 2);
      expect(s.player.breath, 2);
    });

    test('mǎbù: puños +2; patadas cuestan +1', () {
      var s = setup(['mabu_chongquan', 'tan_tui', ...filler]);
      s = play(s, 'mabu_chongquan').state;
      expect(s.enemy.hp, 24 - 7);
      final p = engine.preview(s, uidOf(s, 'tan_tui'));
      expect(p.cost, 2);
      expect(p.damage, 5);
    });

    test('xūbù: patadas cuestan 1 menos y hacen +2; defensas −2', () {
      var s = setup(['xubu_liangzhang', 'tan_tui', ...filler]);
      s = play(s, 'xubu_liangzhang').state;
      expect(s.player.stance, Stance.xubu);
      expect(s.player.guard, 5);
      final p = engine.preview(s, uidOf(s, 'tan_tui'));
      expect(p.cost, 0);
      expect(p.damage, 7);
    });

    test('Dīngbù: 1 Aliento, una vez por turno', () {
      var s = setup(filler);
      s = engine.reduce(s, const Dingbu(Stance.gongbu)).state;
      expect(s.player.stance, Stance.gongbu);
      expect(s.player.breath, 2);
      expect(engine.validate(s, const Dingbu(Stance.xubu)), isNotNull);
    });
  });

  group('guardia y altura', () {
    test('altura incorrecta absorbe la mitad', () {
      // Salamandra: bajo 7 (E2). Gé Dǎng es medio 7 → absorbe 3.
      var s = play(setup(filler), 'ge_dang').state;
      s = endTurn(s).state;
      expect(s.player.hp, 50 - 4);
      // bloqueado: 2 → 1, mǎbù ½ → 0
      expect(s.player.structure, 10);
    });

    test('sin guardia en gōngbù recibís +2 a Estructura', () {
      var s = engine.reduce(setup(filler), const Dingbu(Stance.gongbu)).state;
      s = endTurn(s).state;
      expect(s.player.hp, 43);
      expect(s.player.structure, 10 - 4);
    });

    test('desvío: sin daño, enemigo −3 Estructura, +1 Aliento', () {
      var s = setup(['an_zhang', 'ti_xi', ...filler]);
      s = play(s, 'an_zhang').state;
      s = play(s, 'ti_xi').state; // Guardia 12 baja ≥ 7
      final r = endTurn(s);
      s = r.state;
      expect(r.events.whereType<Deflected>(), hasLength(1));
      expect(s.player.hp, 50);
      expect(s.player.structure, 10);
      expect(s.enemy.structure, 8 - 3);
      expect(s.enemy.hp, 24 - 4); // Tí Xī: 4 de daño al desviar
      expect(s.player.breath, 4);
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
      s = play(s, 'xubu_liangzhang').state; // Guardia 5 alta ≥ 3
      s = endTurn(s).state;
      expect(s.player.breath, 5);
      expect(s.enemy.structure, 3);
    });

    test('Hǔ Bào Tóu: el desvío quita 3 de Estructura extra', () {
      var s = setup(['hu_bao_tou', ...filler], enemy: 'bat');
      s = play(s, 'hu_bao_tou').state;
      s = endTurn(s).state;
      expect(s.enemy.structure, 0 + 6 - 6); // se desequilibra
      expect(s.enemy.staggered, isTrue);
    });
  });

  group('estructura y desequilibrio', () {
    test('enemigo desequilibrado pierde su acción y recibe ×2', () {
      var s = setup([
        'tui_zhang', 'mabu_chongquan', 'ge_dang', 'ge_dang', 'an_zhang', //
        'gongbu_chongquan', 'tan_tui', 'ge_dang', 'ge_dang', 'an_zhang',
      ], enemy: 'bat');
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
      expect(p.damage, 18);
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
      expect(r.state.enemy.structure, 12);
      expect(r.state.enemy.staggered, isFalse);
      // reanuda el ciclo: la acción perdida era el ataque, ahora Carga
      expect(r.events.whereType<EnemyCharged>(), hasLength(1));
    });

    test('jugador con Estructura rota empieza con 2 de Aliento menos', () {
      var s = setup(filler);
      s = s.copyWith(player: s.player.copyWith(structure: 1));
      final r = endTurn(s); // bajo 7 E2 → mǎbù 1
      expect(r.events.whereType<PlayerBroken>(), hasLength(1));
      expect(r.state.player.breath, 1);
      expect(r.state.player.structure, 10);
    });

    test('Gólem inamovible: mitad de daño', () {
      final s = play(setup(['gongbu_chongquan', ...filler], enemy: 'golem'),
              'gongbu_chongquan')
          .state;
      expect(s.enemy.hp, 30 - 4);
    });
  });

  group('cartas', () {
    test('Pī Quán +6 contra enemigo desequilibrado', () {
      var s = setup(['pi_quan', ...filler], enemy: 'golem');
      s = s.copyWith(enemy: s.enemy.copyWith(structure: 1));
      s = play(s, 'tui_zhang').state;
      final p = engine.preview(s, uidOf(s, 'pi_quan'));
      expect(p.damage, (6 + 2 + 6) * 2);
    });

    test('Tiáo Xī: +1 Aliento, roba 1 y se agota', () {
      var s = setup(['tiao_xi', ...filler, 'ge_dang']);
      s = play(s, 'tiao_xi').state;
      expect(s.player.breath, 4);
      expect(s.hand.length, 5);
      expect(s.exhausted.map((c) => c.cardId), ['tiao_xi']);
    });

    test('Bàoquán Lǐ solo en el primer turno', () {
      var s = setup(['ge_dang', ...filler, 'baoquan_li', 'ge_dang', 'ge_dang',
          'ge_dang']);
      s = endTurn(s).state;
      expect(engine.validate(s, PlayCard(uidOf(s, 'baoquan_li'))), isNotNull);
    });

    test('Hǔ Xiào: +2 a todo daño a Estructura este turno', () {
      var s = setup(['hu_xiao', 'hu_zhao', ...filler], enemy: 'golem');
      s = play(s, 'hu_xiao').state;
      s = play(s, 'hu_zhao').state; // 4 + 2 (mǎbù) + 2
      expect(s.enemy.structure, 12 - 8);
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
    test('retener según la edad', () {
      var s = setup([...filler, ...filler]);
      final keep = s.hand.first.uid;
      expect(engine.validate(s, EndTurn(retain: [keep, s.hand[1].uid])),
          isNotNull);
      s = endTurn(s, [keep]).state;
      expect(s.hand.length, 5);
      expect(s.hand.any((c) => c.uid == keep), isTrue);
    });

    test('respirar una vez por combate', () {
      var s = setup([...filler, ...filler]);
      s = engine.reduce(s, const Breathe()).state;
      expect(s.hand.map((c) => c.uid), [5, 6, 7, 8, 9]);
      expect(engine.validate(s, const Breathe()), isNotNull);
    });

    test('mismo seed, misma mano', () {
      CombatState start(int seed) => engine
          .start(
            deck: [
              for (final (i, id) in data.starterDeck.indexed)
                CombatCard(uid: i, cardId: id),
            ],
            enemyId: 'bat',
            age: Age.adult,
            playerHp: 50,
            seed: seed,
          )
          .state;
      expect(start(42).hand.map((c) => c.uid), start(42).hand.map((c) => c.uid));
    });
  });

  group('formas', () {
    const xhq = 'xiao_hong_quan';

    test('Xiǎo Hóng Quán completa en dos turnos', () {
      var s = setup([
        'gongbu_chongquan', 'tan_tui', 'mabu_jiada', 'ge_dang', 'ge_dang',
        'an_zhang', //
        'xubu_liangzhang', 'tui_zhang', 'tui_zhang', 'tui_zhang', 'tui_zhang',
        'tui_zhang', 'tui_zhang', 'tui_zhang',
      ], enemy: 'golem', age: Age.young);
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
      expect(r.state.enemy.hp, hpBefore - 5); // 10 a la mitad (Gólem)
      expect(r.state.formsCompleted[xhq], 1);
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
      var s = setup(['gongbu_chongquan', 'tan_tui', 'gongbu_chongquan', 'ge_dang',
          'ge_dang']);
      s = play(s, 'gongbu_chongquan').state;
      s = play(s, 'tan_tui').state;
      expect(s.formProgress[xhq], 2);
      s = play(s, 'gongbu_chongquan').state;
      expect(s.formProgress[xhq], 1);
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
      var s = setup([...filler, ...filler]);
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 1));
      s = endTurn(s).state;
      expect(s.enemy.guard, 8);
      s = play(s, 'tui_zhang').state; // 4 daño, 4 E
      expect(s.enemy.hp, 24);
      expect(s.enemy.guard, 4);
      expect(s.enemy.structure, 4);
    });

    test('Gólem: Carga suma +5 al próximo ataque', () {
      var s = setup([...filler, ...filler], enemy: 'golem');
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 1));
      s = endTurn(s).state;
      expect(engine.intentView(s).damage, 15);
    });

    test('Discípulo: misma postura dos turnos → +4 daño y +2 E', () {
      var s = setup([...filler, ...filler, ...filler], enemy: 'disciple');
      s = endTurn(s).state; // alto 6 (E2): 50 → 44
      expect(engine.intentView(s).punishIfSameStance, isTrue);
      s = endTurn(s).state; // medio 8 + 4
      expect(s.player.hp, 44 - 12);
    });

    test('Murciélago: Chillido obliga a descartar', () {
      var s = setup([...filler, ...filler, ...filler, ...filler], enemy: 'bat');
      s = s.copyWith(enemy: s.enemy.copyWith(patternIndex: 2));
      s = endTurn(s).state;
      expect(s.phase, CombatPhase.discarding);
      expect(engine.validate(s, const EndTurn()), isNotNull);
      s = engine.reduce(s, ChooseDiscard(s.hand.first.uid)).state;
      expect(s.phase, CombatPhase.playerTurn);
      expect(s.hand.length, 4);
    });

    test('Eco del Dragón: fase 2 al 50% con cuenta regresiva', () {
      var s = setup(['gongbu_chongquan', ...filler], enemy: 'dragon');
      s = s.copyWith(enemy: s.enemy.copyWith(hp: 50));
      final r = play(s, 'gongbu_chongquan');
      s = r.state;
      expect(r.events.whereType<EnemyPhaseChanged>(), hasLength(1));
      expect(s.enemy.phaseIndex, 1);
      expect(engine.intentView(s).countdown, 2);
      s = endTurn(s).state;
      expect(engine.intentView(s).countdown, 1);
    });
  });
}
