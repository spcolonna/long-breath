import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import 'juice.dart';

/// Color del borde de un talismán: oro los raros, jade los comunes.
Color talismanColor(bool rare) => rare ? Palette.gold : Palette.jade;

/// Talismán dibujado con su carácter: no hace falta arte.
class TalismanBadge extends ConsumerWidget {
  const TalismanBadge({
    super.key,
    required this.id,
    this.size = 34,
    this.trigger,
  });

  final String id;
  final double size;

  /// Rebota cada vez que cambia (cuando el talismán actúa).
  final Object? trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = ref.watch(dataProvider).talisman(id);
    final color = talismanColor(def.rare);
    return Bounce(
      trigger: trigger,
      scale: 1.4,
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Palette.surface,
          border: Border.all(color: color, width: size > 40 ? 3 : 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: def.rare ? 0.55 : 0.25),
              blurRadius: def.rare ? 10 : 4,
            ),
          ],
        ),
        child: Text(
          def.hanzi,
          style: TextStyle(
            fontSize: size * 0.5,
            height: 1,
            fontWeight: FontWeight.w700,
            color: def.rare ? Palette.gold : Palette.text,
          ),
        ),
      ),
    );
  }
}

/// Fila de talismanes; al tocarla se abre la lista con lo que hace cada uno.
class TalismanRow extends StatelessWidget {
  const TalismanRow({
    super.key,
    required this.ids,
    this.size = 28,
    this.triggers = const {},
    this.wrap = true,
  });

  final List<String> ids;
  final double size;

  /// Sin [wrap] van en una sola fila, alineados a la derecha y achicándose
  /// si no entran (encabezados).
  final bool wrap;

  /// Cuántas veces actuó cada talismán (para el rebote).
  final Map<String, int> triggers;

  @override
  Widget build(BuildContext context) {
    if (ids.isEmpty) return const SizedBox.shrink();
    final badges = [
      for (final id in ids)
        TalismanBadge(id: id, size: size, trigger: triggers[id]),
    ];
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        HapticFeedback.selectionClick();
        showTalismansSheet(context, ids);
      },
      child: wrap
          ? Wrap(spacing: 4, runSpacing: 4, children: badges)
          : Align(
              alignment: Alignment.centerRight,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    for (final (i, b) in badges.indexed) ...[
                      if (i > 0) const SizedBox(width: 4),
                      b,
                    ],
                  ],
                ),
              ),
            ),
    );
  }
}

/// Lista de talismanes con su nombre y su efecto.
void showTalismansSheet(BuildContext context, List<String> ids) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.surface,
    showDragHandle: true,
    builder: (_) => _TalismansSheet(ids: ids),
  );
}

class _TalismansSheet extends ConsumerWidget {
  const _TalismansSheet({required this.ids});

  final List<String> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.talismansTitle,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              ids.isEmpty ? t.talismansNone : t.talismansHint,
              style: const TextStyle(color: Palette.textDim),
            ),
            const SizedBox(height: 12),
            for (final id in ids) ...[
              TalismanTile(id: id),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}

/// Talismán con nombre, rareza y efecto (lista y pantalla de elección).
class TalismanTile extends ConsumerWidget {
  const TalismanTile({super.key, required this.id, this.badgeSize = 44});

  final String id;
  final double badgeSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = ref.watch(dataProvider).talisman(id);
    return Row(
      children: [
        TalismanBadge(id: id, size: badgeSize),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      text.talisman(id),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (def.rare) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 1,
                      ),
                      decoration: BoxDecoration(
                        color: Palette.gold.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        t.talismanRare,
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Palette.gold,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
              Text(
                t.talismanEffect(def.effect, text),
                style: const TextStyle(fontSize: 13, color: Palette.textDim),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
