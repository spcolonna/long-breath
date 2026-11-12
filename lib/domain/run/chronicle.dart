/// 山志: la crónica de la montaña. Cada enemigo vencido abre su ficha en
/// el registro, con cuántas veces se lo venció y cuántas te venció.
library;

import '../model/enums.dart';
import '../model/game_data.dart';

/// Lo que la escuela sabe de un enemigo.
class Sighting {
  const Sighting({this.wins = 0, this.falls = 0});

  factory Sighting.fromJson(List<dynamic> j) => Sighting(
    wins: j.isNotEmpty ? j[0] as int : 0,
    falls: j.length > 1 ? j[1] as int : 0,
  );

  final int wins;
  final int falls;

  /// Se lo conoce: se lo venció o te venció.
  bool get seen => wins > 0 || falls > 0;

  List<int> toJson() => [wins, falls];
}

/// Los enemigos de la crónica, por etapa (donde aparecen primero): los
/// comunes, después los élites y al final el jefe. La última lista son los
/// discípulos perdidos, que no tienen etapa. Los muñecos de práctica no
/// cuentan.
List<List<String>> chronicleByStage(GameData data) {
  final seen = <String>{};
  final out = <List<String>>[];
  for (final stage in data.balance.stages) {
    final ids = <String>[];
    for (final f in stage.floors) {
      for (final id in [...f.enemies, ...f.escorts, ...f.elites]) {
        if (data.enemies.containsKey(id) && seen.add(id)) ids.add(id);
      }
    }
    out.add([
      for (final rank in EnemyRank.values)
        ...ids.where((id) => data.enemy(id).rank == rank),
    ]);
  }
  out.add([
    for (final id in data.enemies.keys)
      if (!seen.contains(id) && !id.startsWith('dummy')) id,
  ]);
  return out;
}

/// Todos los enemigos de la crónica, en orden.
List<String> chronicleOrder(GameData data) =>
    [for (final s in chronicleByStage(data)) ...s];
