import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/path_gen.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// El sendero de salas: cada etapa es una cadena de salas y, al terminar
/// cada una, se elige entre las puertas que siguen.
void main() {
  final run = RunEngine(loadGameDataFromDir('assets/data'));
  final b = run.data.balance;

  /// Juega lo que no es el mapa: gana los combates, toma lo primero.
  RunState settle(RunState r) {
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
            ev.options
                .lastWhere((o) => o.duel == null && run.canChoose(r, o))
                .id,
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

  /// Sube una etapa entera eligiendo con [pick]; devuelve las filas de
  /// puertas ofrecidas y el estado al terminar (etapa superada o cumbre).
  (List<List<MapNodeDef>>, RunState) climb(
    RunState r,
    int Function(List<MapNodeDef> doors) pick,
  ) {
    final rows = <List<MapNodeDef>>[];
    while (r.phase == RunPhase.map) {
      final doors = run.available(r).map(r.node).toList();
      rows.add(doors);
      r = settle(run.enter(r, doors[pick(doors)].id));
    }
    return (rows, r);
  }

  bool fight(MapNodeDef n) => n.type == NodeType.combat;

  test('cada etapa: 13 salas, con élite, fuente y jefe al final', () {
    for (var seed = 1; seed <= 60; seed++) {
      var r = run.newRun(seed: seed);
      for (var st = 0; st < b.stages.length; st++) {
        final floors = b.stages[st].floors;
        final (rows, end) = climb(r, (d) => seed % d.length);
        expect(rows, hasLength(floors.length), reason: 'semilla $seed');
        final trail = [for (final id in end.visited) end.node(id)];
        expect(trail.last.enemy, floors.last.enemies.single);
        expect(trail[trail.length - 2].type, NodeType.fountain);
        expect(
          run.data.enemy(trail[trail.length - 3].enemy!).rank,
          EnemyRank.elite,
        );
        if (st == b.stages.length - 1) {
          expect(end.phase, RunPhase.victory);
          break;
        }
        expect(end.phase, RunPhase.stageClear);
        r = run.advanceStage(end, awakening: end.awakeningOptions.firstOrNull);
      }
    }
  });

  test('las puertas no dejan esquivar las peleas', () {
    final rules = b.path;
    for (var seed = 1; seed <= 300; seed++) {
      // El que siempre elige lo que no es pelea: el peor caso.
      final (rows, end) = climb(run.newRun(seed: seed), (d) {
        final calm = d.indexWhere((n) => !fight(n));
        return calm < 0 ? 0 : calm;
      });
      final trail = [for (final id in end.visited) end.node(id)];
      expect(trail.where(fight).length, greaterThanOrEqualTo(rules.minFights));
      var rest = 0;
      for (final n in trail) {
        rest = fight(n) ? 0 : rest + 1;
        expect(rest, lessThanOrEqualTo(rules.maxRest), reason: 'semilla $seed');
      }
      for (var d = 0; d < rows.length; d++) {
        final floor = b.stages[0].floors[d];
        if ((floor.types[NodeType.combat] ?? 0) > 0) {
          expect(rows[d].any(fight), isTrue, reason: 'semilla $seed piso $d');
        }
        final kinds = [for (final n in rows[d]) '${n.type}:${n.reward}'];
        expect(rows[d].map((n) => n.id).toSet(), hasLength(rows[d].length));
        expect(kinds, isNotEmpty);
      }
    }
  });

  test('maestro a tiempo, mercader en el camino y a lo sumo un desvío', () {
    final rules = b.path;
    var merchants = 0;
    for (var seed = 1; seed <= 300; seed++) {
      final (rows, _) = climb(run.newRun(seed: seed), (d) {
        final f = d.indexWhere(fight);
        return f < 0 ? 0 : f;
      });
      final offered = rows.expand((x) => x).toList();
      final master = rows.indexWhere(
        (row) => row.any((n) => n.type == NodeType.master),
      );
      expect(
        master,
        inInclusiveRange(0, rules.masterBy - 1),
        reason: 'semilla $seed',
      );
      if (offered.any((n) => n.type == NodeType.merchant)) merchants++;
      final floors = b.stages[0].floors;
      final detours = [
        for (var d = 0; d < rows.length; d++)
          for (final n in rows[d])
            if (floors[d].elite > 0 &&
                n.enemy != null &&
                run.data.enemy(n.enemy!).rank == EnemyRank.elite)
              n,
      ];
      expect(detours.length, lessThanOrEqualTo(1));
      // Los comunes muestran su premio; élites y jefe, no.
      for (final n in offered.where(fight)) {
        final common = run.data.enemy(n.enemy!).rank == EnemyRank.common;
        expect(n.reward != null, common, reason: n.enemy);
      }
    }
    expect(merchants, 300, reason: 'toda etapa ofrece mercader');
  });

  test('retirarse vuelve a las mismas puertas', () {
    var r = run.newRun(seed: 4);
    r = settle(run.enter(r, run.available(r).first));
    final doors = run.available(r);
    final fightDoor = doors.firstWhere((id) => fight(r.node(id)));
    final inside = run.enter(r, fightDoor);
    final back = run.retreat(inside);
    expect(run.available(back), doors);
    // Entrar por otra puerta tira otras salas más arriba, sin repetir ids.
    final other = doors.firstWhere((id) => id != fightDoor, orElse: () => '');
    if (other.isNotEmpty) {
      final again = run.enter(back, other);
      final ids = [for (final n in again.map) n.id];
      expect(ids.toSet(), hasLength(ids.length));
    }
  });

  test('la sala ganada da el premio que mostraba la puerta', () {
    for (var seed = 1; seed <= 40; seed++) {
      var r = settle(
        run.enter(
          run.newRun(seed: seed),
          run.available(run.newRun(seed: seed)).first,
        ),
      );
      final door = run
          .available(r)
          .map(r.node)
          .firstWhere(
            (n) => fight(n) && n.reward != null,
            orElse: () => r.node(run.available(r).first),
          );
      if (door.reward == null) continue;
      r = run.finishCombat(run.enter(r, door.id), won: true, hp: r.hp);
      final expected = switch (door.reward!) {
        RewardKind.tea when r.hp >= r.maxHp => RewardKind.jade,
        final k => k,
      };
      expect(r.rewardKind, expected, reason: 'semilla $seed');
    }
  });

  test('las puertas salen de la semilla: mismas puertas, mismo sendero', () {
    final a = run.newRun(seed: 9);
    final c = run.newRun(seed: 9);
    expect(a.toJson(), c.toJson());
    final (doors, _) = rollDoors(
      b.stages[0].floors,
      DoorContext(depth: 3, rules: b.path),
      Rng.seeded(1),
      packable: run.packable,
    );
    expect(doors, isNotEmpty);
    expect(RunState.fromJson(a.toJson()).toJson(), a.toJson());
  });
}
