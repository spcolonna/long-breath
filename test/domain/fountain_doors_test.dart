import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/sim/bots.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir('assets/data');
  final run = RunEngine(data);

  RunState atFountain() =>
      run.newRun(seed: 3).copyWith(phase: RunPhase.fountain);

  test('templar mejora dos cartas distintas de una vez', () {
    final r = atFountain();
    expect(data.balance.fountainTemper, 2);
    final ids = bestUpgrades(run, r);
    expect(ids.toSet().length, 2);
    final up = run.fountainUpgrade(r, [...ids, ids.first]);
    final plus = data.balance.fountainUpgrade;
    for (final c in up.deck) {
      expect(c.upgrades, ids.contains(c.uid) ? plus : 0);
    }
    expect(up.phase, RunPhase.map);
  });

  test('nunca templa más cartas que el tope', () {
    final r = atFountain();
    final all = [for (final c in r.deck.where(run.canUpgrade)) c.uid];
    final up = run.fountainUpgrade(r, all);
    expect(up.deck.where((c) => c.upgrades > 0).length,
        data.balance.fountainTemper);
  });

  test('purificar quita una carta y suma Vida máxima y Vida', () {
    final r = atFountain().copyWith(hp: 30);
    final extra = data.balance.fountainRemoveMaxHp;
    expect(extra, greaterThan(0));
    final p = run.fountainRemove(r, r.deck.first.uid);
    expect(p.deck.length, r.deck.length - 1);
    expect(p.maxHp, r.maxHp + extra);
    expect(p.hp, 30 + extra);
  });

  test('sin cartas mejorables no hay nada que templar', () {
    final r = atFountain();
    final bare = r.copyWith(
        deck: [for (final c in r.deck) if (!run.canUpgrade(c)) c]);
    expect(run.fountainTemperOf(bare), 0);
  });

  test('las puertas ya no ofrecen té: Vida no compite con poder', () {
    final def = data.balance.combatRewards;
    for (var stage = 0; stage < 3; stage++) {
      expect(def.weightsAt(stage)[RewardKind.tea] ?? 0, 0);
    }
  });
}
