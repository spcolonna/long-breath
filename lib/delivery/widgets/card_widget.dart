import 'package:flutter/material.dart';

import '../../domain/combat/combat_engine.dart';
import '../../domain/model/card_def.dart';
import '../../domain/model/enums.dart';
import '../theme.dart';

const stanceNames = {
  Stance.mabu: ('Mǎbù', '马步'),
  Stance.gongbu: ('Gōngbù', '弓步'),
  Stance.xubu: ('Xūbù', '虚步'),
};

/// Carta de juego. Con [preview] muestra los valores finales (bonus aplicados).
class CardWidget extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final h = width * 1.5;
    final s = width / 88;
    final color = typeColor(def.type);
    final p = preview;
    final cost = p?.cost ?? def.cost;
    final damage = p?.damage ?? (def.damage + (def.guard == 0 ? upgrades : 0));
    final structure = p?.structure ?? def.structure;
    final guard = p?.guard ?? (def.guard > 0 ? def.guard + upgrades : 0);

    Color border = Palette.inkLine;
    double borderW = 1.5;
    List<BoxShadow> shadows = const [
      BoxShadow(color: Colors.black54, blurRadius: 6, offset: Offset(0, 3)),
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
      border = Palette.paper;
      borderW = 3;
    }

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: playable ? 1 : 0.5,
      child: Container(
        width: width,
        height: h,
        decoration: BoxDecoration(
          color: Palette.inkSoft,
          borderRadius: BorderRadius.circular(10 * s),
          border: Border.all(color: border, width: borderW),
          boxShadow: shadows,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color.withValues(alpha: 0.28), Palette.inkSoft],
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
                    _CostBadge(cost: cost, base: def.cost, scale: s),
                    SizedBox(width: 4 * s),
                    Expanded(
                      child: Text(typeLabel(def.type),
                          textAlign: TextAlign.right,
                          maxLines: 1,
                          overflow: TextOverflow.clip,
                          style: TextStyle(
                              fontSize: 9 * s,
                              color: color,
                              fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
                Expanded(
                  child: Center(
                    child: FittedBox(
                      child: Text(def.hanzi,
                          style: TextStyle(
                              fontSize: 24 * s,
                              color: Palette.paper,
                              fontWeight: FontWeight.w500)),
                    ),
                  ),
                ),
                Text(def.pinyin,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 9.5 * s,
                        fontWeight: FontWeight.w600,
                        height: 1.1)),
                SizedBox(height: 3 * s),
                _Stats(
                  damage: damage,
                  structure: structure,
                  guard: guard,
                  height: def.height,
                  scale: s,
                ),
                if (def.stance != null || def.exhaust || upgrades > 0)
                  Padding(
                    padding: EdgeInsets.only(top: 2 * s),
                    child: Text(
                      [
                        if (def.stance != null) '→ ${stanceNames[def.stance]!.$1}',
                        if (def.exhaust) 'Agotar',
                        if (upgrades > 0) '+$upgrades',
                      ].join(' · '),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 8 * s, color: Palette.paperDim),
                    ),
                  ),
              ],
            ),
            if (interruptsForm)
              Positioned(
                right: 0,
                top: 16 * s,
                child: Icon(Icons.warning_amber_rounded,
                    size: 16 * s, color: Palette.lacquer),
              ),
          ],
        ),
      ),
    );
  }
}

class _CostBadge extends StatelessWidget {
  const _CostBadge({required this.cost, required this.base, required this.scale});

  final int cost;
  final int base;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final changed = cost != base;
    return Container(
      width: 20 * scale,
      height: 20 * scale,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Palette.sky.withValues(alpha: 0.85),
        border: changed ? Border.all(color: Palette.gold, width: 2) : null,
      ),
      child: Text('$cost',
          style: TextStyle(
              fontSize: 12 * scale,
              fontWeight: FontWeight.bold,
              color: Colors.white)),
    );
  }
}

class _Stats extends StatelessWidget {
  const _Stats({
    required this.damage,
    required this.structure,
    required this.guard,
    required this.height,
    required this.scale,
  });

  final int damage;
  final int structure;
  final int guard;
  final Height? height;
  final double scale;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[
      if (damage > 0) _stat(Icons.flash_on, '$damage', Palette.lacquer),
      if (structure > 0) _stat(Icons.hexagon_outlined, '$structure', Palette.structure),
      if (guard > 0) _stat(heightIcon(height), '$guard', Palette.sky),
    ];
    if (items.isEmpty) return SizedBox(height: 14 * scale);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 4 * scale,
      children: items,
    );
  }

  Widget _stat(IconData icon, String v, Color c) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11 * scale, color: c),
          Text(v,
              style: TextStyle(
                  fontSize: 11 * scale, fontWeight: FontWeight.bold, color: c)),
        ],
      );
}

/// Texto corto con el efecto especial de la carta (lo que no se ve en íconos).
String cardEffectText(CardDef d) {
  final parts = <String>[
    if (d.stance != null) 'Pasás a ${stanceNames[d.stance]!.$1}',
    if (d.draw > 0) 'Robás ${d.draw}',
    if (d.gainBreath > 0) '+${d.gainBreath} Aliento',
    if (d.bonusDamageIfStaggered > 0)
      '+${d.bonusDamageIfStaggered} si el enemigo está Desequilibrado',
    if (d.onDeflectDamage > 0) 'Si desviás, ${d.onDeflectDamage} de daño',
    if (d.onDeflectStructure > 0)
      'Si desviás, el enemigo pierde ${d.onDeflectStructure} E extra',
    if (d.stanceStructureBonus != null)
      'En ${stanceNames[d.stanceStructureBonus!.$1]!.$1}, +${d.stanceStructureBonus!.$2} E',
    if (d.clearGuard) 'Perdés toda tu Guardia',
    if (d.turnStructureBonus > 0)
      'Este turno, todo daño a Estructura +${d.turnStructureBonus}',
    if (d.firstTurnOnly) 'Solo en el primer turno',
    if (d.exhaust) 'Agotar',
  ];
  return parts.join('. ');
}
