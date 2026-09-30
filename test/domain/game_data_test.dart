import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
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

  test('posturas, formas y enemigos', () {
    expect(data.stances.keys, containsAll(Stance.values));
    expect(data.transition.cost, 1);
    expect(data.forms.map((f) => f.id), ['xiao_hong_quan', 'da_hong_quan']);
    for (final f in data.forms) {
      for (final step in f.steps) {
        expect(data.cards.containsKey(step), isTrue, reason: step);
      }
    }
    expect(data.enemies.length, 6);
    expect(data.enemy('dragon').phases.length, 2);
  });

  test('mapa de la run: 7 nodos con enemigos válidos', () {
    final nodes = data.balance.runNodes;
    expect(nodes.length, 7);
    final ids = nodes.map((n) => n.id).toSet();
    for (final n in nodes) {
      expect(ids.containsAll(n.next), isTrue);
      if (n.enemy != null) expect(data.enemies.containsKey(n.enemy), isTrue);
    }
    expect(data.balance.styles[Style.crane]!.retain, 3);
  });
}
