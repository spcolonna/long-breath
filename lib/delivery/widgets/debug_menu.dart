import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../infrastructure/progress_storage.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../screens/home_screen.dart' show routeFor;
import '../theme.dart';

/// Menú de pruebas: solo aparece en las builds de desarrollo (kDebugMode).
/// Arranca una subida en cualquier etapa y piso, y suma loto.
class DebugButton extends ConsumerWidget {
  const DebugButton({super.key, this.onDone});

  final VoidCallback? onDone;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: 'Pruebas',
    visualDensity: VisualDensity.compact,
    color: Palette.structure,
    icon: const Icon(Icons.bug_report_rounded, size: 22),
    onPressed: () async {
      await showModalBottomSheet<void>(
        context: context,
        backgroundColor: Palette.bg,
        builder: (_) => const _DebugSheet(),
      );
      onDone?.call();
    },
  );
}

class _DebugSheet extends ConsumerStatefulWidget {
  const _DebugSheet();

  @override
  ConsumerState<_DebugSheet> createState() => _DebugSheetState();
}

class _DebugSheetState extends ConsumerState<_DebugSheet> {
  int _stage = 0;
  int _floor = 1;

  Future<void> _start() async {
    final info = await ref.read(slotInfoProvider.future);
    await ref.read(metaBonusProvider.future);
    if (!mounted) return;
    final difficulty = info?.difficulty ?? Difficulty.normal;
    ref
        .read(runControllerProvider.notifier)
        .debugStart(difficulty, info?.pico ?? 0, _stage, _floor);
    ref.invalidate(savedRunProvider);
    final router = GoRouter.of(context);
    Navigator.pop(context);
    router.go(routeFor(ref.read(runControllerProvider)!));
  }

  Future<void> _lotus() async {
    await ref.read(progressStorageProvider).addLotus(20);
    ref.invalidate(meridianProvider);
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final stages = ref.watch(dataProvider).balance.stages;
    final floors = stages[_stage].floors.length;
    final names = ref.watch(textProvider);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pruebas (solo debug)',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              alignment: WrapAlignment.center,
              children: [
                for (var i = 0; i < stages.length; i++)
                  ChoiceChip(
                    label: Text(names.stage(stages[i].id)),
                    selected: _stage == i,
                    onSelected: (_) => setState(() {
                      _stage = i;
                      _floor = _floor.clamp(1, stages[i].floors.length);
                    }),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            Text('Piso $_floor de $floors', textAlign: TextAlign.center),
            Slider(
              value: _floor.toDouble(),
              min: 1,
              max: floors.toDouble(),
              divisions: floors - 1,
              label: '$_floor',
              onChanged: (v) => setState(() => _floor = v.round()),
            ),
            FilledButton(onPressed: _start, child: const Text('Subir acá')),
            const SizedBox(height: 8),
            OutlinedButton(onPressed: _lotus, child: const Text('+20 loto')),
          ],
        ),
      ),
    );
  }
}
