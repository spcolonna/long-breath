import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/model/event_def.dart';
import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/juice.dart';
import '../widgets/talisman_widgets.dart';

/// Evento del mapa: una escena, dos opciones y lo que pasó.
class EventScreen extends ConsumerStatefulWidget {
  const EventScreen({super.key});

  @override
  ConsumerState<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends ConsumerState<EventScreen> {
  /// El evento se guarda acá: al resolverlo la run vuelve al mapa.
  String? _eventId;
  EventResult? _result;
  int _burst = 0;

  void _choose(EventOptionDef o) {
    if (_result != null) return;
    final ctl = ref.read(runControllerProvider.notifier);
    ctl.resolveEvent(o.id);
    final r = ref.read(runControllerProvider)!.lastEvent!;
    final audio = ref.read(audioProvider);
    final good =
        r.talisman != null ||
        r.form != null ||
        r.card != null ||
        r.upgraded != null ||
        r.maxHp > 0;
    if (good) {
      HapticFeedback.heavyImpact();
      audio.play(Sfx.rewardTake);
    } else if (r.hp < 0) {
      HapticFeedback.mediumImpact();
      audio.play(Sfx.playerHurt);
    } else if (r.hp > 0) {
      HapticFeedback.lightImpact();
      audio.play(Sfx.fountainHeal);
    } else {
      HapticFeedback.selectionClick();
      audio.play(Sfx.uiButton);
    }
    setState(() {
      _result = r;
      if (good) _burst++;
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final run = ref.watch(runControllerProvider);
    if (run == null) return const SizedBox();
    _eventId ??= run.eventId;
    final id = _eventId;
    if (id == null) return const SizedBox();
    final data = ref.watch(dataProvider);
    final engine = ref.watch(runEngineProvider);
    final text = ref.watch(textProvider);
    final event = data.event(id);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Palette.jade, size: 18),
                  const SizedBox(width: 4),
                  Bounce(
                    trigger: '${run.hp}/${run.maxHp}',
                    scale: 1.3,
                    child: Text(
                      '${run.hp}/${run.maxHp}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                  Expanded(child: TalismanRow(ids: run.talismans, wrap: false)),
                ],
              ),
              const Spacer(),
              Container(
                width: 92,
                height: 92,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Palette.surface,
                  border: Border.all(color: Palette.blossom, width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Palette.blossom.withValues(alpha: 0.35),
                      blurRadius: 18,
                    ),
                  ],
                ),
                child: Text(
                  event.hanzi,
                  style: const TextStyle(
                    fontSize: 46,
                    height: 1,
                    color: Palette.blossom,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                text.event(id),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                text.eventText(id),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16, height: 1.4),
              ),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 320),
                transitionBuilder: (child, a) => FadeTransition(
                  opacity: a,
                  child: ScaleTransition(
                    scale: Tween(begin: 0.94, end: 1.0).animate(a),
                    child: child,
                  ),
                ),
                child: _result == null
                    ? Column(
                        key: const ValueKey('options'),
                        children: [
                          for (final o in event.options) ...[
                            _OptionButton(
                              label: text.eventOption(id, o.id),
                              summary: t.eventOptionSummary(o),
                              risky: o.chance != null,
                              enabled: engine.canChoose(run, o),
                              onTap: () => _choose(o),
                            ),
                            const SizedBox(height: 10),
                          ],
                        ],
                      )
                    : Stack(
                        key: const ValueKey('result'),
                        clipBehavior: Clip.none,
                        children: [
                          _ResultCard(result: _result!),
                          Positioned.fill(
                            child: InkBurst(
                              trigger: _burst,
                              colors: const [
                                Palette.blossom,
                                Palette.gold,
                                Colors.white,
                              ],
                              count: 36,
                              radius: 170,
                            ),
                          ),
                        ],
                      ),
              ),
              const SizedBox(height: 8),
              AnimatedOpacity(
                opacity: _result == null ? 0 : 1,
                duration: const Duration(milliseconds: 300),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _result == null
                        ? null
                        : () {
                            HapticFeedback.selectionClick();
                            ref.read(audioProvider).play(Sfx.uiButton);
                            context.go('/map');
                          },
                    child: Text(t.eventContinue),
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

class _OptionButton extends StatelessWidget {
  const _OptionButton({
    required this.label,
    required this.summary,
    required this.risky,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final String summary;
  final bool risky;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Opacity(
      opacity: enabled ? 1 : 0.5,
      child: Material(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled ? onTap : null,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: risky ? Palette.gold : Palette.line,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        enabled ? summary : t.eventCantPay,
                        style: TextStyle(
                          fontSize: 13,
                          color: enabled ? Palette.textDim : Palette.lacquer,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  risky ? Icons.casino_outlined : Icons.chevron_right_rounded,
                  color: risky ? Palette.gold : Palette.textDim,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Qué pasó: la escena, si salió bien o mal y lo que se ganó o perdió.
class _ResultCard extends ConsumerWidget {
  const _ResultCard({required this.result});

  final EventResult result;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final r = result;
    final failed = r.success == false;
    final chips = <Widget>[
      if (r.hp < 0) _chip(t.eventCost(-r.hp), Palette.lacquer, Icons.favorite),
      if (r.hp > 0) _chip(t.eventHeal(r.hp), Palette.jade, Icons.favorite),
      if (r.maxHp > 0)
        _chip(t.eventMaxHp(r.maxHp), Palette.jade, Icons.favorite_border),
      if (r.talisman != null)
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _PopIn(child: TalismanBadge(id: r.talisman!, size: 30)),
            const SizedBox(width: 6),
            Text(
              t.eventResultTalisman(text.talisman(r.talisman!)),
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      if (r.form != null)
        _chip(
          t.eventResultForm(text.form(r.form!)),
          Palette.lacquer,
          Icons.auto_awesome,
        ),
      if (r.card != null)
        _chip(t.eventResultCard(text.card(r.card!)), Palette.gold, Icons.style),
      if (r.upgraded != null)
        _chip(
          t.eventResultUpgrade(text.card(r.upgraded!)),
          Palette.gold,
          Icons.arrow_upward,
        ),
      if (r.lost != null)
        _chip(
          t.eventResultLost(text.card(r.lost!)),
          Palette.textDim,
          Icons.remove_circle_outline,
        ),
    ];
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Palette.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: failed ? Palette.lacquer : Palette.blossom,
          width: 2,
        ),
      ),
      child: Column(
        children: [
          if (r.success != null) ...[
            _PopIn(
              child: Text(
                r.success! ? t.eventLucky : t.eventUnlucky,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: r.success! ? Palette.jade : Palette.lacquer,
                ),
              ),
            ),
            const SizedBox(height: 6),
          ],
          Text(
            text.eventResult(r.eventId, r.optionId, failed: failed),
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, height: 1.35),
          ),
          if (chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 10,
              runSpacing: 8,
              children: chips,
            ),
          ],
        ],
      ),
    );
  }

  Widget _chip(String label, Color color, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withValues(alpha: 0.12),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.w700, color: color),
        ),
      ],
    ),
  );
}

/// Aparece creciendo con un rebote (los avisos del resultado).
class _PopIn extends StatelessWidget {
  const _PopIn({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0.4, end: 1),
    duration: const Duration(milliseconds: 520),
    curve: Curves.elasticOut,
    builder: (_, v, child) => Transform.scale(scale: v, child: child),
    child: child,
  );
}
