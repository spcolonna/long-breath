import 'dart:math' as math;

import '../model/enums.dart';
import 'ascent.dart';

/// Contadores que la subida junta para los hitos (`RunState.feats`).
abstract final class Feat {
  /// Formas completadas.
  static const forms = 'forms';

  /// Golpes desviados.
  static const deflects = 'deflects';

  /// Combates ganados sin perder Vida.
  static const flawless = 'flawless';

  /// Jefes vencidos sin perder Vida.
  static const flawlessBoss = 'flawless_boss';

  /// Talismanes que se llevaban al terminar.
  static const talismans = 'talismans';

  /// Si se llevaba un talismán de jefe al terminar.
  static const bossTalisman = 'boss_talisman';

  /// Élite o jefe [id] vencido en la subida.
  static String beat(String id) => 'beat.$id';

  /// Despertar [id] elegido en la subida.
  static String awakening(String id) => 'awk.$id';

  /// Talismán [id] que se llevaba al terminar.
  static String talisman(String id) => 'tal.$id';
}

/// Los élites de cada reino, en orden de etapa (ver `game_balance.json`).
const stageElites = [
  ['monk', 'lion', 'fan'],
  [
    'iron_abbot',
    'jade_lion',
    'bell_keeper',
    'dragon_reflection',
    'celadon_lion',
    'nine_tail_fox',
  ],
  ['wind_lady', 'snow_lion', 'dragon_dream', 'qilin'],
];

/// Despertares de cada camino y talismanes que hay en total.
const awakeningsPerPath = 4;
const talismanCount = 23;

Map<String, int> addFeats(Map<String, int> a, Map<String, int> b) => {
  ...a,
  for (final e in b.entries)
    if (e.value != 0) e.key: (a[e.key] ?? 0) + e.value,
};

/// Un hito 功 de la escuela: se cumple una sola vez por partida y deja
/// [breath] de aliento extra.
class HitoDef {
  const HitoDef(this.id, this.hanzi, this.breath, this.reached);

  final String id;
  final String hanzi;
  final int breath;

  /// Si la subida [a] lo cumple, dadas las anteriores.
  final bool Function(Ascent a, List<Ascent> before) reached;
}

bool _won(Ascent a) => !a.fell;

bool _wonWith(Ascent a, List<Ascent> before, Style s) =>
    [...before, a].any((x) => _won(x) && x.style == s);

int _feat(Ascent a, String k) => a.feats[k] ?? 0;

/// Claves de contador con [prefix] que aparecen en alguna subida.
Set<String> _seen(Iterable<Ascent> all, String prefix) => {
  for (final x in all)
    for (final k in x.feats.keys)
      if (k.startsWith(prefix)) k,
};

/// Élites del reino [stage] vencidos en todas las subidas.
int _elitesBeaten(Iterable<Ascent> all, int stage) {
  final seen = _seen(all, 'beat.');
  return stageElites[stage].where((e) => seen.contains(Feat.beat(e))).length;
}

/// Lo más que se conoce de los despertares de un solo camino.
int _bestPathAwakenings(Iterable<Ascent> all) => Style.values.fold(
  0,
  (m, s) => math.max(m, _seen(all.where((x) => x.style == s), 'awk.').length),
);

HitoDef _elites(String id, String hanzi, int breath, int stage) => HitoDef(
  id,
  hanzi,
  breath,
  (a, b) => _elitesBeaten([...b, a], stage) == stageElites[stage].length,
);

