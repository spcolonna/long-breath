import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/ghost.dart';
import '../providers.dart';
import '../screens/home_screen.dart' show routeFor;
import 'run_controller.dart';

/// Sube un discípulo nuevo con la dificultad y el Pico de la partida en
/// juego, y va a la primera pantalla de la subida.
Future<void> startClimb(BuildContext context, WidgetRef ref) async {
  final info = await ref.read(slotInfoProvider.future);
  final locked = (await ref.read(cultivationProvider.future)).locked;
  final meta = await ref.read(metaBonusProvider.future);
  final ascents = await ref.read(ascentsProvider.future);
  if (!context.mounted) return;
  final difficulty = info?.difficulty ?? Difficulty.normal;
  ref
      .read(runControllerProvider.notifier)
      .newRun(
        difficulty,
        pico: difficulty == Difficulty.normal ? info?.pico ?? 0 : 0,
        locked: locked,
        meta: meta,
        ghost: ghostFrom(ascents),
      );
  // Con el talismán de los meridianos se elige antes del mapa.
  context.go(routeFor(ref.read(runControllerProvider)!));
}
