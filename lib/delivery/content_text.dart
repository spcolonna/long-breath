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
  String intent(String key) => _get('intents', key);
  String stage(String id) => _get('stages', id);
  String age(Age a) => _get('ages', a.name);
}
