/// Variedad de las peleas comunes: la condición de la sala y el reto
/// opcional que se ven en la puerta antes de entrar.
library;

/// Condición de una sala de pelea común.
enum RoomRule {
  /// Niebla: la intención del rival no se ve en los turnos impares.
  fog,

  /// Viento de altura: las patadas cuestan 1 de Aliento menos.
  wind,

  /// Puente angosto: los rivales vienen de a uno, nunca a la vez.
  bridge,

  /// Campana: cada tantos turnos repica y golpea a todos (a vos y a ellos).
  bell;

  static RoomRule? parse(Object? s) =>
      s is String ? RoomRule.values.asNameMap()[s] : null;
}

/// Reto opcional de una pelea común: cumplirlo da jade extra.
enum Challenge {
  /// Ganar sin perder Vida.
  flawless,

  /// Rematar al último rival mientras está Desequilibrado.
  breakFinish,

  /// Ganar en pocos turnos (`RoomsDef.swiftTurns`).
  swift,

  /// No terminar dos turnos seguidos en la misma postura.
  noRepeat;

  static Challenge? parse(Object? s) =>
      s is String ? Challenge.values.asNameMap()[s] : null;
}

/// Lo que la memoria de la escuela deja en una puerta del mapa.
enum NodeMark {
  /// Revancha: el rival que venció al último caído, en la fila donde cayó.
  revenge,

  /// Atajo de Shuang: ella ya pasó por ahí y los rivales arrancan cansados.
  shuang;

  static NodeMark? parse(Object? s) =>
      s is String ? NodeMark.values.asNameMap()[s] : null;
}

/// Lo que cuesta el tramo hasta una puerta. El costo garantiza el nivel de
/// lo que hay del otro lado: pagar nunca lleva a algo peor que el sendero
/// gratis de la misma fila.
enum PathToll {
  /// Sendero llano: gratis; pelea común, evento o mercader.
  free,

  /// Puente de peaje: jade; una pelea común que paga con talismán.
  jade,

  /// Cuesta empinada: Aliento del primer turno; un élite que da talismán
  /// y una llave.
  breath,

  /// Senda oculta: una llave; el cofre sellado.
  key;

  static PathToll parse(Object? s) =>
      (s is String ? PathToll.values.asNameMap()[s] : null) ?? PathToll.free;
}

/// La pista del mundo que se ve desde el tramo: deja intuir qué hay sin
/// decirlo. Huellas y voces pueden ser pelea; voces y humo, un evento;
/// humo y campanilla, el mercader.
enum DoorSign {
  tracks,
  voices,
  smoke,
  bells,
  banner,
  seal;

  static DoorSign? parse(Object? s) =>
      s is String ? DoorSign.values.asNameMap()[s] : null;
}

/// Los tramos con costo (`run.tolls`).
class TollsDef {
  const TollsDef({
    this.fromDepth = 1,
    this.jadeChance = const [],
    this.jade = const [],
    this.breath = 1,
    this.secretChance = 0,
    this.secretMax = 0,
    this.eliteKeys = 1,
    this.revengeKeys = 1,
  });

  static const none = TollsDef();

  /// Primera fila (0 = la primera) con puente de peaje o senda oculta.
  final int fromDepth;

  /// % por fila de que una pelea común quede tras un puente de peaje.
  final List<int> jadeChance;

  /// Jade del peaje, por etapa (siempre menos que un talismán en la tienda).
  final List<int> jade;

  /// Aliento de menos en el primer turno tras la cuesta empinada.
  final int breath;

  /// % por fila de que aparezca la senda oculta (si hay llave).
  final int secretChance;

  /// Tope de sendas ocultas por etapa.
  final int secretMax;

  /// Llaves por vencer al élite de la cuesta y por la revancha.
  final int eliteKeys;
  final int revengeKeys;

  int jadeChanceAt(int stage) => RoomsDef._at(jadeChance, stage);
  int jadeAt(int stage) => RoomsDef._at(jade, stage);

  factory TollsDef.fromJson(Map<String, dynamic>? j) => j == null
      ? none
      : TollsDef(
          fromDepth: j['fromDepth'] as int? ?? 1,
          jadeChance: RoomsDef._ints(j['jadeChance']),
          jade: RoomsDef._ints(j['jade']),
          breath: j['breath'] as int? ?? 1,
          secretChance: j['secretChance'] as int? ?? 0,
          secretMax: j['secretMax'] as int? ?? 0,
          eliteKeys: j['eliteKeys'] as int? ?? 1,
          revengeKeys: j['revengeKeys'] as int? ?? 1,
        );
}

