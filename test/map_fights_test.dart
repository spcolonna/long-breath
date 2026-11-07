import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/map_gen.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// Ningún camino se salta las peleas: como mucho [maxRest] lugares seguidos
/// sin combate y al menos [minFights] combates por etapa.
void main() {
  final data = loadGameDataFromDir();

  test('todo camino tiene peleas suficientes y sigue habiendo maestro', () {
    for (final st in data.balance.stages) {
      for (var seed = 0; seed < 500; seed++) {
        final (map, _) = generateMap(
          st.floors,
          Rng.seeded(seed),
          scenes: st.scenes,
          lights: st.lights,
        );
        final byId = {for (final n in map) n.id: n};
        expect(map.any((n) => n.type == NodeType.master), isTrue,
            reason: '${st.id} semilla $seed sin maestro');
        for (final n in map.where((n) => n.type == NodeType.combat)) {
          expect(n.enemy, isNotNull, reason: '${st.id} ${n.id}');
        }
        void walk(MapNodeDef n, int rest, int fights, String trail) {
          final fight = n.type == NodeType.combat;
          final r = fight ? 0 : rest + 1;
          final f = fights + (fight ? 1 : 0);
          final path = '$trail ${n.id}:${n.type.name}';
          expect(r, lessThanOrEqualTo(maxRest),
              reason: '${st.id} semilla $seed:$path');
          if (n.next.isEmpty) {
            expect(f, greaterThanOrEqualTo(minFights),
                reason: '${st.id} semilla $seed:$path');
            return;
          }
          for (final id in n.next) {
            walk(byId[id]!, r, f, path);
          }
        }

        for (final start in map.where((n) => n.id.startsWith('f1') &&
            n.id.length == 3)) {
          walk(start, 0, 0, '');
        }
      }
    }
  });
}
