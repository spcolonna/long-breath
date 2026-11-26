import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../feel.dart';
import '../../infrastructure/progress_storage.dart';
import '../providers.dart';
import '../theme.dart';
import 'press.dart';
import 'lotus.dart';
import 'npc_portrait.dart';

/// Los sistemas de la escuela que se presentan la primera vez que se abren,
/// cada uno con quien lo cuida.
enum SystemIntro {
  meridians,
  school,
  mastery,
  progress;

  /// Clave guardada en las presentaciones vistas de la partida.
  String get id => 'intro_$name';

  String get asset => switch (this) {
    school => 'assets/art/npc/tie.webp',
    mastery => 'assets/art/npc/shuang.webp',
    _ => 'assets/art/npc/master.webp',
  };

  String get hanzi => switch (this) {
    school => '鐵',
    mastery => '霜',
    _ => '师',
  };

  Color get color => switch (this) {
    school => Palette.lacquer,
    mastery => Palette.sky,
    _ => Palette.gold,
  };
}

/// Lo que dice cada presentación: quién habla, el título, una frase suya y
/// tres o cuatro puntos con lo que hay que saber.
({String who, String title, String quote, List<(IconData, String)> points})
introText(AppLocalizations t, SystemIntro s) => switch (s) {
  SystemIntro.meridians => (
    who: t.introWhoMaster,
    title: t.meridiansTitle,
    quote: t.introMeridiansQuote,
    points: [
      (Icons.local_florist_rounded, t.introMeridians1),
      (Icons.account_tree_rounded, t.introMeridians2),
      (Icons.call_split_rounded, t.introMeridians3),
      (Icons.terrain_rounded, t.introMeridians4),
    ],
  ),
  SystemIntro.school => (
    who: t.introWhoTie,
    title: t.schoolButton,
    quote: t.introSchoolQuote,
    points: [
      (Icons.diamond_rounded, t.introSchool1),
      (Icons.foundation_rounded, t.introSchool2),
      (Icons.groups_rounded, t.introSchool3),
    ],
  ),
  SystemIntro.mastery => (
    who: t.introWhoShuang,
    title: t.masteryTitle,
    quote: t.introMasteryQuote,
    points: [
      (Icons.sports_martial_arts_rounded, t.introMastery1),
      (Icons.star_rounded, t.introMastery2),
      (Icons.lock_open_rounded, t.introMastery3),
    ],
  ),
  SystemIntro.progress => (
    who: t.introWhoMaster,
    title: t.progressTitle,
    quote: t.introProgressQuote,
    points: [
      (Icons.visibility_rounded, t.introProgress1),
      (Icons.touch_app_rounded, t.introProgress2),
      (Icons.flag_rounded, t.introProgress3),
    ],
  ),
};

/// [s] todavía no se presentó en esta partida (mientras carga, no).
bool isNew(WidgetRef ref, SystemIntro s) =>
    !(ref.watch(seenProvider).value ?? {s.id}).contains(s.id);

/// Muestra la presentación de [s] si todavía no se vio en esta partida (o
/// siempre, con [force]) y la marca como vista.
Future<void> showSystemIntro(
  BuildContext context,
  WidgetRef ref,
  SystemIntro s, {
  bool force = false,
}) async {
  final seen = await ref.read(seenProvider.future);
  if (!force && seen.contains(s.id)) return;
  if (!context.mounted) return;
  Haptics.lightImpact();
  ref.read(audioProvider).play(Sfx.scrollOpen);
  await showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.bg,
    isScrollControlled: true,
    builder: (_) => SystemIntroSheet(intro: s),
  );
  if (seen.contains(s.id)) return;
  await ref.read(progressStorageProvider).markCinematicSeen(s.id);
  ref.invalidate(seenProvider);
}

/// La hoja de la presentación: retrato, quién habla, su frase y los puntos.
class SystemIntroSheet extends StatelessWidget {
  const SystemIntroSheet({super.key, required this.intro});

  final SystemIntro intro;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final x = introText(t, intro);
    final media = MediaQuery.sizeOf(context);
    final small = media.height < 740;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: media.height * 0.92),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    NpcPortrait(
                      asset: intro.asset,
                      color: intro.color,
                      height: small ? 104 : 150,
                      badge: InkSeal(
                        hanzi: intro.hanzi,
                        color: intro.color,
                        size: small ? 38 : 46,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      x.who,
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.6,
                        color: intro.color,
                      ),
                    ),
                    Text(
                      x.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 23,
                        height: 1.1,
                        fontFamily: Fonts.display,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      x.quote,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 14.5,
                        height: 1.25,
                        fontStyle: FontStyle.italic,
                        color: Palette.textDim,
                      ),
                    ),
                    SizedBox(height: small ? 8 : 12),
                    for (final (i, (icon, line)) in x.points.indexed)
                      StaggerIn(
                        index: i,
                        child: Padding(
                          padding: EdgeInsets.only(bottom: small ? 6 : 9),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: intro.color.withValues(alpha: 0.12),
                                ),
                                child: Icon(icon, size: 16, color: intro.color),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 3),
                                  child: Text(
                                    line,
                                    style: const TextStyle(
                                      fontSize: 14.5,
                                      height: 1.25,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
              child: SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.introOk),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Cartelito «Nuevo» en el acceso a un sistema que todavía no se presentó.
class NewTag extends StatelessWidget {
  const NewTag({super.key});

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(left: 6),
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
    decoration: BoxDecoration(
      color: Palette.gold,
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      AppLocalizations.of(context).introNew,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: Palette.onColor,
      ),
    ),
  );
}

/// Botón «?» que vuelve a mostrar la presentación de un sistema.
class IntroHelpButton extends ConsumerWidget {
  const IntroHelpButton({super.key, required this.intro});

  final SystemIntro intro;

  @override
  Widget build(BuildContext context, WidgetRef ref) => IconButton(
    tooltip: AppLocalizations.of(context).introHelp,
    icon: const Icon(Icons.help_outline_rounded),
    onPressed: () => showSystemIntro(context, ref, intro, force: true),
  );
}
