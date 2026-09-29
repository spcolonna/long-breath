import 'dart:convert';
import 'dart:io';

import '../domain/model/game_data.dart';

/// Carga los datos desde disco (tests y simulador, sin Flutter).
GameData loadGameDataFromDir([String dir = 'assets/data']) {
  Map<String, dynamic> read(String name) =>
      jsonDecode(File('$dir/$name').readAsStringSync()) as Map<String, dynamic>;
  return GameData.fromJson(
    cards: read('cards.json'),
    stances: read('stances.json'),
    forms: read('forms.json'),
    enemies: read('enemies.json'),
    balance: read('game_balance.json'),
  );
}
