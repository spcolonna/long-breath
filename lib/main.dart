import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'delivery/audio/game_audio.dart';
import 'delivery/feel.dart';
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
  var feel = const FeelSettings();
  try {
    feel = FeelSettings.read(await SharedPreferences.getInstance());
  } catch (e) {
    debugPrint('feel: $e');
  }
  runApp(ProviderScope(
    overrides: [
      audioProvider.overrideWithValue(audio),
      initialFeelProvider.overrideWithValue(feel),
    ],
    child: const LongBreathApp(),
  ));
}
