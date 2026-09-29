import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../rng.dart';

enum RunPhase { map, combat, reward, fountain, victory, defeat }

/// Estado inmutable de una run (serializable para el guardado local).
class RunState {
  const RunState({
    required this.age,
    required this.hp,
    required this.maxHp,
    required this.deck,
    required this.nextUid,
    required this.phase,
    required this.currentNode,
    required this.visited,
    required this.rewardOptions,
    required this.rng,
  });

  final Age age;
  final int hp;
  final int maxHp;
  final List<CombatCard> deck;
  final int nextUid;
  final RunPhase phase;

  /// Nodo actual (null antes de entrar al primero).
  final String? currentNode;
  final List<String> visited;
  final List<String> rewardOptions;
  final Rng rng;

  RunState copyWith({
    int? hp,
    List<CombatCard>? deck,
    int? nextUid,
    RunPhase? phase,
    String? currentNode,
    List<String>? visited,
    List<String>? rewardOptions,
    Rng? rng,
  }) =>
      RunState(
        age: age,
        hp: hp ?? this.hp,
        maxHp: maxHp,
        deck: deck ?? this.deck,
        nextUid: nextUid ?? this.nextUid,
        phase: phase ?? this.phase,
        currentNode: currentNode ?? this.currentNode,
        visited: visited ?? this.visited,
        rewardOptions: rewardOptions ?? this.rewardOptions,
        rng: rng ?? this.rng,
      );

  Map<String, dynamic> toJson() => {
        'age': age.name,
        'hp': hp,
        'maxHp': maxHp,
        'deck': [for (final c in deck) c.toJson()],
        'nextUid': nextUid,
        'phase': phase.name,
        'currentNode': currentNode,
        'visited': visited,
        'rewardOptions': rewardOptions,
        'rng': rng.state,
      };

  factory RunState.fromJson(Map<String, dynamic> j) => RunState(
        age: Age.parse(j['age'] as String),
        hp: j['hp'] as int,
        maxHp: j['maxHp'] as int,
        deck: [
          for (final c in j['deck'] as List)
            CombatCard.fromJson(c as Map<String, dynamic>),
        ],
        nextUid: j['nextUid'] as int,
        phase: RunPhase.values.byName(j['phase'] as String),
        currentNode: j['currentNode'] as String?,
        visited: (j['visited'] as List).cast<String>(),
        rewardOptions: (j['rewardOptions'] as List).cast<String>(),
        rng: Rng(j['rng'] as int),
      );
}
