import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();

  test('38 cartas: 12 iniciales, 8 generales y 6 por cada camino', () {
    expect(data.cards.length, 34); // definiciones únicas
    expect(data.starterDeck.length, 12);
    expect(data.cards.values.where((c) => c.pool == 'reward').length, 8);
    for (final s in Style.values) {
      expect(data.cards.values.where((c) => c.pool == s.name).length, 6,
          reason: s.name);
    }
    expect(data.rewardPool.length, 26);
  });

  test('las cartas de cada camino solo le salen a ese camino', () {
    for (final s in Style.values) {
      final pool = data.rewardPoolFor(s);
      expect(pool.length, 14, reason: s.name);
      expect(
        pool.where((c) => Style.values.any((o) => o.name == c.pool)),
        everyElement(predicate((c) => (c as dynamic).pool == s.name)),
      );
    }
    expect(data.rewardPoolFor(null).length, 8,
        reason: 'el novicio todavía no eligió');
  });

  test('posturas, formas y enemigos', () {
    expect(data.stances.keys, containsAll(Stance.values));
    expect(data.transition.cost, 1);
    expect(data.forms.map((f) => f.id), [
      'xiao_hong_quan', 'wu_bu_quan', 'she_quan', 'he_quan',
      'lian_huan_quan', 'men_hu_tui', 'hu_quan', 'da_hong_quan',
    ]);
    expect(data.forms.firstWhere((f) => f.id == 'he_quan').pool, Style.crane);
    expect(data.forms.firstWhere((f) => f.id == 'hu_quan').pool, Style.tiger);
    expect(data.forms.firstWhere((f) => f.id == 'she_quan').pool, Style.snake);
    for (final f in data.forms) {
      for (final step in f.steps) {
        expect(data.cards.containsKey(step), isTrue, reason: step);
      }
    }
    // 10 de la etapa 1, 8 del monasterio, 8 de la cumbre y 6 muñecos.
    expect(data.enemies.length, 34);
    expect(data.enemy('bell_keeper').rank, EnemyRank.elite);
    expect(data.enemy('dragon_dream').scales, 3);
    expect(data.enemy('dragon').phases.length, 3);
  });

  test('pisos del mapa: enemigos válidos, santuario, fuente, élite y jefe', () {
    final floors = data.balance.floors;
    expect(floors, hasLength(11));
    for (final f in floors) {
      for (final e in f.enemies) {
        expect(data.enemies.containsKey(e), isTrue, reason: e);
      }
      expect(f.minWidth, lessThanOrEqualTo(f.maxWidth));
    }
    expect(floors[2].types.keys, [NodeType.shrine]);
    // Élite, después la fuente y arriba el jefe.
    expect(floors[8].enemies, ['monk', 'lion', 'fan']);
    expect(floors[9].types.keys, [NodeType.fountain]);
    expect(floors.last.enemies, ['dragon']);
    expect(data.balance.jadeElite, 0, reason: 'la élite paga con un talismán');
    // El mercader aparece en el camino, no en el mapa.
    for (final st in data.balance.stages) {
      for (final f in st.floors) {
        expect(f.types.keys, isNot(contains(NodeType.merchant)));
      }
    }
    expect(data.balance.merchantEvery, greaterThan(0));
    expect(floors[3].packs.keys, contains(2));
  });

  test('tres etapas de 11 pisos, cada una con élite, fuente y jefe', () {
    final stages = data.balance.stages;
    expect(stages.map((s) => s.id), ['qianyunshan', 'xuankongsi', 'wolongding']);
    expect(data.balance.totalFloors, 33);
    for (final st in stages) {
      expect(st.floors, hasLength(11), reason: st.id);
      expect(st.floors[9].types.keys, [NodeType.fountain], reason: st.id);
      for (final e in st.floors[8].enemies) {
        expect(data.enemy(e).rank, EnemyRank.elite, reason: e);
      }
      expect(data.enemy(st.floors.last.enemies.single).rank, EnemyRank.boss);
      for (final f in st.floors) {
        for (final e in f.enemies) {
          expect(data.enemies.containsKey(e), isTrue, reason: e);
        }
      }
    }
    // Solo la primera etapa tiene santuario: el camino se elige una vez.
    expect(
      stages.skip(1).expand((s) => s.floors).any(
            (f) => f.types.containsKey(NodeType.shrine),
          ),
      isFalse,
    );
  });

  test('cada camino tiene 4 despertares con nombre', () {
    final content = jsonDecode(
      File('assets/l10n/content/es.json').readAsStringSync(),
    ) as Map<String, dynamic>;
    final names = content['awakenings'] as Map<String, dynamic>;
    final ids = <String>{};
    for (final s in Style.values) {
      final aw = data.balance.styles[s]!.awakenings;
      expect(aw, hasLength(4), reason: s.name);
      for (final a in aw) {
        expect(ids.add(a.id), isTrue, reason: 'repetido: ${a.id}');
        expect(names.containsKey(a.id), isTrue, reason: a.id);
        expect(data.balance.awakening(a.id), same(a));
      }
    }
    expect(data.balance.awakeningChoices, 3);
  });

  test('talismanes y eventos', () {
    expect(data.talismans, hasLength(10));
    expect(data.talismans.values.where((t) => t.rare), hasLength(3));
    expect(data.talismans.values.map((t) => t.hanzi).toSet(), hasLength(10),
        reason: 'cada uno se reconoce por su carácter');
    expect(data.events, hasLength(16));
    for (final e in data.events) {
      expect(e.options.length, inInclusiveRange(2, 3), reason: e.id);
    }
  });
}
