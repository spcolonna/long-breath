import '../model/enums.dart';

sealed class CombatAction {
  const CombatAction();
}

class PlayCard extends CombatAction {
  const PlayCard(this.uid);
  final int uid;
}

class Dingbu extends CombatAction {
  const Dingbu(this.stance);
  final Stance stance;
}

/// Respirar: descartás la mano y robás la misma cantidad.
class Breathe extends CombatAction {
  const Breathe();
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
