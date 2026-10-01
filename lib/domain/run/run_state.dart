import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../rng.dart';

enum RunPhase { map, combat, reward, fountain, shrine, victory, defeat }

/// Estado inmutable de una run (serializable para el guardado local).
class RunState {
  const RunState({
    required this.style,
    required this.hp,
    required this.maxHp,
    required this.deck,
    required this.nextUid,
    required this.phase,
    required this.currentNode,
    required this.visited,
    required this.rewardOptions,
    this.pathOptions = const [],
    required this.rng,
    this.difficulty = Difficulty.normal,
  });

  /// Camino animal; null mientras sea novicio (antes del santuario).
  final Style? style;
  final int hp;
  final int maxHp;
  final List<CombatCard> deck;
  final int nextUid;
  final RunPhase phase;

  /// Nodo actual (null antes de entrar al primero).
  final String? currentNode;
  final List<String> visited;
  final List<String> rewardOptions;

  /// Caminos que ofrece el santuario (solo en la fase shrine).
  final List<Style> pathOptions;
  final Rng rng;
  final Difficulty difficulty;

  RunState copyWith({
    Style? style,
    int? hp,
    List<CombatCard>? deck,
    int? nextUid,
    RunPhase? phase,
    String? currentNode,
    bool clearCurrentNode = false,
    List<String>? visited,
    List<String>? rewardOptions,
    List<Style>? pathOptions,
    Rng? rng,
  }) =>
      RunState(
        style: style ?? this.style,
        hp: hp ?? this.hp,
        maxHp: maxHp,
        deck: deck ?? this.deck,
        nextUid: nextUid ?? this.nextUid,
        phase: phase ?? this.phase,
        currentNode: clearCurrentNode ? null : currentNode ?? this.currentNode,
        visited: visited ?? this.visited,
        rewardOptions: rewardOptions ?? this.rewardOptions,
        pathOptions: pathOptions ?? this.pathOptions,
        rng: rng ?? this.rng,
        difficulty: difficulty,
      );

  Map<String, dynamic> toJson() => {
        'style': style?.name,
        'hp': hp,
        'maxHp': maxHp,
        'deck': [for (final c in deck) c.toJson()],
        'nextUid': nextUid,
        'phase': phase.name,
        'currentNode': currentNode,
        'visited': visited,
        'rewardOptions': rewardOptions,
        'pathOptions': [for (final s in pathOptions) s.name],
        'rng': rng.state,
        'difficulty': difficulty.name,
      };

  factory RunState.fromJson(Map<String, dynamic> j) => RunState(
        style: switch (j['style'] ?? j['age']) {
          final String s => Style.parse(s),
          _ => null,
        },
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
        pathOptions: [
          for (final s in (j['pathOptions'] as List?) ?? const []) Style.parse(s as String),
        ],
        rng: Rng(j['rng'] as int),
        difficulty: Difficulty.parse(j['difficulty'] as String?),
      );
}
