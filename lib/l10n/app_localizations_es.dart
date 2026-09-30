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
}
