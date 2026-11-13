part of '../combat_screen.dart';

// -------------------------------------------------------------------- arena

class _EnemySlot {
  const _EnemySlot({
    required this.def,
    required this.enemy,
    required this.intent,
    required this.foe,
    required this.onTap,
    this.wave = 0,
    this.waveCount = 1,
    this.reserve = const [],
    this.index = 0,
    this.pair = false,
    this.targeted = true,
    this.anyChips = false,
  });

  final EnemyDef def;
  final EnemyCombat enemy;

  /// Alguno de los que están en escena muestra estados: con dos, el otro
  /// guarda ese lugar para que las placas queden a la misma altura.
  final bool anyChips;
  final IntentView intent;

  /// Lugar en el grupo (0 = el primero) y cuántos son.
  final int wave;
  final int waveCount;

  /// Los que esperan su turno (se muestran en miniatura).
  final List<EnemyDef> reserve;

  /// Sus animaciones (y la marca de dónde está la figura).
  final _FoeFx foe;

  /// Su lugar en escena; con [pair] hay dos a la vez y [targeted] dice si
  /// las cartas van a él.
  final int index;
  final bool pair;
  final bool targeted;
  final VoidCallback onTap;
}

/// Escenario del combate: fondo de la etapa, suelo, los enemigos al frente y
/// el héroe de espaldas en primer plano.
class _Arena extends StatelessWidget {
  const _Arena({
    required this.stageId,
    required this.scene,
    required this.light,
    required this.turn,
    required this.style,
    required this.talismans,
    this.weapon,
    this.weaponLevel = 0,
    required this.fx,
    required this.heroKey,
    required this.introTitle,
    required this.slots,
    this.room,
  });

  final String stageId;

  /// En una estancia, «Sala 2/3» (null en un combate suelto).
  final String? room;

