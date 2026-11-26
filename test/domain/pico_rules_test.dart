import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/room.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/infrastructure/progress_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Los Picos traen reglas, no solo números: niebla, campanas, élites con
/// dos preguntas, aire fino y un jefe que se levanta una vez más. Ganar en
/// un Pico deja la marca del camino.
void main() {
  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);
  final deck = [
    for (var i = 0; i < 10; i++) CombatCard(uid: i, cardId: 'ge_dang'),
  ];

  CombatState start({
    int pico = 0,
    String enemy = 'bat',
    RoomRule? room,
  }) =>
      engine
          .start(
            deck: deck,
            enemyId: enemy,
            style: null,
            playerHp: 50,
            seed: 3,
            pico: pico,
            room: room,
          )
          .state;

  test('Pico 2: la niebla tapa el primer turno de cada pelea', () {
    expect(engine.intentView(start(pico: 1)).hidden, isFalse);
    final s = start(pico: 2);
    expect(engine.intentView(s).hidden, isTrue);
    final next = engine.reduce(s, const EndTurn()).state;
    expect(next.turn, 2);
    expect(engine.intentView(next).hidden, isFalse);
  });

  test('Pico 4: élites y jefes pelean con campana; los comunes no', () {
    expect(start(pico: 3, enemy: 'monk').trial.room, isNull);
    expect(start(pico: 4, enemy: 'monk').trial.room, RoomRule.bell);
    expect(start(pico: 4, enemy: 'dragon').trial.room, RoomRule.bell);
    expect(start(pico: 4).trial.room, isNull);
    // La condición de la sala manda.
    expect(
      start(pico: 4, enemy: 'monk', room: RoomRule.wind).trial.room,
      RoomRule.wind,
    );
  });

  test('Pico 6: cada élite suma su segunda pregunta', () {
    expect(start(pico: 5, enemy: 'lion').enemy.regen, 0);
    final lion = start(pico: 6, enemy: 'lion').enemy;
    expect((lion.regen, lion.thorns), (3, 0));
    expect(start(pico: 6, enemy: 'iron_abbot').enemy.furyStep, 2);
    expect(start(pico: 6, enemy: 'monk').enemy.thorns, 1);
    // Todos los élites tienen una segunda pregunta.
    for (final e in data.enemies.values.where((e) => e.rank == EnemyRank.elite)) {
      final s = e.second;
      expect(s.thorns + s.regen + s.fury, greaterThan(0), reason: e.id);
    }
    // El común no.
    final bat = start(pico: 6).enemy;
    expect((bat.regen, bat.thorns, bat.furyStep), (0, 0, 0));
  });

  test('Pico 8: aire fino hasta que respirás', () {
    final base = start(pico: 7);
    final thin = start(pico: 8);
    expect(thin.trial.thinAir, 1);
    expect(thin.player.breath, base.player.breath - 1);
    // Respirar lo despeja: el turno siguiente vuelve el Aliento entero.
    expect(thin.breathesLeft, greaterThan(0));
    final breathed = engine
        .reduce(thin, const Breathe(BreatheMode.breath))
        .state;
    expect(breathed.trial.thinAir, 0);
    final next = engine.reduce(breathed, const EndTurn()).state;
    final baseNext = engine.reduce(base, const EndTurn()).state;
    expect(next.player.breath, baseNext.player.breath);
  });

  test('Pico 10: el jefe se levanta una vez más', () {
    final normal = engine.phasesOf('dragon', false);
    final extra = engine.phasesOf('dragon', true);
    expect(extra, hasLength(normal.length + 1));
    expect(extra.last.hpThreshold, normal.last.hpThreshold! / 2);
    expect(start(pico: 9, enemy: 'dragon').enemy.extraPhase, isFalse);
    expect(start(pico: 10, enemy: 'dragon').enemy.extraPhase, isTrue);
    expect(start(pico: 10, enemy: 'monk').enemy.extraPhase, isFalse);
  });

  test('ganar en un Pico deja la marca del camino (la más alta)', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = ProgressStorage();
    expect(await storage.picoMarks(), isEmpty);
    // Sin Pico, o en Fácil, no hay marca.
    await storage.markPicoWin(Difficulty.normal, 0, style: Style.tiger);
    await storage.markPicoWin(Difficulty.easy, 3, style: Style.tiger);
    expect(await storage.picoMarks(), isEmpty);
    await storage.markPicoWin(Difficulty.normal, 3, style: Style.tiger);
    await storage.markPicoWin(Difficulty.normal, 1, style: Style.tiger);
    await storage.markPicoWin(Difficulty.normal, 2, style: Style.crane);
    expect(await storage.picoMarks(), {Style.tiger: 3, Style.crane: 2});
  });
}
