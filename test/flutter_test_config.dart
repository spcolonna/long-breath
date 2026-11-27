import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

/// Los tests leen los textos en castellano: el dispositivo de prueba se
/// pone en español (por defecto sería inglés y el juego ya lo soporta).
Future<void> testExecutable(FutureOr<void> Function() testMain) async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();
  void spanish() {
    binding.platformDispatcher.localeTestValue = const Locale('es');
    binding.platformDispatcher.localesTestValue = const [Locale('es')];
  }

  spanish();
  setUp(spanish);
  await testMain();
}
