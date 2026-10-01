import 'dart:math' as math;

import '../combat/combat_action.dart';
import '../combat/combat_engine.dart';
import '../combat/combat_state.dart';
import '../model/card_def.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../run/run_engine.dart';
import '../run/run_state.dart';

/// Un jugador automático para el simulador de balance.
abstract class Bot {
  Bot(int seed) : random = math.Random(seed);

  final math.Random random;

  String get name;

  CombatAction act(CombatEngine engine, CombatState s);

  /// Recompensa elegida (null = saltear).
  String? pickReward(RunEngine run, RunState r) =>
      r.rewardOptions[random.nextInt(r.rewardOptions.length)];

  RunState useFountain(RunEngine run, RunState r) => run.fountainHeal(r);

  String pickPath(List<String> options) =>
      options[random.nextInt(options.length)];

  CombatAction discard(CombatState s) =>
      ChooseDiscard(s.hand[random.nextInt(s.hand.length)].uid);
}

/// Juega cartas al azar hasta no poder más.
class RandomBot extends Bot {
  RandomBot(super.seed);

  @override
  String get name => 'aleatorio';

  @override
  CombatAction act(CombatEngine engine, CombatState s) {
    if (s.phase == CombatPhase.discarding) return discard(s);
    final plays = engine.legalActions(s).whereType<PlayCard>().toList();
    if (plays.isEmpty) {
      final retain = [...s.hand]..shuffle(random);
      return EndTurn(
          retain: [for (final c in retain.take(s.retainMax)) c.uid]);
    }
    return plays[random.nextInt(plays.length)];
  }
}

/// Maximiza el daño inmediato; defiende solo con lo que sobra.
class GreedyBot extends Bot {
  GreedyBot(super.seed);

  @override
  String get name => 'codicioso';

  @override
  CombatAction act(CombatEngine engine, CombatState s) {
    if (s.phase == CombatPhase.discarding) return discard(s);
    final plays = engine.legalActions(s).whereType<PlayCard>().toList();
    if (plays.isEmpty) {
      return EndTurn(retain: _bestDamage(engine, s, s.hand, s.retainMax));
    }
    plays.sort((a, b) {
      final pa = engine.preview(s, a.uid), pb = engine.preview(s, b.uid);
      final c = pb.damage.compareTo(pa.damage);
      if (c != 0) return c;
      final c2 = pb.structure.compareTo(pa.structure);
      return c2 != 0 ? c2 : pb.guard.compareTo(pa.guard);
    });
    return plays.first;
  }

  @override
  String? pickReward(RunEngine run, RunState r) {
    final defs = [for (final id in r.rewardOptions) run.data.card(id)];
    defs.sort((a, b) => b.damage.compareTo(a.damage));
    return defs.first.id;
  }

  List<int> _bestDamage(
      CombatEngine engine, CombatState s, List<CombatCard> cards, int n) {
    final sorted = [...cards]..sort((a, b) =>
        engine.data.card(b.cardId).damage.compareTo(engine.data.card(a.cardId).damage));
    return [for (final c in sorted.take(n)) c.uid];
  }
}

/// Busca en el árbol del turno la secuencia con mejor evaluación tras la
/// acción del enemigo: persigue formas, desvíos y desequilibrios.
class PlannerBot extends Bot {
  PlannerBot(super.seed, {this.nodeLimit = 1200, this.breathes = false});

  final int nodeLimit;

  /// Usa Respirar cuando la mano no tiene ningún ataque pagable.
  final bool breathes;

  @override
  String get name => 'planificador';

  @override
  CombatAction act(CombatEngine engine, CombatState s) {
    if (s.phase == CombatPhase.discarding) {
      final uid = _retainOrder(engine, s).last;
      return ChooseDiscard(uid);
    }
    if (breathes && shouldBreathe(engine, s)) return const Breathe();
    final search = _Search(engine, this);
    final best = search.run(s);
    return best ?? EndTurn(retain: _retain(engine, s));
  }

  /// Cartas ordenadas de más a menos valiosas para guardar.
  List<int> _retainOrder(CombatEngine engine, CombatState s) {
    final data = engine.data;
    int value(CombatCard c) {
      var v = data.card(c.cardId).damage + data.card(c.cardId).structure;
      for (final f in data.forms) {
        final p = s.formProgress[f.id]!;
        if (p > 0 && f.steps[p] == c.cardId) v += 30;
      }
      return v;
    }

    final sorted = [...s.hand]..sort((a, b) => value(b).compareTo(value(a)));
    return [for (final c in sorted) c.uid];
  }

