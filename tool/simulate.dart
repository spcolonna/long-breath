// ignore_for_file: avoid_print
// Simulador de balance sin interfaz.
//
//   dart run tool/simulate.dart --n 500 --style snake --runs 200
//
// Juega combates aislados (mazo inicial, Vida completa) contra cada enemigo y
// runs completas, con tres bots: aleatorio, codicioso y planificador.
import 'package:long_breath/domain/combat/combat_engine.dart';
import 'package:long_breath/domain/combat/combat_state.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/tutorial.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/sim/bots.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

typedef BotFactory = Bot Function(int seed);

final bots = <String, BotFactory>{
  'aleatorio': RandomBot.new,
  'codicioso': GreedyBot.new,
  'planificador': PlannerBot.new,
};

class CombatStats {
  int played = 0, won = 0, turnsWon = 0, forms = 0, deflects = 0, hpLost = 0;

  String row() {
    final wr = played == 0 ? 0 : won * 100 / played;
    final t = won == 0 ? 0 : turnsWon / won;
    return '${wr.toStringAsFixed(1).padLeft(6)}%  '
        '${t.toStringAsFixed(1).padLeft(5)}  '
        '${(forms / played).toStringAsFixed(2).padLeft(6)}  '
        '${(deflects / played).toStringAsFixed(2).padLeft(6)}  '
        '${(hpLost / played).toStringAsFixed(1).padLeft(6)}';
  }
}

(CombatState, int) playCombat(CombatEngine engine, Bot bot,
    List<CombatCard> deck, String enemy, Style? style, int hp, int seed) {
  var s = engine
      .start(deck: deck, enemyId: enemy, style: style, playerHp: hp, seed: seed)
      .state;
  var steps = 0;
  while (!s.isOver && s.turn <= 40 && steps++ < 2000) {
    s = engine.reduce(s, bot.act(engine, s)).state;
  }
  return (s, s.turn);
}

void main(List<String> args) {
  String opt(String name, String def) {
    final i = args.indexOf('--$name');
    return i >= 0 && i + 1 < args.length ? args[i + 1] : def;
  }

  final n = int.parse(opt('n', '300'));
  final runs = int.parse(opt('runs', '200'));
  final style = Style.parse(opt('style', 'snake'));
  final baseSeed = int.parse(opt('seed', '1'));

  final data = loadGameDataFromDir();
  final engine = CombatEngine(data);
  final runEngine = RunEngine(data);
  final starter = [
    for (final (i, id) in data.starterDeck.indexed) CombatCard(uid: i, cardId: id),
  ];

  print('Long Breath — simulador de balance');
  print('estilo: ${style.name}, combates por enemigo: $n, runs: $runs\n');

  final winRates = <String, Map<String, double>>{};
  for (final enemy in data.enemies.keys.where((e) => e != tutorialEnemy)) {
    print('== $enemy (${data.enemy(enemy).rank.name})');
    print('bot            victoria  turnos  formas  desvíos  vida perdida');
    for (final MapEntry(key: name, value: make) in bots.entries) {
      final st = CombatStats();
      for (var i = 0; i < n; i++) {
        final bot = make(baseSeed * 7919 + i);
        final (s, turns) = playCombat(engine, bot, starter, enemy, style,
            data.balance.playerHp, baseSeed * 104729 + i);
        st.played++;
        if (s.phase == CombatPhase.won) {
          st.won++;
          st.turnsWon += turns;
        }
        st.forms += s.formsCompleted.values.fold(0, (a, b) => a + b);
        st.deflects += s.deflects;
        st.hpLost += data.balance.playerHp - s.player.hp;
      }
      winRates.putIfAbsent(enemy, () => {})[name] = st.won * 100 / st.played;
      print('${name.padRight(14)} ${st.row()}');
    }
    final gap = winRates[enemy]!['planificador']! - winRates[enemy]!['aleatorio']!;
    print('diferencia planificador − aleatorio: ${gap.toStringAsFixed(1)} pp\n');
  }

  print('== Runs completas (novicio hasta el santuario, después --style si sale)');
  print('bot            victoria  llega al guardián  nodo medio de derrota');
  for (final MapEntry(key: name, value: make) in bots.entries) {
    var won = 0, reachedBoss = 0, deathDepth = 0;
    for (var i = 0; i < runs; i++) {
      final bot = make(baseSeed * 31 + i);
      var r = runEngine.newRun(seed: baseSeed * 7 + i);
      while (r.phase != RunPhase.victory && r.phase != RunPhase.defeat) {
        switch (r.phase) {
          case RunPhase.map:
            r = runEngine.enter(r, bot.pickPath(runEngine.available(r)));
          case RunPhase.combat:
            final (seed, next) = runEngine.combatSeed(r);
            r = next;
            final enemy = runEngine.enemyOf(r);
            if (runEngine.node(r.currentNode!).type == NodeType.combat &&
                enemy == 'dragon') {
              reachedBoss++;
            }
            final (s, _) =
                playCombat(engine, bot, r.deck, enemy, r.style, r.hp, seed);
            r = runEngine.finishCombat(r,
                won: s.phase == CombatPhase.won, hp: s.player.hp);
          case RunPhase.reward:
            r = runEngine.chooseReward(r, bot.pickReward(runEngine, r));
          case RunPhase.fountain:
            r = bot.useFountain(runEngine, r);
          case RunPhase.shrine:
            // Toma el camino pedido si el santuario lo ofrece.
            r = runEngine.choosePath(r,
                r.pathOptions.contains(style) ? style : r.pathOptions.first);
          case RunPhase.victory || RunPhase.defeat:
            break;
        }
      }
      if (r.phase == RunPhase.victory) {
        won++;
      } else {
        deathDepth += r.visited.length;
      }
    }
    final lost = runs - won;
    print('${name.padRight(14)} '
        '${(won * 100 / runs).toStringAsFixed(1).padLeft(6)}%  '
        '${(reachedBoss * 100 / runs).toStringAsFixed(1).padLeft(15)}%  '
        '${lost == 0 ? '-' : (deathDepth / lost).toStringAsFixed(1)}');
  }
}
