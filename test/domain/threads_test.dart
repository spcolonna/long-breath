import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/rng.dart';
import 'package:long_breath/domain/run/run_engine.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/domain/run/threads.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';

/// Los hilos: Shuang y Tío Bao avanzan un capítulo por subida y recuerdan
/// lo que hiciste.
void main() {
  final run = RunEngine(loadGameDataFromDir());

  /// Entra a un lugar suelto de [type] en la etapa [stage].
  RunState at(
    NodeType type, {
    int stage = 0,
    Set<String> threads = const {},
    List<String> threadRun = const [],
    int seed = 1,
  }) => run.enter(
    run
        .newRun(seed: seed, threads: threads)
        .copyWith(
          stage: stage,
          map: [MapNodeDef(id: 'x', type: type, next: const [])],
          clearCurrentNode: true,
          visited: const [],
          threadRun: threadRun,
          rng: Rng(seed),
        ),
    'x',
  );

  test('el primer evento de la primera subida es Shuang, y una vez', () {
    for (var seed = 0; seed < 20; seed++) {
      final r = at(NodeType.event, seed: seed);
      expect(r.eventId, 'shuang_1');
      final done = run.resolveEvent(r, 'bow');
      expect(done.threads, containsAll(['shuang_1', 'shuang_1_kind']));
      expect(done.threadRun, [threadShuang]);
      // En la misma subida no vuelve.
      final again = at(
        NodeType.event,
        seed: seed,
        threads: done.threads,
        threadRun: done.threadRun,
      );
      expect(again.eventId, isNot(startsWith('shuang')));
    }
  });

  test('cada capítulo sale en su etapa y en otra subida', () {
    var marks = {'shuang_1', 'shuang_1_proud'};
    // El 2 es del monasterio: abajo no sale.
    expect(at(NodeType.event, threads: marks).eventId, isNot(startsWith('shuang')));
    var r = at(NodeType.event, stage: 1, threads: marks);
    expect(r.eventId, 'shuang_2');
    r = run.resolveEvent(r, 'pass');
    marks = r.threads;
    r = at(NodeType.event, stage: 1, threads: marks);
    expect(r.eventId, 'shuang_3');
    r = run.resolveEvent(r, 'spar');
    marks = r.threads;
    r = at(NodeType.event, stage: 2, threads: marks);
    expect(r.eventId, 'shuang_4');
    marks = run.resolveEvent(r, 'silence').threads;
    expect(bondOf(marks, threadShuang), 'proud');
    expect(at(NodeType.event, stage: 2, threads: marks).eventId, 'shuang_5_proud');
    expect(
      at(NodeType.event, stage: 2, threads: {...marks, 'shuang_9_kind', 'shuang_8_kind'})
          .eventId,
      'shuang_5_kind',
    );
    final end = run.resolveEvent(
      at(NodeType.event, stage: 2, threads: marks),
      'yield',
    );
    expect(chapterOf(end.threads, threadShuang), 5);
    expect(
      at(NodeType.event, stage: 2, threads: end.threads).eventId,
      isNot(startsWith('shuang')),
    );
  });

  test('Tío Bao cuenta un capítulo por subida si le compraste algo', () {
    var r = at(NodeType.merchant);
    expect(r.threadLine, 'bao_1');
    expect(r.threadRun, [threadBao]);
    // Sin comprar, la próxima subida no cuenta nada nuevo.
    expect(at(NodeType.merchant, threads: r.threads).threadLine, isNull);
    r = r.copyWith(jade: 500);
    r = run.buyTea(r.copyWith(hp: 1));
    expect(r.threads, contains('bao_1_trust'));
    r = run.leaveShop(r);
    expect(r.threadLine, isNull);
    final next = at(NodeType.merchant, threads: r.threads);
    expect(next.threadLine, 'bao_2');
    // Dos veces en la misma subida, no.
    expect(
      at(NodeType.merchant, threads: next.threads, threadRun: next.threadRun)
          .threadLine,
      isNull,
    );
  });

  test('al terminar su historia, Tío Bao cobra como a la familia', () {
    final all = {
      for (var n = 1; n <= 5; n++) ...['bao_$n', 'bao_${n}_trust'],
    };
    final plain = run.merchantOf(at(NodeType.merchant));
    final friend = run.merchantOf(at(NodeType.merchant, threads: all));
    expect(friend.card, lessThan(plain.card));
    expect(at(NodeType.merchant, threads: all).threadLine, isNull);
  });

  test('los hilos sobreviven al guardado de la subida', () {
    final r = run.resolveEvent(at(NodeType.event), 'accept');
    final back = RunState.fromJson(r.toJson());
    expect(back.threads, r.threads);
    expect(back.threadRun, r.threadRun);
    final shop = at(NodeType.merchant);
    expect(RunState.fromJson(shop.toJson()).threadLine, 'bao_1');
  });

  test('todo capítulo tiene textos y su pergamino', () {
    final data = run.data;
    final chapters = [for (final e in data.events) if (e.thread != null) e];
    expect(chapters, hasLength(6));
    for (var n = 1; n <= 5; n++) {
      expect(chapters.where((e) => e.chapter == n), isNotEmpty, reason: '$n');
    }
    for (final e in chapters) {
      for (final o in e.options) {
        if (e.chapter < 5) expect(o.bond, isNotNull, reason: '${e.id} ${o.id}');
      }
    }
  });
}
