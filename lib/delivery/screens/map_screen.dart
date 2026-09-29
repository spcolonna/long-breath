import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/enums.dart';
import '../../domain/model/game_balance.dart';
import '../../domain/model/game_data.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../controllers/combat_controller.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/deck_sheet.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final available = engine.available(run).toSet();
    final rows = _rows(data.balance);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Palette.ink,
        title: Text(t.mapTitle, style: const TextStyle(fontSize: 18)),
        actions: [
          IconButton(
            tooltip: t.abandon,
            icon: const Icon(Icons.close),
            onPressed: () {
              ref.read(runControllerProvider.notifier).abandon();
              ref.invalidate(savedRunProvider);
              context.go('/');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _RunHeader(run: run),
            Expanded(
              child: LayoutBuilder(builder: (context, box) {
                final pos = <String, Offset>{};
                final rowH = box.maxHeight / rows.length;
                for (var r = 0; r < rows.length; r++) {
                  final row = rows[r];
                  for (var i = 0; i < row.length; i++) {
                    // La run se juega de abajo hacia arriba.
                    pos[row[i].id] = Offset(
                      box.maxWidth * (i + 1) / (row.length + 1),
                      box.maxHeight - rowH * (r + 0.5),
                    );
                  }
                }
                return Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PathPainter(data.balance.runNodes, pos, run),
                      ),
                    ),
                    for (final n in data.balance.runNodes)
                      Positioned(
                        left: pos[n.id]!.dx - 36,
                        top: pos[n.id]!.dy - 36,
                        child: _NodeButton(
                          node: n,
                          data: data,
                          visited: run.visited.contains(n.id),
                          available: available.contains(n.id),
                          onTap: () => _enter(context, ref, n),
                        ),
                      ),
                  ],
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _enter(BuildContext context, WidgetRef ref, MapNodeDef n) {
    ref.read(runControllerProvider.notifier).enter(n.id);
    if (n.type == NodeType.combat) {
      ref.read(combatControllerProvider.notifier).start();
      context.go('/combat');
    } else {
      context.go('/fountain');
    }
  }

  /// Filas por profundidad desde el inicio.
  List<List<MapNodeDef>> _rows(GameBalance b) {
    final depth = <String, int>{b.runStart: 0};
    final queue = [b.runStart];
    while (queue.isNotEmpty) {
      final id = queue.removeAt(0);
      final node = b.runNodes.firstWhere((n) => n.id == id);
      for (final next in node.next) {
        if (!depth.containsKey(next)) {
          depth[next] = depth[id]! + 1;
          queue.add(next);
        }
      }
    }
    final maxD = depth.values.fold(0, (a, b) => a > b ? a : b);
    return [
      for (var d = 0; d <= maxD; d++)
        [for (final n in b.runNodes) if (depth[n.id] == d) n],
    ];
  }
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
          const SizedBox(width: 16),
          TextButton.icon(
            onPressed: () => showDeckSheet(context, run.deck),
            icon: const Icon(Icons.style, size: 18),
            label: Text(t.deckCount(run.deck.length)),
          ),
        ],
      ),
    );
  }
}

class _NodeButton extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final enemy = node.enemy == null ? null : data.enemy(node.enemy!);
    final glyph = enemy == null
        ? '泉'
        : switch (enemy.rank) {
            EnemyRank.common => '战',
            EnemyRank.elite => '僧',
            EnemyRank.boss => '龙',
          };
    final color = available
        ? Palette.gold
        : visited
            ? Palette.paperDim
            : Palette.inkLine;
    return GestureDetector(
      onTap: available ? onTap : null,
      child: SizedBox(
        width: 72,
        height: 72,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: available
                    ? Palette.lacquer
                    : (visited ? Palette.inkSoft : Palette.ink),
                border: Border.all(color: color, width: available ? 3 : 1.5),
                boxShadow: available
                    ? [BoxShadow(color: Palette.gold.withValues(alpha: 0.5), blurRadius: 12)]
                    : null,
              ),
              child: visited
                  ? const Icon(Icons.check, color: Palette.paperDim)
                  : Text(glyph,
                      style: TextStyle(
                          fontSize: 22,
                          color: available ? Palette.paper : Palette.paperDim)),
            ),
            const SizedBox(height: 2),
            Text(
              enemy?.name ?? 'Fuente',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9, color: color),
            ),
          ],
        ),
      ),
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
          ..color = walked ? Palette.gold : Palette.inkLine
          ..strokeWidth = walked ? 3 : 2;
        canvas.drawLine(pos[n.id]! + const Offset(0, -12),
            pos[next]! + const Offset(0, -12), paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathPainter old) => old.run != run;
}
