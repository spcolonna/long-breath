import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';

String routeFor(RunState r) => switch (r.phase) {
      RunPhase.map => '/map',
      RunPhase.combat => '/map',
      RunPhase.reward => '/reward',
      RunPhase.fountain => '/fountain',
      RunPhase.victory || RunPhase.defeat => '/result',
    };

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  Age _age = Age.adult;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final saved = ref.watch(savedRunProvider).value;
    final stats = data.balance.ages[_age]!;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(flex: 2),
              const Text('龙',
                  style: TextStyle(fontSize: 120, color: Palette.lacquer, height: 1)),
              const SizedBox(height: 8),
              const Text('LONG BREATH',
                  style: TextStyle(
                      fontSize: 28, letterSpacing: 8, fontWeight: FontWeight.w300)),
              const Text('长息',
                  style: TextStyle(fontSize: 16, color: Palette.paperDim)),
              const Spacer(flex: 2),
              Text(t.ageTitle, style: const TextStyle(color: Palette.paperDim)),
              const SizedBox(height: 8),
              SegmentedButton<Age>(
                segments: [
                  for (final a in Age.values)
                    ButtonSegment(value: a, label: Text(data.balance.ages[a]!.name)),
                ],
                selected: {_age},
                onSelectionChanged: (s) => setState(() => _age = s.first),
              ),
              const SizedBox(height: 6),
              Text(t.ageSummary(stats.draw, stats.breath, stats.retain),
                  style: const TextStyle(fontSize: 12, color: Palette.paperDim)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    ref.read(runControllerProvider.notifier).newRun(_age);
                    context.go('/map');
                  },
                  child: Text(t.newRun, style: const TextStyle(fontSize: 17)),
                ),
              ),
              if (saved != null &&
                  saved.phase != RunPhase.victory &&
                  saved.phase != RunPhase.defeat) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton(
                    onPressed: () {
                      // Un combate a medias se reinicia desde el mapa.
                      final r = saved.phase == RunPhase.combat
                          ? saved.copyWith(
                              phase: RunPhase.map,
                              visited: saved.visited
                                  .sublist(0, saved.visited.length - 1),
                              currentNode: saved.visited.length > 1
                                  ? saved.visited[saved.visited.length - 2]
                                  : null,
                            )
                          : saved;
                      ref.read(runControllerProvider.notifier).resume(r);
                      context.go(routeFor(r));
                    },
                    child: Text(t.continueRun),
                  ),
                ),
              ],
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
