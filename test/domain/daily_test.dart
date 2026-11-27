import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/daily.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

import 'room_trial_test.dart' show settle;

/// El desafío diario: la misma montaña para todos cada día, con el camino
/// del día y sin nada de la partida.
void main() {
  final data = loadGameDataFromDir();
  final run = RunEngine(data);

  test('el día, el anterior y la semilla salen de la fecha', () {
    expect(dailyDay(DateTime(2026, 11, 26, 23, 59)), 20261126);
    expect(dailyBefore(20261201), 20261130);
    expect(dailyBefore(20270101), 20261231);
    expect(dailyBefore(20280301), 20280229);
    expect(dailySeed(20261126), dailySeed(20261126));
    expect(dailySeed(20261126), isNot(dailySeed(20261127)));
    expect(dailySeed(20261126), inInclusiveRange(0, 0x7FFFFFFF));
  });

  test('los tres caminos se turnan día a día', () {
    final week = [
      for (var d = 20261123; d < 20261130; d++) dailyStyle(d),
    ];
    for (var i = 0; i + 1 < week.length; i++) {
      expect(week[i + 1], isNot(week[i]));
    }
    expect(week.toSet(), Style.values.toSet());
  });

  test('el mismo día da la misma subida, con su camino y sin la partida', () {
    final a = run.newDaily(20261126);
    final b = run.newDaily(20261126);
    expect(a.toJson(), b.toJson());
    expect(a.daily, 20261126);
    expect(a.style, dailyStyle(20261126));
    expect(a.difficulty, Difficulty.normal);
    expect((a.pico, a.ghost, a.memorial, a.legacy), (0, null, null, null));
    expect(a.threads, isEmpty);
    expect(a.phase, RunPhase.map);
    expect(run.newDaily(20261127).toJson(), isNot(a.toJson()));
    // Se guarda con la subida.
    expect(RunState.fromJson(a.toJson()).daily, 20261126);
    expect(RunState.fromJson(run.newRun(seed: 3).toJson()).daily, isNull);
  });

  test('el santuario confirma el camino del día', () {
    var seen = 0;
    for (var day = 20261120; day < 20261130; day++) {
      var r = run.newDaily(day);
      for (var step = 0; step < 8 && r.phase == RunPhase.map; step++) {
        final doors = run.enterable(r).map(r.node).toList();
        if (doors.isEmpty) break;
        final pick = doors
                .where((d) => d.type == NodeType.shrine)
                .firstOrNull ??
            doors.first;
        r = run.enter(r, pick.id);
        if (r.phase == RunPhase.shrine) {
          expect(r.pathOptions, [dailyStyle(day)]);
          seen++;
        }
        r = settle(run, r);
        expect(r.style, dailyStyle(day));
        expect(r.daily, day);
      }
    }
    expect(seen, greaterThan(0));
  });

  test('estadísticas por camino y racha', () {
    const results = [
      DailyResult(day: 20261122, style: Style.tiger, floor: 9, done: true),
      DailyResult(day: 20261124, style: Style.snake, floor: 20, done: true),
      DailyResult(
        day: 20261125,
        style: Style.snake,
        won: true,
        floor: 39,
        done: true,
      ),
      DailyResult(day: 20261126, style: Style.crane),
    ];
    final s = dailyStats(results, 20261126);
    expect(s.streak, 3);
    expect((s.played, s.won), (4, 1));
    expect(s.paths[Style.snake]!.played, 2);
    expect(s.paths[Style.snake]!.won, 1);
    expect(s.paths[Style.snake]!.best, 39);
    expect(s.paths[Style.tiger]!.best, 9);
    // Si hoy todavía no jugó, la racha sigue desde ayer.
    expect(dailyStats(results.take(3), 20261126).streak, 2);
    expect(dailyStats(results.take(3), 20261127).streak, 0);
    final back = DailyResult.fromJson(results[2].toJson())!;
    expect((back.day, back.style, back.won, back.floor, back.done),
        (20261125, Style.snake, true, 39, true));
    expect(DailyResult.fromJson(const {'d': 1, 's': 'nada'}), isNull);
  });
}
