import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../rng.dart';

enum RunPhase {
  map,
  combat,

  /// Elegir un talismán (después de vencer al élite, antes de la recompensa).
  talisman,
  reward,
  fountain,
  shrine,

  /// Escena con una decisión.
  event,
  victory,
  defeat,
}

/// Lo que pasó en el último evento (para mostrarlo y para los tests).
class EventResult {
  const EventResult({
    required this.eventId,
    required this.optionId,
    this.success,
    this.hp = 0,
    this.maxHp = 0,
    this.talisman,
    this.card,
    this.form,
    this.upgraded,
    this.lost,
  });

  final String eventId;
  final String optionId;

  /// Si la opción tenía riesgo: salió bien o mal. Null si no había riesgo.
  final bool? success;

  /// Cambio de Vida (negativo = se perdió).
  final int hp;
  final int maxHp;
  final String? talisman;
  final String? card;
  final String? form;

  /// Carta mejorada y carta perdida (ids).
  final String? upgraded;
  final String? lost;

  Map<String, dynamic> toJson() => {
        'eventId': eventId,
        'optionId': optionId,
        'success': success,
        'hp': hp,
        'maxHp': maxHp,
        'talisman': talisman,
        'card': card,
        'form': form,
        'upgraded': upgraded,
        'lost': lost,
      };

  factory EventResult.fromJson(Map<String, dynamic> j) => EventResult(
        eventId: j['eventId'] as String,
        optionId: j['optionId'] as String,
        success: j['success'] as bool?,
        hp: j['hp'] as int? ?? 0,
        maxHp: j['maxHp'] as int? ?? 0,
        talisman: j['talisman'] as String?,
        card: j['card'] as String?,
        form: j['form'] as String?,
        upgraded: j['upgraded'] as String?,
        lost: j['lost'] as String?,
      );
}

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
    this.knownForms = const [],
    this.rewardForm,
    this.talismans = const [],
    this.talismanOptions = const [],
    this.eventId,
    this.seenEvents = const [],
    this.lastEvent,
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

  /// Formas aprendidas en la subida (se arranca sin ninguna).
  final List<String> knownForms;

  /// Forma que se ofrece junto a las cartas en la recompensa.
  final String? rewardForm;

  /// Talismanes conseguidos en la subida.
  final List<String> talismans;

  /// Talismanes que ofrece el élite (solo en la fase talisman).
  final List<String> talismanOptions;

  /// Evento del nodo actual (solo en la fase event).
  final String? eventId;

  /// Eventos que ya salieron en esta subida (no se repiten).
  final List<String> seenEvents;

  /// Resultado del último evento resuelto.
  final EventResult? lastEvent;

  RunState copyWith({
    Style? style,
    int? hp,
    int? maxHp,
    List<CombatCard>? deck,
    int? nextUid,
    RunPhase? phase,
    String? currentNode,
    bool clearCurrentNode = false,
    List<String>? visited,
    List<String>? rewardOptions,
    List<Style>? pathOptions,
    Rng? rng,
    List<String>? knownForms,
    String? rewardForm,
    bool clearRewardForm = false,
    List<String>? talismans,
    List<String>? talismanOptions,
    String? eventId,
    bool clearEventId = false,
    List<String>? seenEvents,
    EventResult? lastEvent,
  }) =>
      RunState(
        style: style ?? this.style,
        hp: hp ?? this.hp,
        maxHp: maxHp ?? this.maxHp,
        deck: deck ?? this.deck,
        nextUid: nextUid ?? this.nextUid,
        phase: phase ?? this.phase,
        currentNode: clearCurrentNode ? null : currentNode ?? this.currentNode,
        visited: visited ?? this.visited,
        rewardOptions: rewardOptions ?? this.rewardOptions,
        pathOptions: pathOptions ?? this.pathOptions,
        rng: rng ?? this.rng,
        difficulty: difficulty,
        knownForms: knownForms ?? this.knownForms,
        rewardForm: clearRewardForm ? null : rewardForm ?? this.rewardForm,
        talismans: talismans ?? this.talismans,
        talismanOptions: talismanOptions ?? this.talismanOptions,
        eventId: clearEventId ? null : eventId ?? this.eventId,
        seenEvents: seenEvents ?? this.seenEvents,
        lastEvent: lastEvent ?? this.lastEvent,
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
        'knownForms': knownForms,
        'rewardForm': rewardForm,
        'talismans': talismans,
        'talismanOptions': talismanOptions,
        'eventId': eventId,
        'seenEvents': seenEvents,
        'lastEvent': lastEvent?.toJson(),
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
        knownForms: ((j['knownForms'] as List?) ?? const []).cast<String>(),
        rewardForm: j['rewardForm'] as String?,
        talismans: ((j['talismans'] as List?) ?? const []).cast<String>(),
        talismanOptions:
            ((j['talismanOptions'] as List?) ?? const []).cast<String>(),
        eventId: j['eventId'] as String?,
        seenEvents: ((j['seenEvents'] as List?) ?? const []).cast<String>(),
        lastEvent: switch (j['lastEvent']) {
          final Map<String, dynamic> e => EventResult.fromJson(e),
          _ => null,
        },
      );
}
