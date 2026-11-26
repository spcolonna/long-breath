import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/room.dart';
import 'combat_action.dart';
import 'combat_state.dart';

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

/// La carta se jugó desde la postura que pedía: cadena de postura.
class StanceChained extends CombatEvent {
  const StanceChained(this.cardId, this.from);
  final String cardId;
  final Stance from;
}

/// Encadenaste desde las tres posturas en un turno: el círculo se cierra.
class StanceCircle extends CombatEvent {
  const StanceCircle(this.breath, this.draw);
  final int breath;
  final int draw;
}

/// Por qué cambió el Flujo.
enum FlowCause { chain, deflect, form, hit, idle, counter, technique }

/// El Flujo cambió a [level] (ya acotado) por [cause].
class FlowChanged extends CombatEvent {
  const FlowChanged(this.level, this.delta, this.cause);
  final int level;
  final int delta;
  final FlowCause cause;
}

enum ChargeCause { deflect, form, held }

/// Respirar avanzó un paso de carga por [cause]: [progress] pasos hacia la
/// próxima y [charges] cargas listas ([ready] si se completó una).
class BreatheCharged extends CombatEvent {
  const BreatheCharged(this.progress, this.charges, this.cause, {this.ready = false});
  final int progress;
  final int charges;
  final ChargeCause cause;

  /// Se completó una carga nueva.
  final bool ready;
}

/// Se gastó una carga de Respirar en [mode].
class Breathed extends CombatEvent {
  const Breathed(this.mode);
  final BreatheMode mode;
}

/// El jugador recuperó [amount] de Estructura (Respirar).
class StructureRecovered extends CombatEvent {
  const StructureRecovered(this.amount);
  final int amount;
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

/// El arma actuó (al empezar o con su efecto: atravesar Guardia, etc.).
class WeaponTriggered extends CombatEvent {
  const WeaponTriggered();
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

/// Furia de la montaña: sus golpes suman [total] (no se calma).
class EnemyFurious extends CombatEvent {
  const EnemyFurious(this.total);
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

/// Con dos enemigos a la vez: actúa el de la posición [index] (lo que sigue
/// hasta el próximo [EnemyActing] es suyo).
class EnemyActing extends CombatEvent {
  const EnemyActing(this.index);
  final int index;
}

/// Cambió el enemigo apuntado (a mano, o porque cayó el anterior).
class TargetChanged extends CombatEvent {
  const TargetChanged(this.index);
  final int index;
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

/// Cayó un enemigo y queda otro en el grupo: el jugador elige un respiro.
class BreatherOffered extends CombatEvent {
  const BreatherOffered(this.options);
  final List<Breather> options;
}

class BreatherTaken extends CombatEvent {
  const BreatherTaken(this.breather);
  final Breather breather;
}

/// Un desvío dejó listo el Contragolpe para el próximo turno propio.
class CounterReady extends CombatEvent {
  const CounterReady();
}

/// Se usó el Contragolpe en el modo [mode].
class Countered extends CombatEvent {
  const Countered(this.mode);
  final CounterMode mode;
}

/// Se usó la Técnica del Camino de [style] (el Flujo ya bajó a 0).
class TechniqueUsed extends CombatEvent {
  const TechniqueUsed(this.style);
  final Style style;
}

/// El rival [index] cambió de intención: reacciona a [reaction].
class EnemyReacted extends CombatEvent {
  const EnemyReacted(this.index, this.reaction);
  final int index;
  final Reaction reaction;
}

/// El protector [from] le dio [amount] de Guardia a [to].
class EnemyShielded extends CombatEvent {
  const EnemyShielded(this.from, this.to, this.amount);
  final int from;
  final int to;
  final int amount;
}

/// El sanador [from] le curó [amount] de Vida a [to].
class EnemyHealedAlly extends CombatEvent {
  const EnemyHealedAlly(this.from, this.to, this.amount);
  final int from;
  final int to;
  final int amount;
}

/// Repicó la campana: te quitó [taken] (tras tu Guardia) y a cada rival
/// [damage].
class BellTolled extends CombatEvent {
  const BellTolled(this.taken, this.damage);
  final int taken;
  final int damage;
}

/// Se cumplió el reto de la pelea.
class ChallengeMet extends CombatEvent {
  const ChallengeMet(this.challenge);
  final Challenge challenge;
}

/// El reto ya no se puede cumplir.
class ChallengeFailed extends CombatEvent {
  const ChallengeFailed(this.challenge);
  final Challenge challenge;
}
