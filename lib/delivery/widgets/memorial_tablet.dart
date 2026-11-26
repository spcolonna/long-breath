import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/run/memorial.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';

/// La tablilla de piedra del discípulo anterior, en la fila del mapa donde
/// cayó. Aparece con un leve fundido y se queda quieta: es un recuerdo.
class MemorialTablet extends ConsumerWidget {
  const MemorialTablet({super.key, required this.memorial});

  final Memorial memorial;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final foe = memorial.enemy;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(offset: Offset(0, 6 * (1 - v)), child: child),
      ),
      child: Container(
        padding: const EdgeInsets.fromLTRB(8, 5, 12, 5),
        decoration: BoxDecoration(
          color: Palette.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Palette.textDim.withValues(alpha: 0.6)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '牌',
              style: TextStyle(
                fontFamily: Fonts.display,
                fontSize: 18,
                height: 1,
                fontWeight: FontWeight.w700,
                color: Palette.textDim,
              ),
            ),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                [
                  t.memorialHere(memorial.n),
                  if (foe != null) t.memorialFoe(text.enemy(foe)),
                ].join(' '),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  height: 1.2,
                  fontStyle: FontStyle.italic,
                  color: Palette.text,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
