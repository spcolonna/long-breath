import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/juice.dart';
import '../widgets/node_kit.dart';
import '../widgets/talisman_widgets.dart';
import 'home_screen.dart' show routeFor;
import '../feel.dart';
import '../labels.dart';
import '../widgets/press.dart';

/// Después de vencer al élite: elegir 1 de 3 talismanes. Después viene la
/// recompensa de siempre. Al empezar la subida (árbol de meridianos) es el
/// don de la escuela y después se va al mapa.
class TalismanScreen extends ConsumerWidget {
  const TalismanScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final atStart = run.currentNode == null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: TalismanChoice(
            title: atStart ? t.talismanStartTitle : t.talismanPickTitle,
            hint: atStart ? t.talismanStartHint : t.talismanPickHint,
            options: run.talismanOptions,
            onChosen: (id) {
              ref.read(runControllerProvider.notifier).chooseTalisman(id);
              context.go(routeFor(ref.read(runControllerProvider)!));
            },
          ),
        ),
      ),
    );
  }
}

/// Elegir uno de varios talismanes: entran de a uno, el elegido brilla y,
/// al confirmar, estalla en tinta antes de [onChosen].
class TalismanChoice extends ConsumerStatefulWidget {
  const TalismanChoice({
    super.key,
    required this.title,
    required this.hint,
    required this.options,
    required this.onChosen,
    this.top,
  });

  final String title;
  final String hint;
  final List<String> options;
  final ValueChanged<String> onChosen;

  /// Algo arriba del título (el sello del botín).
  final Widget? top;

  @override
  ConsumerState<TalismanChoice> createState() => _TalismanChoiceState();
}

class _TalismanChoiceState extends ConsumerState<TalismanChoice> {
  String? _picked;
  bool _taking = false;
  int _burst = 0;

  void _select(String id) {
    if (_taking) return;
    // Uno que cobra se siente más pesado en la mano.
    final cost = AppLocalizations.of(
      context,
    ).talismanCost(ref.read(dataProvider).talisman(id).effect);
    cost.isEmpty ? Haptics.selectionClick() : Haptics.mediumImpact();
    ref.read(audioProvider).play(Sfx.cardSelect);
    setState(() => _picked = id);
  }

  void _take() {
    final id = _picked;
    if (id == null || _taking) return;
    Haptics.heavyImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    setState(() {
      _taking = true;
      _burst++;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      widget.onChosen(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    return Column(
      children: [
        ?widget.top,
        const SizedBox(height: 24),
        Text(widget.title, style: const TextStyle(fontSize: 26)),
        const SizedBox(height: 6),
        Text(
          widget.hint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Palette.textDim),
        ),
        const Spacer(),
        for (final (i, id) in widget.options.indexed)
          StaggerIn(
            index: i,
            delay: const Duration(milliseconds: 150),
            step: const Duration(milliseconds: 160),
            rise: 40,
            onShow: () => ref.read(audioProvider).play(Sfx.rewardFlip),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Press(
                child: GestureDetector(
                  onTap: () => _select(id),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      PickCard(
                        picked: _picked == id,
                        dimmed: _picked != null && _picked != id,
                        taking: _taking && _picked == id,
                        accent: Palette.lacquer,
                        child: TalismanTile(id: id, badgeSize: 52),
                      ),
                      Positioned.fill(
                        child: InkBurst(
                          trigger: _picked == id ? _burst : 0,
                          colors: [
                            talismanColor(data.talisman(id)),
                            Palette.gold,
                            Colors.white,
                          ],
                          count: 36,
                          radius: 160,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: _taking && _picked != null
              ? Bounce(
                  trigger: _burst,
                  scale: 1.25,
                  child: Text(
                    t.talismanGained(text.talisman(_picked!)),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Palette.lacquer,
                    ),
                  ),
                )
              : null,
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _picked == null ? null : _take,
            child: Text(t.confirm),
          ),
        ),
      ],
    );
  }
}
