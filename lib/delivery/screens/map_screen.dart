import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/model/game_balance.dart';
import '../../domain/model/game_data.dart';
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
import '../widgets/talisman_widgets.dart';

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
              '${ref.watch(textProvider).stage(data.balance.stage.id)} · ${data.balance.stage.hanzi}',
              style: const TextStyle(fontSize: 18),
            ),
            Text(
              t.difficultyName(run.difficulty),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: difficultyColor(run.difficulty),
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
      body: SafeArea(
        child: Column(
          children: [
            _RunHeader(run: run),
            Expanded(child: _MapView(run: run, available: available)),
          ],
        ),
      ),
    );
  }
}

/// Filas por profundidad desde los nodos de inicio.
List<List<MapNodeDef>> _rows(RunState run) {
  final depth = {for (final id in run.starts) id: 0};
  final queue = [...run.starts];
  while (queue.isNotEmpty) {
    final id = queue.removeAt(0);
    for (final next in run.node(id).next) {
      if (!depth.containsKey(next)) {
        depth[next] = depth[id]! + 1;
        queue.add(next);
      }
    }
  }
  final maxD = depth.values.fold(0, (a, b) => a > b ? a : b);
  return [
    for (var d = 0; d <= maxD; d++)
      [
        for (final n in run.map)
          if (depth[n.id] == d) n,
      ],
  ];
}

/// El mapa se recorre de abajo hacia arriba y, si no entra, se desplaza;
/// arranca mostrando el piso al que se puede ir.
class _MapView extends ConsumerStatefulWidget {
  const _MapView({required this.run, required this.available});

  final RunState run;
  final Set<String> available;

