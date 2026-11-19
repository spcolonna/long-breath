import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/sim/bots.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

import '../../tool/sim/lab.dart';

void main() {
  final data = loadGameDataFromDir('assets/data');
  final run = RunEngine(data);

  test('la fuente cura aunque falte poca Vida (el promedio mejoraría)', () {
    final r0 = run.newRun(seed: 1);
    final r = r0.copyWith(phase: RunPhase.fountain, hp: r0.maxHp - 3);
    expect(PrudentBot(1).useFountain(run, r).hp, r.maxHp);
    expect(AverageBot(1).useFountain(run, r).hp, r.hp);
  });

  test('en un evento elige la opción que cura', () {
    final r0 = run.newRun(seed: 1);
    final r = r0.copyWith(
        phase: RunPhase.event, eventId: 'spring', hp: r0.maxHp - 20);
    expect(PrudentBot(1).pickEventOption(run, r), 'drink');
  });

  test('juega subidas enteras y se cura más veces que el promedio', () {
    var prudentHeal = 0, averageHeal = 0;
    for (var seed = 1; seed <= 30; seed++) {
      final p = playRun(data, profiles['prudente']!(seed), seed);
      final a = playRun(data, profiles['promedio']!(seed), seed);
      expect(p.fights, isNotEmpty);
      prudentHeal += p.heals;
      averageHeal += a.heals;
    }
    expect(prudentHeal, greaterThan(averageHeal));
  });
}
