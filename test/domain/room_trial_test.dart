import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/content_text.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enemy_def.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// Peleas comunes con variedad: condiciones de sala, retos, rivales que
/// reaccionan y roles de grupo.
void main() {
  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);
  final rooms = data.balance.rooms;

  CombatState setup(
    List<String> ids, {
    String enemy = 'salamander',
    List<String> waves = const [],
    bool together = false,
    RoomRule? room,
    Challenge? challenge,
    int hp = 50,
    int stage = 0,
  }) => engine
      .start(
        deck: [
          for (var i = 0; i < ids.length; i++)
            CombatCard(uid: i, cardId: ids[i]),
        ],
        enemyId: enemy,
        waves: waves,
        together: together,
        style: Style.crane,
        playerHp: hp,
        seed: 1,
        shuffle: false,
        stage: stage,
        room: room,
        challenge: challenge,
      )
      .state;

  CombatResult endTurn(CombatState s) =>
      engine.reduce(s, const EndTurn(retain: []));

  CombatResult play(CombatState s, String id) => engine.reduce(
    s,
    PlayCard(s.hand.firstWhere((c) => c.cardId == id).uid),
  );

  const filler = ['ge_dang', 'ge_dang', 'an_zhang', 'tui_zhang', 'tan_tui'];

  group('salas', () {
    test('niebla: la intención no se ve en los turnos impares', () {
      var s = setup([for (var i = 0; i < 20; i++) ...filler], room: RoomRule.fog);
      expect(engine.intentView(s).hidden, isTrue);
      s = endTurn(s).state;
      expect(s.turn, 2);
      expect(engine.intentView(s).hidden, isFalse);
      expect(engine.intentView(setup(filler)).hidden, isFalse);
    });

    test('viento: las patadas cuestan 1 de Aliento menos', () {
      final kick = data.card('tan_tui');
      final windy = setup(filler, room: RoomRule.wind);
      final calm = setup(filler);
      expect(engine.costOf(windy, kick), engine.costOf(calm, kick) - 1);
      final palm = data.card('tui_zhang');
      expect(engine.costOf(windy, palm), engine.costOf(calm, palm));
    });

    test('campana: cada 3 turnos golpea a todos; la Guardia te cubre', () {
      var s = setup(
        [for (var i = 0; i < 30; i++) 'ge_dang'],
        enemy: 'dummy_light',
        room: RoomRule.bell,
        hp: 80,
      );
      expect(engine.bellIn(s), 2);
      final damage = rooms.bellDamageAt(0);
      final events = <CombatEvent>[];
      for (var i = 0; i < 3; i++) {
        final r = endTurn(s);
        events.addAll(r.events);
        s = r.state;
      }
      final tolls = events.whereType<BellTolled>().toList();
      expect(tolls, hasLength(1));
      expect(tolls.single.damage, damage);
      expect(s.enemy.hp, s.enemy.maxHp - damage);
      expect(engine.bellIn(s), 2);
      expect(engine.bellIn(setup(filler)), isNull);
    });

    test('la campana no remata a los rivales', () {
      var s = setup(
        [for (var i = 0; i < 30; i++) 'ge_dang'],
        enemy: 'dummy_light',
        room: RoomRule.bell,
        hp: 80,
      );
      s = s.copyWith(
        enemies: [s.enemy.copyWith(hp: 1)],
      );
      for (var i = 0; i < 3; i++) {
        s = endTurn(s).state;
      }
      expect(s.enemy.hp, 1);
      expect(s.isOver, isFalse);
    });
  });

  group('retos', () {
    test('sin un rasguño: se pierde al recibir daño', () {
      var s = setup(
        [for (var i = 0; i < 20; i++) 'tui_zhang'],
        enemy: 'dummy_basic',
        challenge: Challenge.flawless,
      );
      final r = endTurn(s);
      s = r.state;
      expect(s.player.hp, lessThan(50));
      expect(s.trial.failed, isTrue);
      expect(r.events.whereType<ChallengeFailed>(), hasLength(1));
    });

    test('dos respiros: se pierde al pasar el turno límite', () {
      var s = setup(
        [for (var i = 0; i < 30; i++) 'ge_dang'],
        enemy: 'dummy_light',
        challenge: Challenge.swift,
        hp: 80,
      );
      for (var i = 1; i < rooms.swiftTurns; i++) {
        s = endTurn(s).state;
      }
      expect(s.trial.pending, isTrue);
      s = endTurn(s).state;
      expect(s.turn, rooms.swiftTurns + 1);
      expect(s.trial.failed, isTrue);
    });

    test('pies inquietos: repetir postura lo pierde', () {
      var s = setup(
        [for (var i = 0; i < 30; i++) 'ge_dang'],
        enemy: 'dummy_light',
        challenge: Challenge.noRepeat,
        hp: 80,
      );
      s = endTurn(s).state;
      expect(s.trial.pending, isTrue);
      s = endTurn(s).state;
      expect(s.trial.failed, isTrue);
    });

    test('ganar con el reto en pie lo cumple', () {
      var s = setup(
        [for (var i = 0; i < 20; i++) 'tan_tui'],
        enemy: 'dummy_heights',
        challenge: Challenge.noRepeat,
      );
      s = s.copyWith(enemies: [s.enemy.copyWith(hp: 1)]);
      final r = play(s, 'tan_tui');
      expect(r.state.phase, CombatPhase.won);
      expect(r.state.trial.met, isTrue);
      expect(r.events.whereType<ChallengeMet>(), hasLength(1));
    });

    test('remate en quiebre: rematar sin desequilibrio no lo cumple', () {
      var s = setup(
        [for (var i = 0; i < 20; i++) 'tan_tui'],
        enemy: 'dummy_heights',
        challenge: Challenge.breakFinish,
      );
      s = s.copyWith(enemies: [s.enemy.copyWith(hp: 1)]);
      final r = play(s, 'tan_tui');
      expect(r.state.phase, CombatPhase.won);
      expect(r.state.trial.met, isFalse);
      expect(r.state.trial.failed, isTrue);
    });

    test('el reto cumplido paga jade y cuenta para los hitos', () {
      final run = RunEngine(data);
      var r = run.newRun(seed: 5);
      final door = run.enterable(r).map(r.node).firstWhere(
        (n) => n.type == NodeType.combat,
      );
      r = run.enter(r, door.id);
      final plain = run.finishCombat(r, won: true, hp: r.hp);
      final met = run.finishCombat(r, won: true, hp: r.hp, challengeMet: true);
      expect(met.challengeJade, rooms.challengeJadeAt(0));
      expect(met.jadeGained - plain.jadeGained, rooms.challengeJadeAt(0));
      expect(met.feats['challenges'], 1);
      expect(plain.challengeJade, 0);
    });
  });

  group('rivales que reaccionan', () {
    test('repetir postura: el murciélago cambia a una picada baja', () {
      var s = setup([for (var i = 0; i < 30; i++) 'ge_dang'], enemy: 'bat', hp: 80);
      s = endTurn(s).state;
      expect(s.enemy.reaction, isNull);
      final r = endTurn(s);
      s = r.state;
      expect(s.enemy.reaction, Reaction.repeat);
      expect(r.events.whereType<EnemyReacted>(), hasLength(1));
      final iv = engine.intentView(s);
      expect(iv.reaction, Reaction.repeat);
      expect(iv.intent.height, Height.low);
      // Hace la picada y vuelve a su ciclo donde estaba.
      final pattern = s.enemy.patternIndex;
      final after = endTurn(s).state;
      // Repitió otra vez: vuelve a reaccionar, pero el ciclo no avanzó.
      expect(after.enemy.patternIndex, pattern);
    });

    test('al desequilibrarla, la salamandra se recupera con un coletazo', () {
      var s = setup(filler);
      s = s.copyWith(enemies: [s.enemy.copyWith(structure: 1)]);
      final r = play(s, 'tui_zhang');
      expect(r.state.enemy.staggered, isTrue);
      expect(r.state.enemy.reaction, Reaction.broken);
      // Pierde la acción desequilibrada; la reacción espera.
      s = endTurn(r.state).state;
      expect(s.enemy.reaction, Reaction.broken);
      expect(engine.intentView(s).intent.labelKey, 'tail_lash');
    });

    test('si cae su compañero, el bandido descarga su rabia', () {
      var s = setup(
        [for (var i = 0; i < 20; i++) 'tan_tui'],
        enemy: 'bat',
        waves: ['bandit'],
        together: true,
      );
      s = s.copyWith(enemies: [s.enemies[0].copyWith(hp: 1), s.enemies[1]]);
      final r = play(s, 'tan_tui');
      expect(r.state.enemies[0].hp, 0);
      expect(r.state.enemies[1].reaction, Reaction.allyDown);
      expect(engine.intentView(r.state, 1).intent.labelKey, 'bandit_rage');
    });
  });

  group('roles de grupo', () {
    test('el gólem cubre a su compañero al terminar el turno enemigo', () {
      final s = setup(
        [for (var i = 0; i < 20; i++) 'ge_dang'],
        enemy: 'golem',
        waves: ['bat'],
        together: true,
        hp: 80,
      );
      final r = endTurn(s);
      final shield = r.events.whereType<EnemyShielded>().single;
      expect(shield.to, 1);
      expect(shield.amount, data.enemy('golem').roleValue);
      expect(r.state.enemies[1].guard, greaterThanOrEqualTo(shield.amount));
    });

    test('el lingzhi cura al más herido', () {
      var s = setup(
        [for (var i = 0; i < 20; i++) 'ge_dang'],
        enemy: 'lingzhi',
        waves: ['bat'],
        together: true,
        hp: 80,
      );
      s = s.copyWith(
        enemies: [s.enemies[0], s.enemies[1].copyWith(hp: 10)],
      );
      final r = endTurn(s);
      final heal = r.events.whereType<EnemyHealedAlly>().single;
      expect(heal.to, 1);
      expect(heal.amount, data.enemy('lingzhi').roleValue);
    });

    test('solo, el rol no hace nada', () {
      final r = endTurn(setup([for (var i = 0; i < 20; i++) 'ge_dang'], enemy: 'golem', hp: 80));
      expect(r.events.whereType<EnemyShielded>(), isEmpty);
    });
  });

  group('puertas', () {
    test('las salas comunes traen condición y reto; nunca en la primera fila',
        () {
      final run = RunEngine(data);
      var withRule = 0, withChallenge = 0, commons = 0;
      for (var seed = 1; seed <= 40; seed++) {
        var r = run.newRun(seed: seed);
        for (var step = 0; step < 10 && r.phase == RunPhase.map; step++) {
          final doors = run.enterable(r).map(r.node).toList();
          for (final d in doors) {
            if (d.rule != null || d.challenge != null) {
              expect(d.depth, greaterThanOrEqualTo(rooms.fromDepth));
              expect(data.enemy(d.enemy!).rank, EnemyRank.common);
            }
            if (d.rule == RoomRule.fog) expect(d.light, 'niebla');
            if (d.rule == RoomRule.bridge) {
              expect(d.waves, isNotEmpty);
              expect(d.together, isFalse);
            }
            if (d.type == NodeType.combat &&
                d.depth >= rooms.fromDepth &&
                data.enemy(d.enemy!).rank == EnemyRank.common) {
              commons++;
              if (d.rule != null) withRule++;
              if (d.challenge != null) withChallenge++;
            }
            // Se guardan con la subida.
            expect(MapNodeDef.fromJson(d.toJson()).rule, d.rule);
            expect(MapNodeDef.fromJson(d.toJson()).challenge, d.challenge);
          }
          final pick = doors.firstWhere(
            (d) => d.type != NodeType.combat,
            orElse: () => doors.first,
          );
          r = settle(run, run.enter(r, pick.id));
          if (r.phase != RunPhase.map) break;
        }
      }
      expect(commons, greaterThan(20));
      expect(withRule, greaterThan(0));
      expect(withChallenge, greaterThan(0));
    });
  });

  test('cada condición, reto, reacción y rol tiene su texto', () {
    final text = ContentText(
      jsonDecode(File('assets/l10n/content/es.json').readAsStringSync())
          as Map<String, dynamic>,
    );
    for (final r in RoomRule.values) {
      for (final f in ['name', 'hanzi', 'text']) {
        expect(text.room(r, f), isNot(r.name), reason: '${r.name}.$f');
      }
    }
    for (final c in Challenge.values) {
      for (final f in ['name', 'text']) {
        expect(text.challenge(c, f), isNot(c.name), reason: '${c.name}.$f');
      }
    }
    for (final e in data.enemies.values) {
      for (final i in e.reactions.values) {
        if (i.labelKey != null) {
          expect(text.intent(i.labelKey!), isNot(i.labelKey));
        }
      }
    }
  });
}

