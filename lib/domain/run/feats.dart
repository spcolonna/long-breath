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
}

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

/// Los hitos, en el orden en que se muestran.
final hitos = <HitoDef>[
  HitoDef('first_climb', '初', 10, (a, _) => true),
  HitoDef('reach_monastery', '寺', 15, (a, _) => a.stage >= 1),
  HitoDef('reach_peak', '顶', 20, (a, _) => a.stage >= 2),
  HitoDef('summit', '胜', 30, (a, _) => _won(a)),
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
