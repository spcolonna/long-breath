import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/tutorial.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);

  test('el guion del tutorial desvía, desequilibra y gana en el turno 2', () {
    var r = engine.start(
      deck: [
        for (final (i, id) in tutorialDeck.indexed) CombatCard(uid: i, cardId: id),
      ],
      enemyId: tutorialEnemy,
      style: null,
      playerHp: data.balance.playerHp,
      seed: 1,
      shuffle: false,
    );
    int uid(String id) => r.state.hand.firstWhere((c) => c.cardId == id).uid;
    void play(String id) {
      final a = PlayCard(uid(id));
      expect(engine.validate(r.state, a), isNull, reason: id);
      r = engine.reduce(r.state, a);
    }

    expect(r.state.hand.map((c) => c.cardId).take(3),
        ['gongbu_chongquan', 'xubu_liangzhang', 'tan_tui']);
    play('gongbu_chongquan');
    play('xubu_liangzhang');
    play('tan_tui'); // en postura Vacía cuesta 0
    expect(r.state.formProgress.values.any((p) => p == 2), isTrue);
    r = engine.reduce(r.state, const EndTurn());
    expect(r.events.whereType<Deflected>(), isNotEmpty);
    expect(r.events.whereType<EnemyBroken>(), isNotEmpty);
    expect(r.state.enemy.staggered, isTrue);
    expect(r.state.player.hp, data.balance.playerHp);

    // Turno 2: con el muñeco desequilibrado, dos golpes alcanzan.
    play('gongbu_chongquan');
    play('tan_tui');
    expect(r.state.phase, CombatPhase.won);
  });
}
