import 'dart:math' as math;

import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../rng.dart';
import 'run_state.dart';

/// Reglas de la run: mapa, recompensas, santuario y fuente de meditación.
class RunEngine {
  RunEngine(this.data);

  final GameData data;

  MapNodeDef node(String id) =>
      data.balance.runNodes.firstWhere((n) => n.id == id);

  /// La run empieza como novicio; el camino se elige en el santuario.
  RunState newRun({required int seed, Difficulty difficulty = Difficulty.normal}) {
    final starter = data.starterDeck;
    final hp = data.balance.difficulty(difficulty).playerHp;
    return RunState(
      difficulty: difficulty,
      style: null,
      hp: hp,
      maxHp: hp,
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

  /// Un combate a medias (se cerró la app o el jugador salió) se retoma
  /// desde el mapa, como si todavía no se hubiera entrado a ese nodo.
  RunState retreat(RunState r) {
    if (r.phase != RunPhase.combat) return r;
    final visited = r.visited.sublist(0, r.visited.length - 1);
    return r.copyWith(
      phase: RunPhase.map,
      visited: visited,
      currentNode: visited.isEmpty ? null : visited.last,
      clearCurrentNode: visited.isEmpty,
    );
  }

  RunState enter(RunState r, String nodeId) {
    if (!available(r).contains(nodeId)) {
      throw StateError('Nodo no disponible: $nodeId');
    }
    final n = node(nodeId);
    final entered = r.copyWith(
      currentNode: nodeId,
      visited: [...r.visited, nodeId],
      phase: switch (n.type) {
        NodeType.combat => RunPhase.combat,
        NodeType.fountain => RunPhase.fountain,
        NodeType.shrine => RunPhase.shrine,
      },
    );
    if (n.type != NodeType.shrine) return entered;
    final (shuffled, rng) = entered.rng.shuffle(Style.values);
    return entered.copyWith(
      pathOptions: shuffled.take(data.balance.pathChoices).toList(),
      rng: rng,
    );
  }

  /// Tomar uno de los caminos que ofrece el santuario.
  RunState choosePath(RunState r, Style style) {
    if (r.phase != RunPhase.shrine) throw StateError('No estás en el santuario');
    if (!r.pathOptions.contains(style)) {
      throw StateError('Camino no ofrecido: ${style.name}');
    }
    return r.copyWith(style: style, pathOptions: const [], phase: RunPhase.map);
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
    final (options, rng) = _rollRewards(r.rng, r.style);
    final (form, rng2) = _rollForm(rng, r);
    return r.copyWith(
      hp: hp,
      phase: RunPhase.reward,
      rewardOptions: options,
      rewardForm: form,
      clearRewardForm: form == null,
      rng: rng2,
    );
  }

  /// Formas que todavía se pueden aprender en este camino.
  List<String> learnableForms(RunState r) => [
        for (final f in data.forms)
          if (!r.knownForms.contains(f.id) &&
              (f.pool == null || f.pool == r.style))
            f.id,
      ];

  (String?, Rng) _rollForm(Rng rng, RunState r) {
    final pool = learnableForms(r);
    if (pool.isEmpty) return (null, rng);
    final (shuffled, next) = rng.shuffle(pool);
    return (shuffled.first, next);
  }

  (List<String>, Rng) _rollRewards(Rng rng, Style? style) {
    final pool = [for (final c in data.rewardPoolFor(style)) c.id];
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
      clearRewardForm: true,
      phase: RunPhase.map,
    );
  }

  /// Aprender la forma ofrecida en vez de sumar una carta.
  RunState chooseForm(RunState r, String formId) {
    if (r.phase != RunPhase.reward) throw StateError('No hay recompensa');
    if (r.rewardForm != formId) {
      throw StateError('Forma no ofrecida: $formId');
    }
    return r.copyWith(
      knownForms: [...r.knownForms, formId],
      rewardOptions: const [],
      clearRewardForm: true,
      phase: RunPhase.map,
    );
  }

  /// Vida que cura la fuente en la dificultad de la run.
  int healOf(RunState r) => data.balance.difficulty(r.difficulty).fountainHeal;

  RunState fountainHeal(RunState r) {
    _checkFountain(r);
    return r.copyWith(
      hp: math.min(r.maxHp, r.hp + healOf(r)),
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
