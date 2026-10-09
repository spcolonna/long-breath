import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/widgets/cinematic.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_data.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:long_breath/infrastructure/file_game_data_loader.dart';
import 'package:long_breath/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late GameData data;
  setUpAll(() => data = loadGameDataFromDir('assets/data'));

  Widget host(Widget child) => ProviderScope(
    child: MaterialApp(
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: child,
    ),
  );

  testWidgets('el jefe se presenta y la escena termina sola o al tocar', (
    tester,
  ) async {
    final def = data.enemy('bell_abbot');
    var done = 0;
    Widget intro(bool full) => FoeIntro(
      def: def,
      name: 'Abad de la Gran Campana',
      stageId: 'xuankongsi',
      scene: 'gran_campana',
      light: null,
      style: Style.tiger,
      full: full,
      onDone: () => done++,
    );

    await tester.pumpWidget(host(intro(true)));
    await tester.pump(const Duration(milliseconds: 2600));
    expect(find.text('Abad de la Gran Campana'), findsOneWidget);
    expect(find.text('GUARDIÁN DE LA ETAPA'), findsOneWidget);
    expect(find.text('钟师'), findsOneWidget);
    expect(done, 0);
    await tester.pump(const Duration(milliseconds: 1600));
    expect(done, 1);

    // La corta se salta con un toque.
    await tester.pumpWidget(host(SizedBox(key: UniqueKey())));
    await tester.pumpWidget(host(intro(false)));
    await tester.pump(const Duration(milliseconds: 1000));
    expect(find.text('Tocá para saltar'), findsOneWidget);
    await tester.tap(find.byType(FoeIntro));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(done, 2);
  });

  testWidgets('la etapa se presenta entera la primera vez y una sola vez', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    final container = ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
    final runs = container.read(runControllerProvider.notifier);
    runs.newRun(Difficulty.normal);
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));
    router.go('/map');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(StageIntro), findsOneWidget);
    expect(tester.widget<StageIntro>(find.byType(StageIntro)).full, isTrue);
    await tester.pump(const Duration(milliseconds: 1000));
    await tester.tap(find.byType(StageIntro));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pump();
    expect(find.byType(StageIntro), findsNothing);
    expect(container.read(runControllerProvider)!.introShown, 0);

    // Volver al mapa no la repite; otra subida la muestra corta.
    router.go('/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    router.go('/map');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    expect(find.byType(StageIntro), findsNothing);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getStringList('long_breath.cinematics'), [
      'stage_qianyunshan',
    ]);
    router.go('/');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    runs.resume(
      container.read(runControllerProvider)!.copyWith(introShown: -1),
    );
    router.go('/map');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(tester.widget<StageIntro>(find.byType(StageIntro)).full, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(find.byType(StageIntro), findsNothing);

    // Los guardados viejos no la tienen anotada.
    final json = container.read(runControllerProvider)!.toJson()
      ..remove('introShown');
    expect(RunState.fromJson(json).introShown, -1);
    await tester.pump(const Duration(seconds: 2));
  });
}
