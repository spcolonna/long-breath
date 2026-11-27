import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Rutas de todas las hojas string de un JSON anidado.
Map<String, String> leaves(Object? v, [String at = '']) => switch (v) {
  Map() => {
    for (final e in v.entries)
      if (!'${e.key}'.startsWith('@'))
        ...leaves(e.value, at.isEmpty ? '${e.key}' : '$at.${e.key}'),
  },
  List() => {
    for (var i = 0; i < v.length; i++) ...leaves(v[i], '$at[$i]'),
  },
  String() => {at: v},
  _ => {},
};

Map<String, String> read(String path) =>
    leaves(jsonDecode(File(path).readAsStringSync()));

final _placeholder = RegExp(r'(?<!\w)\{(\w+)[,}]');
Set<String> placeholders(String s) => {
  for (final m in _placeholder.allMatches(s)) m.group(1)!,
};

void main() {
  for (final (name, es, en) in [
    (
      'contenido',
      'assets/l10n/content/es.json',
      'assets/l10n/content/en.json',
    ),
    ('interfaz', 'lib/l10n/app_es.arb', 'lib/l10n/app_en.arb'),
  ]) {
    test('el inglés del $name tiene todo y con los mismos marcadores', () {
      final a = read(es);
      final b = read(en);
      expect(b.keys.toSet().difference(a.keys.toSet()), isEmpty);
      expect(a.keys.toSet().difference(b.keys.toSet()), isEmpty);
      for (final k in a.keys) {
        expect(
          placeholders(b[k]!),
          placeholders(a[k]!),
          reason: '$name: $k',
        );
      }
    });
  }
}
