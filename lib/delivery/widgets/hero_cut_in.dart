import 'package:flutter/material.dart';

import '../feel.dart';

/// Pose del héroe de frente en el corte rápido.
enum CutInPose { strike, guard }

/// Corte rápido del héroe de frente: una franja del color del camino entra en
/// diagonal con su pose (golpe en la Técnica del Camino, guardia al abrir el
/// Contragolpe), se sostiene un instante y sale. En combate se lo ve de
/// espaldas; el corte es el único momento en que se le ve la cara.
///
/// Con movimiento reducido solo aparece y se desvanece.
class HeroCutIn extends StatefulWidget {
  const HeroCutIn({
    super.key,
    required this.trigger,
    required this.pose,
    required this.color,
  });

  final int trigger;
  final CutInPose pose;
  final Color color;

  static const duration = Duration(milliseconds: 1100);

  static String asset(CutInPose p) => 'assets/art/player/hero_${p.name}.webp';

  @override
  State<HeroCutIn> createState() => _HeroCutInState();
}

class _HeroCutInState extends State<HeroCutIn>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(vsync: this, duration: HeroCutIn.duration);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Decodificadas de antemano: el corte no puede llegar tarde al golpe.
    for (final p in CutInPose.values) {
      precacheImage(AssetImage(HeroCutIn.asset(p)), context);
    }
  }

  @override
  void didUpdateWidget(HeroCutIn old) {
    super.didUpdateWidget(old);
    if (widget.trigger != old.trigger) _c.forward(from: 0);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final still = calm(context);
    return IgnorePointer(
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _c,
          builder: (context, _) {
            if (!_c.isAnimating) return const SizedBox.expand();
            final t = _c.value;
            // Entra (0–0.18), se sostiene con una deriva lenta y sale (0.8–1).
            final enter = Curves.easeOutCubic.transform((t / 0.18).clamp(0, 1));
            final exit = Curves.easeInCubic.transform(
              ((t - 0.8) / 0.2).clamp(0, 1),
            );
            final fade = still
                ? (t < 0.15 ? t / 0.15 : (t > 0.8 ? 1 - exit : 1.0))
                : 1.0;
            final slide = still ? 0.0 : (1 - enter) * -1.0 + exit * 1.0;
            final drift = still ? 0.0 : 0.04 * t;
            return LayoutBuilder(
              builder: (context, box) {
                final h = box.maxHeight * 0.42;
                final band = h * 0.62;
                return Opacity(
                  opacity: fade.clamp(0, 1),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Franja diagonal del color del camino.
                      Positioned(
                        left: -box.maxWidth * 0.2,
                        right: -box.maxWidth * 0.2,
                        top: box.maxHeight * 0.36,
                        height: band,
                        child: Transform.translate(
                          offset: Offset(slide * box.maxWidth * 1.4, 0),
                          child: Transform.rotate(
                            angle: -0.12,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    widget.color.withValues(alpha: 0),
                                    widget.color.withValues(alpha: 0.85),
                                    widget.color.withValues(alpha: 0.85),
                                    widget.color.withValues(alpha: 0),
                                  ],
                                  stops: const [0, 0.25, 0.75, 1],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      // El héroe, un poco más rápido que la franja.
                      Positioned(
                        left: box.maxWidth * 0.06,
                        top: box.maxHeight * 0.36 + band - h,
                        height: h,
                        child: Transform.translate(
                          offset: Offset(
                            (slide * 1.6 + drift) * box.maxWidth,
                            0,
                          ),
                          child: Image.asset(
                            HeroCutIn.asset(widget.pose),
                            height: h,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
