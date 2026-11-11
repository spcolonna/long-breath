import '../model/game_balance.dart';
import '../rng.dart';

/// Tipos que salen como mucho una vez entre las puertas de una sala.
const _oncePerRow = {
  NodeType.shrine,
  NodeType.fountain,
  NodeType.merchant,
  NodeType.master,
};

/// Lo que el sendero recorrido le dice a las puertas que vienen.
class DoorContext {
  const DoorContext({
    required this.depth,
    this.restStreak = 0,
    this.fights = 0,
    this.masterOffered = false,
    this.detourOffered = false,
    this.merchantDue = false,
    this.usedElites = const {},
    this.recent = const {},
    this.rules = const PathRules(),
  });

  /// Profundidad de las puertas (0 = la primera de la etapa).
  final int depth;

  /// Salas seguidas sin pelear al final del sendero.
  final int restStreak;

  /// Peleas ya hechas en la etapa.
  final int fights;

  /// Ya se ofreció un maestro en la etapa.
  final bool masterOffered;

  /// Ya se ofreció un élite opcional (desvío) en la etapa.
  final bool detourOffered;

  /// Toca ofrecer un mercader.
  final bool merchantDue;

  /// Élites que ya salieron en la etapa (no se repiten si hay otros).
  final Set<String> usedElites;

  /// Enemigos de las salas recientes: se evitan si hay otros.
  final Set<String> recent;

  final PathRules rules;
}

bool _fightable(FloorDef f) => (f.types[NodeType.combat] ?? 0) > 0;

