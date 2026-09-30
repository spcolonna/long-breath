import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'delivery/providers.dart';
import 'delivery/screens/combat_screen.dart';
import 'delivery/screens/fountain_screen.dart';
import 'delivery/screens/home_screen.dart';
import 'delivery/screens/map_screen.dart';
import 'delivery/screens/result_screen.dart';
import 'delivery/screens/reward_screen.dart';
import 'delivery/theme.dart';
import 'l10n/app_localizations.dart';

final _router = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, _) => const HomeScreen()),
    GoRoute(path: '/map', builder: (_, _) => const MapScreen()),
    GoRoute(path: '/combat', builder: (_, _) => const CombatScreen()),
    GoRoute(path: '/reward', builder: (_, _) => const RewardScreen()),
    GoRoute(path: '/fountain', builder: (_, _) => const FountainScreen()),
    GoRoute(path: '/result', builder: (_, _) => const ResultScreen()),
  ],
);

class LongBreathApp extends ConsumerWidget {
  const LongBreathApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(gameDataProvider);
    final text = ref.watch(contentTextProvider);
    const locales = [Locale('es')];
    const delegates = [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ];
    final ready = data.hasValue && text.hasValue;
    final error = data.error ?? text.error;
    if (ready) {
      return MaterialApp.router(
        title: 'Long Breath',
        debugShowCheckedModeBanner: false,
        theme: buildTheme(),
        routerConfig: _router,
        builder: backdrop,
        supportedLocales: locales,
        localizationsDelegates: delegates,
        // Idioma del dispositivo si está soportado; si no, español.
        localeResolutionCallback: (locale, supported) => supported.firstWhere(
            (l) => l.languageCode == locale?.languageCode,
            orElse: () => locales.first),
      );
    }
    return MaterialApp(
      builder: backdrop,
      theme: buildTheme(),
      home: Scaffold(
        body: Center(
          child: error != null
              ? Text('Error cargando datos: $error')
              : const CircularProgressIndicator(),
        ),
      ),
    );
  }
}
