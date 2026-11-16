import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/model/card_def.dart';
import '../../l10n/app_localizations.dart';
import '../feel.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import 'card_widget.dart';
import 'paper_panel.dart';

/// Palabras del juego que se pueden tocar para leer qué significan.
enum Term {
  guard('守'),
  height('高'),
  deflect('化'),
  structure('架'),
  staggered('乱'),
  breath('气'),
  breathe('息'),
  stance('势'),
  dingbu('丁'),
  chain('连'),
  circle('圆'),
  retain('留'),
  exhaust('尽'),
  form('套'),
  thorns('刺'),
  regen('愈'),
  wrath('怒'),
  parry('扇'),
  steal('盗'),
  scales('鳞');

  const Term(this.hanzi);
  final String hanzi;

  /// Términos que conviene leer después de este.
  List<Term> get related => switch (this) {
    guard => const [height, deflect],
    height => const [guard, deflect],
    deflect => const [guard, height, structure],
    structure => const [staggered],
    staggered => const [structure],
    breath => const [breathe, dingbu],
    breathe => const [breath],
    stance => const [dingbu, chain],
    dingbu => const [stance],
    chain => const [stance, circle],
    circle => const [chain, stance],
    retain => const [],
    exhaust => const [],
    form => const [],
    thorns || regen || wrath || parry || scales => const [staggered],
    steal => const [],
  };
}

extension GlossaryLabels on AppLocalizations {
  String termTitle(Term t, {required String dingbu}) => switch (t) {
    Term.guard => guard,
    Term.height => termHeight,
    Term.deflect => termDeflect,
    Term.structure => structure,
    Term.staggered => termStaggered,
    Term.breath => breath,
    Term.breathe => breathe,
    Term.stance => termStance,
    Term.dingbu => dingbu,
    Term.chain => termChain,
    Term.circle => termCircle,
    Term.retain => termRetain,
    Term.exhaust => termExhaust,
    Term.form => termForm,
    Term.thorns => termThorns,
    Term.regen => termRegen,
    Term.wrath => termWrath,
    Term.parry => termParry,
    Term.steal => termSteal,
    Term.scales => termScales,
  };

  String termBody(Term t) => switch (t) {
    Term.guard => glossGuard,
    Term.height => glossHeight,
    Term.deflect => glossDeflect,
    Term.structure => glossStructure,
    Term.staggered => glossStaggered,
    Term.breath => glossBreath,
    Term.breathe => glossBreathe,
    Term.stance => glossStance,
    Term.dingbu => glossDingbu,
    Term.chain => glossChain,
    Term.circle => glossCircle,
    Term.retain => glossRetain,
    Term.exhaust => glossExhaust,
    Term.form => glossForm,
    Term.thorns => glossThorns,
    Term.regen => glossRegen,
    Term.wrath => glossWrath,
    Term.parry => glossParry,
    Term.steal => glossSteal,
    Term.scales => glossScales,
  };
}

/// Cómo aparece cada término dentro de un texto en castellano. El orden
/// importa: «Paso en T» antes que «postura», «Desequilibrado» antes que nada.
/// Al traducir el juego, cada idioma necesita su propia tabla.
const _patterns = <Term, String>{
  Term.dingbu: r'paso en t',
  Term.staggered: r'desequilibr\p{L}*',
  Term.deflect: r'desv[ií]\p{L}*',
  Term.guard: r'guardia',
  Term.structure: r'estructura',
  Term.breathe: r'respirar',
  Term.breath: r'aliento',
  Term.stance: r'posturas?',
  Term.circle: r'c[ií]rculo',
  Term.chain: r'encadena\p{L}*',
  Term.retain: r'reten\p{L}*|retuviste',
  Term.exhaust: r'agotar',
  Term.form: r'formas?',
  Term.height: r'altura',
};

