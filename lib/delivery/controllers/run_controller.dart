import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/run_engine.dart';
import '../../domain/run/run_state.dart';
import '../providers.dart';

/// Run en curso. Cada cambio se guarda localmente.
class RunController extends Notifier<RunState?> {
  @override
  RunState? build() => null;

  RunEngine get _engine => ref.read(runEngineProvider);

  void _set(RunState? r) {
    state = r;
    ref.read(runStorageProvider).save(r);
  }

  void resume(RunState r) => state = r;

  void newRun(Age age) =>
      _set(_engine.newRun(age: age, seed: DateTime.now().microsecondsSinceEpoch));

  void abandon() => _set(null);

  void enter(String nodeId) => _set(_engine.enter(state!, nodeId));

  /// Devuelve la semilla y el enemigo del combate del nodo actual.
  (int, String) beginCombat() {
    final (seed, next) = _engine.combatSeed(state!);
    _set(next);
    return (seed, _engine.enemyOf(next));
  }

  void finishCombat({required bool won, required int hp}) =>
      _set(_engine.finishCombat(state!, won: won, hp: hp));

  void chooseReward(String? cardId) =>
      _set(_engine.chooseReward(state!, cardId));

  void heal() => _set(_engine.fountainHeal(state!));

  void removeCard(int uid) => _set(_engine.fountainRemove(state!, uid));

  void upgradeCard(int uid) => _set(_engine.fountainUpgrade(state!, uid));
}

final runControllerProvider =
    NotifierProvider<RunController, RunState?>(RunController.new);
