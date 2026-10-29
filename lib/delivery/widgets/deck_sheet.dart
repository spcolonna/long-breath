import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_state.dart';
import '../audio/game_audio.dart';
import '../providers.dart';
import '../theme.dart';
import 'card_widget.dart';
import 'juice.dart';
import 'press.dart';

/// Qué le pasa a la carta elegida antes de avisar: se quema (quitar) o se
/// ilumina y sube de nivel (mejorar).
enum DeckPick { remove, upgrade }

/// Grilla de cartas; con [onPick] se puede elegir una. Con [pickFx], la
/// elegida se anima (con sonido y vibración) y recién después se avisa.
class DeckGrid extends ConsumerStatefulWidget {
  const DeckGrid({
    super.key,
    required this.cards,
    this.onPick,
    this.enabled,
    this.pickFx,
  });

  final List<CombatCard> cards;
  final void Function(CombatCard)? onPick;
  final bool Function(CombatCard)? enabled;
  final DeckPick? pickFx;

  @override
  ConsumerState<DeckGrid> createState() => _DeckGridState();
}

class _DeckGridState extends ConsumerState<DeckGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fx;
  int? _picked;

  @override
  void initState() {
    super.initState();
    _fx = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 760),
    );
  }

  @override
  void dispose() {
    _fx.dispose();
    super.dispose();
  }

  Future<void> _pick(CombatCard c) async {
    final fx = widget.pickFx;
    if (fx == null) return widget.onPick!(c);
    if (_picked != null) return;
    setState(() => _picked = c.uid);
    final audio = ref.read(audioProvider);
    if (fx == DeckPick.remove) {
      HapticFeedback.mediumImpact();
      audio.play(Sfx.breathSpend);
    } else {
      // La fanfarria queda para la pantalla que llama.
      HapticFeedback.mediumImpact();
      audio.play(Sfx.rewardFlip);
    }
    await _fx.forward(from: 0);
    if (mounted) widget.onPick!(c);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(dataProvider);
    final sorted = [...widget.cards]
      ..sort((a, b) => a.cardId.compareTo(b.cardId));
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 96,
        childAspectRatio: 1 / 1.5,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
      ),
      itemCount: sorted.length,
      itemBuilder: (_, i) {
        final c = sorted[i];
        final ok = widget.enabled?.call(c) ?? true;
        final tappable = widget.onPick != null && ok && _picked == null;
        Widget card(int upgrades) => FittedBox(
          child: CardWidget(
            def: data.card(c.cardId),
            upgrades: upgrades,
            playable: ok,
          ),
        );
        final Widget child;
        if (_picked == null) {
          child = card(c.upgrades);
        } else if (_picked != c.uid) {
          // Las demás se apagan para que la elegida sea la protagonista.
          child = AnimatedOpacity(
            opacity: 0.35,
            duration: const Duration(milliseconds: 250),
            child: card(c.upgrades),
          );
        } else {
          child = _PickedCard(
            fx: widget.pickFx!,
            anim: _fx,
            card: card,
            upgrades: c.upgrades,
          );
        }
        return Press(
          enabled: tappable,
          haptic: false,
          child: GestureDetector(
            onTap: tappable ? () => _pick(c) : null,
            child: child,
          ),
        );
      },
    );
  }
}

/// La carta elegida: se quema y se va, o brilla en oro y sube de nivel.
class _PickedCard extends StatelessWidget {
  const _PickedCard({
    required this.fx,
    required this.anim,
    required this.card,
    required this.upgrades,
  });

  final DeckPick fx;
  final Animation<double> anim;
  final Widget Function(int upgrades) card;
  final int upgrades;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: anim,
    builder: (_, _) {
      final t = anim.value;
      if (fx == DeckPick.remove) {
        // Se eleva, se tiñe de laca y se deshace en tinta.
        final lift = Curves.easeOut.transform((t / 0.3).clamp(0, 1));
        final fade = Curves.easeIn.transform(((t - 0.3) / 0.7).clamp(0, 1));
        return Stack(
          clipBehavior: Clip.none,
          fit: StackFit.expand,
          children: [
            Opacity(
              opacity: 1 - fade,
              child: Transform.translate(
                offset: Offset(0, -10 * lift - 30 * fade),
                child: Transform.rotate(
                  angle: 0.12 * fade,
                  child: Transform.scale(
                    scale: 1 + 0.12 * lift - 0.4 * fade,
                    child: ColorFiltered(
                      colorFilter: ColorFilter.mode(
                        Palette.lacquer.withValues(alpha: 0.55 * lift),
                        BlendMode.srcATop,
                      ),
                      child: card(upgrades),
                    ),
                  ),
                ),
              ),
            ),
            InkBurst(
              trigger: t > 0.3 ? 1 : 0,
              colors: const [Palette.lacquer, Palette.gold, Palette.text],
              count: 18,
              radius: 70,
            ),
          ],
        );
      }
      // Mejora: crece, destella en oro y queda con el nivel nuevo.
      final up = t < 0.45
          ? Curves.easeOut.transform(t / 0.45)
          : 1 - Curves.easeInOut.transform((t - 0.45) / 0.55) * 0.6;
      final glow = math.sin(t * math.pi);
      return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Transform.scale(
            scale: 1 + 0.16 * up,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Palette.gold.withValues(alpha: 0.75 * glow),
                    blurRadius: 22 * glow,
                    spreadRadius: 3 * glow,
                  ),
                ],
              ),
              child: card(t > 0.45 ? upgrades + 1 : upgrades),
            ),
          ),
          InkBurst(
            trigger: t > 0.45 ? 1 : 0,
            colors: const [Palette.gold, Palette.jade, Colors.white],
            count: 20,
            radius: 80,
          ),
        ],
      );
    },
  );
}

void showDeckSheet(BuildContext context, List<CombatCard> deck) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Palette.surface,
    builder: (_) => SizedBox(
      height: MediaQuery.of(context).size.height * 0.75,
      child: DeckGrid(cards: deck),
    ),
  );
}
