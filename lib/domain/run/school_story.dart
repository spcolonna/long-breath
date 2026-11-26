/// Los hilos de la escuela: Hermano Ming (enfermería) y Maestro Tie (forja)
/// cuentan su historia en su edificio, un capítulo por vuelta a la escuela.
///
/// Cada capítulo leído queda como pergamino (`ming_<n>`, `tie_<n>`). Para
/// que no se lean de un tirón, se guarda el número del último discípulo
/// que había bajado cuando se leyó el anterior: el próximo pide otra subida.
library;

/// Quien cuenta cada hilo y en qué edificio.
const schoolThreads = {'ming': 'infirmary', 'tie': 'forge'};

/// Capítulos de cada hilo de la escuela.
const schoolChapters = 5;

/// Nivel del edificio que pide cada capítulo (el 1 se cuenta en ruinas).
const schoolChapterLevel = [0, 1, 2, 3, 3];

/// El pergamino que el último capítulo pide además: haber hecho cumbre.
const schoolLastChapterNeeds = 'summit';

/// Los pergaminos de los hilos de la escuela, en orden.
const schoolStoryLore = [
  'ming_1', 'ming_2', 'ming_3', 'ming_4', 'ming_5', //
  'tie_1', 'tie_2', 'tie_3', 'tie_4', 'tie_5',
];

/// Último capítulo leído del hilo [thread] (0: ninguno).
int schoolChapterOf(Set<String> lore, String thread) {
  var n = 0;
  while (n < schoolChapters && lore.contains('${thread}_${n + 1}')) {
    n++;
  }
  return n;
}

/// Qué le falta al próximo capítulo de un hilo.
enum StoryWait {
  /// Se puede leer ahora.
  none,

  /// Ya se contó todo.
  done,

  /// Hay que subir (todavía nadie bajó, o ya se leyó uno en esta vuelta).
  ascent,

  /// Hay que restaurar más el edificio.
  level,

  /// El último capítulo pide haber hecho cumbre.
  summit,
}

/// Qué falta para el próximo capítulo de [thread].
///
/// [level] es el nivel de su edificio, [lastDisciple] el número del último
/// discípulo que terminó una subida y [readAt] el que había bajado cuando
/// se leyó el capítulo anterior (0 si nunca).
StoryWait schoolStoryWait({
  required String thread,
  required Set<String> lore,
  required int level,
  required int lastDisciple,
  required int readAt,
}) {
  final n = schoolChapterOf(lore, thread);
  if (n >= schoolChapters) return StoryWait.done;
  if (lastDisciple <= 0 || lastDisciple <= readAt) return StoryWait.ascent;
  if (level < schoolChapterLevel[n]) return StoryWait.level;
  if (n == schoolChapters - 1 && !lore.contains(schoolLastChapterNeeds)) {
    return StoryWait.summit;
  }
  return StoryWait.none;
}

/// El hilo que se cuenta en el edificio [building], o null.
String? threadOfBuilding(String building) {
  for (final e in schoolThreads.entries) {
    if (e.value == building) return e.key;
  }
  return null;
}

/// Qué línea del maestro comenta la última subida (`masterRecap.<clave>`
/// del contenido): cumbre, el Discípulo Perdido, un jefe o la etapa donde
/// se cayó. Las que nombran al rival se usan solo si hay rival.
String masterRecapKey({
  required bool fell,
  required int stage,
  required int n,
  String? enemy,
  bool ghost = false,
  bool boss = false,
}) {
  if (!fell) return n.isEven ? 'won_a' : 'won_b';
  if (ghost) return 'ghost';
  if (enemy != null && boss) return 'fell_boss';
  final s = stage.clamp(0, 2);
  return enemy != null && n.isOdd ? 'fell_${s}_b' : 'fell_${s}_a';
}
