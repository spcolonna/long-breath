import '../model/game_balance.dart';
import '../rng.dart';

/// Tipos que salen como mucho una vez por piso.
const _oncePerFloor = {
  NodeType.shrine,
  NodeType.fountain,
  NodeType.merchant,
  NodeType.master,
};

/// Tipos que tienen que aparecer al menos una vez en el mapa si algún piso
/// los permite (así toda subida tiene maestro). El mercader ya no va en el
/// mapa: aparece en el camino cada tantos combates (ver RunEngine).
const _required = [NodeType.master];

/// Arma el mapa de una subida con la semilla de la run, piso por piso.
///
/// Reglas: cada piso que permite combates tiene al menos uno; los
/// enemigos no se repiten dentro de un piso; los caminos no se cruzan.
/// Cada combate lleva un escenario (sin repetir en el piso) y una luz.
/// Los combates pueden traer un grupo (`packs` del piso) de los enemigos
/// [packable]: los que esperan entran de a uno cuando cae el anterior.
(List<MapNodeDef>, Rng) generateMap(
  List<FloorDef> floors,
  Rng rng, {
  List<String> scenes = const [],
  List<String> lights = const [],
  bool Function(String enemy)? packable,
}) {
  final types = <List<NodeType>>[];
  for (final f in floors) {
    final (w, r1) = rng.nextInt(f.maxWidth - f.minWidth + 1);
    rng = r1;
    final width = f.minWidth + w;
    final row = <NodeType>[];
    for (var i = 0; i < width; i++) {
      final pool = {
        for (final e in f.types.entries)
          if (e.value > 0 &&
              !(_oncePerFloor.contains(e.key) && row.contains(e.key)))
            e.key: e.value,
      };
      // Si no queda nada (piso angosto de un solo tipo), se repite combate.
      if (pool.isEmpty) {
        row.add(NodeType.combat);
        continue;
      }
      final (t, r2) = _weighted(rng, pool);
      rng = r2;
      row.add(t);
    }
    if (f.types.containsKey(NodeType.combat) &&
        !row.contains(NodeType.combat)) {
      row[0] = NodeType.combat;
    }
    types.add(row);
  }

  for (final need in _required) {
    if (types.any((row) => row.contains(need))) continue;
    // Pisos que lo permiten y donde se puede reemplazar algo que no sea el
    // único combate ni otro tipo obligatorio.
    final candidates = [
      for (var f = 0; f < floors.length; f++)
        if ((floors[f].types[need] ?? 0) > 0 && _slot(types[f]) >= 0) f,
    ];
    if (candidates.isEmpty) continue;
    final (pick, r1) = rng.nextInt(candidates.length);
    rng = r1;
    final row = types[candidates[pick]];
    row[_slot(row)] = need;
  }

  // Mezcla las posiciones y reparte enemigos y escenarios sin repetir
  // dentro del piso.
  final rows = <List<(NodeType, String?, String?, String?, List<String>)>>[];
  for (var f = 0; f < floors.length; f++) {
    final (shuffled, r1) = rng.shuffle(types[f]);
    final (enemies, r2) = r1.shuffle(floors[f].enemies);
    final (places, r3) = r2.shuffle(scenes);
    rng = r3;
    var e = 0;
    final row = <(NodeType, String?, String?, String?, List<String>)>[];
    final packs = {
      for (final p in floors[f].packs.entries)
        if (p.value > 0) p.key: p.value,
    };
    final followers = [
      for (final id in floors[f].enemies)
        if (packable?.call(id) ?? false) id,
    ];
    for (final t in shuffled) {
      if (t != NodeType.combat) {
        row.add((t, null, null, null, const []));
        continue;
      }
      String? light;
      if (lights.isNotEmpty) {
        final (l, r4) = rng.nextInt(lights.length);
        rng = r4;
        light = lights[l];
      }
      final scene =
          floors[f].scene ??
          (places.isEmpty ? null : places[e % places.length]);
      final lead = enemies.isEmpty ? null : enemies[e % enemies.length];
      final waves = <String>[];
      if (lead != null &&
          packs.length > 1 &&
          followers.isNotEmpty &&
          (packable?.call(lead) ?? false)) {
        final (size, r5) = _weighted(rng, packs);
        rng = r5;
        // Los que acompañan: sin repetir al que encabeza si se puede.
        final others = followers.where((x) => x != lead).toList();
        final from = others.isEmpty ? followers : others;
        for (var k = 1; k < size; k++) {
          final (pick, r6) = rng.nextInt(from.length);
          rng = r6;
          waves.add(from[pick]);
        }
      }
      row.add((t, lead, scene, light, waves));
      e++;
    }
    rows.add(row);
  }

  final nodes = <MapNodeDef>[];
  for (var f = 0; f < rows.length; f++) {
    final next = f + 1 < rows.length
        ? _links(rows[f].length, rows[f + 1].length, rng)
        : (List.generate(rows[f].length, (_) => <int>[]), rng);
    rng = next.$2;
    for (var i = 0; i < rows[f].length; i++) {
      nodes.add(
        MapNodeDef(
          id: _id(f, i),
          type: rows[f][i].$1,
          enemy: rows[f][i].$2,
          waves: rows[f][i].$5,
          scene: rows[f][i].$3,
          light: rows[f][i].$4,
          next: [for (final j in next.$1[i]) _id(f + 1, j)],
        ),
      );
    }
  }
  return (nodes, rng);
}

/// Lugar del piso que se puede ceder a un tipo obligatorio, o -1.
int _slot(List<NodeType> row) {
  final free = row.indexWhere(
    (t) => t != NodeType.combat && !_required.contains(t),
  );
  if (free >= 0) return free;
  final combats = row.where((t) => t == NodeType.combat).length;
  return combats > 1 ? row.indexOf(NodeType.combat) : -1;
}

String _id(int floor, int i) => 'f${floor + 1}${String.fromCharCode(97 + i)}';

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

/// Conexiones de un piso de [a] nodos al de [b]: cada nodo va a los que
/// le quedan enfrente; entre pisos del mismo ancho se suman diagonales al
/// azar sin que dos caminos se crucen. Todo nodo tiene entrada y salida.
(List<List<int>>, Rng) _links(int a, int b, Rng rng) {
  final out = List.generate(a, (_) => <int>{});
  if (a == b) {
    for (var i = 0; i < a; i++) {
      out[i].add(i);
    }
    // Para cada par vecino: nada, diagonal hacia arriba o hacia abajo.
    for (var i = 0; i + 1 < a; i++) {
      final (roll, next) = rng.nextInt(3);
      rng = next;
      if (roll == 1) out[i].add(i + 1);
      if (roll == 2) out[i + 1].add(i);
    }
  } else {
    // Cada nodo cubre una franja; se une con los de la franja que se pisa.
    for (var i = 0; i < a; i++) {
      for (var j = 0; j < b; j++) {
        if (i * b < (j + 1) * a && j * a < (i + 1) * b) out[i].add(j);
      }
    }
  }
  return ([for (final s in out) s.toList()..sort()], rng);
}
