// ignore_for_file: avoid_print
// Simulador de balance sin interfaz. Imprime tablas en markdown.
//
//   dart run tool/simulate.dart                      # la subida entera (3 etapas)
//   dart run tool/simulate.dart --stages 1           # solo la etapa 1
//   dart run tool/simulate.dart --runs 400 --profile promedio --style all
//   dart run tool/simulate.dart --hp common=1.8,boss=1.5 --dmg 1.2   # palancas
//   dart run tool/simulate.dart --proto --stages 3 --talismans       # prototipo viejo
//   dart run tool/simulate.dart --section picos
//   dart run tool/simulate.dart --section talismans
//   dart run tool/simulate.dart --section cards          # poder de cada carta
//   dart run tool/simulate.dart --data otra/carpeta      # comparar con otros datos
//
// Perfiles: novato, promedio, experto (y de referencia aleatorio, codicioso).
// Secciones: runs (defecto), picos, talismans, cards, difficulty.
//   --difficulty easy|normal|hard|shifu  (sección runs)
import 'dart:io';
import 'dart:isolate';
import 'dart:math' as math;

import 'package:long_breath/domain/model/enums.dart';

import 'sim/lab.dart';

late List<String> _args;

String opt(String name, String def) {
  final i = _args.indexOf('--$name');
  return i >= 0 && i + 1 < _args.length ? _args[i + 1] : def;
}

bool flag(String name) => _args.contains('--$name');

/// Prototipo viejo de 3 etapas (enemigos de la etapa 1 escalados) en vez
/// de las etapas reales.
var proto = false;

class Config {
  Config({
    required this.raw,
    required this.stages,
    required this.talismans,
    this.pico = 0,
    this.startTalismans = const [],
    this.startCards = const [],
    this.difficulty = Difficulty.normal,
  });

  final RawData raw;
  final int stages;
  final bool talismans;
  final int pico;
  final List<String> startTalismans;
  final List<String> startCards;
  final Difficulty difficulty;
}

/// Corre [runs] runs de un perfil repartidas en varios isolates.
Future<List<RunLog>> simulate(Config c, String profile, int runs, int seed,
    {Style? style}) async {
  final workers = math.min(Platform.numberOfProcessors, math.max(1, runs ~/ 10));
  final chunks = [
    for (var w = 0; w < workers; w++)
      [for (var i = w; i < runs; i += workers) i],
  ];
  final sloppy = sloppiness;
  final curve = (stageHp, stageDmg, stageStr, fountainRate, bossHeal);
  final useProto = proto;
  final parts = await Future.wait([
    for (final chunk in chunks)
      Isolate.run(() {
        sloppiness = sloppy;
        stageHp = curve.$1;
        stageDmg = curve.$2;
        stageStr = curve.$3;
        fountainRate = curve.$4;
        bossHeal = curve.$5;
        final base = c.raw.copy();
        if (useProto) addStageEnemies(base);
        // Etapas reales: se recorta la subida a las primeras [c.stages].
        final run = base.balance['run'] as Map<String, dynamic>;
        if (!useProto && run['stages'] is List) {
          run['stages'] = (run['stages'] as List).take(c.stages).toList();
        }
        final fixed = useProto ? null : base.build();
        return [
          for (final i in chunk)
            playRun(
              fixed ?? protoData(base, seed * 7 + i),
              profiles[profile]!(seed * 31 + i),
              seed * 7 + i,
              wanted: style ?? Style.values[i % 3],
              withTalismans: c.talismans,
              startTalismans: c.startTalismans,
              startCards: c.startCards,
              difficulty: c.difficulty,
              pico: c.pico,
            ),
        ];
      }),
  ]);
  return [for (final p in parts) ...p];
}

String pct(num a, num b) => b == 0 ? '-' : '${(a * 100 / b).toStringAsFixed(0)}%';
String f1(num v) => v.toStringAsFixed(1);
double mean(Iterable<num> xs) => xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;
num p90(List<num> xs) {
  if (xs.isEmpty) return 0;
  final s = [...xs]..sort();
  return s[((s.length - 1) * 0.9).round()];
}

