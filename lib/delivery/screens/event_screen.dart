import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/event_def.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../content_text.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/paper_panel.dart';
import '../widgets/scroll_panel.dart';
import '../widgets/game_icon.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/scene_backdrop.dart';
import '../widgets/talisman_widgets.dart';
import '../widgets/hp_count.dart';
import '../widgets/press.dart';
import '../feel.dart';
import '../widgets/node_kit.dart';

/// Evento del mapa: una escena, dos opciones y lo que pasó.
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  /// El evento se guarda acá: al resolverlo la run vuelve al mapa.
  String? _eventId;
  EventResult? _result;
  int _burst = 0, _shake = 0, _flash = 0, _seal = 0;

  /// Adónde lleva el botón después de elegir: a pelear (duelo), a elegir
  /// (cartas o mejora) o de vuelta al mapa.
  RunPhase _next = RunPhase.map;

  @override
  void initState() {
    super.initState();
    // Un evento del camino, o la segunda parte de uno de más abajo, entra
    // con ceremonia: sello, golpe y sonido.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final id = ref.read(runControllerProvider)?.eventId;
      if (!mounted || id == null) return;
      final event = ref.read(dataProvider).event(id);
      if (event.path == null && event.after == null) return;
      Haptics.mediumImpact();
      ref.read(audioProvider).play(Sfx.shrineOath);
      setState(() => _seal++);
    });
  }

  void _choose(EventOptionDef o) {
    if (_result != null) return;
    final ctl = ref.read(runControllerProvider.notifier);
    ctl.resolveEvent(o.id);
    final run = ref.read(runControllerProvider)!;
    final r = run.lastEvent!;
    final audio = ref.read(audioProvider);
    _next = run.phase;
    if (_next == RunPhase.combat) {
      // El rival acepta: golpe seco, destello y la pantalla tiembla.
      Haptics.heavyImpact();
      audio.play(Sfx.fightStart);
      setState(() {
        _result = r;
        _shake++;
        _flash++;
      });
      return;
    }
    final good =
        _next == RunPhase.reward ||
        r.talisman != null ||
        r.form != null ||
        r.card != null ||
        r.upgraded != null ||
        r.maxHp > 0 ||
        r.jade > 0 ||
        r.tempered != null ||
        r.mark != null;
    if (good) {
      Haptics.heavyImpact();
      audio.play(Sfx.rewardTake);
    } else if (r.hp < 0) {
      Haptics.mediumImpact();
      audio.play(Sfx.playerHurt);
    } else if (r.hp > 0) {
      Haptics.lightImpact();
      audio.play(Sfx.fountainHeal);
    } else {
      Haptics.selectionClick();
      audio.play(Sfx.uiButton);
    }
    setState(() {
      _result = r;
      if (good) _burst++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    _eventId ??= run.eventId;
    final id = _eventId;
    if (id == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final text = ref.watch(textProvider);
    final event = data.event(id);
    final path = event.path;
    final back = event.after != null;
    final accent = path != null
        ? styleColor(path)
        : back
            ? Palette.gold
            : Palette.blossom;
    return Scaffold(
      // El alto en el camino (pabellón, té y faroles); si faltara, el paisaje
      // de la etapa.
      body: Stack(
        children: [
          Positioned.fill(
            child: Shake(
              trigger: _shake,
              strength: 10,
              child: SceneBackdrop(
        assets: [
          'assets/art/ui/event_bg.webp',
          ...stageArt(data.balance.stages[run.stage].id, 'map_bg.webp'),
        ],
        veil: 0.45,
        child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  HpCount(hp: run.hp, maxHp: run.maxHp),
                  const SizedBox(width: 12),
                  JadeCount(jade: run.jade, size: 20),
                  Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
                ],
              ),
              // La escena se centra en el lugar que queda; en pantallas
              // chicas se desliza y las opciones siguen a mano.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => ScrollPanel(
                    framed: false,
                    child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(minHeight: box.maxHeight),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
              Bounce(
                trigger: _seal,
                scale: 1.25,
                child: Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.surface,
                  border: Border.all(color: accent, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Text(
                  event.hanzi,
                  style: TextStyle(
                    fontSize: 46,
                    height: 1,
                    color: accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              ),
              const SizedBox(height: 14),
              // Una nube de papel: el paisaje se ve y el texto se lee.
              PaperPanel(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 16),
                radius: 20,
                opacity: 0.9,
                child: Column(
                  children: [
                    if (path != null || back) ...[
                      _PathTag(
                        label: path != null ? t.eventPath(path) : t.eventBack,
                        color: accent,
                      ),
                      const SizedBox(height: 8),
                    ],
                    Text(
                      text.event(id),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    // Al elegir, la escena se pliega y deja lugar a lo que pasó.
                    AnimatedSize(
                      duration: const Duration(milliseconds: 360),
                      curve: Curves.easeOutCubic,
                      child: _result != null
                          ? const SizedBox(width: double.infinity)
                          : Padding(
                              padding: const EdgeInsets.only(top: 10),
                              child: Text(
                                text.eventText(id),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                  height: 1.4,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
                        ],
                      ),
                    ),
                  ),
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.94, end: 1.0).animate(a),
                    child: child,
                  ),
                ),
                child: _result == null
                    ? Column(
                        key: const ValueKey('options'),
                        children: [
                          for (final (i, o)
                              in engine.eventOptions(run, event).indexed) ...[
                            StaggerIn(
                              index: i,
                              delay: const Duration(milliseconds: 250),
                              // Lo que se abre con lo que llevás cae como un
                              // sello, con su campanada.
                              scaleFrom: o.needs != null ? 1.12 : 1,
                              onShow: o.needs == null
                                  ? null
                                  : () {
                                      Haptics.lightImpact();
                                      ref
                                          .read(audioProvider)
                                          .play(Sfx.breathGain);
                                    },
                              child: ChoiceTile(
                                title: text.eventOption(id, o.id),
                                detail: o.duel != null
                                    ? t.eventDuel(text.enemy(o.duel!))
                                    : o.needs != null
                                        ? '${t.eventNeedWith(_needName(text, o.needs!.kind, engine.needMet(run, o)!))} · ${t.eventOptionSummary(o)}'
                                        : t.eventOptionSummary(o),
                                accent: o.duel != null
                                    ? Palette.lacquer
                                    : o.needs != null
                                        ? Palette.jade
                                        : o.chance != null
                                            ? Palette.gold
                                            : null,
                                trailing: o.duel != null
                                    ? Icons.sports_martial_arts
                                    : o.needs != null
                                        ? Icons.auto_awesome
                                        : o.chance != null
                                            ? Icons.casino_outlined
                                            : Icons.chevron_right_rounded,
                                enabled: engine.canChoose(run, o),
                                blocked: run.hp > o.cost
                                    ? t.merchantNoJade
                                    : t.eventCantPay,
                                onTap: () => _choose(o),
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      )
                    : Stack(
                        key: const ValueKey('result'),
                        clipBehavior: Clip.none,
                        children: [
                          _ResultCard(result: _result!, accent: accent),
                          Positioned.fill(
                            child: InkBurst(
                              trigger: _burst,
                              colors: const [
                                Palette.blossom,
                                Palette.gold,
                                Colors.white,
                              ],
                              count: 36,
                              radius: 170,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _result == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: _next == RunPhase.combat
                        ? FilledButton.styleFrom(
                            backgroundColor: Palette.lacquer,
                          )
                        : null,
                    onPressed: _result == null ? null : _leave,
                    child: Text(switch (_next) {
                      RunPhase.combat => t.eventDuelGo,
                      RunPhase.reward => t.eventChoose,
                      _ => t.eventContinue,
                    }),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      ),
            ),
          ),
          Positioned.fill(
            child: ScreenFlash(trigger: _flash, color: Palette.lacquer),
          ),
        ],
      ),
    );
  }

  String _needName(ContentText text, EventNeedKind kind, String id) =>
      switch (kind) {
        EventNeedKind.talisman => text.talisman(id),
        EventNeedKind.weapon => text.weapon(id),
        EventNeedKind.form => text.form(id),
      };

  void _leave() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    switch (_next) {
      case RunPhase.combat:
        ref.read(combatControllerProvider.notifier).start();
        context.go('/combat');
      case RunPhase.reward:
        context.go('/reward');
      default:
        context.go('/map');
    }
  }
}

/// Qué pasó: la escena, si salió bien o mal y lo que se ganó o perdió.
class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.result, required this.accent});

  final EventResult result;
  final Color accent;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final r = result;
    final failed = r.success == false;
    final chips = <Widget>[
      if (r.duel != null) _Rival(id: r.duel!),
      if (r.hp < 0) _chip(t.eventCost(-r.hp), Palette.lacquer, Icons.favorite),
      if (r.hp > 0) _chip(t.eventHeal(r.hp), Palette.jade, Icons.favorite),
      if (r.maxHp > 0)
        _chip(t.eventMaxHp(r.maxHp), Palette.jade, Icons.favorite_border),
      if (r.jade > 0) _PopIn(child: _jadeChip(t.eventJade(r.jade), Palette.jade)),
      if (r.jade < 0) _jadeChip(t.eventJadeSpent(-r.jade), Palette.gold),
      if (r.talisman != null)
        _PopIn(
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Palette.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TalismanTile(id: r.talisman!, badgeSize: 40),
                const SizedBox(height: 6),
                Text(
                  t.talismanTapHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 12, color: Palette.textDim),
                ),
              ],
            ),
          ),
        ),
      if (r.form != null)
        _chip(
          t.eventResultForm(text.form(r.form!)),
          Palette.lacquer,
          Icons.auto_awesome,
        ),
      if (r.card != null)
        _chip(t.eventResultCard(text.card(r.card!)), Palette.gold, Icons.style),
      if (r.upgraded != null)
        _chip(
          t.eventResultUpgrade(text.card(r.upgraded!)),
          Palette.gold,
          Icons.arrow_upward,
        ),
      if (r.lost != null)
        _chip(
          t.eventResultLost(text.card(r.lost!)),
          Palette.textDim,
          Icons.remove_circle_outline,
        ),
      if (r.tempered != null)
        _PopIn(
          child: _chip(
            t.eventResultTemper(
              text.weapon(r.tempered!),
              ref.watch(runControllerProvider)?.weaponLevel ?? 1,
            ),
            Palette.gold,
            Icons.hardware_rounded,
          ),
        ),
      if (r.mark != null)
        _PopIn(
          child: _chip(t.eventResultMark, Palette.gold, Icons.north_rounded),
        ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: failed || r.duel != null ? Palette.lacquer : accent,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (r.success != null) ...[
            _PopIn(
              child: Text(
                r.success! ? t.eventLucky : t.eventUnlucky,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: r.success! ? Palette.jade : Palette.lacquer,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            text.eventResult(r.eventId, r.optionId, failed: failed),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.35),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  Widget _jadeChip(String label, Color color) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const JadeCoin(size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );

  Widget _chip(String label, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameIcon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            label,
            style: TextStyle(fontWeight: FontWeight.w700, color: color),
          ),
        ),
      ],
    ),
  );
}

/// Aparece creciendo con un rebote (los avisos del resultado).
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.4, end: 1),
    duration: const Duration(milliseconds: 520),
    curve: Curves.elasticOut,
    builder: (_, v, child) => Transform.scale(scale: v, child: child),
    child: child,
  );
}

/// Cartel de un evento de camino («Prueba del Tigre»).
class _PathTag extends StatelessWidget {
  const _PathTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: color.withValues(alpha: 0.5)),
    ),
    child: Text(
      label.toUpperCase(),
      style: TextStyle(
        fontSize: 12,
        letterSpacing: 1.6,
        fontWeight: FontWeight.w800,
        color: color,
      ),
    ),
  );
}

/// El rival que aceptó el duelo, con su nombre.
class _Rival extends ConsumerWidget {
  const _Rival({required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = ref.watch(dataProvider).enemy(id);
    final name = ref.watch(textProvider).enemy(id);
    return _PopIn(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 76,
            height: 76,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Palette.bg,
              border: Border.all(color: Palette.lacquer, width: 3),
            ),
            child: Image.asset(
              'assets/art/enemies/${def.art}.webp',
              cacheWidth: 228,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Icon(
                Icons.sports_martial_arts,
                size: 40,
                color: Palette.lacquer,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
            name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Palette.lacquer,
            ),
          ),
          ),
        ],
      ),
    );
  }
}
