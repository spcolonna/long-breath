import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();

  test('24 cartas: 12 iniciales, 8 generales y 4 del Tigre', () {
    expect(data.cards.length, 20); // definiciones únicas
    expect(data.starterDeck.length, 12);
    expect(data.cards.values.where((c) => c.pool == 'reward').length, 8);
    expect(data.cards.values.where((c) => c.pool == 'tiger').length, 4);
    expect(data.rewardPool.length, 12);
  });

  test('las cartas del Tigre solo le salen al Tigre', () {
    bool hasTiger(Style? s) => data.rewardPoolFor(s).any((c) => c.pool == 'tiger');
    expect(data.rewardPoolFor(Style.tiger).length, 12);
    expect(data.rewardPoolFor(Style.snake).length, 8);
    expect(hasTiger(null), isFalse, reason: 'el novicio todavía no eligió');
    expect(hasTiger(Style.crane), isFalse);
  });

  test('posturas, formas y enemigos', () {
    expect(data.stances.keys, containsAll(Stance.values));
    expect(data.transition.cost, 1);
    expect(data.forms.map((f) => f.id), [
      'xiao_hong_quan', 'wu_bu_quan', 'she_quan', 'lian_huan_quan',
      'men_hu_tui', 'hu_quan', 'da_hong_quan',
    ]);
    expect(data.forms.firstWhere((f) => f.id == 'hu_quan').pool, Style.tiger);
    expect(data.forms.firstWhere((f) => f.id == 'she_quan').pool, Style.snake);
    for (final f in data.forms) {
      for (final step in f.steps) {
        expect(data.cards.containsKey(step), isTrue, reason: step);
      }
    }
    expect(data.enemies.length, 12); // 6 de la run + 6 muñecos de práctica
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
    expect(floors[7].enemies, ['monk']);
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
