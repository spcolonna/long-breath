import 'dart:math' as math;

import '../combat/combat_action.dart';
import '../combat/combat_engine.dart';
import '../combat/combat_state.dart';
import '../model/card_def.dart';
import '../model/enemy_def.dart';
import '../model/enums.dart';
import '../model/event_def.dart';
import '../model/form_def.dart';
import '../run/run_engine.dart';
import '../run/run_state.dart';

/// Un jugador automático para el simulador de balance.
abstract class Bot {
  Bot(int seed) : random = math.Random(seed);

  final math.Random random;

  String get name;

  CombatAction act(CombatEngine engine, CombatState s);

  /// Si aprende la forma ofrecida en vez de la carta [cardPick].
  bool learnForm(RunEngine run, RunState r, String? cardPick) => false;

  /// Recompensa elegida (null = saltear).
  String? pickReward(RunEngine run, RunState r) =>
      r.rewardOptions[random.nextInt(r.rewardOptions.length)];

  RunState useFountain(RunEngine run, RunState r) => run.fountainHeal(r);

  String pickPath(List<String> options) =>
      options[random.nextInt(options.length)];

  /// Talismán elegido entre los que ofrece el élite.
  String pickTalisman(RunEngine run, RunState r) =>
      r.talismanOptions[random.nextInt(r.talismanOptions.length)];

  /// Opción elegida en un evento (entre las que puede pagar).
  String pickEventOption(RunEngine run, RunState r) {
    final options = [
      for (final o in run.data.event(r.eventId!).options)
        if (run.canChoose(r, o)) o.id,
    ];
    return options[random.nextInt(options.length)];
  }

  CombatAction discard(CombatState s) =>
      ChooseDiscard(s.hand[random.nextInt(s.hand.length)].uid);

  /// Compras en el mercader: una carta al azar si alcanza, y se va.
  RunState shop(RunEngine run, RunState r) {
    if (r.shopCards.isNotEmpty) {
      final id = r.shopCards[random.nextInt(r.shopCards.length)];
      if (run.canAfford(r, run.cardPrice(r, id))) r = run.buyCard(r, id);
    }
    return run.leaveShop(r);
  }

  /// Con el maestro: la primera forma que ofrece, o mejorar una carta.
  RunState master(RunEngine run, RunState r) {
    if (r.masterForms.isNotEmpty) return run.masterTeach(r, r.masterForms.first);
    final pool = [for (final c in r.deck) if (run.canUpgrade(c)) c];
    return run.masterUpgrade(r, pool[random.nextInt(pool.length)].uid);
  }
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
      final d = data.card(c.cardId);
      var v = d.damage + d.structure + d.retainedDamage + d.retainedStructure;
      if (d.cost > 0) v += 2;
      for (final f in engine.knownForms(s)) {
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
    // En un grupo cuenta la Vida de los que esperan: si no, voltear al
    // primero (y que entre otro entero) parecería empeorar.
    final waiting = s.reserve.fold(0, (a, x) => a + x.hp);
    var v = -(e.hp + waiting) * 3.0 + s.player.hp * 2.0;
    if (e.staggered) {
      v += 14;
    } else {
      v -= e.structure / e.maxStructure * 10;
    }
    v += s.player.breath * 2.0;
    v += s.player.structure * 0.4;
    for (final f in engine.knownForms(s)) {
      v += s.formProgress[f.id]! / f.steps.length * effectValue(f.effect) * 1.2;
    }
    return v;
  }

  @override
  bool learnForm(RunEngine run, RunState r, String? cardPick) =>
      prefersForm(run, r, cardPick, 0);

  /// Té si viene golpeado, talismán si alcanza, después la mejor carta y,
  /// con lo que sobre, quitar la carta inicial más floja.
  @override
  RunState shop(RunEngine run, RunState r) {
    final m = run.merchantOf(r);
    if (!r.shopTea && r.hp <= r.maxHp * 0.6 && run.canAfford(r, m.tea)) {
      r = run.buyTea(r);
    }
    if (r.shopTalisman != null && run.canAfford(r, m.talisman)) {
      r = run.buyTalisman(r);
    }
    final cards = [...r.shopCards]..sort((a, b) => cardValue(run.data.card(b))
        .compareTo(cardValue(run.data.card(a))));
    if (cards.isNotEmpty &&
        cardValue(run.data.card(cards.first)) > 4 &&
        run.canAfford(r, run.cardPrice(r, cards.first))) {
      r = run.buyCard(r, cards.first);
    }
    if (!r.shopRemoved && run.canAfford(r, m.remove)) {
      final starters = [
        for (final c in r.deck)
          if (run.data.card(c.cardId).pool == 'starter') c,
      ]..sort((a, b) => cardValue(run.data.card(a.cardId))
          .compareTo(cardValue(run.data.card(b.cardId))));
      if (starters.isNotEmpty) r = run.buyRemove(r, starters.first.uid);
    }
    if (!r.shopUpgraded &&
        run.canAfford(r, m.upgrade) &&
        r.deck.any((c) => run.canUpgrade(c))) {
      r = run.buyUpgrade(r, bestUpgrade(run, r));
    }
    return run.leaveShop(r);
  }

  /// La forma que más rinde con el mazo actual; si ninguna vale, mejora.
  @override
  RunState master(RunEngine run, RunState r) {
    String? best;
    var bestV = 4.0;
    for (final id in r.masterForms) {
      final v = formValue(run, r, run.data.forms.firstWhere((f) => f.id == id));
      if (v > bestV) {
        bestV = v;
        best = id;
      }
    }
    return best != null
        ? run.masterTeach(r, best)
        : run.masterUpgrade(r, bestUpgrade(run, r));
  }

