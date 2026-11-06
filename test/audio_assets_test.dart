import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/audio/game_audio.dart';

/// Todo el sonido sale de `tool/make_audio.py`: cada efecto (con todas sus
/// variantes), cada pista y la voz de cada enemigo tiene su archivo.
void main() {
  test('cada Sfx tiene su archivo y sus variantes', () {
    for (final s in Sfx.values) {
      final names = s.variants == 1
          ? [s.id]
          : [for (var i = 1; i <= s.variants; i++) '${s.id}_$i'];
      for (final n in names) {
        expect(File('assets/audio/sfx/$n.wav').existsSync(), isTrue,
            reason: 'falta $n.wav');
      }
    }
  });

  test('cada pista de música y jingle existe', () {
    for (final m in Music.values) {
      expect(File('assets/audio/music/${m.id}.ogg').existsSync(), isTrue,
          reason: 'falta ${m.id}.ogg');
    }
  });

  test('cada enemigo tiene voz', () {
    final data = jsonDecode(File('assets/data/enemies.json').readAsStringSync())
        as Map<String, dynamic>;
    for (final e in data['enemies'] as List) {
      final id = (e as Map)['id'];
      expect(File('assets/audio/sfx/enemy_$id.wav').existsSync(), isTrue,
          reason: 'falta la voz de $id');
    }
  });
}
