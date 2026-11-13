import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/combat/combat_engine.dart';
import '../../domain/model/card_def.dart';
import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import 'game_icon.dart';
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
    final art = ref.watch(cardArtProvider).value?.contains(def.id) ?? false;
    final h = width * 1.5;
    final s = width / 88;
    final color = typeColor(def.type);
    final p = preview;
    final cost = p?.cost ?? def.cost;
    final damage = p?.damage ?? (def.damage + (def.guard == 0 ? upgrades : 0));
    final structure = p?.structure ?? def.structure;
    final guard = p?.guard ?? (def.guard > 0 ? def.guard + upgrades : 0);

    // Selección, retenida o forma: un brillo con la forma del marco pintado
    // (no un borde aparte, que se lee como un segundo marco).
    Color? glow;
    final chained = p?.chained == true;
    if (advancesForm || chained) glow = Palette.gold;
    if (marked) glow = Palette.jade;
    if (selected) glow = Palette.lacquer;

    final dpr = MediaQuery.devicePixelRatioOf(context);
    final frame = 'assets/art/cards/frame_${def.type.name}.webp';
    final retained = p?.retained == true;
    // Medidas del marco (512×768): el círculo del costo y el hueco interior
    // (de 11,5% a 90,5% de ancho y de 9% a 85% de alto; abajo al centro
    // baja el adorno hasta el 82,5%).
    final badge = 18 * s;
    final hole = EdgeInsets.fromLTRB(
      width * 0.115,
      h * 0.09,
      width * 0.095,
      h * 0.15,
    );
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 200),
      opacity: playable ? 1 : 0.5,
      child: SizedBox(
        width: width,
        height: h,
        child: Stack(
          children: [
            if (glow != null)
              Positioned.fill(
                child: IgnorePointer(
                  child: ImageFiltered(
                    imageFilter: ImageFilter.blur(sigmaX: 5 * s, sigmaY: 5 * s),
                    child: Image.asset(
                      frame,
                      fit: BoxFit.fill,
                      color: glow,
                      colorBlendMode: BlendMode.srcIn,
                      cacheWidth: (width * dpr).ceil(),
                      errorBuilder: (_, _, _) => const SizedBox(),
                    ),
                  ),
                ),
              ),
            // Papel teñido del tipo, solo en el hueco (asoma un poco bajo el
            // marco para que no queden rendijas).
            Positioned(
              left: hole.left - width * 0.015,
              right: hole.right - width * 0.015,
              top: hole.top - h * 0.01,
              bottom: hole.bottom - h * 0.01,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4 * s),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [color.withValues(alpha: 0.2), Palette.surface],
                  ),
                ),
              ),
            ),
            // La ilustración ocupa el hueco de punta a punta; sin ella, el
            // hanzi de marca de agua.
            Positioned(
              left: hole.left,
              right: hole.right,
              top: hole.top,
              bottom: h * 0.41,
              child: ClipRect(
                child: art
                    ? Image.asset(
                        'assets/art/cards/${def.id}.webp',
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        cacheWidth: (width * dpr).ceil(),
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => const SizedBox(),
                      )
                    : Padding(
                        padding: EdgeInsets.all(4 * s),
                        child: FittedBox(
                          child: Text(
                            def.hanzi,
                            style: TextStyle(
                              fontSize: 40 * s, fontFamily: Fonts.display,
                              height: 1,
                              color: color.withValues(alpha: 0.2),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
              ),
            ),
            Positioned.fill(
              child: IgnorePointer(
                child: Image.asset(
                  frame,
                  fit: BoxFit.fill,
                  cacheWidth: (width * dpr).ceil(),
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (_, _, _) => const SizedBox(),
                ),
              ),
            ),
            // Legendaria: un brillo de oro recorre el marco cada tanto.
            if (def.rarity == CardRarity.legendary)
              Positioned.fill(
                child: IgnorePointer(
                  child: _GoldSheen(
                    frame: frame,
                    cacheWidth: (width * dpr).ceil(),
                  ),
                ),
              ),
            // Tipo por forma además de color (círculo, cuadrado, triángulo,
            // escudo o rombo), debajo del costo.
            Positioned(
              left: width * 0.146 - 6 * s,
              top: h * 0.111 + badge / 2 + 1.5 * s,
              child: TypeMark(def.type, size: 12 * s),
            ),
            // Rareza: una gema sobre el adorno del pie (las comunes no llevan).
            if (def.rarity != CardRarity.common)
              Positioned(
                left: width / 2 - 7 * s,
                top: h * 0.835 - 7 * s,
                child: RarityGem(def.rarity, size: 14 * s),
              ),
            Positioned(
              left: width * 0.146 - badge / 2,
              top: h * 0.111 - badge / 2,
              child: _CostBadge(
                cost: cost,
                base: def.cost,
                // Postura o carta retenida: verde si baja, rojo si sube.
                stanceDelta: p == null ? 0 : cost - def.cost,
                scale: s,
              ),
            ),
            // El tipo lo dicen el marco y su forma: arriba a la derecha van
            // solo la carta retenida, la postura a la que lleva y el aviso de
            // que corta una forma.
            if (retained ||
                def.stance != null ||
                def.chainFrom != null ||
                interruptsForm)
              Positioned(
                right: hole.right + 2 * s,
                top: hole.top + 2 * s,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (retained) _Tag(t.retainedTag, Palette.jade, scale: s),
                    if (def.stance != null || def.chainFrom != null)
                      Padding(
                        padding: EdgeInsets.only(top: retained ? 2 * s : 0),
                        // Cadena: de qué postura sale y a cuál lleva; dorada
                        // cuando ya estás en la de salida.
                        child: _Tag(
                          [
                            if (def.chainFrom != null)
                              text.stance(def.chainFrom!)
                            else
                              '',
                            if (def.stance != null) text.stance(def.stance!),
                          ].join(' → ').trim(),
                          chained ? Palette.gold : Palette.textDim,
                          scale: s,
                        ),
                      ),
                    if (chained)
                      Padding(
                        padding: EdgeInsets.only(top: 2 * s),
                        child: _Tag(
                          p?.closesCircle == true ? t.circleTag : t.chainedTag,
                          Palette.gold,
                          scale: s,
                        ),
                      ),
                    if (interruptsForm)
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 16 * s,
                        color: Palette.lacquer,
                      ),
                  ],
                ),
              ),
            // Nombre y números al pie, sobre el papel, por encima del adorno.
            // El nombre tiene tamaño fijo (hasta dos líneas) para que todas
            // las cartas se lean igual; la línea de números se achica si no
            // entra.
            Positioned(
              left: hole.left + 2 * s,
              right: hole.right + 2 * s,
              top: h * 0.57,
              bottom: h * 0.175,
              // Por las dudas (fuentes más altas), se achica en vez de
              // desbordar.
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: SizedBox(
                  width: width - hole.horizontal - 4 * s,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text.rich(
                        TextSpan(
                          text: text.card(def.id),
                          children: [
                            if (upgrades > 0)
                              TextSpan(
                                text: ' +$upgrades',
                                style: const TextStyle(color: Palette.gold),
                              ),
                          ],
                        ),
                        // Sin cortar: si el nombre es largo, el FittedBox
                        // achica el bloque entero en vez de poner "…".
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 9.5 * s,
                          fontWeight: FontWeight.w700,
                          height: 1,
                          color: Palette.text,
                        ),
                      ),
                      SizedBox(height: 1.5 * s),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: _Stats(
                          damage: damage,
                          structure: structure,
                          guard: guard,
                          height: def.height,
                          scale: s,
                          damageDelta:
                              (p?.stanceDamage ?? 0) + (p?.styleDamage ?? 0),
                          structureDelta: p?.stanceStructure ?? 0,
                          guardDelta: p?.stanceGuard ?? 0,
                          exhaust: def.exhaust,
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
    );
  }
}

