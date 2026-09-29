import 'dart:math' as math;

import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../rng.dart';
import 'run_state.dart';

/// Reglas de la run: mapa, recompensas y fuente de meditación.
class RunEngine {
  RunEngine(this.data);

  final GameData data;

  MapNodeDef node(String id) =>
      data.balance.runNodes.firstWhere((n) => n.id == id);

  RunState newRun({required Age age, required int seed}) {
    final starter = data.starterDeck;
    return RunState(
      age: age,
      hp: data.balance.playerHp,
      maxHp: data.balance.playerHp,
      deck: [
        for (var i = 0; i < starter.length; i++)
          CombatCard(uid: i, cardId: starter[i]),
      ],
      nextUid: starter.length,
      phase: RunPhase.map,
      currentNode: null,
      visited: const [],
      rewardOptions: const [],
      rng: Rng.seeded(seed),
    );
  }

  /// Nodos a los que se puede avanzar desde la posición actual.
  List<String> available(RunState r) {
    if (r.phase != RunPhase.map) return const [];
    final current = r.currentNode;
    return current == null ? [data.balance.runStart] : node(current).next;
  }

  RunState enter(RunState r, String nodeId) {
    if (!available(r).contains(nodeId)) {
      throw StateError('Nodo no disponible: $nodeId');
    }
    final n = node(nodeId);
    return r.copyWith(
      currentNode: nodeId,
      visited: [...r.visited, nodeId],
      phase: n.type == NodeType.combat ? RunPhase.combat : RunPhase.fountain,
    );
  }

  /// Semilla del combate del nodo actual (derivada de la run, reproducible).
  (int, RunState) combatSeed(RunState r) {
    final (seed, rng) = r.rng.nextInt(0x7FFFFFFF);
    return (seed, r.copyWith(rng: rng));
  }

  String enemyOf(RunState r) => node(r.currentNode!).enemy!;

  RunState finishCombat(RunState r, {required bool won, required int hp}) {
    if (!won) return r.copyWith(hp: 0, phase: RunPhase.defeat);
    if (node(r.currentNode!).next.isEmpty) {
      return r.copyWith(hp: hp, phase: RunPhase.victory);
    }
    final (options, rng) = _rollRewards(r.rng);
    return r.copyWith(
      hp: hp,
      phase: RunPhase.reward,
      rewardOptions: options,
      rng: rng,
    );
  }

  (List<String>, Rng) _rollRewards(Rng rng) {
    final pool = [for (final c in data.rewardPool) c.id];
    final (shuffled, next) = rng.shuffle(pool);
    return (shuffled.take(data.balance.rewardChoices).toList(), next);
  }

  /// Elegir una recompensa o saltear (cardId null).
  RunState chooseReward(RunState r, String? cardId) {
    if (r.phase != RunPhase.reward) throw StateError('No hay recompensa');
    if (cardId != null && !r.rewardOptions.contains(cardId)) {
      throw StateError('Recompensa inválida: $cardId');
    }
    return r.copyWith(
      deck: cardId == null
          ? r.deck
          : [...r.deck, CombatCard(uid: r.nextUid, cardId: cardId)],
      nextUid: cardId == null ? r.nextUid : r.nextUid + 1,
      rewardOptions: const [],
      phase: RunPhase.map,
    );
  }

  RunState fountainHeal(RunState r) {
    _checkFountain(r);
    return r.copyWith(
      hp: math.min(r.maxHp, r.hp + data.balance.fountainHeal),
      phase: RunPhase.map,
    );
  }

  RunState fountainRemove(RunState r, int uid) {
    _checkFountain(r);
    return r.copyWith(
      deck: [for (final c in r.deck) if (c.uid != uid) c],
      phase: RunPhase.map,
    );
  }

  /// Una carta se puede mejorar si tiene daño o Guardia.
  bool canUpgrade(CombatCard c) {
    final def = data.card(c.cardId);
    return def.damage > 0 || def.guard > 0;
  }

  RunState fountainUpgrade(RunState r, int uid) {
    _checkFountain(r);
    return r.copyWith(
      deck: [
        for (final c in r.deck)
          if (c.uid == uid)
            CombatCard(
              uid: c.uid,
              cardId: c.cardId,
              upgrades: c.upgrades + data.balance.fountainUpgrade,
            )
          else
            c,
      ],
      phase: RunPhase.map,
    );
  }

  void _checkFountain(RunState r) {
    if (r.phase != RunPhase.fountain) throw StateError('No estás en la fuente');
  }
}