void table(List<String> head, List<List<String>> rows) {
  print('| ${head.join(' | ')} |');
  print('|${[for (final _ in head) '---'].join('|')}|');
  for (final r in rows) {
    print('| ${r.join(' | ')} |');
  }
  print('');
}

Future<void> main(List<String> args) async {
  _args = args;
  final runs = int.parse(opt('runs', '300'));
  final seed = int.parse(opt('seed', '1'));
  final section = opt('section', 'runs');
  final profileArg = opt('profile', 'novato,promedio,experto');
  final selected = profileArg == 'all' ? profiles.keys.toList() : profileArg.split(',');
  final styleArg = opt('style', 'all');
  final style = styleArg == 'all' ? null : Style.parse(styleArg);

  final raw = RawData.load(opt('data', 'assets/data'));
  proto = flag('proto');
  final real = (raw.balance['run'] as Map<String, dynamic>)['stages'] as List?;
  final stages = int.parse(opt('stages', proto ? '3' : '${real?.length ?? 1}'));
  final levers = Levers(
    hp: Levers.parse(_args.contains('--hp') ? opt('hp', '') : null),
    dmg: Levers.parse(_args.contains('--dmg') ? opt('dmg', '') : null),
    str: Levers.parse(_args.contains('--str') ? opt('str', '') : null),
  );
  levers.apply(raw);
  // --set game_balance.json:styles.tiger.draw=5;cards.json:pi_quan.damage=5
  if (_args.contains('--set')) {
    for (final kv in opt('set', '').split(';')) {
      final [path, value] = kv.split('=');
      final [file, keys] = path.split(':');
      raw.set(file, keys.split('.'), num.parse(value));
    }
  }
  sloppiness = double.parse(opt('sloppy', '$sloppiness'));
  // --curve 1.25,1.5,1.15,1.3 : Vida etapa 2 y 3, daño etapa 2 y 3.
  if (_args.contains('--curve')) {
    final v = [for (final x in opt('curve', '').split(',')) double.parse(x)];
    stageHp = [1, v[0], v[1]];
    stageDmg = [1, v[2], v[3]];
    stageStr = stageDmg;
  }
  fountainRate = double.parse(opt('fountains', '$fountainRate'));
  bossHeal = double.parse(opt('boss-heal', '$bossHeal'));

  final sw = Stopwatch()..start();
  print('# Long Breath — simulación ($section, ${proto ? '$stages etapas (prototipo)' : stages == 1 ? 'etapa 1' : '$stages etapas'}, '
      '$runs runs por perfil, semilla $seed${levers.isEmpty ? '' : ', con palancas'})\n');

  switch (section) {
    case 'picos':
      await _picos(raw, stages, runs, seed, selected);
    case 'cards':
      await _cards(raw, stages, runs, seed, selected);
    case 'talismans':
      await _talismans(raw, stages, runs, seed);
    case 'difficulty':
      await _difficulties(raw, stages, runs, seed, selected);
    default:
      final cfg = Config(
          raw: raw,
          stages: stages,
          talismans: flag('talismans'),
          difficulty: Difficulty.parse(opt('difficulty', 'normal')));
      final logs = <String, List<RunLog>>{};
      for (final p in selected) {
        logs[p] = await simulate(cfg, p, runs, seed, style: style);
      }
      _report(logs);
  }
  print('_${(sw.elapsedMilliseconds / 1000).toStringAsFixed(0)} s de cómputo_');
}

/// Victoria y minutos de cada perfil en cada dificultad.
Future<void> _difficulties(
    RawData raw, int stages, int runs, int seed, List<String> profilesSel) async {
  final rows = <List<String>>[];
  for (final d in Difficulty.values) {
    final cfg = Config(
        raw: raw, stages: stages, talismans: proto, difficulty: d);
    final row = [d.name];
    for (final p in profilesSel) {
      final l = await simulate(cfg, p, runs, seed);
      final won = l.where((r) => r.won).toList();
      row.add('${pct(won.length, l.length)} · '
          '${mean([for (final r in won) r.seconds / 60]).toStringAsFixed(0)} min');
    }
    rows.add(row);
  }
  table(['Dificultad', ...profilesSel], rows);
}

