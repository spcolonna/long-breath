import '../model/enums.dart';

/// Eventos que produce el motor para que la interfaz anime.
sealed class CombatEvent {
  const CombatEvent();
}

class TurnStarted extends CombatEvent {
  const TurnStarted(this.turn, this.breath);
  final int turn;
  final int breath;
}

class CardsDrawn extends CombatEvent {
  const CardsDrawn(this.count);
  final int count;
}

class DeckShuffled extends CombatEvent {
  const DeckShuffled();
}

class CardPlayed extends CombatEvent {
  const CardPlayed(this.cardId);
  final String cardId;
}

class StanceChanged extends CombatEvent {
  const StanceChanged(this.stance);
  final Stance stance;
}

class GuardGained extends CombatEvent {
  const GuardGained(this.amount, this.height);
  final int amount;
  final Height? height;
}

class EnemyDamaged extends CombatEvent {
  const EnemyDamaged(this.damage, this.structure, {this.absorbed = 0});
  final int damage;
  final int structure;
  final int absorbed;
}

class EnemyBroken extends CombatEvent {
  const EnemyBroken();
}

/// El enemigo perdió una escama al desequilibrarse; quedan [remaining].
class ScaleShed extends CombatEvent {
  const ScaleShed(this.remaining);
  final int remaining;
}

class EnemyRecovered extends CombatEvent {
  const EnemyRecovered();
}

class EnemyActionSkipped extends CombatEvent {
  const EnemyActionSkipped();
}

class EnemyGuarded extends CombatEvent {
  const EnemyGuarded(this.amount);
  final int amount;
}

class EnemyCharged extends CombatEvent {
  const EnemyCharged(this.amount);
  final int amount;
}

class EnemyPhaseChanged extends CombatEvent {
  const EnemyPhaseChanged(this.phase);
  final int phase;
}

class PlayerHit extends CombatEvent {
  const PlayerHit(this.damage, this.structure, {required this.blocked});
  final int damage;
  final int structure;
  final bool blocked;
}

class Deflected extends CombatEvent {
  const Deflected();
}

class PlayerBroken extends CombatEvent {
  const PlayerBroken();
}

class FormAdvanced extends CombatEvent {
  const FormAdvanced(this.formId, this.progress);
  final String formId;
  final int progress;
}

class FormInterrupted extends CombatEvent {
  const FormInterrupted(this.formId);
  final String formId;
}

class FormCompleted extends CombatEvent {
  const FormCompleted(this.formId);
  final String formId;
}

class FormsResetByEnemy extends CombatEvent {
  const FormsResetByEnemy();
}

class DiscardRequired extends CombatEvent {
  const DiscardRequired(this.count);
  final int count;
}

class Victory extends CombatEvent {
  const Victory();
}

class Defeat extends CombatEvent {
  const Defeat();
}
