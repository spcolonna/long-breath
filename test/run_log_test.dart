import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/log/run_log.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/infrastructure/run_log_storage.dart';

void main() {
  final data = loadGameDataFromDir('assets/data');
  final run = RunEngine(data);

  test('el registro anota el camino elegido con sus alternativas', () {
    final r = run.newRun(seed: 7);
    final options = run.available(r);
    final next = run.enter(r, options.first);
    final lines = runDiff(r, next, options: options);
    expect(lines.single, contains('CAMINO etapa 1 piso 1'));
    if (options.length > 1) expect(lines.single, contains('otras:'));
  });

  test('el registro anota cartas, vida y jade que cambian', () {
    final r = run.newRun(seed: 7);
    final b = r.copyWith(hp: r.hp - 5, jade: r.jade + 20);
    final line = runDiff(r, b, what: 'prueba').single;
    expect(line, contains('prueba'));
    expect(line, contains('vida ${r.hp}/${r.maxHp} → ${r.hp - 5}'));
    expect(line, contains('jade ${r.jade} → ${r.jade + 20}'));
  });

  test('jugadas y efectos del combate en una línea', () {
    final engine = CombatEngine(data);
    final r = run.newRun(seed: 3);
    final c = engine.start(
      deck: r.deck,
      enemyId: 'bat',
      style: null,
      playerHp: r.hp,
      maxHp: r.maxHp,
      seed: 3,
    );
    final card = c.state.hand.first;
    expect(actionLine(PlayCard(card.uid), c.state), contains(card.cardId));
    expect(
      eventsLine(const [EnemyDamaged(6, 2), StanceCircle(1, 2), Victory()]),
      'daño 6, estructura 2; CÍRCULO +1 aliento +2 cartas; VICTORIA',
    );
    expect(turnSnapshot(c.state, engine).join('\n'), contains('bat: vida'));
  });

  test('el archivo archiva la subida anterior al empezar otra', () async {
    final tmp = await Directory.systemTemp.createTemp('runlog');
    final log = RunLogStorage(1, base: () async => tmp);
    await log.start(['primera']);
    await log.append(['a', 'b']);
    expect(await log.read(), 'primera\na\nb\n');
    await log.start(['segunda']);
    expect(await log.read(), 'segunda\n');
    final files = Directory('${tmp.path}/run_logs/slot1').listSync();
    expect(files, hasLength(2));
    await tmp.delete(recursive: true);
  });
}
