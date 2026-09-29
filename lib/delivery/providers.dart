import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/combat/combat_engine.dart';
import '../domain/model/game_data.dart';
import '../domain/run/run_engine.dart';
import '../infrastructure/asset_game_data_loader.dart';
import '../infrastructure/run_storage.dart';

final gameDataProvider =
    FutureProvider<GameData>((ref) => loadGameDataFromAssets());

/// Solo usar una vez cargado [gameDataProvider].
final dataProvider =
    Provider<GameData>((ref) => ref.watch(gameDataProvider).requireValue);

final combatEngineProvider =
    Provider<CombatEngine>((ref) => CombatEngine(ref.watch(dataProvider)));

final runEngineProvider =
    Provider<RunEngine>((ref) => RunEngine(ref.watch(dataProvider)));

final runStorageProvider = Provider<RunStorage>((ref) => RunStorage());

final savedRunProvider =
    FutureProvider((ref) => ref.watch(runStorageProvider).load());
