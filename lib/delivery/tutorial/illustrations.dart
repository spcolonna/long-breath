import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/enums.dart';
import '../../l10n/app_localizations.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/card_widget.dart';
import 'tutorial_steps.dart';

/// Dibujo explicativo del maestro, armado con las mismas piezas que el juego
/// para que lo que se ve acá sea idéntico a lo que se ve en el combate.
class IllustrationView extends StatelessWidget {
  const IllustrationView(this.kind, {super.key});

  final Illustration kind;

  @override
  Widget build(BuildContext context) => switch (kind) {
    Illustration.card => const _CardAnatomy(),
    Illustration.intent => const _IntentLegend(),
    Illustration.heights => const _Heights(),
    Illustration.stances => const _StanceTable(),
    Illustration.turn => const _TurnOrder(),
    Illustration.broken => const _Broken(),
    Illustration.forms => const _FormSteps(),
  };
}

/// Todas las ilustraciones juntas, con título: la hoja "Cómo se juega".
class HowToPlay extends StatelessWidget {
  const HowToPlay({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget section(String title, Illustration kind) => Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: Palette.lacquer,
            ),
          ),
          const SizedBox(height: 8),
          IllustrationView(kind),
        ],
      ),
    );
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      children: [
        section(t.illTurnTitle, Illustration.turn),
        section(t.illCardTitle, Illustration.card),
        section(t.illIntentTitle, Illustration.intent),
        section(t.illHeightsTitle, Illustration.heights),
        section(t.illStancesTitle, Illustration.stances),
        section(t.illBrokenTitle, Illustration.broken),
        section(t.illFormsTitle, Illustration.forms),
      ],
    );
  }
}

const _small = TextStyle(fontSize: 12.5, height: 1.3, color: Palette.text);

class _Num extends StatelessWidget {
  const _Num(this.n, {this.color = Palette.gold});

  final int n;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: 18,
    height: 18,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: color,
      shape: BoxShape.circle,
      border: Border.all(color: Palette.surface, width: 1.5),
    ),
    child: Text(
      '$n',
      style: const TextStyle(
        fontSize: 10.5,
        height: 1,
        fontWeight: FontWeight.w800,
        color: Palette.onColor,
      ),
    ),
  );
}

/// Carta real con números sobre cada parte y la leyenda al costado.
class _CardAnatomy extends ConsumerWidget {
  const _CardAnatomy();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final def = ref.watch(dataProvider).card('gongbu_chongquan');
    const w = 104.0;
    const h = w * 1.5;
    // Altura relativa de cada parte de la carta (ver CardWidget); el costo se
    // marca a la izquierda y el resto sobre el borde derecho.
    const marks = [
      (1, 0.05, true),
      (2, 0.05, false),
      (3, 0.33, false),
      (4, 0.74, false),
      (5, 0.9, false),
    ];
    Widget label(String s) => Text(s, style: _small);
    final labels = [
      label(t.illCost),
      label(t.illType),
      label(t.illName),
      Wrap(
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          const Icon(Icons.bolt, size: 15, color: Palette.lacquer),
          Text('${t.illStatsDamage}  ', style: _small),
          const Icon(Icons.hexagon_outlined, size: 14, color: Palette.structure),
          Text(' ${t.illStatsStructure}', style: _small),
        ],
      ),
      label(t.illStance),
    ];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(
          width: w + 14,
          height: h + 6,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left: 7,
                top: 3,
                child: CardWidget(def: def, width: w),
              ),
              for (final (n, y, left) in marks)
                Positioned(
                  left: left ? 0 : w - 4,
                  top: 3 + y * h - 9,
                  child: _Num(n),
                ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final (i, l) in labels.indexed)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Num(i + 1),
                      const SizedBox(width: 6),
                      Expanded(child: l),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.lead, required this.text});

  final Widget lead;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(width: 30, child: Center(child: lead)),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: _small)),
      ],
    ),
  );
}

Widget _chipIcon(IconData icon, Color color) => Container(
  width: 26,
  height: 26,
  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  child: Icon(icon, size: 16, color: Palette.onColor),
);

