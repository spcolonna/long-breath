/// El final verdadero: con los tres finales de camino, el Pico 5 ganado y
/// la escuela entera restaurada, después del último jefe se levanta el
/// Primer Discípulo (el sueño que el dragón tiene de sí mismo). Vencerlo
/// abre el último pergamino; después el dragón duerme sin soñar y ya no
/// vuelve a levantarse.
library;

import '../model/enums.dart';
import 'ascent.dart';

/// El jefe del final verdadero.
const trueBoss = 'first_disciple';

/// El pergamino del final verdadero.
const trueEndingLore = 'true_ending';

/// Pico que hay que haber ganado.
const trueSummitPico = 5;

/// Lo que pide el final verdadero, cada parte por separado (para mostrar
/// cuánto falta).
({bool endings, bool pico, bool school}) trueSummitParts({
  required Set<String> lore,
  required int picoUnlocked,
  required bool schoolDone,
}) => (
  endings: Style.values.every((s) => lore.contains(endingOf(s))),
  pico: picoUnlocked > trueSummitPico,
  school: schoolDone,
);

/// La próxima subida va por el final verdadero: se cumple todo y todavía no
/// se lo vio.
bool trueSummitReady({
  required Set<String> lore,
  required int picoUnlocked,
  required bool schoolDone,
}) {
  if (lore.contains(trueEndingLore)) return false;
  final p = trueSummitParts(
    lore: lore,
    picoUnlocked: picoUnlocked,
    schoolDone: schoolDone,
  );
  return p.endings && p.pico && p.school;
}
