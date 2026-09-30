import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'delivery/audio/game_audio.dart';
import 'delivery/providers.dart';
import 'infrastructure/soloud_audio.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  GameAudio audio;
  try {
    audio = await SoloudAudio.create();
  } catch (e) {
    // Sin audio el juego sigue siendo jugable.
    debugPrint('audio: $e');
    audio = SilentAudio();
  }
  runApp(ProviderScope(
    overrides: [audioProvider.overrideWithValue(audio)],
    child: const LongBreathApp(),
  ));
}
