import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/meta_bonus.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/feats.dart';
import 'package:long_breath/domain/run/legacy.dart';
import 'package:long_breath/domain/run/map_gen.dart';
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
  // Las reglas de siempre: el premio de los combates es siempre de cartas.
  final run = RunEngine(
    loadGameDataFromDir('assets/data', const {'combatRewards': null}),
  );

  RunState fresh(int seed, {Difficulty difficulty = Difficulty.normal}) => run
      .newRun(seed: seed, difficulty: difficulty)
      .copyWith(map: _legacy);

  test('la subida junta formas, desvíos y combates sin daño para los hitos', () {
    var r = fresh(3);
    r = run.enter(r, 'n1');
    r = run.finishCombat(
      r,
      won: true,
      hp: r.hp,
      tally: {Feat.forms: 2, Feat.deflects: 3},
    );
    expect(r.feats, {Feat.forms: 2, Feat.deflects: 3, Feat.flawless: 1});
    r = run.chooseReward(r, null);
    r = run.enter(r, 'n2');
    r = run.finishCombat(r, won: true, hp: r.hp - 5, tally: {Feat.forms: 1});
    expect(r.feats, {Feat.forms: 3, Feat.deflects: 3, Feat.flawless: 1});
    final back = RunState.fromJson(
      jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
    );
    expect(back.feats, r.feats);
  });

  test('vencer a un élite o jefe queda en la subida; el jefe limpio, aparte', () {
    var r = fresh(3).copyWith(currentNode: 'n5', phase: RunPhase.combat);
    r = run.finishCombat(r, won: true, hp: r.hp - 1);
    expect(r.feats[Feat.beat('monk')], 1);
    r = r.copyWith(currentNode: 'n6', phase: RunPhase.combat);
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(r.feats[Feat.beat('dragon')], 1);
    expect(r.feats[Feat.flawlessBoss], 1);
    r = r.copyWith(currentNode: 'n1', phase: RunPhase.combat);
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(r.feats.containsKey(Feat.beat('bat')), isFalse);
  });

  test('al terminar se anotan despertares y talismanes que se llevaban', () {
    final r = fresh(3).copyWith(
      awakenings: ['hu_nu'],
      talismans: ['arco', 'luna'],
    );
    expect(run.finalFeats(r), {
      Feat.awakening('hu_nu'): 1,
      Feat.talisman('arco'): 1,
      Feat.talisman('luna'): 1,
      Feat.talismans: 2,
      Feat.bossTalisman: 1,
    });
  });

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
    // Tercer combate ganado: un mercader en el camino, sin nodo propio.
    expect(r.phase, RunPhase.merchant);
    expect(run.isWanderingMerchant(r), isTrue);
    expect(r.shopCards, isNotEmpty);
    r = run.leaveShop(r);
    expect(r.combatsSinceMerchant, 0);
    expect(run.available(r), ['e2']);
    r = run.enter(r, 'e2');
    expect(r.phase, RunPhase.event);
    final ev = run.data.event(r.eventId!);
    // Sin duelo: vuelve al mapa, o pasa antes por elegir carta o mejora.
    final calm = ev.options.lastWhere((o) => o.duel == null);
    r = run.resolveEvent(r, calm.id);
    if (r.phase == RunPhase.reward) {
      r = r.rewardKind == RewardKind.upgrade
          ? run.chooseRewardUpgrade(r, r.deck.firstWhere(run.canUpgrade).uid)
          : run.chooseReward(r, null);
    }
    expect(r.phase, RunPhase.map);
    r = run.enter(r, 'n4');
    expect(r.phase, RunPhase.fountain);
    final before = r.hp;
    r = run.fountainHeal(r);
    expect(r.hp, greaterThan(before));
    expect(r.hp, lessThanOrEqualTo(r.maxHp));
  });

  test('si el rival se escapa, se lleva el jade y no deja', () {
    var r = fresh(3).copyWith(jade: 30);
    r = run.enter(r, 'n1');
    r = run.finishCombat(r, won: true, hp: 40, fledWith: 12);
    expect(r.jade, 18);
    expect(r.jadeGained, -12);
    expect(r.phase, RunPhase.reward, reason: 'la carta se gana igual');
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

  test('formas de camino: salen más seguido y las largas se abren con el cultivo', () {
    final own = {
      for (final f in run.data.forms)
        if (f.pool == Style.crane) f.id,
    };
    var hits = 0;
    for (var seed = 1; seed <= 60; seed++) {
      var r = fresh(seed).copyWith(style: Style.crane);
      r = run.enter(r, 'n1');
      r = run.finishCombat(r, won: true, hp: 40);
      if (own.contains(r.rewardForm)) hits++;
    }
    expect(hits, greaterThan(30), reason: 'dos de cada tres, más el azar');
    final r = fresh(1).copyWith(style: Style.crane);
    expect(run.learnableForms(r), containsAll(['he_zhan_chi', 'bai_he_quan']));
    final realm0 = run.data.balance.cultivation.lockedAt(0);
    expect(realm0, contains('bai_he_quan'), reason: 'la larga espera al reino 开脉');
    expect(realm0, isNot(contains('he_zhan_chi')));
    expect(run.data.forms.firstWhere((f) => f.id == 'bai_he_quan').isLong, isTrue);
  });

  test('fuente: mejorar y eliminar', () {
    var r = fresh(1)
        .copyWith(phase: RunPhase.fountain);
    final up = run.fountainUpgrade(r, 0);
    expect(up.deck.first.upgrades, 3);
    final rm = run.fountainRemove(r, 0);
    expect(rm.deck.length, 11);
  });

  test('derrota termina la run; victoria en el jefe de la última etapa', () {
    var r = run.enter(fresh(1), 'n1');
    expect(run.finishCombat(r, won: false, hp: 0).phase, RunPhase.defeat);
    r = r.copyWith(currentNode: 'n6', stage: 2);
    expect(run.finishCombat(r, won: true, hp: 5).phase, RunPhase.victory);
  });

  test('el jefe de una etapa intermedia lleva a la siguiente', () {
    var r = fresh(1).copyWith(currentNode: 'n6', jade: 3, hp: 20);
    r = run.finishCombat(r, won: true, hp: 10);
    // Talismán, recompensa y jade para la etapa que viene.
    expect(r.phase, RunPhase.talisman);
    expect(r.jade, 3 + run.data.balance.stageJade);
    r = run.chooseTalisman(r, r.talismanOptions.first);
    r = run.chooseReward(r, null);
    expect(r.phase, RunPhase.stageClear);
    // Respira hondo: recupera el 40% de lo que le falta, no todo.
    final heal = ((r.maxHp - r.hp) * 0.4).round();
    expect(run.stageHealOf(r), heal);
    final before = r.hp;
    final up = run.advanceStage(r);
    expect(up.stage, 1);
    expect(up.phase, RunPhase.map);
    expect(up.hp, before + heal);
    expect(up.currentNode, isNull);
    expect(up.visited, isEmpty);
    expect(run.available(up), up.starts);
    // El mapa nuevo es el del monasterio: su jefe es el abad.
    expect(up.map.singleWhere((n) => n.next.isEmpty).enemy, 'bell_abbot');
    expect(RunState.fromJson(up.toJson()).toJson(), up.toJson());
    expect(() => run.advanceStage(up), throwsStateError);
  });

  test('superar una etapa ofrece despertares del camino', () {
    var r = fresh(1).copyWith(currentNode: 'n6', style: Style.crane);
    r = run.finishCombat(r, won: true, hp: 10);
    r = run.chooseTalisman(r, r.talismanOptions.first);
    r = run.chooseReward(r, null);
    expect(r.phase, RunPhase.stageClear);
    final crane = [
      for (final a in run.data.balance.styles[Style.crane]!.awakenings) a.id,
    ];
    expect(r.awakeningOptions, hasLength(3));
    expect(crane, containsAll(r.awakeningOptions));
    expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
    // Hay que elegir uno de los ofrecidos.
    expect(() => run.advanceStage(r), throwsStateError);
    expect(() => run.advanceStage(r, awakening: 'hu_nu'), throwsStateError);
    final picked = r.awakeningOptions.first;
    final up = run.advanceStage(r, awakening: picked);
    expect(up.awakenings, [picked]);
    expect(up.awakeningOptions, isEmpty);
    // La etapa siguiente no vuelve a ofrecer el que ya aprendió.
    expect(run.missingAwakenings(up), isNot(contains(picked)));
    expect(run.missingAwakenings(up), hasLength(crane.length - 1));
  });

  test('cada etapa genera su mapa con su jefe', () {
    final bosses = ['dragon', 'bell_abbot', 'sleeping_dragon'];
    final stages = run.data.balance.stages;
    expect(stages, hasLength(3));
    for (var seed = 1; seed <= 40; seed++) {
      var r = run.newRun(seed: seed);
      for (var st = 0; st < stages.length; st++) {
        expect(r.stage, st);
        expect(r.map.singleWhere((n) => n.next.isEmpty).enemy, bosses[st]);
        for (final n in r.map) {
          if (n.enemy != null) {
            expect(stages[st].floors.any((f) => f.enemies.contains(n.enemy)),
                isTrue, reason: n.enemy);
          }
        }
        if (st == stages.length - 1) break;
        r = run.advanceStage(r.copyWith(
          phase: RunPhase.stageClear,
          currentNode: r.map.singleWhere((n) => n.next.isEmpty).id,
        ));
      }
    }
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
    final easy = run.data.balance.difficulty(Difficulty.easy);
    expect(easy.playerHp, greaterThan(50));
    expect(r.hp, easy.playerHp);
    expect(r.maxHp, easy.playerHp);
    expect(run.healOf(r), easy.fountainHeal);
    r = RunState.fromJson(r.toJson());
    expect(r.difficulty, Difficulty.easy);
    // Las runs guardadas antes de las dificultades se leen como Normal.
    final old = fresh(1).toJson()..remove('difficulty');
    expect(RunState.fromJson(old).difficulty, Difficulty.normal);
  });

  test('el Pico baja la Vida inicial y la fuente, y se guarda', () {
    final pico = run.data.balance.picoMods(5);
    expect(pico.fountainHeal, -5);
    expect(pico.playerHp, -5);
    var r = run.newRun(seed: 1, pico: 5);
    expect(r.maxHp, 45);
    expect(run.healOf(r), 15);
    r = RunState.fromJson(r.toJson());
    expect(r.pico, 5);
    // Antes del Pico 5 la fuente cura lo de siempre.
    expect(run.healOf(run.newRun(seed: 1, pico: 1)), 20);
    final old = fresh(1).toJson()..remove('pico');
    expect(RunState.fromJson(old).pico, 0);
  });

  test('desde el Pico 2 el mercader cobra más', () {
    final base = run.merchantOf(run.newRun(seed: 1, pico: 1));
    final dear = run.merchantOf(run.newRun(seed: 1, pico: 2));
    expect(dear.card, (base.card * 1.2).round());
    expect(dear.remove, (base.remove * 1.2).round());
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

    test('jade: el ermitaño acepta jade, los dados y el peregrino', () {
      final hermit = run.data.event('hermit').option('gift');
      expect(run.canChoose(at('hermit'), hermit), isFalse, reason: 'sin jade');
      final rich = at('hermit').copyWith(jade: 40);
      final r = run.resolveEvent(rich, 'gift');
      expect(r.jade, 15);
      expect(r.hp, 40, reason: 'no cuesta Vida');
      expect(r.knownForms, hasLength(1));
      expect(r.lastEvent!.jade, -25);

      final outcomes = <bool>{};
      for (var seed = 1; seed < 30; seed++) {
        final d = run.resolveEvent(
          at('dice', seed: seed).copyWith(jade: 20),
          'bet',
        );
        outcomes.add(d.lastEvent!.success!);
        expect(d.jade, d.lastEvent!.success! ? 20 - 15 + 35 : 5);
      }
      expect(outcomes, {true, false});

      final p = run.resolveEvent(at('pilgrim'), 'guide');
      expect(p.jade, 30);
      expect(p.hp, 34);
      expect(p.lastEvent!.jade, 30);
    });

    test('altar: talismán raro; manantial: mejora una carta', () {
      final altar = run.resolveEvent(at('altar'), 'offer');
      expect(run.data.talisman(altar.talismans.single).rare, isTrue);
      final spring = run.resolveEvent(at('spring'), 'bathe');
      expect(spring.deck.where((c) => c.upgrades > 0), hasLength(1));
      expect(spring.lastEvent!.upgraded, isNotNull);
    });
  });

  group('eventos con requisito y en dos partes', () {
    RunState at(String id, {RunState? base}) => (base ?? fresh(3))
        .copyWith(phase: RunPhase.event, eventId: id, hp: 40);

    test('la opción que pide un talismán solo se ve con él, y primero', () {
      final bridge = run.data.event('bridge');
      final glide = bridge.option('glide');
      final plain = at('bridge');
      expect(run.eventOptions(plain, bridge).map((o) => o.id), [
        'cross',
        'around',
      ]);
      expect(run.canChoose(plain, glide), isFalse);
      final crane = at('bridge').copyWith(talismans: ['pluma']);
      expect(run.eventOptions(crane, bridge).first.id, 'glide');
      expect(run.needMet(crane, glide), 'pluma');
      final r = run.resolveEvent(crane, 'glide');
      expect(r.lastEvent!.talisman, isNotNull);
      expect(r.lastEvent!.success, isNull, reason: 'sin riesgo');
    });

    test('arma y forma también abren opciones', () {
      final wood = run.data.event('woodcutter');
      expect(run.eventOptions(at('woodcutter'), wood), hasLength(2));
      final pudao = run.equipWeapon(at('woodcutter'), 'pudao');
      expect(run.eventOptions(pudao, wood).first.id, 'chop');
      expect(run.equipWeapon(at('woodcutter'), 'jian').weapon, 'jian');
      expect(
        run.eventOptions(run.equipWeapon(at('woodcutter'), 'jian'), wood),
        hasLength(2),
      );
      final hermit = run.data.event('hermit');
      expect(run.eventOptions(at('hermit'), hermit), hasLength(3));
      final known = at('hermit').copyWith(knownForms: ['wu_bu_quan']);
      expect(run.eventOptions(known, hermit).first.id, 'show');
    });

    test('templar sube el arma; sin arma, mejora una carta', () {
      final armed = run.equipWeapon(at('ice_sage'), 'gun');
      final r = run.resolveEvent(armed, 'forge');
      expect(r.weaponLevel, 2);
      expect(r.lastEvent!.tempered, 'gun');
      final delivery = run.resolveEvent(at('smith_delivery'), 'take');
      expect(delivery.weapon, isNull);
      expect(delivery.lastEvent!.upgraded, isNotNull);
    });

    test('la marca de abajo trae la segunda parte en una etapa más arriba', () {
      var r = run.resolveEvent(at('wounded'), 'help');
      expect(r.marks, {'wounded': 0});
      expect(r.lastEvent!.mark, 'wounded');
      const scene = [
        MapNodeDef(id: 'x', type: NodeType.event, next: []),
      ];
      RunState walk(RunState base, int stage, int seed) => run.enter(
        base.copyWith(
          style: Style.tiger,
          stage: stage,
          map: scene,
          clearCurrentNode: true,
          visited: const [],
          seenEvents: [...base.seenEvents, 'tiger_drums', 'tiger_boulder'],
          rng: Rng(seed),
        ),
        'x',
      );
      for (var seed = 0; seed < 20; seed++) {
        expect(walk(r, 1, seed).eventId, 'wounded_return');
        // En la misma etapa no vuelve, y sin marca nunca sale.
        expect(walk(r, 0, seed).eventId, isNot('wounded_return'));
        expect(walk(fresh(3), 1, seed).eventId, isNot('wounded_return'));
      }
      r = RunState.fromJson(
        jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
      );
      expect(r.marks, {'wounded': 0});
      expect(r.lastEvent!.mark, 'wounded');
    });
  });

  group('eventos de camino', () {
    // Un evento con un combate después (el duelo no es el jefe de etapa).
    const scene = [
      MapNodeDef(id: 'x', type: NodeType.event, next: ['y']),
      MapNodeDef(id: 'y', type: NodeType.combat, enemy: 'bat', next: []),
    ];
    RunState walk(Style? style, {int stage = 0, int seed = 1}) => run.enter(
          fresh(seed).copyWith(
            style: style,
            stage: stage,
            map: scene,
            clearCurrentNode: true,
            visited: const [],
          ),
          'x',
        );
    RunState at(String id, Style style, {int seed = 1}) =>
        walk(style, seed: seed).copyWith(eventId: id, hp: 40);

    test('sale el del camino propio en cada etapa y nunca el de otro', () {
      for (final (i, own) in ['tiger_boulder', 'tiger_drums', 'tiger_marks']
          .indexed) {
        for (var seed = 0; seed < 8; seed++) {
          expect(walk(Style.tiger, stage: i, seed: seed).eventId, own);
        }
      }
      for (var seed = 0; seed < 30; seed++) {
        final none = walk(null, seed: seed).eventId!;
        final snake = walk(Style.snake, seed: seed).eventId!;
        expect(run.data.event(none).path, isNull);
        expect(run.data.event(snake).path, anyOf(isNull, Style.snake));
      }
    });

    test('cartas del camino: se eligen entre tres y se vuelven a tirar del camino', () {
      var r = run.resolveEvent(at('tiger_boulder', Style.tiger), 'smash');
      expect(r.hp, 30);
      expect(r.phase, RunPhase.reward);
      expect(r.rewardKind, RewardKind.cards);
      expect(r.rewardOptions, hasLength(3));
      expect(r.jadeGained, 0);
      bool tiger(String id) => run.data.card(id).pool == 'tiger';
      expect(r.rewardOptions.every(tiger), isTrue);
      r = run.rerollReward(r.copyWith(rerollsLeft: 1));
      expect(r.rewardOptions.every(tiger), isTrue);
      final pick = r.rewardOptions.first;
      r = run.chooseReward(r, pick);
      expect(r.phase, RunPhase.map);
      expect(r.deck.last.cardId, pick);
    });

    test('elegir qué mejorar pasa por el premio de mejora', () {
      var r = run.resolveEvent(at('tiger_drums', Style.tiger), 'strike');
      expect(r.phase, RunPhase.reward);
      expect(r.rewardKind, RewardKind.upgrade);
      final uid = r.deck.firstWhere(run.canUpgrade).uid;
      r = run.chooseRewardUpgrade(r, uid);
      expect(r.phase, RunPhase.map);
      expect(r.deck.firstWhere((c) => c.uid == uid).upgrades, greaterThan(0));
    });

    test('el talismán del camino; si ya se tiene, uno raro', () {
      final r = run.resolveEvent(at('snake_skin', Style.snake), 'wear');
      expect(r.talismans.last, 'escama');
      expect(r.lastEvent!.talisman, 'escama');
      final again = run.resolveEvent(
        at('snake_skin', Style.snake).copyWith(talismans: ['escama']),
        'wear',
      );
      final got = run.data.talisman(again.talismans.last);
      expect(got.rare, isTrue);
      expect(got.pool, isNull);
    });

    test('duelo: pelea contra el rival y deja el talismán del camino primero', () {
      var r = run.resolveEvent(at('tiger_boulder', Style.tiger), 'challenge');
      expect(r.phase, RunPhase.combat);
      expect(r.duel, 'bandit');
      expect(r.lastEvent!.duel, 'bandit');
      expect(run.packOf(r), ['bandit']);
      expect(run.togetherOf(r), isFalse);
      expect(RunState.fromJson(r.toJson()).duel, 'bandit');
      // Si se cierra la app a mitad del duelo, se vuelve a la escena.
      final back = run.retreat(r);
      expect(back.phase, RunPhase.event);
      expect(back.eventId, 'tiger_boulder');
      expect(back.duel, isNull);
      r = run.finishCombat(r, won: true, hp: 30);
      expect(r.duel, isNull);
      expect(r.phase, RunPhase.talisman);
      expect(r.talismanOptions.first, 'garra');
      r = run.chooseTalisman(r, 'garra');
      expect(r.phase, RunPhase.map, reason: 'el talismán es todo el premio');
    });
  });

  group('talismanes', () {
    test('el élite ofrece talismanes antes de la recompensa', () {
      var r = run.enter(fresh(3).copyWith(currentNode: 'n4'), 'n5');
      r = run.finishCombat(r, won: true, hp: 30);
      expect(r.phase, RunPhase.talisman);
      expect(r.talismanOptions, hasLength(3));
      expect(r.rewardKind, RewardKind.weapon,
          reason: 'sin arma, el élite la garantiza después del talismán');
      expect(r.weaponOptions, hasLength(3));
      expect(() => run.chooseTalisman(r, 'nope'), throwsStateError);
      final vida = r.copyWith(talismanOptions: ['vida', 'roca', 'arco']);
      r = run.chooseTalisman(vida, 'vida');
      expect(r.phase, RunPhase.reward);
      expect(r.talismans, ['vida']);
      expect(r.maxHp, 56);
      expect(r.hp, 36);
      expect(RunState.fromJson(r.toJson()).talismans, ['vida']);
    });

    test('los de jefe solo los ofrece el jefe', () {
      final r = fresh(3);
      final normal = run.missingTalismans(r);
      expect(normal, isNot(contains('luna')));
      expect(normal, isNot(contains('montana')));
      expect(run.missingTalismans(r, rare: true), isNot(contains('luna')));
      expect(run.missingTalismans(r, boss: true), [
        'luna',
        'montana',
        'tambor',
        'perla',
        'hoja',
        'horno',
      ]);
      for (final id in run.missingTalismans(r, boss: true)) {
        expect(normal, isNot(contains(id)));
      }
    });

    test('los de jefe con costo: la fuente nunca quita Vida', () {
      final r = fresh(3);
      final base = run.healOf(r);
      final drum = r.copyWith(talismans: ['tambor']);
      expect(run.healOf(drum), math.max(0, base - 15));
      final none = r.copyWith(talismans: ['tambor', 'tambor']);
      expect(run.healOf(none), 0);
      final card = run.merchantOf(r).card;
      final shop = run.merchantOf(r.copyWith(talismans: ['perla']));
      expect(shop.card, (card * 1.5).round());
    });

    test('los de camino solo le salen a ese camino', () {
      expect(run.missingTalismans(fresh(3)), isNot(contains('garra')));
      for (final (s, own) in [
        (Style.tiger, 'garra'),
        (Style.snake, 'escama'),
        (Style.crane, 'pluma'),
      ]) {
        final mine = run.missingTalismans(
          fresh(3).copyWith(style: s),
          rare: true,
        );
        expect(
          mine.where((id) => run.data.talisman(id).pool != null),
          [own],
        );
      }
    });

    test('Luna Llena quita Vida máxima sin dejarte en 0', () {
      var r = fresh(3).copyWith(hp: 3);
      r = run.addTalisman(r, 'luna');
      expect(r.maxHp, 45);
      expect(r.hp, 1);
    });

    test('Bolsa del Peregrino: más jade al ganar', () {
      var r = run.enter(fresh(3), 'n1');
      final plain = run.finishCombat(r, won: true, hp: 30).jadeGained;
      r = run.enter(run.addTalisman(fresh(3), 'bolsa'), 'n1');
      expect(run.finishCombat(r, won: true, hp: 30).jadeGained, plain + 8);
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
        // Un solo santuario y una sola fuente, entre el élite y el jefe.
        expect(map.where((n) => n.type == NodeType.shrine), hasLength(1));
        final fountain = map.singleWhere((n) => n.type == NodeType.fountain);
        expect(r.node(fountain.next.single).enemy, 'dragon');
        final elite = map.singleWhere((n) => n.next.contains(fountain.id));
        expect(['monk', 'lion', 'fan'], contains(elite.enemy));
        // Siempre hay maestro; el mercader ya no es un nodo del mapa.
        expect(map.any((n) => n.type == NodeType.merchant), isFalse);
        expect(map.any((n) => n.type == NodeType.master), isTrue);
        for (final n in map) {
          if (n.type == NodeType.combat) {
            expect(run.data.enemies.containsKey(n.enemy), isTrue);
            // Los grupos: solo comunes que no se escapan, de 2 o 3.
            if (n.waves.isNotEmpty) {
              expect(n.waves.length, lessThanOrEqualTo(2));
              for (final id in [n.enemy!, ...n.waves]) {
                expect(run.packable(id), isTrue, reason: id);
              }
            }
            // Las salas de antes: comunes que no se escapan, de a uno o dos,
            // sin repetir en la estancia mientras alcancen.
            for (final room in n.rooms) {
              expect(room.waves.length, lessThanOrEqualTo(1));
              for (final id in room.foes) {
                expect(run.packable(id), isTrue, reason: id);
              }
            }
            expect(n.stay.length, lessThanOrEqualTo(4));
            if (n.next.isEmpty || n.next.any(
                (x) => r.node(x).type == NodeType.fountain)) {
              expect(n.rooms, isEmpty, reason: 'jefe y élite fijo: una sala');
            }
          } else {
            expect(n.enemy, isNull);
            expect(n.waves, isEmpty);
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
      final t = run.data.talisman(r.shopTalisman!);
      expect(t.shop || !t.rare, isTrue, reason: 'común o de los suyos');
      expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
    });

    test('más arriba el mercader cobra más, ofrece 4 cartas y una vitrina', () {
      final base = run.merchantOf(fresh(5));
      RunState up(int stage) => run.enter(
        fresh(5).copyWith(
          stage: stage,
          jade: 200,
          map: [const MapNodeDef(id: 'm', type: NodeType.merchant, next: [])],
        ),
        'm',
      );
      final r2 = up(1), r3 = up(2);
      expect(run.merchantOf(r2).card, greaterThan(base.card));
      expect(r2.shopCards, hasLength(4));
      final t2 = run.data.talisman(r2.shopTalisman!);
      expect(t2.shop || !t2.rare, isTrue);
      expect(run.merchantOf(r3).talisman, greaterThan(run.merchantOf(r2).talisman));
      final bought = run.buyTalisman(r3);
      expect(bought.jade, 200 - run.merchantOf(r3).talisman);
      // Vitrina: un raro aparte, más caro que el talismán de arriba.
      final base0 = up(0);
      expect(base0.shopRare, isNull);
      for (final r in [r2, r3]) {
        final m = run.merchantOf(r);
        expect(run.data.talisman(r.shopRare!).rare, isTrue);
        expect(r.shopRare, isNot(r.shopTalisman));
        expect(m.rare, greaterThan(m.talisman));
      }
      expect(run.merchantOf(r3).rare, greaterThan(run.merchantOf(r2).rare));
      expect(RunState.fromJson(r3.toJson()).shopRare, r3.shopRare);
      final rare = run.buyRare(r3);
      expect(rare.jade, 200 - run.merchantOf(r3).rare);
      expect(rare.talismans, contains(r3.shopRare));
      expect(rare.shopRare, isNull);
      expect(() => run.buyRare(rare), throwsStateError);
      expect(run.leaveShop(r3).shopRare, isNull);
      expect(
        () => run.buyRare(r3.copyWith(jade: run.merchantOf(r3).rare - 1)),
        throwsStateError,
      );
    });

    test('el mercader trae a veces los suyos, que solo él vende', () {
      final seen = <String>{};
      for (var seed = 1; seed <= 20; seed++) {
        final r = run.enter(
          fresh(seed).copyWith(
            jade: 200,
            map: [const MapNodeDef(id: 'm', type: NodeType.merchant, next: [])],
          ),
          'm',
        );
        seen.add(r.shopTalisman!);
      }
      expect(seen.intersection({'abaco', 'manga'}), isNotEmpty);
      expect(run.missingTalismans(fresh(5)), isNot(contains('abaco')));
      expect(run.missingTalismans(fresh(5), shop: true), ['abaco', 'manga']);
    });

    test('Ábaco del Mercader: todo sale un 20% menos', () {
      final r = fresh(5);
      final base = run.merchantOf(r);
      final cheap = run.merchantOf(run.addTalisman(r, 'abaco'));
      expect(cheap.card, lessThan(base.card));
      expect(cheap.talisman, lessThan(base.talisman));
      final up = r.copyWith(stage: 2);
      expect(
        run.merchantOf(run.addTalisman(up, 'abaco')).rare,
        lessThan(run.merchantOf(up).rare),
      );
    });

    test('cada etapa tiene sus eventos y prefiere los propios', () {
      for (final (i, st) in run.data.balance.stages.indexed) {
        final own = [
          for (final e in run.data.events)
            if (e.stages?.contains(st.id) ?? false) e.id,
        ];
        expect(own.length, greaterThanOrEqualTo(2), reason: st.id);
        for (var seed = 0; seed < 10; seed++) {
          final r = run.enter(
            fresh(seed).copyWith(
              stage: i,
              map: [const MapNodeDef(id: 'x', type: NodeType.event, next: [])],
            ),
            'x',
          );
          expect(own, contains(r.eventId), reason: st.id);
        }
      }
    });

    test('comprar descuenta jade y suma lo comprado', () {
      final m = run.data.balance.merchant;
      var r = shop();
      final card = r.shopCards.firstWhere((c) => c != r.shopSale);
      r = run.buyCard(r, card);
      expect(r.jade, 200 - m.card);
      expect(r.deck.last.cardId, card);
      expect(r.shopCards, isNot(contains(card)));
      final t = r.shopTalisman!;
      r = run.buyTalisman(r);
      expect(r.talismans, [t]);
      expect(r.shopTalisman, isNull);
      // Precios después del talismán (el ábaco abarata la tienda).
      final after = run.merchantOf(r);
      final size = r.deck.length;
      r = run.buyRemove(r, r.deck.first.uid);
      expect(r.deck, hasLength(size - 1));
      expect(() => run.buyRemove(r, r.deck.first.uid), throwsStateError,
          reason: 'una vez por visita');
      r = run.buyUpgrade(r, r.deck.first.uid);
      expect(r.deck.first.upgrades, run.data.balance.fountainUpgrade);
      expect(r.jade, 200 - m.card - m.talisman - after.remove - after.upgrade);
      r = run.leaveShop(r);
      expect(r.phase, RunPhase.map);
      expect(r.shopCards, isEmpty);
    });

    test('una carta en oferta y un té por visita', () {
      final m = run.data.balance.merchant;
      var r = shop().copyWith(hp: 20);
      expect(r.shopCards, contains(r.shopSale));
      expect(m.salePrice, lessThan(m.card));
      expect(run.cardPrice(r, r.shopSale!), m.salePrice);
      r = run.buyCard(r, r.shopSale!);
      expect(r.jade, 200 - m.salePrice);
      r = run.buyTea(r);
      expect(r.hp, 20 + m.teaHeal);
      expect(r.jade, 200 - m.salePrice - m.tea);
      expect(() => run.buyTea(r), throwsStateError, reason: 'una vez');
      expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
      r = run.leaveShop(r);
      expect(r.shopSale, isNull);
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

  group('mercader ambulante', () {
    RunState winAt(RunState r, String node) {
      r = run.enter(r, node);
      r = run.finishCombat(r, won: true, hp: r.hp);
      if (r.phase == RunPhase.talisman) {
        r = run.chooseTalisman(r, r.talismanOptions.first);
      }
      return run.chooseReward(r, null);
    }

    test('el élite lo garantiza si la etapa no tuvo ninguno', () {
      var r = fresh(5);
      r = r.copyWith(currentNode: 'n4', visited: ['n1', 'n4']);
      expect(r.stageMerchants, 0);
      r = winAt(r, 'n5');
      expect(r.phase, RunPhase.merchant);
      expect(r.stageMerchants, 1);
    });

    test('nunca después del jefe', () {
      var r = fresh(5).copyWith(combatsSinceMerchant: 9, stageMerchants: 1);
      r = r.copyWith(currentNode: 'n5', visited: ['n1', 'n5']);
      r = winAt(r, 'n6');
      expect(r.phase, isNot(RunPhase.merchant));
    });

    test('un guardado viejo sin contadores carga, y su nodo de mercader anda',
        () {
      final old = fresh(5).copyWith(map: [
        const MapNodeDef(id: 'm', type: NodeType.merchant, next: ['b']),
        const MapNodeDef(
            id: 'b', type: NodeType.combat, enemy: 'dragon', next: []),
      ]);
      final json = old.toJson()
        ..remove('combatsSinceMerchant')
        ..remove('nextMerchantAt')
        ..remove('stageMerchants');
      var r = RunState.fromJson(json);
      expect(r.combatsSinceMerchant, 0);
      expect(r.map.first.waves, isEmpty);
      r = run.enter(r, 'm');
      expect(r.phase, RunPhase.merchant);
      expect(run.isWanderingMerchant(r), isFalse);
      r = run.leaveShop(r);
      expect(run.available(r), ['b']);
    });

    test('élite opcional: a veces un combate intermedio, siempre con salida', () {
      for (final st in run.data.balance.stages) {
        var seen = 0;
        for (var seed = 0; seed < 200; seed++) {
          final (map, _) = generateMap(
            st.floors,
            Rng.seeded(seed),
            packable: run.packable,
          );
          for (var f = 0; f < st.floors.length; f++) {
            final row = map.where((n) => n.id.startsWith('f${f + 1}')).toList();
            final elites = row.where(
              (n) =>
                  n.type == NodeType.combat &&
                  run.data.enemy(n.enemy!).rank == EnemyRank.elite,
            );
            if (st.floors[f].elite == 0) {
              if (f != 8) expect(elites, isEmpty, reason: '${st.id} $f');
              continue;
            }
            expect(elites.length, lessThanOrEqualTo(1));
            if (elites.isEmpty) continue;
            seen++;
            expect(row.length, greaterThan(1), reason: 'tiene que haber otro lugar');
            expect(elites.single.waves, isEmpty);
          }
          // Mientras queden otros, el élite del piso 9 no repite uno opcional.
          final ids = [
            for (final n in map)
              if (n.type == NodeType.combat &&
                  run.data.enemy(n.enemy!).rank == EnemyRank.elite)
                n.enemy,
          ];
          if (ids.length <= st.floors[8].enemies.length) {
            expect(ids.toSet(), hasLength(ids.length), reason: '${st.id} $seed');
          }
        }
        // 2 pisos al 40%: unos 160 en 200 mapas, ni siempre ni nunca.
        expect(seen, inInclusiveRange(100, 220), reason: st.id);
      }
    });

    test('el élite a veces trae escolta: un común de la etapa, a la vez', () {
      final st = run.data.balance.stages[2];
      final floor = st.floors.firstWhere((f) => f.escort > 0);
      var escorted = 0;
      for (var seed = 0; seed < 200; seed++) {
        final (map, _) = generateMap(
          st.floors,
          Rng.seeded(seed),
          packable: run.packable,
        );
        final elite = map.firstWhere(
          (n) => n.id.startsWith('f9') && n.type == NodeType.combat,
        );
        if (elite.waves.isEmpty) {
          expect(elite.together, isFalse);
          continue;
        }
        escorted++;
        expect(elite.together, isTrue);
        expect(floor.escorts, contains(elite.waves.single));
        expect(run.data.enemy(elite.enemy!).rank, EnemyRank.elite);
      }
      // Cerca del porcentaje del piso, ni siempre ni nunca.
      expect(
        escorted,
        inInclusiveRange(floor.escort * 2 - 40, floor.escort * 2 + 40),
      );
    });

    test('un grupo paga jade extra por cada enemigo de más', () {
      final base = fresh(5).copyWith(map: [
        const MapNodeDef(
            id: 'g', type: NodeType.combat, enemy: 'bat', next: ['x']),
        const MapNodeDef(
            id: 'h',
            type: NodeType.combat,
            enemy: 'bat',
            waves: ['golem'],
            next: ['x']),
        const MapNodeDef(
            id: 'x', type: NodeType.combat, enemy: 'dragon', next: []),
      ]);
      final solo = run.finishCombat(run.enter(base, 'g'), won: true, hp: 40);
      final group = run.finishCombat(run.enter(base, 'h'), won: true, hp: 40);
      expect(run.packOf(run.enter(base, 'h')), ['bat', 'golem']);
      expect(group.jadeGained - solo.jadeGained,
          run.data.balance.packJade);
    });
  });

  group('emboscada', () {
    RunState at(int seed) {
      var r = fresh(seed);
      return r.copyWith(phase: RunPhase.event, eventId: 'ambush_qianyunshan');
    }

    test('pelear lleva al duelo; pagar cuesta jade y vuelve al mapa', () {
      final fight = run.resolveEvent(at(1), 'fight');
      expect((fight.phase, fight.duel), (RunPhase.combat, 'bandit'));
      final rich = at(1).copyWith(jade: 30);
      final paid = run.resolveEvent(rich, 'pay');
      expect((paid.phase, paid.jade), (RunPhase.map, 10));
    });

    test('escabullirse sale bien (jade) o te alcanzan (duelo)', () {
      final seen = <String>{};
      for (var seed = 0; seed < 40; seed++) {
        final r = run.resolveEvent(at(seed), 'sneak');
        if (r.lastEvent!.success!) {
          expect((r.phase, r.duel), (RunPhase.map, null));
          seen.add('ok');
        } else {
          expect((r.phase, r.duel), (RunPhase.combat, 'bandit'));
          expect(r.hp, at(seed).hp - 4);
          seen.add('caught');
        }
      }
      expect(seen, {'ok', 'caught'});
    });

    test('ganarle paga como un combate común: sin talismán', () {
      final fight = run.resolveEvent(at(1), 'fight');
      final won = run.finishCombat(fight, won: true, hp: fight.hp);
      expect(won.phase, RunPhase.reward);
      expect(won.talismanOptions, isEmpty);
      expect(won.duel, isNull);
    });
  });

  group('estancias', () {
    RunState base() => fresh(7).copyWith(map: [
          const MapNodeDef(
              id: 'p',
              type: NodeType.combat,
              enemy: 'salamander',
              rooms: [
                RoomDef('bat'),
                RoomDef('golem', waves: ['monkey'], together: true),
              ],
              next: ['x']),
          const MapNodeDef(
              id: 'x', type: NodeType.combat, enemy: 'dragon', next: []),
        ]);
    // Sale del premio sin tomar nada (o con lo que no se elige).
    RunState leave(RunState r) => r.rewardKind == RewardKind.cards
        ? run.chooseReward(r, null)
        : run.collectReward(r);

    test('sala por sala, sin premio de cartas hasta el cofre', () {
      var r = run.enter(base(), 'p');
      expect(r.phase, RunPhase.combat);
      expect(run.roomsOf(r), 3);
      expect(run.packOf(r), ['bat']);
      expect(run.roomHpPct(r), run.data.balance.stayHpPct(0));
      final jade = r.jade;
      r = run.finishCombat(r, won: true, hp: 30);
      expect(r.phase, RunPhase.roomBreak);
      expect(r.rewardOptions, isEmpty);
      expect(r.jade, greaterThan(jade), reason: 'cada sala da jade');
      expect(r.combatsSinceMerchant, 0, reason: 'el mercader cuenta estancias');
      r = run.roomContinue(r, Breather.focus);
      expect((r.phase, r.roomStep, r.roomBoon), (RunPhase.combat, 1, Breather.focus));
      expect(run.packOf(r), ['golem', 'monkey']);
      expect(run.togetherOf(r), isTrue);
      expect(RunState.fromJson(r.toJson()).toJson(), r.toJson());
    });

    test('reponerse cura entre salas; la última abre el cofre', () {
      var r = run.finishCombat(run.enter(base(), 'p'), won: true, hp: 20);
      r = run.roomContinue(r, Breather.rest);
      expect(r.hp, 20 + run.restHeal(r));
      expect(r.roomBoon, isNull);
      r = run.roomContinue(run.finishCombat(r, won: true, hp: 20), Breather.fist);
      expect(run.packOf(r), ['salamander']);
      expect(run.lastRoom(r), isTrue);
      final last = run.finishCombat(r, won: true, hp: 20);
      expect([RunPhase.reward, RunPhase.talisman], contains(last.phase));
      expect(last.combatsSinceMerchant, 1);
      final out = leave(last.phase == RunPhase.talisman
          ? run.chooseTalisman(last, last.talismanOptions.first)
          : last);
      expect(out.phase, RunPhase.map);
      expect(run.available(out), ['x']);
    });

    test('a mitad de la estancia no se vuelve al mapa', () {
      var r = run.finishCombat(run.enter(base(), 'p'), won: true, hp: 30);
      r = run.roomContinue(r, Breather.focus);
      r = run.retreat(r);
      expect((r.phase, r.roomStep), (RunPhase.roomBreak, 0));
      expect(run.available(r), isEmpty);
    });

    test('el viejo paso guardado se lee como estancia', () {
      final n = MapNodeDef.fromJson({
        'id': 'p',
        'type': 'pass',
        'enemy': 'bat',
        'waves': ['golem', 'salamander'],
        'next': ['x'],
      });
      expect(n.type, NodeType.combat);
      expect([for (final room in n.stay) room.enemy], ['bat', 'golem', 'salamander']);
      final r = RunState.fromJson({
        ...base().toJson(),
        'phase': 'passChoice',
        'passStep': 1,
      });
      expect((r.phase, r.roomStep), (RunPhase.roomBreak, 1));
    });
  });

  group('premios variados y dones de la escuela', () {
    final real = RunEngine(loadGameDataFromDir());
    final def = real.data.balance.combatRewards;

    RunState at(int seed, {MetaBonus meta = MetaBonus.none}) => real
        .newRun(seed: seed, meta: meta)
        .copyWith(map: _legacy);

    RunState won(RunState r, String node, {int? hp}) =>
        real.finishCombat(real.enter(r, node), won: true, hp: hp ?? r.hp - 10);

    test('el premio sale con los pesos de la etapa y es reproducible', () {
      final counts = <RewardKind, int>{};
      for (var seed = 0; seed < 2000; seed++) {
        final r = won(at(seed), 'n1');
        expect(r.phase, RunPhase.reward);
        counts[r.rewardKind] = (counts[r.rewardKind] ?? 0) + 1;
        expect(won(at(seed), 'n1').rewardKind, r.rewardKind);
        expect(r.rewardOptions.isNotEmpty, r.rewardKind == RewardKind.cards);
      }
      final w = def.weightsAt(0);
      final total = w.values.fold(0, (a, b) => a + b);
      for (final k in RewardKind.values) {
        expect(counts[k] ?? 0, closeTo(2000 * w[k]! / total, 70),
            reason: k.name);
      }
    });

    test('el jefe y el que se escapa dejan cartas; el élite no da otro '
        'talismán', () {
      for (var seed = 0; seed < 200; seed++) {
        final boss = won(at(seed).copyWith(currentNode: 'n5', visited: ['n5']),
            'n6');
        expect(boss.rewardKind, RewardKind.cards);
        final fled = real.finishCombat(real.enter(at(seed), 'n1'),
            won: true, hp: 30, fledWith: 0);
        expect(fled.rewardKind, RewardKind.cards);
        expect(fled.lotusGained, 0);
        final elite = won(
            at(seed).copyWith(currentNode: 'n4', visited: ['n4']), 'n5');
        expect(elite.phase, RunPhase.talisman);
        expect(elite.rewardKind, isNot(RewardKind.talisman));
      }
    });

    test('con la Vida llena no sale té, y nunca más de 2 sin cartas', () {
      for (var seed = 0; seed < 400; seed++) {
        final full = won(at(seed), 'n1', hp: 50);
        expect(full.rewardKind, isNot(RewardKind.tea));
        final streak = won(at(seed).copyWith(cardlessStreak: 2), 'n1');
        expect(streak.rewardKind, RewardKind.cards);
        expect(streak.cardlessStreak, 0);
      }
    });

    RunState kindAt(RewardKind kind, {MetaBonus meta = MetaBonus.none}) {
      for (var seed = 0;; seed++) {
        final r = won(at(seed, meta: meta), 'n1');
        if (r.rewardKind == kind) return r;
      }
    }

    test('jade, loto y té se cobran al tomarlos', () {
      final jade = kindAt(RewardKind.jade);
      expect(jade.rewardAmount, def.jadeAt(0));
      final j = real.collectReward(jade);
      expect(j.jade, jade.jade + def.jadeAt(0));
      expect(j.phase, RunPhase.map);
      final lotus = kindAt(RewardKind.lotus);
      final l = real.collectReward(lotus);
      expect(l.lotus,
          lotus.lotus + real.data.balance.meridians.lotus.rewardAt(0));
      expect(l.stageLotus, l.lotus);
      final tea = kindAt(RewardKind.tea);
      final t = real.collectReward(tea);
      expect(t.hp, math.min(tea.maxHp, tea.hp + tea.rewardAmount));
      expect(() => real.chooseRewardUpgrade(tea, 0), throwsStateError);
    });

    test('temple y talismán se eligen; el temple también se puede saltear',
        () {
      final up = kindAt(RewardKind.upgrade);
      final card = up.deck.firstWhere(real.canUpgrade);
      final u = real.chooseRewardUpgrade(up, card.uid);
      expect(u.deck.firstWhere((c) => c.uid == card.uid).upgrades,
          card.upgrades + real.data.balance.fountainUpgrade);
      expect(real.collectReward(up).deck, up.deck);
      final tal = kindAt(RewardKind.talisman);
      expect(tal.talismanOptions, hasLength(def.talismanChoices));
      final id = tal.talismanOptions.first;
      final t = real.chooseRewardTalisman(tal, id);
      expect(t.talismans, contains(id));
      expect(t.phase, RunPhase.map);
    });

    test('cada combate deja loto; la cumbre deja más', () {
      final lotus = real.data.balance.meridians.lotus;
      final r = won(at(1), 'n1');
      expect(r.lotus, lotus.perCombat);
      final summit = won(
          at(1).copyWith(currentNode: 'n5', visited: ['n5'], stage: 2), 'n6');
      expect(summit.phase, RunPhase.victory);
      expect(summit.lotus, lotus.perCombat + lotus.boss + lotus.victory);
      final more = won(at(1, meta: const MetaBonus(lotusPct: 100)), 'n1');
      expect(more.lotus, lotus.perCombat * 2);
    });

    test('el jade que sobra se ofrenda como loto', () {
      final per = real.data.balance.meridians.lotus.jadePer;
      expect(per, greaterThan(0));
      final r = at(1);
      expect(real.offeringOf(r.copyWith(jade: 0)), 0);
      expect(real.offeringOf(r.copyWith(jade: per - 1)), 0);
      expect(real.offeringOf(r.copyWith(jade: per * 7 + 2)), 7);
      final more = at(1, meta: const MetaBonus(lotusPct: 100));
      expect(real.offeringOf(more.copyWith(jade: per * 7)), 14);
    });

    test('legado: la carta con la mitad de mejoras o los números', () {
      final def = real.data.balance.legacy;
      expect(def.enabled, isTrue);
      Ascent prev({int stage = 0, String? card = 'hu_zhao'}) => Ascent(
          n: 3, fell: true, floor: 6, floors: 33, stage: stage,
          difficulty: Difficulty.normal, pico: 0,
          keepsake: card, keepsakeUp: 7);
      expect(real.legacyOf(null), isNull, reason: 'la primera subida');
      final near = real.legacyOf(prev())!;
      expect(near.n, 3);
      expect(near.upgrades, 7 * def.upgradePct ~/ 100);
      expect((near.maxHp, near.jade), (0, def.jade));
      final far = real.legacyOf(prev(stage: def.hpStage))!;
      expect((far.maxHp, far.jade), (def.maxHp, 0));
      expect(real.legacyOf(prev(card: null))!.card, isNull);

      // Primero la herencia, después el don de la escuela.
      final start = real.newRun(
          seed: 4, meta: const MetaBonus(startTalisman: 1), legacy: near);
      expect(start.phase, RunPhase.legacy);
      expect(start.talismanOptions, isNotEmpty);
      final back = RunState.fromJson(
          jsonDecode(jsonEncode(start.toJson())) as Map<String, dynamic>);
      expect(back.legacy!.card, 'hu_zhao');
      final withCard = real.chooseLegacy(back, LegacyPick.card);
      expect(withCard.phase, RunPhase.talisman);
      expect(withCard.deck, hasLength(start.deck.length + 1));
      expect(withCard.deck.last.cardId, 'hu_zhao');
      expect(withCard.deck.last.upgrades, near.upgrades);
      expect(withCard.nextUid, start.nextUid + 1);
      final withJade = real.chooseLegacy(start, LegacyPick.stat);
      expect(withJade.jade, start.jade + def.jade);
      final hp = real.chooseLegacy(
          real.newRun(seed: 4, legacy: far), LegacyPick.stat);
      expect(hp.phase, RunPhase.map);
      expect((hp.maxHp, hp.hp), (start.maxHp + def.maxHp, start.hp + def.maxHp));
      expect(
          () => real.chooseLegacy(
              real.newRun(seed: 4, legacy: real.legacyOf(prev(card: null))),
              LegacyPick.card),
          throwsStateError);
    });

    test('los dones se aplican al empezar y quedan guardados', () {
      const meta = MetaBonus(
        maxHp: 4,
        startJade: 15,
        upgradedStarters: 2,
        rerolls: 1,
        startTalisman: 1,
        merchantDiscountPct: 10,
        fountainHeal: 5,
      );
      final base = real.newRun(seed: 9);
      var r = real.newRun(seed: 9, meta: meta);
      expect(r.maxHp, base.maxHp + 4);
      expect(r.jade, 15);
      expect(r.rerollsLeft, 1);
      expect(r.deck.where((c) => c.upgrades > 0), hasLength(2));
      expect(r.phase, RunPhase.talisman, reason: 'el don de la escuela');
      // La fuente cambiaría la curación que se mide abajo.
      r = real.chooseTalisman(
          r, r.talismanOptions.firstWhere((t) => t != 'fuente'));
      expect(r.phase, RunPhase.map);
      expect(r.talismans, hasLength(1));
      expect(real.merchantOf(r).card,
          (real.merchantOf(base).card * 0.9).round());
      expect(real.healOf(r), real.healOf(base) + 5);
      final back = RunState.fromJson(
          jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>);
      expect(back.meta.toJson(), meta.toJson());
    });

    test('volver a tirar cambia las cartas y gasta uno', () {
      final r = kindAt(RewardKind.cards, meta: const MetaBonus(rerolls: 1));
      final again = real.rerollReward(r);
      expect(again.rerollsLeft, 0);
      expect(again.rewardOptions, hasLength(r.rewardOptions.length));
      expect(() => real.rerollReward(again), throwsStateError);
    });

    test('un guardado sin los campos nuevos carga con premio de cartas', () {
      final j = at(1).toJson()
        ..remove('meta')
        ..remove('rewardKind')
        ..remove('lotus');
      final r = RunState.fromJson(j);
      expect(r.rewardKind, RewardKind.cards);
      expect(r.meta.isNone, isTrue);
      expect(r.lotus, 0);
    });
  });

  test('menú de pruebas: arranca en la etapa y el piso pedidos', () {
    final r = run.debugStart(seed: 5, stage: 2, floor: 9);
    expect(r.stage, 2);
    expect(r.phase, RunPhase.map);
    expect(r.style, isNotNull);
    expect(r.visited, hasLength(8));
    // Lo siguiente es el piso 9: el élite de la cumbre.
    final next = run.available(r).map(r.node).toList();
    expect(next.single.enemy, isNotNull);
    expect(next.single.type, NodeType.combat);
  });

  group('armas', () {
    RunState rewarded(RunState r) => run.finishCombat(
      run.enter(r.copyWith(currentNode: 'n4'), 'n5'),
      won: true,
      hp: 30,
    );

    test('el primer élite da a elegir arma, la del camino primero', () {
      var r = rewarded(fresh(3).copyWith(style: Style.snake));
      r = run.chooseTalisman(r, r.talismanOptions.first);
      expect(r.rewardKind, RewardKind.weapon);
      expect(r.weaponOptions, hasLength(3));
      expect(r.weaponOptions.first, 'jian');
      expect(() => run.chooseRewardWeapon(r, 'nope'), throwsStateError);
      r = run.chooseRewardWeapon(r, 'pudao');
      expect(r.weapon, 'pudao');
      expect(r.weaponLevel, 1);
      expect(r.phase, isNot(RunPhase.reward));
    });

    test('con arma, el élite da otro premio y el botín de arma la templa', () {
      final armed = run.equipWeapon(fresh(3), 'gun');
      final r = rewarded(armed);
      expect(r.rewardKind, isNot(RewardKind.weapon));
      final forge = r.copyWith(
        phase: RunPhase.reward,
        rewardKind: RewardKind.weapon,
        weaponOptions: ['gun'],
      );
      final up = run.chooseRewardWeapon(forge, 'gun');
      expect(up.weaponLevel, 2);
      expect(run.canGainWeapon(run.equipWeapon(up, 'gun', level: 3)), isFalse);
    });

    test('las cartas del arma salen en el botín según el nivel', () {
      final r = run.equipWeapon(fresh(3), 'jian', level: 2);
      final ids = {
        for (var seed = 0; seed < 60; seed++)
          ...run.collectReward(r.copyWith(phase: RunPhase.reward)).deck.map(
                (c) => c.cardId,
              ),
      };
      expect(ids, isNotEmpty);
      final pool = run.data.rewardPoolFor(
        r.style,
        weapon: 'jian',
        weaponLevel: 2,
      ).map((c) => c.id);
      expect(pool, containsAll(['jian_ci', 'jian_dian', 'jian_jie']));
      expect(pool, isNot(contains('jian_chuanxin')));
    });

    test('el mercader vende un arma sin arma y la templa con arma', () {
      const shop = MapNodeDef(id: 'm', type: NodeType.merchant, next: []);
      RunState visit(RunState r) =>
          run.enter(r.copyWith(jade: 200, map: [shop]), 'm');
      var r = visit(fresh(5));
      expect(r.shopWeapon, isNotNull);
      final price = run.merchantOf(r).weapon;
      r = run.buyWeapon(r);
      expect(r.weapon, isNotNull);
      expect(r.jade, 200 - price);
      expect(() => run.buyWeapon(r), throwsStateError);

      var f = visit(run.equipWeapon(fresh(5), 'gun'));
      expect(f.shopWeapon, 'gun');
      f = run.buyForge(f);
      expect(f.weaponLevel, 2);
      expect(() => run.buyForge(f), throwsStateError, reason: 'una vez');
    });

    test('el maestro templa hasta el nivel 2', () {
      var r = run.equipWeapon(fresh(3), 'pudao').copyWith(
        phase: RunPhase.master,
      );
      r = run.masterForge(r);
      expect(r.weaponLevel, 2);
      expect(r.phase, RunPhase.map);
      expect(
        () => run.masterForge(r.copyWith(phase: RunPhase.master)),
        throwsStateError,
      );
    });

    test('el arma se guarda con la subida', () {
      final r = run.equipWeapon(fresh(3), 'jian', level: 2).copyWith(
        weaponOptions: ['jian'],
        shopWeapon: 'jian',
        shopForged: true,
      );
      final back = RunState.fromJson(
        jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
      );
      expect(back.weapon, 'jian');
      expect(back.weaponLevel, 2);
      expect(back.weaponOptions, ['jian']);
      expect(back.shopWeapon, 'jian');
      expect(back.shopForged, isTrue);
      final old = RunState.fromJson(
        jsonDecode(jsonEncode(fresh(3).toJson())) as Map<String, dynamic>,
      );
      expect(old.weapon, isNull);
    });
  });
}
