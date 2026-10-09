import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'delivery/providers.dart';
import 'delivery/screens/meridian_screen.dart';
import 'delivery/screens/climb_lesson_screen.dart';
import 'delivery/screens/combat_screen.dart';
import 'delivery/screens/event_screen.dart';
import 'delivery/screens/merchant_screen.dart';
import 'delivery/screens/master_screen.dart';
import 'delivery/screens/fountain_screen.dart';
import 'delivery/screens/home_screen.dart';
import 'delivery/screens/lessons_screen.dart';
import 'delivery/screens/map_screen.dart';
import 'delivery/screens/registry_screen.dart';
import 'delivery/screens/result_screen.dart';
import 'delivery/screens/reward_screen.dart';
import 'delivery/screens/shrine_screen.dart';
import 'delivery/screens/stage_clear_screen.dart';
import 'delivery/screens/talisman_screen.dart';
import 'delivery/theme.dart';
import 'delivery/widgets/ink_reveal.dart';
import 'l10n/app_localizations.dart';

/// Las pantallas son transparentes sobre el mismo fondo de papel, así que
/// no se deslizan una sobre otra: la que sale se desvanece primero y la que
/// entra aparece después, con un leve acercamiento.
///
/// Si se navega con un [InkFrom] como `extra` (al tocar un lugar del mapa),
/// la pantalla entra con una mancha de tinta desde ese punto.
GoRoute _route(String path, Widget screen) => GoRoute(
  path: path,
  pageBuilder: (_, state) => CustomTransitionPage(
    key: state.pageKey,
    child: screen,
    transitionDuration: Duration(
      milliseconds: state.extra is InkFrom ? 620 : 420,
    ),
    reverseTransitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (_, animation, secondary, child) {
      final exit = CurvedAnimation(
        parent: secondary,
        curve: const Interval(0, 0.4, curve: Curves.easeIn),
      );
      if (state.extra case final InkFrom from) {
        return FadeTransition(
          opacity: ReverseAnimation(exit),
          child: inkReveal(animation, child, from),
        );
      }
      final enter = CurvedAnimation(
        parent: animation,
        curve: const Interval(0.4, 1, curve: Curves.easeOutCubic),
      );
      return FadeTransition(
        opacity: ReverseAnimation(exit),
        child: FadeTransition(
          opacity: enter,
          child: ScaleTransition(
            scale: Tween(begin: 0.97, end: 1.0).animate(enter),
            child: child,
          ),
        ),
      );
    },
  ),
);

final _router = GoRouter(
  routes: [
    _route('/', const HomeScreen()),
    _route('/lessons', const LessonsScreen()),
    _route('/lessons/climb', const ClimbLessonScreen()),
    _route('/map', const MapScreen()),
    _route('/combat', const CombatScreen()),
    _route('/reward', const RewardScreen()),
    _route('/fountain', const FountainScreen()),
    _route('/shrine', const ShrineScreen()),
    _route('/event', const EventScreen()),
    _route('/merchant', const MerchantScreen()),
    _route('/master', const MasterScreen()),
    _route('/talisman', const TalismanScreen()),
    _route('/stage', const StageClearScreen()),
    _route('/result', const ResultScreen()),
    _route('/registry', const RegistryScreen()),
    _route('/meridians', const MeridianScreen()),
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
          orElse: () => locales.first,
        ),
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
