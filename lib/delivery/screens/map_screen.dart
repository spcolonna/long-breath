import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/game_balance.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/deck_sheet.dart';
import '../labels.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/jade.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/ink_reveal.dart';
import '../widgets/juice.dart';
import '../widgets/talisman_widgets.dart';
import 'map/map_layout.dart';
import 'map/map_node.dart';
import 'map/mountain_backdrop.dart';
import 'map/trail_painter.dart';

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

    return Scaffold(
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
            context.go('/');
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
            _RunHeader(
              run: run,
              floor:
                  mapRows(run).indexWhere(
                    (row) => row.any((n) => n.id == run.currentNode),
                  ) +
                  1,
              floors: mapRows(run).length,
            ),
            Expanded(
              child: _MapView(run: run, available: available),
            ),
          ],
        ),
      ),
    );
  }
}

/// El mapa se recorre de abajo hacia arriba: una montaña en capas, un
/// sendero de escalones y el discípulo que camina de un lugar al otro.
class _MapView extends ConsumerStatefulWidget {
  const _MapView({required this.run, required this.available});

  final RunState run;
  final Set<String> available;

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView>
    with TickerProviderStateMixin {
  ScrollController? _scroll;
  final _content = GlobalKey();
  late final _breath = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();
  late final _drift = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 50),
  )..repeat();
  late final _reveal = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 750),
  );
  late final _walk = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  );
  MapLayout? _layout;
  (Size, List<MapNodeDef>)? _laidFor;
  MapNodeDef? _going;
  Path? _route;
  int _burst = 0;

  @override
  void initState() {
    super.initState();
    // El último tramo se pinta de a poco al volver al mapa.
    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _reveal.forward();
    });
  }

  @override
  void dispose() {
    _scroll?.dispose();
    _breath.dispose();
    _drift.dispose();
    _reveal.dispose();
    _walk.dispose();
    super.dispose();
  }

  Offset get _here {
    return _layout!.pos[widget.run.currentNode] ?? _layout!.foot;
  }

  /// Desplazamiento que deja la altura [y] en la fracción [frac] de la
  /// pantalla (0 arriba, 1 abajo).
  double _offsetFor(double y, double view, double frac) {
    final h = _layout!.size.height;
    return (h - view - (y - frac * view)).clamp(0.0, math.max(0.0, h - view));
  }

  double? _nextY() {
    final ys = [for (final id in widget.available) _layout!.pos[id]!.dy];
    return ys.isEmpty ? null : ys.reduce(math.max);
  }

  Future<void> _go(MapNodeDef n) async {
    if (_going != null) return;
    final layout = _layout!;
    final from = _here;
    final to = layout.pos[n.id]!;
    ref.read(audioProvider).play(Sfx.mapNode);
    HapticFeedback.mediumImpact();
    setState(() {
      _going = n;
      final cur = widget.run.currentNode;
      _route = trailPath(
        from,
        to,
        cur == null ? 'foot${n.id}' : '$cur>${n.id}',
      );
    });
    final view = _scroll!.position.viewportDimension;
    _scroll!.animateTo(
      _offsetFor(to.dy, view, 0.5),
      duration: _walk.duration!,
      curve: Curves.easeInOutCubic,
    );
    await _walk.forward(from: 0);
    if (!mounted) return;
    HapticFeedback.lightImpact();
    setState(() => _burst++);
    await Future.delayed(const Duration(milliseconds: 160));
    if (!mounted) return;
    final box = _content.currentContext?.findRenderObject() as RenderBox?;
    final color = nodeLook(n, ref.read(dataProvider)).color;
    _enter(
      context,
      ref,
      n,
      box == null ? null : InkFrom(box.localToGlobal(to), color),
    );
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final data = ref.watch(dataProvider);
    return LayoutBuilder(
      builder: (context, box) {
        final view = box.biggest;
        if (_laidFor?.$1 != view || !identical(_laidFor?.$2, run.map)) {
          _layout = layoutMap(run, data, view);
          _laidFor = (view, run.map);
        }
        final layout = _layout!;
        final size = layout.size;
        if (_scroll == null) {
          // Arranca donde quedó el discípulo y la cámara sube sola hasta el
          // piso siguiente.
          _scroll = ScrollController(
            initialScrollOffset: _offsetFor(_here.dy, view.height, 0.6),
          );
          final next = _nextY();
          if (next != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted || !_scroll!.hasClients) return;
              _scroll!.animateTo(
                _offsetFor(next, view.height, 0.42),
                duration: const Duration(milliseconds: 1100),
                curve: Curves.easeInOutCubic,
              );
            });
          }
        }
        final scroll = _scroll!;
        final current = layout.rowOf[run.currentNode] ?? -1;
        double fogAt(int row) => row + 3 < layout.rowY.length
            ? (layout.rowY[row + 2] + layout.rowY[row + 3]) / 2
            : 0;
        final prevRow = run.visited.length >= 2
            ? layout.rowOf[run.visited[run.visited.length - 2]] ?? current
            : current - 1;
        return ClipRect(
          child: Stack(
            children: [
              // Cielo y cordilleras: quietos en pantalla, se corren despacio.
              Positioned.fill(
                child: RepaintBoundary(
                  child: AnimatedBuilder(
                    animation: scroll,
                    builder: (_, _) => CustomPaint(
                      painter: SkyPainter(
                        scroll: scroll.hasClients
                            ? scroll.offset
                            : scroll.initialScrollOffset,
                        maxScroll: size.height - view.height,
                        tint: MountainTint.of(widget.run.stage),
                      ),
                    ),
                  ),
                ),
              ),
              SingleChildScrollView(
                controller: scroll,
                reverse: true,
                child: SizedBox.fromSize(
                  key: _content,
                  size: size,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // El fondo pintado de la etapa ya trae sus hitos; si
                      // falta, se dibujan por código.
                      Positioned.fill(
                        child: Image.asset(
                          'assets/art/stages/${data.balance.stages[run.stage].id}/map_bg.png',
                          fit: BoxFit.cover,
                          opacity: const AlwaysStoppedAnimation(0.85),
                          errorBuilder: (_, _, _) => RepaintBoundary(
                            child: CustomPaint(
                              painter: LandmarkPainter(
                                layout,
                                stage: widget.run.stage,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: RepaintBoundary(
                          child: CustomPaint(
                            painter: TrailPainter(
                              layout: layout,
                              run: run,
                              available: widget.available,
                              breath: _breath,
                              reveal: _reveal,
                            ),
                          ),
                        ),
                      ),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: RepaintBoundary(
                            child: CustomPaint(
                              painter: CloudPainter(
                                layout: layout,
                                drift: _drift,
                              ),
                            ),
                          ),
                        ),
                      ),
                      for (final n in run.map)
                        Positioned(
                          left: layout.pos[n.id]!.dx - sealCenter.dx,
                          top: layout.pos[n.id]!.dy - sealCenter.dy,
                          child: MapNode(
                            node: n,
                            visited: run.visited.contains(n.id),
                            available:
                                _going == null &&
                                widget.available.contains(n.id),
                            onTap: () => _go(n),
                          ),
                        ),
                      // La niebla se despeja hasta dos pisos por encima.
                      Positioned.fill(
                        child: IgnorePointer(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: fogAt(prevRow),
                              end: fogAt(current),
                            ),
                            duration: const Duration(milliseconds: 1400),
                            curve: Curves.easeOutCubic,
                            builder: (_, edge, _) =>
                                CustomPaint(painter: FogPainter(edge)),
                          ),
                        ),
                      ),
                      _walker(run),
                      if (_going != null)
                        Positioned(
                          left: layout.pos[_going!.id]!.dx - 120,
                          top: layout.pos[_going!.id]!.dy - 120,
                          width: 240,
                          height: 240,
                          child: InkBurst(
                            trigger: _burst,
                            colors: [
                              nodeLook(_going!, data).color,
                              Palette.gold,
                            ],
                            radius: 90,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// El discípulo (de espaldas, con la ropa de su camino) parado donde
  /// quedó; al elegir un lugar camina el sendero hasta él.
  Widget _walker(RunState run) {
    const h = 50.0;
    return AnimatedBuilder(
      animation: Listenable.merge([_walk, _breath]),
      builder: (_, child) {
        // Quieto, espera al costado de su sello (no lo tapa).
        final aside = widget.run.currentNode == null
            ? const Offset(0, 4)
            : const Offset(-40, 22);
        var feet = _here + aside;
        var lift = 0.0;
        if (_route != null) {
          final m = _route!.computeMetrics().first;
          final t = Curves.easeInOut.transform(_walk.value);
          feet =
              m.getTangentForOffset(m.length * t)!.position +
              Offset.lerp(aside, const Offset(0, 10), math.min(1, t * 3))!;
          lift = (math.sin(_walk.value * math.pi * 6)).abs() * 5;
        } else {
          lift = math.sin(_breath.value * 2 * math.pi) * 1.2;
        }
        return Positioned(
          left: feet.dx - h / 2,
          top: feet.dy - h - lift,
          width: h,
          height: h,
          child: child!,
        );
      },
      child: IgnorePointer(
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: -3,
              child: Container(
                width: 26,
                height: 7,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
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
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(t.abandonConfirmTitle),
      content: Text(t.abandonConfirmBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(t.cancelAction),
        ),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: Palette.lacquer),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(t.abandon),
        ),
      ],
    ),
  );
  if (ok != true || !context.mounted) return;
  ref.read(runControllerProvider.notifier).abandon();
  ref.invalidate(savedRunProvider);
  context.go('/');
}

class _RunHeader extends StatelessWidget {
  const _RunHeader({
    required this.run,
    required this.floor,
    required this.floors,
  });

  final RunState run;

  /// Piso alcanzado (0 = al pie de la montaña) sobre el total.
  final int floor;
  final int floors;

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
          const Icon(Icons.favorite, color: Palette.jade, size: 18),
          const SizedBox(width: 4),
          Text(
            '${run.hp}/${run.maxHp}',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 8),
          JadeCount(jade: run.jade),
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
          // Los talismanes de la subida; tocarlos explica qué hace cada uno.
          Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
          _Altitude(floor: floor, floors: floors),
        ],
      ),
    );
  }
}

/// Cuánto falta para la cumbre: una regla vertical con el piso marcado.
class _Altitude extends StatelessWidget {
  const _Altitude({required this.floor, required this.floors});

  final int floor;
  final int floors;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Tooltip(
      message: t.mapFloor(floor, floors),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 6,
            height: 30,
            child: CustomPaint(painter: _AltitudePainter(floor / floors)),
          ),
          const SizedBox(width: 5),
          Text(
            '$floor/$floors',
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Palette.textDim,
            ),
          ),
        ],
      ),
    );
  }
}

class _AltitudePainter extends CustomPainter {
  _AltitudePainter(this.p);

  final double p;

  @override
  void paint(Canvas canvas, Size size) {
    final track = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(3),
    );
    canvas.drawRRect(track, Paint()..color = Palette.line);
    final h = size.height * p.clamp(0.0, 1.0);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(0, size.height - h, size.width, h),
        const Radius.circular(3),
      ),
      Paint()..color = Palette.gold,
    );
  }

  @override
  bool shouldRepaint(_AltitudePainter old) => old.p != p;
}
