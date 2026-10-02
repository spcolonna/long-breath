// Laboratorio de balance: datos con palancas, prototipo de 3 etapas, Picos,
// talismanes y la simulación de una run completa con métricas.
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:long_breath/domain/combat/combat_action.dart';
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_event.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/model/game_data.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/sim/bots.dart';

typedef Json = Map<String, dynamic>;

Json _clone(Object o) => jsonDecode(jsonEncode(o)) as Json;

// ------------------------------------------------------------------ datos

/// Los JSON crudos del juego; las palancas y el prototipo los transforman
/// antes de construir el [GameData].
class RawData {
  RawData(this.files);

  factory RawData.load([String dir = 'assets/data']) => RawData({
        for (final f in GameData.fileNames)
          f: jsonDecode(File('$dir/$f').readAsStringSync()) as Json,
      });

  final Map<String, Json> files;

  /// Cambia un valor: las listas se indexan por `id` (p. ej. `pi_quan.damage`).
  void set(String file, List<String> keys, num value) {
    Object node = files[file]!;
    for (final (i, k) in keys.indexed) {
      final last = i == keys.length - 1;
      if (node is Map) {
        if (last) {
          node[k] = value;
          return;
        }
        if (node.containsKey(k)) {
          node = node[k] as Object;
        } else {
          // Buscar en la primera lista del mapa (cards, enemies, stances, forms).
          final list = node.values.whereType<List>().first;
          node = list.firstWhere((e) => (e as Map)['id'] == k) as Object;
        }
      } else if (node is List) {
        node = node.firstWhere((e) => (e as Map)['id'] == k) as Object;
        if (last) throw ArgumentError('Ruta incompleta: $keys');
      }
    }
  }

  RawData copy() => RawData({for (final e in files.entries) e.key: _clone(e.value)});

  List<Json> get enemies => (files['enemies.json']!['enemies'] as List).cast<Json>();
  Json get balance => files['game_balance.json']!;

  GameData build() => GameData.fromJson(
        cards: files['cards.json']!,
        stances: files['stances.json']!,
        forms: files['forms.json']!,
        enemies: files['enemies.json']!,
        balance: files['game_balance.json']!,
        talismans: files['talismans.json'],
        events: files['events.json'],
      );
}

/// Multiplica Vida, Estructura y daño de un enemigo (los muñecos no se tocan).
void scaleEnemy(Json e, {double hp = 1, double dmg = 1, double str = 1}) {
  int r(num v, double m) => (v * m).round();
  e['hp'] = r(e['hp'] as int, hp);
  e['structure'] = r(e['structure'] as int, str);
  for (final p in e['phases'] as List) {
    for (final i in (p as Json)['pattern'] as List) {
      final intent = i as Json;
      for (final k in ['damage', 'structure', 'value']) {
        if (intent[k] is int && intent['kind'] != 'discard') {
          intent[k] = r(intent[k] as int, k == 'structure' ? math.sqrt(dmg) : dmg);
        }
      }
    }
  }
  final punish = e['sameStancePunish'] as Json?;
  if (punish != null) punish['damage'] = r(punish['damage'] as int, dmg);
}

/// Palancas de exploración: multiplicadores por rango sobre los datos reales.
class Levers {
  Levers({this.hp = const {}, this.dmg = const {}, this.str = const {}});

  final Map<String, double> hp, dmg, str;

  bool get isEmpty => hp.isEmpty && dmg.isEmpty && str.isEmpty;

  void apply(RawData d) {
    for (final e in d.enemies) {
      if ((e['id'] as String).startsWith('dummy')) continue;
      final rank = e['rank'] as String;
      double m(Map<String, double> x) => x[rank] ?? x['all'] ?? 1;
      scaleEnemy(e, hp: m(hp), dmg: m(dmg), str: m(str));
    }
  }

  /// "1.8" o "common=1.8,elite=1.5,boss=1.4".
  static Map<String, double> parse(String? s) {
    if (s == null) return const {};
    if (!s.contains('=')) return {'all': double.parse(s)};
    return {
      for (final part in s.split(','))
        part.split('=')[0]: double.parse(part.split('=')[1]),
    };
  }
}

// --------------------------------------------------------- prototipo futuro

