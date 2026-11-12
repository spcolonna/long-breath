/// Hilos: historias que cruzan subidas. Lo que pasó queda como marcas
/// sueltas que se guardan con la partida:
/// - `<hilo>_<n>`: se vivió el capítulo n;
/// - `<hilo>_<n>_<lazo>`: cómo se lo vivió (`kind` amable, `proud` orgulloso);
/// - `bao_<n>_trust`: después del capítulo n se le compró algo a Tío Bao.
///
/// Un capítulo por hilo y por subida, así cada subida suma uno.
library;

/// La rival de la escuela del Ave Azul.
const threadShuang = 'shuang';

/// El mercader.
const threadBao = 'bao';

/// Capítulos de cada hilo.
const threadChapters = {threadShuang: 5, threadBao: 5};

/// Último capítulo vivido del hilo (0: ninguno).
int chapterOf(Set<String> marks, String thread) {
  var n = 0;
  while (marks.contains('${thread}_${n + 1}')) {
    n++;
  }
  return n;
}

/// Cómo se trató al personaje del hilo hasta ahora: `kind` si las veces
/// amables alcanzan a las orgullosas, `proud` si no.
String bondOf(Set<String> marks, String thread) {
  final kind = marks.where((m) => m.startsWith('${thread}_') && m.endsWith('_kind')).length;
  final proud = marks.where((m) => m.startsWith('${thread}_') && m.endsWith('_proud')).length;
  return kind >= proud ? 'kind' : 'proud';
}

/// El próximo capítulo de Tío Bao, si toca en esta subida: el primero
/// siempre; los demás, si después del anterior se le compró algo.
int? nextBaoChapter(Set<String> marks) {
  final n = chapterOf(marks, threadBao);
  if (n >= threadChapters[threadBao]!) return null;
  if (n > 0 && !marks.contains('${threadBao}_${n}_trust')) return null;
  return n + 1;
}

/// Tío Bao contó todo: precio de amigo.
bool baoFriend(Set<String> marks) =>
    chapterOf(marks, threadBao) >= threadChapters[threadBao]!;

/// Los pergaminos de los hilos, en orden (se releen en el registro).
const threadLore = [
  'shuang_1', 'shuang_2', 'shuang_3', 'shuang_4', 'shuang_5', //
  'bao_1', 'bao_2', 'bao_3', 'bao_4', 'bao_5',
];

/// Las páginas sueltas que trae a veces un cofre (diario del maestro,
/// notas de los que subieron, cuentas del monasterio). Salen en orden y
/// cada una queda como marca y como pergamino.
const pageLore = [
  'page_1', 'page_2', 'page_3', 'page_4', 'page_5', 'page_6', //
  'page_7', 'page_8', 'page_9', 'page_10', 'page_11', 'page_12',
];

/// Marca de `threadRun` por cada página encontrada en la subida.
const threadPage = 'page';

/// La próxima página que falta, o null si ya están todas.
String? nextPage(Set<String> marks) {
  for (final p in pageLore) {
    if (!marks.contains(p)) return p;
  }
  return null;
}
