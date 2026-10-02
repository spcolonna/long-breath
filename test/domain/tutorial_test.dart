import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/tutorial.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// Cada lección sigue el guion del maestro: estas pruebas juegan exactamente
/// lo que piden sus globos y verifican que pase lo que el texto promete.
void main() {
  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);

  late CombatResult r;
  void start(String lesson) {
    final s = lessonSetups[lesson]!;
    r = engine.start(
      deck: [for (final (i, id) in s.deck.indexed) CombatCard(uid: i, cardId: id)],
      enemyId: s.enemyId,
      style: null,
      playerHp: data.balance.playerHp,
      seed: 1,
      shuffle: false,
    );
  }

  List<CombatEvent> act(CombatAction a) {
    expect(engine.validate(r.state, a), isNull, reason: '$a');
    r = engine.reduce(r.state, a);
    return r.events;
  }

  List<CombatEvent> play(String id) =>
      act(PlayCard(r.state.hand.firstWhere((c) => c.cardId == id).uid));
  List<CombatEvent> endTurn() => act(const EndTurn());
  bool canPlay(String id) => r.state.hand
      .where((c) => c.cardId == id)
      .any((c) => engine.validate(r.state, PlayCard(c.uid)) == null);

  test('1. Tu primer golpe', () {
    start('strike');
    final hit = play('mabu_chongquan').whereType<EnemyDamaged>().single;
    expect((hit.damage, hit.structure), (7, 2));
    play('tui_zhang');
    play('mabu_chongquan');
    expect(r.state.player.breath, 0);
    expect(canPlay('tan_tui'), isFalse);
    final ev = endTurn();
    final got = ev.whereType<PlayerHit>().single;
    expect((got.damage, got.structure), (5, 1)); // Caballo: mitad de E
    expect(r.state.turn, 2);
    expect(r.state.player.breath, 3);
    expect(r.state.hand, hasLength(5));
    play('mabu_chongquan');
    play('mabu_chongquan');
    expect(r.state.phase, CombatPhase.won);
  });

  test('2. Defenderse', () {
    start('defend');
    play('shang_jia');
    expect(r.state.player.guard, 9);
    play('mabu_chongquan');
    var ev = endTurn();
    expect(ev.whereType<Deflected>(), isNotEmpty);
    expect(ev.whereType<EnemyBroken>(), isEmpty);
    expect(r.state.player.hp, data.balance.playerHp);
    expect(r.state.player.guard, 0);
    expect(r.state.player.breath, 4, reason: '+1 por el desvío');
    play('an_zhang');
    ev = endTurn();
    final hit = ev.whereType<PlayerHit>().single;
    expect(hit.damage, 3, reason: 'la Guardia baja absorbe la mitad de 6');
    play('an_zhang');
    play('mabu_chongquan');
    play('mabu_chongquan');
    expect(r.state.phase, CombatPhase.won);
  });

  test('3. Posturas', () {
    start('stances');
    // Pega desde Caballo (+2) y recién después queda en Arco.
    final hit = play('gongbu_chongquan').whereType<EnemyDamaged>().single;
    expect(hit.damage, 8);
    expect(r.state.player.stance, Stance.gongbu);
    // El puño de Caballo aprovecha el Arco (+3) y te deja en Caballo.
    final fist = play('mabu_chongquan').whereType<EnemyDamaged>().single;
    expect(fist.damage, 8);
    expect(r.state.player.stance, Stance.mabu);
    act(const Dingbu(Stance.xubu));
    expect(r.state.player.stance, Stance.xubu);
    final kick = play('tan_tui').whereType<EnemyDamaged>().single;
    expect(kick.damage, 7);
    expect(r.state.player.breath, 0);
  });

  test('4. Estructura y Desequilibrio', () {
    start('structure');
    play('tui_zhang');
    final ev = play('tui_zhang');
    expect(ev.whereType<EnemyBroken>(), isNotEmpty);
    final hit = play('mabu_chongquan').whereType<EnemyDamaged>().single;
    expect(hit.damage, 14);
    final turn = endTurn();
    expect(turn.whereType<EnemyActionSkipped>(), isNotEmpty);
    expect(r.state.enemy.staggered, isTrue);
    expect(engine.intentView(r.state).intent.kind.name, 'charge');
    play('mabu_chongquan');
    expect(r.state.phase, CombatPhase.won);
  });

  test('5. Formas', () {
    start('forms');
    play('gongbu_chongquan');
    play('tan_tui');
    expect(r.state.formProgress['xiao_hong_quan'], 2);
    expect(canPlay('mabu_jiada'), isFalse);
    endTurn();
    expect(r.state.formProgress['xiao_hong_quan'], 2);
    play('mabu_jiada');
    // Queda 1 de Aliento: Respirar se podría, pero no alcanzaría para el paso.
    expect(r.state.player.breath, 1);
    endTurn();
    expect(r.state.hand.any((c) => c.cardId == 'xubu_liangzhang'), isFalse);
    act(const Breathe());
    expect(r.state.player.breath, 2);
    final ev = play('xubu_liangzhang');
    expect(ev.whereType<FormCompleted>(), isNotEmpty);
    expect(r.state.phase, isNot(CombatPhase.won));
  });
}
