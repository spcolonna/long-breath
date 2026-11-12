import '../model/game_balance.dart';
import 'run_state.dart';

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
