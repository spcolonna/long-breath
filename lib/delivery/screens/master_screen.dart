import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/form_def.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/deck_sheet.dart';
import '../widgets/form_scroll.dart';
import '../widgets/jade.dart';
import '../widgets/juice.dart';
import '../widgets/npc_portrait.dart';
import '../widgets/talisman_widgets.dart';

/// Maestro errante: una sola lección, una forma o mejorar una carta.
class MasterScreen extends ConsumerStatefulWidget {
  const MasterScreen({super.key});

  @override
  ConsumerState<MasterScreen> createState() => _MasterScreenState();
}

class _MasterScreenState extends ConsumerState<MasterScreen> {
  /// Las formas se guardan al entrar: al aprender, la run vuelve al mapa.
  List<String>? _forms;
  String? _picked;
  bool _picking = false;

  /// Lo aprendido o mejorado, para el cartel final.
  String? _done;
  int _burst = 0;

  void _finish(String label, VoidCallback apply) {
    HapticFeedback.heavyImpact();
    ref.read(audioProvider).play(Sfx.formComplete);
    setState(() {
      _done = label;
      _picking = false;
      _burst++;
    });
    Future.delayed(const Duration(milliseconds: 1400), () {
      if (!mounted) return;
      apply();
      context.go('/map');
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final text = ref.watch(textProvider);
    final ctl = ref.read(runControllerProvider.notifier);
    _forms ??= run.masterForms;
    final upgrade = data.balance.fountainUpgrade;

    if (_picking) {
      return Scaffold(
        appBar: AppBar(
          title: Text(t.masterUpgradeHint),
          leading: BackButton(
            onPressed: () => setState(() => _picking = false),
          ),
        ),
        body: DeckGrid(
          cards: run.deck,
          enabled: engine.canUpgrade,
          onPick: (c) => _finish(
            t.masterUpgraded(text.card(c.cardId), upgrade),
            () => ctl.masterUpgrade(c.uid),
          ),
        ),
      );
    }

    final deckIds = {for (final c in run.deck) c.cardId};
    FormDef form(String id) => data.forms.firstWhere((f) => f.id == id);
    final busy = _done != null;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Palette.jade, size: 18),
                  const SizedBox(width: 4),
                  Text(
                    '${run.hp}/${run.maxHp}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: 12),
                  JadeCount(jade: run.jade),
                  Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
                ],
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.only(top: 12, bottom: 16),
                  children: [
                    NpcPortrait(
                      asset: 'assets/art/npc/master.png',
                      color: Palette.structure,
                      height: 150,
                      badge: SizedBox(
                        width: 120,
                        height: 96,
                        child: Stack(
                          alignment: Alignment.center,
                          clipBehavior: Clip.none,
                          children: [
                            Bounce(
                              trigger: _burst,
                              scale: 1.2,
                              child: Container(
                                width: 84,
                                height: 84,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Palette.surface,
                                  border: Border.all(
                                    color: Palette.structure,
                                    width: 3,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Palette.structure.withValues(
                                        alpha: 0.35,
                                      ),
                                      blurRadius: 18,
                                    ),
                                  ],
                                ),
                                child: const Text(
                                  '师',
                                  style: TextStyle(
                                    fontSize: 42,
                                    height: 1,
                                    color: Palette.structure,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            Positioned.fill(
                              child: InkBurst(
                                trigger: _burst,
                                colors: const [
                                  Palette.structure,
                                  Palette.gold,
                                  Colors.white,
                                ],
                                count: 40,
                                radius: 170,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      t.masterTitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      t.masterText,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 15, height: 1.35),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _forms!.isEmpty ? t.masterNoForms : t.masterTeachHint,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Palette.textDim),
                    ),
                    const SizedBox(height: 8),
                    for (final id in _forms!) ...[
                      GestureDetector(
                        onTap: busy
                            ? null
                            : () {
                                HapticFeedback.selectionClick();
                                ref.read(audioProvider).play(Sfx.cardSelect);
                                setState(
                                  () => _picked = _picked == id ? null : id,
                                );
                              },
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 200),
                          opacity: _picked != null && _picked != id ? 0.55 : 1,
                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutBack,
                            scale: _picked == id ? 1.03 : 1,
                            child: FormScroll(
                              form: form(id),
                              name: text.form(id),
                              steps: [
                                for (final s in form(id).steps)
                                  (text.card(s), deckIds.contains(s)),
                              ],
                              effect: t.formEffect(form(id).effect),
                              selected: _picked == id,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                    ],
                    if (_forms!.isNotEmpty)
                      Text(
                        t.masterOr,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Palette.textDim,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: OutlinedButton.icon(
                        onPressed: busy
                            ? null
                            : () => setState(() => _picking = true),
                        icon: const Icon(Icons.upgrade),
                        label: Text(
                          t.masterUpgrade(upgrade),
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Al terminar, el cartel ocupa el lugar del botón.
              SizedBox(
                width: double.infinity,
                height: 48,
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  // El botón ocupa todo el ancho, como en las otras pantallas.
                  layoutBuilder: (current, previous) => Stack(
                    fit: StackFit.expand,
                    children: [...previous, ?current],
                  ),
                  child: _done != null
                      ? Center(
                          key: const ValueKey('done'),
                          child: Bounce(
                            trigger: _burst,
                            scale: 1.25,
                            child: Text(
                              _done!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: Palette.structure,
                              ),
                            ),
                          ),
                        )
                      : FilledButton(
                          key: const ValueKey('confirm'),
                          onPressed: _picked == null
                              ? null
                              : () => _finish(
                                  t.formLearned(text.form(_picked!)),
                                  () => ctl.masterTeach(_picked!),
                                ),
                          child: Text(t.confirm),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
