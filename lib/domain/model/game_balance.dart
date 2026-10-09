import 'awakening_def.dart';
import 'cultivation_def.dart';
import 'enums.dart';
import 'meta_bonus.dart';

/// Cómo se juega la mano: el del novicio o el del camino animal elegido.
class StyleStats {
  const StyleStats({
    required this.hanzi,
    required this.pinyin,
    required this.draw,
    required this.breath,
    required this.retain,
    this.firstStrike = 0,
    this.chain = 0,
    this.retainedDiscount = 0,
    this.awakenings = const [],
  });

  final String hanzi;
  final String pinyin;
  final int draw;
  final int breath;
  final int retain;

  /// Tigre: daño extra del primer ataque de cada turno.
  final int firstStrike;

  /// Serpiente: daño extra de cada ataque por cada ataque anterior del turno.
  final int chain;

  /// Grulla: las cartas retenidas cuestan esto menos el turno siguiente.
  final int retainedDiscount;

  /// Despertares que el camino puede enseñar al superar una etapa.
  final List<AwakeningDef> awakenings;

  factory StyleStats.fromJson(Map<String, dynamic> j) => StyleStats(
        hanzi: j['hanzi'] as String,
        pinyin: j['pinyin'] as String,
        draw: j['draw'] as int,
        breath: j['breath'] as int,
        retain: j['retain'] as int,
        firstStrike: j['firstStrike'] as int? ?? 0,
        chain: j['chain'] as int? ?? 0,
        retainedDiscount: j['retainedDiscount'] as int? ?? 0,
        awakenings: [
          for (final a in (j['awakenings'] as List?) ?? const [])
            AwakeningDef.fromJson(a as Map<String, dynamic>),
        ],
      );
}

enum NodeType {
  combat,
  fountain,

  /// Santuario de los animales: se elige el camino.
  shrine,

  /// Escena con una decisión (ermitaño, puente, manantial…).
  event,

  /// Mercader de pergaminos: se compra con jade.
  merchant,

  /// Maestro errante: enseña una forma o mejora una carta.
  master;

  static NodeType parse(String s) => NodeType.values.byName(s);
}

/// Una etapa de la subida: su nombre, sus pisos (el último es su jefe) y los
/// escenarios y luces que se reparten entre sus combates.
class StageDef {
  const StageDef({
    required this.id,
    required this.hanzi,
    required this.pinyin,
    this.floors = const [],
    this.scenes = const ['terraza'],
    this.lights = const ['alba'],
    this.enemyMods = const PicoDef(),
  });

  final String id;
  final String hanzi;
  final String pinyin;
  final List<FloorDef> floors;
  final List<String> scenes;
  final List<String> lights;

  /// Rivales más duros en esta etapa (mismas reglas que un Pico): compensan
  /// los despertares que se aprenden al subir.
  final PicoDef enemyMods;

  /// [run] aporta pisos, escenas y luces cuando la etapa no los trae
  /// (formato viejo: una sola etapa con `run.floors`).
  factory StageDef.fromJson(
    Map<String, dynamic> j, [
    Map<String, dynamic> run = const {},
  ]) {
    List<String>? strings(String k) =>
        ((j[k] ?? run[k]) as List?)?.cast<String>();
    return StageDef(
      id: j['id'] as String,
      hanzi: j['hanzi'] as String,
      pinyin: j['pinyin'] as String,
      floors: [
        for (final f in ((j['floors'] ?? run['floors']) as List?) ?? const [])
          FloorDef.fromJson(f as Map<String, dynamic>),
      ],
      scenes: strings('scenes') ?? const ['terraza'],
      lights: strings('lights') ?? const ['alba'],
      enemyMods: switch (j['enemyMods']) {
        final Map<String, dynamic> m => PicoDef.fromJson(m),
        _ => const PicoDef(),
      },
    );
  }
}

class MapNodeDef {
  const MapNodeDef({
    required this.id,
    required this.type,
    required this.next,
    this.enemy,
    this.waves = const [],
    this.scene,
    this.light,
  });

