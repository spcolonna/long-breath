import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/meta_bonus.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);

  CombatState start(MetaBonus meta) => engine
      .start(
        deck: [
          for (var i = 0; i < 12; i++)
            CombatCard(uid: i, cardId: 'gongbu_chongquan'),
        ],
        enemyId: 'salamander',
        style: Style.tiger,
        playerHp: 50,
        seed: 1,
        shuffle: false,
        meta: meta,
      )
      .state;

  test('los puntos de combate del árbol llegan a la pelea', () {
    final base = start(MetaBonus.none);
    final plus = start(
      const MetaBonus(
        handSize: 1,
        turnBreath: 1,
        retain: 1,
        firstStrike: 2,
        chain: 1,
        enemyHp: 3,
        enemyStructure: 2,
      ),
    );
    expect(plus.handSize, base.handSize + 1);
    expect(plus.hand.length, base.hand.length + 1);
    expect(plus.breathPerTurn, base.breathPerTurn + 1);
    expect(plus.player.breath, base.player.breath + 1);
    expect(plus.retainMax, base.retainMax + 1);
    expect(plus.firstStrike, base.firstStrike + 2);
    expect(plus.chain, base.chain + 1);
    expect(plus.enemies.first.hp, base.enemies.first.hp - 3);
    expect(plus.enemies.first.structure, base.enemies.first.structure - 2);
  });

  test('el árbol completo cuesta ~6000 de loto y suma lo de cada fila', () {
    final m = data.balance.meridians;
    final c = data.balance.cultivation;
    // Eligiendo siempre el primero de cada elección.
    final owned = [
      for (final b in MeridianBranch.values)
        for (final row in m.rows(b)) row.first.id,
    ];
    expect(owned, hasLength(m.maxOwned));
    for (final id in owned) {
      expect(m.canOpen(m.node(id), 5, owned.where((x) => x != id)), isTrue,
          reason: id);
    }
    final all = m.bonusOf(c, c.realms.length - 1, owned);
    expect(all.breathes, greaterThan(0));
    expect(all.turnBreath, greaterThan(0));
    expect(all.startTalisman, greaterThan(0));
  });
}
