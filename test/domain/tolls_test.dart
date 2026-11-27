import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// Los tramos con costo: pagar nunca lleva a algo peor que el sendero
/// gratis de la misma fila.
void main() {
  final run = RunEngine(loadGameDataFromDir('assets/data'));
  final data = run.data;
  final b = data.balance;

  bool fight(MapNodeDef n) => n.type == NodeType.combat;
  EnemyRank? rank(MapNodeDef n) =>
      fight(n) ? data.enemy(n.enemy!).rank : null;

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
          final ev = data.event(r.eventId!);
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

  /// Todas las filas ofrecidas en subidas enteras, con jade y llaves de
  /// sobra para ver todos los tramos; elige puertas pagas cuando puede.
  Iterable<(List<MapNodeDef>, RunState)> rows({int seeds = 80}) sync* {
    for (var seed = 1; seed <= seeds; seed++) {
      var r = run.newRun(seed: seed).copyWith(jade: 999, keys: 3);
      for (var guard = 0; guard < 60; guard++) {
        if (r.phase == RunPhase.stageClear) {
          r = run.advanceStage(r, awakening: r.awakeningOptions.firstOrNull);
        }
        if (r.phase != RunPhase.map) break;
        final doors = run.available(r).map(r.node).toList();
        yield (doors, r);
        final paid = doors.indexWhere((d) => d.toll != PathToll.free);
        final pick = doors[paid >= 0 && seed.isEven ? paid : seed % doors.length];
        r = settle(run.enter(r, pick.id).copyWith(jade: 999));
      }
    }
  }

  test('cada tramo pago garantiza su nivel y siempre queda uno gratis', () {
    final seen = <PathToll>{};
    for (final (doors, r) in rows()) {
      final free = doors.where((d) => d.toll == PathToll.free).toList();
      expect(free, isNotEmpty, reason: 'sin sendero llano: ${doors.map((d) => d.id)}');
      // Si la fila tiene peleas, una se puede tomar gratis (no se esquiva
      // pelear por falta de jade).
      if (doors.any(fight)) expect(free.any(fight), isTrue);
      for (final d in doors) {
        seen.add(d.toll);
        switch (d.toll) {
          case PathToll.free:
            // Gratis nunca es un élite que se pueda esquivar.
            if (d.sign != null) expect(rank(d), isNot(EnemyRank.elite));
          case PathToll.jade:
            // Una pelea común (el mismo riesgo que el sendero llano) que
            // paga con talismán, el premio de más arriba de las puertas,
            // y cuesta menos que un talismán en la tienda.
            expect(rank(d), EnemyRank.common);
            expect(d.reward, RewardKind.talisman);
            expect(d.tollCost, greaterThan(0));
            expect(d.tollCost, lessThan(run.merchantOf(r).talisman));
          case PathToll.breath:
            expect(rank(d), EnemyRank.elite);
            expect(d.tollCost, b.tolls.breath);
          case PathToll.key:
            expect(d.type, NodeType.event);
            expect(d.tollCost, 1);
        }
      }
    }
    expect(seen, containsAll(PathToll.values));
  });

  test('el cofre sellado solo tiene opciones buenas y sin costo', () {
    final chest = data.event(RunEngine.sealedChest);
    expect(chest.options, hasLength(greaterThanOrEqualTo(2)));
    for (final o in chest.options) {
      expect(o.price, 0, reason: o.id);
      expect(o.chance, isNull, reason: o.id);
      expect(o.duel, isNull, reason: o.id);
      expect(o.outcome.hp, 0, reason: o.id);
      expect(o.outcome.maxHp, greaterThanOrEqualTo(0), reason: o.id);
      expect(o.outcome.gain != null || o.outcome.jade > 0, isTrue, reason: o.id);
    }
  });

  test('la senda oculta usa la llave y abre el cofre; nunca sale al azar', () {
    var found = false;
    for (final (doors, r) in rows()) {
      for (final d in doors.where((d) => d.toll == PathToll.key)) {
        final inside = run.enter(r, d.id);
        expect(inside.keys, r.keys - 1);
        expect(inside.eventId, RunEngine.sealedChest);
        found = true;
      }
      for (final d in doors.where(
        (d) => d.type == NodeType.event && d.toll == PathToll.free,
      )) {
        expect(run.enter(r, d.id).eventId, isNot(RunEngine.sealedChest));
      }
    }
    expect(found, isTrue);
  });

  test('el peaje se cobra, no se puede entrar sin jade y vuelve al retirarse', () {
    final (doors, r) = rows().firstWhere(
      (e) => e.$1.any((d) => d.toll == PathToll.jade),
    );
    final door = doors.firstWhere((d) => d.toll == PathToll.jade);
    final broke = r.copyWith(jade: door.tollCost - 1);
    expect(run.canPay(broke, door.id), isFalse);
    expect(run.enterable(broke), isNot(contains(door.id)));
    expect(() => run.enter(broke, door.id), throwsStateError);

    final rich = r.copyWith(jade: 100);
    final inside = run.enter(rich, door.id);
    expect(inside.jade, 100 - door.tollCost);
    final back = run.retreat(inside);
    expect(back.jade, 100);
    expect(run.available(back), contains(door.id));
  });

  test('la cuesta: Aliento de menos en el primer turno y una llave al ganar', () {
    final (doors, r) = rows().firstWhere(
      (e) => e.$1.any((d) => d.toll == PathToll.breath),
    );
    final door = doors.firstWhere((d) => d.toll == PathToll.breath);
    final won = run.finishCombat(run.enter(r, door.id), won: true, hp: r.hp);
    expect(won.keys, r.keys + b.tolls.eliteKeys);

    final engine = CombatEngine(data);
    CombatState start(int toll) => engine
        .start(
          deck: [
            for (final (i, id) in data.starterDeck.indexed)
              CombatCard(uid: i, cardId: id),
          ],
          enemyId: door.enemy!,
          style: Style.snake,
          playerHp: 50,
          seed: 1,
          breathToll: toll,
        )
        .state;
    expect(start(1).player.breath, start(0).player.breath - 1);
  });

  test('los puntos fijos se ven tal cual; lo demás, por su pista', () {
    for (final (doors, _) in rows(seeds: 30)) {
      for (final d in doors) {
        final fixed = d.type == NodeType.master ||
            d.type == NodeType.fountain ||
            d.type == NodeType.shrine ||
            rank(d) == EnemyRank.boss ||
            (rank(d) == EnemyRank.elite && doors.length == 1);
        expect(d.sign == null, fixed, reason: '${d.id} ${d.type}');
      }
    }
  });

  test('tramo, pista y llaves sobreviven al guardado', () {
    final (_, r) = rows().firstWhere(
      (e) => e.$1.any((d) => d.toll == PathToll.jade),
    );
    final back = RunState.fromJson(r.toJson());
    expect(back.toJson(), r.toJson());
    expect(back.keys, r.keys);
    final paid = back.map.firstWhere((n) => n.toll == PathToll.jade);
    expect(paid.tollCost, greaterThan(0));
    expect(paid.sign, isNotNull);
  });
}