  final String id;
  final NodeType type;
  final String? enemy;

  /// Enemigos que entran después de [enemy], uno por vez (grupo).
  final List<String> waves;
  final List<String> next;

  /// Escenario del combate y la luz del momento (alba, niebla, ocaso): de
  /// ahí sale el nombre del camino en el mapa, que no dice quién espera.
  final String? scene;
  final String? light;

  factory MapNodeDef.fromJson(Map<String, dynamic> j) => MapNodeDef(
        id: j['id'] as String,
        type: NodeType.parse(j['type'] as String),
        enemy: j['enemy'] as String?,
        waves: ((j['waves'] as List?) ?? const []).cast<String>(),
        next: (j['next'] as List).cast<String>(),
        scene: j['scene'] as String?,
        light: j['light'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        if (enemy != null) 'enemy': enemy,
        if (waves.isNotEmpty) 'waves': waves,
        'next': next,
        if (scene != null) 'scene': scene,
        if (light != null) 'light': light,
      };
}

/// Un piso del mapa generado: cuántos nodos tiene, de qué tipo pueden ser
/// (con su peso) y qué enemigos pueden salir en sus combates.
class FloorDef {
  const FloorDef({
    required this.minWidth,
    required this.maxWidth,
    required this.types,
    this.enemies = const [],
    this.packs = const {1: 1},
    this.scene,
  });

  final int minWidth;
  final int maxWidth;
  final Map<NodeType, int> types;
  final List<String> enemies;

  /// Peso de cada tamaño de grupo en los combates comunes ({1: 3, 2: 2}).
  final Map<int, int> packs;

  /// Escenario fijo de los combates del piso (la cumbre del jefe); si no,
  /// sale al azar de [GameBalance.scenes].
  final String? scene;

  factory FloorDef.fromJson(Map<String, dynamic> j) {
    final width = j['width'];
    final (min, max) = switch (width) {
      final List w => (w[0] as int, w[1] as int),
      final int w => (w, w),
      _ => (1, 1),
    };
    return FloorDef(
      minWidth: min,
      maxWidth: max,
      types: {
        for (final e in (j['types'] as Map<String, dynamic>).entries)
          NodeType.parse(e.key): e.value as int,
      },
      enemies: ((j['enemies'] as List?) ?? const []).cast<String>(),
      packs: switch (j['packs']) {
        final Map<String, dynamic> m => {
            for (final e in m.entries) int.parse(e.key): e.value as int,
          },
        _ => const {1: 1},
      },
      scene: j['scene'] as String?,
    );
  }
}

/// Precios del mercader, en jade.
class MerchantDef {
  const MerchantDef({
    this.cards = 3,
    this.card = 25,
    this.talisman = 60,
    this.remove = 35,
    this.upgrade = 30,
    this.sale = 40,
    this.tea = 15,
    this.teaHeal = 15,
    this.rareTalisman = false,
  });

  /// Cartas en venta.
  final int cards;
  final int card;
  final int talisman;
  final int remove;
  final int upgrade;

  /// Descuento (%) de la carta en oferta.
  final int sale;

  /// Té de jengibre: precio y Vida que cura (una vez por tienda).
  final int tea;
  final int teaHeal;

  /// Si el talismán en venta es raro (los mercaderes de más arriba).
  final bool rareTalisman;

  /// Precio de una carta en oferta.
  int get salePrice => (card * (100 - sale) / 100).round();

  /// Los mismos precios con [pct] % de descuento (meridianos).
  MerchantDef discounted(int pct) {
    if (pct <= 0) return this;
    int off(int v) => (v * (100 - pct) / 100).round();
    return MerchantDef(
      cards: cards,
      card: off(card),
      talisman: off(talisman),
      remove: off(remove),
      upgrade: off(upgrade),
      sale: sale,
      tea: off(tea),
      teaHeal: teaHeal,
      rareTalisman: rareTalisman,
    );
  }