/// La condición y el reto de la pelea en curso, y cómo va el reto.
class Trial {
  const Trial({
    this.room,
    this.challenge,
    this.startHp = 0,
    this.failed = false,
    this.met = false,
    this.swiftTurns = 2,
    this.bellEvery = 3,
    this.bellDamage = 0,
    this.windDiscount = 1,
    this.fogOpening = false,
    this.thinAir = 0,
  });

  static const none = Trial();

  final RoomRule? room;
  final Challenge? challenge;

  /// Vida con la que se entró (para «sin perder Vida»).
  final int startHp;

  /// El reto ya no se puede cumplir.
  final bool failed;

  /// El reto se cumplió (se decide al ganar).
  final bool met;

  final int swiftTurns;
  final int bellEvery;
  final int bellDamage;
  final int windDiscount;

  /// Niebla de los Picos: la intención del primer turno no se ve.
  final bool fogOpening;

  /// Aire fino de los Picos: Aliento de menos por turno hasta que respirás
  /// (0 = no hay, o ya respiraste en esta pelea).
  final int thinAir;

  /// Trae algo que mostrar en la ficha del combate.
  bool get shown => room != null || challenge != null || thinAir > 0;

  /// El reto sigue en juego.
  bool get pending => challenge != null && !failed && !met;

  Trial copyWith({bool? failed, bool? met, int? thinAir}) => Trial(
    room: room,
    challenge: challenge,
    startHp: startHp,
    failed: failed ?? this.failed,
    met: met ?? this.met,
    swiftTurns: swiftTurns,
    bellEvery: bellEvery,
    bellDamage: bellDamage,
    windDiscount: windDiscount,
    fogOpening: fogOpening,
    thinAir: thinAir ?? this.thinAir,
  );
}

/// Reglas de las salas y los retos (`run.rooms` en game_balance.json). Las
/// listas van por etapa.
class RoomsDef {
  const RoomsDef({
    this.fromDepth = 1,
    this.ruleChance = const [],
    this.challengeChance = const [],
    this.challengeJade = const [],
    this.bellEvery = 3,
    this.bellDamage = const [],
    this.windDiscount = 1,
    this.swiftTurns = 3,
    this.revengeJade = const [],
    this.shuangChance = 0,
    this.shuangMax = 0,
    this.shuangWeaken = 0,
  });

  static const none = RoomsDef();

  /// Primera fila (0 = la primera) en que puede haber condición o reto.
  final int fromDepth;

  /// % de que una sala común tenga condición, por etapa.
  final List<int> ruleChance;

  /// % de que una sala común tenga reto, por etapa.
  final List<int> challengeChance;

  /// Jade extra por cumplir el reto, por etapa.
  final List<int> challengeJade;
  final int bellEvery;
  final List<int> bellDamage;
  final int windDiscount;
  final int swiftTurns;

  /// Jade extra por vencer la revancha, por etapa.
  final List<int> revengeJade;

  /// % por fila (y por capítulo de Shuang leído) de que una pelea común
  /// traiga su atajo.
  final int shuangChance;

  /// Tope de atajos de Shuang por etapa.
  final int shuangMax;

  /// % de Vida menos con que arrancan los rivales de un atajo de Shuang.
  final int shuangWeaken;

  static int _at(List<int> l, int stage) =>
      l.isEmpty ? 0 : l[stage.clamp(0, l.length - 1)];

  int ruleChanceAt(int stage) => _at(ruleChance, stage);
  int challengeChanceAt(int stage) => _at(challengeChance, stage);
  int challengeJadeAt(int stage) => _at(challengeJade, stage);
  int bellDamageAt(int stage) => _at(bellDamage, stage);
  int revengeJadeAt(int stage) => _at(revengeJade, stage);

  static List<int> _ints(Object? v) =>
      [for (final x in (v as List?) ?? const []) x as int];

  factory RoomsDef.fromJson(Map<String, dynamic>? j) => j == null
      ? none
      : RoomsDef(
          fromDepth: j['fromDepth'] as int? ?? 1,
          ruleChance: _ints(j['ruleChance']),
          challengeChance: _ints(j['challengeChance']),
          challengeJade: _ints(j['challengeJade']),
          bellEvery: j['bellEvery'] as int? ?? 3,
          bellDamage: _ints(j['bellDamage']),
          windDiscount: j['windDiscount'] as int? ?? 1,
          swiftTurns: j['swiftTurns'] as int? ?? 3,
          revengeJade: _ints(j['revengeJade']),
          shuangChance: j['shuangChance'] as int? ?? 0,
          shuangMax: j['shuangMax'] as int? ?? 0,
          shuangWeaken: j['shuangWeaken'] as int? ?? 0,
        );
}
