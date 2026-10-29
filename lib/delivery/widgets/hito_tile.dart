import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/run/feats.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import 'lotus.dart';

/// Un hito 功 en papel: sello con su carácter, nombre, cómo se cumple y el
/// aliento que deja. Sellado ([sealed]) se ve apagado; recién cumplido
/// ([fresh]) lleva la marca "nuevo".
class HitoTile extends ConsumerWidget {
  const HitoTile({
    super.key,
    required this.id,
    this.sealed = false,
    this.fresh = false,
  });

  final String id;
  final bool sealed;
  final bool fresh;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = hito(id);
    final accent = sealed ? Palette.textDim : Palette.gold;
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 10, 14, 10),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: sealed ? 0.7 : 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: fresh ? Palette.gold : Palette.line,
          width: fresh ? 1.6 : 1,
        ),
        boxShadow: sealed
            ? null
            : [
                BoxShadow(
                  color: Palette.gold.withValues(alpha: fresh ? 0.3 : 0.12),
                  blurRadius: fresh ? 14 : 6,
                  offset: const Offset(0, 2),
                ),
              ],
      ),
      child: Row(
        children: [
          InkSeal(
            hanzi: def.hanzi,
            color: Palette.lacquer,
            size: 42,
            dim: sealed,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        text.hito(id, 'name'),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: sealed ? Palette.textDim : Palette.text,
                        ),
                      ),
                    ),
                    if (fresh) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 1,
                        ),
                        decoration: BoxDecoration(
                          color: Palette.gold,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          t.hitoNew,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            color: Palette.onColor,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  text.hito(id, 'text'),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Palette.textDim,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            t.hitoBreath(def.breath),
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: accent,
            ),
          ),
        ],
      ),
    );
  }
}
