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
}
