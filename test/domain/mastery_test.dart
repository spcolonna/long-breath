import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/meta_bonus.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final real = RunEngine(loadGameDataFromDir());
  final data = real.data;
  final def = data.balance.mastery;
  final closed = def.lockedFor(const {});

  test('cinco niveles por camino que abren cosas de ese camino', () {
    expect(def.maxLevel, 5);
    final cultivation = {
      for (final r in data.balance.cultivation.realms) ...r.unlocks,
    };
    for (final (i, l) in def.levels.indexed) {
      if (i > 0) expect(l.xp, greaterThan(def.levels[i - 1].xp));
      for (final s in Style.values) {
        expect(l.of(s), isNotEmpty, reason: '$s $i');
        for (final id in l.of(s)) {
          expect(cultivation, isNot(contains(id)), reason: id);
          final awakening = data.balance
              .statsOf(s)
              .awakenings
              .any((a) => a.id == id);
          final card = data.cards[id];
          final weapon = data.weapons.values.where(
            (w) => w.levels.any((x) => x.cards.contains(id)),
          );
          expect(
            awakening || card?.pool == s.name || weapon.any((w) => w.path == s),
            isTrue,
            reason: '$id no es del camino $s',
          );
        }
      }
    }
    expect(closed.toSet(), hasLength(closed.length), reason: 'sin repetidos');
    expect(def.lockedFor({for (final s in Style.values) s: 9999}), isEmpty);
    expect(def.levelOf(def.levels.first.xp - 1), 0);
    expect(def.levelOf(def.levels.first.xp), 1);
    expect(def.progress(def.levels.last.xp), 1);
  });

  group('sin maestría', () {
    RunState fresh(Style s, {MetaBonus meta = MetaBonus.none}) =>
        real.newRun(seed: 3, locked: closed, meta: meta).copyWith(style: s);

    test('las cartas raras y la legendaria del camino no salen', () {
      final r = fresh(Style.tiger);
      final pool = data
          .rewardPoolFor(Style.tiger, locked: r.locked)
          .map((c) => c.id);
      expect(pool, isNot(contains('hu_pu')));
      expect(pool, isNot(contains('hu_ya')));
      expect(pool, contains('hu_zhao'));
    });

    test('el cuarto despertar queda cerrado', () {
      expect(
        real.missingAwakenings(fresh(Style.snake)),
        isNot(contains('she_tui')),
      );
      expect(real.missingAwakenings(fresh(Style.snake)), hasLength(3));
    });

    test('el arma no pasa del nivel 2, ni con la forja de la escuela', () {
      final r = fresh(Style.tiger, meta: const MetaBonus(weaponLevel: 9));
      expect(real.weaponMaxOf(r, 'pudao'), 2);
      final armed = real.equipWeapon(r, 'pudao');
      expect(armed.weaponLevel, 2);
      expect(real.canForge(armed), isFalse);
      final open = real.newRun(seed: 3).copyWith(style: Style.tiger);
      expect(real.weaponMaxOf(open, 'pudao'), 3);
    });
  });

  test('cada pelea ganada suma experiencia; escapar no', () {
    final r = real.newRun(seed: 5).copyWith(phase: RunPhase.map);
    final fight = real.enter(r, real.available(r).first);
    expect(fight.phase, RunPhase.combat);
    final won = real.finishCombat(fight, won: true, hp: fight.hp);
    expect(won.masteryXp, def.perCombat);
    final fled = real.finishCombat(fight, won: true, hp: fight.hp, fledWith: 0);
    expect(fled.masteryXp, 0);
    expect(RunState.fromJson(won.toJson()).masteryXp, def.perCombat);
  });

  test('la experiencia de la subida va a su camino', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    expect(await storage.mastery(), isEmpty);
    await storage.recordAscent(
      const Ascent(
        n: 0,
        fell: true,
        floor: 9,
        floors: 33,
        difficulty: Difficulty.normal,
        style: Style.crane,
        mastery: 12,
      ),
    );
    await storage.addMastery(Style.crane, 3);
    await storage.addMastery(Style.tiger, 7);
    expect(await storage.mastery(), {Style.crane: 15, Style.tiger: 7});
    expect(ProgressStorage.slotKeys, contains('mastery'));
  });
}