  List<int> _retain(CombatEngine engine, CombatState s) =>
      _retainOrder(engine, s).take(s.retainMax).toList();

  double score(CombatEngine engine, CombatState s) {
    if (s.phase == CombatPhase.won) return 1e6 + s.player.hp;
    if (s.phase == CombatPhase.lost) return -1e6;
    final e = s.enemy;
    var v = -e.hp * 3.0 + s.player.hp * 2.0;
    if (e.staggered) {
      v += 14;
    } else {
      v -= e.structure / e.maxStructure * 10;
    }
    v += s.player.breath * 2.0;
    v += s.player.structure * 0.4;
    for (final f in engine.data.forms) {
      v += s.formProgress[f.id]! / f.steps.length * f.effect.damage * 1.2;
    }
    return v;
  }

  @override
  String? pickReward(RunEngine run, RunState r) {
    const priority = [
      'gongbu_tuizhang', 'deng_tui', 'pi_quan', 'hu_zhao', 'ce_chuai',
      'shang_jia', 'tiao_xi', 'hu_bao_tou',
    ];
    for (final id in priority) {
      if (r.rewardOptions.contains(id)) return id;
    }
    return null;
  }

  @override
  RunState useFountain(RunEngine run, RunState r) {
    if (r.hp <= r.maxHp - 15) return run.fountainHeal(r);
    final target = r.deck.firstWhere((c) => c.cardId == 'gongbu_chongquan');
    return run.fountainUpgrade(r, target.uid);
  }
}

class _Search {
  _Search(this.engine, this.bot);

  final CombatEngine engine;
  final PlannerBot bot;
  final _seen = <String>{};
  var _nodes = 0;
  double _bestScore = double.negativeInfinity;
  CombatAction? _bestFirst;

  CombatAction? run(CombatState root) {
    _visit(root, null);
    return _bestFirst;
  }

  String _key(CombatState s) {
    final hand = [for (final c in s.hand) c.uid]..sort();
    return '${hand.join(',')}|${s.player.stance.index}|${s.player.breath}|'
        '${s.dingbuUsed}|${s.formProgress.values.join(',')}|${s.enemy.hp}|'
        '${s.enemy.structure}|${s.player.guard}|${s.player.guardHeight?.index}';
  }

  void _visit(CombatState s, CombatAction? first) {
    if (_nodes++ > bot.nodeLimit) return;
    if (!_seen.add(_key(s))) return;
    // Opción: terminar el turno acá.
    final after = s.isOver
        ? s
        : engine.reduce(s, EndTurn(retain: bot._retain(engine, s))).state;
    final v = bot.score(engine, after);
    if (v > _bestScore) {
      _bestScore = v;
      _bestFirst = first ?? EndTurn(retain: bot._retain(engine, s));
    }
    if (s.isOver) return;
    for (final a in engine.legalActions(s)) {
      if (a is EndTurn || a is Breathe) continue;
      _visit(engine.reduce(s, a).state, first ?? a);
    }
  }
}


/// Respirar conviene si la mano no tiene ningún ataque que se pueda pagar.
bool shouldBreathe(CombatEngine engine, CombatState s) {
  if (s.breathesLeft <= 0 || s.hand.isEmpty || s.player.breath == 0) return false;
  if (engine.validate(s, const Breathe()) != null) return false;
  for (final c in s.hand) {
    final def = engine.data.card(c.cardId);
    if (def.type.isAttack && engine.costOf(s, def) <= s.player.breath) return false;
  }
  return true;
}

/// Valor heurístico de una carta de recompensa para un jugador razonable.
double cardValue(CardDef d) {
  var v = d.damage + d.structure * 0.8 + d.guard * 0.7;
  v += d.draw * 2.5 + d.gainBreath * 3 + d.turnStructureBonus * 2;
  v += d.bonusDamageIfStaggered * 0.4 + d.onDeflectDamage * 0.4;
  v += d.onDeflectStructure * 0.4;
  return v / (d.cost == 0 ? 0.8 : d.cost);
}

/// Jugador nuevo que terminó el tutorial: pega con lo que más daño hace y
/// se defiende de los golpes de 6 o más, pero lee mal la altura una de cada
/// cuatro veces. No planifica posturas ni formas, ni usa Paso en T ni Respirar.
class NoviceBot extends Bot {
  NoviceBot(super.seed);

  @override
  String get name => 'novato';

  int _defendedTurn = -1;

