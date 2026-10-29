import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../providers.dart';
import '../theme.dart';
import '../feel.dart';

/// Pregunta de sí o no sobre papel, con un sello de laca arriba. Entra
/// cayendo como un sello y el fondo se vela sin oscurecerse del todo.
/// Devuelve `true` solo si se confirmó.
Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String body,
  required String ok,
  String seal = '问',
}) async {
  Haptics.selectionClick();
  ProviderScope.containerOf(context).read(audioProvider).play(Sfx.uiButton);
  final r = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Palette.text.withValues(alpha: 0.16),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (ctx, _, _) =>
        _ConfirmCard(title: title, body: body, ok: ok, seal: seal),
    transitionBuilder: (_, anim, _, child) {
      final a = CurvedAnimation(
        parent: anim,
        curve: Curves.easeOutBack,
        reverseCurve: Curves.easeIn,
      );
      return FadeTransition(
        opacity: CurvedAnimation(parent: anim, curve: Curves.easeOut),
        child: ScaleTransition(
          scale: Tween(begin: 0.86, end: 1.0).animate(a),
          child: child,
        ),
      );
    },
  );
  return r == true;
}

class _ConfirmCard extends StatelessWidget {
  const _ConfirmCard({
    required this.title,
    required this.body,
    required this.ok,
    required this.seal,
  });

  final String title;
  final String body;
  final String ok;
  final String seal;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 380),
          child: Material(
            color: Colors.transparent,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 26),
                  padding: const EdgeInsets.fromLTRB(22, 38, 22, 14),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Palette.line, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: Palette.text.withValues(alpha: 0.18),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        body,
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.35),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          Expanded(
                            child: TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: Text(t.cancelAction),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: FilledButton(
                              onPressed: () {
                                Haptics.mediumImpact();
                                Navigator.pop(context, true);
                              },
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(ok, maxLines: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                // El sello de laca que corona la pregunta.
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Palette.lacquer,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Palette.surface, width: 3),
                  ),
                  child: Text(
                    seal,
                    style: const TextStyle(
                      fontSize: 26,
                      height: 1,
                      color: Palette.onColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
