import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/meta_bonus.dart';
import '../../domain/run/cultivation.dart';
import '../../infrastructure/progress_storage.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/cultivation_view.dart';
import '../widgets/juice.dart';
import '../widgets/lotus.dart';

/// 经络: el árbol de meridianos. Tres canales (Cuerpo, Espíritu, Técnica)
/// de cinco puntos cada uno; se abren con semillas de loto cuando la
/// escuela llegó al reino de cada fila. Arriba, los dones de los reinos.
class MeridianScreen extends ConsumerStatefulWidget {
  const MeridianScreen({super.key});

  @override
  ConsumerState<MeridianScreen> createState() => _MeridianScreenState();
}

class _MeridianScreenState extends ConsumerState<MeridianScreen> {
  /// El último punto abierto (estalla en tinta) y cuántas veces.
  String? _opened;
  int _burst = 0;

  Future<void> _open(MeridianNode n, int realm) async {
    final def = ref.read(dataProvider).balance.meridians;
    final ok = await ref
        .read(progressStorageProvider)
        .openMeridian(def, n, realm);
    if (!ok || !mounted) return;
    HapticFeedback.heavyImpact();
    ref.read(audioProvider).play(Sfx.formComplete);
    ref
      ..invalidate(meridianProvider)
      ..invalidate(metaBonusProvider);
    setState(() {
      _opened = n.id;
      _burst++;
    });
  }

  void _details(MeridianNode n, Cultivation c, int lotus, List<String> owned) {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      showDragHandle: true,
      builder: (sheet) => _NodeSheet(
        node: n,
        cultivation: c,
        lotus: lotus,
        owned: owned,
        onOpen: () {
          Navigator.of(sheet).pop();
          _open(n, c.realm);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final data = ref.watch(dataProvider);
    final def = data.balance.meridians;
    final c = ref.watch(cultivationProvider).value;
    final m = ref.watch(meridianProvider).value;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(t.meridiansTitle),
        actions: [
          if (m != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: LotusCount(lotus: m.lotus, size: 24),
            ),
        ],
      ),
      body: c == null || m == null
          ? const SizedBox()
          : SafeArea(
              top: false,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                children: [
                  Text(
                    t.meridiansHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Palette.textDim),
                  ),
                  const SizedBox(height: 18),
                  _Tree(
                    def: def,
                    cultivation: c,
                    lotus: m.lotus,
                    owned: m.owned,
                    opened: _opened,
                    burst: _burst,
                    onTap: (n) => _details(n, c, m.lotus, m.owned),
                  ),
                  const SizedBox(height: 18),
                  _RealmGifts(cultivation: c),
                ],
              ),
            ),
    );
  }
}

/// Los dones de los reinos: un sello por reino, encendido si ya se llegó.
class _RealmGifts extends ConsumerWidget {
  const _RealmGifts({required this.cultivation});