/// Etiqueta chica de papel (carta retenida).
class _Tag extends StatelessWidget {
  const _Tag(this.label, this.color, {required this.scale});

  final String label;
  final Color color;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4 * scale, vertical: scale),
      decoration: BoxDecoration(
        color: Palette.surface.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(6 * scale),
        border: Border.all(color: color.withValues(alpha: 0.6)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 7.5 * scale,
          fontWeight: FontWeight.w800,
          color: color,
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
        width: 18 * scale,
        height: 18 * scale,
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
            fontSize: 11 * scale,
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
    this.exhaust = false,
  });

  final int damage;
  final int structure;
  final int guard;
  final Height? height;
  final double scale;
  final int damageDelta;
  final int structureDelta;
  final int guardDelta;

  /// Se quema al jugarla.
  final bool exhaust;

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
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) SizedBox(width: 4 * scale),
          items[i],
        ],
        if (exhaust)
          Padding(
            padding: EdgeInsets.only(left: 2 * scale),
            child: Icon(
              Icons.local_fire_department,
              size: 10 * scale,
              color: Palette.lacquer,
            ),
          ),
        if (items.isEmpty && !exhaust) SizedBox(height: 11 * scale),
      ],
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
            GameIcon(icon, size: 11 * scale, color: c),
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

/// Forma del tipo de carta: se lee aunque no se distinga el color.
class TypeMark extends StatelessWidget {
  const TypeMark(this.type, {super.key, this.size = 12});

  final CardType type;
  final double size;

