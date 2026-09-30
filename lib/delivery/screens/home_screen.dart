import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/hero_sprite.dart';

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
  Style _style = Style.snake;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final saved = ref.watch(savedRunProvider).value;
    final stats = data.balance.styles[_style]!;
    final text = ref.watch(textProvider);
    final accent = styleColor(_style);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          child: Column(
            children: [
              const FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text('龙 ',
                        style: TextStyle(fontSize: 30, color: Palette.lacquer, height: 1)),
                    Text('LONG BREATH',
                        style: TextStyle(
                            fontSize: 22, letterSpacing: 6, fontWeight: FontWeight.w300)),
                    Text('  长息', style: TextStyle(fontSize: 13, color: Palette.textDim)),
                  ],
                ),
              ),
              // El héroe cambia de ropa y de aura según el camino elegido.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => AnimatedSwitcher(
                    duration: const Duration(milliseconds: 450),
                    transitionBuilder: (child, anim) => FadeTransition(
                      opacity: anim,
                      child: ScaleTransition(
                          scale: Tween(begin: 0.94, end: 1.0).animate(anim), child: child),
                    ),
                    child: HeroSprite(
                      key: ValueKey(_style),
                      style: _style,
                      height: math.min(box.maxHeight, box.maxWidth * 1.3),
                      glyph: stats.hanzi,
                    ),
                  ),
                ),
              ),
              Text(t.styleTitle, style: const TextStyle(color: Palette.textDim)),
              const SizedBox(height: 8),
              Row(
                children: [
                  for (final a in Style.values)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: _StyleTile(
                          name: text.style(a),
                          hanzi: data.balance.styles[a]!.hanzi,
                          color: styleColor(a),
                          selected: a == _style,
                          onTap: () => setState(() => _style = a),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              Text(text.styleMotto(_style),
                  style: TextStyle(
                      fontSize: 15, fontStyle: FontStyle.italic, color: accent)),
              const SizedBox(height: 2),
              Text(t.styleSummary(stats.draw, stats.breath, stats.retain),
                  style: const TextStyle(fontSize: 12, color: Palette.textDim)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    ref.read(runControllerProvider.notifier).newRun(_style);
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
            ],
          ),
        ),
      ),
    );
  }
}

class _StyleTile extends StatelessWidget {
  const _StyleTile({
    required this.name,
    required this.hanzi,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String hanzi;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: selected ? color : Palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? color : Palette.line, width: 1.5),
          boxShadow: selected
              ? [BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 10)]
              : null,
        ),
        child: Column(
          children: [
            Text(name,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: selected ? Palette.onColor : Palette.text)),
            Text(hanzi,
                style: TextStyle(
                    fontSize: 13, color: selected ? Palette.onColor : color)),
          ],
        ),
      ),
    );
  }
}
