import '../../domain/model/enums.dart';

/// Dibujos que el maestro puede mostrar dentro de su globo.
enum Illustration { card, intent, heights, stances, turn, broken, forms }

/// Un paso de una lección. Si espera una jugada (`wait*`), solo se puede tocar
/// la zona resaltada; si no, se avanza con el botón.
class TutorialStep {
  const TutorialStep(
    this.text, {
    this.anchor,
    this.waitCard,
    this.waitSelect,
    this.waitTurn,
    this.waitStance,
    this.waitBreathe = false,
    this.delayMs = 0,
    this.illustration,
  });

  final String text;

  /// Zona resaltada ([TutorialAnchor.id]); con `+` se resaltan varias juntas y
  /// solo la primera recibe toques. Null centra el globo sin foco.
  final String? anchor;

  /// Avanza al jugar esta carta.
  final String? waitCard;

  /// Avanza al tocar esta carta una vez (queda seleccionada, sin jugarse).
  final String? waitSelect;

  /// Avanza al llegar a este turno.
  final int? waitTurn;

  /// Avanza al cambiar a esta postura con Paso en T.
  final Stance? waitStance;

  /// Avanza al usar Respirar.
  final bool waitBreathe;

  /// Espera antes de mostrarse, para que se vean las animaciones del combate.
  final int delayMs;

  final Illustration? illustration;

  bool get waits =>
      waitCard != null ||
      waitSelect != null ||
      waitTurn != null ||
      waitStance != null ||
      waitBreathe;
}