/// Curva de las etapas futuras: cuánto crecen los enemigos por etapa.
/// Se pueden cambiar desde la línea de comandos (--curve, --fountains).
var stageHp = [1.0, 1.1, 1.2];
var stageDmg = [1.0, 1.05, 1.1];
var stageStr = [1.0, 1.05, 1.1];
const floorsPerStage = 13;

/// Probabilidad de que un nodo de piso (desde el 3) sea una fuente.
var fountainRate = 0.3;

/// Vida que se recupera al vencer al jefe de una etapa (fracción del máximo).
var bossHeal = 1.0;

const _commons = ['bat', 'salamander', 'golem', 'disciple'];

/// Agrega las copias escaladas de los enemigos para las etapas 2 y 3.
void addStageEnemies(RawData d) {
  final base = {for (final e in d.enemies) e['id'] as String: e};
  for (var k = 1; k < stageHp.length; k++) {
    for (final id in [..._commons, 'monk', 'dragon']) {
      final e = _clone(base[id]!)..['id'] = '${id}_s${k + 1}';
      scaleEnemy(e, hp: stageHp[k], dmg: stageDmg[k], str: stageStr[k]);
      d.enemies.add(e);
    }
  }
}

String _stageId(String id, int stage) => stage == 0 ? id : '${id}_s${stage + 1}';

/// Mapa de prueba de 3 etapas generado con la semilla de la run.
/// Reglas por piso: santuario en el 4 de la etapa 1, élite desde el piso 5,
/// fuente antes del jefe, dos caminos por piso.
List<Json> generateMap(int seed, {int stages = 3}) {
  final rnd = math.Random(seed);
  final floors = <List<Json>>[];
  for (var st = 0; st < stages; st++) {
    for (var f = 1; f <= floorsPerStage; f++) {
      final id = 's${st}f$f';
      if (f == floorsPerStage) {
        floors.add([
          {'id': '${id}a', 'type': 'combat', 'enemy': _stageId('dragon', st)},
        ]);
      } else if (f == floorsPerStage - 1) {
        floors.add([
          {'id': '${id}a', 'type': 'fountain'},
        ]);
      } else if (st == 0 && f == 4) {
        floors.add([
          {'id': '${id}a', 'type': 'shrine'},
        ]);
      } else {
        floors.add([
          for (final side in ['a', 'b'])
            () {
              final roll = rnd.nextDouble();
              if (f >= 5 && roll < 0.18) {
                return <String, dynamic>{'id': '$id$side', 'type': 'combat', 'enemy': _stageId('monk', st)};
              }
              if (f >= 3 && roll > 1 - fountainRate) return <String, dynamic>{'id': '$id$side', 'type': 'fountain'};
              final c = _commons[rnd.nextInt(_commons.length)];
              return <String, dynamic>{'id': '$id$side', 'type': 'combat', 'enemy': _stageId(c, st)};
            }(),
        ]);
      }
    }
  }
  for (var i = 0; i < floors.length; i++) {
    final next = i + 1 < floors.length
        ? [for (final n in floors[i + 1]) n['id'] as String]
        : <String>[];
    for (final n in floors[i]) {
      n['next'] = next;
    }
  }
  return [for (final f in floors) ...f];
}

// ------------------------------------------------------------------ Picos

// Los Picos son del juego (game_balance.json → picos): la run los aplica
// con `pico`, igual que la app.

// -------------------------------------------------------------- talismanes

/// Ids de los talismanes del juego, en el orden de los datos.
List<String> talismanIds(GameData data) => data.talismans.keys.toList();

// ------------------------------------------------------------- métricas

class FightLog {
  FightLog(this.enemy, this.rank);

  final String enemy;
  final EnemyRank rank;
  bool won = false;
  int turns = 0, hpLost = 0, forms = 0, deflects = 0, staggers = 0, plays = 0;
  final stanceUse = <Stance, int>{};
}

class RunLog {
  bool won = false;
  int nodes = 0, fountains = 0, shrines = 0, events = 0;
  int merchants = 0, masters = 0, jadeSpent = 0;
  int? hpAtBoss;
  Style? style;
  final fights = <FightLog>[];
  final offered = <String>{};
  final picked = <String>[];

  /// Formas aprendidas en la run.
  final learned = <String>[];
  final talismans = <String>[];

