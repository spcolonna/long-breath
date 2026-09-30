import '../../l10n/app_localizations.dart';

/// Un paso del entrenamiento. Si espera una jugada ([waitCard] o [waitTurn]),
/// solo se puede tocar la zona resaltada; si no, se avanza con el botón.
class TutorialStep {
  const TutorialStep(this.text, {this.anchor, this.waitCard, this.waitTurn, this.delayMs = 0});

  final String text;

  /// Zona resaltada ([TutorialAnchor.id]); con `+` se resaltan varias juntas.
  /// Null centra el globo sin foco.
  final String? anchor;
  final String? waitCard;
  final int? waitTurn;

  /// Espera antes de mostrarse, para que se vean las animaciones del combate.
  final int delayMs;

  bool get waits => waitCard != null || waitTurn != null;
}

List<TutorialStep> tutorialSteps(AppLocalizations t) => [
      TutorialStep(t.tutWelcome),
      TutorialStep(t.tutIntent, anchor: 'intent'),
      TutorialStep(t.tutEnemy, anchor: 'enemyInfo'),
      TutorialStep(t.tutPlayer, anchor: 'player'),
      TutorialStep(t.tutHand, anchor: 'hand'),
      TutorialStep(t.tutPlayFist,
          anchor: 'card:gongbu_chongquan+preview', waitCard: 'gongbu_chongquan'),
      TutorialStep(t.tutStance, anchor: 'stances', delayMs: 700),
      TutorialStep(t.tutDefend,
          anchor: 'card:xubu_liangzhang+preview', waitCard: 'xubu_liangzhang'),
      TutorialStep(t.tutKick, anchor: 'card:tan_tui+preview', waitCard: 'tan_tui', delayMs: 500),
      TutorialStep(t.tutForms, anchor: 'forms', delayMs: 700),
      TutorialStep(t.tutEndTurn, anchor: 'endTurn', waitTurn: 2),
      TutorialStep(t.tutDeflect, anchor: 'enemyInfo', delayMs: 1800),
      TutorialStep(t.tutActions, anchor: 'actions'),
      TutorialStep(t.tutFree),
    ];
