import 'package:flutter/material.dart';

import '../../domain/model/enemy_def.dart';
import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../feel.dart';
import '../theme.dart';
import 'enemy_sprite.dart';
import 'game_icon.dart';
import 'lore_scroll.dart';
import 'lotus.dart';

/// Lo que el pergamino cuenta de un rival en combate.
class EnemyScrollInfo {
  const EnemyScrollInfo({
    required this.def,
    required this.name,
    required this.rule,
    required this.hp,
    required this.maxHp,
    required this.structure,
    required this.maxStructure,
    this.scales = 0,
    this.quote,
    this.intentIcon,
    this.intentTitle,
    this.intentDetail,
    this.intentNotes = const [],
  });

  final EnemyDef def;
  final String name;
  final String rule;
  final int hp, maxHp, structure, maxStructure, scales;

  /// Lo que dice al presentarse (jefes y élites), si tiene.
  final String? quote;

  /// Lo que prepara este turno (null si ya cayó).
  final IconData? intentIcon;
  final String? intentTitle;
  final String? intentDetail;

  /// Las reglas extra del golpe, explicadas enteras.
  final List<String> intentNotes;
}

/// Ficha del rival en un pergamino que se desenrolla, como el del inicio de
/// la subida (no un diálogo genérico).
Future<void> showEnemyScroll(BuildContext context, EnemyScrollInfo info) {
  Haptics.lightImpact();
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: info.name,
    barrierColor: const Color(0x66F6EEDC),
    transitionDuration: const Duration(milliseconds: 520),
    pageBuilder: (context, _, _) => Material(
      type: MaterialType.transparency,
      child: DefaultTextStyle.merge(
        style: const TextStyle(color: Palette.text),
        child: _EnemyScroll(info: info),
      ),
    ),
    transitionBuilder: (context, a, _, child) => FadeTransition(
      opacity: CurvedAnimation(parent: a, curve: const Interval(0, 0.4)),
      child: child,
    ),
  );
}

class _EnemyScroll extends StatelessWidget {
  const _EnemyScroll({required this.info});

  final EnemyScrollInfo info;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final def = info.def;
    final accent = rankColor(def.rank);
    final open = ModalRoute.of(context)!.animation!;
    final rank = switch (def.rank) {
      EnemyRank.common => t.rankCommon,
      EnemyRank.elite => t.rankElite,
      EnemyRank.boss => t.rankBoss,
    };
    return SafeArea(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: AnimatedBuilder(
              animation: open,
              builder: (context, child) => ScrollFrame(
                open: Curves.easeOutCubic.transform(
                  ((open.value - 0.1) / 0.9).clamp(0.0, 1.0),
                ),
                child: child!,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(context).height * 0.62,
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          SizedBox(
                            width: 92,
                            height: 92,
                            child: EnemySprite(
                              def: def,
                              staggered: false,
                              hitKey: 0,
                              attackKey: 0,
                              size: 92,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  info.name,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    height: 1.15,
                                  ),
                                ),
                                if (def.hanzi != null)
                                  Text(
                                    '${def.hanzi}'
                                    '${def.pinyin == null ? '' : ' · ${def.pinyin}'}',
                                    style: TextStyle(
                                      fontSize: 15,
                                      color: accent,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: accent,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    rank,
                                    style: const TextStyle(
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w800,
                                      color: Palette.onColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 8,
                        runSpacing: 6,
                        children: [
                          _Stat(
                            icon: Icons.favorite,
                            color: Palette.lacquer,
                            label: t.enemyInfoHp,
                            value: '${info.hp}/${info.maxHp}',
                          ),
                          _Stat(
                            icon: Icons.hexagon_outlined,
                            color: Palette.structure,
                            label: t.enemyInfoStructure,
                            value: '${info.structure}/${info.maxStructure}',
                          ),
                          if (info.scales > 0)
                            _Stat(
                              icon: Icons.layers,
                              color: Palette.jade,
                              label: t.enemyInfoScales,
                              value: '${info.scales}',
                            ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      _Heading(t.enemyInfoRule, accent),
                      const SizedBox(height: 4),
                      Text(
                        info.rule,
                        style: const TextStyle(fontSize: 15.5, height: 1.4),
                      ),
                      if (info.intentTitle != null) ...[
                        const SizedBox(height: 14),
                        _Heading(t.enemyInfoNow, Palette.lacquer),
                        const SizedBox(height: 6),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 30,
                              height: 30,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: Palette.lacquer,
                              ),
                              child: GameIcon(
                                info.intentIcon ?? Icons.bolt,
                                size: 19,
                                color: Palette.onColor,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    info.intentTitle!,
                                    style: const TextStyle(
                                      fontSize: 15.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  if (info.intentDetail != null)
                                    Text(
                                      info.intentDetail!,
                                      style: const TextStyle(
                                        fontSize: 14.5,
                                        fontWeight: FontWeight.w700,
                                        color: Palette.lacquer,
                                      ),
                                    ),
                                  for (final n in info.intentNotes)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 3),
                                      child: Text(
                                        '· $n',
                                        style: const TextStyle(
                                          fontSize: 14.5,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                      if (info.quote != null) ...[
                        const SizedBox(height: 14),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            InkSeal(hanzi: '言', color: accent, size: 30),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '«${info.quote}»',
                                style: const TextStyle(
                                  fontSize: 14.5,
                                  height: 1.4,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      Center(
                        child: Text(
                          t.enemyInfoClose,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Palette.textDim,
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
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(width: 4, height: 16, color: color),
      const SizedBox(width: 8),
      Text(
        text,
        style: TextStyle(
          fontSize: 13.5,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.6,
          color: color,
        ),
      ),
    ],
  );
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color color;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.10),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: color.withValues(alpha: 0.4)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GameIcon(icon, size: 16, color: color),
        const SizedBox(width: 6),
        Text(
          '$label ',
          style: const TextStyle(fontSize: 13.5, color: Palette.text),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
      ],
    ),
  );
}