  final Cultivation cultivation;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final perks = ref.watch(dataProvider).balance.meridians.realmPerks;
    final realms = cultivation.def.realms;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Palette.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.meridiansRealmGifts,
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
          Text(
            t.meridiansRealmGiftsHint,
            style: const TextStyle(fontSize: 12, color: Palette.textDim),
          ),
          const SizedBox(height: 10),
          for (final (i, r) in realms.indexed)
            if (perks[r.id] case final MetaBonus p)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 3),
                child: Opacity(
                  opacity: i <= cultivation.realm ? 1 : 0.5,
                  child: Row(
                    children: [
                      RealmSeal(
                        hanzi: r.hanzi,
                        size: 30,
                        sealed: i > cultivation.realm,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          '${text.realm(r.id)} · ${t.bonusLines(p).join(' · ')}',
                          style: const TextStyle(fontSize: 13),
                        ),
                      ),
                      if (i <= cultivation.realm)
                        const Icon(Icons.check, color: Palette.jade, size: 18),
                    ],
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

/// Los tres canales con sus puntos, fila por reino.
class _Tree extends StatelessWidget {
  const _Tree({
    required this.def,
    required this.cultivation,
    required this.lotus,
    required this.owned,
    required this.opened,
    required this.burst,
    required this.onTap,
  });

  final MeridianDef def;
  final Cultivation cultivation;
  final int lotus;
  final List<String> owned;
  final String? opened;
  final int burst;
  final ValueChanged<MeridianNode> onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final branches = MeridianBranch.values;
    final byBranch = {
      for (final b in branches)
        b: [
          for (final n in def.nodes)
            if (n.branch == b) n,
        ],
    };
    final rows = byBranch.values.fold(0, (a, l) => math.max(a, l.length));
    const rowH = 104.0;
    const gutter = 34.0;
    return Column(
      children: [
        Row(
          children: [
            const SizedBox(width: gutter),
            for (final b in branches)
              Expanded(
                child: Column(
                  children: [
                    InkSeal(
                      hanzi: branchLook(b).$1,
                      color: branchLook(b).$2,
                      size: 40,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.branchName(b),
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: rowH * rows,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // El reino que pide cada fila (el del primer canal).
              SizedBox(
                width: gutter,
                child: Column(
                  children: [
                    for (var i = 0; i < rows; i++)
                      SizedBox(
                        height: rowH,
                        child: Center(
                          child: () {
                            final n = byBranch[branches.first]!.elementAtOrNull(
                              i,
                            );
                            if (n == null) return const SizedBox();
                            final r = cultivation.def.realms[n.realm];
                            return RealmSeal(
                              hanzi: r.hanzi,
                              size: 28,
                              sealed: n.realm > cultivation.realm,
                            );
                          }(),
                        ),
                      ),
                  ],
                ),
              ),
              for (final b in branches)
                Expanded(
                  child: _Channel(
                    nodes: byBranch[b]!,
                    color: branchLook(b).$2,
                    rowH: rowH,
                    cultivation: cultivation,
                    lotus: lotus,
                    owned: owned,
                    def: def,
                    opened: opened,
                    burst: burst,
                    onTap: onTap,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Un canal: la línea de tinta (llena hasta el último punto abierto) y sus
/// puntos.
class _Channel extends StatelessWidget {
  const _Channel({
    required this.nodes,
    required this.color,
    required this.rowH,
    required this.cultivation,
    required this.lotus,
    required this.owned,
    required this.def,
    required this.opened,
    required this.burst,
    required this.onTap,
  });

  final List<MeridianNode> nodes;
  final Color color;
  final double rowH;
  final Cultivation cultivation;
  final int lotus;
  final List<String> owned;
  final MeridianDef def;
  final String? opened;
  final int burst;
  final ValueChanged<MeridianNode> onTap;

  @override
  Widget build(BuildContext context) {
    final done = nodes.where((n) => owned.contains(n.id)).length;
    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Positioned.fill(
          child: TweenAnimationBuilder<double>(
            tween: Tween(end: done.toDouble()),
            duration: const Duration(milliseconds: 900),
            curve: Curves.easeOutCubic,
            builder: (_, v, _) => CustomPaint(
              painter: _ChannelPainter(
                count: nodes.length,
                filled: v,
                rowH: rowH,
                color: color,
              ),
            ),
          ),
        ),
        Column(
          children: [
            for (final n in nodes)
              SizedBox(
                height: rowH,
                child: Center(
                  child: _Point(
                    node: n,
                    color: color,
                    owned: owned.contains(n.id),
                    open: def.canOpen(n, cultivation.realm, owned),
                    affordable: lotus >= n.cost,
                    burst: opened == n.id ? burst : 0,
                    onTap: () => onTap(n),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ChannelPainter extends CustomPainter {
  _ChannelPainter({
    required this.count,
    required this.filled,
    required this.rowH,
    required this.color,
  });

  final int count;
  final double filled;
  final double rowH;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (count < 2) return;
    final x = size.width / 2;
    final top = rowH / 2;
    final bottom = rowH * (count - 0.5);
    final base = Paint()
      ..color = Palette.line
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(Offset(x, top), Offset(x, bottom), base);
    if (filled <= 1) return;
    final ink = Paint()
      ..color = color.withValues(alpha: 0.85)
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    final end = top + rowH * (math.min(filled, count.toDouble()) - 1);
    canvas.drawLine(Offset(x, top), Offset(x, end), ink);
  }

  @override
  bool shouldRepaint(_ChannelPainter old) =>
      old.filled != filled || old.color != color;
}

/// Un punto del canal: abierto (lleno), por abrir (late si alcanza el loto)
/// o cerrado (apagado).
class _Point extends ConsumerStatefulWidget {
  const _Point({
    required this.node,
    required this.color,
    required this.owned,
    required this.open,
    required this.affordable,
    required this.burst,
    required this.onTap,
  });

  final MeridianNode node;
  final Color color;
  final bool owned;
  final bool open;
  final bool affordable;
  final int burst;
  final VoidCallback onTap;

  @override
  ConsumerState<_Point> createState() => _PointState();
}

class _PointState extends ConsumerState<_Point>
    with SingleTickerProviderStateMixin {
  late final _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = ref.watch(textProvider);
    final ready = widget.open && widget.affordable;
    final locked = !widget.owned && !widget.open;
    const size = 58.0;
    return GestureDetector(
      onTap: widget.onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (_, child) => Container(
                  width: size,
                  height: size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    boxShadow: [
                      if (ready)
                        BoxShadow(
                          color: Palette.jade.withValues(
                            alpha: 0.25 + 0.35 * _pulse.value,
                          ),
                          blurRadius: 10 + 10 * _pulse.value,
                          spreadRadius: 2 * _pulse.value,
                        ),
                      if (widget.owned)
                        BoxShadow(
                          color: Palette.gold.withValues(alpha: 0.45),
                          blurRadius: 12,
                        ),
                    ],
                  ),
                  child: child,
                ),
                child: Bounce(
                  trigger: widget.burst,
                  scale: 1.3,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 400),
                    width: size,
                    height: size,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: widget.owned ? Palette.gold : Palette.surface,
                      border: Border.all(
                        color: widget.owned
                            ? Palette.surface
                            : ready
                            ? Palette.jade
                            : locked
                            ? Palette.line
                            : widget.color.withValues(alpha: 0.6),
                        width: 3,
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(6),
                      child: FittedBox(
                        child: Text(
                          text.meridianHanzi(widget.node.id),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: widget.owned
                                ? Palette.onColor
                                : locked
                                ? Palette.textDim
                                : Palette.text,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned.fill(
                child: IgnorePointer(
                  child: InkBurst(
                    trigger: widget.burst,
                    colors: [widget.color, Palette.gold, Colors.white],
                    count: 34,
                    radius: 110,
                  ),
                ),
              ),
              if (locked)
                const Positioned(
                  right: -2,
                  bottom: -2,
                  child: Icon(Icons.lock, size: 16, color: Palette.textDim),
                ),
            ],
          ),
          const SizedBox(height: 4),
          widget.owned
              ? Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  color: Palette.surface,
                  child: Text(
                    text.meridian(widget.node.id),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Palette.gold,
                    ),
                  ),
                )
              : Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: Palette.surface,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const LotusSeed(size: 13),
                      const SizedBox(width: 3),
                      Text(
                        '${widget.node.cost}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: widget.affordable
                              ? Palette.blossom
                              : Palette.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
        ],
      ),
    );
  }
}

/// Detalle de un punto: qué hace, cuánto cuesta y el botón para abrirlo.
class _NodeSheet extends ConsumerWidget {
  const _NodeSheet({
    required this.node,
    required this.cultivation,
    required this.lotus,
    required this.owned,
    required this.onOpen,
  });

  final MeridianNode node;
  final Cultivation cultivation;
  final int lotus;
  final List<String> owned;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = ref.watch(dataProvider).balance.meridians;
    final (_, color) = branchLook(node.branch);
    final isOwned = owned.contains(node.id);
    final realm = cultivation.def.realms[node.realm];
    final String? why = isOwned
        ? null
        : cultivation.realm < node.realm
        ? t.meridianNeedsRealm('${realm.hanzi} ${text.realm(realm.id)}')
        : node.requires != null && !owned.contains(node.requires)
        ? t.meridianNeedsPrev
        : lotus < node.cost
        ? t.meridianNeedsLotus(node.cost - lotus)
        : null;
    final can =
        !isOwned && why == null && def.canOpen(node, cultivation.realm, owned);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkSeal(hanzi: text.meridianHanzi(node.id), color: color, size: 64),
            const SizedBox(height: 10),
            Text(
              text.meridian(node.id),
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            ),
            Text(
              '${t.branchName(node.branch)} · ${text.meridianText(node.id)}',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Palette.textDim),
            ),
            const SizedBox(height: 12),
            for (final line in t.bonusLines(node.effect))
              Text(
                line,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 6),
            Text(
              t.meridianNextRun,
              style: const TextStyle(fontSize: 12, color: Palette.textDim),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: isOwned
                  ? OutlinedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.check),
                      label: Text(t.meridianOpened),
                    )
                  : FilledButton.icon(
                      onPressed: can ? onOpen : null,
                      icon: const LotusSeed(size: 18),
                      label: Text(why ?? t.meridianOpen(node.cost)),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
