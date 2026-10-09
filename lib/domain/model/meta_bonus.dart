import 'cultivation_def.dart';

/// Lo que la escuela le da a cada subida: los dones de los reinos del cultivo
/// y los puntos abiertos del árbol de meridianos. Cada campo en 0 no hace
/// nada. Queda fijo al empezar la subida (se guarda en la run).
class MetaBonus {
  const MetaBonus({
    this.maxHp = 0,
    this.fountainHeal = 0,
    this.winHeal = 0,
    this.structure = 0,
    this.startJade = 0,
    this.upgradedStarters = 0,
    this.startTalisman = 0,
    this.merchantDiscountPct = 0,
    this.rewardChoices = 0,
    this.talismanChoices = 0,
    this.rerolls = 0,
    this.lotusPct = 0,
    this.firstTurnBreath = 0,
    this.breathes = 0,
  });

  static const none = MetaBonus();

  /// Vida máxima extra.
  final int maxHp;

  /// Vida extra que cura la fuente.
  final int fountainHeal;

  /// Vida que se recupera al ganar un combate.
  final int winHeal;

  /// Estructura máxima extra en cada combate.
  final int structure;

  /// Jade con el que se empieza.
  final int startJade;

  /// Cartas iniciales que empiezan mejoradas.
  final int upgradedStarters;

  /// Se elige un talismán (de 3) al empezar.
  final int startTalisman;

  /// Descuento (%) en todo lo del mercader.
  final int merchantDiscountPct;

  /// Cartas extra en cada recompensa de cartas.
  final int rewardChoices;

  /// Talismanes extra que ofrece el élite.
  final int talismanChoices;

  /// Veces por subida que se pueden volver a tirar las cartas.
  final int rerolls;

  /// Semillas de loto extra (%).
  final int lotusPct;

  /// Aliento extra en el turno 1 de cada combate.
  final int firstTurnBreath;

  /// Respirar extra por combate.
  final int breathes;

  bool get isNone => toJson().isEmpty;

  MetaBonus operator +(MetaBonus o) => MetaBonus(
        maxHp: maxHp + o.maxHp,
        fountainHeal: fountainHeal + o.fountainHeal,
        winHeal: winHeal + o.winHeal,
        structure: structure + o.structure,
        startJade: startJade + o.startJade,
        upgradedStarters: upgradedStarters + o.upgradedStarters,
        startTalisman: startTalisman + o.startTalisman,
        merchantDiscountPct: merchantDiscountPct + o.merchantDiscountPct,
        rewardChoices: rewardChoices + o.rewardChoices,
        talismanChoices: talismanChoices + o.talismanChoices,
        rerolls: rerolls + o.rerolls,
        lotusPct: lotusPct + o.lotusPct,
        firstTurnBreath: firstTurnBreath + o.firstTurnBreath,
        breathes: breathes + o.breathes,
      );

  /// Solo los campos que hacen algo (el árbol los muestra así).
  Map<String, int> toJson() => {
        for (final e in {
          'maxHp': maxHp,
          'fountainHeal': fountainHeal,
          'winHeal': winHeal,
          'structure': structure,
          'startJade': startJade,
          'upgradedStarters': upgradedStarters,
          'startTalisman': startTalisman,
          'merchantDiscountPct': merchantDiscountPct,
          'rewardChoices': rewardChoices,
          'talismanChoices': talismanChoices,
          'rerolls': rerolls,
          'lotusPct': lotusPct,
          'firstTurnBreath': firstTurnBreath,
          'breathes': breathes,
        }.entries)
          if (e.value != 0) e.key: e.value,
      };

  factory MetaBonus.fromJson(Map<String, dynamic> j) => MetaBonus(
        maxHp: j['maxHp'] as int? ?? 0,
        fountainHeal: j['fountainHeal'] as int? ?? 0,
        winHeal: j['winHeal'] as int? ?? 0,
        structure: j['structure'] as int? ?? 0,
        startJade: j['startJade'] as int? ?? 0,
        upgradedStarters: j['upgradedStarters'] as int? ?? 0,
        startTalisman: j['startTalisman'] as int? ?? 0,
        merchantDiscountPct: j['merchantDiscountPct'] as int? ?? 0,
        rewardChoices: j['rewardChoices'] as int? ?? 0,
        talismanChoices: j['talismanChoices'] as int? ?? 0,
        rerolls: j['rerolls'] as int? ?? 0,
        lotusPct: j['lotusPct'] as int? ?? 0,
        firstTurnBreath: j['firstTurnBreath'] as int? ?? 0,
        breathes: j['breathes'] as int? ?? 0,
      );
}

