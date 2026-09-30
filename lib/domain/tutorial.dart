/// Lecciones del tutorial: cada una es un combate armado a mano contra un
/// muñeco de madera (木人桩). El mazo no se mezcla, así cada mano es la que
/// el guion del maestro espera. Los textos viven en la capa de presentación.
class LessonSetup {
  const LessonSetup({required this.enemyId, required this.deck});

  final String enemyId;

  /// En orden de robo: las 5 primeras son la primera mano, y así.
  final List<String> deck;
}

const lessonSetups = <String, LessonSetup>{
  // 1. Tu primer golpe: solo ataques, para que el muñeco te pegue.
  'strike': LessonSetup(
    enemyId: 'dummy_basic',
    deck: [
      'mabu_chongquan',
      'tui_zhang',
      'mabu_chongquan',
      'tan_tui',
      'mabu_chongquan',
      'mabu_chongquan',
      'mabu_chongquan',
      'tui_zhang',
      'tan_tui',
      'tui_zhang',
      'mabu_chongquan',
      'tan_tui',
      'tui_zhang',
      'mabu_chongquan',
      'tan_tui',
    ],
  ),
  // 2. Defenderse: desvío alto en el turno 1, altura equivocada en el 2.
  'defend': LessonSetup(
    enemyId: 'dummy_heights',
    deck: [
      'shang_jia',
      'mabu_chongquan',
      'tan_tui',
      'tui_zhang',
      'mabu_chongquan',
      'an_zhang',
      'mabu_chongquan',
      'tan_tui',
      'tui_zhang',
      'mabu_chongquan',
      'an_zhang',
      'mabu_chongquan',
      'mabu_chongquan',
      'tui_zhang',
      'tan_tui',
    ],
  ),
  // 3. Posturas: Arco con el puño, Paso en T a Vacía y patada gratis.
  'stances': LessonSetup(
    enemyId: 'dummy_light',
    deck: [
      'gongbu_chongquan',
      'tan_tui',
      'mabu_chongquan',
      'tui_zhang',
      'ge_dang',
      'mabu_chongquan',
      'gongbu_chongquan',
      'tan_tui',
      'tui_zhang',
      'ge_dang',
      'gongbu_chongquan',
      'tan_tui',
      'mabu_chongquan',
      'tui_zhang',
      'ge_dang',
    ],
  ),
  // 4. Estructura: dos empujes lo desequilibran y el puño pega doble.
  'structure': LessonSetup(
    enemyId: 'dummy_guard',
    deck: [
      'tui_zhang',
      'tui_zhang',
      'mabu_chongquan',
      'ge_dang',
      'mabu_chongquan',
      'mabu_chongquan',
      'tan_tui',
      'tui_zhang',
      'mabu_chongquan',
      'ge_dang',
      'mabu_chongquan',
      'tui_zhang',
      'tan_tui',
      'ge_dang',
      'mabu_chongquan',
    ],
  ),
  // 5. Formas: dos pasos en el turno 1; en el 2, Respirar trae el último.
  'forms': LessonSetup(
    enemyId: 'dummy_forms',
    deck: [
      'gongbu_chongquan',
      'tan_tui',
      'tui_zhang',
      'ge_dang',
      'an_zhang',
      'mabu_jiada',
      'ge_dang',
      'an_zhang',
      'mabu_chongquan',
      'tui_zhang',
      'xubu_liangzhang',
      'gongbu_chongquan',
      'tan_tui',
      'mabu_chongquan',
      'tui_zhang',
      'mabu_chongquan',
      'gongbu_chongquan',
      'tan_tui',
    ],
  ),
};