  factory MerchantDef.fromJson(Map<String, dynamic> j) => MerchantDef(
        cards: j['cards'] as int? ?? 3,
        card: j['card'] as int? ?? 25,
        talisman: j['talisman'] as int? ?? 60,
        remove: j['remove'] as int? ?? 35,
        upgrade: j['upgrade'] as int? ?? 30,
        sale: j['sale'] as int? ?? 40,
        tea: j['tea'] as int? ?? 15,
        teaHeal: j['teaHeal'] as int? ?? 15,
        rareTalisman: j['rareTalisman'] as bool? ?? false,
      );
}

/// Ajustes de una dificultad. Los porcentajes se aplican a los enemigos
/// de la subida (no a los muñecos de las lecciones).
class DifficultyDef {
  const DifficultyDef({
    required this.hanzi,
    required this.playerHp,
    required this.fountainHeal,
    this.enemyHp = 100,
    this.enemyDamage = 100,
    this.enemyStructure = 100,
  });

  final String hanzi;
  final int playerHp;
  final int fountainHeal;
  final int enemyHp;
  final int enemyDamage;
  final int enemyStructure;

  factory DifficultyDef.fromJson(Map<String, dynamic> j) => DifficultyDef(
        hanzi: j['hanzi'] as String,
        playerHp: j['playerHp'] as int,
        fountainHeal: j['fountainHeal'] as int,
        enemyHp: j['enemyHp'] as int? ?? 100,
        enemyDamage: j['enemyDamage'] as int? ?? 100,
        enemyStructure: j['enemyStructure'] as int? ?? 100,
      );
}

/// Una regla de Pico. Se acumulan: el Pico N suma las reglas del 1 al N.
/// Los porcentajes se suman a los de la dificultad.
class PicoDef {
  const PicoDef({
    this.enemyHp = 0,
    this.commonHp = 0,
    this.eliteHp = 0,
    this.bossHp = 0,
    this.enemyDamage = 0,
    this.enemyStructure = 0,
    this.fountainHeal = 0,
    this.playerHp = 0,
  });

  final int enemyHp;
  final int commonHp;
  final int eliteHp;
  final int bossHp;
  final int enemyDamage;
  final int enemyStructure;
  final int fountainHeal;
  final int playerHp;

  PicoDef operator +(PicoDef o) => PicoDef(
        enemyHp: enemyHp + o.enemyHp,
        commonHp: commonHp + o.commonHp,
        eliteHp: eliteHp + o.eliteHp,
        bossHp: bossHp + o.bossHp,
        enemyDamage: enemyDamage + o.enemyDamage,
        enemyStructure: enemyStructure + o.enemyStructure,
        fountainHeal: fountainHeal + o.fountainHeal,
        playerHp: playerHp + o.playerHp,
      );

  factory PicoDef.fromJson(Map<String, dynamic> j) => PicoDef(
        enemyHp: j['enemyHp'] as int? ?? 0,
        commonHp: j['commonHp'] as int? ?? 0,
        eliteHp: j['eliteHp'] as int? ?? 0,
        bossHp: j['bossHp'] as int? ?? 0,
        enemyDamage: j['enemyDamage'] as int? ?? 0,
        enemyStructure: j['enemyStructure'] as int? ?? 0,
        fountainHeal: j['fountainHeal'] as int? ?? 0,
        playerHp: j['playerHp'] as int? ?? 0,
      );
}

/// Tipos de premio de un combate ganado (se revela al ganar).
enum RewardKind { cards, jade, lotus, upgrade, tea, talisman }

/// Qué premio deja un combate común: pesos por etapa y cuánto da cada uno.
class CombatRewardsDef {
  const CombatRewardsDef({
    this.weights = const [],
    this.jade = const [],
    this.teaPct = const [],
    this.talismanChoices = 2,
    this.maxWithoutCards = 2,
  });

