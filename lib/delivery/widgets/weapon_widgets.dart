import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../feel.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import 'juice.dart';
import 'press.dart';
import 'weapon_art.dart';

/// Insignia del arma: su carácter en un sello cuadrado con el borde del
/// color del nivel y una marca por nivel.
class WeaponBadge extends ConsumerWidget {
  const WeaponBadge({
    super.key,
    required this.id,
    required this.level,
    this.size = 34,
    this.trigger,
  });

  final String id;
  final int level;
  final double size;

  /// Rebota cada vez que cambia (cuando el arma actúa).
  final Object? trigger;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final def = ref.watch(dataProvider).weapon(id);
    final color = weaponColor(level);
    return Bounce(
      trigger: trigger,
      scale: 1.4,
      child: SizedBox(
        width: size,
        height: size,
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Container(
              width: size,
              height: size,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(size * 0.22),
                border: Border.all(color: color, width: size > 40 ? 3 : 2),
                boxShadow: [
                  BoxShadow(
                    color: color.withValues(alpha: level >= 3 ? 0.6 : 0.3),
                    blurRadius: level >= 3 ? 10 : 4,
                  ),
                ],
              ),
              child: FittedBox(
                child: Padding(
                  padding: EdgeInsets.all(size * 0.12),
                  child: Text(
                    def.hanzi,
                    style: TextStyle(
                      fontSize: size * 0.5,
                      height: 1,
                      fontWeight: FontWeight.w700,
                      color: Palette.text,
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: -size * 0.12,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var i = 0; i < level; i++)
                    Container(
                      width: size * 0.16,
                      height: size * 0.16,
                      margin: EdgeInsets.symmetric(horizontal: size * 0.03),
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                        border: Border.all(color: Palette.surface, width: 1),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// El arma de la subida (o el aviso de que no hay); al tocarla, qué hace.
class WeaponChip extends StatelessWidget {
  const WeaponChip({
    super.key,
    required this.id,
    required this.level,
    required this.style,
    this.size = 28,
    this.trigger,
  });

  final String? id;
  final int level;
  final Style? style;
  final double size;
  final Object? trigger;

  @override
  Widget build(BuildContext context) {
    final id = this.id;
    if (id == null) return const SizedBox.shrink();
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Haptics.tap();
        showWeaponSheet(context, id: id, level: level, style: style);
      },
      child: Padding(
        padding: EdgeInsets.only(bottom: size * 0.12),
        child: WeaponBadge(id: id, level: level, size: size, trigger: trigger),
      ),
    );
  }
}

/// Hoja con el arma: imagen, nivel, efecto y técnicas.
void showWeaponSheet(
  BuildContext context, {
  required String id,
  required int level,
  required Style? style,
}) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Palette.surface,
    showDragHandle: true,
    builder: (_) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: WeaponTile(id: id, level: level, style: style),
      ),
    ),
  );
}

/// Arma con su dibujo, nombre, nivel, efecto, técnicas y afinidad. Con
/// [from] muestra el templado (nivel [from] → [level]).
class WeaponTile extends ConsumerWidget {
  const WeaponTile({
    super.key,
    required this.id,
    required this.level,
    required this.style,
    this.from,
    this.artHeight = 120,
    this.showcase = false,
  });

  final String id;
  final int level;
  final Style? style;
  final int? from;
  final double artHeight;

  /// En una caja, cruzada y más grande (la vitrina del mercader).
  final bool showcase;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final def = ref.watch(dataProvider).weapon(id);
    final effect = def.levels[level - 1].effect;
    final affine = style != null && def.path == style;
    final cards = def.cardsUpTo(level);
    final fresh = from == null ? cards : def.levels[level - 1].cards;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (showcase)
          // En la vitrina: el arma cruzada en su caja, grande y a la vista.
          Container(
            width: artHeight * 1.05,
            height: artHeight * 1.25,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: RadialGradient(colors: [
                Colors.white,
                weaponColor(level).withValues(alpha: 0.18),
              ]),
              border: Border.all(
                color: weaponColor(level).withValues(alpha: 0.6),
                width: 2,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: OverflowBox(
                maxHeight: artHeight * 2,
                maxWidth: artHeight * 2,
                child: Transform.rotate(
                  angle: 0.62,
                  child: WeaponArt(
                    id: id,
                    level: level,
                    height: artHeight * 1.5,
                  ),
                ),
              ),
            ),
          )
        else
          WeaponArt(id: id, level: level, height: artHeight),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      '${text.weapon(id)}  ${def.hanzi}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  _LevelTag(
                    label: from == null
                        ? t.weaponLevel(level)
                        : t.weaponLevelUp(from!, level),
                    color: weaponColor(level),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                text.weaponText(id),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontStyle: FontStyle.italic,
                  color: Palette.textDim,
                ),
              ),
              const SizedBox(height: 6),
              if (t.talismanEffect(effect, text).isNotEmpty)
                Text(t.talismanEffect(effect, text)),
              if (fresh.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    t.weaponCards(fresh.map(text.card).join(', ')),
                    style: const TextStyle(fontSize: 13),
                  ),
                ),
              if (def.path != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    '${affine ? '★ ' : ''}${text.style(def.path!)}: '
                    '${t.talismanEffect(def.pathBonus, text)}',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: affine ? FontWeight.w700 : FontWeight.w400,
                      color: affine ? styleColor(def.path) : Palette.textDim,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _LevelTag extends StatelessWidget {
  const _LevelTag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.15),
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: color),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: color),
    ),
  );
}

