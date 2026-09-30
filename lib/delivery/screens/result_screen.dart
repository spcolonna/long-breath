import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';

class ResultScreen extends ConsumerWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final won = run.phase == RunPhase.victory;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              Text(won ? '龙' : '败',
                  style: TextStyle(
                      fontSize: 120, color: won ? Palette.gold : Palette.lacquer)),
              Text(won ? t.runWon : t.runLost, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('${run.visited.length} / 7 · ${t.deckCount(run.deck.length)}',
                  style: const TextStyle(color: Palette.textDim)),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    ref.read(runControllerProvider.notifier).newRun();
                    context.go('/map');
                  },
                  child: Text(t.tryAgain),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(runControllerProvider.notifier).abandon();
                  ref.invalidate(savedRunProvider);
                  context.go('/');
                },
                child: Text(t.backHome),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
