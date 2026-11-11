import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/model/game_balance.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/confirm_dialog.dart';
import '../widgets/cinematic.dart';
import '../widgets/deck_sheet.dart';
import '../labels.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/jade.dart';
import '../widgets/lotus.dart';
import '../widgets/paper_panel.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/ink_reveal.dart';
import '../widgets/juice.dart';
import '../widgets/talisman_widgets.dart';
import '../widgets/weapon_widgets.dart';
import '../widgets/hp_count.dart';
import '../widgets/altitude_bar.dart';
import 'map/map_node.dart';
import '../feel.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Idempotente: si ya suena, sigue sin cortarse.
    ref.read(audioProvider).music(Music.menu);
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final available = engine.available(run).toSet();
    final stage = data.balance.stages[run.stage];
    // Al pisar una etapa nueva, su presentación (una sola vez por subida).
    final intro =
        ref.watch(cinematicsProvider) &&
        run.introShown < run.stage &&
        run.visited.isEmpty &&
        run.phase == RunPhase.map;

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              '${ref.watch(textProvider).stage(data.balance.stages[run.stage].id)} · ${data.balance.stages[run.stage].hanzi}',
              style: const TextStyle(fontSize: 18),
            ),
            Text.rich(
              TextSpan(
                children: [
                  if (data.balance.stages.length > 1)
                    TextSpan(
                      text:
                          '${t.mapStage(run.stage + 1, data.balance.stages.length)} · ',
                      style: const TextStyle(color: Palette.textDim),
                    ),
                  TextSpan(
                    text: run.pico > 0
                        ? '${t.difficultyName(run.difficulty)} · ${t.picoName(run.pico)}'
                        : t.difficultyName(run.difficulty),
                  ),
                ],
              ),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: run.pico > 0
                    ? picoColor
                    : difficultyColor(run.difficulty),
              ),
            ),
          ],
        ),
        // Volver al menú no borra nada: la subida queda guardada.
        leading: IconButton(
          tooltip: t.mapHome,
          icon: const Icon(Icons.home_rounded),
          onPressed: () {
            ref.invalidate(savedRunProvider);
            context.go('/school');
          },
        ),
        actions: [
          PopupMenuButton<String>(
            tooltip: t.mapMore,
            icon: const Icon(Icons.more_vert_rounded),
            onSelected: (_) => _confirmAbandon(context, ref),
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 'abandon',
                child: Row(
                  children: [
                    const Icon(
                      Icons.flag_rounded,
                      color: Palette.lacquer,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Text(t.abandon),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      // La montaña llega hasta el borde de abajo.
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _RunHeader(run: run, altitude: engine.altitudeOf(run)),
            Expanded(
              child: _PathView(run: run, available: available),
            ),
          ],
        ),
      ),
    );
    if (!intro) return scaffold;
    return Stack(
      children: [
        scaffold,
        Positioned.fill(
          child: CinematicGate(
            id: 'stage_${stage.id}',
            builder: (full) => StageIntro(
              stageId: stage.id,
              hanzi: stage.hanzi,
              name: ref.watch(textProvider).stage(stage.id),
              subtitle: data.balance.stages.length > 1
                  ? t.mapStage(run.stage + 1, data.balance.stages.length)
                  : t.difficultyName(run.difficulty),
              style: run.style,
              full: full,
              onDone: () =>
                  ref.read(runControllerProvider.notifier).introSeen(),
            ),
          ),
        ),
      ],
    );
  }
}

/// El sendero: la ladera de la etapa sube a medida que se pisan salas; a
/// la izquierda la altitud, arriba las puertas que siguen (cada pelea con
/// su premio a la vista) y abajo el discípulo, que trepa hasta la elegida.
class _PathView extends ConsumerStatefulWidget {
  const _PathView({required this.run, required this.available});

  final RunState run;
  final Set<String> available;

  @override
  ConsumerState<_PathView> createState() => _PathViewState();
}