  @override
  ConsumerState<_MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<_MapView> {
  static const _rowH = 96.0;
  ScrollController? _scroll;

  @override
  void dispose() {
    _scroll?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final run = widget.run;
    final data = ref.watch(dataProvider);
    final rows = _rows(run);
    return LayoutBuilder(
      builder: (context, box) {
        final height = math.max(box.maxHeight, rows.length * _rowH);
        final rowH = height / rows.length;
        final target = rows.indexWhere(
          (row) => row.any((n) => widget.available.contains(n.id)),
        );
        _scroll ??= ScrollController(
          initialScrollOffset: math.max(
            0,
            math.min(
              height - box.maxHeight,
              (target < 0 ? 0 : target) * rowH - box.maxHeight * 0.3,
            ),
          ),
        );
        final pos = <String, Offset>{};
        for (var r = 0; r < rows.length; r++) {
          final row = rows[r];
          for (var i = 0; i < row.length; i++) {
            pos[row[i].id] = Offset(
              box.maxWidth * (i + 1) / (row.length + 1),
              height - rowH * (r + 0.5),
            );
          }
        }
        return SingleChildScrollView(
          controller: _scroll,
          reverse: true,
          child: SizedBox(
            width: box.maxWidth,
            height: height,
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: _PathPainter(run.map, pos, run),
                  ),
                ),
                for (final n in run.map)
                  Positioned(
                    left: pos[n.id]!.dx - 50,
                    top: pos[n.id]!.dy - 36,
                    child: _NodeButton(
                      node: n,
                      data: data,
                      visited: run.visited.contains(n.id),
                      available: widget.available.contains(n.id),
                      onTap: () {
                        ref.read(audioProvider).play(Sfx.mapNode);
                        _enter(context, ref, n);
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

void _enter(BuildContext context, WidgetRef ref, MapNodeDef n) {
  ref.read(runControllerProvider.notifier).enter(n.id);
  switch (n.type) {
    case NodeType.combat:
      ref.read(combatControllerProvider.notifier).start();
      context.go('/combat');
    case NodeType.fountain:
      context.go('/fountain');
    case NodeType.shrine:
      context.go('/shrine');
    case NodeType.event:
      context.go('/event');
    case NodeType.merchant:
      context.go('/merchant');
    case NodeType.master:
      context.go('/master');
  }
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
  const _RunHeader({required this.run});

  final RunState run;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.favorite, color: Palette.jade, size: 18),
          const SizedBox(width: 4),
          Text('${run.hp}/${run.maxHp}'),
          const SizedBox(width: 12),
          JadeCount(jade: run.jade),
          const SizedBox(width: 4),
          TextButton.icon(
            onPressed: () => showDeckSheet(context, run.deck),
            icon: const Icon(Icons.style, size: 18),
            label: Text(t.deckCount(run.deck.length)),
          ),
          // Los talismanes de la subida; tocarlos explica qué hace cada uno.
          Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
        ],
      ),
    );
  }
}

class _NodeButton extends ConsumerWidget {
  const _NodeButton({
    required this.node,
    required this.data,
    required this.visited,
    required this.available,
    required this.onTap,
  });

  final MapNodeDef node;
  final GameData data;
  final bool visited;
  final bool available;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final enemy = node.enemy == null ? null : data.enemy(node.enemy!);
    final (IconData icon, Color accent, String label) = switch (node.type) {
      NodeType.combat => (
        switch (enemy!.rank) {
          EnemyRank.common => Icons.sports_martial_arts,
          EnemyRank.elite => Icons.whatshot,
          EnemyRank.boss => Icons.military_tech,
        },
        rankColor(enemy.rank),
        text.enemy(enemy.id),
      ),
      NodeType.fountain => (Icons.water_drop, Palette.sky, t.fountainNode),
      NodeType.shrine => (Icons.temple_buddhist, Palette.gold, t.shrineNode),
      NodeType.event => (
        Icons.question_mark_rounded,
        Palette.blossom,
        t.eventNode,
      ),
      NodeType.merchant => (
        Icons.storefront_rounded,
        Palette.jade,
        t.merchantNode,
      ),
      NodeType.master => (
        Icons.self_improvement_rounded,
        Palette.structure,
        t.masterNode,
      ),
    };
    // Cada tipo de nodo tiene su color, así el mapa se lee de un vistazo.
    final color = available
        ? Palette.gold
        : visited
        ? Palette.textDim
        : accent;
    return GestureDetector(
      onTap: available
          ? () {
              HapticFeedback.mediumImpact();
              onTap();
            }
          : null,
      // Angosto: con tres lugares por piso los nombres no se pisan.
      child: SizedBox(
        width: 100,
        height: 84,
        child: Column(
          children: [
            _PulseRing(
              active: available,
              color: accent,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 48,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: available
                      ? accent
                      : (visited ? Palette.bgAlt : Palette.surface),
                  border: Border.all(color: color, width: available ? 3 : 1.5),
                  boxShadow: available
                      ? [
                          BoxShadow(
                            color: Palette.gold.withValues(alpha: 0.5),
                            blurRadius: 12,
                          ),
                        ]
                      : null,
                ),
                child: visited
                    ? const Icon(Icons.check, color: Palette.textDim)
                    : Icon(
                        icon,
                        size: 24,
                        color: available ? Palette.onColor : accent,
                      ),
              ),
            ),
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(
                color: Palette.surface.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  height: 1.1,
                  color: available ? Palette.text : Palette.textDim,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Los nodos a los que se puede ir laten y sueltan un anillo, para que el
/// siguiente paso se vea sin buscarlo.
class _PulseRing extends StatefulWidget {
  const _PulseRing({
    required this.active,
    required this.color,
    required this.child,
  });

  final bool active;
  final Color color;
  final Widget child;

  @override
  State<_PulseRing> createState() => _PulseRingState();
}

class _PulseRingState extends State<_PulseRing>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );
    if (widget.active) _c.repeat();
  }

  @override
  void didUpdateWidget(_PulseRing old) {
    super.didUpdateWidget(old);
    if (widget.active && !_c.isAnimating) _c.repeat();
    if (!widget.active && _c.isAnimating) _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.active) return widget.child;
    return AnimatedBuilder(
      animation: _c,
      builder: (_, child) {
        final t = _c.value;
        final beat = 1 + 0.06 * math.sin(math.pi * math.min(1, t * 2.5));
        return Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            // El anillo no ocupa lugar: se expande por fuera del nodo.
            Positioned.fill(
              child: OverflowBox(
                maxWidth: 80,
                maxHeight: 80,
                child: Container(
                  width: 48 + 30 * t,
                  height: 48 + 30 * t,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color.withValues(alpha: 0.7 * (1 - t)),
                      width: 3 * (1 - t) + 1,
                    ),
                  ),
                ),
              ),
            ),
            Transform.scale(scale: beat, child: child),
          ],
        );
      },
      child: widget.child,
    );
  }
}

class _PathPainter extends CustomPainter {
  _PathPainter(this.nodes, this.pos, this.run);

  final List<MapNodeDef> nodes;
  final Map<String, Offset> pos;
  final RunState run;

  @override
  void paint(Canvas canvas, Size size) {
    for (final n in nodes) {
      for (final next in n.next) {
        final walked = run.visited.contains(n.id) && run.visited.contains(next);
        final paint = Paint()
          ..color = walked ? Palette.gold : Palette.line
          ..strokeWidth = walked ? 3 : 2;
        canvas.drawLine(
          pos[n.id]! + const Offset(0, -12),
          pos[next]! + const Offset(0, -12),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.run != run;
}
