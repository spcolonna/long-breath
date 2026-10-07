import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../model/game_balance.dart';
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

  /// Tienda del mercader de pergaminos.
  merchant,

  /// Maestro errante.
  master,

  /// Se venció al jefe de una etapa intermedia: descanso antes de subir a
  /// la siguiente.
  stageClear,
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
    this.jade = 0,
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

  /// Cambio de jade (negativo = se pagó).
  final int jade;
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
        'jade': jade,
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
        jade: j['jade'] as int? ?? 0,
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
    this.pico = 0,
    this.knownForms = const [],
    this.rewardForm,
    this.talismans = const [],
    this.talismanOptions = const [],
    this.awakenings = const [],
    this.awakeningOptions = const [],
    this.locked = const [],
    this.eventId,
    this.seenEvents = const [],
    this.lastEvent,
    required this.map,
    this.jade = 0,
    this.jadeGained = 0,
    this.shopCards = const [],
    this.shopTalisman,
    this.shopRemoved = false,
    this.shopUpgraded = false,
    this.shopSale,
    this.shopTea = false,
    this.masterForms = const [],
    this.stage = 0,
  });

  /// Etapa de la subida (0 = la primera). El [map] es el de esta etapa.
  final int stage;

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

  /// Pico de la subida (0 = sin Picos). Se suma encima de la dificultad.
  final int pico;

  /// Formas aprendidas en la subida (se arranca sin ninguna).
  final List<String> knownForms;

  /// Forma que se ofrece junto a las cartas en la recompensa.
  final String? rewardForm;

  /// Talismanes conseguidos en la subida.
  final List<String> talismans;

  /// Talismanes que ofrece el élite (solo en la fase talisman).
  final List<String> talismanOptions;

  /// Despertares del camino aprendidos al superar etapas.
  final List<String> awakenings;

  /// Despertares que se ofrecen (solo en la fase stageClear).
  final List<String> awakeningOptions;

  /// Lo que la escuela todavía no abrió cuando empezó la subida (caminos,
  /// cartas, talismanes y formas del cultivo). Queda fijo toda la run.
  final List<String> locked;

  /// Evento del nodo actual (solo en la fase event).
  final String? eventId;

  /// Eventos que ya salieron en esta subida (no se repiten).
  final List<String> seenEvents;

  /// Resultado del último evento resuelto.
  final EventResult? lastEvent;

  /// Mapa de esta subida (generado con la semilla de la run).
  final List<MapNodeDef> map;

  /// Monedas de jade para el mercader.
  final int jade;

  /// Jade ganado en el último combate (para mostrarlo en la recompensa).
  final int jadeGained;

  /// Cartas y talismán en venta (solo en la fase merchant).
  final List<String> shopCards;
  final String? shopTalisman;

  /// Servicios del mercader ya usados en esta visita.
  final bool shopRemoved;
  final bool shopUpgraded;

  /// Carta en oferta (más barata) y si ya se tomó el té.
  final String? shopSale;
  final bool shopTea;

  /// Formas que ofrece el maestro errante (solo en la fase master).
  final List<String> masterForms;

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
    List<String>? awakenings,
    List<String>? awakeningOptions,
    String? eventId,
    bool clearEventId = false,
    List<String>? seenEvents,
    EventResult? lastEvent,
    int? jade,
    int? jadeGained,
    List<String>? shopCards,
    String? shopTalisman,
    bool clearShopTalisman = false,
    bool? shopRemoved,
    bool? shopUpgraded,
    String? shopSale,
    bool clearShopSale = false,
    bool? shopTea,
    List<String>? masterForms,
    List<MapNodeDef>? map,
    int? stage,
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
        pico: pico,
        knownForms: knownForms ?? this.knownForms,
        rewardForm: clearRewardForm ? null : rewardForm ?? this.rewardForm,
        talismans: talismans ?? this.talismans,
        talismanOptions: talismanOptions ?? this.talismanOptions,
        awakenings: awakenings ?? this.awakenings,
        awakeningOptions: awakeningOptions ?? this.awakeningOptions,
        locked: locked,
        eventId: clearEventId ? null : eventId ?? this.eventId,
        seenEvents: seenEvents ?? this.seenEvents,
        lastEvent: lastEvent ?? this.lastEvent,
        map: map ?? this.map,
        jade: jade ?? this.jade,
        jadeGained: jadeGained ?? this.jadeGained,
        shopCards: shopCards ?? this.shopCards,
        shopTalisman:
            clearShopTalisman ? null : shopTalisman ?? this.shopTalisman,
        shopRemoved: shopRemoved ?? this.shopRemoved,
        shopUpgraded: shopUpgraded ?? this.shopUpgraded,
        shopSale: clearShopSale ? null : shopSale ?? this.shopSale,
        shopTea: shopTea ?? this.shopTea,
        masterForms: masterForms ?? this.masterForms,
        stage: stage ?? this.stage,
      );

  /// Nodo del mapa por id.
  MapNodeDef node(String id) => map.firstWhere((n) => n.id == id);

  /// Nodos por los que se empieza (los que no tienen ninguno antes).
  List<String> get starts {
    final reached = {for (final n in map) ...n.next};
    return [for (final n in map) if (!reached.contains(n.id)) n.id];
  }

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
        'pico': pico,
        'knownForms': knownForms,
        'rewardForm': rewardForm,
        'talismans': talismans,
        'talismanOptions': talismanOptions,
        'awakenings': awakenings,
        'awakeningOptions': awakeningOptions,
        'locked': locked,
        'eventId': eventId,
        'seenEvents': seenEvents,
        'lastEvent': lastEvent?.toJson(),
        'map': [for (final n in map) n.toJson()],
        'jade': jade,
        'jadeGained': jadeGained,
        'shopCards': shopCards,
        'shopTalisman': shopTalisman,
        'shopRemoved': shopRemoved,
        'shopUpgraded': shopUpgraded,
        'shopSale': shopSale,
        'shopTea': shopTea,
        'masterForms': masterForms,
        'stage': stage,
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
        pico: j['pico'] as int? ?? 0,
        knownForms: ((j['knownForms'] as List?) ?? const []).cast<String>(),
        rewardForm: j['rewardForm'] as String?,
        talismans: ((j['talismans'] as List?) ?? const []).cast<String>(),
        talismanOptions:
            ((j['talismanOptions'] as List?) ?? const []).cast<String>(),
        awakenings: ((j['awakenings'] as List?) ?? const []).cast<String>(),
        awakeningOptions:
            ((j['awakeningOptions'] as List?) ?? const []).cast<String>(),
        locked: ((j['locked'] as List?) ?? const []).cast<String>(),
        eventId: j['eventId'] as String?,
        seenEvents: ((j['seenEvents'] as List?) ?? const []).cast<String>(),
        lastEvent: switch (j['lastEvent']) {
          final Map<String, dynamic> e => EventResult.fromJson(e),
          _ => null,
        },
        // Las subidas guardadas antes del mapa generado no tienen 'map' y se
        // descartan al cargar.
        map: [
          for (final n in j['map'] as List)
            MapNodeDef.fromJson(n as Map<String, dynamic>),
        ],
        jade: j['jade'] as int? ?? 0,
        jadeGained: j['jadeGained'] as int? ?? 0,
        shopCards: ((j['shopCards'] as List?) ?? const []).cast<String>(),
        shopTalisman: j['shopTalisman'] as String?,
        shopRemoved: j['shopRemoved'] as bool? ?? false,
        shopUpgraded: j['shopUpgraded'] as bool? ?? false,
        shopSale: j['shopSale'] as String?,
        shopTea: j['shopTea'] as bool? ?? false,
        masterForms: ((j['masterForms'] as List?) ?? const []).cast<String>(),
        stage: j['stage'] as int? ?? 0,
      );
}
