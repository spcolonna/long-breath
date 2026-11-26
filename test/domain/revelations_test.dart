import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/content_text.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/revelations.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final content =
      jsonDecode(File('assets/l10n/content/es.json').readAsStringSync())
          as Map<String, dynamic>;

  test(
    'las revelaciones son pergaminos que existen y se llevan a la subida',
    () {
      for (final id in revelationLore) {
        expect(loreOrder, contains(id), reason: id);
      }
      final known = knownRevelations({'prologue', 'dream_7', 'dream_2'});
      expect(known, {'dream_7', 'dream_2'});
      expect(isRevealed('wind_lady', known), isTrue);
      expect(isRevealed('sleeping_dragon', known), isFalse);
      expect(revealedOf(known), {'wind_lady'});
    },
  );

  test('el rival que ya conocés arranca con menos Estructura', () {
    final engine = CombatEngine(data);
    CombatState start(Set<String> revealed) => engine
        .start(
          deck: [
            for (var i = 0; i < 12; i++)
              CombatCard(uid: i, cardId: 'gongbu_chongquan'),
          ],
          enemyId: 'wind_lady',
          style: Style.tiger,
          playerHp: 50,
          seed: 1,
          shuffle: false,
          revealed: revealed,
          revealedPct: revealedStructurePct,
        )
        .state;
    final base = start({}).enemy;
    final known = start({'wind_lady'}).enemy;
    expect(known.maxStructure, base.maxStructure);
    expect(
      known.structure,
      (base.structure * revealedStructurePct / 100).round(),
    );
    expect(start({'dragon'}).enemy.structure, base.structure);
  });

  test('cada rival revelado tiene sus cuatro líneas nuevas', () {
    final text = ContentText(content);
    for (final id in revealedFoes.keys) {
      for (final f in ['intro', 'reply', 'defeat', 'triumph']) {
        final plain = text.enemyLine(id, f);
        final rev = text.enemyLine(id, f, revealed: true);
        expect(rev, isNotNull, reason: '$id.$f');
        expect(rev, isNot(plain), reason: '$id.$f');
      }
    }
    // Sin línea revelada, la de siempre.
    expect(
      text.enemyLine('monk', 'intro', revealed: true),
      text.enemyLine('monk', 'intro'),
    );
  });

  test('las opciones de evento con pergamino salen solo si se leyó', () {
    final run = RunEngine(data);
    final events = {for (final e in data.events) e.id: e};
    final r = run.newRun(seed: 3);
    final known = run.newRun(seed: 3, known: {'dream_2', 'dream_9'});
    for (final (event, option) in [
      ('snowbound', 'breathe'),
      ('beam_names', 'finish'),
    ]) {
      final e = events[event]!;
      final o = e.options.firstWhere((o) => o.id == option);
      expect(run.eventOptions(r, e), isNot(contains(o)));
      expect(run.eventOptions(known, e).first, o);
      expect(run.canChoose(known, o), isTrue);
      final c = content['events'][event] as Map<String, dynamic>;
      expect(c.containsKey(option), isTrue);
      expect(c.containsKey('${option}Result'), isTrue);
    }
    // Se guardan con la subida.
    expect(RunState.fromJson(known.toJson()).known, {'dream_2', 'dream_9'});
  });
}