  @override
  Widget build(BuildContext context) => Semantics(
    label: AppLocalizations.of(context).cardTypeName(type.name),
    child: CustomPaint(
      size: Size.square(size),
      painter: _TypeShapePainter(type),
    ),
  );
}

class _TypeShapePainter extends CustomPainter {
  _TypeShapePainter(this.type);

  final CardType type;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final r = Rect.fromLTWH(w * 0.12, w * 0.12, w * 0.76, w * 0.76);
    final path = switch (type) {
      CardType.palm => Path()..addOval(r),
      CardType.fist => Path()
        ..addRRect(RRect.fromRectAndRadius(r, Radius.circular(w * 0.12))),
      CardType.kick => Path()
        ..moveTo(w / 2, w * 0.08)
        ..lineTo(w * 0.94, w * 0.9)
        ..lineTo(w * 0.06, w * 0.9)
        ..close(),
      CardType.defense => Path()
        ..moveTo(w * 0.12, w * 0.12)
        ..lineTo(w * 0.88, w * 0.12)
        ..lineTo(w * 0.88, w * 0.48)
        ..quadraticBezierTo(w * 0.86, w * 0.82, w / 2, w * 0.95)
        ..quadraticBezierTo(w * 0.14, w * 0.82, w * 0.12, w * 0.48)
        ..close(),
      CardType.technique => Path()
        ..moveTo(w / 2, w * 0.04)
        ..lineTo(w * 0.94, w / 2)
        ..lineTo(w / 2, w * 0.96)
        ..lineTo(w * 0.06, w / 2)
        ..close(),
    };
    canvas.drawShadow(path, Palette.text, w * 0.08, false);
    canvas.drawPath(path, Paint()..color = typeColor(type));
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.12
        ..color = Palette.surface,
    );
  }

  @override
  bool shouldRepaint(_TypeShapePainter old) => old.type != type;
}

/// Gema de rareza: rombo de jade (rara) u oro con destello (legendaria).
class RarityGem extends StatelessWidget {
  const RarityGem(this.rarity, {super.key, this.size = 12});

  final CardRarity rarity;
  final double size;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Semantics(
      label: rarity == CardRarity.legendary ? t.cardLegendary : t.cardRare,
      child: CustomPaint(
        size: Size.square(size),
        painter: _GemPainter(rarity),
      ),
    );
  }
}

class _GemPainter extends CustomPainter {
  _GemPainter(this.rarity);

  final CardRarity rarity;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final gem = Path()
      ..moveTo(w / 2, 0)
      ..lineTo(w, w / 2)
      ..lineTo(w / 2, w)
      ..lineTo(0, w / 2)
      ..close();
    final (light, dark) = switch (rarity) {
      CardRarity.legendary => (const Color(0xFFFFE08A), Palette.gold),
      _ => (const Color(0xFF8FE3CF), Palette.jade),
    };
    canvas.drawShadow(gem, Palette.text, w * 0.1, false);
    canvas.drawPath(
      gem,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [light, dark],
        ).createShader(Offset.zero & size),
    );
    canvas.drawPath(
      gem,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = w * 0.1
        ..color = Palette.surface,
    );
    // Faceta de luz.
    canvas.drawCircle(
      Offset(w * 0.4, w * 0.36),
      w * 0.1,
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );
  }

  @override
  bool shouldRepaint(_GemPainter old) => old.rarity != rarity;
}

/// Destello de oro que cruza el marco de una legendaria (quieto con
/// movimiento reducido).
class _GoldSheen extends StatefulWidget {
  const _GoldSheen({required this.frame, required this.cacheWidth});

  final String frame;
  final int cacheWidth;

  @override
  State<_GoldSheen> createState() => _GoldSheenState();
}

class _GoldSheenState extends State<_GoldSheen>
    with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _c
        ..stop()
        ..value = 0.32;
    } else if (!_c.isAnimating) {
      _c.repeat();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _c,
    // El barrido ocupa el primer tercio del ciclo; el resto, reposo.
    builder: (context, child) {
      final x = -1.6 + _c.value * 3 * 3.2;
      return ShaderMask(
        blendMode: BlendMode.srcIn,
        shaderCallback: (r) => LinearGradient(
          begin: Alignment(x - 0.5, -1),
          end: Alignment(x + 0.5, 1),
          colors: const [
            Color(0x00FFE08A),
            Color(0xB3FFF3C4),
            Color(0x00FFE08A),
          ],
        ).createShader(r),
        child: child,
      );
    },
    child: Image.asset(
      widget.frame,
      fit: BoxFit.fill,
      cacheWidth: widget.cacheWidth,
      errorBuilder: (_, _, _) => const SizedBox(),
    ),
  );
}
