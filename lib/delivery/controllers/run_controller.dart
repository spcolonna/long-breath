import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_state.dart';
import '../../domain/model/enums.dart';
import '../../domain/model/meta_bonus.dart';
import '../../domain/run/run_engine.dart';
import '../../domain/run/run_state.dart';
import '../../domain/run/ascent.dart';
import '../../domain/run/cultivation.dart';
import '../../domain/run/ghost.dart';
import '../../domain/run/legacy.dart';
import '../../infrastructure/progress_storage.dart';
import '../log/run_log.dart';
import '../providers.dart';
import '../screens/map/map_layout.dart';

/// Run en curso. Cada cambio se guarda localmente.
class RunController extends Notifier<RunState?> {
  /// Cambiar de partida deja la subida en memoria vacía.
  @override
  RunState? build() {
    ref.watch(activeSlotProvider);
    return null;
  }

  RunEngine get _engine => ref.read(runEngineProvider);

  /// El enemigo en pie al terminar el último combate (para el registro).
  String? _lastFoe;

  /// Guarda y anota en el registro lo que cambió ([what]: la decisión;
  /// [options]: los nodos que se podían elegir).
  void _set(RunState? r, {String? what, List<String> options = const []}) {
    final prev = state;
    state = r;
    ref.read(runStorageProvider).save(r);
    final finished = prev != null &&
        (prev.phase == RunPhase.victory || prev.phase == RunPhase.defeat);
    if (prev != null && !(r == null && finished)) {
      ref.read(runLogProvider).append(
        runDiff(prev, r, what: what, options: options),
      );
    }
  }

  /// Empieza el registro de una subida nueva.
  void _startLog(RunState r) => ref
      .read(runLogProvider)
      .start(runHeader(r, ref.read(activeSlotProvider)));

  /// Anota una línea suelta (combate) en el registro.
  void log(Iterable<String> lines) => ref.read(runLogProvider).append(lines);

  void resume(RunState r) => state = r;

  /// Sube un discípulo nuevo. [locked]: lo que el cultivo todavía no abrió
  /// (si no se pasa, se toma del reino ya cargado).
  void newRun(
    Difficulty difficulty, {
    int pico = 0,
    List<String>? locked,
    MetaBonus? meta,
    Ghost? ghost,
    Legacy? legacy,
  }) {
    final run = _engine.newRun(
        seed: DateTime.now().microsecondsSinceEpoch,
        difficulty: difficulty,
        pico: pico,
        locked:
            locked ?? ref.read(cultivationProvider).value?.locked ?? const [],
        meta: meta ?? ref.read(metaBonusProvider).value ?? MetaBonus.none,
        ghost: ghost ?? ghostFrom(ref.read(ascentsProvider).value ?? const []),
        legacy: legacy,
      );
    _startLog(run);
    _set(run);
  }

  void abandon() => _set(null);

  /// Menú de pruebas (solo debug): subida en la etapa y el piso elegidos.
  void debugStart(
    Difficulty difficulty,
    int pico,
    int stage,
    int floor, {
    String? weapon,
    int weaponLevel = 1,
  }) {
    final run = _engine.debugStart(
        seed: DateTime.now().microsecondsSinceEpoch,
        difficulty: difficulty,
        pico: pico,
        stage: stage,
        floor: floor,
        meta: ref.read(metaBonusProvider).value ?? MetaBonus.none,
        ghost: ghostFrom(ref.read(ascentsProvider).value ?? const []),
        weapon: weapon,
        weaponLevel: weaponLevel,
      );
    _startLog(run);
    _set(run, what: 'menú de pruebas: etapa $stage piso $floor');
  }

  void enter(String nodeId) => _set(
    _engine.enter(state!, nodeId),
    options: _engine.available(state!),
  );

  /// Estancia: la tregua elegida y a la próxima sala.
  void roomContinue(Breather b) => _set(
    _engine.roomContinue(state!, b),
    what: 'sala ${state!.roomStep + 2}, tregua ${b.name}',
  );

  /// Devuelve la semilla y los enemigos del combate del nodo actual (el
  /// primero y los que entran después).
  (int, List<String>) beginCombat() {
    final (seed, next) = _engine.combatSeed(state!);
    _set(next);
    return (seed, _engine.packOf(next));
  }

