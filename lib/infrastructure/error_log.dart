import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Los errores que no se atrapan quedan en `Documents/errors.log` (solo en el
/// teléfono, nada sale del dispositivo) para poder leerlos después de una
/// sesión de prueba. Se recorta solo para no crecer sin límite.
class ErrorLog {
  ErrorLog({Future<Directory> Function()? base})
    : _base = base ?? getApplicationDocumentsDirectory;

  final Future<Directory> Function() _base;
  static const maxBytes = 200 * 1024;
  Future<void> _chain = Future.value();

  /// Engancha los errores de Flutter y los asincrónicos sin dueño.
  void install() {
    final previous = FlutterError.onError;
    FlutterError.onError = (details) {
      previous?.call(details);
      record(details.exception, details.stack, where: details.library);
    };
    PlatformDispatcher.instance.onError = (error, stack) {
      debugPrint('error sin atrapar: $error');
      record(error, stack);
      return true;
    };
  }

  /// Anota un error; nunca falla hacia afuera.
  Future<void> record(Object error, StackTrace? stack, {String? where}) {
    final text = StringBuffer()
      ..writeln('── ${DateTime.now().toIso8601String()} ${where ?? ''}')
      ..writeln(error)
      ..writeln(_short(stack));
    return _chain = _chain.then((_) async {
      final f = File('${(await _base()).path}/errors.log');
      if (await f.exists() && await f.length() > maxBytes) {
        final keep = (await f.readAsString());
        await f.writeAsString(keep.substring(keep.length ~/ 2));
      }
      await f.writeAsString(text.toString(), mode: FileMode.append);
    }).catchError((Object _) {});
  }

  /// Las primeras líneas de la pila alcanzan para ubicar el error.
  static String _short(StackTrace? s) =>
      (s?.toString().split('\n') ?? const <String>[]).take(12).join('\n');
}