class _PathViewState extends ConsumerState<_PathView>
    with TickerProviderStateMixin {
  final _content = GlobalKey();
  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  );
  late final _walk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  MapNodeDef? _going;

  /// Puerta que se está mirando antes de ir (tocarla de nuevo, o «Ir», va).
  String? _picked;
  int _burst = 0;
  Offset _target = Offset.zero;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loopUnlessCalm(context, _breath);
  }

  @override
  void dispose() {
    _breath.dispose();
    _walk.dispose();
    super.dispose();
  }

  void _tapDoor(MapNodeDef n) {
    if (_going != null) return;
    if (_picked == n.id) {
      _go(n);
      return;
    }
    Haptics.tap();
    setState(() => _picked = n.id);
  }

  Future<void> _go(MapNodeDef n) async {
    if (_going != null) return;
    final data = ref.read(dataProvider);
    ref.read(audioProvider).play(Sfx.mapNode);
    Haptics.mediumImpact();
    // Tomar el desvío: un segundo golpe, como quien acepta el reto.
    if (isOptionalElite(n, widget.run.map, data)) {
      Future.delayed(const Duration(milliseconds: 110), Haptics.heavyImpact);
    }
    setState(() => _going = n);
    await _walk.forward(from: 0);
    if (!mounted) return;
    final rank = n.type == NodeType.combat ? data.enemy(n.enemy!).rank : null;
    rank == EnemyRank.elite || rank == EnemyRank.boss
        ? Haptics.heavyImpact()
        : Haptics.lightImpact();
    setState(() => _burst++);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    final box = _content.currentContext?.findRenderObject() as RenderBox?;
    _enter(
      context,
      ref,
      n,
      box == null
          ? null
          : InkFrom(box.localToGlobal(_target), nodeLook(n, data).color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final t = AppLocalizations.of(context);
    final stage = data.balance.stages[run.stage];
    final depths = engine.depthsOf(run);
    final climbed = engine.climbed(run);
    final doors = [
      for (final n in run.map)
        if (widget.available.contains(n.id)) n,
    ];
    // Hitos de la etapa: el guardián, la fuente y el jefe.
    final milestones = <int, String>{
      for (var d = 0; d < stage.floors.length; d++)
        if (stage.floors[d].maxWidth == 1 &&
            stage.floors[d].types.length == 1)
          d: switch (stage.floors[d].types.keys.single) {
            NodeType.fountain => '泉',
            NodeType.shrine => '庙',
            NodeType.combat when d == stage.floors.length - 1 => '龙',
            NodeType.combat => '精',
            _ => '·',
          },
    };
    return LayoutBuilder(
      builder: (context, box) {
        final w = box.maxWidth;
        final h = box.maxHeight;
        const left = 58.0;
        final area = w - left - 8;
        final slot = doors.isEmpty ? area : area / doors.length;
        final doorsTop = math.max(64.0, h * 0.2);
        Offset doorCenter(int i) {
          final arc = doors.length == 3 && i == 1 ? -34.0 : 0.0;
          return Offset(left + slot * (i + 0.5), doorsTop + arc + 40);
        }

        final feet = Offset(left + area / 2, h - 118);
        final going = _going == null ? -1 : doors.indexOf(_going!);
        if (going >= 0) _target = doorCenter(going);
        final p = depths <= 0 ? 0.0 : climbed / depths;
        final from = depths <= 0
            ? 0.0
            : (climbed - 1).clamp(0, depths) / depths;
        return ClipRect(
          key: _content,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              // La ladera pintada de la etapa: se corre hacia arriba con
              // cada sala, como quien levanta la vista al subir.
              Positioned.fill(
                child: TweenAnimationBuilder<double>(
                  tween: Tween(begin: calm(context) ? p : from, end: p),
                  duration: const Duration(milliseconds: 1400),
                  curve: Curves.easeInOutCubic,
                  builder: (_, v, _) => Image.asset(
                    'assets/art/stages/${stage.id}/map_bg.webp',
                    fit: BoxFit.cover,
                    alignment: Alignment(0, 1 - 2 * v),
                    cacheWidth: 900,
                    errorBuilder: (_, _, _) => const ColoredBox(
                      color: Palette.bgAlt,
                    ),
                  ),
                ),
              ),
              // Papel arriba: las puertas se leen sobre cualquier fondo.
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                height: doorsTop + 150,
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Palette.bg.withValues(alpha: 0.85),
                          Palette.bg.withValues(alpha: 0),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 10,
                top: 10,
                bottom: 112 + MediaQuery.paddingOf(context).bottom,
                width: 40,
                child: AltitudeBar(
                  depths: depths,
                  climbed: climbed,
                  altitude: engine.altitudeOf(run),
                  summit: stage.altitude.$2,
                  milestones: milestones,
                  style: run.style,
                ),
              ),
              Positioned(
                top: 8,
                left: left,
                right: 8,
                child: Text(
                  t.pathTitle(math.min(climbed + 1, depths), depths),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: Palette.text,
                  ),
                ),
              ),
              for (var i = 0; i < doors.length; i++)
                Positioned(
                  left: doorCenter(i).dx - slot / 2,
                  top: doorCenter(i).dy - 40,
                  width: slot,
                  child: _Arrive(
                    key: ValueKey('arrive${doors[i].id}'),
                    index: i,
                    child: AnimatedOpacity(
                      opacity: _going == null || _going == doors[i] ? 1 : 0.35,
                      duration: const Duration(milliseconds: 260),
                      child: _Door(
                        node: doors[i],
                        available: _going == null,
                        selected: _picked == doors[i].id,
                        optional: isOptionalElite(doors[i], run.map, data),
                        onTap: () => _tapDoor(doors[i]),
                      ),
                    ),
                  ),
                ),
              _climber(run, feet),
              if (going >= 0)
                Positioned(
                  left: _target.dx - 120,
                  top: _target.dy - 120,
                  width: 240,
                  height: 240,
                  child: IgnorePointer(
                    child: InkBurst(
                      trigger: _burst,
                      colors: [nodeLook(_going!, data).color, Palette.gold],
                      radius: 90,
                    ),
                  ),
                ),
              Positioned(
                left: 16,
                right: 16,
                bottom: 16 + MediaQuery.paddingOf(context).bottom,
                child: _PickCard(
                  node: _going != null || _picked == null
                      ? null
                      : run.node(_picked!),
                  hidden: _going != null,
                  optional:
                      _picked != null &&
                      isOptionalElite(run.node(_picked!), run.map, data),
                  onGo: () => _go(run.node(_picked!)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// El discípulo (de espaldas, con la ropa de su camino) al pie de las
  /// puertas; al elegir una, trepa hasta ella y se achica en la distancia.
  Widget _climber(RunState run, Offset feet) {
    const h = 96.0;
    return AnimatedBuilder(
      animation: Listenable.merge([_walk, _breath]),
      builder: (_, child) {
        var at = feet;
        var scale = 1.0;
        var lift = math.sin(_breath.value * 2 * math.pi) * 1.5;
        if (_going != null) {
          final t = Curves.easeInOut.transform(_walk.value);
          at = Offset.lerp(feet, _target + const Offset(0, 30), t)!;
          scale = 1 - 0.55 * t;
          lift = (math.sin(_walk.value * math.pi * 6)).abs() * 6;
        }
        return Positioned(
          left: at.dx - h / 2,
          top: at.dy - h - lift,
          width: h,
          height: h,
          child: Transform.scale(
            scale: scale,
            alignment: Alignment.bottomCenter,
            child: child,
          ),
        );
      },
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: -4,
              child: Container(
                width: 46,
                height: 10,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color(0x33806A45),
                ),
              ),
            ),
            Image.asset(
              heroAsset(run.style),
              height: h,
              errorBuilder: (_, _, _) =>
                  const Icon(Icons.person_rounded, color: Palette.text),
            ),
          ],
        ),
      ),
    );
  }
}

/// Una puerta del sendero: el sello del lugar y, si es pelea, el premio
/// que espera del otro lado.
class _Door extends ConsumerWidget {
  const _Door({
    required this.node,
    required this.available,
    required this.selected,
    required this.optional,
    required this.onTap,
  });

  final MapNodeDef node;
  final bool available;
  final bool selected;
  final bool optional;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final rank = node.type == NodeType.combat
        ? data.enemy(node.enemy!).rank
        : null;
    final reward =
        node.reward ?? (rank == EnemyRank.elite ? RewardKind.talisman : null);
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          MapNode(
            node: node,
            visited: false,
            available: available,
            selected: selected,
            optional: optional,
            onTap: onTap,
          ),
          if (reward != null) ...[
            const SizedBox(height: 2),
            GestureDetector(
              onTap: available ? onTap : null,
              child: _RewardBadge(kind: reward, label: t.lootKind(reward)),
            ),
          ],
        ],
      ),
    );
  }
}

