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
    this.weaponLevel = 0,
    this.teaHeal = 0,
    this.stageHealPct = 0,
    this.handSize = 0,
    this.turnBreath = 0,
    this.retain = 0,
    this.firstStrike = 0,
    this.chain = 0,
    this.enemyHp = 0,
    this.enemyStructure = 0,
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

  /// Niveles extra del arma al conseguirla (hasta su máximo).
  final int weaponLevel;

  /// Vida extra que cura el té del mercader.
  final int teaHeal;

  /// Cura extra (% de lo que falta) al pasar de etapa.
  final int stageHealPct;

  /// Cartas extra que se roban cada turno.
  final int handSize;

  /// Aliento extra en cada turno.
  final int turnBreath;

  /// Cartas extra que se pueden guardar al terminar el turno.
  final int retain;

  /// Daño extra del primer ataque de cada turno.
  final int firstStrike;

  /// Daño extra de cada ataque por cada ataque anterior del turno.
  final int chain;

  /// Vida que le falta a cada rival al empezar.
  final int enemyHp;

  /// Estructura que le falta a cada rival al empezar.
  final int enemyStructure;

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
        weaponLevel: weaponLevel + o.weaponLevel,
        teaHeal: teaHeal + o.teaHeal,
        stageHealPct: stageHealPct + o.stageHealPct,
        handSize: handSize + o.handSize,
        turnBreath: turnBreath + o.turnBreath,
        retain: retain + o.retain,
        firstStrike: firstStrike + o.firstStrike,
        chain: chain + o.chain,
        enemyHp: enemyHp + o.enemyHp,
        enemyStructure: enemyStructure + o.enemyStructure,
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
          'weaponLevel': weaponLevel,
          'teaHeal': teaHeal,
          'stageHealPct': stageHealPct,
          'handSize': handSize,
          'turnBreath': turnBreath,
          'retain': retain,
          'firstStrike': firstStrike,
          'chain': chain,
          'enemyHp': enemyHp,
          'enemyStructure': enemyStructure,
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
        weaponLevel: j['weaponLevel'] as int? ?? 0,
        teaHeal: j['teaHeal'] as int? ?? 0,
        stageHealPct: j['stageHealPct'] as int? ?? 0,
        handSize: j['handSize'] as int? ?? 0,
        turnBreath: j['turnBreath'] as int? ?? 0,
        retain: j['retain'] as int? ?? 0,
        firstStrike: j['firstStrike'] as int? ?? 0,
        chain: j['chain'] as int? ?? 0,
        enemyHp: j['enemyHp'] as int? ?? 0,
        enemyStructure: j['enemyStructure'] as int? ?? 0,
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
/// escuela llegó al reino [realm] y está abierto alguno de [requires] (el
/// punto anterior de su rama, o cualquiera de los dos de una elección).
/// Los puntos con el mismo [choice] son una elección: abrir uno cierra el
/// otro para siempre.
class MeridianNode {
  const MeridianNode({
    required this.id,
    required this.branch,
    required this.realm,
    required this.cost,
    required this.effect,
    this.requires = const [],
    this.choice,
  });

  final String id;
  final MeridianBranch branch;

  /// Índice del reino que hace falta (0 = desde el principio).
  final int realm;
  final int cost;
  final MetaBonus effect;

  /// Basta con tener abierto uno de estos (vacío = no pide nada).
  final List<String> requires;

  /// Grupo de elección (null = punto suelto).
  final String? choice;

  factory MeridianNode.fromJson(Map<String, dynamic> j) => MeridianNode(
        id: j['id'] as String,
        branch: MeridianBranch.parse(j['branch'] as String),
        realm: j['realm'] as int? ?? 0,
        cost: j['cost'] as int,
        effect: MetaBonus.fromJson(j['effect'] as Map<String, dynamic>),
        requires: switch (j['requires']) {
          final String s => [s],
          final List l => l.cast<String>(),
          _ => const [],
        },
        choice: j['choice'] as String?,
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
    this.jadePer = 0,
    this.vow = 0,
  });

  final int perCombat;
  final int elite;
  final int boss;
  final int victory;

  /// Loto extra por cumplir un voto: vencer al jefe de la etapa con él.
  final int vow;

  /// Lo que da el premio de loto en cada etapa.
  final List<int> reward;

  /// Ofrenda al terminar: una semilla por cada [jadePer] de jade que
  /// sobró (0 = el jade se pierde).
  final int jadePer;

  int rewardAt(int stage) =>
      reward.isEmpty ? 0 : reward[stage.clamp(0, reward.length - 1)];

  factory LotusDef.fromJson(Map<String, dynamic> j) => LotusDef(
        perCombat: j['perCombat'] as int? ?? 0,
        elite: j['elite'] as int? ?? 0,
        boss: j['boss'] as int? ?? 0,
        victory: j['victory'] as int? ?? 0,
        reward: ((j['reward'] as List?) ?? const []).cast<int>(),
        jadePer: j['jadePer'] as int? ?? 0,
        vow: j['vow'] as int? ?? 0,
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
      prevOpen(n, owned) &&
      !chosenOther(n, owned);

  /// Está abierto alguno de los que pide [n].
  bool prevOpen(MeridianNode n, Iterable<String> owned) =>
      n.requires.isEmpty || n.requires.any(owned.contains);

  /// Ya se eligió el otro punto de la elección de [n].
  bool chosenOther(MeridianNode n, Iterable<String> owned) =>
      n.choice != null &&
      nodes.any((x) =>
          x.id != n.id && x.choice == n.choice && owned.contains(x.id));

  /// Las filas de una rama, de arriba abajo: un punto suelto o los de una
  /// elección (consecutivos con el mismo [MeridianNode.choice]).
  List<List<MeridianNode>> rows(MeridianBranch b) {
    final out = <List<MeridianNode>>[];
    for (final n in nodes.where((n) => n.branch == b)) {
      final last = out.lastOrNull;
      if (last != null && n.choice != null && last.first.choice == n.choice) {
        last.add(n);
      } else {
        out.add([n]);
      }
    }
    return out;
  }

  /// Puntos que se pueden llegar a abrir (uno por fila): el árbol completo.
  int get maxOwned =>
      MeridianBranch.values.fold(0, (a, b) => a + rows(b).length);

  /// Filas abiertas (cuenta una por elección).
  int ownedCount(Iterable<String> owned) =>
      nodes.where((n) => owned.contains(n.id)).length;

  /// Loto que cuesta el árbol completo (eligiendo lo más caro de cada fila).
  int get totalCost => [
        for (final b in MeridianBranch.values)
          for (final r in rows(b))
            r.map((n) => n.cost).reduce((a, c) => a > c ? a : c),
      ].fold(0, (a, c) => a + c);

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