void _report(Map<String, List<RunLog>> logs) {
  print('## Runs');
  table([
    'perfil', 'victoria', 'llega al jefe final', 'piso medio de derrota',
    'Vida al jefe', 'minutos (media)', 'minutos (victorias)', 'mazo final', 'formas por run', 'formas aprendidas', 'talismanes', 'mercader', 'maestro', 'jade gastado', 'jade sin gastar',
  ], [
    for (final MapEntry(key: p, value: l) in logs.entries)
      [
        p,
        pct(l.where((r) => r.won).length, l.length),
        pct(l.where((r) => r.hpAtBoss != null).length, l.length),
        f1(mean([for (final r in l.where((r) => !r.won)) r.nodes])),
        f1(mean([for (final r in l) if (r.hpAtBoss != null) r.hpAtBoss!])),
        f1(mean([for (final r in l) r.seconds / 60])),
        f1(mean([for (final r in l.where((r) => r.won)) r.seconds / 60])),
        f1(mean([for (final r in l) r.deckSize])),
        f1(mean([for (final r in l) r.fights.fold(0, (a, f) => a + f.forms)])),
        f1(mean([for (final r in l) r.learned.length])),
        f1(mean([for (final r in l) r.talismans.length])),
        f1(mean([for (final r in l) r.merchants])),
        f1(mean([for (final r in l) r.masters])),
        f1(mean([for (final r in l) r.jadeSpent])),
        f1(mean([for (final r in l) r.jadeLeft])),
      ],
  ]);

  print('## Hasta dónde llega');
  final maxStage = logs.values.expand((l) => l).fold(0, (a, r) => math.max(a, r.stage));
  table(['perfil', for (var st = 1; st <= maxStage; st++) 'llega a la etapa ${st + 1}', 'gana'], [
    for (final MapEntry(key: p, value: l) in logs.entries)
      [
        p,
        for (var st = 1; st <= maxStage; st++)
          pct(l.where((r) => r.stage >= st).length, l.length),
        pct(l.where((r) => r.won).length, l.length),
      ],
  ]);

  print('## Victoria por camino');
  table(['perfil', for (final s in Style.values) s.name, 'sin camino (murió antes)'], [
    for (final MapEntry(key: p, value: l) in logs.entries)
      [
        p,
        for (final s in Style.values)
          '${pct(l.where((r) => r.style == s && r.won).length, l.where((r) => r.style == s).length)} '
              '(${l.where((r) => r.style == s).length})',
        '${l.where((r) => r.style == null).length}',
      ],
  ]);

  print('## Combates (dentro de las runs: mazo y Vida reales)');
  for (final MapEntry(key: p, value: l) in logs.entries) {
    print('### $p');
    final byEnemy = <String, List<FightLog>>{};
    for (final r in l) {
      for (final f in r.fights) {
        byEnemy.putIfAbsent(f.enemy, () => []).add(f);
      }
    }
    final order = byEnemy.keys.toList()
      ..sort((a, b) {
        final ra = byEnemy[a]!.first.rank.index, rb = byEnemy[b]!.first.rank.index;
        return ra != rb ? ra.compareTo(rb) : a.compareTo(b);
      });
    table([
      'enemigo', 'rango', 'peleas', 'victoria', 'turnos', 'turnos p90',
      'Vida perdida', 'desequilibrios', 'desvíos', 'formas', 'minutos',
    ], [
      for (final e in order)
        () {
          final fs = byEnemy[e]!;
          final won = fs.where((f) => f.won).toList();
          return [
            e,
            fs.first.rank.name,
            '${fs.length}',
            pct(won.length, fs.length),
            f1(mean([for (final f in won) f.turns])),
            '${p90([for (final f in won) f.turns])}',
            f1(mean([for (final f in fs) f.hpLost])),
            f1(mean([for (final f in fs) f.staggers])),
            f1(mean([for (final f in fs) f.deflects])),
            f1(mean([for (final f in fs) f.forms])),
            f1(mean([for (final f in fs) (f.plays * 5 + f.turns * 6 + 10) / 60])),
          ];
        }(),
    ]);
  }

  print('## Uso de posturas (cartas jugadas desde cada una)');
  table(['perfil', for (final s in Stance.values) s.name], [
    for (final MapEntry(key: p, value: l) in logs.entries)
      () {
        final c = <Stance, int>{};
        for (final r in l) {
          for (final f in r.fights) {
            f.stanceUse.forEach((k, v) => c[k] = (c[k] ?? 0) + v);
          }
        }
        final total = c.values.fold(0, (a, b) => a + b);
        return [p, for (final s in Stance.values) pct(c[s] ?? 0, total)];
      }(),
  ]);

  for (final p in ['promedio', 'experto']) {
    final l = logs[p];
    if (l == null) continue;
    print('## Cartas de recompensa ($p)');
    final ids = {for (final r in l) ...r.offered}.toList()..sort();
    table(['carta', 'runs donde salió', 'elegida', 'victoria si la tomó', 'victoria si no'], [
      for (final id in ids)
        () {
          final off = l.where((r) => r.offered.contains(id)).toList();
          final took = off.where((r) => r.picked.contains(id)).toList();
          final not = off.where((r) => !r.picked.contains(id)).toList();
          return [
            id,
            '${off.length}',
            pct(took.length, off.length),
            pct(took.where((r) => r.won).length, took.length),
            pct(not.where((r) => r.won).length, not.length),
          ];
        }(),
    ]);
  }
}

