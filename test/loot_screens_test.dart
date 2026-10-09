import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:long_breath/app.dart';
import 'package:long_breath/delivery/controllers/run_controller.dart';
import 'package:long_breath/delivery/providers.dart';
import 'package:long_breath/domain/model/enums.dart';
import 'package:long_breath/domain/model/game_balance.dart';
import 'package:long_breath/domain/run/run_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  Future<ProviderContainer> boot(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1206, 2622);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(const ProviderScope(child: LongBreathApp()));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    return ProviderScope.containerOf(
      tester.element(find.byType(Scaffold).first),
    );
  }

  Future<void> settle(WidgetTester tester) async {
    await tester.pump();
    for (var i = 0; i < 4; i++) {
      await tester.pump(const Duration(milliseconds: 500));
    }
  }

  testWidgets('botín de cada tipo y árbol de meridianos', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final container = await boot(tester);
    final runs = container.read(runControllerProvider.notifier);
    runs.newRun(Difficulty.normal);
    final r = container.read(runControllerProvider)!;
    runs.resume(
      r.copyWith(
        phase: RunPhase.reward,
        currentNode: r.starts.first,
        visited: [r.starts.first],
        rewardKind: RewardKind.jade,
        rewardAmount: 20,
        jadeGained: 15,
        jade: 15,
        lotusGained: 1,
        lotus: 1,
      ),
    );
    GoRouter.of(tester.element(find.byType(Scaffold).first)).go('/reward');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 700));
    expect(find.text('Botín'), findsOneWidget);
    expect(find.text('Tocá el cofre para abrirlo'), findsOneWidget);
    await settle(tester);
    expect(find.text('Bolsa de jade'), findsOneWidget);
    expect(find.text('+1 de loto'), findsOneWidget);
    await tester.tap(find.text('Tomar'));
    await settle(tester);
    final after = container.read(runControllerProvider)!;
    expect(after.jade, 35);
    expect(after.phase, RunPhase.map);

    // Té, temple y talismán muestran su elección.
    final base = after;
    RunState loot(RewardKind kind, {int amount = 0, List<String>? t}) =>
        base.copyWith(
          phase: RunPhase.reward,
          currentNode: base.starts.first,
          visited: [base.starts.first],
          rewardKind: kind,
          rewardAmount: amount,
          talismanOptions: t,
          hp: 20,
        );
    final router = GoRouter.of(tester.element(find.byType(Scaffold).first));

    runs.resume(loot(RewardKind.tea, amount: 8));
    router.go('/reward');
    await settle(tester);
    expect(find.text('Té de montaña'), findsOneWidget);
    await tester.tap(find.text('Beber'));
    await settle(tester);
    expect(container.read(runControllerProvider)!.hp, 28);

    runs.resume(loot(RewardKind.upgrade, amount: 3));
    router.go('/reward');
    await settle(tester);
    expect(find.text('Temple'), findsOneWidget);
    expect(find.text('Templar'), findsOneWidget);

    // Del temple se sale salteándolo: el botín siguiente es otra pantalla.
    await tester.tap(find.text('Saltear'));
    await settle(tester);
    runs.resume(loot(RewardKind.talisman, t: ['vida', 'roca']));
    router.go('/reward');
    await settle(tester);
    expect(find.text('Talismán'), findsOneWidget);
    expect(find.text('Hilo de Vida'), findsOneWidget);

    // El árbol de meridianos abre un punto con loto.
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('long_breath.lotus', 40);
    container.invalidate(meridianProvider);
    router.go('/meridians');
    await settle(tester);
    expect(find.text('Árbol de meridianos'), findsOneWidget);
    expect(find.text('Cuerpo'), findsOneWidget);
    await tester.tap(find.text('足三里'));
    await settle(tester);
    expect(find.text('Zúsānlǐ'), findsOneWidget);
    await tester.tap(find.textContaining('Abrir punto'));
    await settle(tester);
    final m = await container.read(meridianProvider.future);
    expect(m.owned, ['body_1']);
    expect(m.lotus, 40 - 25);
  });
}
