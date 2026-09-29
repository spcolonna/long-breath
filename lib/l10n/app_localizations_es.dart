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
  String get ageTitle => 'Edad (prueba)';

  @override
  String ageSummary(int draw, int breath, int retain) {
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
  String get dingbu => 'Dīngbù';

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
}
