import '../model/enums.dart';
import 'combat_state.dart';

sealed class CombatAction {
  const CombatAction();
}

class PlayCard extends CombatAction {
  const PlayCard(this.uid);
  final int uid;
}

/// Apuntar a otro enemigo cuando hay dos en escena (no cuesta nada).
class Target extends CombatAction {
  const Target(this.index);
  final int index;
}

class Dingbu extends CombatAction {
  const Dingbu(this.stance);
  final Stance stance;
}

/// Cómo se gasta una carga de Respirar.
enum BreatheMode {
  /// Descartás la mano y robás la misma cantidad (mínimo 3). Cuesta Aliento.
  hand,

  /// Recuperás Aliento.
  breath,

  /// Recuperás Estructura.
  structure,
}

/// Respirar: gasta una carga y hace lo que dice [mode].
class Breathe extends CombatAction {
  const Breathe([this.mode = BreatheMode.hand]);
  final BreatheMode mode;
}

/// Terminar turno reteniendo las cartas indicadas (hasta el máximo por edad).
class EndTurn extends CombatAction {
  const EndTurn({this.retain = const []});
  final List<int> retain;
}

/// Descartar una carta de la mano (Chillido del Murciélago).
class ChooseDiscard extends CombatAction {
  const ChooseDiscard(this.uid);
  final int uid;
}

/// Elegir el respiro entre una oleada y la siguiente.
class ChooseBreather extends CombatAction {
  const ChooseBreather(this.breather);
  final Breather breather;
}
