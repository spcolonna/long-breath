import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../domain/model/enums.dart';
import '../../../domain/model/game_balance.dart';
import '../../../domain/model/game_data.dart';
import '../../../l10n/app_localizations.dart';
import '../../providers.dart';
import '../../theme.dart';

/// Ancho y alto de un lugar (sello + nombre); el centro del sello queda en
/// [sealCenter].
const nodeBox = Size(104, 92);
const sealCenter = Offset(52, 30);

/// Cómo se ve cada tipo de lugar: el carácter tallado en la piedra y su
/// color. El combate muestra el rango (común, élite o jefe), no quién es.
({String hanzi, Color color, double size}) nodeLook(
  MapNodeDef n,
  GameData data,
) => switch (n.type) {
  NodeType.combat => switch (data.enemy(n.enemy!).rank) {
    EnemyRank.common => (hanzi: '武', color: Palette.lacquer, size: 48.0),
    EnemyRank.elite => (hanzi: '精', color: Palette.gold, size: 52.0),
    EnemyRank.boss => (hanzi: '龙', color: Palette.lacquer, size: 60.0),
  },
  NodeType.fountain => (hanzi: '泉', color: Palette.sky, size: 48.0),
  NodeType.shrine => (hanzi: '庙', color: Palette.gold, size: 52.0),
  NodeType.event => (hanzi: '缘', color: Palette.blossom, size: 48.0),
  NodeType.merchant => (hanzi: '商', color: Palette.jade, size: 48.0),
  NodeType.master => (hanzi: '师', color: Palette.structure, size: 48.0),
};

String nodeLabel(
  MapNodeDef n,
  AppLocalizations t,
  String Function(String scene, String light) path,
) => switch (n.type) {
  // El camino tiene nombre de lugar: quién espera se ve al llegar.
  NodeType.combat =>
    n.scene == null ? t.combatNode : path(n.scene!, n.light ?? 'alba'),
  NodeType.fountain => t.fountainNode,
  NodeType.shrine => t.shrineNode,
  NodeType.event => t.eventNode,
  NodeType.merchant => t.merchantNode,
  NodeType.master => t.masterNode,
};

/// Un lugar del mapa: un sello de piedra con su carácter tallado. El que se
/// puede tomar flota y late; el ya andado lleva el sello rojo 印; los que
/// faltan esperan apagados.
class MapNode extends ConsumerStatefulWidget {
  const MapNode({
    super.key,
    required this.node,
    required this.visited,
    required this.available,
    required this.onTap,
  });

  final MapNodeDef node;
  final bool visited;
  final bool available;
  final VoidCallback? onTap;

  @override
  ConsumerState<MapNode> createState() => _MapNodeState();
}

class _MapNodeState extends ConsumerState<MapNode>
    with SingleTickerProviderStateMixin {
  late final _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  bool _down = false;

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(MapNode old) {
    super.didUpdateWidget(old);
    _sync();
  }

  void _sync() {
    if (widget.available && !_float.isAnimating) _float.repeat();
    if (!widget.available && _float.isAnimating) _float.stop();
  }

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final text = ref.watch(textProvider);
    final look = nodeLook(widget.node, data);
    final label = nodeLabel(widget.node, t, text.path);
    final available = widget.available;
    final tap = available ? widget.onTap : null;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: tap == null ? null : (_) => setState(() => _down = true),
      onTapCancel: () => setState(() => _down = false),
      onTapUp: tap == null ? null : (_) => setState(() => _down = false),
      onTap: tap,
      child: SizedBox.fromSize(
        size: nodeBox,
        child: AnimatedBuilder(
          animation: _float,
          builder: (_, child) {
            final phase = _float.value * 2 * math.pi;
            return Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.topCenter,
              children: [
                // Sombra en el suelo: se achica cuando el sello sube.
                Positioned(
                  top: sealCenter.dy + look.size / 2 - 3,
                  child: Container(
                    width: look.size * (0.8 - 0.08 * math.sin(phase)),
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: const Color(
                        0xFF8C7B5E,
                      ).withValues(alpha: available ? 0.22 : 0.14),
                    ),
                  ),
                ),
                Positioned(
                  top:
                      sealCenter.dy -
                      look.size / 2 +
                      (available ? -3 - 3 * math.sin(phase) : 0),
                  child: AnimatedScale(
                    scale: _down ? 0.9 : 1,
                    duration: const Duration(milliseconds: 110),
                    child: _Seal(
                      look: look,
                      available: available,
                      visited: widget.visited,
                      pulse: available ? _float.value : null,
                    ),
                  ),
                ),
                // Grupo: un punto por enemigo, colgado del sello.
                if (widget.node.waves.isNotEmpty)
                  Positioned(
                    top:
                        sealCenter.dy -
                        look.size / 2 -
                        6 +
                        (available ? -3 - 3 * math.sin(phase) : 0),
                    left: sealCenter.dx + look.size / 2 - 12,
                    child: _PackPips(
                      count: 1 + widget.node.waves.length,
                      color: look.color,
                      dim: !available,
                    ),
                  ),
                Positioned(
                  top: sealCenter.dy + look.size / 2 + 6,
                  child: child!,
                ),
              ],
            );
          },
          child: _Ribbon(label: label, strong: available, color: look.color),
        ),
      ),
    );
  }
}

