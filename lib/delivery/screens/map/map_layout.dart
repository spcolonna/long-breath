import 'dart:math' as math;
import 'dart:ui';

import '../../../domain/model/enums.dart';
import '../../../domain/model/game_balance.dart';
import '../../../domain/model/game_data.dart';
import '../../../domain/run/run_state.dart';

/// Qué se dibuja detrás de un piso de un solo lugar: los hitos de la subida.
enum Landmark { gate, pond, pagoda, summit }

/// Dónde va cada lugar del mapa. Es puro: la misma subida siempre se ve
/// igual, pero no es una grilla — cada lugar se corre un poco según su id,
/// como un sendero de montaña de verdad.
class MapLayout {
  const MapLayout({
    required this.rows,
    required this.pos,
    required this.rowOf,
    required this.rowY,
    required this.landmarks,
    required this.size,
    required this.foot,
  });

  final List<List<MapNodeDef>> rows;

  /// Centro del sello de cada lugar.
  final Map<String, Offset> pos;
  final Map<String, int> rowOf;

  /// Altura (y) de cada piso.
  final List<double> rowY;
  final Map<int, Landmark> landmarks;
  final Size size;

  /// Pie de la montaña: de ahí sale el discípulo.
  final Offset foot;

  /// Piso alcanzado (1 = el primero); 0 si todavía no entró a ninguno.
  int floorOf(RunState run) =>
      run.currentNode == null ? 0 : (rowOf[run.currentNode!] ?? -1) + 1;
}

/// Alto mínimo de cada piso; si la montaña no entra en pantalla, se desplaza.
const mapRowH = 108.0;
const _top = 150.0; // cielo y cumbre por encima del jefe
const _bottom = 70.0; // pie de la montaña
const _minGap = 96.0; // dos sellos con su nombre no se pisan

/// Número estable en [0, 1) a partir de un texto (no usa `hashCode`, que
/// cambia entre ejecuciones).
double mapHash(String s, [int salt = 0]) {
  var h = 0x811C9DC5 ^ salt;
  for (final c in s.codeUnits) {
    h = ((h ^ c) * 0x01000193) & 0x7FFFFFFF;
  }
  return (h % 10007) / 10007;
}

/// Filas por profundidad desde los nodos de inicio.
List<List<MapNodeDef>> mapRows(RunState run) {
  final depth = {for (final id in run.starts) id: 0};
  final queue = [...run.starts];
  while (queue.isNotEmpty) {
    final id = queue.removeAt(0);
    for (final next in run.node(id).next) {
      if (!depth.containsKey(next)) {
        depth[next] = depth[id]! + 1;
        queue.add(next);
      }
    }
  }
  final maxD = depth.values.fold(0, (a, b) => a > b ? a : b);
  return [
    for (var d = 0; d <= maxD; d++)
      [
        for (final n in run.map)
          if (depth[n.id] == d) n,
      ],
  ];
}

Landmark? _landmark(List<MapNodeDef> row, GameData data) {
  if (row.length != 1) return null;
  final n = row.single;
  return switch (n.type) {
    NodeType.shrine => Landmark.gate,
    NodeType.fountain => Landmark.pond,
    NodeType.combat => switch (data.enemy(n.enemy!).rank) {
      EnemyRank.elite => Landmark.pagoda,
      EnemyRank.boss => Landmark.summit,
      EnemyRank.common => null,
    },
    _ => null,
  };
}

MapLayout layoutMap(RunState run, GameData data, Size view) {
  final rows = mapRows(run);
  final w = view.width;
  final height = math.max(view.height, _top + _bottom + rows.length * mapRowH);
  final rowH = (height - _top - _bottom) / rows.length;
  final pos = <String, Offset>{};
  final rowOf = <String, int>{};
  final rowY = <double>[];
  final landmarks = <int, Landmark>{};
  for (var r = 0; r < rows.length; r++) {
    final row = rows[r];
    final mark = _landmark(row, data);
    if (mark != null) landmarks[r] = mark;
    final y = height - _bottom - rowH * (r + 0.5);
    rowY.add(y);
    final slot = w / (row.length + 1);
    // Lo que sobra entre sellos es lo que se puede correr cada uno.
    final room = math.max(0.0, (slot - _minGap) / 2);
    for (var i = 0; i < row.length; i++) {
      final id = row[i].id;
      final reach = mark != null ? w * 0.05 : math.min(room, w * 0.12);
      final dx = (mapHash(id, 1) - 0.5) * 2 * reach;
      final dy = (mapHash(id, 2) - 0.5) * 2 * math.min(14.0, rowH * 0.12);
      pos[id] = Offset((slot * (i + 1) + dx).clamp(54.0, w - 54.0), y + dy);
      rowOf[id] = r;
    }
  }
  return MapLayout(
    rows: rows,
    pos: pos,
    rowOf: rowOf,
    rowY: rowY,
    landmarks: landmarks,
    size: Size(w, height),
    foot: Offset(w / 2, height - 22),
  );
}

/// El tramo de sendero entre dos lugares: una curva suave que se tuerce a
/// un lado o al otro según el par, nunca una línea recta.
Path trailPath(Offset a, Offset b, String salt) {
  final dy = a.dy - b.dy;
  final bend = (mapHash(salt, 3) - 0.5) * 56;
  return Path()
    ..moveTo(a.dx, a.dy)
    ..cubicTo(
      a.dx + bend,
      a.dy - dy * 0.42,
      b.dx + bend * 0.6,
      b.dy + dy * 0.42,
      b.dx,
      b.dy,
    );
}
