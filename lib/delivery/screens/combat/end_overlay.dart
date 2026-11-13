part of '../combat_screen.dart';

/// Cartel de un efecto importante: una franja de color entra barriendo, el
/// título salta y todo sale hacia el otro lado.
class _FxBanner extends StatelessWidget {
  const _FxBanner({super.key, required this.fx, required this.onDone});

  final _Fx fx;
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final ms = fx.duration;
    // Entrada y salida de duración fija; el resto es tiempo para leer.
    final inF = math.min(0.18, 260 / ms), outF = math.min(0.18, 260 / ms);
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: ms),
      onEnd: onDone,
      builder: (_, v, _) {
        final inT = Curves.easeOutCubic.transform(math.min(1, v / inF));
        final outT = v < 1 - outF
            ? 0.0
            : Curves.easeInCubic.transform((v - (1 - outF)) / outF);
        double popAt(double from) => v < from
            ? 0.6
            : 0.6 +
                  0.4 *
                      Curves.easeOutBack.transform(
                        math.min(1, (v - from) / (inF * 1.2)),
                      );
        final pop = popAt(inF * 0.5);
        // El detalle aparece un poco después del título, para leer en orden.
        final late = Curves.easeOut.transform(
          ((v - inF * 1.6) / inF).clamp(0.0, 1.0),
        );
        return Stack(
          children: [
            Positioned.fill(
              child: ColoredBox(
                color: Palette.surface.withValues(
                  alpha: (fx.detail != null ? 0.5 : 0.35) * inT * (1 - outT),
                ),
              ),
            ),
            Align(
              alignment: const Alignment(0, -0.2),
              child: Transform.translate(
                offset: Offset(-w * (1 - inT) + w * outT, 0),
                child: Transform(
                  transform: Matrix4.skewX(-0.12),
                  alignment: Alignment.center,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: fx.big ? 18 : 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          fx.color.withValues(alpha: 0),
                          fx.color.withValues(alpha: 0.95),
                          fx.color.withValues(alpha: 0.95),
                          fx.color.withValues(alpha: 0),
                        ],
                        stops: const [0, 0.15, 0.85, 1],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: fx.color.withValues(alpha: 0.35),
                          blurRadius: 24,
                        ),
                      ],
                    ),
                    child: Transform.scale(
                      scale: pop,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fx.header != null)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 4),
                              child: Text(
                                fx.header!.toUpperCase(),
                                style: TextStyle(
                                  fontSize: 13,
                                  letterSpacing: 2.5,
                                  fontWeight: FontWeight.w800,
                                  color: Palette.onColor.withValues(alpha: 0.85),
                                ),
                              ),
                            ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              fx.title,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: fx.big ? 44 : 34,
                                height: 1.05,
                                fontWeight: FontWeight.w900,
                                color: Palette.onColor,
                                shadows: [
                                  Shadow(
                                    color: fx.color.withValues(alpha: 0.9),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (fx.subtitle != null)
                            Text(
                              fx.subtitle!,
                              style: const TextStyle(
                                fontSize: 16,
                                color: Palette.onColor,
                              ),
                            ),
                          if (fx.detail != null && fx.detail!.isNotEmpty)
                            Opacity(
                              opacity: late,
                              child: Transform.translate(
                                offset: Offset(0, 8 * (1 - late)),
                                child: Container(
                                  margin: const EdgeInsets.only(top: 8),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Palette.onColor,
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Palette.gold,
                                      width: 2,
                                    ),
                                  ),
                                  child: Text(
                                    fx.detail!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: fx.color,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Cierre del combate. Victoria: rayos dorados, título que cae como un golpe
/// y el sello rojo 胜. Derrota: todo más lento, en gris, con el sello 败.
class _EndOverlay extends ConsumerStatefulWidget {
  const _EndOverlay({
    required this.won,
    required this.lessonId,
    required this.turns,
    required this.hp,
    required this.maxHp,
    required this.enemyName,
    required this.enemyHp,
    this.quote,
    this.fledWith,
    this.inset = EdgeInsets.zero,
  });

  /// Lo que la zona segura le quita: el velo lo recupera y llega a los bordes.
  final EdgeInsets inset;

  final bool won;

  /// Últimas palabras del jefe o la élite (o lo que dice si ganó).
  final String? quote;

  /// El enemigo se escapó con este jade (null si lo venciste).
  final int? fledWith;

  /// En una lección: botones para seguir, reintentar o volver a la lista.
  final String? lessonId;
  final int turns;
  final int hp;
  final int maxHp;
  final String enemyName;
  final int enemyHp;

  @override
  ConsumerState<_EndOverlay> createState() => _EndOverlayState();
}

class _EndOverlayState extends ConsumerState<_EndOverlay>
    with TickerProviderStateMixin {
  late final _c =
      AnimationController(
          vsync: this,
          duration: Duration(milliseconds: widget.won ? 1700 : 2100),
        )
        ..addListener(_onTick)
        ..forward();
  late final _loop = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 12),
  )..repeat();
  static const _sealAt = 0.52;
  bool _sealed = false;
  int _sealKey = 0;

  @override
  void initState() {
    super.initState();
    final id = widget.lessonId;
    if (id != null && widget.won) {
      ref.read(tutorialStorageProvider).markDone(id).then((_) {
        if (mounted) ref.invalidate(lessonsDoneProvider);
      });
    }
  }

  void _onTick() {
    if (!_sealed && _c.value >= _sealAt) {
      _sealed = true;
      Haptics.heavyImpact();
      ref
          .read(audioProvider)
          .play(widget.won ? Sfx.victoryStamp : Sfx.defeatStamp);
      if (widget.won) ref.read(audioProvider).play(Sfx.endRays);
      setState(() => _sealKey++);
    }
  }

  @override
  void dispose() {
    _c.dispose();
    _loop.dispose();
    super.dispose();
  }

  double _span(double a, double b, [Curve curve = Curves.linear]) =>
      curve.transform(((_c.value - a) / (b - a)).clamp(0.0, 1.0));

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final won = widget.won;
    final accent = won ? Palette.gold : Palette.lacquer;
    final seal = won
        ? Palette.lacquer
        : Color.lerp(Palette.lacquer, Palette.textDim, 0.55)!;
    final lesson = widget.lessonId == null
        ? null
        : lessonById(widget.lessonId!);
    final next = lesson == null ? null : nextLesson(lesson.id);
    final fled = widget.fledWith;
    final String summaryText = switch ((lesson, won)) {
      (null, true) when fled != null => t.endSummaryFled(
        widget.enemyName,
        fled,
      ),
      (null, true) => t.endSummaryWon(widget.turns, widget.hp, widget.maxHp),
      (null, false) => t.endSummaryLost(widget.enemyName, widget.enemyHp),
      (final l?, true) => l.done!(t),
      (_?, false) => t.lessonLostHint,
    };
    final (String label, VoidCallback onPressed) = switch ((lesson, won)) {
      (null, _) => (t.continueLabel, _continue),
      (_?, true) when next != null => (
        t.lessonNext,
        () => _openLesson(next.id),
      ),
      (_?, true) => (t.lessonBackToList, _toLessons),
      (final l?, false) => (t.lessonRetry, () => _openLesson(l.id)),
    };
    final secondary = lesson != null && !(won && next == null);
    return Positioned(
      left: -widget.inset.left,
      top: -widget.inset.top,
      right: -widget.inset.right,
      bottom: -widget.inset.bottom,
      child: AnimatedBuilder(
        animation: Listenable.merge([_c, _loop]),
        builder: (context, _) {
          final veil = _span(0, 0.25, Curves.easeOut);
          // El título cae desde grande, como un golpe sobre el papel.
          final title = _span(0.12, 0.4, Curves.easeInCubic);
          final settle = _span(0.4, 0.55, Curves.easeOutBack);
          final sealIn = _span(0.38, _sealAt, Curves.easeInCubic);
          final summary = _span(0.62, 0.82, Curves.easeOutCubic);
          final button = _span(0.78, 1, Curves.easeOutBack);
          return Container(
            color: Palette.surface.withValues(alpha: 0.9 * veil),
            alignment: Alignment.center,
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (won && fled == null)
                  Opacity(
                    opacity: veil,
                    child: Transform.rotate(
                      angle: _loop.value * math.pi * 2,
                      child: Transform.scale(
                        scale: 0.4 + 0.6 * _span(0.1, 0.5, Curves.easeOutCubic),
                        child: CustomPaint(
                          size: const Size(520, 520),
                          painter: _RaysPainter(),
                        ),
                      ),
                    ),
                  ),
                if (won && fled == null)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _PetalsPainter(t: _loop.value, fade: summary),
                    ),
                  ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        clipBehavior: Clip.none,
                        children: [
                          Opacity(
                            opacity: title,
                            child: Transform.scale(
                              scale:
                                  2.6 -
                                  1.6 * title +
                                  0.06 * math.sin(math.pi * settle),
                              child: Text(
                                fled != null
                                    ? t.fledTitle
                                    : won
                                    ? t.victory
                                    : t.defeat,
                                style: TextStyle(
                                  fontSize: 54, fontFamily: Fonts.display,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                  color: accent,
                                  shadows: [
                                    const Shadow(
                                      color: Colors.white,
                                      blurRadius: 12,
                                    ),
                                    Shadow(
                                      color: accent.withValues(alpha: 0.5),
                                      blurRadius: 24,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Sello de tinta roja, como el de un pergamino.
                          Positioned(
                            right: -62,
                            bottom: 10,
                            child: Opacity(
                              opacity: sealIn,
                              child: Transform.rotate(
                                angle: -0.12,
                                child: Transform.scale(
                                  scale: 3 - 2 * sealIn,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    alignment: Alignment.center,
                                    decoration: BoxDecoration(
                                      color: seal,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: Palette.onColor,
                                        width: 2,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: seal.withValues(alpha: 0.4),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Text(
                                      won ? '胜' : '败',
                                      style: const TextStyle(
                                        fontSize: 32, fontFamily: Fonts.display,
                                        height: 1,
                                        color: Palette.onColor,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: -102,
                            bottom: -30,
                            width: 136,
                            height: 136,
                            child: InkBurst(
                              trigger: _sealKey,
                              colors: [seal, accent],
                              count: 16,
                              radius: 70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Opacity(
                      opacity: summary,
                      child: Transform.translate(
                        offset: Offset(0, 16 * (1 - summary)),
                        child: Text(
                          summaryText,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            color: Palette.textDim,
                          ),
                        ),
                      ),
                    ),
                    if (widget.quote != null && fled == null)
                      Opacity(
                        opacity: summary,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(32, 12, 32, 0),
                          child: Text(
                            '«${widget.quote}»',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontStyle: FontStyle.italic,
                              color: Palette.text,
                            ),
                          ),
                        ),
                      ),
                    const SizedBox(height: 28),
                    Opacity(
                      opacity: button.clamp(0, 1),
                      child: Transform.scale(
                        scale: 0.8 + 0.2 * button,
                        child: IgnorePointer(
                          ignoring: button < 0.5,
                          child: SizedBox(
                            width: 220,
                            height: 52,
                            child: FilledButton(
                              onPressed: onPressed,
                              style: FilledButton.styleFrom(
                                backgroundColor: won
                                    ? Palette.gold
                                    : Palette.lacquer,
                              ),
                              child: Text(
                                label,
                                style: const TextStyle(fontSize: 17),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (secondary)
                      Opacity(
                        opacity: button.clamp(0, 1),
                        child: IgnorePointer(
                          ignoring: button < 0.5,
                          child: TextButton(
                            onPressed: _toLessons,
                            child: Text(
                              t.lessonBackToList,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Palette.text,
                                shadows: Palette.halo,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Abre una lección: las de combate reinician esta pantalla, la de la
  /// subida es otra pantalla.
  void _openLesson(String id) {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    final ctl = ref.read(combatControllerProvider.notifier)..finish();
    if (lessonById(id).isCombat) {
      ctl.startLesson(id);
    } else {
      context.go('/lessons/climb');
    }
  }

  void _toLessons() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    context.go('/lessons');
  }

  void _continue() {
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
    ref.read(combatControllerProvider.notifier).finish();
    final run = ref.read(runControllerProvider)!;
    context.go(switch (run.phase) {
      RunPhase.talisman => '/talisman',
      RunPhase.reward => '/reward',
      RunPhase.stageClear => '/stage',
      RunPhase.victory || RunPhase.defeat => '/result',
      _ => '/map',
    });
  }
}

class _RaysPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.width / 2;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          Palette.gold.withValues(alpha: 0.26),
          Palette.gold.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: c, radius: r));
    const n = 14;
    for (var i = 0; i < n; i++) {
      final a = i * 2 * math.pi / n;
      canvas.drawPath(
        Path()
          ..moveTo(c.dx, c.dy)
          ..lineTo(c.dx + math.cos(a - 0.09) * r, c.dy + math.sin(a - 0.09) * r)
          ..lineTo(c.dx + math.cos(a + 0.09) * r, c.dy + math.sin(a + 0.09) * r)
          ..close(),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_RaysPainter old) => false;
}

/// Pétalos dorados y bermellón que caen en loop detrás de la victoria.
class _PetalsPainter extends CustomPainter {
  _PetalsPainter({required this.t, required this.fade});

  final double t;
  final double fade;

  @override
  void paint(Canvas canvas, Size size) {
    if (fade == 0) return;
    final rnd = math.Random(7);
    for (var i = 0; i < 26; i++) {
      final x0 = rnd.nextDouble() * size.width;
      final speed = 0.6 + rnd.nextDouble() * 0.8;
      final phase = rnd.nextDouble();
      final y = ((t * 6 * speed + phase) % 1) * (size.height + 40) - 20;
      final x = x0 + math.sin((t * 12 + phase) * math.pi * 2) * 18;
      final color = i.isEven ? Palette.gold : Palette.lacquer;
      canvas.save();
      canvas.translate(x, y);
      canvas.rotate((t * 20 + phase) * math.pi * 2 * (i.isEven ? 1 : -1));
      canvas.drawOval(
        const Rect.fromLTWH(-5, -2.5, 10, 5),
        Paint()..color = color.withValues(alpha: 0.7 * fade),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_PetalsPainter old) => old.t != t || old.fade != fade;
}

/// Pausa: seguir, repasar las reglas o salir (la subida queda guardada).
class _PauseButton extends ConsumerWidget {
  const _PauseButton({required this.lessonId});

  final String? lessonId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    return Material(
      color: Palette.surface.withValues(alpha: 0.92),
      shape: const CircleBorder(side: BorderSide(color: Palette.line)),
      child: IconButton(
        tooltip: t.pauseTitle,
        visualDensity: VisualDensity.compact,
        icon: const Icon(Icons.pause_rounded, color: Palette.text),
        onPressed: () {
          Haptics.selectionClick();
          ref.read(audioProvider).play(Sfx.uiButton);
          _open(context, ref);
        },
      ),
    );
  }

  void _open(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final ctl = ref.read(combatControllerProvider.notifier);
    final lesson = lessonId;
    // El combate queda como está: el próximo que empiece lo reemplaza, y así
    // la pantalla no se vacía mientras se desvanece.
    void leave(String route) {
      Navigator.pop(context);
      ref.invalidate(savedRunProvider);
      context.go(route);
    }

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Palette.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.pauseTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 14),
              SizedBox(
                height: 50,
                child: FilledButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(
                    t.pauseResume,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => showModalBottomSheet<void>(
                  context: ctx,
                  isScrollControlled: true,
                  backgroundColor: Palette.surface,
                  builder: (_) => DraggableScrollableSheet(
                    expand: false,
                    initialChildSize: 0.85,
                    maxChildSize: 0.95,
                    builder: (_, scroll) => PrimaryScrollController(
                      controller: scroll,
                      child: const HowToPlay(),
                    ),
                  ),
                ),
                icon: const Icon(Icons.menu_book_rounded),
                label: Text(t.pauseHowTo),
              ),
              const SizedBox(height: 8),
              if (lesson == null) ...[
                OutlinedButton.icon(
                  onPressed: () => leave('/school'),
                  icon: const Icon(Icons.home_rounded),
                  label: Text(t.pauseToMenu),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                  child: Text(
                    t.pauseToMenuHint,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                ),
              ] else ...[
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ctl.startLesson(lesson);
                  },
                  icon: const Icon(Icons.replay_rounded),
                  label: Text(t.pauseRestartLesson),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () => leave('/lessons'),
                  icon: const Icon(Icons.school_rounded),
                  label: Text(t.pauseExitLesson),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
