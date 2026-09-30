import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/juice.dart';

/// Santuario de los animales: la montaña ofrece dos caminos al azar y el
/// novicio toma uno. Al tocar un camino, la túnica se tiñe de su color.
class ShrineScreen extends ConsumerStatefulWidget {
  const ShrineScreen({super.key});

  @override
  ConsumerState<ShrineScreen> createState() => _ShrineScreenState();
}

class _ShrineScreenState extends ConsumerState<ShrineScreen> {
  Style? _picked;

  /// Momento del juramento: el héroe estalla en el color del camino.
  bool _sworn = false;
  int _burst = 0;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final picked = _picked;
    final stats = data.balance.statsOf(picked);

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            children: [
              Text(t.shrineTitle, style: const TextStyle(fontSize: 24)),
              const SizedBox(height: 6),
              Text(
                t.shrineHint,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Palette.textDim),
              ),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => Stack(
                    alignment: Alignment.center,
                    children: [
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 450),
                        transitionBuilder: (child, anim) => FadeTransition(
                          opacity: anim,
                          child: ScaleTransition(
                            scale: Tween(begin: 0.94, end: 1.0).animate(anim),
                            child: child,
                          ),
                        ),
                        child: HeroSprite(
                          key: ValueKey(picked),
                          style: picked,
                          height: math.min(box.maxHeight, box.maxWidth * 1.3),
                          glyph: stats.hanzi,
                          victory: _sworn,
                        ),
                      ),
                      Positioned.fill(
                        child: InkBurst(
                          trigger: _burst,
                          colors: [
                            styleColor(picked),
                            Palette.gold,
                            Colors.white,
                          ],
                          count: 40,
                          radius: box.maxWidth * 0.55,
                          duration: const Duration(milliseconds: 1000),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  for (final s in run.pathOptions)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: _PathTile(
                          name: text.style(s),
                          hanzi: data.balance.styles[s]!.hanzi,
                          motto: text.styleMotto(s),
                          color: styleColor(s),
                          selected: s == picked,
                          onTap: () {
                            if (_sworn) return;
                            HapticFeedback.selectionClick();
                            ref.read(audioProvider).play(Sfx.cardSelect);
                            setState(() => _picked = s);
                          },
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 10),
              AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: picked == null ? 0 : 1,
                child: Text(
                  t.styleSummary(stats.draw, stats.breath, stats.retain),
                  style: const TextStyle(fontSize: 12, color: Palette.textDim),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  style: picked == null
                      ? null
                      : FilledButton.styleFrom(
                          backgroundColor: styleColor(picked),
                        ),
                  onPressed: picked == null
                      ? null
                      : () {
                          if (_sworn) return;
                          HapticFeedback.heavyImpact();
                          ref.read(audioProvider).play(Sfx.shrineOath);
                          setState(() {
                            _sworn = true;
                            _burst++;
                          });
                          Future.delayed(
                            const Duration(milliseconds: 1000),
                            () {
                              if (!context.mounted) return;
                              ref
                                  .read(runControllerProvider.notifier)
                                  .choosePath(picked);
                              context.go('/map');
                            },
                          );
                        },
                  child: Text(
                    t.shrineConfirm,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PathTile extends StatelessWidget {
  const _PathTile({
    required this.name,
    required this.hanzi,
    required this.motto,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final String hanzi;
  final String motto;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? Palette.onColor : Palette.text;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
        decoration: BoxDecoration(
          color: selected ? color : Palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color, width: selected ? 2 : 1.5),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.35),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        child: Column(
          children: [
            Text(
              hanzi,
              style: TextStyle(
                fontSize: 28,
                height: 1.1,
                color: selected ? Palette.onColor : color,
              ),
            ),
            Text(
              name,
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: fg,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              motto,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
