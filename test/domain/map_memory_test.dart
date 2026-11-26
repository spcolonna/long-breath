import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/memorial.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/run/threads.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

import 'room_trial_test.dart' show settle;

/// El mapa con memoria: la tablilla y la revancha del caído anterior, los
/// atajos de Shuang y la hora del día que va con la altitud.
void main() {
  final data = loadGameDataFromDir();
  final run = RunEngine(data);
  final rooms = data.balance.rooms;
  final floors = [for (final s in data.balance.stages) s.floors.length];

  Ascent ascent({required int floor, int stage = 0, bool fell = true}) =>
      Ascent(
        n: 4,
        fell: fell,
        floor: floor,
        floors: 39,
        difficulty: Difficulty.normal,
        stage: stage,
        enemy: 'bat',
      );

  /// Sube hasta que la fila [depth] esté a la vista (o se corte).
  RunState climbTo(RunState r, int depth) {
    for (var step = 0; step < 20 && r.phase == RunPhase.map; step++) {
      final doors = run.available(r).map(r.node).toList();
      if (doors.isEmpty || doors.first.depth >= depth) break;
      r = settle(run, run.enter(r, doors.first.id));
    }
    return r;
  }

  group('tablilla', () {
    test('sale del último caído: etapa y fila', () {
      final m = memorialFrom([ascent(floor: 5)], floors)!;
      expect((m.n, m.stage, m.depth, m.enemy), (4, 0, 4, 'bat'));
      // En la segunda etapa el piso cuenta las salas de la primera.
      final m2 = memorialFrom([ascent(floor: floors[0] + 3, stage: 1)], floors)!;
      expect((m2.stage, m2.depth), (1, 2));
      // Si el último volvió (o no subió nadie), no hay tablilla.
      expect(memorialFrom([ascent(floor: 5, fell: false)], floors), isNull);
      expect(memorialFrom(const [], floors), isNull);
      expect(Memorial.fromJson(m.toJson()).depth, 4);
    });

    test('la revancha espera en esa fila, con su rival, y paga jade', () {
      // Una fila con peleas comunes de la primera etapa.
      final st = data.balance.stages[0];
      final depth = [
        for (var d = 1; d < st.floors.length - 2; d++)
          if (st.floors[d].types.keys.contains(NodeType.combat) &&
              st.floors[d].enemies.isNotEmpty)
            d,
      ].first;
      final foe = st.floors[depth].enemies.last;
      var found = 0;
      for (var seed = 1; seed <= 12; seed++) {
        var r = run.newRun(
          seed: seed,
          memorial: Memorial(n: 7, stage: 0, depth: depth, enemy: foe),
        );
        r = climbTo(r, depth);
        if (r.phase != RunPhase.map) continue;
        final doors = run.available(r).map(r.node).toList();
        if (doors.first.depth != depth) continue;
        expect(run.memorialAt(r, depth), isTrue);
        final revenge = doors.where((d) => d.mark == NodeMark.revenge);
        if (!doors.any(
          (d) =>
              d.type == NodeType.combat &&
              data.enemy(d.enemy!).rank == data.enemy(foe).rank,
        )) {
          continue;
        }
        expect(revenge, hasLength(1));
        expect(revenge.single.foes, contains(foe));
        found++;
        // Se guarda con la subida.
        expect(RunState.fromJson(r.toJson()).memorial?.n, 7);
        expect(RunState.fromJson(r.toJson()).node(revenge.single.id).mark,
            NodeMark.revenge);
        final before = r.jade;
        final won = run.finishCombat(
          run.enter(r, revenge.single.id),
          won: true,
          hp: r.hp,
        );
        expect(won.revengeJade, rooms.revengeJadeAt(0));
        expect(won.jade - before, greaterThanOrEqualTo(won.revengeJade));
      }
      expect(found, greaterThan(0));
    });

    test('sin tablilla (o en otra etapa) no hay revancha', () {
      for (var seed = 1; seed <= 10; seed++) {
        var r = run.newRun(
          seed: seed,
          memorial: const Memorial(n: 2, stage: 1, depth: 2, enemy: 'bat'),
        );
        for (var step = 0; step < 6 && r.phase == RunPhase.map; step++) {
          final doors = run.available(r).map(r.node).toList();
          expect(doors.where((d) => d.mark == NodeMark.revenge), isEmpty);
          r = settle(run, run.enter(r, doors.first.id));
        }
      }
    });
  });

  group('atajos de Shuang', () {
    Map<NodeMark, int> marks(Set<String> threads) {
      final out = <NodeMark, int>{};
      for (var seed = 1; seed <= 30; seed++) {
        var r = run.newRun(seed: seed, threads: threads);
        var stage = 0;
        for (var step = 0; step < 14 && r.phase == RunPhase.map; step++) {
          if (r.stage != stage) break;
          final doors = run.available(r).map(r.node).toList();
          if (doors.isEmpty) break;
          for (final d in doors.where((d) => d.mark != null)) {
            out[d.mark!] = (out[d.mark!] ?? 0) + 1;
            expect(data.enemy(d.enemy!).rank, EnemyRank.common);
            // Solo con capítulos de su hilo (leídos antes o en esta subida).
            if (d.mark == NodeMark.shuang) {
              expect(chapterOf(r.threads, threadShuang), greaterThan(0));
            }
          }
          r = settle(run, run.enter(r, doors.first.id));
          stage = r.stage;
        }
        // Nunca más del tope por etapa.
        expect(
          r.map.where((n) => n.mark == NodeMark.shuang).length,
          lessThanOrEqualTo(rooms.shuangMax),
        );
      }
      return out;
    }

    test('solo con capítulos de su hilo', () {
      marks(const {});
      expect(
        marks(const {'shuang_1', 'shuang_2'})[NodeMark.shuang],
        greaterThan(0),
      );
    });

    test('los rivales del atajo arrancan cansados', () {
      final engine = CombatEngine(data);
      CombatState start(int weaken) => engine
          .start(
            deck: const [CombatCard(uid: 0, cardId: 'ge_dang')],
            enemyId: 'salamander',
            style: null,
            playerHp: 50,
            seed: 1,
            weakenPct: weaken,
          )
          .state;
      final full = start(0).enemies.first;
      final tired = start(rooms.shuangWeaken).enemies.first;
      expect(tired.maxHp, full.maxHp);
      expect(tired.hp, full.hp * (100 - rooms.shuangWeaken) ~/ 100);
    });
  });

  test('la hora del día va con la altitud: sin ocaso al pie ni alba arriba',
      () {
    expect(RunEngine.timeOfDay('ocaso', 0, 13), 'alba');
    expect(RunEngine.timeOfDay('alba', 12, 13), 'ocaso');
    expect(RunEngine.timeOfDay('niebla', 12, 13), 'niebla');
    expect(RunEngine.timeOfDay('alba', 6, 13), 'alba');
    for (var seed = 1; seed <= 20; seed++) {
      var r = run.newRun(seed: seed);
      for (var step = 0; step < 13 && r.phase == RunPhase.map; step++) {
        final doors = run.available(r).map(r.node).toList();
        if (doors.isEmpty) break;
        final n = run.depthsOf(r);
        for (final d in doors) {
          if (d.light == null) continue;
          if (d.depth / (n - 1) < 0.4) expect(d.light, isNot('ocaso'));
          if (d.depth / (n - 1) >= 0.7) expect(d.light, isNot('alba'));
        }
        r = settle(run, run.enter(r, doors.first.id));
      }
    }
  });
}
