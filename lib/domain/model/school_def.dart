import 'meta_bonus.dart';

/// Un nivel de un edificio: cuánto jade cuesta restaurarlo y qué suma a cada
/// subida (además de lo que dieron los niveles anteriores).
class SchoolLevel {
  const SchoolLevel({required this.cost, required this.effect});

  final int cost;
  final MetaBonus effect;

  factory SchoolLevel.fromJson(Map<String, dynamic> j) => SchoolLevel(
        cost: j['cost'] as int,
        effect: MetaBonus.fromJson(
          (j['effect'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );
}

/// Un edificio de la escuela (forja, casa de té…): se restaura nivel por
/// nivel con el jade que sobra de las subidas.
class SchoolBuilding {
  const SchoolBuilding({required this.id, required this.levels});

  final String id;
  final List<SchoolLevel> levels;

  int get maxLevel => levels.length;

  factory SchoolBuilding.fromJson(Map<String, dynamic> j) => SchoolBuilding(
        id: j['id'] as String,
        levels: [
          for (final l in j['levels'] as List)
            SchoolLevel.fromJson(l as Map<String, dynamic>),
        ],
      );
}

/// El monasterio en ruinas que se restaura con jade (fase 2 del rediseño).
/// El jade que sobra de cada subida va al tesoro de la escuela.
class SchoolDef {
  const SchoolDef({this.buildings = const []});

  static const none = SchoolDef();

  final List<SchoolBuilding> buildings;

  bool get isEmpty => buildings.isEmpty;

  SchoolBuilding? building(String id) {
    for (final b in buildings) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Nivel de [id] según [levels] (lo que guarda la partida), sin pasarse.
  int levelOf(String id, Map<String, int> levels) {
    final b = building(id);
    if (b == null) return 0;
    return (levels[id] ?? 0).clamp(0, b.maxLevel);
  }

  /// El próximo nivel de [id], o null si ya está restaurado del todo.
  SchoolLevel? nextLevel(String id, Map<String, int> levels) {
    final b = building(id);
    if (b == null) return null;
    final at = levelOf(id, levels);
    return at < b.maxLevel ? b.levels[at] : null;
  }

  /// Todo lo que dan los edificios restaurados.
  MetaBonus bonusOf(Map<String, int> levels) {
    var bonus = MetaBonus.none;
    for (final b in buildings) {
      for (final l in b.levels.take(levelOf(b.id, levels))) {
        bonus = bonus + l.effect;
      }
    }
    return bonus;
  }

  /// Niveles restaurados en total, sobre [maxLevels].
  int restored(Map<String, int> levels) =>
      buildings.fold(0, (s, b) => s + levelOf(b.id, levels));

  int get maxLevels => buildings.fold(0, (s, b) => s + b.maxLevel);

  factory SchoolDef.fromJson(Map<String, dynamic> j) => SchoolDef(
        buildings: [
          for (final b in (j['buildings'] as List?) ?? const [])
            SchoolBuilding.fromJson(b as Map<String, dynamic>),
        ],
      );
}
