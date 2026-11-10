import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:long_breath/infrastructure/error_log.dart';

void main() {
  test('anota el error con su pila en errors.log', () async {
    final dir = await Directory.systemTemp.createTemp('errlog');
    addTearDown(() => dir.delete(recursive: true));
    final log = ErrorLog(base: () async => dir);
    await log.record(StateError('se rompió'), StackTrace.current, where: 'x');
    final text = await File('${dir.path}/errors.log').readAsString();
    expect(text, contains('se rompió'));
    expect(text, contains('error_log_test'));
  });
}
