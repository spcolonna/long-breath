import '../model/cultivation_def.dart';
import 'ascent.dart';

/// Aliento que deja una subida terminada.
int ascentBreath(CultivationDef c, Ascent a) => c.breathFor(
  fell: a.fell,
  floor: a.floor,
  stage: a.stage,
  diff: a.difficulty,
  pico: a.pico,
);

/// Dónde está la escuela en el cultivo: aliento acumulado y reino.
class Cultivation {
  const Cultivation(this.def, this.breath);

  final CultivationDef def;
  final int breath;

  /// Índice del reino actual (0 = el primero).
  int get realm => def.realmOf(breath);

  /// Sin reinos definidos no hay nada que mostrar ni cerrar.
  bool get active => def.realms.isNotEmpty;

  bool get isMax => realm >= def.realms.length - 1;

  /// Progreso hacia el reino siguiente (0..1; 1 en el último).
  double get progress {
    if (!active || isMax) return 1;
    final from = def.realms[realm].breath;
    final to = def.realms[realm + 1].breath;
    return ((breath - from) / (to - from)).clamp(0, 1).toDouble();
  }

  /// Lo que sigue cerrado para la próxima subida.
  List<String> get locked => def.lockedAt(realm);
}
