import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/run/ascent.dart';

void main() {
  Ascent ascent({
    required bool fell,
    int stage = 0,
    String? enemy,
    Style style = Style.tiger,
  }) => Ascent(
    n: 1,
    fell: fell,
    floor: 1,
    floors: 33,
    difficulty: Difficulty.normal,
    stage: stage,
    enemy: enemy,
    style: style,
  );

  test('llegar a la cumbre abre el epílogo después de la cumbre', () {
    final lore = earnedLore(ascent(fell: false, stage: 2), const [], const {});
    expect(lore.indexOf('epilogue'), lore.indexOf('summit') + 1);
    expect(loreOrder.indexOf('epilogue'), loreOrder.indexOf('summit') + 1);
  });

  test('caer en el monasterio y en la nieve abre sus secretos', () {
    expect(
      earnedLore(ascent(fell: true, stage: 1, enemy: 'bell_keeper'), const [], const {}),
      containsAll(['fell_bell_keeper', 'monastery_beams']),
    );
    expect(
      earnedLore(ascent(fell: true, stage: 2, enemy: 'wind_lady'), const [], const {}),
      containsAll(['fell_wind_lady', 'snow_footprints']),
    );
  });

  test('cada camino tiene su final al llegar a la cumbre', () {
    final won = ascent(fell: false, stage: 2, style: Style.snake);
    expect(earnedLore(won, const [], const {}), contains('ending_snake'));
    expect(earnedLore(won, const [], const {}), isNot(contains('ending_tiger')));
    expect(
      earnedLore(ascent(fell: true, stage: 2), const [], const {}),
      isNot(contains('ending_tiger')),
    );
  });

  test('el maestro cuenta su nombre al tener los tres finales', () {
    final won = ascent(fell: false, stage: 2, style: Style.crane);
    expect(
      earnedLore(won, const [], const {'ending_tiger'}),
      isNot(contains('master_name')),
    );
    final lore = earnedLore(won, const [], const {
      'ending_tiger',
      'ending_snake',
    });
    expect(lore, containsAll(['ending_crane', 'master_name']));
    expect(lore.last, 'master_name');
  });

  test('todos los pergaminos tienen su texto', () {
    expect(loreOrder.toSet(), hasLength(loreOrder.length));
  });
}