/// Elegir un arma (o templar la propia, si es la única opción): entran de a
/// una, la elegida brilla y, al confirmar, estalla antes de [onChosen].
class WeaponChoice extends ConsumerStatefulWidget {
  const WeaponChoice({
    super.key,
    required this.options,
    required this.onChosen,
    this.top,
  });

  final List<String> options;
  final ValueChanged<String> onChosen;

  /// Algo arriba del título (el sello del botín).
  final Widget? top;

  @override
  ConsumerState<WeaponChoice> createState() => _WeaponChoiceState();
}

class _WeaponChoiceState extends ConsumerState<WeaponChoice> {
  String? _picked;
  bool _taking = false;
  int _burst = 0;

  @override
  void initState() {
    super.initState();
    // Templar no es elegir: la única opción ya viene marcada.
    if (widget.options.length == 1) _picked = widget.options.first;
  }

  void _select(String id) {
    if (_taking) return;
    Haptics.selectionClick();
    ref.read(audioProvider).play(Sfx.cardSelect);
    setState(() => _picked = id);
  }

  void _take() {
    final id = _picked;
    if (id == null || _taking) return;
    Haptics.heavyImpact();
    ref.read(audioProvider).play(Sfx.rewardTake);
    setState(() {
      _taking = true;
      _burst++;
    });
    Future.delayed(const Duration(milliseconds: 1100), () {
      if (!mounted) return;
      widget.onChosen(id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final run = ref.watch(runControllerProvider);
    final style = run?.style;
    final current = run?.weapon;
    final forging = current != null && widget.options.contains(current);
    final level = run?.weaponLevel ?? 0;
    return Column(
      children: [
        ?widget.top,
        const SizedBox(height: 24),
        Text(
          forging ? t.weaponForgeTitle : t.weaponPickTitle,
          style: const TextStyle(fontSize: 26, fontFamily: Fonts.display),
        ),
        const SizedBox(height: 6),
        Text(
          forging ? t.weaponForgeHint : t.weaponPickHint,
          textAlign: TextAlign.center,
          style: const TextStyle(color: Palette.textDim),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            children: [
              for (final (i, id) in widget.options.indexed)
                StaggerIn(
                  index: i,
                  delay: const Duration(milliseconds: 150),
                  step: const Duration(milliseconds: 160),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Press(
                      child: GestureDetector(
                        onTap: () => _select(id),
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            _Option(
                              picked: _picked == id,
                              dimmed: _picked != null && _picked != id,
                              taking: _taking && _picked == id,
                              child: WeaponTile(
                                id: id,
                                level: forging ? level + 1 : 1,
                                from: forging ? level : null,
                                style: style,
                                artHeight: 108,
                              ),
                            ),
                            Positioned.fill(
                              child: InkBurst(
                                trigger: _picked == id ? _burst : 0,
                                colors: [
                                  weaponColor(forging ? level + 1 : 1),
                                  Palette.gold,
                                  Colors.white,
                                ],
                                count: 36,
                                radius: 160,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        SizedBox(
          height: 40,
          child: _taking && _picked != null
              ? Bounce(
                  trigger: _burst,
                  scale: 1.25,
                  child: Text(
                    forging
                        ? t.weaponForged(text.weapon(_picked!), level + 1)
                        : t.weaponGained(text.weapon(_picked!)),
                    style: const TextStyle(
                      fontSize: 20, fontFamily: Fonts.display,
                      fontWeight: FontWeight.w700,
                      color: Palette.lacquer,
                    ),
                  ),
                )
              : null,
        ),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: _picked == null || _taking ? null : _take,
            child: Text(forging ? t.lootTemper : t.confirm),
          ),
        ),
      ],
    );
  }
}

/// Tarjeta de una opción: la elegida sube y brilla, las otras se apagan.
class _Option extends StatelessWidget {
  const _Option({
    required this.picked,
    required this.dimmed,
    required this.taking,
    required this.child,
  });

  final bool picked;
  final bool dimmed;
  final bool taking;
  final Widget child;

  @override
  Widget build(BuildContext context) => AnimatedScale(
    scale: taking ? 1.04 : (picked ? 1.02 : (dimmed ? 0.97 : 1)),
    duration: const Duration(milliseconds: 240),
    curve: Curves.easeOutBack,
    child: AnimatedOpacity(
      opacity: dimmed ? (taking ? 0 : 0.55) : 1,
      duration: const Duration(milliseconds: 220),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Palette.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: picked ? Palette.lacquer : Palette.line,
            width: picked ? 3 : 1.5,
          ),
          boxShadow: picked
              ? [
                  BoxShadow(
                    color: Palette.gold.withValues(alpha: 0.45),
                    blurRadius: 14,
                  ),
                ]
              : null,
        ),
        child: child,
      ),
    ),
  );
}