  /// Modelo de tiempo: 5 s por carta, 6 s por turno (incluye la animación
  /// del rival), 15 s por pantalla de mapa/recompensa/fuente, 30 s el santuario
  /// 30 s cada evento (leer la escena y decidir), 40 s el mercader y 25 s
  /// el maestro.
  double get seconds {
    var t = 0.0;
    for (final f in fights) {
      t += f.plays * 5 + f.turns * 6 + 10;
    }
    return t + nodes * 15 + fountains * 15 + shrines * 30 + events * 30 +
        merchants * 40 + masters * 25;
  }

  /// Mazo al terminar (cuenta cartas de eventos y las que se pierden).
  int deckSize = 12;
}

// ------------------------------------------------------------- simulación

typedef BotFactory = Bot Function(int seed);

/// Torpeza del perfil promedio (fracción de turnos en piloto automático).
double sloppiness = 0.25;

final profiles = <String, BotFactory>{
  'novato': NoviceBot.new,
  'promedio': (seed) => AverageBot(seed, sloppiness: sloppiness),
  'experto': ExpertBot.new,
  'aleatorio': RandomBot.new,
  'codicioso': GreedyBot.new,
};

FightLog playFight(CombatEngine engine, Bot bot, List<CombatCard> deck,
    String enemy, Style? style, int hp, int seed, List<String> talismans,
    {Difficulty difficulty = Difficulty.normal,
    int pico = 0,
    int? maxHp,
    Iterable<String>? forms}) {
  final log = FightLog(enemy, engine.data.enemy(enemy).rank);
  var s = engine
      .start(
          deck: deck,
          enemyId: enemy,
          style: style,
          playerHp: hp,
          seed: seed,
          difficulty: difficulty,
          pico: pico,
          maxHp: maxHp,
          forms: forms,
          talismans: talismans)
      .state;
  var steps = 0;
  while (!s.isOver && s.turn <= 40 && steps++ < 3000) {
    final action = bot.act(engine, s);
    if (action is PlayCard) {
      log.plays++;
      log.stanceUse[s.player.stance] = (log.stanceUse[s.player.stance] ?? 0) + 1;
    }
    final r = engine.reduce(s, action);
    s = r.state;
    log.staggers += r.events.whereType<EnemyBroken>().length;
  }
  log.won = s.phase == CombatPhase.won;
  log.turns = s.turn;
  log.hpLost = hp - math.max(0, s.player.hp);
  log.forms = s.formsCompleted.values.fold(0, (a, b) => a + b);
  log.deflects = s.deflects;
  _lastHp = s.player.hp;
  return log;
}

int _lastHp = 0;

