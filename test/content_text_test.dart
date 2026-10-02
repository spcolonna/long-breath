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
        for (final a in Style.values) ...[
          if (!text.has('styles', a.name)) 'styles.${a.name}',
          if (!text.has('styleMottos', a.name)) 'styleMottos.${a.name}',
        ],
        for (final id in data.talismans.keys)
          if (!text.has('talismans', id)) 'talismans.$id',
        for (final e in data.events) ...[
          for (final f in ['name', 'text'])
            if (!text.has('events', e.id, f)) 'events.${e.id}.$f',
          for (final o in e.options) ...[
            if (!text.has('events', e.id, o.id)) 'events.${e.id}.${o.id}',
            if (!text.has('events', e.id, '${o.id}Result'))
              'events.${e.id}.${o.id}Result',
            if (o.chance != null && !text.has('events', e.id, '${o.id}Fail'))
              'events.${e.id}.${o.id}Fail',
          ],
        ],
        if (!text.has('stages', data.balance.stage.id))
          'stages.${data.balance.stage.id}',
      ];
      expect(missing, isEmpty);
    });
  }
}
