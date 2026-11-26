import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/run/true_summit.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final run = RunEngine(data);
  final endings = {for (final s in Style.values) endingOf(s)};

  /// En la sala del último jefe, peleando.
  RunState atLastBoss({bool trueSummit = false}) {
    final floors = data.balance.stages.last.floors.length;
    var r = run.debugStart(seed: 7, stage: 2, floor: floors);
    r = r.copyWith(trueSummit: trueSummit);
    final boss = run.available(r).first;
    r = run.enter(r, boss);
    expect(run.packOf(r), ['sleeping_dragon']);
    return r.copyWith(phase: RunPhase.combat);
  }

  test('pide los tres finales, el Pico 5 y la escuela entera', () {
    bool ready({Set<String>? lore, int pico = 6, bool school = true}) =>
        trueSummitReady(
          lore: lore ?? endings,
          picoUnlocked: pico,
          schoolDone: school,
        );
    expect(ready(), isTrue);
    expect(ready(pico: 5), isFalse, reason: 'el Pico 5 abierto no alcanza');
    expect(ready(school: false), isFalse);
    expect(ready(lore: {endingOf(Style.tiger)}), isFalse);
    expect(
      ready(lore: {...endings, trueEndingLore}),
      isFalse,
      reason: 'después de verlo, el dragón ya no sueña',
    );
  });

  test('sin final verdadero, el Dragón Dormido termina la subida', () {
    final r = run.finishCombat(atLastBoss(), won: true, hp: 20);
    expect(r.phase, RunPhase.victory);
  });

  test('con final verdadero se levanta el Primer Discípulo', () {
    final r = run.finishCombat(atLastBoss(trueSummit: true), won: true, hp: 20);
    expect(r.phase, RunPhase.combat);
    expect(r.dreamFight, isTrue);
    expect(r.hp, r.maxHp, reason: 'el caldo de Ming cura todo');
    expect(run.packOf(r), [trueBoss]);
    expect(data.enemy(trueBoss).rank, EnemyRank.boss);
    expect(RunState.fromJson(r.toJson()).dreamFight, isTrue);
    // Cerrar la app a mitad de la pelea la retoma en la cumbre.
    expect(run.retreat(r).dreamFight, isTrue);
    expect(run.retreat(r).phase, RunPhase.combat);
    final won = run.finishCombat(r, won: true, hp: 30);
    expect(won.phase, RunPhase.victory);
    final lost = run.finishCombat(r, won: false, hp: 0);
    expect(lost.phase, RunPhase.defeat);
  });

  test('vencerlo abre el final verdadero', () {
    Ascent win(String enemy) => Ascent(
      n: 9,
      fell: false,
      floor: 39,
      floors: 39,
      stage: 2,
      difficulty: Difficulty.normal,
      enemy: enemy,
      style: Style.crane,
    );
    expect(
      earnedLore(win(trueBoss), const [], endings),
      contains(trueEndingLore),
    );
    expect(
      earnedLore(win('sleeping_dragon'), const [], endings),
      isNot(contains(trueEndingLore)),
    );
    expect(loreOrder, contains(trueEndingLore));
  });
}