  void finishCombat({
    required bool won,
    required int hp,
    int? fledWith,
    String? foe,
    Map<String, int> tally = const {},
  }) {
    // Quién quedó en pie: en una estancia o un grupo no es el enemigo del
    // nodo (ese es el guardián de la última sala).
    _lastFoe = foe;
    _set(
      _engine.finishCombat(
        state!,
        won: won,
        hp: hp,
        fledWith: fledWith,
        tally: tally,
      ),
      what: won
          ? 'gana el combate'
          : fledWith != null
          ? 'el enemigo huyó'
          : 'pierde el combate',
    );
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
    final alive = _lastFoe;
    final foe = alive != null && isGhostFoe(alive)
        ? ghostEnemy
        : alive ??
        (node == null ? null : _engine.packOf(run).firstOrNull ?? node.enemy);
    _lastFoe = null;
    // El piso se cuenta en toda la subida: las etapas anteriores suman.
    final stages = ref.read(dataProvider).balance.stages;
    final below = stages.take(run.stage).fold(0, (a, s) => a + s.floors.length);
    final cultivation = ref.read(dataProvider).balance.cultivation;
    final keepsake = keepsakeOf(ref.read(dataProvider), run.deck, run.style);
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
      enemy: foe,
      scene: node?.scene,
      light: node?.light,
      style: run.style,
      maxHp: run.maxHp,
      deck: run.deck.length,
      keepsake: keepsake?.cardId,
      keepsakeUp: keepsake?.upgrades ?? 0,
      // Si lo venció el Discípulo Perdido, queda quién lo llevaba.
      ghost: foe == ghostEnemy
          ? run.ghost?.n
          : null,
    );
    final offering = _engine.offeringOf(run);
    ascent = Ascent.fromJson({
      ...ascent.toJson(),
      'breath': ascentBreath(cultivation, ascent),
      'lotus': run.lotus + offering,
      'jade': run.jade,
      'offering': offering,
      'feats': _engine.finalFeats(run),
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
        ..invalidate(hitosProvider)
        ..invalidate(cultivationProvider)
        ..invalidate(meridianProvider)
        ..invalidate(metaBonusProvider);
    });
  }

  /// Subir a la etapa siguiente después de vencer a su jefe.
  void advanceStage([String? awakening, String? vow]) => _set(
    _engine.advanceStage(state!, awakening: awakening, vow: vow),
    what: 'sube de etapa${awakening == null ? '' : ' con $awakening'}'
        '${vow == null ? '' : ', voto $vow'}',
  );

  void chooseReward(String? cardId) =>
      _set(_engine.chooseReward(state!, cardId), what: 'elige carta ${cardId ?? 'ninguna'}');

  void chooseForm(String formId) =>
      _set(_engine.chooseForm(state!, formId), what: 'elige forma $formId');

  void collectReward() => _set(_engine.collectReward(state!), what: 'cobra el botín');

  void chooseRewardUpgrade(int uid) =>
      _set(_engine.chooseRewardUpgrade(state!, uid), what: 'mejora carta $uid');

  void chooseRewardTalisman(String id) =>
      _set(_engine.chooseRewardTalisman(state!, id), what: 'elige talismán $id');

  void chooseRewardWeapon(String id) =>
      _set(_engine.chooseRewardWeapon(state!, id), what: 'elige arma $id');

  void rerollReward() => _set(_engine.rerollReward(state!), what: 'vuelve a tirar el botín');

  /// La presentación de la etapa ya se vio: no se repite al volver al mapa.
  void introSeen() => _set(state!.copyWith(introShown: state!.stage));

  void chooseLegacy(LegacyPick pick) =>
      _set(_engine.chooseLegacy(state!, pick), what: 'elige legado ${pick.name}');

  void chooseTalisman(String id) =>
      _set(_engine.chooseTalisman(state!, id), what: 'elige talismán $id');

  void resolveEvent(String optionId) =>
      _set(_engine.resolveEvent(state!, optionId), what: 'evento: elige $optionId');

  void buyCard(String cardId) => _set(_engine.buyCard(state!, cardId), what: 'compra carta $cardId');

  void buyTalisman() => _set(_engine.buyTalisman(state!), what: 'compra talismán');

  void buyRare() => _set(_engine.buyRare(state!), what: 'compra el de la vitrina');

  void buyWeapon() => _set(_engine.buyWeapon(state!), what: 'compra arma');

  void buyForge() => _set(_engine.buyForge(state!), what: 'templa el arma');

  void buyRemove(int uid) => _set(_engine.buyRemove(state!, uid), what: 'paga quitar carta');

  void buyUpgrade(int uid) => _set(_engine.buyUpgrade(state!, uid), what: 'paga mejorar carta');

  void buyTea() => _set(_engine.buyTea(state!), what: 'compra té');

  void leaveShop() => _set(_engine.leaveShop(state!), what: 'se va del mercader');

  void masterTeach(String formId) => _set(_engine.masterTeach(state!, formId), what: 'maestro enseña $formId');

  void masterUpgrade(int uid) => _set(_engine.masterUpgrade(state!, uid), what: 'maestro mejora carta');

  void masterForge() => _set(_engine.masterForge(state!), what: 'maestro templa el arma');

  void choosePath(Style style) => _set(_engine.choosePath(state!, style), what: 'elige camino ${style.name}');

  void heal() => _set(_engine.fountainHeal(state!), what: 'fuente: descansa');

  void removeCard(int uid) => _set(_engine.fountainRemove(state!, uid), what: 'fuente: quita carta');

  void upgradeCard(int uid) => _set(_engine.fountainUpgrade(state!, uid), what: 'fuente: mejora carta');
}

final runControllerProvider =
    NotifierProvider<RunController, RunState?>(RunController.new);
