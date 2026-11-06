import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// El registro de cada subida, en texto plano, para analizar el balance:
/// `Documents/run_logs/slot<N>/actual.log` es la subida en curso (o la
/// última) y al empezar otra se archiva con la fecha. Se guardan las últimas
/// [keep] por partida.
///
/// Nunca falla hacia afuera: si no hay disco (tests, sin permiso), no anota.
class RunLogStorage {
  RunLogStorage(this.slot, {Future<Directory> Function()? base})
    : _base = base ?? getApplicationDocumentsDirectory;

  final int slot;
  final Future<Directory> Function() _base;
  static const keep = 20;

  Future<void> _chain = Future.value();
  Directory? _dir;

  Future<Directory> _folder() async {
    if (_dir != null) return _dir!;
    final root = await _base();
    final d = Directory('${root.path}/run_logs/slot$slot');
    await d.create(recursive: true);
    return _dir = d;
  }

  Future<File> get _current async => File('${(await _folder()).path}/actual.log');

  /// Encola una escritura (en orden) y se traga cualquier error.
  Future<void> _run(Future<void> Function() job) =>
      _chain = _chain.then((_) => job()).catchError((Object _) {});

  /// Agrega líneas a la subida en curso.
  Future<void> append(Iterable<String> lines) {
    if (lines.isEmpty) return _chain;
    final text = '${lines.join('\n')}\n';
    return _run(() async {
      await (await _current).writeAsString(text, mode: FileMode.append, flush: false);
    });
  }

  /// Empieza el registro de una subida nueva: archiva el anterior.
  Future<void> start(Iterable<String> header) => _run(() async {
    final cur = await _current;
    if (await cur.exists()) {
      final stamp = (await cur.lastModified())
          .toIso8601String()
          .replaceAll(':', '-')
          .split('.')
          .first;
      await cur.rename('${(await _folder()).path}/$stamp.log');
    }
    await cur.writeAsString('${header.join('\n')}\n');
    final old = (await (await _folder()).list().toList())
        .whereType<File>()
        .where((f) => !f.path.endsWith('actual.log'))
        .toList()
      ..sort((a, b) => b.path.compareTo(a.path));
    for (final f in old.skip(keep)) {
      await f.delete();
    }
  });

  /// El texto de la subida en curso (o la última), para copiarlo.
  Future<String?> read() async {
    await _chain;
    try {
      final cur = await _current;
      return await cur.exists() ? await cur.readAsString() : null;
    } catch (_) {
      return null;
    }
  }

  /// Borra todos los registros de esta partida (al borrar la partida).
  Future<void> clear() => _run(() async {
    final d = await _folder();
    if (await d.exists()) await d.delete(recursive: true);
    _dir = null;
  });
}
