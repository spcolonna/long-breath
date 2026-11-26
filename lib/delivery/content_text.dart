import '../domain/model/enums.dart';

/// Textos del contenido del juego (cartas, enemigos, etapas…) en un idioma.
///
/// Salen de `assets/l10n/content/<idioma>.json`, indexados por id. Si falta una
/// clave se usa el idioma de respaldo y, en último caso, el id.
class ContentText {
  ContentText(this._data, [this._fallback]);

  final Map<String, dynamic> _data;
  final ContentText? _fallback;

  String? _lookup(String section, String id, [String? field]) {
    var v = (_data[section] as Map<String, dynamic>?)?[id];
    if (field != null) v = (v as Map<String, dynamic>?)?[field];
    return v as String?;
  }

  /// El texto en la ruta [path] (secciones anidadas), o null.
  String? _lookupIn(List<String> path) {
    Object? v = _data;
    for (final k in path) {
      v = v is Map<String, dynamic> ? v[k] : null;
    }
    return v is String ? v : _fallback?._lookupIn(path);
  }

  String _get(String section, String id, [String? field]) =>
      _lookup(section, id, field) ?? _fallback?._get(section, id, field) ?? id;

  bool has(String section, String id, [String? field]) =>
      _lookup(section, id, field) != null;

  String card(String id) => _get('cards', id);
  String stance(Stance s) => _get('stances', s.name);
  String dingbu() => _get('stances', 'dingbu');
  String form(String id) => _get('forms', id);
  String enemy(String id) => _get('enemies', id, 'name');
  String enemyRule(String id) => _get('enemies', id, 'rule');
  String enemyLore(String id) => _get('enemies', id, 'lore');

  /// Lo que dice el maestro errante la [n]-ésima vez (desde 1) que se lo
  /// cruza en la etapa; las líneas se repiten en ronda. Null si no hay.
  String? masterLine(String stageId, int n) {
    var count = 0;
    while (has('masterLines', '${stageId}_${count + 1}')) {
      count++;
    }
    if (count == 0) return null;
    return _get('masterLines', '${stageId}_${(n - 1) % count + 1}');
  }

  /// Lo que dice un jefe o una élite: al presentarse (`intro`), lo que le
  /// contesta el héroe (`reply`), al caer (`defeat`) y si gana (`triumph`).
  /// Null si no tiene esa línea.
  /// Con [revealed] (ya se conoce su historia), la línea de `revealed` si
  /// la tiene.
  String? enemyLine(String id, String field, {bool revealed = false}) {
    final r = revealed ? _lookupIn(['enemies', id, 'revealed', field]) : null;
    if (r != null) return r;
    return has('enemies', id, field) ? _get('enemies', id, field) : null;
  }

  /// Lo que dice el maestro de la última subida (ver `masterRecapKey`).
  String masterRecap(String key, {int floor = 0, String enemy = ''}) =>
      _get('masterRecap', key)
          .replaceAll('{floor}', '$floor')
          .replaceAll('{enemy}', enemy);

  String intent(String key) => _get('intents', key);
  String stage(String id) => _get('stages', id);

  /// Lo que se ve al llegar a una etapa.
  String stageIntro(String id) => _get('stageIntros', id);

  /// Nombre del camino de un combate según su escenario y su luz.
  String path(String scene, String light) => _get('paths', scene, light);
  String style(Style a) => _get('styles', a.name);
  String styleMotto(Style a) => _get('styleMottos', a.name);
  String talisman(String id) => _get('talismans', id);
  String weapon(String id) => _get('weapons', id, 'name');
  String weaponText(String id) => _get('weapons', id, 'text');
  String awakening(String id) => _get('awakenings', id, 'name');
  String awakeningText(String id) => _get('awakenings', id, 'text');

  /// Nombre del reino del cultivo y su frase.
  String realm(String id) => _get('realms', id, 'name');
  String realmText(String id) => _get('realms', id, 'text');

  /// Punto del árbol de meridianos: nombre (pinyin), carácter y una línea.
  String meridian(String id) => _get('meridians', id, 'name');
  String meridianHanzi(String id) => _get('meridians', id, 'hanzi');
  String meridianText(String id) => _get('meridians', id, 'text');

  /// Edificio de la escuela: nombre, carácter, quién lo cuida, su historia y
  /// una línea por nivel ([level] desde 1).
  String building(String id) => _get('school', id, 'name');
  String buildingHanzi(String id) => _get('school', id, 'hanzi');
  String buildingWho(String id) => _get('school', id, 'who');
  String buildingText(String id) => _get('school', id, 'text');
  String buildingLevel(String id, int level) => _get('school', id, 'l$level');

  /// Nombre de algo que abre el cultivo: un camino, una carta, un talismán o
  /// una forma (los ids no se repiten entre sí).
  String unlockName(String id) {
    for (final s in Style.values) {
      if (s.name == id) return style(s);
    }
    for (final section in const ['cards', 'talismans', 'forms']) {
      if (has(section, id)) return _get(section, id);
    }
    return id;
  }
  String event(String id) => _get('events', id, 'name');
  String eventText(String id) => _get('events', id, 'text');
  String eventOption(String id, String option) => _get('events', id, option);

  /// Un pergamino de la escuela: [field] es `title`, `text` o `hint`.
  String lore(String id, String field) => _get('lore', id, field);

  /// Un hito 功: [field] es `name` (su nombre) o `text` (cómo se cumple).
  String hito(String id, String field) => _get('hitos', id, field);

  /// Lo que pasó al elegir [option] (con [failed], la versión que salió mal).
  String eventResult(String id, String option, {bool failed = false}) =>
      _get('events', id, failed ? '${option}Fail' : '${option}Result');
}