/// Cuántos enemigos trae el combate: puntos de tinta en una plaquita.
class _PackPips extends StatelessWidget {
  const _PackPips({
    required this.count,
    required this.color,
    required this.dim,
  });

  final int count;
  final Color color;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    final c = dim ? color.withValues(alpha: 0.5) : color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 4),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c, width: 1.4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < count; i++)
            Container(
              margin: EdgeInsets.only(left: i == 0 ? 0 : 3),
              width: 6,
              height: 6,
              decoration: BoxDecoration(shape: BoxShape.circle, color: c),
            ),
        ],
      ),
    );
  }
}

class _Seal extends StatelessWidget {
  const _Seal({
    required this.look,
    required this.available,
    required this.visited,
    required this.pulse,
  });

  final ({String hanzi, Color color, double size}) look;
  final bool available;
  final bool visited;

  /// Fase del latido (0..1) si se puede tomar.
  final double? pulse;

  @override
  Widget build(BuildContext context) {
    final s = look.size;
    final dim = !available && !visited;
    final carve = visited
        ? Palette.textDim.withValues(alpha: 0.55)
        : dim
        ? look.color.withValues(alpha: 0.55)
        : look.color;
    final rim = available
        ? look.color
        : look.color.withValues(alpha: visited ? 0.25 : 0.45);
    return SizedBox(
      width: s,
      height: s,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (pulse != null) ...[
            // Aura del color del lugar y un anillo que se expande.
            Container(
              width: s + 18,
              height: s + 18,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: look.color.withValues(alpha: 0.35),
                    blurRadius: 16,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
            IgnorePointer(
              child: OverflowBox(
                maxWidth: s + 40,
                maxHeight: s + 40,
                child: Container(
                  width: s + 34 * ((pulse! * 1.6) % 1),
                  height: s + 34 * ((pulse! * 1.6) % 1),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: look.color.withValues(
                        alpha: 0.6 * (1 - (pulse! * 1.6) % 1),
                      ),
                      width: 2,
                    ),
                  ),
                ),
              ),
            ),
          ],
          // La piedra: luz arriba a la izquierda, sombra abajo.
          Container(
            width: s,
            height: s,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                center: const Alignment(-0.35, -0.45),
                radius: 0.95,
                colors: dim || visited
                    ? const [Color(0xFFF4EEE2), Color(0xFFD6CCBA)]
                    : const [Color(0xFFFFFBF1), Color(0xFFE2D3B6)],
              ),
              border: Border.all(color: rim, width: available ? 3 : 2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x40806A45),
                  offset: Offset(0, 3),
                  blurRadius: 3,
                ),
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/art/stages/qianyunshan/map_node_stone.png',
                fit: BoxFit.cover,
                opacity: const AlwaysStoppedAnimation(0.9),
                errorBuilder: (_, _, _) => const SizedBox(),
              ),
            ),
          ),
          // Surco tallado por dentro del borde.
          Container(
            width: s - 12,
            height: s - 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: const Color(0xFF8C7B5E).withValues(alpha: 0.22),
              ),
            ),
          ),
          // El carácter tallado: oscuro arriba, luz abajo (bajorrelieve).
          Text(
            look.hanzi,
            style: TextStyle(
              fontSize: s * 0.46,
              height: 1,
              fontWeight: FontWeight.w800,
              color: carve,
              shadows: const [
                Shadow(color: Color(0xCCFFFFFF), offset: Offset(0, 1.2)),
              ],
            ),
          ),
          if (visited)
            Positioned(
              right: -4,
              bottom: -2,
              child: Transform.rotate(
                angle: -0.18,
                child: Container(
                  width: 22,
                  height: 22,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Palette.lacquer.withValues(alpha: 0.88),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    '印',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1,
                      color: Palette.onColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// El nombre del lugar en una cinta de papel con las puntas cortadas.
class _Ribbon extends StatelessWidget {
  const _Ribbon({
    required this.label,
    required this.strong,
    required this.color,
  });

  final String label;
  final bool strong;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 100),
      child: DecoratedBox(
        decoration: ShapeDecoration(
          color: Palette.surface.withValues(alpha: strong ? 0.97 : 0.82),
          shape: BeveledRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: BorderSide(
              color: strong ? color.withValues(alpha: 0.7) : Palette.line,
              width: strong ? 1.4 : 1,
            ),
          ),
          shadows: strong
              ? const [
                  BoxShadow(
                    color: Color(0x22806A45),
                    offset: Offset(0, 2),
                    blurRadius: 3,
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 2, 8, 3),
          child: Text(
            label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              height: 1.1,
              fontWeight: strong ? FontWeight.w700 : FontWeight.w500,
              color: strong ? Palette.text : Palette.textDim,
            ),
          ),
        ),
      ),
    );
  }
}
