import 'dart:math' as math;

import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../model/event_def.dart';
import '../model/game_balance.dart';
import '../model/game_data.dart';
import '../model/talisman_def.dart';
import '../rng.dart';
import 'run_state.dart';

/// Reglas de la run: mapa, recompensas, santuario, eventos, talismanes y
/// fuente de meditación.
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
        NodeType.event => RunPhase.event,
      },
    );
    if (n.type == NodeType.event) return _rollEvent(entered);
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
    final healed = math.min(r.maxHp, hp + talismanSum(r, (e) => e.winHeal));
    final (options, rng) = _rollRewards(r.rng, r.style);
    final (form, rng2) = _rollForm(rng, r);
    // El élite deja elegir un talismán antes de la recompensa.
    final elite = data.enemy(enemyOf(r)).rank == EnemyRank.elite;
    final (talismans, rng3) = elite
        ? _rollTalismans(rng2, r, data.balance.talismanChoices)
        : (const <String>[], rng2);
    return r.copyWith(
      hp: healed,
      phase: talismans.isEmpty ? RunPhase.reward : RunPhase.talisman,
      rewardOptions: options,
      rewardForm: form,
      clearRewardForm: form == null,
      talismanOptions: talismans,
      rng: rng3,
    );
  }

  // ------------------------------------------------------------ talismanes

  /// Suma un efecto de todos los talismanes de la run.
  int talismanSum(RunState r, int Function(TalismanEffect e) of) =>
      r.talismans.fold(0, (a, id) => a + of(data.talisman(id).effect));

  /// Talismanes que todavía no se tienen ([rare]: null = cualquiera).
  List<String> missingTalismans(RunState r, {bool? rare}) => [
        for (final t in data.talismans.values)
          if (!r.talismans.contains(t.id) && (rare == null || t.rare == rare))
            t.id,
      ];

  (List<String>, Rng) _rollTalismans(Rng rng, RunState r, int n) {
    final (shuffled, next) = rng.shuffle(missingTalismans(r));
    return (shuffled.take(n).toList(), next);
  }

  /// Suma un talismán: los de Vida máxima también curan lo mismo.
  RunState addTalisman(RunState r, String id) {
    final extra = data.talisman(id).effect.maxHp;
    return r.copyWith(
      talismans: [...r.talismans, id],
      maxHp: r.maxHp + extra,
      hp: r.hp + extra,
    );
  }

  /// Elegir uno de los talismanes del élite; después viene la recompensa.
  RunState chooseTalisman(RunState r, String id) {
    if (r.phase != RunPhase.talisman) throw StateError('No hay talismán');
    if (!r.talismanOptions.contains(id)) {
      throw StateError('Talismán no ofrecido: $id');
    }
    return addTalisman(r, id)
        .copyWith(talismanOptions: const [], phase: RunPhase.reward);
  }

  // --------------------------------------------------------------- eventos

  RunState _rollEvent(RunState r) {
    final fresh = [
      for (final e in data.events)
        if (!r.seenEvents.contains(e.id)) e.id,
    ];
    final pool = fresh.isEmpty ? [for (final e in data.events) e.id] : fresh;
    final (shuffled, rng) = r.rng.shuffle(pool);
    return r.copyWith(eventId: shuffled.first, rng: rng);
  }

  /// Una opción con costo de Vida solo se puede pagar si no te deja en 0.
  bool canChoose(RunState r, EventOptionDef o) => r.hp > o.cost;

  /// Resuelve la opción elegida y vuelve al mapa.
  RunState resolveEvent(RunState r, String optionId) {
    if (r.phase != RunPhase.event) throw StateError('No hay evento');
    final event = data.event(r.eventId!);
    final option = event.option(optionId);
    if (!canChoose(r, option)) throw StateError('No alcanza la Vida');
    var rng = r.rng;
    bool? success;
    var outcome = option.outcome;
    if (option.chance != null) {
      final (roll, next) = rng.nextInt(100);
      rng = next;
      success = roll < option.chance!;
      if (!success) outcome = option.failure!;
    }
    var next = r.copyWith(rng: rng);
    final startHp = next.hp;
    if (outcome.maxHp > 0) {
      next = next.copyWith(
        maxHp: next.maxHp + outcome.maxHp,
        hp: next.hp + outcome.maxHp,
      );
    }
    if (outcome.hp > 0) next = next.copyWith(hp: math.max(1, next.hp - outcome.hp));
    if (outcome.heal > 0) {
      next = next.copyWith(hp: math.min(next.maxHp, next.hp + outcome.heal));
    }
    String? talisman, card, form, upgraded, lost;
    switch (outcome.gain) {
      case null:
        break;
      case EventGain.form:
        final forms = learnableForms(next);
        if (forms.isNotEmpty) {
          final (pick, rng2) = _pick(next.rng, forms);
          form = pick;
          next = next.copyWith(knownForms: [...next.knownForms, pick], rng: rng2);
        } else {
          (next, card) = _gainCard(next);
        }
      case EventGain.talisman || EventGain.rareTalisman:
        final rare = outcome.gain == EventGain.rareTalisman;
        var pool = missingTalismans(next, rare: rare);
        if (pool.isEmpty) pool = missingTalismans(next);
        if (pool.isNotEmpty) {
          final (pick, rng2) = _pick(next.rng, pool);
          talisman = pick;
          next = addTalisman(next.copyWith(rng: rng2), pick);
        }
      case EventGain.card:
        (next, card) = _gainCard(next);
      case EventGain.upgrade:
        final pool = [for (final c in next.deck) if (canUpgrade(c)) c.uid];
        if (pool.isNotEmpty) {
          final (uid, rng2) = _pick(next.rng, pool);
          upgraded = next.deck.firstWhere((c) => c.uid == uid).cardId;
          next = next.copyWith(
            deck: [
              for (final c in next.deck)
                c.uid == uid
                    ? CombatCard(
                        uid: c.uid,
                        cardId: c.cardId,
                        upgrades: c.upgrades + data.balance.fountainUpgrade,
                      )
                    : c,
            ],
            rng: rng2,
          );
        }
      case EventGain.loseStarter:
        final pool = [
          for (final c in next.deck)
            if (data.card(c.cardId).pool == 'starter') c.uid,
        ];
        if (pool.isNotEmpty) {
          final (uid, rng2) = _pick(next.rng, pool);
          lost = next.deck.firstWhere((c) => c.uid == uid).cardId;
          next = next.copyWith(
            deck: [for (final c in next.deck) if (c.uid != uid) c],
            rng: rng2,
          );
        }
    }
    return next.copyWith(
      phase: RunPhase.map,
      clearEventId: true,
      seenEvents: [...next.seenEvents, event.id],
      lastEvent: EventResult(
        eventId: event.id,
        optionId: optionId,
        success: success,
        hp: next.hp - startHp - (next.maxHp - r.maxHp),
        maxHp: next.maxHp - r.maxHp,
        talisman: talisman,
        card: card,
        form: form,
        upgraded: upgraded,
        lost: lost,
      ),
    );
  }

  (RunState, String) _gainCard(RunState r) {
    final pool = [for (final c in data.rewardPoolFor(r.style)) c.id];
    final (id, rng) = _pick(r.rng, pool);
    return (
      r.copyWith(
        deck: [...r.deck, CombatCard(uid: r.nextUid, cardId: id)],
        nextUid: r.nextUid + 1,
        rng: rng,
      ),
      id,
    );
  }

  (T, Rng) _pick<T>(Rng rng, List<T> items) {
    final (i, next) = rng.nextInt(items.length);
    return (items[i], next);
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
  int healOf(RunState r) =>
      data.balance.difficulty(r.difficulty).fountainHeal +
      talismanSum(r, (e) => e.fountainHeal);

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
