import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/screens/map/map_layout.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final engine = RunEngine(data);
  const phone = Size(402, 700);

  test('el mismo mapa siempre se dibuja igual', () {
    final run = engine.newRun(seed: 7, difficulty: Difficulty.normal);
    final a = layoutMap(run, data, phone);
    final b = layoutMap(run, data, phone);
    expect(a.pos, b.pos);
    expect(a.size, b.size);
  });

  for (final seed in [1, 2, 3, 4, 5, 42, 99]) {
    test('semilla $seed: los lugares no se pisan y entran en pantalla', () {
      final run = engine.newRun(seed: seed, difficulty: Difficulty.normal);
      final l = layoutMap(run, data, phone);
      expect(l.pos.keys.toSet(), {for (final n in run.map) n.id});
      for (final row in l.rows) {
        final xs = [for (final n in row) l.pos[n.id]!.dx];
        for (var i = 1; i < xs.length; i++) {
          expect(xs[i] - xs[i - 1], greaterThanOrEqualTo(90));
        }
      }
      for (final p in l.pos.values) {
        expect(p.dx, inInclusiveRange(54, phone.width - 54));
        expect(p.dy, inInclusiveRange(0, l.size.height));
      }
      // Se sube: cada piso queda más arriba que el anterior.
      for (var r = 1; r < l.rowY.length; r++) {
        expect(l.rowY[r], lessThan(l.rowY[r - 1]));
      }
    });
  }

  test('los pisos de un solo lugar son hitos', () {
    final run = engine.newRun(seed: 3, difficulty: Difficulty.normal);
    final l = layoutMap(run, data, phone);
    final shrineRow =
        l.rowOf[run.map.singleWhere((n) => n.type == NodeType.shrine).id]!;
    expect(l.landmarks[shrineRow], Landmark.gate);
    expect(l.landmarks[l.rows.length - 1], Landmark.summit);
    final shrine = l.pos[l.rows[shrineRow].single.id]!;
    expect((shrine.dx - phone.width / 2).abs(), lessThan(phone.width * 0.06));
  });
}