final _matcher = RegExp(
  r'(?<!\p{L})(?:' +
      _patterns.values.map((p) => '($p)').join('|') +
      r')(?!\p{L})',
  caseSensitive: false,
  unicode: true,
);

/// Parte [text] en tramos: texto suelto y términos del glosario.
List<(String, Term?)> splitTerms(String text, {Set<Term> skip = const {}}) {
  final terms = _patterns.keys.toList();
  final out = <(String, Term?)>[];
  var at = 0;
  for (final m in _matcher.allMatches(text)) {
    var term = terms.first;
    for (var g = 1; g <= terms.length; g++) {
      if (m.group(g) != null) {
        term = terms[g - 1];
        break;
      }
    }
    if (skip.contains(term)) continue;
    if (m.start > at) out.add((text.substring(at, m.start), null));
    out.add((m.group(0)!, term));
    at = m.end;
  }
  if (at < text.length) out.add((text.substring(at), null));
  return out;
}

/// Texto con las palabras del glosario subrayadas en oro punteado: tocarlas
/// abre su explicación.
class GlossaryText extends StatefulWidget {
  const GlossaryText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.skip = const {},
    this.onTerm,
  });

  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final int? maxLines;

  /// Términos que no se marcan (el que se está explicando).
  final Set<Term> skip;

  /// Qué hacer al tocar un término; por defecto abre el glosario.
  final void Function(Term)? onTerm;

  @override
  State<GlossaryText> createState() => _GlossaryTextState();
}

class _GlossaryTextState extends State<GlossaryText> {
  final _recognizers = <TapGestureRecognizer>[];

  void _clear() {
    for (final r in _recognizers) {
      r.dispose();
    }
    _recognizers.clear();
  }

  @override
  void dispose() {
    _clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _clear();
    final open = widget.onTerm ?? (t) => showGlossary(context, t);
    final spans = [
      for (final (s, term) in splitTerms(widget.text, skip: widget.skip))
        if (term == null)
          TextSpan(text: s)
        else
          TextSpan(
            text: s,
            style: const TextStyle(
              decoration: TextDecoration.underline,
              decorationStyle: TextDecorationStyle.dotted,
              decorationColor: Palette.gold,
              decorationThickness: 2,
            ),
            recognizer: (TapGestureRecognizer()
              ..onTap = () {
                Haptics.selectionClick();
                open(term);
              })
              .also(_recognizers.add),
          ),
    ];
    return Text.rich(
      TextSpan(children: spans),
      style: widget.style,
      textAlign: widget.textAlign,
      maxLines: widget.maxLines,
      overflow: widget.maxLines == null ? null : TextOverflow.ellipsis,
    );
  }
}

extension _Also<T> on T {
  T also(void Function(T) f) {
    f(this);
    return this;
  }
}

/// Envuelve un chip o una insignia para que al tocarla explique su término.
class GlossaryTap extends StatelessWidget {
  const GlossaryTap({super.key, required this.term, required this.child});

  final Term term;
  final Widget child;

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () {
      Haptics.selectionClick();
      showGlossary(context, term);
    },
    child: child,
  );
}

/// Hoja de papel con la explicación de [term]. Los términos relacionados
/// cambian el contenido en el lugar, sin apilar hojas.
Future<void> showGlossary(BuildContext context, Term term) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      barrierColor: Palette.text.withValues(alpha: 0.18),
      builder: (_) => _GlossarySheet(term: term),
    );

class _GlossarySheet extends ConsumerStatefulWidget {
  const _GlossarySheet({required this.term});

  final Term term;

  @override
  ConsumerState<_GlossarySheet> createState() => _GlossarySheetState();
}

class _GlossarySheetState extends ConsumerState<_GlossarySheet> {
  late Term _term = widget.term;

