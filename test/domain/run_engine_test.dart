import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final run = RunEngine(loadGameDataFromDir());

  test('camino completo con bifurcación, recompensa y fuente', () {
    var r = run.newRun(age: Age.adult, seed: 3);
    expect(r.deck.length, 12);
    expect(run.available(r), ['n1']);
    r = run.enter(r, 'n1');
    expect(r.phase, RunPhase.combat);
    expect(run.enemyOf(r), 'bat');
    r = run.finishCombat(r, won: true, hp: 40);
    expect(r.rewardOptions.length, 3);
    r = run.chooseReward(r, r.rewardOptions.first);
    expect(r.deck.length, 13);
    r = run.enter(r, 'n2');
    r = run.finishCombat(r, won: true, hp: 30);
    r = run.chooseReward(r, null); // saltear
    expect(r.deck.length, 13);
    expect(run.available(r), ['n3a', 'n3b']);
    r = run.enter(r, 'n3b');
    r = run.finishCombat(r, won: true, hp: 30);
    r = run.chooseReward(r, null);
    r = run.enter(r, 'n4');
    expect(r.phase, RunPhase.fountain);
    r = run.fountainHeal(r);
    expect(r.hp, 45);
  });

  test('fuente: mejorar y eliminar', () {
    var r = run.newRun(age: Age.adult, seed: 1)
        .copyWith(phase: RunPhase.fountain);
    final up = run.fountainUpgrade(r, 0);
    expect(up.deck.first.upgrades, 3);
    final rm = run.fountainRemove(r, 0);
    expect(rm.deck.length, 11);
  });

  test('derrota termina la run; victoria en el guardián', () {
    var r = run.enter(run.newRun(age: Age.adult, seed: 1), 'n1');
    expect(run.finishCombat(r, won: false, hp: 0).phase, RunPhase.defeat);
    r = r.copyWith(currentNode: 'n6');
    expect(run.finishCombat(r, won: true, hp: 5).phase, RunPhase.victory);
  });

  test('serialización ida y vuelta', () {
    final r = run.enter(run.newRun(age: Age.elder, seed: 9), 'n1');
    final back = RunState.fromJson(r.toJson());
    expect(back.toJson(), r.toJson());
  });
}
