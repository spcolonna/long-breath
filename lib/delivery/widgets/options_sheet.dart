import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../feel.dart';
import '../providers.dart';
import '../theme.dart';
import 'press.dart';

/// Botón de Opciones (engranaje) para el inicio y la escuela.
class OptionsButton extends StatelessWidget {
  const OptionsButton({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: AppLocalizations.of(context).options,
    visualDensity: VisualDensity.compact,
    color: Palette.text,
    icon: const Icon(Icons.tune_rounded, size: 24),
    onPressed: () => showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.bg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => const _OptionsSheet(),
    ),
  );
}

/// Sonido, música, movimiento y vibración. Todo se recuerda entre sesiones y
/// vale para las tres partidas.
class _OptionsSheet extends ConsumerStatefulWidget {
  const _OptionsSheet();

  @override
  ConsumerState<_OptionsSheet> createState() => _OptionsSheetState();
}

class _OptionsSheetState extends ConsumerState<_OptionsSheet> {
  void _tick() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final audio = ref.watch(audioProvider);
    final feel = ref.watch(feelProvider);
    final notifier = ref.read(feelProvider.notifier);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Palette.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              t.options,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 14),
            _Switch(
              icon: Icons.volume_up_rounded,
              label: t.soundEffects,
              on: audio.sfxOn,
              onChanged: (v) async {
                await audio.setSfxOn(v);
                if (v) _tick();
                setState(() {});
              },
            ),
            _Switch(
              icon: Icons.music_note_rounded,
              label: t.music,
              on: audio.musicOn,
              onChanged: (v) async {
                await audio.setMusicOn(v);
                _tick();
                setState(() {});
              },
            ),
            _Switch(
              icon: Icons.vibration_rounded,
              label: t.vibration,
              on: feel.haptics,
              onChanged: (v) {
                notifier.set(feel.copyWith(haptics: v));
                _tick();
              },
            ),
            const SizedBox(height: 14),
            Text(
              t.motionTitle,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                for (final m in MotionPref.values) ...[
                  if (m != MotionPref.values.first) const SizedBox(width: 8),
                  Expanded(
                    child: _Segment(
                      label: switch (m) {
                        MotionPref.system => t.motionSystem,
                        MotionPref.full => t.motionFull,
                        MotionPref.reduced => t.motionReduced,
                      },
                      selected: feel.motion == m,
                      onTap: () {
                        notifier.set(feel.copyWith(motion: m));
                        _tick();
                      },
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Text(
              t.motionHint,
              style: const TextStyle(fontSize: 12.5, color: Palette.textDim),
            ),
          ],
        ),
      ),
    );
  }
}

class _Switch extends StatelessWidget {
  const _Switch({
    required this.icon,
    required this.label,
    required this.on,
    required this.onChanged,
  });

  final IconData icon;
  final String label;
  final bool on;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 2),
    child: Row(
      children: [
        Icon(icon, color: on ? Palette.lacquer : Palette.textDim, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15.5, fontWeight: FontWeight.w600),
          ),
        ),
        Switch(
          value: on,
          activeTrackColor: Palette.lacquer,
          onChanged: onChanged,
        ),
      ],
    ),
  );
}

class _Segment extends StatelessWidget {
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Press(
    child: GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(
          color: selected ? Palette.lacquer : Palette.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? Palette.lacquer : Palette.line,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: selected ? Palette.onColor : Palette.text,
          ),
        ),
      ),
    ),
  );
}