/// Las tres ramas del árbol de meridianos.
enum MeridianBranch {
  /// 身 Cuerpo: Vida, curación y Estructura.
  body,

  /// 神 Espíritu: jade, loto, mercader y aliento.
  spirit,

  /// 技 Técnica: cartas, talismanes y premios.
  technique;

  static MeridianBranch parse(String s) => values.byName(s);
}

/// Un punto (穴 xué) del árbol: se abre con semillas de loto, cuando la
/// escuela llegó al reino [realm] y está abierto el anterior de su rama.
class MeridianNode {
  const MeridianNode({
    required this.id,
    required this.branch,
    required this.realm,
    required this.cost,
    required this.effect,
    this.requires,
  });

  final String id;
  final MeridianBranch branch;

  /// Índice del reino que hace falta (0 = desde el principio).
  final int realm;
  final int cost;
  final MetaBonus effect;
  final String? requires;

  factory MeridianNode.fromJson(Map<String, dynamic> j) => MeridianNode(
        id: j['id'] as String,
        branch: MeridianBranch.parse(j['branch'] as String),
        realm: j['realm'] as int? ?? 0,
        cost: j['cost'] as int,
        effect: MetaBonus.fromJson(j['effect'] as Map<String, dynamic>),
        requires: j['requires'] as String?,
      );
}

/// Semillas de loto que deja una subida (antes del % del árbol).
class LotusDef {
  const LotusDef({
    this.perCombat = 0,
    this.elite = 0,
    this.boss = 0,
    this.victory = 0,
    this.reward = const [],
  });

  final int perCombat;
  final int elite;
  final int boss;
  final int victory;

  /// Lo que da el premio de loto en cada etapa.
  final List<int> reward;

  int rewardAt(int stage) =>
      reward.isEmpty ? 0 : reward[stage.clamp(0, reward.length - 1)];

  factory LotusDef.fromJson(Map<String, dynamic> j) => LotusDef(
        perCombat: j['perCombat'] as int? ?? 0,
        elite: j['elite'] as int? ?? 0,
        boss: j['boss'] as int? ?? 0,
        victory: j['victory'] as int? ?? 0,
        reward: ((j['reward'] as List?) ?? const []).cast<int>(),
      );
}

/// El árbol de meridianos (经络 jīngluò) y los dones de los reinos.
class MeridianDef {
  const MeridianDef({
    this.lotus = const LotusDef(),
    this.realmPerks = const {},
    this.nodes = const [],
  });

  static const none = MeridianDef();

  final LotusDef lotus;

  /// Don que da cada reino al alcanzarlo (por id de reino).
  final Map<String, MetaBonus> realmPerks;
  final List<MeridianNode> nodes;

  MeridianNode node(String id) => nodes.firstWhere(
        (n) => n.id == id,
        orElse: () => throw ArgumentError('Punto desconocido: $id'),
      );

  /// Se puede abrir [n] con lo que ya está abierto y el reino [realm].
  bool canOpen(MeridianNode n, int realm, Iterable<String> owned) =>
      !owned.contains(n.id) &&
      realm >= n.realm &&
      (n.requires == null || owned.contains(n.requires));

  /// Dones de los reinos hasta [realm] más los puntos abiertos.
  MetaBonus bonusOf(CultivationDef c, int realm, Iterable<String> owned) {
    var b = MetaBonus.none;
    for (final r in c.realms.take(realm + 1)) {
      b = b + (realmPerks[r.id] ?? MetaBonus.none);
    }
    for (final n in nodes) {
      if (owned.contains(n.id)) b = b + n.effect;
    }
    return b;
  }

  factory MeridianDef.fromJson(Map<String, dynamic> j) => MeridianDef(
        lotus: LotusDef.fromJson((j['lotus'] as Map<String, dynamic>?) ?? {}),
        realmPerks: {
          for (final e
              in ((j['realmPerks'] as Map<String, dynamic>?) ?? {}).entries)
            e.key: MetaBonus.fromJson(e.value as Map<String, dynamic>),
        },
        nodes: [
          for (final n in (j['nodes'] as List?) ?? const [])
            MeridianNode.fromJson(n as Map<String, dynamic>),
        ],
      );
}