class _IntentLegend extends StatelessWidget {
  const _IntentLegend();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Column(
      children: [
        _Row(
          lead: _chipIcon(heightIcon(Height.high), Palette.lacquer),
          text: t.illIntentAttack,
        ),
        _Row(
          lead: _chipIcon(Icons.shield, Palette.sky),
          text: t.illIntentGuard,
        ),
        _Row(
          lead: _chipIcon(Icons.bolt, Palette.gold),
          text: t.illIntentCharge,
        ),
        _Row(
          lead: _chipIcon(Icons.graphic_eq, Palette.structure),
          text: t.illIntentDiscard,
        ),
      ],
    );
  }
}

class _Heights extends StatelessWidget {
  const _Heights();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    Widget pair(Height attack, Height guard, bool ok) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(heightIcon(attack), size: 18, color: Palette.lacquer),
        const Text(
          ' vs ',
          style: TextStyle(fontSize: 11, color: Palette.textDim),
        ),
        Icon(
          Icons.shield,
          size: 16,
          color: ok ? Palette.jade : Palette.textDim,
        ),
        Icon(
          heightIcon(guard),
          size: 14,
          color: ok ? Palette.jade : Palette.textDim,
        ),
      ],
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (final h in Height.values) ...[
              Icon(heightIcon(h), size: 16, color: Palette.lacquer),
              Text(
                ' ${switch (h) {
                  Height.high => t.illHigh,
                  Height.mid => t.illMid,
                  Height.low => t.illLow,
                }}   ',
                style: _small,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            pair(Height.high, Height.high, true),
            const SizedBox(width: 8),
            Expanded(child: Text(t.illHeightsSame, style: _small)),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            pair(Height.mid, Height.low, false),
            const SizedBox(width: 8),
            Expanded(child: Text(t.illHeightsOther, style: _small)),
          ],
        ),
      ],
    );
  }
}

class _StanceTable extends ConsumerWidget {
  const _StanceTable();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final rows = [
      (Stance.mabu, '马步', t.illStanceMabuPro, t.illStanceMabuCon),
      (Stance.gongbu, '弓步', t.illStanceGongbuPro, t.illStanceGongbuCon),
      (Stance.xubu, '虚步', t.illStanceXubuPro, t.illStanceXubuCon),
    ];
    return Column(
      children: [
        for (final (s, hanzi, pro, con) in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 62,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text.stance(s),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        hanzi,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Palette.textDim,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _Line(
                        icon: Icons.add_circle,
                        color: Palette.jade,
                        text: pro,
                      ),
                      _Line(
                        icon: Icons.remove_circle,
                        color: Palette.lacquer,
                        text: con,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _Line extends StatelessWidget {
  const _Line({required this.icon, required this.color, required this.text});

  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 13, color: color),
        ),
        const SizedBox(width: 4),
        Expanded(child: Text(text, style: _small)),
      ],
    ),
  );
}

class _TurnOrder extends StatelessWidget {
  const _TurnOrder();

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final steps = [t.illTurn1, t.illTurn2, t.illTurn3, t.illTurn4];
    return Column(
      children: [
        for (final (i, s) in steps.indexed)
          _Row(
            lead: _Num(i + 1, color: i == 3 ? Palette.lacquer : Palette.jade),
            text: s,
          ),
      ],
    );
  }
}

class _Broken extends StatelessWidget {
  const _Broken();

  @override
  Widget build(BuildContext context) => _Row(
    lead: _chipIcon(Icons.auto_awesome, Palette.gold),
    text: AppLocalizations.of(context).illBroken,
  );
}

class _FormSteps extends ConsumerWidget {
  const _FormSteps();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final form = ref.watch(dataProvider).forms.first;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: 4,
          runSpacing: 4,
          children: [
            for (final (i, id) in form.steps.indexed) ...[
              if (i > 0)
                const Icon(
                  Icons.arrow_forward,
                  size: 13,
                  color: Palette.textDim,
                ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: Palette.gold.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Palette.gold),
                ),
                child: Text(
                  text.card(id),
                  style: const TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(t.illForms, style: _small),
      ],
    );
  }
}