  void _go(Term t) {
    if (t == _term) return;
    Haptics.selectionClick();
    setState(() => _term = t);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final dingbu = ref.watch(textProvider).dingbu();
    final term = _term;
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PaperPanel(
          opacity: 0.98,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              child: Column(
                key: ValueKey(term),
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _Seal(hanzi: term.hanzi),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          t.termTitle(term, dingbu: dingbu),
                          style: const TextStyle(
                            fontFamily: Fonts.display,
                            fontSize: 26,
                            fontWeight: FontWeight.w700,
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  GlossaryText(
                    t.termBody(term),
                    skip: {term},
                    onTerm: _go,
                    style: const TextStyle(fontSize: 16, height: 1.35),
                  ),
                  if (term.related.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Text(
                          t.glossRelated,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Palette.textDim,
                          ),
                        ),
                        for (final r in term.related)
                          TermPill(
                            label: t.termTitle(r, dingbu: dingbu),
                            hanzi: r.hanzi,
                            onTap: () => _go(r),
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Sello de laca con el hanzi del término.
class _Seal extends StatelessWidget {
  const _Seal({required this.hanzi});

  final String hanzi;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    alignment: Alignment.center,
    decoration: BoxDecoration(
      color: Palette.lacquer,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Palette.gold, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Palette.lacquer.withValues(alpha: 0.3),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: ExcludeSemantics(
      child: Text(
        hanzi,
        style: const TextStyle(
          fontFamily: Fonts.brush,
          fontSize: 28,
          height: 1,
          color: Palette.onColor,
        ),
      ),
    ),
  );
}

/// Pastilla de un término: hanzi y nombre, con borde de oro.
class TermPill extends StatelessWidget {
  const TermPill({
    super.key,
    required this.label,
    required this.hanzi,
    required this.onTap,
  });

  final String label;
  final String hanzi;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: label,
    excludeSemantics: true,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Palette.bg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Palette.gold.withValues(alpha: 0.7)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              hanzi,
              style: const TextStyle(
                fontFamily: Fonts.brush,
                fontSize: 15,
                height: 1,
                color: Palette.lacquer,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Términos que una carta pone en juego aunque no estén en su texto.
List<Term> cardTerms(CardDef d) => [
  if (d.guard > 0) ...[Term.guard, Term.height],
  if (d.structure > 0) Term.structure,
  if (d.stance != null || d.chainFrom != null) Term.stance,
  if (d.chainFrom != null) Term.chain,
  if (d.exhaust) Term.exhaust,
];

/// Ficha de una carta: grande, con nombre, efecto y términos tocables.
/// La abre la pulsación larga en la mano y en el mazo.
Future<void> showCardDetail(
  BuildContext context,
  CardDef def, {
  int upgrades = 0,
}) {
  Haptics.mediumImpact();
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    barrierColor: Palette.text.withValues(alpha: 0.22),
    isScrollControlled: true,
    builder: (_) => _CardDetail(def: def, upgrades: upgrades),
  );
}

class _CardDetail extends ConsumerWidget {
  const _CardDetail({required this.def, required this.upgrades});

  final CardDef def;
  final int upgrades;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final dingbu = text.dingbu();
    final effect = t.cardEffect(def, text);
    final terms = cardTerms(def);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: PaperPanel(
          opacity: 0.98,
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ExcludeSemantics(
                child: CardWidget(def: def, upgrades: upgrades, width: 120),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      upgrades > 0
                          ? '${text.card(def.id)} +$upgrades'
                          : text.card(def.id),
                      style: const TextStyle(
                        fontFamily: Fonts.display,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${def.pinyin} ${def.hanzi}',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Palette.textDim,
                      ),
                    ),
                    if (effect.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      GlossaryText(
                        effect,
                        style: const TextStyle(fontSize: 15.5, height: 1.35),
                      ),
                    ],
                    if (terms.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          for (final r in terms)
                            TermPill(
                              label: t.termTitle(r, dingbu: dingbu),
                              hanzi: r.hanzi,
                              onTap: () {
                                Haptics.selectionClick();
                                showGlossary(context, r);
                              },
                            ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
