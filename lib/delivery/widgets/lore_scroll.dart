import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/run/ascent.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';

const _rod = Color(0xFFC9A46A);
const _rodEdge = Color(0xFFA9844C);

/// Un pergamino de la escuela: papel entre dos varillas. Lacrado (con el
/// sello rojo y la pista de cómo se abre) si todavía no se ganó.
class LoreScroll extends ConsumerWidget {
  const LoreScroll({
    super.key,
    required this.id,
    this.sealed = false,
    this.fresh = false,
    this.open = 1,
  });

  final String id;
  final bool sealed;

  /// Marca "nuevo" (se acaba de abrir en esta subida).
  final bool fresh;

  /// Cuánto está desenrollado (0..1), para animarlo al abrirse.
  final double open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final number = loreOrder.indexOf(id) + 1;
    Widget rod() => Container(
      height: 10,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFE2C28A), _rod],
        ),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: _rodEdge),
      ),
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rod(),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: open.clamp(0.0, 1.0),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
              decoration: BoxDecoration(
                color: sealed ? const Color(0xFFF1E8D6) : Palette.surface,
                border: const Border.symmetric(
                  vertical: BorderSide(color: Palette.line),
                ),
              ),
              child: sealed
                  ? Row(
                      children: [
                        Container(
                          width: 34,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Palette.lacquer.withValues(alpha: 0.85),
                            shape: BoxShape.circle,
                          ),
                          child: const Text(
                            '封',
                            style: TextStyle(
                              color: Palette.onColor,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$number · ${t.scrollSealed}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Palette.textDim,
                                ),
                              ),
                              Text(
                                text.lore(id, 'hint'),
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Palette.textDim,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                text.lore(id, 'title'),
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                            if (fresh)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Palette.gold,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Text(
                                  t.loreNew,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    color: Palette.onColor,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          text.lore(id, 'text'),
                          style: const TextStyle(
                            fontSize: 14.5,
                            height: 1.4,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        rod(),
      ],
    );
  }
}
