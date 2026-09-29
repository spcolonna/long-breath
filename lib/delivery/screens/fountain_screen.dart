import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/deck_sheet.dart';

enum _Mode { choose, remove, upgrade }

class FountainScreen extends ConsumerStatefulWidget {
  const FountainScreen({super.key});

  @override
  ConsumerState<FountainScreen> createState() => _FountainScreenState();
}

class _FountainScreenState extends ConsumerState<FountainScreen> {
  _Mode _mode = _Mode.choose;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final ctl = ref.read(runControllerProvider.notifier);

    void done() => context.go('/map');

    if (_mode != _Mode.choose) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          title: Text(_mode == _Mode.remove
              ? t.fountainRemove
              : t.fountainUpgrade(data.balance.fountainUpgrade)),
          leading: BackButton(onPressed: () => setState(() => _mode = _Mode.choose)),
        ),
        body: DeckGrid(
          cards: run.deck,
          enabled: _mode == _Mode.upgrade ? engine.canUpgrade : null,
          onPick: (c) {
            _mode == _Mode.remove ? ctl.removeCard(c.uid) : ctl.upgradeCard(c.uid);
            done();
          },
        ),
      );
    }

    Widget option(IconData icon, String label, VoidCallback onTap) => Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: SizedBox(
            width: double.infinity,
            height: 56,
            child: OutlinedButton.icon(
              onPressed: onTap,
              icon: Icon(icon),
              label: Text(label, style: const TextStyle(fontSize: 16)),
            ),
          ),
        );

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Spacer(),
              const Text('泉', style: TextStyle(fontSize: 96, color: Palette.sky)),
              Text(t.fountain, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 8),
              Text('${t.life}: ${run.hp}/${run.maxHp}',
                  style: const TextStyle(color: Palette.textDim)),
              const Spacer(),
              option(Icons.favorite, t.fountainHeal(data.balance.fountainHeal), () {
                ctl.heal();
                done();
              }),
              option(Icons.delete_outline, t.fountainRemove,
                  () => setState(() => _mode = _Mode.remove)),
              option(Icons.upgrade, t.fountainUpgrade(data.balance.fountainUpgrade),
                  () => setState(() => _mode = _Mode.upgrade)),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}
