import '../../domain/model/enums.dart';
import '../../domain/tutorial.dart';
import '../../l10n/app_localizations.dart';
import 'tutorial_steps.dart';

/// Una lección del tutorial. Las de combate tienen [setup]; la de la subida
/// es una serie de diapositivas.
class Lesson {
  const Lesson({
    required this.id,
    required this.minutes,
    required this.title,
    required this.blurb,
    this.done,
    this.steps,
  });

  final String id;
  final int minutes;
  final String Function(AppLocalizations) title;
  final String Function(AppLocalizations) blurb;

  /// Lo que se aprendió, para el cartel final.
  final String Function(AppLocalizations)? done;
  final List<TutorialStep> Function(AppLocalizations)? steps;

  LessonSetup? get setup => lessonSetups[id];
  bool get isCombat => setup != null;
}

final lessons = <Lesson>[
  Lesson(
    id: 'strike',
    minutes: 3,
    title: (t) => t.lesStrikeTitle,
    blurb: (t) => t.lesStrikeBlurb,
    done: (t) => t.lesStrikeDone,
    steps: (t) => [
      TutorialStep(t.lesStrike1),
      TutorialStep(t.lesStrike2, anchor: 'player'),
      TutorialStep(t.lesStrike3, anchor: 'enemyInfo'),
      TutorialStep(t.lesStrike4, anchor: 'hand'),
      TutorialStep(t.lesStrike5, illustration: Illustration.card),
      TutorialStep(t.lesStrike6, anchor: 'breath'),
      TutorialStep(
        t.lesStrike7,
        anchor: 'card:mabu_chongquan',
        waitSelect: 'mabu_chongquan',
      ),
      TutorialStep(
        t.lesStrike8,
        anchor: 'card:mabu_chongquan+preview',
        waitCard: 'mabu_chongquan',
      ),
      TutorialStep(t.lesStrike9, anchor: 'enemyInfo', delayMs: 900),
      TutorialStep(
        t.lesStrike10,
        anchor: 'card:tui_zhang+preview',
        waitCard: 'tui_zhang',
      ),
      TutorialStep(
        t.lesStrike11,
        anchor: 'card:mabu_chongquan+preview',
        waitCard: 'mabu_chongquan',
        delayMs: 500,
      ),
      TutorialStep(t.lesStrike12, anchor: 'hand', delayMs: 500),
      TutorialStep(t.lesStrike13, anchor: 'intent'),
      TutorialStep(t.lesStrike14, anchor: 'endTurn', waitTurn: 2),
      TutorialStep(t.lesStrike15, anchor: 'player', delayMs: 1800),
      TutorialStep(
        t.lesStrike16,
        anchor: 'hand',
        illustration: Illustration.turn,
      ),
      TutorialStep(t.lesStrike17),
    ],
  ),
  Lesson(
    id: 'defend',
    minutes: 4,
    title: (t) => t.lesDefendTitle,
    blurb: (t) => t.lesDefendBlurb,
    done: (t) => t.lesDefendDone,
    steps: (t) => [
      TutorialStep(
        t.lesDefend1,
        anchor: 'intent',
        illustration: Illustration.intent,
      ),
      TutorialStep(
        t.lesDefend2,
        anchor: 'card:shang_jia',
        illustration: Illustration.heights,
      ),
      TutorialStep(
        t.lesDefend3,
        anchor: 'card:shang_jia+preview',
        waitCard: 'shang_jia',
      ),
      TutorialStep(t.lesDefend4, anchor: 'guard', delayMs: 600),
      TutorialStep(
        t.lesDefend5,
        anchor: 'card:mabu_chongquan+preview',
        waitCard: 'mabu_chongquan',
      ),
      TutorialStep(t.lesDefend6, anchor: 'endTurn', waitTurn: 2),
      TutorialStep(t.lesDefend7, anchor: 'enemyInfo', delayMs: 1800),
      TutorialStep(t.lesDefend8, anchor: 'guard+breath'),
      TutorialStep(t.lesDefend9, anchor: 'intent'),
      TutorialStep(
        t.lesDefend10,
        anchor: 'card:an_zhang+preview',
        waitCard: 'an_zhang',
      ),
      TutorialStep(t.lesDefend11, anchor: 'endTurn', waitTurn: 3),
      TutorialStep(t.lesDefend12, anchor: 'player', delayMs: 1800),
      TutorialStep(t.lesDefend13, anchor: 'enemyRule'),
      TutorialStep(t.lesDefend14),
    ],
  ),
  Lesson(
    id: 'stances',
    minutes: 3,
    title: (t) => t.lesStancesTitle,
    blurb: (t) => t.lesStancesBlurb,
    done: (t) => t.lesStancesDone,
    steps: (t) => [
      TutorialStep(t.lesStances1, anchor: 'stances'),
      TutorialStep(
        t.lesStances2,
        anchor: 'card:gongbu_chongquan',
        waitSelect: 'gongbu_chongquan',
      ),
      TutorialStep(
        t.lesStances3,
        anchor: 'card:gongbu_chongquan+preview',
        waitCard: 'gongbu_chongquan',
      ),
      TutorialStep(t.lesStances4, anchor: 'stances', delayMs: 700),
      TutorialStep(t.lesStances5, anchor: 'dingbu', waitStance: Stance.xubu),
      TutorialStep(
        t.lesStances6,
        anchor: 'card:tan_tui+preview',
        waitCard: 'tan_tui',
        delayMs: 500,
      ),
      TutorialStep(
        t.lesStances7,
        illustration: Illustration.stances,
        delayMs: 700,
      ),
      TutorialStep(t.lesStances8),
    ],
  ),
  Lesson(
    id: 'structure',
    minutes: 3,
    title: (t) => t.lesStructureTitle,
    blurb: (t) => t.lesStructureBlurb,
    done: (t) => t.lesStructureDone,
    steps: (t) => [
      TutorialStep(t.lesStructure1, anchor: 'enemyInfo'),
      TutorialStep(
        t.lesStructure2,
        anchor: 'card:tui_zhang+preview',
        waitCard: 'tui_zhang',
      ),
      TutorialStep(
        t.lesStructure3,
        anchor: 'card:tui_zhang+preview',
        waitCard: 'tui_zhang',
        delayMs: 500,
      ),
      TutorialStep(
        t.lesStructure4,
        anchor: 'enemyInfo',
        delayMs: 1300,
        illustration: Illustration.broken,
      ),
      TutorialStep(
        t.lesStructure5,
        anchor: 'card:mabu_chongquan+preview',
        waitCard: 'mabu_chongquan',
      ),
      TutorialStep(t.lesStructure6, anchor: 'intent', delayMs: 700),
      TutorialStep(t.lesStructure7, anchor: 'player'),
      TutorialStep(t.lesStructure8, anchor: 'endTurn', waitTurn: 2),
      TutorialStep(t.lesStructure9, anchor: 'intent', delayMs: 1600),
      TutorialStep(t.lesStructure10),
    ],
  ),
  Lesson(
    id: 'forms',
    minutes: 4,
    title: (t) => t.lesFormsTitle,
    blurb: (t) => t.lesFormsBlurb,
    done: (t) => t.lesFormsDone,
    steps: (t) => [
      TutorialStep(
        t.lesForms1,
        anchor: 'forms',
        illustration: Illustration.forms,
      ),
      TutorialStep(
        t.lesForms2,
        anchor: 'card:gongbu_chongquan+preview',
        waitCard: 'gongbu_chongquan',
      ),
      TutorialStep(
        t.lesForms3,
        anchor: 'card:tan_tui+preview',
        waitCard: 'tan_tui',
        delayMs: 500,
      ),
      TutorialStep(t.lesForms4, anchor: 'forms', delayMs: 600),
      TutorialStep(
        t.lesForms5,
        anchor: 'card:tui_zhang',
        waitSelect: 'tui_zhang',
      ),
      TutorialStep(t.lesForms6, anchor: 'preview'),
      TutorialStep(t.lesForms7, anchor: 'endTurn', waitTurn: 2),
      TutorialStep(
        t.lesForms8,
        anchor: 'card:mabu_jiada+preview',
        waitCard: 'mabu_jiada',
        delayMs: 1800,
      ),
      TutorialStep(
        t.lesForms9,
        anchor: 'breathe',
        waitBreathe: true,
        delayMs: 500,
      ),
      TutorialStep(
        t.lesForms10,
        anchor: 'card:xubu_liangzhang+preview',
        waitCard: 'xubu_liangzhang',
        delayMs: 900,
      ),
      TutorialStep(t.lesForms11, anchor: 'enemyInfo', delayMs: 1600),
      TutorialStep(t.lesForms12),
    ],
  ),
  Lesson(
    id: 'climb',
    minutes: 2,
    title: (t) => t.lesClimbTitle,
    blurb: (t) => t.lesClimbBlurb,
  ),
];

Lesson lessonById(String id) => lessons.firstWhere((l) => l.id == id);

/// La lección que sigue a [id], si hay.
Lesson? nextLesson(String id) {
  final i = lessons.indexWhere((l) => l.id == id);
  return i + 1 < lessons.length ? lessons[i + 1] : null;
}