/// El premio de una puerta: su sello y su nombre.
class _RewardBadge extends StatelessWidget {
  const _RewardBadge({required this.kind, required this.label});

  final RewardKind kind;
  final String label;

  @override
  Widget build(BuildContext context) {
    final (hanzi, color) = lootLook(kind);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 3, 10, 3),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.7), width: 1.5),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkSeal(hanzi: hanzi, color: color, size: 22),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

void _enter(BuildContext context, WidgetRef ref, MapNodeDef n, InkFrom? ink) {
  ref.read(runControllerProvider.notifier).enter(n.id);
  if (n.type == NodeType.combat) {
    ref.read(combatControllerProvider.notifier).start();
  }
  final route = switch (n.type) {
    NodeType.combat => '/combat',
    NodeType.fountain => '/fountain',
    NodeType.shrine => '/shrine',
    NodeType.event => '/event',
    NodeType.merchant => '/merchant',
    NodeType.master => '/master',
  };
  context.go(route, extra: ink);
}

Future<void> _confirmAbandon(BuildContext context, WidgetRef ref) async {
  final t = AppLocalizations.of(context);
  final ok = await confirmDialog(
    context,
    title: t.abandonConfirmTitle,
    body: t.abandonConfirmBody,
    ok: t.abandon,
    seal: '退',
  );
  if (!ok || !context.mounted) return;
  ref.read(runControllerProvider.notifier).abandon();
  ref.invalidate(savedRunProvider);
  context.go('/school');
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({required this.run, required this.altitude});

  final RunState run;

  /// Metros a los que está el discípulo.
  final int altitude;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Una franja de papel apoyada sobre la montaña.
    return Container(
      margin: const EdgeInsets.fromLTRB(10, 2, 10, 6),
      padding: const EdgeInsets.fromLTRB(10, 4, 8, 4),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.line),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1F806A45),
            offset: Offset(0, 2),
            blurRadius: 6,
          ),
        ],
      ),
      child: Row(
        children: [
          HpCount(hp: run.hp, maxHp: run.maxHp),
          const SizedBox(width: 8),
          JadeCount(jade: run.jade),
          if (run.lotus > 0) ...[
            const SizedBox(width: 6),
            LotusCount(lotus: run.lotus),
          ],
          // Solo el número: el ícono ya dice "mazo" y deja lugar a la altura.
          Tooltip(
            message: t.deckCount(run.deck.length),
            child: TextButton.icon(
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                visualDensity: VisualDensity.compact,
              ),
              onPressed: () => showDeckSheet(context, run.deck),
              icon: const Icon(Icons.style, size: 18),
              label: Text('${run.deck.length}'),
            ),
          ),
          // El arma y los talismanes de la subida; tocarlos explica qué hacen.
          WeaponChip(id: run.weapon, level: run.weaponLevel, style: run.style),
          Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
          Text(
            meters(altitude),
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Palette.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

/// Un lugar que se acaba de abrir sube desde la niebla: se agranda y
/// aparece, uno tras otro. Lo ya visto aparece quieto.
class _Arrive extends StatelessWidget {
  const _Arrive({super.key, required this.index, required this.child});

  /// Orden entre las opciones de ahora; -1 si no es una opción.
  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    if (index < 0 || calm(context)) return child;
    final start = 0.3 + 0.12 * index;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1300),
      curve: Interval(math.min(start, 0.7), 1, curve: Curves.easeOutBack),
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.6 + 0.4 * v, child: child),
      ),
      child: child,
    );
  }
}