/// Los hitos, en el orden en que se muestran.
final hitos = <HitoDef>[
  HitoDef('first_climb', '初', 10, (a, _) => true),
  HitoDef('reach_monastery', '寺', 15, (a, _) => a.stage >= 1),
  HitoDef('reach_peak', '顶', 20, (a, _) => a.stage >= 2),
  HitoDef('summit', '胜', 30, (a, _) => _won(a)),
  _elites('elites_0', '狮', 15, 0),
  _elites('elites_1', '钟', 20, 1),
  _elites('elites_2', '麟', 25, 2),
  HitoDef('flawless_boss', '镇', 25, (a, _) => _feat(a, Feat.flawlessBoss) > 0),
  HitoDef('win_tiger', '虎', 25, (a, b) => _wonWith(a, b, Style.tiger)),
  HitoDef('win_snake', '蛇', 25, (a, b) => _wonWith(a, b, Style.snake)),
  HitoDef('win_crane', '鹤', 25, (a, b) => _wonWith(a, b, Style.crane)),
  HitoDef(
    'three_paths',
    '三',
    40,
    (a, b) => Style.values.every((s) => _wonWith(a, b, s)),
  ),
  HitoDef(
    'win_hard',
    '难',
    30,
    (a, _) => _won(a) && a.difficulty.index >= Difficulty.hard.index,
  ),
  HitoDef(
    'win_shifu',
    '师',
    50,
    (a, _) => _won(a) && a.difficulty == Difficulty.shifu,
  ),
  HitoDef('pico_1', '峰', 25, (a, _) => _won(a) && a.pico >= 1),
  HitoDef('pico_5', '岳', 40, (a, _) => _won(a) && a.pico >= 5),
  HitoDef('pico_10', '巅', 60, (a, _) => _won(a) && a.pico >= 10),
  HitoDef('forms_10', '形', 15, (a, _) => _feat(a, Feat.forms) >= 10),
  HitoDef('deflects_20', '卸', 15, (a, _) => _feat(a, Feat.deflects) >= 20),
  HitoDef('flawless_5', '净', 20, (a, _) => _feat(a, Feat.flawless) >= 5),
  HitoDef(
    'awaken_path',
    '醒',
    20,
    (a, b) => _bestPathAwakenings([...b, a]) >= awakeningsPerPath,
  ),
  HitoDef(
    'awaken_all',
    '觉',
    40,
    (a, b) =>
        _seen([...b, a], 'awk.').length >=
        awakeningsPerPath * Style.values.length,
  ),
  HitoDef('talismans_6', '符', 15, (a, _) => _feat(a, Feat.talismans) >= 6),
  HitoDef('talisman_boss', '印', 20, (a, _) => _feat(a, Feat.bossTalisman) > 0),
  HitoDef(
    'talismans_all',
    '宝',
    40,
    (a, b) => _seen([...b, a], 'tal.').length >= talismanCount,
  ),
  HitoDef('light_deck', '简', 30, (a, _) => _won(a) && a.deck <= 16),
  HitoDef('ten_disciples', '十', 20, (a, _) => a.n >= 10),
];

HitoDef hito(String id) => hitos.firstWhere((h) => h.id == id);

/// Qué hitos cumple una subida, sin contar los que ya se tenían.
List<String> earnedHitos(Ascent a, List<Ascent> before, Set<String> have) => [
  for (final h in hitos)
    if (!have.contains(h.id) && h.reached(a, before)) h.id,
];

/// Aliento extra que dejan [ids].
int hitoBreath(Iterable<String> ids) =>
    ids.fold(0, (s, id) => s + hito(id).breath);

/// Hitos que una partida de [difficulty] no puede cumplir (la dificultad
/// es de la partida; el Pico solo existe en Normal).
bool _outOfReach(HitoDef h, Difficulty difficulty) => switch (h.id) {
  'win_hard' => difficulty.index < Difficulty.hard.index,
  'win_shifu' => difficulty != Difficulty.shifu,
  'pico_1' || 'pico_5' || 'pico_10' => difficulty != Difficulty.normal,
  _ => false,
};

/// El próximo hito para mostrar en la escuela: el primero sin cumplir que
/// la partida puede alcanzar (null si ya están todos).
HitoDef? nextHito(Set<String> have, Difficulty difficulty) {
  for (final h in hitos) {
    if (!have.contains(h.id) && !_outOfReach(h, difficulty)) return h;
  }
  return null;
}

/// En los hitos de contador, lo mejor que se llegó y cuánto piden.
(int, int)? hitoBest(String id, List<Ascent> ascents) {
  int best(int Function(Ascent) f) =>
      ascents.fold(0, (m, a) => math.max(m, f(a)));
  return switch (id) {
    'forms_10' => (best((a) => _feat(a, Feat.forms)), 10),
    'deflects_20' => (best((a) => _feat(a, Feat.deflects)), 20),
    'flawless_5' => (best((a) => _feat(a, Feat.flawless)), 5),
    'ten_disciples' => (best((a) => a.n), 10),
    'elites_0' => (_elitesBeaten(ascents, 0), stageElites[0].length),
    'elites_1' => (_elitesBeaten(ascents, 1), stageElites[1].length),
    'elites_2' => (_elitesBeaten(ascents, 2), stageElites[2].length),
    'awaken_path' => (_bestPathAwakenings(ascents), awakeningsPerPath),
    'awaken_all' => (
      _seen(ascents, 'awk.').length,
      awakeningsPerPath * Style.values.length,
    ),
    'talismans_6' => (best((a) => _feat(a, Feat.talismans)), 6),
    'talismans_all' => (_seen(ascents, 'tal.').length, talismanCount),
    _ => null,
  };
}
