import 'package:flutter/material.dart';

import '../../domain/model/form_def.dart';
import '../../l10n/app_localizations.dart';
import '../theme.dart';

/// Pergamino de forma: nombre, pasos (marcando las cartas que ya tenés) y lo
/// que hace al completarse.
class FormScroll extends StatelessWidget {
  const FormScroll({
    super.key,
    required this.form,
    required this.name,
    required this.steps,
    required this.effect,
    required this.selected,
  });

  final FormDef form;
  final String name;
  final List<(String, bool)> steps;
  final String effect;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected ? Palette.lacquer : Palette.gold,
          width: selected ? 3 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Palette.gold.withValues(alpha: selected ? 0.5 : 0.25),
            blurRadius: selected ? 16 : 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                form.hanzi,
                style: const TextStyle(
                  fontSize: 24,
                  height: 1.1,
                  color: Palette.lacquer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.formScroll,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Palette.gold,
                      ),
                    ),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Palette.text,
                      ),
                    ),
                    Text(
                      form.pinyin,
                      style: const TextStyle(
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final (i, (label, owned)) in steps.indexed) ...[
                if (i > 0)
                  const Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: Palette.textDim,
                  ),
                Expanded(
                  child: Tooltip(
                    message: owned ? t.formStepOwned : t.formStepMissing,
                    child: Container(
                      height: 34,
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: owned
                            ? Palette.gold.withValues(alpha: 0.22)
                            : Palette.surface,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: owned ? Palette.gold : Palette.line,
                        ),
                      ),
                      child: Text(
                        label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 9,
                          height: 1.05,
                          fontWeight: FontWeight.w600,
                          color: owned ? Palette.text : Palette.textDim,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 8),
          Text(
            effect,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Palette.lacquer,
            ),
          ),
        ],
      ),
    );
  }
}
