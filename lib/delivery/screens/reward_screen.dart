import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';

class RewardScreen extends ConsumerStatefulWidget {
  const RewardScreen({super.key});

  @override
  ConsumerState<RewardScreen> createState() => _RewardScreenState();
}

class _RewardScreenState extends ConsumerState<RewardScreen> {
  String? _picked;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);

    void choose(String? id) {
      ref.read(runControllerProvider.notifier).chooseReward(id);
      context.go('/map');
    }

    final picked = _picked == null ? null : data.card(_picked!);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 24),
              Text(t.rewardTitle, style: const TextStyle(fontSize: 26)),
              const SizedBox(height: 6),
              Text(t.rewardHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Palette.paperDim)),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  for (final id in run.rewardOptions)
                    GestureDetector(
                      onTap: () => setState(() => _picked = id),
                      child: CardWidget(
                        def: data.card(id),
                        width: 104,
                        selected: _picked == id,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 72,
                child: picked == null
                    ? null
                    : Text(
                        '${picked.pinyin} ${picked.hanzi} · ${picked.es}\n'
                        '${cardEffectText(picked)}'
                        '${data.forms.any((f) => f.steps.contains(picked.id)) ? '\nParte de una forma' : ''}',
                        textAlign: TextAlign.center,
                      ),
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                        onPressed: () => choose(null), child: Text(t.skip)),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: _picked == null ? null : () => choose(_picked),
                      child: Text(t.confirm),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
