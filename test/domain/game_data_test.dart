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
    expect(data.enemies.length, 16); // 10 de la run + 6 muñecos de práctica
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
    expect(floors[6].types.keys, [NodeType.fountain]);
    expect(floors[7].enemies, ['monk', 'lion', 'fan']);
    expect(floors.last.enemies, ['dragon']);
    expect(data.balance.jadeElite, greaterThan(data.balance.jadeCommon));
  });

  test('talismanes y eventos', () {
    expect(data.talismans, hasLength(10));
    expect(data.talismans.values.where((t) => t.rare), hasLength(3));
    expect(data.talismans.values.map((t) => t.hanzi).toSet(), hasLength(10),
        reason: 'cada uno se reconoce por su carácter');
    expect(data.events, hasLength(6));
    for (final e in data.events) {
      expect(e.options, hasLength(2), reason: e.id);
    }
  });
}
