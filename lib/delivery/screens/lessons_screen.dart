import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../tutorial/lessons.dart';
import '../widgets/juice.dart';

/// Lista de lecciones: en orden, cada una se habilita al completar la
/// anterior y todas se pueden repetir.
class LessonsScreen extends ConsumerWidget {
  const LessonsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final done = ref.watch(lessonsDoneProvider).value ?? const <String>{};
    final allDone = lessons.every((l) => done.contains(l.id));

    void open(Lesson l) {
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
      if (l.isCombat) {
        ref.read(combatControllerProvider.notifier).startLesson(l.id);
        context.go('/combat');
      } else {
        context.go('/lessons/climb');
      }
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: t.mapHome,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/'),
        ),
        title: Text(t.lessonsTitle),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          Text(
            allDone ? t.lessonAllDone : t.lessonsIntro,
            style: const TextStyle(
              fontSize: 14,
              color: Palette.textDim,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          for (final (i, l) in lessons.indexed)
            _LessonTile(
              number: i + 1,
              lesson: l,
              done: done.contains(l.id),
              // La siguiente sin hacer es la que se destaca.
              current:
                  !done.contains(l.id) &&
                  (i == 0 || done.contains(lessons[i - 1].id)),
              locked:
                  i > 0 &&
                  !done.contains(lessons[i - 1].id) &&
                  !done.contains(l.id),
              onTap: () => open(l),
              delayMs: 60 * i,
            ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  const _LessonTile({
    required this.number,
    required this.lesson,
    required this.done,
    required this.current,
    required this.locked,
    required this.onTap,
    required this.delayMs,
  });

  final int number;
  final Lesson lesson;
  final bool done;
  final bool current;
  final bool locked;
  final VoidCallback onTap;
  final int delayMs;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final accent = done
        ? Palette.jade
        : current
        ? Palette.lacquer
        : Palette.textDim;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 380 + delayMs),
      curve: Interval(delayMs / (380 + delayMs), 1, curve: Curves.easeOutCubic),
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: child,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Opacity(
          opacity: locked ? 0.5 : 1,
          child: Material(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(14),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: locked ? null : onTap,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: current ? Palette.lacquer : Palette.line,
                    width: current ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Bounce(
                      trigger: done ? 1 : 0,
                      child: Container(
                        width: 42,
                        height: 42,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: done || current ? accent : Palette.bg,
                          shape: BoxShape.circle,
                        ),
                        child: done
                            ? const Icon(
                                Icons.check_rounded,
                                color: Palette.onColor,
                              )
                            : locked
                            ? const Icon(
                                Icons.lock_rounded,
                                size: 18,
                                color: Palette.textDim,
                              )
                            : Text(
                                '$number',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: current
                                      ? Palette.onColor
                                      : Palette.text,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            t.lessonNumber(number),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: accent,
                            ),
                          ),
                          Text(
                            lesson.title(t),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            locked ? t.lessonLocked : lesson.blurb(t),
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
                      t.lessonMinutes(lesson.minutes),
                      style: const TextStyle(
                        fontSize: 11,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
