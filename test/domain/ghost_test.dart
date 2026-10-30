import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/feats.dart';
import 'package:long_breath/domain/run/ghost.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

final _map = [
  MapNodeDef(
    id: 'n1',
    type: NodeType.combat,
    enemy: 'disciple',
    next: const ['n2'],
  ),
  MapNodeDef(
    id: 'n2',
    type: NodeType.combat,
    enemy: 'disciple',
    next: const [],
  ),
];

Ascent _ascent(int n, {bool fell = true, Style? style, String? keepsake}) =>
    Ascent(
      n: n,
      fell: fell,
      floor: 3 + n,
      floors: 33,
      difficulty: Difficulty.normal,
      style: style,
      keepsake: keepsake,
      keepsakeUp: keepsake == null ? 0 : 2,
    );

void main() {
  final data = loadGameDataFromDir('assets/data', const {
    'combatRewards': null,
  });
  final run = RunEngine(data);

  test('el Discípulo Perdido lleva al último caído del registro', () {
    expect(ghostFrom(const []), isNull);
    expect(ghostFrom([_ascent(1, fell: false)]), isNull);
    final g = ghostFrom([
      _ascent(1, style: Style.snake),
      _ascent(2, style: Style.tiger, keepsake: 'hu_zhao'),
      _ascent(3, fell: false),
    ])!;
    expect(g.n, 2);
    expect(g.floor, 5);
    expect(g.style, Style.tiger);
    expect(g.card, 'hu_zhao');
    expect(g.upgrades, 2);
  });

  test('la carta que se deja: la del camino más mejorada; iniciales no', () {
    const deck = [
      CombatCard(uid: 0, cardId: 'ge_dang', upgrades: 3),
      CombatCard(uid: 1, cardId: 'deng_tui', upgrades: 2),
      CombatCard(uid: 2, cardId: 'hu_pu'),
      CombatCard(uid: 3, cardId: 'hu_zhao', upgrades: 1),
    ];
    expect(keepsakeOf(data, deck, Style.tiger)!.cardId, 'hu_zhao');
    expect(keepsakeOf(data, deck, null)!.cardId, 'deng_tui');
    expect(keepsakeOf(data, deck.take(1).toList(), Style.tiger), isNull);
  });

  test('vencerlo suelta su carta una sola vez y queda en el guardado', () {
    var r = run
        .newRun(
          seed: 4,
          ghost: const Ghost(n: 2, floor: 5, card: 'hu_zhao', upgrades: 2),
        )
        .copyWith(map: _map);
    final before = r.deck.length;
    r = run.enter(r, 'n1');
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(r.deck.length, before + 1);
    expect(r.deck.last.cardId, 'hu_zhao');
    expect(r.deck.last.upgrades, 2);
    expect(r.ghost!.claimedAt, 'n1');
    expect(r.ghost!.dropped, 'hu_zhao');
    final back = RunState.fromJson(
      jsonDecode(jsonEncode(r.toJson())) as Map<String, dynamic>,
    );
    expect(back.ghost!.dropped, 'hu_zhao');
    r = run.chooseReward(r, null);
    r = run.enter(r, 'n2');
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(r.deck.length, before + 1, reason: 'una sola vez por subida');
  });

  test('un registro viejo sin carta suelta una de su camino', () {
    var r = run
        .newRun(seed: 9, ghost: const Ghost(n: 1, floor: 2, style: Style.crane))
        .copyWith(map: _map);
    r = run.enter(r, 'n1');
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(data.cards[r.ghost!.dropped]!.pool, 'crane');
  });

  test('sin caídos no hay nada que soltar', () {
    var r = run.newRun(seed: 4).copyWith(map: _map);
    final before = r.deck.length;
    r = run.enter(r, 'n1');
    r = run.finishCombat(r, won: true, hp: r.hp);
    expect(r.deck.length, before);
  });

  test('el próximo hito salta los que la partida no puede cumplir', () {
    final all = {for (final h in hitos) h.id};
    expect(nextHito({}, Difficulty.normal)!.id, 'first_climb');
    final left = {...all}..removeAll(['win_hard', 'win_shifu', 'forms_10']);
    expect(nextHito(left, Difficulty.easy)!.id, 'forms_10');
    expect(nextHito(all, Difficulty.normal), isNull);
    expect(
      hitoBest('forms_10', [
        Ascent.fromJson({
          ..._ascent(1).toJson(),
          'feats': {Feat.forms: 6},
        }),
      ]),
      (6, 10),
    );
  });
}
