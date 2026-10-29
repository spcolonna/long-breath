import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../providers.dart';
import '../theme.dart';
import 'press.dart';

/// Botón grande del menú, con ícono, subtítulo y una marca opcional.
class MenuButton extends StatelessWidget {
  const MenuButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.badge,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final String? badge;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final fg = primary ? Palette.onColor : Palette.text;
    return Press(
      child: Material(
        color: primary ? Palette.lacquer : Palette.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: primary ? Palette.lacquer : Palette.line,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: primary ? Palette.onColor : Palette.lacquer,
                  size: 30,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: fg,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12.5,
                          color: fg.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Palette.gold,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      badge!,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w800,
                        color: Palette.onColor,
                      ),
                    ),
                  ),
                Icon(
                  Icons.chevron_right_rounded,
                  color: fg.withValues(alpha: 0.7),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Interruptores de efectos y música; se recuerdan entre sesiones.
class AudioToggles extends ConsumerStatefulWidget {
  const AudioToggles({super.key});

  @override
  ConsumerState<AudioToggles> createState() => _AudioTogglesState();
}

class _AudioTogglesState extends ConsumerState<AudioToggles> {
  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final audio = ref.watch(audioProvider);
    Widget toggle(
      bool on,
      IconData onIcon,
      IconData offIcon,
      String tip,
      Future<void> Function(bool) set,
    ) => IconButton(
      tooltip: tip,
      visualDensity: VisualDensity.compact,
      color: on ? Palette.text : Palette.textDim,
      icon: Icon(on ? onIcon : offIcon, size: 22),
      onPressed: () async {
        await set(!on);
        if (!on) audio.play(Sfx.uiButton);
        setState(() {});
      },
    );
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        toggle(
          audio.sfxOn,
          Icons.volume_up_rounded,
          Icons.volume_off_rounded,
          t.soundEffects,
          audio.setSfxOn,
        ),
        toggle(
          audio.musicOn,
          Icons.music_note_rounded,
          Icons.music_off_rounded,
          t.music,
          audio.setMusicOn,
        ),
      ],
    );
  }
}
