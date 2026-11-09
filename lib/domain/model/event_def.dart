import 'enums.dart';

/// Lo que se gana en un evento, además de la Vida.
enum EventGain {
  /// Una forma que todavía no se conoce (si no queda ninguna, una carta).
  form,

  /// Un talismán común que no se tiene.
  talisman,

  /// Un talismán raro que no se tiene.
  rareTalisman,

  /// Una carta de recompensa al azar.
  card,

  /// Mejora una carta al azar de las que se pueden mejorar.
  upgrade,

  /// Se pierde una carta inicial al azar (achica el mazo).
  loseStarter,

  /// Elegir una de tres cartas del camino (sin camino, de recompensa).
  pathCards,

  /// Elegir qué carta del mazo mejorar.
  pickUpgrade,

  /// El talismán del camino (si ya se tiene, uno raro).
  pathTalisman,

  /// Templa el arma (sin arma o al máximo, mejora una carta al azar).
  temper;

  static EventGain? parse(String? s) =>
      s == null ? null : EventGain.values.byName(s);
}

/// Resultado de una opción: Vida y, a veces, algo más.
class EventOutcome {
  const EventOutcome({
    this.hp = 0,
    this.heal = 0,
    this.maxHp = 0,
    this.jade = 0,
    this.gain,
    this.mark,
    this.duel,
  });

  /// Vida que se pierde (nunca deja al jugador en menos de 1).
  final int hp;

  /// Vida que se recupera, hasta el máximo.
  final int heal;

  /// Vida máxima extra (también cura lo mismo).
  final int maxHp;

  /// Jade que se gana.
  final int jade;
  final EventGain? gain;

  /// Deja una marca: el evento que la espera sale en una etapa más arriba.
  final String? mark;

  /// Termina en pelea contra este rival (la emboscada que sale mal).
  final String? duel;

  factory EventOutcome.fromJson(Map<String, dynamic> j) => EventOutcome(
    hp: j['hp'] as int? ?? 0,
    heal: j['heal'] as int? ?? 0,
    maxHp: j['maxHp'] as int? ?? 0,
    jade: j['jade'] as int? ?? 0,
    gain: EventGain.parse(j['gain'] as String?),
    mark: j['mark'] as String?,
    duel: j['duel'] as String?,
  );
}

/// Qué pide una opción para aparecer.
enum EventNeedKind { talisman, weapon, form }

/// Requisito de una opción: tener uno de [ids] (vacío = cualquiera).
class EventNeed {
  const EventNeed(this.kind, [this.ids = const []]);

  final EventNeedKind kind;
  final List<String> ids;

  factory EventNeed.fromJson(Map<String, dynamic> j) {
    final kind = EventNeedKind.values.byName(j.keys.single);
    return EventNeed(kind, (j[kind.name] as List).cast<String>());
  }
}

/// Una opción del evento. Si tiene [chance], sale [success] o [failure].
class EventOptionDef {
  const EventOptionDef({
    required this.id,
    required this.outcome,
    this.chance,
    this.failure,
    this.price = 0,
    this.duel,
    this.needs,
  });

  final String id;

  /// Solo aparece si se cumple (un talismán, el arma o una forma).
  final EventNeed? needs;

  /// Rival de un duelo: elegirla lleva a pelear contra él, y ganarle deja
  /// elegir talismán (el del camino entre ellos).
  final String? duel;

  /// Jade que se paga al elegirla, salga bien o mal.
  final int price;

  /// Lo que pasa (o lo que pasa si sale bien, cuando hay riesgo).
  final EventOutcome outcome;

  /// Probabilidad de éxito en %, o null si no hay riesgo.
  final int? chance;
  final EventOutcome? failure;

  /// Vida que cuesta elegirla de entrada (sin riesgo).
  int get cost => chance == null ? outcome.hp : 0;

  factory EventOptionDef.fromJson(Map<String, dynamic> j) {
    final chance = j['chance'] as int?;
    return EventOptionDef(
      id: j['id'] as String,
      chance: chance,
      price: j['price'] as int? ?? 0,
      duel: j['duel'] as String?,
      needs: j['needs'] == null
          ? null
          : EventNeed.fromJson(j['needs'] as Map<String, dynamic>),
      outcome: EventOutcome.fromJson(
        (chance == null ? j : j['success']) as Map<String, dynamic>,
      ),
      failure: chance == null
          ? null
          : EventOutcome.fromJson(j['failure'] as Map<String, dynamic>),
    );
  }
}

/// Evento del mapa: una escena con una decisión.
class EventDef {
  const EventDef({
    required this.id,
    required this.hanzi,
    required this.options,
    this.stages,
    this.path,
    this.after,
    this.ambush = false,
  });

  final String id;
  final String hanzi;
  final List<EventOptionDef> options;

  /// Etapas donde puede salir (ids); `null` = en cualquiera.
  final List<String>? stages;

  /// Camino al que pertenece: solo le sale a quien lo sigue.
  final Style? path;

  /// Segunda parte: solo sale con esta marca, dejada en una etapa anterior.
  final String? after;

  /// Emboscada: su pelea paga como un combate común (sin talismán).
  final bool ambush;

  bool fitsStage(String stageId) => stages == null || stages!.contains(stageId);

  EventOptionDef option(String id) => options.firstWhere((o) => o.id == id);

  factory EventDef.fromJson(Map<String, dynamic> j) => EventDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    options: [
      for (final o in j['options'] as List)
        EventOptionDef.fromJson(o as Map<String, dynamic>),
    ],
    stages: (j['stages'] as List?)?.cast<String>(),
    path: j['path'] == null ? null : Style.parse(j['path'] as String),
    after: j['after'] as String?,
    ambush: j['ambush'] as bool? ?? false,
  );
}
