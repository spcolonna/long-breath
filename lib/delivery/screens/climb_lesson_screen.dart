import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/juice.dart';

/// Última lección: cómo es la subida, en diapositivas ilustradas con las
/// mismas piezas del juego (íconos del mapa, cartas, el héroe).
class ClimbLessonScreen extends ConsumerStatefulWidget {
  const ClimbLessonScreen({super.key});

  @override
  ConsumerState<ClimbLessonScreen> createState() => _ClimbLessonScreenState();
}

class _ClimbLessonScreenState extends ConsumerState<ClimbLessonScreen> {
  final _pages = PageController();
  int _page = 0;
  static const _count = 6;

  @override
  void dispose() {
    _pages.dispose();
    super.dispose();
  }

  void _onPage(int i) {
    setState(() => _page = i);
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.rewardFlip);
    if (i == _count - 1) {
      ref.read(tutorialStorageProvider).markDone('climb').then((_) {
        if (mounted) ref.invalidate(lessonsDoneProvider);
      });
    }
  }

  void _next() {
    _pages.nextPage(
      duration: const Duration(milliseconds: 380),
      curve: Curves.easeOutCubic,
    );
  }

  void _climb() {
    HapticFeedback.mediumImpact();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(runControllerProvider.notifier).newRun();
    context.go('/map');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final titles = [
      t.lesClimbSlide1Title,
      t.lesClimbSlide2Title,
      t.lesClimbSlide3Title,
      t.lesClimbSlide4Title,
      t.lesClimbSlide5Title,
      t.lesClimbSlide6Title,
    ];
    final bodies = [
      t.lesClimbSlide1,
      t.lesClimbSlide2,
      t.lesClimbSlide3,
      t.lesClimbSlide4,
      t.lesClimbSlide5,
      t.lesClimbSlide6,
    ];
    final visuals = const [
      _MapPath(),
      _NodeLegend(),
      _RewardFan(),
      _LifeVisual(),
      _Paths(),
      _Summit(),
    ];
    final last = _page == _count - 1;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          tooltip: t.lessonBackToList,
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/lessons'),
        ),
        title: Text(t.lesClimbTitle),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pages,
                itemCount: _count,
                onPageChanged: _onPage,
                itemBuilder: (_, i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      Expanded(child: Center(child: visuals[i])),
                      Text(
                        titles[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Palette.lacquer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bodies[i],
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 15, height: 1.4),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < _count; i++)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    margin: const EdgeInsets.all(3),
                    width: i == _page ? 18 : 7,
                    height: 7,
                    decoration: BoxDecoration(
                      color: i == _page ? Palette.lacquer : Palette.line,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 14, 24, 16),
              child: SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: last ? _climb : _next,
                  child: Text(
                    last ? t.tutClimb : t.tutNext,
                    style: const TextStyle(fontSize: 17),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _node(IconData icon, Color color, {double size = 50}) => Container(
  width: size,
  height: size,
  decoration: BoxDecoration(
    color: Palette.surface,
    shape: BoxShape.circle,
    border: Border.all(color: color, width: 2.5),
  ),
  child: Icon(icon, color: color, size: size * 0.5),
);

class _MapPath extends StatelessWidget {
  const _MapPath();

  @override
  Widget build(BuildContext context) {
    final nodes = [
      (Icons.military_tech, Palette.lacquer),
      (Icons.whatshot, Palette.structure),
      (Icons.water_drop, Palette.sky),
      (Icons.sports_martial_arts, Palette.jade),
      (Icons.temple_buddhist, Palette.gold),
      (Icons.sports_martial_arts, Palette.jade),
    ];
    return FittedBox(
      child: Column(
        children: [
          for (final (i, (icon, color)) in nodes.indexed) ...[
            if (i > 0) Container(width: 2, height: 18, color: Palette.line),
            if (i == 3)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _node(icon, color, size: 44),
                  const SizedBox(width: 40),
                  _node(icon, color, size: 44),
                ],
              )
            else
              _node(icon, color, size: 44),
          ],
        ],
      ),
    );
  }
}

class _NodeLegend extends StatelessWidget {
  const _NodeLegend();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final rows = [
      (Icons.sports_martial_arts, Palette.jade, t.nodeCombat),
      (Icons.whatshot, Palette.structure, t.rankElite),
      (Icons.military_tech, Palette.lacquer, t.rankBoss),
      (Icons.water_drop, Palette.sky, t.fountainNode),
      (Icons.temple_buddhist, Palette.gold, t.shrineNode),
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 18,
      runSpacing: 14,
      children: [
        for (final (icon, color, label) in rows)
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _node(icon, color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _RewardFan extends ConsumerWidget {
  const _RewardFan();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final data = ref.watch(dataProvider);
    final ids = ['deng_tui', 'shang_jia', 'pi_quan'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        for (final (i, id) in ids.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Transform.translate(
              offset: Offset(0, i == 1 ? -18 : 0),
              child: Opacity(
                opacity: i == 1 ? 1 : 0.6,
                child: CardWidget(
                  def: data.card(id),
                  width: 92,
                  selected: i == 1,
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _LifeVisual extends StatelessWidget {
  const _LifeVisual();

  @override
  Widget build(BuildContext context) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Icon(Icons.favorite_rounded, size: 84, color: Palette.jade),
      const SizedBox(width: 12),
      const Icon(Icons.arrow_forward_rounded, size: 28, color: Palette.textDim),
      const SizedBox(width: 12),
      Bounce(trigger: 1, child: _node(Icons.water_drop, Palette.sky, size: 84)),
    ],
  );
}

class _Paths extends ConsumerWidget {
  const _Paths();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = ref.watch(textProvider);
    return LayoutBuilder(
      builder: (_, box) {
        final h = (box.maxHeight - 24).clamp(80.0, 220.0);
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (final s in Style.values)
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    HeroSprite(style: s, height: h),
                    Text(
                      text.style(s),
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: styleColor(s),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _Summit extends ConsumerWidget {
  const _Summit();

  @override
  Widget build(BuildContext context, WidgetRef ref) => LayoutBuilder(
    builder: (_, box) => HeroSprite(
      style: null,
      height: box.maxHeight.clamp(100.0, 320.0),
      victory: true,
      glyph: ref.watch(dataProvider).balance.novice.hanzi,
    ),
  );
}
