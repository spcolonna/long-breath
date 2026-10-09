import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../domain/model/meta_bonus.dart';
import '../../domain/run/run_engine.dart';
import '../../domain/run/run_state.dart';
import '../../domain/run/ascent.dart';
import '../../domain/run/cultivation.dart';
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

  /// Sube un discípulo nuevo. [locked]: lo que el cultivo todavía no abrió
  /// (si no se pasa, se toma del reino ya cargado).
  void newRun(
    Difficulty difficulty, {
    int pico = 0,
    List<String>? locked,
    MetaBonus? meta,
  }) =>
      _set(_engine.newRun(
        seed: DateTime.now().microsecondsSinceEpoch,
        difficulty: difficulty,
        pico: pico,
        locked:
            locked ?? ref.read(cultivationProvider).value?.locked ?? const [],
        meta: meta ?? ref.read(metaBonusProvider).value ?? MetaBonus.none,
      ));

  void abandon() => _set(null);

  void enter(String nodeId) => _set(_engine.enter(state!, nodeId));

  /// Devuelve la semilla y los enemigos del combate del nodo actual (el
  /// primero y los que entran después).
  (int, List<String>) beginCombat() {
    final (seed, next) = _engine.combatSeed(state!);
    _set(next);
    return (seed, _engine.packOf(next));
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
    final cultivation = ref.read(dataProvider).balance.cultivation;
    var ascent = Ascent(
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
    ascent = Ascent.fromJson({
      ...ascent.toJson(),
      'breath': ascentBreath(cultivation, ascent),
      'lotus': run.lotus,
    });
    ref.read(lastAscentProvider.notifier).set(null);
    ref
        .read(progressStorageProvider)
        .recordAscent(ascent, migrate: (a) => ascentBreath(cultivation, a))
        .then((done) {
      ref.read(lastAscentProvider.notifier).set(done);
      ref
        ..invalidate(discipleProvider)
        ..invalidate(ascentsProvider)
        ..invalidate(loreProvider)
        ..invalidate(cultivationProvider)
        ..invalidate(meridianProvider)
        ..invalidate(metaBonusProvider);
    });
  }

  /// Subir a la etapa siguiente después de vencer a su jefe.
  void advanceStage([String? awakening]) =>
      _set(_engine.advanceStage(state!, awakening: awakening));

  void chooseReward(String? cardId) =>
      _set(_engine.chooseReward(state!, cardId));

  void chooseForm(String formId) =>
      _set(_engine.chooseForm(state!, formId));

  void collectReward() => _set(_engine.collectReward(state!));

  void chooseRewardUpgrade(int uid) =>
      _set(_engine.chooseRewardUpgrade(state!, uid));

  void chooseRewardTalisman(String id) =>
      _set(_engine.chooseRewardTalisman(state!, id));

  void rerollReward() => _set(_engine.rerollReward(state!));

  /// La presentación de la etapa ya se vio: no se repite al volver al mapa.
  void introSeen() => _set(state!.copyWith(introShown: state!.stage));

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