Future<void> _picos(RawData raw, int stages, int runs, int seed, List<String> profilesSel) async {
  print('## Picos (dificultad desbloqueable)');
  final rows = <List<String>>[];
  for (var pico = 0; pico <= 10; pico++) {
    final cfg = Config(raw: raw, stages: stages, talismans: true, pico: pico);
    final row = [pico == 0 ? '0 (normal)' : '$pico'];
    for (final p in profilesSel) {
      final l = await simulate(cfg, p, runs, seed);
      row.add(pct(l.where((r) => r.won).length, l.length));
    }
    rows.add(row);
  }
  table(['Pico', ...profilesSel], rows);
}

Future<void> _talismans(RawData raw, int stages, int runs, int seed) async {
  print('## Talismanes: victoria del perfil promedio empezando con uno solo');
  final base = await simulate(
      Config(raw: raw, stages: stages, talismans: false), 'promedio', runs, seed);
  final bw = base.where((r) => r.won).length * 100 / runs;
  final rows = [
    ['ninguno', '-', '${bw.toStringAsFixed(0)}%', '-'],
  ];
  final data = raw.build();
  for (final t in talismanIds(data)) {
    final l = await simulate(
        Config(raw: raw, stages: stages, talismans: false, startTalismans: [t]),
        'promedio', runs, seed);
    final w = l.where((r) => r.won).length * 100 / runs;
    rows.add([t, data.talisman(t).hanzi, '${w.toStringAsFixed(0)}%', '${(w - bw) >= 0 ? '+' : ''}${(w - bw).toStringAsFixed(0)} pp']);
  }
  table(['talismán', 'carácter', 'victoria', 'diferencia'], rows);
}

/// Poder de cada carta: victoria si empieza la run ya en el mazo, contra el
/// mazo inicial solo. Aísla la carta de la heurística de elección del bot.
Future<void> _cards(RawData raw, int stages, int runs, int seed, List<String> sel) async {
  print('## Poder de las cartas de recompensa (empezando la run con una copia)');
  final data = raw.build();
  final base = <String, double>{};
  for (final p in sel) {
    final l = await simulate(Config(raw: raw, stages: stages, talismans: false), p, runs, seed);
    base[p] = l.where((r) => r.won).length * 100 / runs;
  }
  final rows = [
    ['(mazo inicial)', '-', for (final p in sel) '${base[p]!.toStringAsFixed(0)}%'],
  ];
  for (final c in data.rewardPool) {
    final row = [c.id, '${c.cost}'];
    for (final p in sel) {
      final l = await simulate(
          Config(raw: raw, stages: stages, talismans: false, startCards: [c.id]), p, runs, seed);
      final w = l.where((r) => r.won).length * 100 / runs - base[p]!;
      row.add('${w >= 0 ? '+' : ''}${w.toStringAsFixed(0)} pp');
    }
    rows.add(row);
  }
  table(['carta', 'costo', ...sel], rows);
}
