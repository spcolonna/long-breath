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
  loseStarter;

  static EventGain? parse(String? s) =>
      s == null ? null : EventGain.values.byName(s);
}

/// Resultado de una opción: Vida y, a veces, algo más.
class EventOutcome {
  const EventOutcome({this.hp = 0, this.heal = 0, this.maxHp = 0, this.gain});

  /// Vida que se pierde (nunca deja al jugador en menos de 1).
  final int hp;

  /// Vida que se recupera, hasta el máximo.
  final int heal;

  /// Vida máxima extra (también cura lo mismo).
  final int maxHp;
  final EventGain? gain;

  factory EventOutcome.fromJson(Map<String, dynamic> j) => EventOutcome(
    hp: j['hp'] as int? ?? 0,
    heal: j['heal'] as int? ?? 0,
    maxHp: j['maxHp'] as int? ?? 0,
    gain: EventGain.parse(j['gain'] as String?),
  );
}

/// Una opción del evento. Si tiene [chance], sale [success] o [failure].
class EventOptionDef {
  const EventOptionDef({
    required this.id,
    required this.outcome,
    this.chance,
    this.failure,
  });

  final String id;

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
  });

  final String id;
  final String hanzi;
  final List<EventOptionDef> options;

  EventOptionDef option(String id) => options.firstWhere((o) => o.id == id);

  factory EventDef.fromJson(Map<String, dynamic> j) => EventDef(
    id: j['id'] as String,
    hanzi: j['hanzi'] as String,
    options: [
      for (final o in j['options'] as List)
        EventOptionDef.fromJson(o as Map<String, dynamic>),
    ],
  );
}
