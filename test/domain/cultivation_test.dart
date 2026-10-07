import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/cultivation.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final def = data.balance.cultivation;

  test('seis reinos de menor a mayor; el primero arranca en 0', () {
    expect(def.realms.length, 6);
    expect(def.realms.first.breath, 0);
    for (var i = 1; i < def.realms.length; i++) {
      expect(def.realms[i].breath, greaterThan(def.realms[i - 1].breath));
    }
    expect(def.realmOf(0), 0);
    expect(def.realmOf(def.realms[1].breath - 1), 0);
    expect(def.realmOf(def.realms[1].breath), 1);
    expect(def.realmOf(1 << 20), 5);
  });

  test('lo que abre cada reino existe y no se repite', () {
    final ids = [for (final r in def.realms) ...r.unlocks];
    expect(ids.toSet().length, ids.length);
    for (final id in ids) {
      final known = Style.values.any((s) => s.name == id) ||
          data.cards.containsKey(id) ||
          data.talismans.containsKey(id) ||
          data.forms.any((f) => f.id == id);
      expect(known, isTrue, reason: id);
    }
    // Lo cerrado se va abriendo: en el último reino no queda nada.
    expect(def.lockedAt(0).length, ids.length);
    expect(def.lockedAt(5), isEmpty);
    expect(def.opened(0, 2), [...def.realms[1].unlocks, ...def.realms[2].unlocks]);
  });

  test('una forma abierta nunca pide cartas que siguen cerradas', () {
    for (var realm = 0; realm < def.realms.length; realm++) {
      final locked = def.lockedAt(realm).toSet();
      for (final f in data.forms.where((f) => !locked.contains(f.id))) {
        for (final step in f.steps) {
          expect(locked.contains(step), isFalse,
              reason: 'reino $realm: ${f.id} pide $step');
        }
      }
    }
  });

  test('aliento: más por subir más alto, ganar y jugar más difícil', () {
    Ascent a({bool fell = true, int floor = 10, int stage = 0,
            Difficulty d = Difficulty.normal, int pico = 0}) =>
        Ascent(n: 1, fell: fell, floor: floor, floors: 33, stage: stage,
            difficulty: d, pico: pico);
    final low = ascentBreath(def, a(floor: 4));
    final high = ascentBreath(def, a(floor: 20, stage: 1));
    final won = ascentBreath(def, a(fell: false, floor: 33, stage: 2));
    expect(low, greaterThan(0));
    expect(high, greaterThan(low));
    expect(won, greaterThan(high));
    expect(ascentBreath(def, a(d: Difficulty.easy)),
        lessThan(ascentBreath(def, a())));
    expect(ascentBreath(def, a(d: Difficulty.hard)),
        greaterThan(ascentBreath(def, a())));
    expect(ascentBreath(def, a(pico: 3)), greaterThan(ascentBreath(def, a())));
  });

  test('una run del primer reino no ofrece nada cerrado', () {
    final engine = RunEngine(data);
    final locked = def.lockedAt(0);
    for (var seed = 1; seed <= 40; seed++) {
      var r = engine.newRun(seed: seed, locked: locked);
      expect(r.locked, locked);
      // Persistencia: lo cerrado viaja con el guardado.
      expect(RunState.fromJson(r.toJson()).locked, locked);
      // Un mapa de un solo santuario para llegar directo a elegir camino.
      r = engine.enter(
        r.copyWith(
          map: const [MapNodeDef(id: 'ns', type: NodeType.shrine, next: [])],
        ),
        'ns',
      );
      expect(r.pathOptions.map((s) => s.name), isNot(contains('crane')));
      r = engine.choosePath(r, r.pathOptions.first);
      expect(
        engine.learnableForms(r).where(locked.contains),
        isEmpty,
      );
      expect(engine.missingTalismans(r).where(locked.contains), isEmpty);
      expect(
        data.rewardPoolFor(r.style, locked: r.locked).map((c) => c.id),
        isNot(anyElement(isIn(locked))),
      );
    }
  });

  test('sin nada cerrado la run es la de siempre', () {
    final engine = RunEngine(data);
    final a = engine.newRun(seed: 9);
    expect(a.locked, isEmpty);
    expect(engine.missingTalismans(a).length, data.talismans.length);
  });

  test('el cultivo informa el progreso hacia el reino siguiente', () {
    final half = (def.realms[1].breath / 2).round();
    expect(Cultivation(def, half).progress, closeTo(0.5, 0.02));
    expect(Cultivation(def, 1 << 20).isMax, isTrue);
    expect(Cultivation(def, 1 << 20).progress, 1);
    expect(Cultivation(def, 0).locked, def.lockedAt(0));
  });
}
