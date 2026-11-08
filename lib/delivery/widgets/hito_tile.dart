import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/run/feats.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import 'lotus.dart';

/// Un hito 功 en papel: sello con su carácter, nombre, cómo se cumple y el
/// aliento que deja. Sellado ([sealed]) se ve apagado; recién cumplido
/// ([fresh]) lleva la marca "nuevo". Los sellados de contador muestran
/// cuánto falta.
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
    final ascents = sealed ? ref.watch(ascentsProvider).value : null;
    final best = ascents == null ? null : hitoBest(id, ascents);
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
                if (best != null && best.$1 > 0) ...[
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(3),
                          child: LinearProgressIndicator(
                            value: math.min(1, best.$1 / best.$2),
                            minHeight: 5,
                            backgroundColor: Palette.line,
                            color: Palette.gold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${math.min(best.$1, best.$2)}/${best.$2}',
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                          color: Palette.textDim,
                        ),
                      ),
                    ],
                  ),
                ],
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

/// Los hitos recién cumplidos como fila de sellos: cada uno con su nombre y
/// su aliento debajo. Tocar un sello muestra cómo se cumplió. [wrap] anima la
/// entrada de cada sello (índice y sello).
class HitoSealRow extends ConsumerStatefulWidget {
  const HitoSealRow({super.key, required this.ids, this.wrap});

  final List<String> ids;
  final Widget Function(int i, Widget seal)? wrap;

  @override
  ConsumerState<HitoSealRow> createState() => _HitoSealRowState();
}

class _HitoSealRowState extends ConsumerState<HitoSealRow> {
  String? _open;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final open = _open;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(8, 12, 8, 10),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.95),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.gold, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Palette.gold.withValues(alpha: 0.25),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            t.hitoNew,
            style: const TextStyle(
              fontSize: 11,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w800,
              color: Palette.gold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 10,
            children: [
              for (final (i, id) in widget.ids.indexed)
                (widget.wrap ?? (_, w) => w)(
                  i,
                  GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => setState(() => _open = open == id ? null : id),
                    child: SizedBox(
                      width: 84,
                      child: Column(
                        children: [
                          AnimatedScale(
                            scale: open == id ? 1.1 : 1,
                            duration: const Duration(milliseconds: 180),
                            curve: Curves.easeOutBack,
                            child: InkSeal(
                              hanzi: hito(id).hanzi,
                              color: Palette.lacquer,
                              size: 50,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            text.hito(id, 'name'),
                            textAlign: TextAlign.center,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12.5,
                              height: 1.15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          Text(
                            t.hitoBreath(hito(id).breath),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              color: Palette.gold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            child: open == null
                ? const SizedBox(width: double.infinity)
                : Padding(
                    padding: const EdgeInsets.fromLTRB(6, 10, 6, 0),
                    child: Text(
                      text.hito(open, 'text'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 13, height: 1.3),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