  /// Escenario y luz del camino (null en las lecciones: la terraza al alba).
  final String? scene;
  final String? light;
  final int turn;
  final Style? style;
  final List<String> talismans;
  final String? weapon;
  final int weaponLevel;
  final _ArenaFx fx;
  final GlobalKey heroKey;
  final String introTitle;
  final List<_EnemySlot> slots;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    // Dentro del SafeArea el padding ya es 0: se mide el de la pantalla.
    final top = MediaQueryData.fromView(View.of(context)).padding.top;
    return LayoutBuilder(
      builder: (context, box) {
        final heroH = math.min(box.maxHeight * 0.62, box.maxWidth * 0.54);
        final heroW = heroH * 2 / 3;
        final heroLeft = -heroW * 0.12;
        final heroBottom = -heroH * 0.12;
        // El escenario sigue debajo de la mano y llega hasta el borde de
        // arriba: los paneles de abajo lo tapan con papel de a poco.
        final sceneH = top + box.maxHeight * 1.55;
        return Stack(
          fit: StackFit.expand,
          clipBehavior: Clip.none,
          children: [
            Positioned(
              top: -top,
              left: 0,
              right: 0,
              height: sceneH,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  StageScene(stageId: stageId, scene: scene, light: light),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Palette.bg.withValues(alpha: 0),
                          Palette.bg.withValues(alpha: 0),
                          Palette.bg.withValues(alpha: 0.78),
                          Palette.bg,
                        ],
                        stops: [
                          0,
                          (top + box.maxHeight * 0.86) / sceneH,
                          (top + box.maxHeight * 1.04) / sceneH,
                          1,
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          // Suelo.
          Align(
            alignment: const Alignment(0, 0.62),
            child: FractionallySizedBox(
              widthFactor: 0.75,
              child: Container(
                height: 34,
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(
                    Radius.elliptical(200, 34),
                  ),
                  gradient: RadialGradient(
                    colors: [
                      Palette.text.withValues(alpha: 0.22),
                      Palette.text.withValues(alpha: 0),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(heroW * 0.8, 8, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (final slot in slots)
                  Expanded(
                    child: _EnemyStage(slot: slot, fx: fx),
                  ),
              ],
            ),
          ),
          // Héroe de espaldas, cortado por el borde inferior.
          Positioned(
            left: heroLeft,
            bottom: heroBottom,
            child: IgnorePointer(
              // Entra desde la izquierda al empezar el combate.
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: 1),
                duration: const Duration(milliseconds: 650),
                curve: Curves.easeOutCubic,
                builder: (_, v, child) => Opacity(
                  opacity: v.clamp(0, 1),
                  child: Transform.translate(
                    offset: Offset(-heroW * 0.7 * (1 - v), heroH * 0.06 * (1 - v)),
                    child: child,
                  ),
                ),
                child: HeroSprite(
                  key: heroKey,
                  style: style,
                  height: heroH,
                  strikeKey: fx.strikeKey,
                  hurtKey: fx.hurtKey,
                  guardKey: fx.guardKey,
                  victory: fx.victory,
                  defeated: fx.defeated,
                  weapon: weapon,
                  weaponLevel: weaponLevel,
                ),
              ),
            ),
          ),
          // Desvío: destello de jade sobre el héroe.
          Positioned(
            left: heroLeft,
            bottom: heroBottom + heroH * 0.25,
            width: heroW,
            height: heroH * 0.6,
            child: InkBurst(
              trigger: fx.deflectKey,
              colors: const [Palette.jade, Palette.sky, Colors.white],
              count: 18,
              radius: heroW * 0.6,
            ),
          ),
          // Aliento o vida que vuelve: un remolino detrás del héroe.
          Positioned(
            left: heroLeft - heroW * 0.15,
            bottom: heroBottom + heroH * 0.1,
            width: heroW * 1.3,
            height: heroW * 1.3,
            child: ArtBurst(
              trigger: fx.qiKey,
              asset: 'assets/art/vfx/qi_swirl.webp',
              size: heroW * 1.3,
              duration: const Duration(milliseconds: 900),
              from: 0.4,
              to: 1,
              spin: 2.4,
              hold: 0.4,
            ),
          ),
          // Números sobre el héroe.
          Positioned(
            left: heroLeft + heroW * 0.62,
            bottom: heroBottom + heroH * 0.62,
            child: IgnorePointer(child: _PopStack(pops: fx.heroPops)),
          ),
          // Turno, camino y talismanes: encima de todo, para que su
          // globo de ayuda no quede tapado por el héroe ni el rival.
          Positioned(
            left: 12,
            top: 8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TutorialAnchor(
                  id: 'turn',
                  child: Bounce(
                    trigger: turn,
                    child: _Chip(
                      icon: Icons.hourglass_bottom,
                      text: t.turn(turn),
                      color: Palette.text,
                    ),
                  ),
                ),
                if (room != null) ...[
                  const SizedBox(height: 6),
                  _Chip(
                    icon: Icons.landscape_rounded,
                    text: room!,
                    color: Palette.text,
                  ),
                ],
                if (style != null) ...[
                  const SizedBox(height: 6),
                  _StyleChip(style: style!),
                ],
                if (weapon != null) ...[
                  const SizedBox(height: 6),
                  WeaponChip(
                    id: weapon,
                    level: weaponLevel,
                    style: style,
                    size: 26,
                    trigger: fx.weaponHits,
                  ),
                ],
                if (talismans.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 100,
                    child: TalismanRow(
                      ids: talismans,
                      size: 26,
                      triggers: fx.talismanHits,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: fx.turnKey == 0
                  ? _Ribbon(
                      title: introTitle,
                      subtitle: room ?? t.fightStart,
                      delayMs: 250,
                    )
                  : _Ribbon(
                      key: ValueKey(fx.turnKey),
                      title: t.yourTurn,
                      subtitle: t.turn(turn),
                    ),
            ),
          ),
          ],
        );
      },
    );
  }
}

/// Números en vuelo, cada uno con su desplazamiento.
class _PopStack extends StatelessWidget {
  const _PopStack({required this.pops});

  final List<_Pop> pops;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0,
      height: 0,
      child: OverflowBox(
        maxWidth: 240,
        maxHeight: 200,
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            for (final p in pops)
              Transform.translate(
                key: ValueKey(p.id),
                offset: Offset(p.dx, p.dy),
                child: PopText(
                  text: p.text,
                  color: p.color,
                  size: p.size,
                  icon: p.icon,
                  heavy: p.heavy,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Cartel que cruza la arena: presentación del enemigo o "Tu turno".
class _Ribbon extends StatefulWidget {
  const _Ribbon({
    super.key,
    required this.title,
    required this.subtitle,
    this.delayMs = 0,
  });

  final String title;
  final String subtitle;
  final int delayMs;

  @override
  State<_Ribbon> createState() => _RibbonState();
}

class _RibbonState extends State<_Ribbon> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: Duration(milliseconds: 1250 + widget.delayMs),
  )..forward();

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final start = widget.delayMs / (1250 + widget.delayMs);
    return AnimatedBuilder(
      animation: _c,
      builder: (context, _) {
        final raw = _c.value;
        if (raw <= start || raw >= 1) return const SizedBox();
        final v = (raw - start) / (1 - start);
        final w = MediaQuery.sizeOf(context).width;
        final inT = Curves.easeOutCubic.transform(math.min(1, v / 0.22));
        final outT = v < 0.8
            ? 0.0
            : Curves.easeInCubic.transform((v - 0.8) / 0.2);
        final dx = -w * (1 - inT) + w * outT;
        return Align(
          alignment: const Alignment(0, -0.05),
          child: Transform.translate(
            offset: Offset(dx, 0),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Palette.surface.withValues(alpha: 0),
                    Palette.surface.withValues(alpha: 0.94),
                    Palette.surface.withValues(alpha: 0.94),
                    Palette.surface.withValues(alpha: 0),
                  ],
                  stops: const [0, 0.2, 0.8, 1],
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 24, fontFamily: Fonts.display,
                      fontWeight: FontWeight.w800,
                      color: Palette.lacquer,
                    ),
                  ),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Palette.textDim,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