/// Tarjeta de abajo: qué es el lugar elegido y el botón para ir. Sin
/// elección, una pista corta.
class _PickCard extends ConsumerWidget {
  const _PickCard({
    required this.node,
    required this.hidden,
    required this.optional,
    required this.onGo,
  });

  final MapNodeDef? node;
  final bool hidden;
  final bool optional;
  final VoidCallback onGo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final n = node;
    final Widget body;
    if (n == null) {
      body = Center(
        key: const ValueKey('hint'),
        child: PaperPanel(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          radius: 22,
          child: Text(
            t.mapPickHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Palette.text,
            ),
          ),
        ),
      );
    } else {
      final data = ref.watch(dataProvider);
      final look = nodeLook(n, data);
      final label = nodeLabel(n, t, ref.watch(textProvider).path);
      final rank = n.type == NodeType.combat ? data.enemy(n.enemy!).rank : null;
      final hint = switch (n.type) {
        NodeType.combat => switch (rank!) {
          EnemyRank.common => t.nodeHintCommon,
          EnemyRank.elite => optional ? t.nodeHintDetour : t.nodeHintElite,
          EnemyRank.boss => t.nodeHintBoss,
        },
        NodeType.fountain => t.nodeHintFountain,
        NodeType.shrine => t.nodeHintShrine,
        NodeType.event => t.nodeHintEvent,
        NodeType.merchant => t.nodeHintMerchant,
        NodeType.master => t.nodeHintMaster,
      };
      // El grupo, si viene más de uno, y el premio del otro lado.
      final pack = n.waves.isEmpty
          ? ''
          : ' ${t.nodeHintPack(1 + n.waves.length)}';
      final reward = n.reward == null
          ? ''
          : ' ${t.pathReward(t.lootKind(n.reward!))}';
      body = PaperPanel(
        key: ValueKey(n.id),
        accent: look.color,
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: look.color.withValues(alpha: 0.14),
                border: Border.all(color: look.color, width: 2),
              ),
              child: Text(
                look.hanzi,
                style: TextStyle(
                  fontSize: 26,
                  height: 1,
                  color: look.color,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Palette.text,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '$hint$pack$reward',
                    style: const TextStyle(
                      fontSize: 14,
                      height: 1.25,
                      color: Palette.text,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            FilledButton(
              onPressed: onGo,
              style: FilledButton.styleFrom(
                backgroundColor: look.color,
                foregroundColor: Palette.surface,
                minimumSize: const Size(64, 48),
                padding: const EdgeInsets.symmetric(horizontal: 18),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: Text(t.mapGo),
            ),
          ],
        ),
      );
    }
    return IgnorePointer(
      ignoring: hidden,
      child: AnimatedOpacity(
        opacity: hidden ? 0 : 1,
        duration: const Duration(milliseconds: 220),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 260),
          switchInCurve: Curves.easeOutCubic,
          transitionBuilder: (child, a) => FadeTransition(
            opacity: a,
            child: SlideTransition(
              position: Tween(
                begin: const Offset(0, 0.25),
                end: Offset.zero,
              ).animate(a),
              child: child,
            ),
          ),
          child: body,
        ),
      ),
    );
  }
}
