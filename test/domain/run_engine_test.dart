import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// El mapa de antes (fijo): los tests de reglas recorren siempre el mismo.
final _legacy = [
  for (final (id, type, enemy, next) in [
    ('n1', NodeType.combat, 'bat', ['n2', 'e1']),
    ('n2', NodeType.combat, 'disciple', ['ns']),
    ('e1', NodeType.event, null, ['ns']),
    ('ns', NodeType.shrine, null, ['n3a', 'n3b']),
    ('n3a', NodeType.combat, 'golem', ['e2']),
    ('n3b', NodeType.combat, 'salamander', ['e2']),
    ('e2', NodeType.event, null, ['n4']),
    ('n4', NodeType.fountain, null, ['n5']),
    ('n5', NodeType.combat, 'monk', ['n6']),
    ('n6', NodeType.combat, 'dragon', <String>[]),
  ])
    MapNodeDef(id: id, type: type, enemy: enemy, next: next),
];

void main() {
  final run = RunEngine(loadGameDataFromDir());

  RunState fresh(int seed, {Difficulty difficulty = Difficulty.normal}) => run
      .newRun(seed: seed, difficulty: difficulty)
      .copyWith(map: _legacy);

  test('camino completo con bifurcación, recompensa y fuente', () {
    var r = fresh(3);
    expect(r.deck.length, 12);
    expect(run.available(r), ['n1']);
    r = run.enter(r, 'n1');
    expect(r.phase, RunPhase.combat);
    expect(run.enemyOf(r), 'bat');
    r = run.finishCombat(r, won: true, hp: 40);
    expect(r.rewardOptions.length, 3);
    r = run.chooseReward(r, r.rewardOptions.first);
    expect(r.deck.length, 13);
    expect(run.available(r), ['n2', 'e1'], reason: 'combate o evento');
    r = run.enter(r, 'n2');
    r = run.finishCombat(r, won: true, hp: 30);
    r = run.chooseReward(r, null); // saltear
    expect(r.deck.length, 13);
    expect(r.style, isNull); // novicio hasta el santuario
    expect(run.available(r), ['ns']);
    r = run.enter(r, 'ns');
    expect(r.phase, RunPhase.shrine);
    expect(r.pathOptions.length, 2);
    expect(r.pathOptions.toSet().length, 2);
    final path = r.pathOptions.last;
    r = run.choosePath(r, path);
    expect(r.style, path);
    expect(r.phase, RunPhase.map);
    expect(run.available(r), ['n3a', 'n3b']);
    r = run.enter(r, 'n3b');
    r = run.finishCombat(r, won: true, hp: 30);
    r = run.chooseReward(r, null);
    expect(run.available(r), ['e2']);
    r = run.enter(r, 'e2');
    expect(r.phase, RunPhase.event);
    final ev = run.data.event(r.eventId!);
    r = run.resolveEvent(r, ev.options.last.id);
    expect(r.phase, RunPhase.map);
    r = run.enter(r, 'n4');
    expect(r.phase, RunPhase.fountain);
    r = run.fountainHeal(r);
    expect(r.hp, r.maxHp);
  });

  test('formas: se arranca sin ninguna y se aprenden en la recompensa', () {
    var r = fresh(3);
    expect(r.knownForms, isEmpty);
    r = run.enter(r, 'n1');
    r = run.finishCombat(r, won: true, hp: 40);
    final form = r.rewardForm;
    expect(form, isNotNull);
    expect(run.learnableForms(r), isNot(contains('hu_quan')),
        reason: 'la del tigre solo en su camino');
    expect(run.learnableForms(r), isNot(contains('she_quan')));
    r = run.chooseForm(r, form!);
    expect(r.knownForms, [form]);
    expect(r.deck.length, 12, reason: 'la forma reemplaza a la carta');
    expect(r.rewardForm, isNull);
    expect(r.phase, RunPhase.map);
    // Se guarda y se recupera.
    final back = RunState.fromJson(r.toJson());
    expect(back.knownForms, [form]);
    // Ya no se vuelve a ofrecer.
    expect(run.learnableForms(r), isNot(contains(form)));
    expect(
      run.learnableForms(r.copyWith(style: Style.tiger)),
      contains('hu_quan'),
    );
    // Elegir carta descarta la forma ofrecida.
    r = run.enter(r, 'n2');
    r = run.finishCombat(r, won: true, hp: 30);
    expect(r.rewardForm, isNotNull);
    r = run.chooseReward(r, r.rewardOptions.first);
    expect(r.rewardForm, isNull);
    expect(r.knownForms, [form]);
  });

  test('fuente: mejorar y eliminar', () {
    var r = fresh(1)
        .copyWith(phase: RunPhase.fountain);
    final up = run.fountainUpgrade(r, 0);
    expect(up.deck.first.upgrades, 3);
    final rm = run.fountainRemove(r, 0);
    expect(rm.deck.length, 11);
  });

  test('derrota termina la run; victoria en el guardián', () {
    var r = run.enter(fresh(1), 'n1');
    expect(run.finishCombat(r, won: false, hp: 0).phase, RunPhase.defeat);
    r = r.copyWith(currentNode: 'n6');
    expect(run.finishCombat(r, won: true, hp: 5).phase, RunPhase.victory);
  });

  test('el santuario solo acepta los caminos que ofrece', () {
    final r = fresh(5).copyWith(currentNode: 'n2');
    final shrine = run.enter(r, 'ns');
    final missing =
        Style.values.firstWhere((s) => !shrine.pathOptions.contains(s));
    expect(() => run.choosePath(shrine, missing), throwsStateError);
  });

  test('serialización ida y vuelta', () {
    final novice = run.enter(fresh(9), 'n1');
    expect(RunState.fromJson(novice.toJson()).toJson(), novice.toJson());
    final shrine =
        run.enter(fresh(9).copyWith(currentNode: 'n2'), 'ns');
    expect(RunState.fromJson(shrine.toJson()).toJson(), shrine.toJson());
    final chosen = run.choosePath(shrine, shrine.pathOptions.first);
    expect(RunState.fromJson(chosen.toJson()).style, chosen.style);
  });

  test('retomar un combate a medias vuelve al mapa antes de ese nodo', () {
    final first = run.enter(fresh(3), 'n1');
    final back = run.retreat(first);
    expect(back.phase, RunPhase.map);
    expect(back.currentNode, isNull);
    expect(back.visited, isEmpty);
    expect(run.available(back), ['n1']);

    final second = run.enter(back.copyWith(currentNode: 'n1', visited: ['n1']), 'n2');
    final back2 = run.retreat(second);
    expect(back2.currentNode, 'n1');
    expect(run.available(back2), ['n2', 'e1']);
  });

  test('la dificultad fija la Vida, la fuente y se guarda', () {
    var r = fresh(1, difficulty: Difficulty.easy);
    expect(r.hp, 60);
    expect(r.maxHp, 60);
    expect(run.healOf(r), 25);
    r = RunState.fromJson(r.toJson());
    expect(r.difficulty, Difficulty.easy);
    // Las runs guardadas antes de las dificultades se leen como Normal.
    final old = fresh(1).toJson()..remove('difficulty');
    expect(RunState.fromJson(old).difficulty, Difficulty.normal);
  });

  group('eventos', () {
    RunState at(String eventId, {int hp = 40, int seed = 4}) => fresh(seed)
        .copyWith(phase: RunPhase.event, eventId: eventId, hp: hp);

    test('el evento sale al entrar y no se repite', () {
      var r = run.enter(fresh(2), 'n1');
      r = run.finishCombat(r, won: true, hp: 40);
      r = run.chooseReward(r, null);
      r = run.enter(r, 'e1');
      expect(r.phase, RunPhase.event);
      final first = r.eventId!;
      r = run.resolveEvent(r, run.data.event(first).options.last.id);
      expect(r.seenEvents, [first]);
      expect(r.eventId, isNull);
      expect(r.lastEvent!.eventId, first);
      for (var seed = 0; seed < 20; seed++) {
        final again = run.enter(
          r.copyWith(rng: Rng.seeded(seed), currentNode: 'n3a'),
          'e2',
        );
        expect(again.eventId, isNot(first));
      }
    });

    test('ermitaño: pagás Vida y aprendés una forma', () {
      final r = run.resolveEvent(at('hermit'), 'pay');
      expect(r.hp, 32);
      expect(r.knownForms, hasLength(1));
      expect(r.lastEvent!.form, r.knownForms.single);
      expect(r.lastEvent!.hp, -8);
      // Sin Vida suficiente no se puede pagar.
      final weak = at('hermit', hp: 8);
      expect(run.canChoose(weak, run.data.event('hermit').option('pay')), isFalse);
      expect(() => run.resolveEvent(weak, 'pay'), throwsStateError);
    });

    test('té: +4 Vida máxima; mono: se lleva una carta inicial', () {
      final tea = run.resolveEvent(at('tea'), 'drink');
      expect(tea.maxHp, 54);
      expect(tea.hp, 44);
      expect(tea.lastEvent!.maxHp, 4);
      final monkey = run.resolveEvent(at('monkey'), 'let');
      expect(monkey.deck, hasLength(11));
      expect(run.data.card(monkey.lastEvent!.lost!).pool, 'starter');
    });

    test('puente: sale bien (talismán) o mal (−10 Vida)', () {
      final outcomes = <bool>{};
      for (var seed = 1; seed < 30; seed++) {
        final r = run.resolveEvent(at('bridge', seed: seed), 'cross');
        final ok = r.lastEvent!.success!;
        outcomes.add(ok);
        if (ok) {
          expect(r.talismans, hasLength(1));
          expect(run.data.talisman(r.talismans.single).rare, isFalse);
        } else {
          expect(r.hp, 30);
        }
      }
      expect(outcomes, {true, false});
    });

    test('altar: talismán raro; manantial: mejora una carta', () {
      final altar = run.resolveEvent(at('altar'), 'offer');
      expect(run.data.talisman(altar.talismans.single).rare, isTrue);
      final spring = run.resolveEvent(at('spring'), 'bathe');
      expect(spring.deck.where((c) => c.upgrades > 0), hasLength(1));
      expect(spring.lastEvent!.upgraded, isNotNull);
    });
  });

  group('talismanes', () {
    test('el élite ofrece talismanes antes de la recompensa', () {
      var r = run.enter(fresh(3).copyWith(currentNode: 'n4'), 'n5');
      r = run.finishCombat(r, won: true, hp: 30);
      expect(r.phase, RunPhase.talisman);
      expect(r.talismanOptions, hasLength(3));
      expect(r.rewardOptions, hasLength(3), reason: 'la recompensa ya espera');
      expect(() => run.chooseTalisman(r, 'nope'), throwsStateError);
      final vida = r.copyWith(talismanOptions: ['vida', 'roca', 'arco']);
      r = run.chooseTalisman(vida, 'vida');
      expect(r.phase, RunPhase.reward);
      expect(r.talismans, ['vida']);
      expect(r.maxHp, 56);
      expect(r.hp, 36);
      expect(RunState.fromJson(r.toJson()).talismans, ['vida']);
    });

    test('un combate común no da talismán', () {
      var r = run.enter(fresh(3), 'n1');
      r = run.finishCombat(r, won: true, hp: 30);
      expect(r.phase, RunPhase.reward);
      expect(r.talismanOptions, isEmpty);
    });

    test('victoria cura al ganar y la fuente cura más', () {
      var r = fresh(3);
      r = run.addTalisman(r, 'victoria');
      r = run.addTalisman(r, 'fuente');
      r = run.enter(r, 'n1');
      expect(run.finishCombat(r, won: true, hp: 30).hp, 33);
      expect(run.healOf(r), 28);
    });

    test('serialización con talismanes y evento', () {
      var r = fresh(3).copyWith(phase: RunPhase.event, eventId: 'tea');
      r = run.addTalisman(r, 'roca');
      final back = RunState.fromJson(r.toJson());
      expect(back.toJson(), r.toJson());
      r = run.resolveEvent(r, 'spar');
      expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
    });
  });

  group('mapa generado', () {
    test('cada semilla arma un mapa válido con sus reglas', () {
      final shapes = <String>{};
      for (var seed = 1; seed <= 200; seed++) {
        final r = run.newRun(seed: seed);
        final map = r.map;
        final ids = {for (final n in map) n.id};
        shapes.add([for (final n in map) '${n.id}:${n.type.name}:${n.next}'].join());
        // Todo nodo es alcanzable y todos llegan al jefe.
        final reached = {...r.starts};
        for (final n in map) {
          expect(ids.containsAll(n.next), isTrue);
          if (reached.contains(n.id)) reached.addAll(n.next);
        }
        expect(reached, ids);
        final boss = map.where((n) => n.next.isEmpty).toList();
        expect(boss, hasLength(1));
        expect(boss.single.enemy, 'dragon');
        expect(r.starts, hasLength(2));
        // Un solo santuario y una sola fuente, que es lo previo al élite.
        expect(map.where((n) => n.type == NodeType.shrine), hasLength(1));
        final fountain = map.singleWhere((n) => n.type == NodeType.fountain);
        expect(r.node(fountain.next.single).enemy, 'monk');
        // Siempre hay mercader y maestro.
        expect(map.any((n) => n.type == NodeType.merchant), isTrue);
        expect(map.any((n) => n.type == NodeType.master), isTrue);
        for (final n in map) {
          if (n.type == NodeType.combat) {
            expect(run.data.enemies.containsKey(n.enemy), isTrue);
          } else {
            expect(n.enemy, isNull);
          }
        }
        // Se puede llegar al jefe sin pasar dos veces por el mismo piso.
        expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
      }
      expect(shapes.length, greaterThan(150), reason: 'mapas distintos');
    });

    test('la misma semilla da el mismo mapa', () {
      expect(run.newRun(seed: 7).toJson(), run.newRun(seed: 7).toJson());
    });

    test('se arranca eligiendo entre los nodos del primer piso', () {
      final r = run.newRun(seed: 7);
      expect(run.available(r), r.starts);
      final next = run.enter(r, r.starts.last);
      expect(next.phase, RunPhase.combat);
    });

    test('una subida guardada sin mapa se descarta', () {
      final old = run.newRun(seed: 7).toJson()..remove('map');
      expect(() => RunState.fromJson(old), throwsA(anything));
    });
  });

  group('jade y mercader', () {
    test('los combates dan jade; el élite, más', () {
      var r = run.enter(fresh(3), 'n1');
      r = run.finishCombat(r, won: true, hp: 40);
      final b = run.data.balance;
      expect(r.jade, inInclusiveRange(b.jadeCommon, b.jadeCommon + b.jadeSpread));
      expect(r.jadeGained, r.jade);
      var e = run.enter(fresh(3).copyWith(currentNode: 'n4'), 'n5');
      e = run.finishCombat(e, won: true, hp: 30);
      expect(e.jade, greaterThanOrEqualTo(b.jadeElite));
      expect(RunState.fromJson(r.toJson()).jade, r.jade);
    });

    RunState shop({int jade = 200}) {
      final map = [
        const MapNodeDef(id: 'm', type: NodeType.merchant, next: []),
      ];
      return run.enter(fresh(5).copyWith(map: map, jade: jade), 'm');
    }

    test('el mercader ofrece cartas, un talismán común y servicios', () {
      final r = shop();
      expect(r.phase, RunPhase.merchant);
      expect(r.shopCards, hasLength(3));
      expect(run.data.talisman(r.shopTalisman!).rare, isFalse);
      expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
    });

    test('comprar descuenta jade y suma lo comprado', () {
      final m = run.data.balance.merchant;
      var r = shop();
      final card = r.shopCards.first;
      r = run.buyCard(r, card);
      expect(r.jade, 200 - m.card);
      expect(r.deck.last.cardId, card);
      expect(r.shopCards, isNot(contains(card)));
      final t = r.shopTalisman!;
      r = run.buyTalisman(r);
      expect(r.talismans, [t]);
      expect(r.shopTalisman, isNull);
      final size = r.deck.length;
      r = run.buyRemove(r, r.deck.first.uid);
      expect(r.deck, hasLength(size - 1));
      expect(() => run.buyRemove(r, r.deck.first.uid), throwsStateError,
          reason: 'una vez por visita');
      r = run.buyUpgrade(r, r.deck.first.uid);
      expect(r.deck.first.upgrades, run.data.balance.fountainUpgrade);
      expect(r.jade, 200 - m.card - m.talisman - m.remove - m.upgrade);
      r = run.leaveShop(r);
      expect(r.phase, RunPhase.map);
      expect(r.shopCards, isEmpty);
    });

    test('sin jade no se compra', () {
      final r = shop(jade: 10);
      expect(() => run.buyCard(r, r.shopCards.first), throwsStateError);
      expect(() => run.buyTalisman(r), throwsStateError);
    });
  });

  group('maestro errante', () {
    RunState master(RunState base) {
      final map = [
        const MapNodeDef(id: 'm', type: NodeType.master, next: []),
      ];
      return run.enter(base.copyWith(map: map), 'm');
    }

    test('ofrece formas que no sabés y enseña una', () {
      var r = master(fresh(4));
      expect(r.phase, RunPhase.master);
      expect(r.masterForms, hasLength(run.data.balance.masterForms));
      final f = r.masterForms.last;
      expect(() => run.masterTeach(r, 'nope'), throwsStateError);
      r = run.masterTeach(r, f);
      expect(r.knownForms, [f]);
      expect(r.phase, RunPhase.map);
      expect(r.masterForms, isEmpty);
    });

    test('o mejora una carta', () {
      var r = master(fresh(4));
      r = run.masterUpgrade(r, 0);
      expect(r.deck.first.upgrades, run.data.balance.fountainUpgrade);
      expect(r.knownForms, isEmpty);
      expect(r.phase, RunPhase.map);
    });

    test('si ya sabés todo, solo mejora', () {
      final all = run.learnableForms(fresh(4));
      final r = master(fresh(4).copyWith(knownForms: all));
      expect(r.masterForms, isEmpty);
    });
  });
}
