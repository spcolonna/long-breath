import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/screens/map/map_node.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/map_gen.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// El élite opcional se marca en el mapa; el de arriba de la etapa, no.
void main() {
  final data = loadGameDataFromDir();

  test('solo el élite que comparte piso lleva la marca de desvío', () {
    var marked = 0;
    for (final st in data.balance.stages) {
      for (var seed = 0; seed < 60; seed++) {
        final (map, _) = generateMap(st.floors, Rng.seeded(seed));
        for (final n in map) {
          final elite = n.type == NodeType.combat &&
              data.enemy(n.enemy!).rank == EnemyRank.elite;
          final optional = isOptionalElite(n, map, data);
          if (!elite) expect(optional, isFalse);
          // El piso 9 es todo élite: no hay desvío posible.
          if (n.id.startsWith('f9')) expect(optional, isFalse, reason: n.id);
          if (elite && !n.id.startsWith('f9')) {
            expect(optional, isTrue, reason: '${st.id} ${n.id}');
            marked++;
          }
        }
      }
    }
    expect(marked, greaterThan(0));
  });
}
