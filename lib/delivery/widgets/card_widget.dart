import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_engine.dart';
import '../../domain/model/card_def.dart';
import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import 'juice.dart';

/// Carta de juego. Con [preview] muestra los valores finales (bonus aplicados).
class CardWidget extends ConsumerWidget {
  const CardWidget({
    super.key,
    required this.def,
    this.upgrades = 0,
    this.preview,
    this.selected = false,
    this.advancesForm = false,
    this.interruptsForm = false,
    this.playable = true,
    this.marked = false,
    this.width = 88,
  });

  final CardDef def;
  final int upgrades;
  final CardPreview? preview;
  final bool selected;
  final bool advancesForm;
  final bool interruptsForm;
  final bool playable;

  /// Marcada para retener.
  final bool marked;
  final double width;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final h = width * 1.5;
    final s = width / 88;
    final color = typeColor(def.type);
    final p = preview;
    final cost = p?.cost ?? def.cost;
    final damage = p?.damage ?? (def.damage + (def.guard == 0 ? upgrades : 0));
    final structure = p?.structure ?? def.structure;
    final guard = p?.guard ?? (def.guard > 0 ? def.guard + upgrades : 0);

    Color border = Palette.line;
    double borderW = 1.5;
    List<BoxShadow> shadows = const [
      BoxShadow(color: Color(0x33000000), blurRadius: 6, offset: Offset(0, 3)),
    ];
    if (advancesForm) {
      border = Palette.gold;
      borderW = 2.5;
      shadows = [
        BoxShadow(color: Palette.gold.withValues(alpha: 0.55), blurRadius: 14),
      ];
    }
    if (marked) {
      border = Palette.jade;
      borderW = 3;
    }
    if (selected) {
      border = Palette.lacquer;
      borderW = 3;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: playable ? 1 : 0.5,
      child: Container(
        width: width,
        height: h,
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(color: border, width: borderW),
          boxShadow: shadows,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.22), Palette.surface],
          ),
        ),
        padding: EdgeInsets.all(5 * s),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    _CostBadge(
                      cost: cost,
                      base: def.cost,
                      // Postura o carta retenida: verde si baja, rojo si sube.
                      stanceDelta: p == null ? 0 : cost - def.cost,
                      scale: s,
                    ),
                    SizedBox(width: 4 * s),
                    Expanded(
                      child: Text(
                        p?.retained == true
                            ? t.retainedTag
                            : t.typeLabel(def.type),
                        textAlign: TextAlign.right,
                        maxLines: 1,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontSize: 9 * s,
                          color: p?.retained == true ? Palette.jade : color,
                          fontWeight: p?.retained == true
                              ? FontWeight.w800
                              : FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                // Nombre traducido como título; el hanzi queda de marca de agua.
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned.fill(
                        child: FittedBox(
                          child: Text(
                            def.hanzi,
                            style: TextStyle(
                              fontSize: 40 * s,
                              height: 1,
                              color: color.withValues(alpha: 0.16),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      // Con manos grandes la carta se achica: el texto se reduce
                      // en vez de desbordar.
                      LayoutBuilder(
                        builder: (context, box) => FittedBox(
                          fit: BoxFit.scaleDown,
                          child: SizedBox(
                            width: box.maxWidth,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  text.card(def.id),
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 12 * s,
                                    fontWeight: FontWeight.w700,
                                    height: 1.1,
                                    color: Palette.text,
                                  ),
                                ),
                                SizedBox(height: 2 * s),
                                Text(
                                  def.pinyin,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 8 * s,
                                    fontStyle: FontStyle.italic,
                                    color: Palette.textDim,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 3 * s),
                _Stats(
                  damage: damage,
                  structure: structure,
                  guard: guard,
                  height: def.height,
                  scale: s,
                  damageDelta: (p?.stanceDamage ?? 0) + (p?.styleDamage ?? 0),
                  structureDelta: p?.stanceStructure ?? 0,
                  guardDelta: p?.stanceGuard ?? 0,
                ),
                if (def.stance != null || def.exhaust || upgrades > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 2 * s),
                    child: Text(
                      [
                        if (def.stance != null) '→ ${text.stance(def.stance!)}',
                        if (def.exhaust) t.effExhaust,
                        if (upgrades > 0) '+$upgrades',
                      ].join(' · '),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 8 * s, color: Palette.textDim),
                    ),
                  ),
              ],
            ),
            if (interruptsForm)
              Positioned(
                right: 0,
                top: 16 * s,
                child: Icon(
                  Icons.warning_amber_rounded,
                  size: 16 * s,
                  color: Palette.lacquer,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Los números van centrados por su caja, sin el aire de arriba y abajo
/// que la fuente deja por defecto (si no, se ven corridos en los círculos).
const _tight = TextHeightBehavior(
  applyHeightToFirstAscent: false,
  applyHeightToLastDescent: false,
  leadingDistribution: TextLeadingDistribution.even,
);

/// Costo de la carta: jade si la postura la abarata, laca si la encarece.
class _CostBadge extends StatelessWidget {
  const _CostBadge({
    required this.cost,
    required this.base,
    required this.stanceDelta,
    required this.scale,
  });

  final int cost;
  final int base;
  final int stanceDelta;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final changed = cost != base;
    final fill = stanceDelta < 0
        ? Palette.jade
        : stanceDelta > 0
        ? Palette.lacquer
        : Palette.sky.withValues(alpha: 0.85);
    return Bounce(
      trigger: stanceDelta,
      scale: 1.3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        width: 20 * scale,
        height: 20 * scale,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: fill,
          border: changed ? Border.all(color: Palette.gold, width: 2) : null,
        ),
        child: Text(
          '$cost',
          textHeightBehavior: _tight,
          style: TextStyle(
            fontSize: 12 * scale,
            height: 1,
            leadingDistribution: TextLeadingDistribution.even,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

/// Daño, Estructura y guardia. Lo que suma la postura va con ▲ en jade y lo
/// que resta con ▼ en laca, y rebota cuando cambia la postura.
class _Stats extends StatelessWidget {
  const _Stats({
    required this.damage,
    required this.structure,
    required this.guard,
    required this.height,
    required this.scale,
    this.damageDelta = 0,
    this.structureDelta = 0,
    this.guardDelta = 0,
  });

  final int damage;
  final int structure;
  final int guard;
  final Height? height;
  final double scale;
  final int damageDelta;
  final int structureDelta;
  final int guardDelta;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (damage > 0)
        _stat(Icons.flash_on, damage, damageDelta, Palette.lacquer),
      if (structure > 0)
        _stat(
          Icons.hexagon_outlined,
          structure,
          structureDelta,
          Palette.structure,
        ),
      if (guard > 0) _stat(heightIcon(height), guard, guardDelta, Palette.sky),
    ];
    if (items.isEmpty) return SizedBox(height: 14 * scale);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4 * scale,
      children: items,
    );
  }

  Widget _stat(IconData icon, int v, int delta, Color c) {
    final mark = delta > 0 ? Palette.jade : Palette.lacquer;
    return Bounce(
      trigger: delta,
      scale: 1.3,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: EdgeInsets.symmetric(
          horizontal: delta == 0 ? 0 : 3 * scale,
          vertical: delta == 0 ? 0 : 1 * scale,
        ),
        decoration: BoxDecoration(
          color: delta == 0 ? null : mark.withValues(alpha: 0.16),
          borderRadius: BorderRadius.circular(4 * scale),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 11 * scale, color: c),
            Text(
              '$v',
              textHeightBehavior: _tight,
              style: TextStyle(
                fontSize: 11 * scale,
                height: 1,
                leadingDistribution: TextLeadingDistribution.even,
                fontWeight: FontWeight.bold,
                color: c,
              ),
            ),
            if (delta != 0)
              Text(
                delta > 0 ? '▲' : '▼',
                textHeightBehavior: _tight,
                style: TextStyle(
                  fontSize: 8 * scale,
                  height: 1,
                  leadingDistribution: TextLeadingDistribution.even,
                  fontWeight: FontWeight.bold,
                  color: mark,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
