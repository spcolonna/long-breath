import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/delivery/content_text.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

void main() {
  final data = loadGameDataFromDir();
  final languages = Directory('assets/l10n/content')
      .listSync()
      .whereType<File>()
      .map((f) => f.uri.pathSegments.last.replaceAll('.json', ''));

  for (final lang in languages) {
    test('content/$lang.json cubre todo el contenido', () {
      final text = ContentText(jsonDecode(
          File('assets/l10n/content/$lang.json').readAsStringSync())
          as Map<String, dynamic>);
      final missing = <String>[
        for (final id in data.cards.keys)
          if (!text.has('cards', id)) 'cards.$id',
        for (final s in [...Stance.values.map((s) => s.name), 'dingbu'])
          if (!text.has('stances', s)) 'stances.$s',
        for (final f in data.forms)
          if (!text.has('forms', f.id)) 'forms.${f.id}',
        for (final e in data.enemies.values) ...[
          if (!text.has('enemies', e.id, 'name')) 'enemies.${e.id}.name',
          if (!text.has('enemies', e.id, 'rule')) 'enemies.${e.id}.rule',
          for (final p in e.phases)
            for (final i in p.pattern)
              if (i.labelKey != null && !text.has('intents', i.labelKey!))
                'intents.${i.labelKey}',
        ],
        for (final a in Age.values)
          if (!text.has('ages', a.name)) 'ages.${a.name}',
        if (!text.has('stages', data.balance.stage.id))
          'stages.${data.balance.stage.id}',
      ];
      expect(missing, isEmpty);
    });
  }
}
