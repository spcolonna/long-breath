import 'dart:convert';

import 'package:flutter/services.dart';

import '../domain/model/game_data.dart';

Future<GameData> loadGameDataFromAssets() async {
  Future<Map<String, dynamic>> read(String name) async =>
      jsonDecode(await rootBundle.loadString('assets/data/$name'))
          as Map<String, dynamic>;
  return GameData.fromJson(
    cards: await read('cards.json'),
    stances: await read('stances.json'),
    forms: await read('forms.json'),
    enemies: await read('enemies.json'),
    balance: await read('game_balance.json'),
    talismans: await read('talismans.json'),
    events: await read('events.json'),
  );
}
