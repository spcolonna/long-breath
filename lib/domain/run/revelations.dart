/// Revelaciones: pergaminos que, una vez leídos, cambian la montaña.
///
/// - El rival cuya historia ya se conoce dice otras líneas (`revealed` en
///   su contenido) y arranca dudando: con menos Estructura.
/// - Algunos eventos abren una opción más (`needs: {lore: [...]}`).
library;

/// Qué pergamino revela a cada rival.
const revealedFoes = {
  'dragon': 'dream_4',
  'bell_abbot': 'page_10',
  'wind_lady': 'dream_7',
  'sleeping_dragon': 'dream_10',
};

/// Pergaminos que abren opciones en los eventos.
const revelationEventLore = ['dream_2', 'dream_9'];

/// Todos los pergaminos que cambian algo en la montaña.
const revelationLore = {...revealedFoesLore, ...revelationEventLore};

/// Los pergaminos que revelan a un rival.
const revealedFoesLore = ['dream_4', 'page_10', 'dream_7', 'dream_10'];

/// Estructura con la que arranca un rival que ya conocés (% de la suya).
const revealedStructurePct = 50;

/// Las revelaciones que se llevan a la subida, de todo lo leído.
Set<String> knownRevelations(Set<String> lore) =>
    lore.where(revelationLore.contains).toSet();

/// [enemy] ya se conoce: se leyó el pergamino que lo revela.
bool isRevealed(String enemy, Set<String> known) {
  final l = revealedFoes[enemy];
  return l != null && known.contains(l);
}

/// Los rivales que se conocen, de las revelaciones que se llevan.
Set<String> revealedOf(Set<String> known) => {
  for (final e in revealedFoes.entries)
    if (known.contains(e.value)) e.key,
};