/// Las puertas de la profundidad [ctx.depth]: entre `width` del piso, con
/// sus tipos (pesos del piso) y, las de pelea, con su encuentro ya tirado.
///
/// Reglas: hay al menos una pelea donde el piso lo permite; si el sendero
/// lleva [PathRules.maxRest] salas sin pelear o no le quedan profundidades
/// para llegar a [PathRules.minFights], todas las puertas son de pelea; el
/// maestro se ofrece a más tardar en [PathRules.masterBy]; el mercader
/// aparece cuando toca ([DoorContext.merchantDue]); a lo sumo un élite
/// opcional por etapa.
(List<MapNodeDef>, Rng) rollDoors(
  List<FloorDef> floors,
  DoorContext ctx,
  Rng rng, {
  List<String> scenes = const [],
  List<String> lights = const [],
  bool Function(String enemy)? packable,
}) {
  final f = floors[ctx.depth];
  final rules = ctx.rules;
  final (w, r0) = rng.nextInt(f.maxWidth - f.minWidth + 1);
  rng = r0;
  final width = f.minWidth + w;
  final ahead = [
    for (var d = ctx.depth; d < floors.length; d++)
      if (_fightable(floors[d])) d,
  ].length;
  final mustFight =
      _fightable(f) &&
      (ctx.restStreak >= rules.maxRest ||
          ctx.fights + ahead <= rules.minFights);
  final free = _fightable(f) && f.maxWidth > 1 && !mustFight;

  final row = <NodeType>[];
  for (var i = 0; i < width; i++) {
    if (mustFight) {
      row.add(NodeType.combat);
      continue;
    }
    final pool = {
      for (final e in f.types.entries)
        if (e.value > 0 &&
            e.key != NodeType.merchant &&
            !(_oncePerRow.contains(e.key) && row.contains(e.key)))
          e.key: e.value,
    };
    if (pool.isEmpty) {
      row.add(NodeType.combat);
      continue;
    }
    final (t, r1) = _weighted(rng, pool);
    rng = r1;
    row.add(t);
  }
  if (_fightable(f) && !row.contains(NodeType.combat)) row[0] = NodeType.combat;

  // El maestro, si la etapa todavía no lo ofreció y ya es hora.
  if (free &&
      !ctx.masterOffered &&
      ctx.depth + 1 >= rules.masterBy &&
      (f.types[NodeType.master] ?? 0) > 0 &&
      !row.contains(NodeType.master)) {
    _place(row, NodeType.master, protect: const {});
  }
  // El mercader, cuando toca.
  if (free && ctx.merchantDue && !row.contains(NodeType.merchant)) {
    _place(row, NodeType.merchant, protect: const {NodeType.master});
  }

  final (shuffled, r2) = rng.shuffle(row);
  final (mixed, r3) = r2.shuffle(f.enemies);
  final (places, r4) = r3.shuffle(scenes);
  rng = r4;
  final enemies = [
    ...mixed.where((x) => !ctx.recent.contains(x)),
    ...mixed.where(ctx.recent.contains),
  ];

  // Élite opcional: un desvío, si queda otra pelea por donde pasar.
  var optional = -1;
  String? optionalFoe;
  final combats = shuffled.where((t) => t == NodeType.combat).length;
  if (!ctx.detourOffered &&
      !mustFight &&
      f.elite > 0 &&
      f.elites.isNotEmpty &&
      combats > 1) {
    final (roll, r5) = rng.nextInt(100);
    rng = r5;
    if (roll < f.elite) {
      final (pool, r6) = rng.shuffle(f.elites);
      rng = r6;
      optional = shuffled.indexOf(NodeType.combat);
      optionalFoe = [
        ...pool.where((x) => !ctx.usedElites.contains(x)),
        ...pool.where(ctx.usedElites.contains),
      ].first;
    }
  }

  final packs = {
    for (final p in f.packs.entries)
      if (p.value > 0) p.key: p.value,
  };
  final followers = [
    for (final id in f.enemies)
      if (packable?.call(id) ?? false) id,
  ];
  final fixedElites = [
    ...enemies.where((x) => !ctx.usedElites.contains(x)),
    ...enemies.where(ctx.usedElites.contains),
  ];
  final doors = <MapNodeDef>[];
  var e = 0;
  for (var i = 0; i < shuffled.length; i++) {
    final t = shuffled[i];
    final id = 'f${ctx.depth + 1}${String.fromCharCode(97 + i)}';
    if (t != NodeType.combat) {
      doors.add(MapNodeDef(id: id, type: t, next: const []));
      continue;
    }
    String? light;
    if (lights.isNotEmpty) {
      final (l, r7) = rng.nextInt(lights.length);
      rng = r7;
      light = lights[l];
    }
    final scene =
        f.scene ?? (places.isEmpty ? null : places[e % places.length]);
    // Piso de un solo élite (el guardián): sin repetir los de la etapa.
    final from = f.types.length == 1 && f.maxWidth == 1 ? fixedElites : enemies;
    final lead = i == optional
        ? optionalFoe
        : from.isEmpty
        ? null
        : from[e % from.length];
    final waves = <String>[];
    var together = false;
    if (lead != null &&
        i != optional &&
        packs.length > 1 &&
        followers.isNotEmpty &&
        (packable?.call(lead) ?? false)) {
      final (size, r8) = _weighted(rng, packs);
      rng = r8;
      final others = followers.where((x) => x != lead).toList();
      final pool = others.isEmpty ? followers : others;
      for (var k = 1; k < size; k++) {
        final (pick, r9) = rng.nextInt(pool.length);
        rng = r9;
        waves.add(pool[pick]);
      }
      if (waves.length == 1 && f.together > 0) {
        final (roll, r10) = rng.nextInt(100);
        rng = r10;
        together = roll < f.together;
      }
    } else if (lead != null &&
        i != optional &&
        f.escort > 0 &&
        f.escorts.isNotEmpty &&
        !(packable?.call(lead) ?? false)) {
      final (roll, r11) = rng.nextInt(100);
      rng = r11;
      if (roll < f.escort) {
        final (pick, r12) = rng.nextInt(f.escorts.length);
        rng = r12;
        waves.add(f.escorts[pick]);
        together = true;
      }
    }
    doors.add(
      MapNodeDef(
        id: id,
        type: t,
        next: const [],
        enemy: lead,
        waves: waves,
        together: together,
        scene: scene,
        light: light,
      ),
    );
    e++;
  }
  return (doors, rng);
}

/// Pone [type] en la fila: en lugar de algo que no sea pelea (ni de
/// [protect]), o agregándolo si hay lugar, o en lugar de una pelea si
/// quedan otras.
void _place(
  List<NodeType> row,
  NodeType type, {
  required Set<NodeType> protect,
}) {
  final free = row.indexWhere(
    (t) => t != NodeType.combat && !protect.contains(t),
  );
  if (free >= 0) {
    row[free] = type;
  } else if (row.length < 3) {
    row.add(type);
  } else if (row.where((t) => t == NodeType.combat).length > 1) {
    row[row.indexOf(NodeType.combat)] = type;
  }
}

(T, Rng) _weighted<T>(Rng rng, Map<T, int> pool) {
  final total = pool.values.fold(0, (a, b) => a + b);
  final (roll, next) = rng.nextInt(total);
  var acc = 0;
  for (final e in pool.entries) {
    acc += e.value;
    if (roll < acc) return (e.key, next);
  }
  return (pool.keys.last, next);
}
