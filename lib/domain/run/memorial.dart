import 'ascent.dart';
import 'ghost.dart';

/// La tablilla del último discípulo caído: en qué etapa y en qué fila
/// cayó, y ante quién. En la subida siguiente queda en esa fila del mapa
/// y, si se puede, su rival espera ahí para la revancha.
class Memorial {
  const Memorial({
    required this.n,
    required this.stage,
    required this.depth,
    this.enemy,
  });

  /// Número del discípulo caído.
  final int n;
  final int stage;

  /// Fila de la etapa (0 = la primera).
  final int depth;

  /// El rival que lo venció (null si no se sabe).
  final String? enemy;

  /// El rival de la revancha: no hay revancha contra otro caído.
  String? get foe => enemy == null || isGhostFoe(enemy!) ? null : enemy;

  Map<String, dynamic> toJson() => {
    'n': n,
    'stage': stage,
    'depth': depth,
    if (enemy != null) 'enemy': enemy,
  };

  factory Memorial.fromJson(Map<String, dynamic> j) => Memorial(
    n: j['n'] as int,
    stage: j['stage'] as int? ?? 0,
    depth: j['depth'] as int? ?? 0,
    enemy: j['enemy'] as String?,
  );
}

/// La tablilla del caído más reciente del registro. [floors]: salas de
/// cada etapa (el registro cuenta el piso en toda la subida). Null si el
/// último en subir no cayó o nadie subió todavía.
Memorial? memorialFrom(List<Ascent> ascents, List<int> floors) {
  if (ascents.isEmpty || !ascents.last.fell) return null;
  final a = ascents.last;
  if (a.stage < 0 || a.stage >= floors.length) return null;
  final below = floors.take(a.stage).fold(0, (s, f) => s + f);
  final depth = a.floor - below - 1;
  if (depth < 0 || depth >= floors[a.stage]) return null;
  return Memorial(n: a.n, stage: a.stage, depth: depth, enemy: a.enemy);
}
