import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/run_engine.dart';
import '../../domain/run/run_state.dart';
import '../../domain/run/ascent.dart';
import '../../infrastructure/progress_storage.dart';
import '../providers.dart';
import '../screens/map/map_layout.dart';

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

  void newRun(Difficulty difficulty, {int pico = 0}) => _set(_engine.newRun(
        seed: DateTime.now().microsecondsSinceEpoch,
        difficulty: difficulty,
        pico: pico,
      ));

  void abandon() => _set(null);

  void enter(String nodeId) => _set(_engine.enter(state!, nodeId));

  /// Devuelve la semilla y el enemigo del combate del nodo actual.
  (int, String) beginCombat() {
    final (seed, next) = _engine.combatSeed(state!);
    _set(next);
    return (seed, _engine.enemyOf(next));
  }

  void finishCombat({required bool won, required int hp, int? fledWith}) {
    _set(_engine.finishCombat(state!, won: won, hp: hp, fledWith: fledWith));
    final phase = state!.phase;
    if (phase == RunPhase.victory || phase == RunPhase.defeat) {
      _record(state!);
    }
    if (phase == RunPhase.victory) {
      final progress = ref.read(progressStorageProvider);
      final run = state!;
      progress.markWin(run.difficulty).then((_) => ref.invalidate(winsProvider));
      progress
          .markPicoWin(run.difficulty, run.pico)
          .then((_) => ref.invalidate(picoUnlockedProvider));
    }
  }

  /// La subida terminó: queda en el registro de la escuela y el próximo
  /// en subir es otro discípulo.
  void _record(RunState run) {
    final rows = mapRows(run);
    final node = run.currentNode == null ? null : run.node(run.currentNode!);
    // El piso se cuenta en toda la subida: las etapas anteriores suman.
    final stages = ref.read(dataProvider).balance.stages;
    final below = stages.take(run.stage).fold(0, (a, s) => a + s.floors.length);
    final ascent = Ascent(
      n: 0,
      fell: run.phase == RunPhase.defeat,
      floor: below +
          rows.indexWhere((r) => r.any((n) => n.id == run.currentNode)) +
          1,
      floors: ref.read(dataProvider).balance.totalFloors,
      stage: run.stage,
      difficulty: run.difficulty,
      pico: run.pico,
      enemy: node?.enemy,
      scene: node?.scene,
      light: node?.light,
      style: run.style,
      maxHp: run.maxHp,
      deck: run.deck.length,
    );
    ref.read(lastAscentProvider.notifier).set(null);
    ref.read(progressStorageProvider).recordAscent(ascent).then((done) {
      ref.read(lastAscentProvider.notifier).set(done);
      ref
        ..invalidate(discipleProvider)
        ..invalidate(ascentsProvider)
        ..invalidate(loreProvider);
    });
  }

  /// Subir a la etapa siguiente después de vencer a su jefe.
  void advanceStage() => _set(_engine.advanceStage(state!));

  void chooseReward(String? cardId) =>
      _set(_engine.chooseReward(state!, cardId));

  void chooseForm(String formId) =>
      _set(_engine.chooseForm(state!, formId));

  void chooseTalisman(String id) =>
      _set(_engine.chooseTalisman(state!, id));

  void resolveEvent(String optionId) =>
      _set(_engine.resolveEvent(state!, optionId));

  void buyCard(String cardId) => _set(_engine.buyCard(state!, cardId));

  void buyTalisman() => _set(_engine.buyTalisman(state!));

  void buyRemove(int uid) => _set(_engine.buyRemove(state!, uid));

  void buyUpgrade(int uid) => _set(_engine.buyUpgrade(state!, uid));

  void buyTea() => _set(_engine.buyTea(state!));

  void leaveShop() => _set(_engine.leaveShop(state!));

  void masterTeach(String formId) => _set(_engine.masterTeach(state!, formId));

  void masterUpgrade(int uid) => _set(_engine.masterUpgrade(state!, uid));

  void choosePath(Style style) => _set(_engine.choosePath(state!, style));

  void heal() => _set(_engine.fountainHeal(state!));

  void removeCard(int uid) => _set(_engine.fountainRemove(state!, uid));

  void upgradeCard(int uid) => _set(_engine.fountainUpgrade(state!, uid));
}

final runControllerProvider =
    NotifierProvider<RunController, RunState?>(RunController.new);
