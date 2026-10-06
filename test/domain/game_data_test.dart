import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();

  test('32 cartas: 12 iniciales, 8 generales y 4 por cada camino', () {
    expect(data.cards.length, 28); // definiciones únicas
    expect(data.starterDeck.length, 12);
    expect(data.cards.values.where((c) => c.pool == 'reward').length, 8);
    for (final s in Style.values) {
      expect(data.cards.values.where((c) => c.pool == s.name).length, 4,
          reason: s.name);
    }
    expect(data.rewardPool.length, 20);
  });

  test('las cartas de cada camino solo le salen a ese camino', () {
    for (final s in Style.values) {
      final pool = data.rewardPoolFor(s);
      expect(pool.length, 12, reason: s.name);
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
    // 10 de la etapa 1, 7 del monasterio, 7 de la cumbre y 6 muñecos.
    expect(data.enemies.length, 30);
    expect(data.enemy('dragon').phases.length, 3);
  });

  test('pisos del mapa: enemigos válidos, santuario, fuente, élite y jefe', () {
    final floors = data.balance.floors;
    expect(floors, hasLength(9));
    for (final f in floors) {
      for (final e in f.enemies) {
        expect(data.enemies.containsKey(e), isTrue, reason: e);
      }
      expect(f.minWidth, lessThanOrEqualTo(f.maxWidth));
    }
    expect(floors[2].types.keys, [NodeType.shrine]);
    // Élite, después la fuente y arriba el jefe.
    expect(floors[6].enemies, ['monk', 'lion', 'fan']);
    expect(floors[7].types.keys, [NodeType.fountain]);
    expect(floors.last.enemies, ['dragon']);
    expect(data.balance.jadeElite, 0, reason: 'la élite paga con un talismán');
    expect(floors[1].types.keys, contains(NodeType.merchant));
  });

  test('tres etapas de 9 pisos, cada una con élite, fuente y jefe', () {
    final stages = data.balance.stages;
    expect(stages.map((s) => s.id), ['qianyunshan', 'xuankongsi', 'wolongding']);
    expect(data.balance.totalFloors, 27);
    for (final st in stages) {
      expect(st.floors, hasLength(9), reason: st.id);
      expect(st.floors[7].types.keys, [NodeType.fountain], reason: st.id);
      for (final e in st.floors[6].enemies) {
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

  test('talismanes y eventos', () {
    expect(data.talismans, hasLength(10));
    expect(data.talismans.values.where((t) => t.rare), hasLength(3));
    expect(data.talismans.values.map((t) => t.hanzi).toSet(), hasLength(10),
        reason: 'cada uno se reconoce por su carácter');
    expect(data.events, hasLength(8));
    for (final e in data.events) {
      expect(e.options.length, inInclusiveRange(2, 3), reason: e.id);
    }
  });
}
