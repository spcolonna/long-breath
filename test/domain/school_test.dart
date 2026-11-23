import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/meta_bonus.dart';
import 'package:long_breath/domain/model/school_def.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final real = RunEngine(loadGameDataFromDir());
  final school = real.data.balance.school;

  group('datos de la escuela', () {
    test('cinco edificios de tres niveles, con arte y textos', () {
      final content = jsonDecode(
        File('assets/l10n/content/es.json').readAsStringSync(),
      ) as Map<String, dynamic>;
      final texts = content['school'] as Map<String, dynamic>;
      expect(school.buildings.map((b) => b.id), [
        'infirmary',
        'tea_house',
        'forge',
        'library',
        'courtyard',
      ]);
      for (final b in school.buildings) {
        expect(b.maxLevel, 3, reason: b.id);
        expect(File('assets/art/school/${b.id}.webp').existsSync(), isTrue,
            reason: b.id);
        final t = texts[b.id] as Map<String, dynamic>;
        for (final f in ['name', 'hanzi', 'who', 'text', 'l1', 'l2', 'l3']) {
          expect(t[f], isA<String>(), reason: '${b.id}.$f');
        }
        // Cada nivel cuesta más que el anterior y hace algo.
        for (var i = 0; i < b.maxLevel; i++) {
          expect(b.levels[i].effect.isNone, isFalse, reason: '${b.id} $i');
          if (i > 0) {
            expect(b.levels[i].cost, greaterThan(b.levels[i - 1].cost));
          }
        }
      }
      expect(File('assets/art/school/school_ruins.webp').existsSync(), isTrue);
    });

    test('los dones suman los niveles restaurados, sin pasarse', () {
      expect(school.bonusOf(const {}).isNone, isTrue);
      final one = school.bonusOf(const {'infirmary': 1});
      expect(one.fountainHeal, school.building('infirmary')!.levels[0]
          .effect.fountainHeal);
      final all = school.bonusOf(const {'courtyard': 99, 'ghost': 3});
      expect(school.levelOf('courtyard', const {'courtyard': 99}), 3);
      var sum = MetaBonus.none;
      for (final l in school.building('courtyard')!.levels) {
        sum = sum + l.effect;
      }
      expect(all.toJson(), sum.toJson());
      expect(school.restored(const {'forge': 2, 'library': 1}), 3);
      expect(school.maxLevels, 15);
      expect(school.nextLevel('forge', const {'forge': 3}), isNull);
    });
  });

  group('efectos en la subida', () {
    test('la forja da el arma ya templada, hasta su máximo', () {
      final id = real.data.weapons.keys.first;
      final max = real.data.weapon(id).maxLevel;
      final r = real.newRun(seed: 1, meta: const MetaBonus(weaponLevel: 1));
      expect(real.equipWeapon(r, id).weaponLevel, 2.clamp(1, max));
      final big = real.newRun(seed: 1, meta: const MetaBonus(weaponLevel: 9));
      expect(real.equipWeapon(big, id).weaponLevel, max);
    });

    test('la enfermería cura más entre etapas', () {
      final base = real.newRun(seed: 1);
      final hurt = base.copyWith(hp: base.maxHp - 40);
      final plus = real
          .newRun(seed: 1, meta: const MetaBonus(stageHealPct: 15))
          .copyWith(hp: base.maxHp - 40);
      final pct = real.data.balance.stageHeal;
      expect(real.stageHealOf(hurt), (40 * pct / 100).round());
      expect(real.stageHealOf(plus), (40 * (pct + 15) / 100).round());
      final full = real
          .newRun(seed: 1, meta: const MetaBonus(stageHealPct: 500))
          .copyWith(hp: base.maxHp - 40);
      expect(real.stageHealOf(full), 40, reason: 'nunca más de lo que falta');
    });

    test('la casa de té hace que el té cure más', () {
      final r = real.newRun(seed: 1);
      final tea = real.newRun(seed: 1, meta: const MetaBonus(teaHeal: 8));
      expect(real.shopTeaHealOf(tea), real.shopTeaHealOf(r) + 8);
    });
  });

  test('el jade sobrante se guarda y restaura edificios', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    await storage.recordAscent(
      const Ascent(
        n: 0,
        fell: true,
        floor: 5,
        floors: 33,
        difficulty: Difficulty.normal,
      ),
      schoolJade: 100,
    );
    expect(await storage.schoolJadeTotal(), 100);
    const def = SchoolDef(
      buildings: [
        SchoolBuilding(
          id: 'forge',
          levels: [
            SchoolLevel(cost: 60, effect: MetaBonus(weaponLevel: 1)),
            SchoolLevel(cost: 80, effect: MetaBonus(structure: 2)),
          ],
        ),
      ],
    );
    expect(await storage.restoreBuilding(def, 'forge'), isTrue);
    expect(await storage.schoolJadeTotal(), 40);
    expect(await storage.schoolLevels(), {'forge': 1});
    expect(await storage.restoreBuilding(def, 'forge'), isFalse,
        reason: 'no alcanza');
    await storage.addSchoolJade(100);
    expect(await storage.restoreBuilding(def, 'forge'), isTrue);
    expect(await storage.restoreBuilding(def, 'forge'), isFalse,
        reason: 'ya está restaurado del todo');
    expect(await storage.schoolLevels(), {'forge': 2});
    expect(await storage.schoolJadeTotal(), 60);
    expect(ProgressStorage.slotKeys, containsAll(['school', 'schoolJade']));
  });
}