  @override
  CombatAction act(CombatEngine engine, CombatState s) {
    if (s.phase == CombatPhase.discarding) return discard(s);
    final plays = engine.legalActions(s).whereType<PlayCard>().toList();
    CardDef def(PlayCard p) => engine.data.card(s.handCard(p.uid)!.cardId);
    final view = engine.intentView(s);
    final incoming = view.intent.kind == IntentKind.attack && !view.skipped
        ? view.damage * view.intent.hits
        : 0;
    if (incoming >= 6 && _defendedTurn != s.turn) {
      final defenses = plays.where((p) => def(p).type == CardType.defense).toList();
      if (defenses.isNotEmpty) {
        _defendedTurn = s.turn;
        final right =
            defenses.where((p) => def(p).height == view.intent.height).toList();
        // Acierta la altura tres de cada cuatro veces.
        return right.isNotEmpty && random.nextDouble() < 0.75
            ? right.first
            : defenses[random.nextInt(defenses.length)];
      }
    }
    final attacks = plays.where((p) => def(p).type.isAttack).toList()
      ..sort((a, b) => engine
          .preview(s, b.uid)
          .damage
          .compareTo(engine.preview(s, a.uid).damage));
    if (attacks.isNotEmpty) return attacks.first;
    final others = plays.where((p) => def(p).type == CardType.technique).toList();
    if (others.isNotEmpty && random.nextBool()) return others.first;
    final retain = [...s.hand]..shuffle(random);
    return EndTurn(retain: [for (final c in retain.take(s.retainMax)) c.uid]);
  }
}

/// Jugador promedio: piensa el turno con poca profundidad y uno de cada
/// cuatro turnos juega en piloto automático (lo que más pega). Elige
/// recompensas con criterio pero no siempre la mejor.
class AverageBot extends PlannerBot {
  AverageBot(super.seed, {this.sloppiness = 0.25})
      : _greedy = GreedyBot(seed + 1),
        super(nodeLimit: 150, breathes: true);

  final double sloppiness;
  final GreedyBot _greedy;
  int _turn = -1;
  bool _sloppy = false;

  @override
  String get name => 'promedio';

  @override
  CombatAction act(CombatEngine engine, CombatState s) {
    if (s.turn != _turn) {
      _turn = s.turn;
      _sloppy = random.nextDouble() < sloppiness;
    }
    if (_sloppy && s.phase == CombatPhase.playerTurn) {
      return _greedy.act(engine, s);
    }
    return super.act(engine, s);
  }

  @override
  String? pickReward(RunEngine run, RunState r) {
    String? best;
    var bestV = 3.5; // por debajo de esto, mejor no engordar el mazo
    for (final id in r.rewardOptions) {
      final v = cardValue(run.data.card(id)) + random.nextDouble() * 3;
      if (v > bestV) {
        bestV = v;
        best = id;
      }
    }
    return best;
  }

  @override
  RunState useFountain(RunEngine run, RunState r) {
    if (r.hp <= r.maxHp - 12) return run.fountainHeal(r);
    return run.fountainUpgrade(r, _bestUpgrade(run, r));
  }
}

/// Jugador experto: el planificador completo, con Respirar y mejor criterio
/// en recompensas y fuente.
class ExpertBot extends PlannerBot {
  ExpertBot(super.seed) : super(breathes: true);

  @override
  String get name => 'experto';

  @override
  String? pickReward(RunEngine run, RunState r) {
    String? best;
    var bestV = 4.0;
    for (final id in r.rewardOptions) {
      final v = cardValue(run.data.card(id));
      if (v > bestV) {
        bestV = v;
        best = id;
      }
    }
    return best;
  }

  @override
  RunState useFountain(RunEngine run, RunState r) {
    if (r.hp <= r.maxHp - 15) return run.fountainHeal(r);
    return run.fountainUpgrade(r, _bestUpgrade(run, r));
  }
}

/// El ataque más barato y frecuente del mazo es el que más rinde mejorado.
int _bestUpgrade(RunEngine run, RunState r) {
  final counts = <String, int>{};
  for (final c in r.deck) {
    counts[c.cardId] = (counts[c.cardId] ?? 0) + 1;
  }
  CombatCard? best;
  var bestV = -1.0;
  for (final c in r.deck.where(run.canUpgrade)) {
    final d = run.data.card(c.cardId);
    if (!d.type.isAttack) continue;
    final v = counts[c.cardId]! * 2 + d.damage / math.max(1, d.cost) - c.upgrades;
    if (v > bestV) {
      bestV = v;
      best = c;
    }
  }
  return (best ?? r.deck.firstWhere(run.canUpgrade)).uid;
}
