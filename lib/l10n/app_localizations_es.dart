// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitle => 'Long Breath';

  @override
  String get newRun => 'Nueva run';

  @override
  String get continueRun => 'Continuar run';

  @override
  String get styleTitle => 'Elegí tu camino';

  @override
  String get homeTagline =>
      'Subís como novicio. El camino se elige en la montaña.';

  @override
  String get shrineNode => 'Santuario';

  @override
  String get shrineTitle => 'Santuario de los animales';

  @override
  String get shrineHint =>
      'Dos espíritus te esperan. El camino que tomes tiñe tu túnica y cambia cómo peleás, hasta el final de la subida.';

  @override
  String get shrineConfirm => 'Tomar este camino';

  @override
  String styleSummary(int draw, int breath, int retain) {
    return 'Robás $draw · Aliento $breath · Retenés $retain';
  }

  @override
  String get life => 'Vida';

  @override
  String get structure => 'Estructura';

  @override
  String get guard => 'Guardia';

  @override
  String get breath => 'Aliento';

  @override
  String get deck => 'Mazo';

  @override
  String deckCount(int count) {
    return 'Mazo: $count';
  }

  @override
  String get fountain => 'Fuente de meditación';

  @override
  String fountainHeal(int amount) {
    return 'Curar $amount de Vida';
  }

  @override
  String get fountainRemove => 'Eliminar 1 carta del mazo';

  @override
  String fountainUpgrade(int amount) {
    return 'Mejorar 1 carta (+$amount)';
  }

  @override
  String get chooseCard => 'Elegí una carta';

  @override
  String get rewardTitle => 'Recompensa';

  @override
  String get rewardHint =>
      'Elegí 1 carta o salteá. Un mazo chico es más predecible.';

  @override
  String get skip => 'Saltear';

  @override
  String get breathe => 'Respirar';

  @override
  String get endTurn => 'Terminar turno';

  @override
  String get confirm => 'Confirmar';

  @override
  String get cancel => 'Cancelar';

  @override
  String retainHint(int count) {
    return 'Tocá hasta $count carta(s) para retener';
  }

  @override
  String get discardHint => 'Chillido: elegí 1 carta para descartar';

  @override
  String get tapAgain => 'Tocá de nuevo para jugar';

  @override
  String get victory => 'Victoria';

  @override
  String get defeat => 'Derrota';

  @override
  String get continueLabel => 'Continuar';

  @override
  String get runWon => 'Llegaste a la cumbre';

  @override
  String get runLost => 'Caíste en la montaña';

  @override
  String get tryAgain => 'Empezar de nuevo';

  @override
  String get backHome => 'Volver al inicio';

  @override
  String get staggered => 'Desequilibrado';

  @override
  String get losesAction => 'Pierde su acción';

  @override
  String get deflect => '¡Desvío!';

  @override
  String get broken => '¡Desequilibrio!';

  @override
  String get playerBroken => 'Estructura rota';

  @override
  String turn(int n) {
    return 'Turno $n';
  }

  @override
  String get abandon => 'Abandonar run';

  @override
  String get typeFist => 'Puño';

  @override
  String get typePalm => 'Palma';

  @override
  String get typeKick => 'Patada';

  @override
  String get typeDefense => 'Defensa';

  @override
  String get typeTechnique => 'Técnica';

  @override
  String get heightHigh => 'alto';

  @override
  String get heightMid => 'medio';

  @override
  String get heightLow => 'bajo';

  @override
  String get rankElite => 'Élite';

  @override
  String get rankBoss => 'Guardián';

  @override
  String get fountainNode => 'Fuente';

  @override
  String intentAttack(String height) {
    return 'Ataque $height';
  }

  @override
  String intentNamedAttack(String name, String height) {
    return '$name ($height)';
  }

  @override
  String get intentCharge => 'Carga';

  @override
  String intentChargeDetail(int n) {
    return 'Próximo ataque +$n';
  }

  @override
  String get intentDiscard => 'Descarte';

  @override
  String intentDiscardDetail(int n) {
    return 'Descartás $n';
  }

  @override
  String get intentInterrupt => 'Interrumpe tus formas si no lo desviás';

  @override
  String get intentSameStance => 'Si terminás en esta postura: +4 daño, +2 E';

  @override
  String get countdown => 'turnos';

  @override
  String get staggeredDouble => 'Desequilibrado · daño ×2';

  @override
  String previewDamage(int n) {
    return '$n daño';
  }

  @override
  String previewStructure(int n) {
    return '$n E';
  }

  @override
  String previewCompletes(String name) {
    return '¡completa $name!';
  }

  @override
  String previewAdvances(String name) {
    return 'avanza $name';
  }

  @override
  String previewInterrupts(String name) {
    return '⚠ interrumpe $name';
  }

  @override
  String get stanceHintMabu =>
      'Puños y palmas +2 · E recibida ½ · patadas +1 costo';

  @override
  String get stanceHintGongbu => 'Puños +3 daño y +1 E · recibís +2 E';

  @override
  String get stanceHintXubu =>
      'Patadas −1 costo y +2 · desvío +1 Aliento · defensas −2';

  @override
  String changeStance(String breath) {
    return 'Cambiar postura · 1 $breath';
  }

  @override
  String get formsInterrupted => 'Formas interrumpidas';

  @override
  String get enemyPhase2 => '¡Segunda fase!';

  @override
  String get formCompleted => '¡Forma completa!';

  @override
  String effStance(String name) {
    return 'Pasás a $name';
  }

  @override
  String effDraw(int n) {
    return 'Robás $n';
  }

  @override
  String effBreath(int n) {
    return '+$n Aliento';
  }

  @override
  String effBonusStaggered(int n) {
    return '+$n si el enemigo está Desequilibrado';
  }

  @override
  String effDeflectDamage(int n) {
    return 'Si desviás, $n de daño';
  }

  @override
  String effDeflectStructure(int n) {
    return 'Si desviás, el enemigo pierde $n E extra';
  }

  @override
  String effStanceStructure(String name, int n) {
    return 'En $name, +$n E';
  }

  @override
  String get effClearGuard => 'Perdés toda tu Guardia';

  @override
  String effTurnStructure(int n) {
    return 'Este turno, todo daño a Estructura +$n';
  }

  @override
  String get effFirstTurn => 'Solo en el primer turno';

  @override
  String get effExhaust => 'Agotar';

  @override
  String get invalidCombatOver => 'El combate terminó';

  @override
  String get invalidMustDiscard => 'Elegí una carta para descartar';

  @override
  String get invalidNotInHand => 'La carta no está en la mano';

  @override
  String get invalidFirstTurnOnly => 'Solo en el primer turno';

  @override
  String get invalidNoBreath => 'Aliento insuficiente';

  @override
  String get invalidDingbuUsed => 'Ya cambiaste de postura este turno';

  @override
  String get invalidSameStance => 'Ya estás en esa postura';

  @override
  String get invalidBreatheUsed => 'Ya respiraste en este combate';

  @override
  String get invalidRetainTooMany => 'Retenés demasiadas cartas';

  @override
  String get invalidNoDiscard => 'No hay que descartar';

  @override
  String get partOfForm => 'Parte de una forma';

  @override
  String get tutStart => 'Empezar entrenamiento';

  @override
  String get tutSkipToRun => 'Ya sé jugar: nueva run';

  @override
  String get tutReplay => 'Repetir entrenamiento';

  @override
  String get tutSkip => 'Saltear';

  @override
  String get tutNext => 'Siguiente';

  @override
  String get tutMaster => 'Maestro';

  @override
  String get tutGo => '¡Vamos!';

  @override
  String get tutClimb => 'Empezar la subida';

  @override
  String get tutHome => 'Volver al inicio';

  @override
  String get tutWelcome =>
      'Bienvenido al patio de la escuela del Dragón Dormido. Antes de subir la montaña vas a practicar con el muñeco de madera. Yo te guío.';

  @override
  String get tutIntent =>
      'Este globo es lo que el muñeco va a hacer en su turno: un golpe ALTO (flecha arriba) de 4 de daño y 2 a tu Estructura (E). El enemigo siempre avisa antes de actuar.';

  @override
  String get tutEnemy =>
      'Su Vida (roja) y su Estructura (violeta). Llevá la Vida a 0 para ganar. Si le vaciás la Estructura, queda Desequilibrado: pierde su acción y recibe el doble de daño.';

  @override
  String get tutPlayer =>
      'Este sos vos: tu Vida, tu Estructura, tu postura actual (Caballo) y tu Guardia, el escudo de la derecha.';

  @override
  String get tutHand =>
      'Tu mano. El número de arriba a la izquierda de cada carta es su costo en Aliento. Tenés 3 por turno y lo que no gastes se pierde.';

  @override
  String get tutPlayFist =>
      'Tocá Puño en arco una vez para ver qué hace y otra vez para jugarla.';

  @override
  String get tutStance =>
      'La carta te llevó a la postura Arco antes de pegar, y en Arco los puños hacen +3. Cada postura tiene ventajas y costos.';

  @override
  String get tutDefend =>
      'Ahora defendete. El muñeco va a pegar ALTO y Mostrar la palma da Guardia alta. Si la altura coincide y la Guardia alcanza, desviás el golpe. Jugala con dos toques.';

  @override
  String get tutKick =>
      'Quedaste en postura Vacía, donde las patadas cuestan 1 menos: Patada de latigazo ahora es gratis. Jugala.';

  @override
  String get tutForms =>
      'Puño en arco y Patada de latigazo son los dos primeros pasos del Pequeño Puño Rojo. Si completás una forma en orden, se desata un golpe grande. Las defensas no la interrumpen.';

  @override
  String get tutEndTurn =>
      'Tu Guardia está lista. Terminá el turno y mirá qué pasa.';

  @override
  String get tutDeflect =>
      '¡Desvío! No recibiste daño, el muñeco perdió Estructura y quedó Desequilibrado: pierde su acción y recibe el doble. Además, el desvío te da Aliento extra para este turno.';

  @override
  String get tutActions =>
      'Dos ayudas: Paso en T te cambia de postura por 1 de Aliento, una vez por turno. Respirar cambia toda tu mano, una vez por combate.';

  @override
  String get tutFree =>
      'Ahora rematalo vos. Mientras esté Desequilibrado, cada golpe cuenta doble.';

  @override
  String get tutDone =>
      '¡Bien hecho! En la montaña, después de cada combate sumás una carta a tu mazo. La Vida no se recupera sola, solo en la fuente. A mitad de camino, el Santuario te ofrece dos caminos. Y mirá siempre el globo antes de jugar.';
}
