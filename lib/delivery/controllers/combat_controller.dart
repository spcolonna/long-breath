import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_action.dart';
import '../../domain/combat/combat_engine.dart';
import '../../domain/combat/combat_event.dart';
import '../../domain/combat/combat_state.dart';
import '../../domain/model/enums.dart';
import '../tutorial/lessons.dart';
import '../providers.dart';
import 'run_controller.dart';

/// Lo que ve la pantalla de combate: estado, últimos eventos y selección.
class CombatView {
  const CombatView({
    required this.state,
    this.events = const [],
    this.seq = 0,
    this.selected,
    this.retaining = false,
    this.retain = const {},
    this.lessonId,
    this.instance = 0,
  });

  final CombatState state;
  final List<CombatEvent> events;

  /// Crece con cada acción, para que la UI dispare animaciones una sola vez.
  final int seq;
  final int? selected;
  final bool retaining;
  final Set<int> retain;

  /// Lección del tutorial en curso: el combate no pertenece a ninguna run.
  final String? lessonId;
  bool get tutorial => lessonId != null;

  /// Distinto en cada combate nuevo (o lección reiniciada): la pantalla se
  /// arma de cero en vez de arrastrar animaciones del anterior.
  final int instance;

  CombatView copyWith({
    CombatState? state,
    List<CombatEvent>? events,
    int? seq,
    int? Function()? selected,
    bool? retaining,
    Set<int>? retain,
  }) => CombatView(
    state: state ?? this.state,
    events: events ?? this.events,
    seq: seq ?? this.seq,
    selected: selected == null ? this.selected : selected(),
    retaining: retaining ?? this.retaining,
    retain: retain ?? this.retain,
    lessonId: lessonId,
    instance: instance,
  );
}

class CombatController extends Notifier<CombatView?> {
  @override
  CombatView? build() => null;

  CombatEngine get engine => ref.read(combatEngineProvider);

  static int _instances = 0;

  void start() {
    final runCtl = ref.read(runControllerProvider.notifier);
    final (seed, enemy) = runCtl.beginCombat();
    final run = ref.read(runControllerProvider)!;
    final r = engine.start(
      deck: run.deck,
      enemyId: enemy,
      style: run.style,
      playerHp: run.hp,
      maxHp: run.maxHp,
      difficulty: run.difficulty,
      pico: run.pico,
      stage: run.stage,
      seed: seed,
      forms: run.knownForms,
      talismans: run.talismans,
      awakenings: run.awakenings,
    );
    state = CombatView(
      state: r.state,
      events: r.events,
      seq: 1,
      instance: ++_instances,
    );
  }

  /// Lección contra un muñeco de madera, con el mazo en orden fijo.
  void startLesson(String lessonId) {
    final setup = lessonById(lessonId).setup!;
    final r = engine.start(
      deck: [
        for (final (i, id) in setup.deck.indexed)
          CombatCard(uid: i, cardId: id),
      ],
      enemyId: setup.enemyId,
      style: null,
      playerHp: ref.read(dataProvider).balance.playerHp,
      seed: 1,
      shuffle: false,
      forms: setup.forms,
    );
    state = CombatView(
      state: r.state,
      events: r.events,
      seq: 1,
      lessonId: lessonId,
      instance: ++_instances,
    );
  }

  void _dispatch(CombatAction action) {
    final v = state!;
    if (engine.validate(v.state, action) != null) return;
    final r = engine.reduce(v.state, action);
    state = CombatView(
      state: r.state,
      events: r.events,
      seq: v.seq + 1,
      lessonId: v.lessonId,
      instance: v.instance,
    );
  }

  void tapCard(int uid) {
    final v = state!;
    final s = v.state;
    if (s.isOver) return;
    if (s.phase == CombatPhase.discarding) return _dispatch(ChooseDiscard(uid));
    if (v.retaining) {
      final retain = {...v.retain};
      if (!retain.remove(uid)) {
        if (retain.length >= s.retainMax) retain.remove(retain.first);
        retain.add(uid);
      }
      state = v.copyWith(retain: retain);
      return;
    }
    if (v.selected == uid) {
      if (engine.validate(s, PlayCard(uid)) == null) _dispatch(PlayCard(uid));
      return;
    }
    state = v.copyWith(selected: () => uid);
  }

  void clearSelection() => state = state!.copyWith(selected: () => null);

  void dingbu(Stance stance) => _dispatch(Dingbu(stance));

  void breathe() => _dispatch(const Breathe());

  /// Si se puede retener, entra en modo retener; si no, termina el turno.
  void endTurnPressed() {
    final v = state!;
    if (v.state.retainMax > 0 && v.state.hand.isNotEmpty) {
      state = v.copyWith(retaining: true, retain: {}, selected: () => null);
    } else {
      _dispatch(const EndTurn());
    }
  }

  void cancelRetain() => state = state!.copyWith(retaining: false, retain: {});

  void confirmRetain() => _dispatch(EndTurn(retain: state!.retain.toList()));

  /// Vuelca el resultado del combate en la run.
  void finish() {
    final s = state!.state;
    if (state!.tutorial) {
      state = null;
      return;
    }
    ref
        .read(runControllerProvider.notifier)
        .finishCombat(
          won: s.phase == CombatPhase.won,
          hp: s.player.hp,
          fledWith: s.enemy.fled ? s.enemy.stolen : null,
        );
    state = null;
  }
}

final combatControllerProvider =
    NotifierProvider<CombatController, CombatView?>(CombatController.new);
