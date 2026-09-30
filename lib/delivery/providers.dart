import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/combat/combat_engine.dart';
import '../domain/model/game_data.dart';
import '../domain/run/run_engine.dart';
import '../infrastructure/asset_game_data_loader.dart';
import '../infrastructure/content_text_loader.dart';
import 'audio/game_audio.dart';
import 'content_text.dart';
import '../infrastructure/run_storage.dart';
import '../infrastructure/tutorial_storage.dart';

final gameDataProvider = FutureProvider<GameData>(
  (ref) => loadGameDataFromAssets(),
);

/// Solo usar una vez cargado [gameDataProvider].
final dataProvider = Provider<GameData>(
  (ref) => ref.watch(gameDataProvider).requireValue,
);

/// Textos del contenido en el idioma del dispositivo (respaldo: español).
final contentTextProvider = FutureProvider<ContentText>(
  (ref) => loadContentText(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  ),
);

/// Solo usar una vez cargado [contentTextProvider].
final textProvider = Provider<ContentText>(
  (ref) => ref.watch(contentTextProvider).requireValue,
);

final combatEngineProvider = Provider<CombatEngine>(
  (ref) => CombatEngine(ref.watch(dataProvider)),
);

final runEngineProvider = Provider<RunEngine>(
  (ref) => RunEngine(ref.watch(dataProvider)),
);

final runStorageProvider = Provider<RunStorage>((ref) => RunStorage());

final savedRunProvider = FutureProvider(
  (ref) => ref.watch(runStorageProvider).load(),
);

final tutorialStorageProvider = Provider<TutorialStorage>(
  (ref) => TutorialStorage(),
);

final lessonsDoneProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(tutorialStorageProvider).lessonsDone(),
);

/// En `main` se reemplaza por el motor real; en tests queda en silencio.
final audioProvider = Provider<GameAudio>((ref) => SilentAudio());
