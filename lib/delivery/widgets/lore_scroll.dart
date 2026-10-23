import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/run/ascent.dart';
import '../../l10n/app_localizations.dart';
import '../content_text.dart';
import '../providers.dart';
import '../theme.dart';

const _rod = Color(0xFFC9A46A);
const _rodEdge = Color(0xFFA9844C);

/// La pintura del rollo (1024×1536): varilla de arriba, papel con su borde
/// bermellón y varilla de abajo. Se recorta en esas tres piezas para que el
/// papel se estire al largo del texto y se pueda desenrollar.
const _artPath = 'assets/art/ui/lore_scroll.webp';
const _artW = 1024.0;

/// Ancho visible de las varillas en la pintura (sin el margen transparente).
const _rodL = 49.0, _rodR = 974.0;
const _topRod = Rect.fromLTRB(0, 0, _artW, 140);
const _paper = Rect.fromLTRB(168, 140, 857, 1388);
const _bottomRod = Rect.fromLTRB(0, 1388, _artW, 1536);

/// Esquinas del papel que no se estiran (en píxeles de la pintura).
const _paperCorner = 44.0;

final _art = ValueNotifier<ui.Image?>(null);
ImageStream? _artStream;

/// Carga la pintura una sola vez; mientras tanto (o si falta) se dibuja el
/// rollo en código.
void _loadArt() {
  if (_artStream != null) return;
  _artStream = const AssetImage(_artPath).resolve(ImageConfiguration.empty)
    ..addListener(
      ImageStreamListener(
        (info, _) => _art.value = info.image,
        onError: (_, _) {},
      ),
    );
}

/// Una varilla recortada de la pintura, a lo ancho del rollo.
class _RodPainter extends CustomPainter {
  _RodPainter(this.image, this.src);

  final ui.Image image;
  final Rect src;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / (_rodR - _rodL);
    canvas.drawImageRect(
      image,
      src,
      Rect.fromLTWH(-_rodL * s, 0, _artW * s, size.height),
      Paint()..filterQuality = FilterQuality.medium,
    );
  }

  @override
  bool shouldRepaint(_RodPainter old) => old.image != image || old.src != src;
}

/// El papel de la pintura en nueve partes: las esquinas quedan fijas y el
/// resto se estira al tamaño del texto.
class _PaperPainter extends CustomPainter {
  _PaperPainter(this.image, this.scale, {required this.sealed});

  final ui.Image image;
  final double scale;
  final bool sealed;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..filterQuality = FilterQuality.medium;
    // Lacrado: el papel un poco más tostado.
    if (sealed) {
      paint.colorFilter = const ColorFilter.mode(
        Color(0x268A6A3A),
        BlendMode.srcATop,
      );
    }
    const c = _paperCorner;
    final d = math.min(c * scale, size.height / 2);
    final sx = [_paper.left, _paper.left + c, _paper.right - c, _paper.right];
    final sy = [_paper.top, _paper.top + c, _paper.bottom - c, _paper.bottom];
    final dx = [0.0, d, size.width - d, size.width];
    final dy = [0.0, d, size.height - d, size.height];
    for (var i = 0; i < 3; i++) {
      for (var j = 0; j < 3; j++) {
        canvas.drawImageRect(
          image,
          Rect.fromLTRB(sx[i], sy[j], sx[i + 1], sy[j + 1]),
          Rect.fromLTRB(dx[i], dy[j], dx[i + 1], dy[j + 1]),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_PaperPainter old) =>
      old.image != image || old.scale != scale || old.sealed != sealed;
}

/// Un pergamino de la escuela: papel entre dos varillas. Lacrado (con el
/// sello rojo y la pista de cómo se abre) si todavía no se ganó.
class LoreScroll extends ConsumerWidget {
  const LoreScroll({
    super.key,
    required this.id,
    this.sealed = false,
    this.fresh = false,
    this.open = 1,
  });

  final String id;
  final bool sealed;

  /// Marca "nuevo" (se acaba de abrir en esta subida).
  final bool fresh;

  /// Cuánto está desenrollado (0..1), para animarlo al abrirse.
  final double open;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final number = loreOrder.indexOf(id) + 1;
    _loadArt();
    return ValueListenableBuilder(
      valueListenable: _art,
      builder: (context, image, _) => image == null
          ? _scroll(context, t, text, number, null, 0)
          : LayoutBuilder(
              builder: (context, box) => _scroll(
                context,
                t,
                text,
                number,
                image,
                box.maxWidth / (_rodR - _rodL),
              ),
            ),
    );
  }

  Widget _scroll(
    BuildContext context,
    AppLocalizations t,
    ContentText text,
    int number,
    ui.Image? image,
    double scale,
  ) {
    Widget rod(Rect src) => image != null
        ? SizedBox(
            width: double.infinity,
            height: src.height * scale,
            child: CustomPaint(painter: _RodPainter(image, src)),
          )
        : Container(
            height: 10,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFE2C28A), _rod],
              ),
              borderRadius: BorderRadius.circular(5),
              border: Border.all(color: _rodEdge),
            ),
          );
    final paperInset = (_paper.left - _rodL) * scale;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        rod(_topRod),
        ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: open.clamp(0.0, 1.0),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: image != null ? paperInset : 8,
              ),
              child: CustomPaint(
                painter: image == null
                    ? null
                    : _PaperPainter(image, scale, sealed: sealed),
                child: Container(
                  padding: image != null
                      ? const EdgeInsets.fromLTRB(20, 18, 20, 18)
                      : const EdgeInsets.fromLTRB(16, 12, 16, 14),
                  decoration: image != null
                      ? null
                      : BoxDecoration(
                          color: sealed
                              ? const Color(0xFFF1E8D6)
                              : Palette.surface,
                          border: const Border.symmetric(
                            vertical: BorderSide(color: Palette.line),
                          ),
                        ),
                  child: sealed
                      ? Row(
                          children: [
                            Container(
                              width: 34,
                              height: 34,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Palette.lacquer.withValues(alpha: 0.85),
                                shape: BoxShape.circle,
                              ),
                              child: const Text(
                                '封',
                                style: TextStyle(
                                  color: Palette.onColor,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '$number · ${t.scrollSealed}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Palette.textDim,
                                    ),
                                  ),
                                  Text(
                                    text.lore(id, 'hint'),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Palette.textDim,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // El último rollo trae la ilustración del maestro
                            // que entrega el pincel.
                            if (id == 'epilogue') ...[
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: AspectRatio(
                                  aspectRatio: 4 / 5,
                                  child: Image.asset(
                                    'assets/art/ui/epilogue_bg.webp',
                                    fit: BoxFit.cover,
                                    alignment: const Alignment(0, 0.1),
                                    errorBuilder: (_, _, _) => const SizedBox(),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                            ],
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    text.lore(id, 'title'),
                                    style: const TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                if (fresh)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Palette.gold,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      t.loreNew,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w800,
                                        color: Palette.onColor,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              text.lore(id, 'text'),
                              style: const TextStyle(
                                fontSize: 14.5,
                                height: 1.4,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
        rod(_bottomRod),
      ],
    );
  }
}
