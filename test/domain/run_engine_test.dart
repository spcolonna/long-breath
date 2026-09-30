import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final run = RunEngine(loadGameDataFromDir());

  test('camino completo con bifurcación, recompensa y fuente', () {
    var r = run.newRun(seed: 3);
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
    r = run.enter(r, 'n4');
    expect(r.phase, RunPhase.fountain);
    r = run.fountainHeal(r);
    expect(r.hp, 45);
  });

  test('fuente: mejorar y eliminar', () {
    var r = run.newRun(seed: 1)
        .copyWith(phase: RunPhase.fountain);
    final up = run.fountainUpgrade(r, 0);
    expect(up.deck.first.upgrades, 3);
    final rm = run.fountainRemove(r, 0);
    expect(rm.deck.length, 11);
  });

  test('derrota termina la run; victoria en el guardián', () {
    var r = run.enter(run.newRun(seed: 1), 'n1');
    expect(run.finishCombat(r, won: false, hp: 0).phase, RunPhase.defeat);
    r = r.copyWith(currentNode: 'n6');
    expect(run.finishCombat(r, won: true, hp: 5).phase, RunPhase.victory);
  });

  test('el santuario solo acepta los caminos que ofrece', () {
    final r = run.newRun(seed: 5).copyWith(currentNode: 'n2');
    final shrine = run.enter(r, 'ns');
    final missing =
        Style.values.firstWhere((s) => !shrine.pathOptions.contains(s));
    expect(() => run.choosePath(shrine, missing), throwsStateError);
  });

  test('serialización ida y vuelta', () {
    final novice = run.enter(run.newRun(seed: 9), 'n1');
    expect(RunState.fromJson(novice.toJson()).toJson(), novice.toJson());
    final shrine =
        run.enter(run.newRun(seed: 9).copyWith(currentNode: 'n2'), 'ns');
    expect(RunState.fromJson(shrine.toJson()).toJson(), shrine.toJson());
    final chosen = run.choosePath(shrine, shrine.pathOptions.first);
    expect(RunState.fromJson(chosen.toJson()).style, chosen.style);
  });

  test('retomar un combate a medias vuelve al mapa antes de ese nodo', () {
    final first = run.enter(run.newRun(seed: 3), 'n1');
    final back = run.retreat(first);
    expect(back.phase, RunPhase.map);
    expect(back.currentNode, isNull);
    expect(back.visited, isEmpty);
    expect(run.available(back), ['n1']);

    final second = run.enter(back.copyWith(currentNode: 'n1', visited: ['n1']), 'n2');
    final back2 = run.retreat(second);
    expect(back2.currentNode, 'n1');
    expect(run.available(back2), ['n2']);
  });
}