  /// Sin datos: siempre cartas (datos viejos y pruebas).
  static const none = CombatRewardsDef();

  final List<Map<RewardKind, int>> weights;
  final List<int> jade;

  /// Vida máxima (%) que cura el té.
  final List<int> teaPct;
  final int talismanChoices;

  /// Premios seguidos sin cartas como máximo.
  final int maxWithoutCards;

  static T _at<T>(List<T> l, int stage, T fallback) =>
      l.isEmpty ? fallback : l[stage.clamp(0, l.length - 1)];

  Map<RewardKind, int> weightsAt(int stage) =>
      _at(weights, stage, const {RewardKind.cards: 1});
  int jadeAt(int stage) => _at(jade, stage, 0);
  int teaPctAt(int stage) => _at(teaPct, stage, 0);

  factory CombatRewardsDef.fromJson(Map<String, dynamic> j) =>
      CombatRewardsDef(
        weights: [
          for (final w in (j['weights'] as List?) ?? const [])
            {
              for (final e in (w as Map<String, dynamic>).entries)
                RewardKind.values.byName(e.key): e.value as int,
            },
        ],
        jade: ((j['jade'] as List?) ?? const []).cast<int>(),
        teaPct: ((j['teaPct'] as List?) ?? const []).cast<int>(),
        talismanChoices: j['talismanChoices'] as int? ?? 2,
        maxWithoutCards: j['maxWithoutCards'] as int? ?? 2,
      );
}

class GameBalance {
  const GameBalance({
    required this.playerHp,
    required this.playerStructure,
    required this.startStance,
    required this.breathesPerCombat,
    this.breatheCost = 1,
    required this.novice,
    required this.styles,
    required this.pathChoices,
    required this.deflectEnemyStructureLoss,
    required this.deflectBreathBonus,
    required this.playerBreakBreathPenalty,
    required this.enemyBreakDamageMultiplier,
    required this.rewardChoices,
    required this.rewardPools,
    this.talismanChoices = 3,
    required this.fountainHeal,
    required this.fountainUpgrade,
    required this.stages,
    this.fixedMap,
    this.stageHeal = 100,
    this.stageJade = 0,
    this.jadeCommon = 0,
    this.jadeElite = 0,
    this.jadeSpread = 0,
    this.merchant = const MerchantDef(),
    this.stageMerchants = const [],
    this.masterForms = 2,
    this.packHp = const [100],
    this.packJade = 0,
    this.merchantEvery = 0,
    this.merchantSpread = 0,
    required this.difficulties,
    this.picos = const [],
    this.awakeningChoices = 3,
    this.cultivation = CultivationDef.none,
    this.meridians = MeridianDef.none,
    this.combatRewards = CombatRewardsDef.none,
  });

  final int playerHp;
  final int playerStructure;
  final Stance startStance;
  final int breathesPerCombat;

  /// Aliento que cuesta Respirar (cambiar toda la mano).
  final int breatheCost;
  final StyleStats novice;
  final Map<Style, StyleStats> styles;

  /// Cuántos caminos (al azar) ofrece el santuario.
  final int pathChoices;
  final int deflectEnemyStructureLoss;
  final int deflectBreathBonus;
  final int playerBreakBreathPenalty;
  final int enemyBreakDamageMultiplier;
  final int rewardChoices;
  final List<String> rewardPools;

  /// Talismanes que ofrece el élite al vencerlo.
  final int talismanChoices;
  final int fountainHeal;
  final int fountainUpgrade;
  /// Etapas de la subida, de abajo hacia arriba. Vencer al jefe de una
  /// lleva a la siguiente; vencer al de la última es la cumbre.
  final List<StageDef> stages;

  /// Primera etapa (y la única con el formato viejo).
  StageDef get stage => stages.first;

  /// Pisos de la primera etapa.
  List<FloorDef> get floors => stage.floors;
  List<String> get scenes => stage.scenes;
  List<String> get lights => stage.lights;