/// Juega una run entera. [wanted] es el camino que el bot toma si el
/// santuario lo ofrece.
RunLog playRun(GameData data, Bot bot, int seed,
    {Style? wanted,
    bool withTalismans = false,
    Set<String>? onlyTalisman,
    List<String> startTalismans = const [],
    List<String> startCards = const [],
    Difficulty difficulty = Difficulty.normal,
    int pico = 0}) {
  final engine = CombatEngine(data);
  final runEngine = RunEngine(data);
  final log = RunLog();
  final tRng = math.Random(seed * 13 + 5);
  var r = runEngine.newRun(seed: seed, difficulty: difficulty, pico: pico);
  for (final id in startCards) {
    r = r.copyWith(
        deck: [...r.deck, CombatCard(uid: r.nextUid, cardId: id)],
        nextUid: r.nextUid + 1);
  }
  for (final id in startTalismans) {
    r = runEngine.addTalisman(r, id);
  }
  while (r.phase != RunPhase.victory && r.phase != RunPhase.defeat) {
    switch (r.phase) {
      case RunPhase.map:
        log.nodes++;
        r = runEngine.enter(r, _route(runEngine, bot, r));
      case RunPhase.combat:
        final (cs, next) = runEngine.combatSeed(r);
        r = next;
        final enemy = runEngine.enemyOf(r);
        if (r.node(r.currentNode!).next.isEmpty) log.hpAtBoss = r.hp;
        final f = playFight(engine, bot, r.deck, enemy, r.style, r.hp, cs, r.talismans,
            difficulty: r.difficulty, pico: r.pico, maxHp: r.maxHp, forms: r.knownForms);
        log.fights.add(f);
        var hp = math.min(r.maxHp, math.max(0, _lastHp));
        if (f.won && f.rank == EnemyRank.boss) {
          hp = math.min(r.maxHp, hp + (r.maxHp * bossHeal).round());
        }
        r = runEngine.finishCombat(r, won: f.won, hp: hp);
        // Prototipo de 3 etapas: los jefes intermedios también dejan un
        // talismán (el élite ya lo da el motor de la run).
        if (f.won && withTalismans && f.rank == EnemyRank.boss &&
            r.phase != RunPhase.victory) {
          final pool = runEngine
              .missingTalismans(r)
              .where((t) => onlyTalisman == null || onlyTalisman.contains(t))
              .toList();
          if (pool.isNotEmpty) {
            final t = pool[tRng.nextInt(pool.length)];
            log.talismans.add(t);
            r = runEngine.addTalisman(r, t);
          }
        }
      case RunPhase.talisman:
        final t = bot.pickTalisman(runEngine, r);
        log.talismans.add(t);
        r = runEngine.chooseTalisman(r, t);
      case RunPhase.event:
        log.events++;
        r = runEngine.resolveEvent(r, bot.pickEventOption(runEngine, r));
      case RunPhase.reward:
        log.offered.addAll(r.rewardOptions);
        final pick = bot.pickReward(runEngine, r);
        if (bot.learnForm(runEngine, r, pick)) {
          log.learned.add(r.rewardForm!);
          r = runEngine.chooseForm(r, r.rewardForm!);
        } else {
          if (pick != null) log.picked.add(pick);
          r = runEngine.chooseReward(r, pick);
        }
      case RunPhase.merchant:
        log.merchants++;
        final before = r.jade;
        r = bot.shop(runEngine, r);
        log.jadeSpent += before - r.jade;
      case RunPhase.master:
        log.masters++;
        r = bot.master(runEngine, r);
      case RunPhase.fountain:
        log.fountains++;
        r = bot.useFountain(runEngine, r);
      case RunPhase.shrine:
        log.shrines++;
        r = runEngine.choosePath(
            r,
            wanted != null && r.pathOptions.contains(wanted)
                ? wanted
                : r.pathOptions[tRng.nextInt(r.pathOptions.length)]);
      case RunPhase.victory || RunPhase.defeat:
        break;
    }
  }
  log.won = r.phase == RunPhase.victory;
  log.style = r.style;
  log.deckSize = r.deck.length;
  return log;
}

/// GameData con un mapa de 3 etapas distinto para cada semilla.
GameData protoData(RawData base, int seed) {
  final d = base.copy();
  final run = d.balance['run'] as Json;
  final nodes = generateMap(seed);
  run['nodes'] = nodes;
  run['start'] = nodes.first['id'];
  // El primer piso tiene dos nodos; el motor arranca en uno solo.
  final first = nodes.where((n) => (n['id'] as String).startsWith('s0f1')).toList();
  if (first.length > 1) {
    nodes.remove(first[1]);
  }
  return d.build();
}

/// Elección de camino en el mapa: los perfiles que piensan van a la fuente
/// si les falta Vida y esquivan la élite si están golpeados.
String _route(RunEngine run, Bot bot, RunState r) {
  final options = run.available(r);
  if (bot is NoviceBot || bot is RandomBot || options.length < 2) {
    return bot.pickPath(options);
  }
  final ratio = r.hp / r.maxHp;
  double score(String id) {
    final n = r.node(id);
    if (n.type == NodeType.fountain) return ratio < 0.6 ? 3 : 0.5;
    if (n.type == NodeType.merchant) {
      return r.jade >= run.data.balance.merchant.card ? 1.5 : 0.5;
    }
    if (n.type == NodeType.master) return 1.2;
    if (n.type != NodeType.combat) return 1;
    final rank = run.data.enemy(n.enemy!).rank;
    if (rank == EnemyRank.elite) return ratio > 0.7 ? 2 : -1;
    return 1;
  }

  // Desempate al azar: entre dos combates comunes cualquiera vale.
  final scored = {for (final o in options) o: score(o) + bot.random.nextDouble() * 0.1};
  final sorted = [...options]..sort((a, b) => scored[b]!.compareTo(scored[a]!));
  return sorted.first;
}