  @override
  String pickTalisman(RunEngine run, RunState r) => r.talismanOptions
      .reduce((a, b) => talismanValue(b) > talismanValue(a) ? b : a);

  @override
  String pickEventOption(RunEngine run, RunState r) {
    final options = [
      for (final o in run.data.event(r.eventId!).options)
        if (run.canChoose(r, o)) o,
    ];
    return options
        .reduce((a, b) =>
            eventOptionValue(run, r, b) > eventOptionValue(run, r, a) ? b : a)
        .id;
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
        '${s.dingbuUsed}|${s.formProgress.values.join(',')}|${s.wave}|${s.enemy.hp}|'
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
  // Respirar cuesta: solo si después queda Aliento para jugar algo.
  if (s.breathesLeft <= 0 || s.hand.isEmpty) return false;
  if (s.player.breath <= engine.data.balance.breatheCost) return false;
  if (engine.validate(s, const Breathe()) != null) return false;
  for (final c in s.hand) {
    final def = engine.data.card(c.cardId);
    if (def.type.isAttack && engine.costOf(s, def) <= s.player.breath) return false;
  }
  return true;
}

/// Valor de lo que da una forma al completarse, en "daño equivalente".
double effectValue(FormEffect e) =>
    e.damage +
    e.structure * 0.8 +
    e.guard * 0.7 +
    e.draw * 2.5 +
    e.breath * 3 +
    e.heal * 0.8 +
    e.fistBonus * 6;

/// Valor de aprender una forma con este mazo: cuánto rinde por lo que cuesta
/// armarla y qué parte de sus pasos ya tenés.
double formValue(RunEngine run, RunState r, FormDef f) {
  final deck = [for (final c in r.deck) c.cardId];
  final owned = f.steps.toSet().where(deck.contains).length /
      f.steps.toSet().length;
  // Se repite en cada combate: vale más que su golpe suelto por paso.
  return effectValue(f.effect) / f.steps.length * owned * owned * 1.8;
}

/// Comparación forma vs carta para los bots que planifican.
/// Valor de un talismán según lo que mide el simulador (`balance.md`).
double talismanValue(String id) => const {
      'grieta': 12.0, 'victoria': 11.0, 'aliento': 10.0, 'vida': 8.0,
      'primer': 7.0, 'fuente': 7.0, 'roca': 5.0, 'arco': 3.0,
      'desvio': 3.0, 'formas': 2.0,
    }[id] ??
    4.0;

/// Lo que vale 1 de jade frente a 1 punto de las otras ganancias (un
/// talismán, 7 puntos, cuesta 50 de jade).
const jadeWorth = 0.15;

/// Valor esperado de una opción de evento: la Vida pesa más cuanto menos
/// queda.
double eventOptionValue(RunEngine run, RunState r, EventOptionDef o) {
  final missing = r.maxHp - r.hp;
  final hpWeight = 0.4 + (1 - r.hp / r.maxHp);
  double value(EventOutcome e) {
    var v = -e.hp * hpWeight + math.min(e.heal, missing) * hpWeight + e.maxHp * 1.5 +
        e.jade * jadeWorth;
    v += switch (e.gain) {
      null => 0.0,
      EventGain.form => run.learnableForms(r).isEmpty ? 3.0 : 6.0,
      EventGain.talisman => 7.0,
      EventGain.rareTalisman => 10.0,
      EventGain.card => 3.0,
      EventGain.upgrade => 4.0,
      EventGain.loseStarter => 2.0,
    };
    return v;
  }

  final chance = o.chance;
  final price = o.price * jadeWorth;
  if (chance == null) return value(o.outcome) - price;
  return value(o.outcome) * chance / 100 +
      value(o.failure!) * (100 - chance) / 100 -
      price;
}

bool prefersForm(RunEngine run, RunState r, String? cardPick, double margin) {
  final id = r.rewardForm;
  if (id == null) return false;
  final f = run.data.forms.firstWhere((f) => f.id == id);
  final card = cardPick == null ? 0.0 : cardValue(run.data.card(cardPick));
  return formValue(run, r, f) > card + margin;
}

/// Valor heurístico de una carta de recompensa para un jugador razonable.
double cardValue(CardDef d) {
  var v = d.damage + d.structure * 0.8 + d.guard * 0.7;
  v += d.draw * 2.5 + d.gainBreath * 3 + d.turnStructureBonus * 2;
  v += d.bonusDamageIfStaggered * 0.4 + d.onDeflectDamage * 0.4;
  v += d.onDeflectStructure * 0.4;
  // Cadena: se cuentan ~1,5 ataques previos; retenida: la mitad de las veces.
  v += d.chainDamage * 1.5 + d.chainStructure * 1.2;
  v += d.retainedDamage * 0.5 + d.retainedStructure * 0.4;
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
  bool learnForm(RunEngine run, RunState r, String? cardPick) =>
      prefersForm(run, r, cardPick, random.nextDouble() * 3 - 1.5);

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
    return run.fountainUpgrade(r, bestUpgrade(run, r));
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
    return run.fountainUpgrade(r, bestUpgrade(run, r));
  }
}

/// El ataque más barato y frecuente del mazo es el que más rinde mejorado.
int bestUpgrade(RunEngine run, RunState r) {
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