  /// Pisos de toda la subida (para el registro: "piso 14 de 27").
  int get totalFloors => stages.fold(0, (a, s) => a + s.floors.length);

  /// Mapa fijo (solo para el simulador); si no hay, se genera por run.
  final List<MapNodeDef>? fixedMap;

  /// Al vencer al jefe de una etapa intermedia: porcentaje de la Vida que
  /// falta que se recupera y jade para gastar en la etapa siguiente.
  final int stageHeal;
  final int stageJade;

  /// Jade que se gana al vencer a un común o a un élite (más 0..spread).
  final int jadeCommon;
  final int jadeElite;
  final int jadeSpread;
  final MerchantDef merchant;

  /// Mercader de cada etapa: el base con lo que la etapa cambia (`merchant`
  /// dentro de la etapa). Más arriba, todo cuesta más y hay otras cosas.
  final List<MerchantDef> stageMerchants;

  /// Vida (%) de cada enemigo según el tamaño del grupo: [100, 70, 58].
  final List<int> packHp;

  /// Jade extra por cada enemigo de más en el grupo.
  final int packJade;

  int packHpPct(int size) =>
      packHp.isEmpty ? 100 : packHp[(size - 1).clamp(0, packHp.length - 1)];

  /// El mercader ambulante aparece cada [merchantEvery] combates ganados
  /// (± [merchantSpread]); 0 = solo en sus nodos del mapa.
  final int merchantEvery;
  final int merchantSpread;

  MerchantDef merchantAt(int stage) =>
      stage < stageMerchants.length ? stageMerchants[stage] : merchant;

  /// Formas que ofrece el maestro errante.
  final int masterForms;
  final Map<Difficulty, DifficultyDef> difficulties;

  DifficultyDef difficulty(Difficulty d) => difficulties[d]!;

  /// Reglas de los Picos, del 1 al 10.
  final List<PicoDef> picos;

  /// Reglas acumuladas hasta el Pico [n] (0 = ninguna).
  PicoDef picoMods(int n) =>
      picos.take(n).fold(const PicoDef(), (a, p) => a + p);

  /// Estadísticas del camino, o las del novicio si todavía no eligió.
  StyleStats statsOf(Style? s) => s == null ? novice : styles[s]!;

  /// Un despertar de cualquier camino.
  AwakeningDef awakening(String id) =>
      styles.values.expand((s) => s.awakenings).firstWhere(
            (a) => a.id == id,
            orElse: () => throw ArgumentError('Despertar desconocido: $id'),
          );

  /// Suma de los despertares de una run.
  AwakeningEffect awakeningsEffect(Iterable<String> ids) => ids.fold(
        AwakeningEffect.none,
        (a, id) => a + awakening(id).effect,
      );

  /// Cuántos despertares se ofrecen al superar una etapa.
  final int awakeningChoices;

  /// Reinos del cultivo y cuánto aliento deja cada subida.
  final CultivationDef cultivation;

  /// Árbol de meridianos, dones de los reinos y semillas de loto.
  final MeridianDef meridians;

  /// Premios variados de los combates.
  final CombatRewardsDef combatRewards;

