import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/ascent.dart';
import 'package:long_breath/domain/run/feats.dart';

void main() {
  Ascent ascent({
    bool fell = true,
    Style? style,
    Difficulty difficulty = Difficulty.normal,
    int pico = 0,
    int deck = 20,
    int n = 1,
    Map<String, int> feats = const {},
  }) => Ascent(
    n: n,
    fell: fell,
    floor: 5,
    floors: 33,
    difficulty: difficulty,
    pico: pico,
    style: style,
    deck: deck,
    feats: feats,
  );

  test('cada hito tiene un id distinto, su carácter y aliento', () {
    expect(hitos.map((h) => h.id).toSet(), hasLength(hitos.length));
    for (final h in hitos) {
      expect(h.hanzi, isNotEmpty);
      expect(h.breath, greaterThan(0));
    }
  });

  test('los tres caminos se cuentan entre subidas', () {
    final before = [
      ascent(fell: false, style: Style.tiger),
      ascent(fell: false, style: Style.snake),
    ];
    final got = earnedHitos(
      ascent(fell: false, style: Style.crane),
      before,
      {'first_climb', 'summit', 'win_tiger', 'win_snake'},
    );
    expect(got, containsAll(['win_crane', 'three_paths']));
    expect(got, isNot(contains('win_tiger')));
  });

  test('caer no cumple los hitos de ganar', () {
    final got = earnedHitos(
      ascent(style: Style.tiger, difficulty: Difficulty.shifu, pico: 10),
      const [],
      const {},
    );
    expect(got, ['first_climb']);
  });

  test('los contadores de la subida abren formas, desvíos y combates limpios', () {
    final got = earnedHitos(
      ascent(feats: {Feat.forms: 10, Feat.deflects: 20, Feat.flawless: 4}),
      const [],
      const {'first_climb'},
    );
    expect(got, ['forms_10', 'deflects_20']);
  });

  test('Shifu también cuenta como Difícil, y el Pico 10 abre los tres Picos', () {
    final got = earnedHitos(
      ascent(fell: false, difficulty: Difficulty.shifu, pico: 10, n: 10),
      const [],
      const {},
    );
    expect(
      got,
      containsAll([
        'win_hard',
        'win_shifu',
        'pico_1',
        'pico_5',
        'pico_10',
        'ten_disciples',
      ]),
    );
  });

  test('addFeats suma por clave', () {
    expect(
      addFeats({Feat.forms: 2}, {Feat.forms: 3, Feat.deflects: 1}),
      {Feat.forms: 5, Feat.deflects: 1},
    );
  });

  test('los élites de un reino se juntan entre subidas', () {
    final before = [
      ascent(feats: {Feat.beat('monk'): 1}),
      ascent(feats: {Feat.beat('lion'): 1}),
    ];
    expect(hitoBest('elites_0', before), (2, 3));
    final last = ascent(feats: {Feat.beat('fan'): 1});
    expect(earnedHitos(last, before, {'first_climb'}), ['elites_0']);
    expect(
      earnedHitos(last, const [], {'first_climb'}),
      isNot(contains('elites_0')),
    );
  });

  test('los despertares cuentan por camino; los talismanes, entre subidas', () {
    final tiger = [
      for (final id in ['hu_nu', 'hu_po', 'hu_yue'])
        ascent(style: Style.tiger, feats: {Feat.awakening(id): 1}),
    ];
    final snake = ascent(style: Style.snake, feats: {Feat.awakening('she_du'): 1});
    expect(hitoBest('awaken_path', [...tiger, snake]), (3, 4));
    expect(
      earnedHitos(snake, tiger, {'first_climb'}),
      isNot(contains('awaken_path')),
    );
    final fourth = ascent(style: Style.tiger, feats: {Feat.awakening('hu_shi'): 1});
    expect(earnedHitos(fourth, tiger, {'first_climb'}), ['awaken_path']);
    final got = earnedHitos(
      ascent(feats: {Feat.talismans: 6, Feat.bossTalisman: 1}),
      const [],
      {'first_climb'},
    );
    expect(got, ['talismans_6', 'talisman_boss']);
  });
}