/// Juega lo que no es el mapa: gana los combates y toma lo primero.
RunState settle(RunEngine run, RunState r) {
  for (var guard = 0; guard < 20; guard++) {
    switch (r.phase) {
      case RunPhase.combat:
        r = run.finishCombat(r, won: true, hp: r.hp);
      case RunPhase.talisman:
        r = run.chooseTalisman(r, r.talismanOptions.first);
      case RunPhase.reward when r.rewardKind == RewardKind.upgrade:
        r = run.chooseRewardUpgrade(r, r.deck.firstWhere(run.canUpgrade).uid);
      case RunPhase.reward when r.rewardKind == RewardKind.talisman:
        r = run.chooseRewardTalisman(r, r.talismanOptions.first);
      case RunPhase.reward when r.rewardKind == RewardKind.weapon:
        r = run.chooseRewardWeapon(r, r.weaponOptions.first);
      case RunPhase.reward when r.rewardKind != RewardKind.cards:
        r = run.collectReward(r);
      case RunPhase.reward:
        r = run.chooseReward(r, null);
      case RunPhase.event:
        final ev = run.data.event(r.eventId!);
        r = run.resolveEvent(
          r,
          ev.options.lastWhere((o) => o.duel == null && run.canChoose(r, o)).id,
        );
      case RunPhase.master:
        r = run.masterUpgrade(r, r.deck.first.uid);
      case RunPhase.fountain:
        r = run.fountainHeal(r);
      case RunPhase.shrine:
        r = run.choosePath(r, r.pathOptions.first);
      case RunPhase.merchant:
        r = run.leaveShop(r);
      default:
        return r;
    }
  }
  return r;
}