  factory GameBalance.fromJson(Map<String, dynamic> j) {
    final player = j['player'] as Map<String, dynamic>;
    final styles = j['styles'] as Map<String, dynamic>;
    final deflect = j['deflect'] as Map<String, dynamic>;
    final rewards = j['rewards'] as Map<String, dynamic>;
    final fountain = j['fountain'] as Map<String, dynamic>;
    final run = j['run'] as Map<String, dynamic>;
    final jade = (j['jade'] as Map<String, dynamic>?) ?? const {};
    return GameBalance(
      playerHp: player['hp'] as int,
      playerStructure: player['structure'] as int,
      startStance: Stance.parse(player['startStance'] as String)!,
      breathesPerCombat: player['breathesPerCombat'] as int,
      breatheCost: player['breatheCost'] as int? ?? 1,
      novice: StyleStats.fromJson(j['novice'] as Map<String, dynamic>),
      styles: {
        for (final e in styles.entries)
          Style.parse(e.key): StyleStats.fromJson(e.value as Map<String, dynamic>),
      },
      pathChoices: (j['paths'] as Map<String, dynamic>)['choices'] as int,
      deflectEnemyStructureLoss: deflect['enemyStructureLoss'] as int,
      deflectBreathBonus: deflect['breathBonus'] as int,
      playerBreakBreathPenalty:
          (j['playerBreak'] as Map<String, dynamic>)['breathPenalty'] as int,
      enemyBreakDamageMultiplier:
          (j['enemyBreak'] as Map<String, dynamic>)['damageMultiplier'] as int,
      rewardChoices: rewards['choices'] as int,
      rewardPools: (rewards['pools'] as List).cast<String>(),
      talismanChoices: rewards['talismanChoices'] as int? ?? 3,
      fountainHeal: fountain['heal'] as int,
      fountainUpgrade: fountain['upgrade'] as int,
      stages: switch (run['stages']) {
        final List stages => [
            for (final st in stages) StageDef.fromJson(st as Map<String, dynamic>),
          ],
        _ => [StageDef.fromJson(run['stage'] as Map<String, dynamic>, run)],
      },
      stageHeal: (run['stageClear'] as Map<String, dynamic>?)?['heal'] as int? ?? 100,
      stageJade: (run['stageClear'] as Map<String, dynamic>?)?['jade'] as int? ?? 0,
      fixedMap: switch (run['nodes']) {
        final List nodes => [
            for (final n in nodes) MapNodeDef.fromJson(n as Map<String, dynamic>),
          ],
        _ => null,
      },
      jadeCommon: jade['common'] as int? ?? 0,
      jadeElite: jade['elite'] as int? ?? 0,
      jadeSpread: jade['spread'] as int? ?? 0,
      merchant: MerchantDef.fromJson(
        (j['merchant'] as Map<String, dynamic>?) ?? const {},
      ),
      stageMerchants: [
        for (final st in (run['stages'] as List?) ?? const [])
          MerchantDef.fromJson({
            ...(j['merchant'] as Map<String, dynamic>?) ?? const {},
            ...((st as Map<String, dynamic>)['merchant']
                    as Map<String, dynamic>?) ??
                const {},
          }),
      ],
      awakeningChoices: run['awakeningChoices'] as int? ?? 3,
      packHp: ((run['packs'] as Map<String, dynamic>?)?['hpPct'] as List?)
              ?.cast<int>() ??
          const [100],
      packJade:
          (run['packs'] as Map<String, dynamic>?)?['jadePerExtra'] as int? ?? 0,
      merchantEvery:
          (run['wanderingMerchant'] as Map<String, dynamic>?)?['every'] as int? ??
              0,
      merchantSpread:
          (run['wanderingMerchant'] as Map<String, dynamic>?)?['spread']
                  as int? ??
              0,
      masterForms:
          ((j['master'] as Map<String, dynamic>?) ?? const {})['forms'] as int? ??
              2,
      difficulties: {
        for (final e in (j['difficulties'] as Map<String, dynamic>).entries)
          Difficulty.parse(e.key):
              DifficultyDef.fromJson(e.value as Map<String, dynamic>),
      },
      picos: [
        for (final p in (j['picos'] as List?) ?? const [])
          PicoDef.fromJson(p as Map<String, dynamic>),
      ],
      cultivation: switch (j['cultivation']) {
        final Map<String, dynamic> c => CultivationDef.fromJson(c),
        _ => CultivationDef.none,
      },
      meridians: switch (j['meridians']) {
        final Map<String, dynamic> m => MeridianDef.fromJson(m),
        _ => MeridianDef.none,
      },
      combatRewards: switch (j['combatRewards']) {
        final Map<String, dynamic> m => CombatRewardsDef.fromJson(m),
        _ => CombatRewardsDef.none,
      },
    );
  }
}
