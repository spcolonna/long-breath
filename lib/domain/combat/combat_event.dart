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

/// El enemigo se volvió a cubrir de escamas al cambiar de fase.
class ScalesRegrown extends CombatEvent {
  const ScalesRegrown(this.scales);
  final int scales;
}

class EnemyRecovered extends CombatEvent {
  const EnemyRecovered();
}

class EnemyActionSkipped extends CombatEvent {
  const EnemyActionSkipped();
}

class EnemyGuarded extends CombatEvent {
  const EnemyGuarded(this.amount, [this.blocks]);
  final int amount;

  /// Tipo de golpe que frena (null = todos).
  final CardType? blocks;
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

/// Efectos de forma sobre el jugador.
class BreathGained extends CombatEvent {
  const BreathGained(this.amount);
  final int amount;
}

class PlayerHealed extends CombatEvent {
  const PlayerHealed(this.amount);
  final int amount;
}

class FistBonusGained extends CombatEvent {
  const FistBonusGained(this.amount, this.total);
  final int amount;
  final int total;
}

/// Un talismán actuó (al empezar, en un desvío, al completar una forma…).
class TalismanTriggered extends CombatEvent {
  const TalismanTriggered(this.talismanId);
  final String talismanId;
}

class FormsResetByEnemy extends CombatEvent {
  const FormsResetByEnemy();
}

class DiscardRequired extends CombatEvent {
  const DiscardRequired(this.count);
  final int count;
}

/// Abanico: desvió tu golpe y te devolvió [damage].
class Parried extends CombatEvent {
  const Parried(this.damage);
  final int damage;
}

/// El enemigo despertó un poco más: sus golpes suman [total].
class EnemyEnraged extends CombatEvent {
  const EnemyEnraged(this.total);
  final int total;
}

/// Al desequilibrarlo, se le pasó el enojo.
class WrathCalmed extends CombatEvent {
  const WrathCalmed();
}

/// Te robó [amount] de jade ([total] en este combate).
class JadeStolen extends CombatEvent {
  const JadeStolen(this.amount, this.total);
  final int amount;
  final int total;
}

/// Se escapó con [stolen] de jade. El combate termina.
class EnemyFled extends CombatEvent {
  const EnemyFled(this.stolen);
  final int stolen;
}

/// Cayó un enemigo del grupo y todavía quedan otros esperando.
class EnemyDefeated extends CombatEvent {
  const EnemyDefeated(this.enemyId);
  final String enemyId;
}

/// Entra el siguiente enemigo del grupo ([index] de [total], desde 1).
class WaveStarted extends CombatEvent {
  const WaveStarted(this.enemyId, this.index, this.total);
  final String enemyId;
  final int index;
  final int total;
}

class Victory extends CombatEvent {
  const Victory();
}

class Defeat extends CombatEvent {
  const Defeat();
}

/// Espinas: te lastimaste al golpearlo.
class ThornsHurt extends CombatEvent {
  const ThornsHurt(this.damage);
  final int damage;
}

/// Recuperó Vida antes de actuar.
class EnemyRegenerated extends CombatEvent {
  const EnemyRegenerated(this.amount);
  final int amount;
}

/// El próximo turno tenés [amount] menos de Aliento.
class BreathDrained extends CombatEvent {
  const BreathDrained(this.amount);
  final int amount;
}

/// El próximo turno robás [amount] cartas menos.
class HandFrozen extends CombatEvent {
  const HandFrozen(this.amount);
  final int amount;
}

/// El golpe era de otro tipo y esquivó su Guardia.
class GuardBypassed extends CombatEvent {
  const GuardBypassed();
}
