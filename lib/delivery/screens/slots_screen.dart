import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../infrastructure/slot_storage.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../labels.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/lotus.dart';
import '../widgets/slot_badge.dart';
import 'map/map_layout.dart';

const _numerals = ['一', '二', '三'];

/// Las tres partidas: cada una con su escuela, su registro y una dificultad
/// fija. Se elige una para jugar, se crea una nueva o se borra.
class SlotsScreen extends ConsumerWidget {
  const SlotsScreen({super.key});

  void _tap(WidgetRef ref) {
    HapticFeedback.selectionClick();
    ref.read(audioProvider).play(Sfx.uiButton);
  }

  /// Pasa a jugar la partida [slot]: todo el progreso se lee de ella.
  void _enter(BuildContext context, WidgetRef ref, int slot) {
    ref.read(activeSlotProvider.notifier).select(slot);
    ref
      ..invalidate(progressStorageProvider)
      ..invalidate(runStorageProvider)
      ..invalidate(runControllerProvider)
      ..invalidate(lastAscentProvider)
      ..invalidate(slotInfoProvider);
    context.go('/school');
  }

  Future<void> _create(BuildContext context, WidgetRef ref, int slot) async {
    _tap(ref);
    final choice = await pickDifficulty(context);
    if (choice == null || !context.mounted) return;
    await ref
        .read(slotStorageProvider)
        .create(slot, choice.difficulty, pico: choice.pico);
    _refresh(ref, slot);
    if (context.mounted) _enter(context, ref, slot);
  }

  void _refresh(WidgetRef ref, int slot) => ref
    ..invalidate(slotsProvider)
    ..invalidate(slotSummaryProvider(slot))
    ..invalidate(anyWinsProvider)
    ..invalidate(bestPicoProvider);

  /// Borrar pide confirmación; si la partida ya tiene progreso, dos veces.
  Future<bool> _confirmDelete(
    BuildContext context,
    int slot,
    bool progress,
  ) async {
    final t = AppLocalizations.of(context);
    Future<bool> ask(String title, String body, String ok) async =>
        await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(title),
            content: Text(body),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.cancelAction),
              ),
              FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: Palette.lacquer,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(ok),
              ),
            ],
          ),
        ) ==
        true;
    if (!await ask(
      t.slotDeleteTitle(slot),
      t.slotDeleteBody,
      t.slotDeleteOk,
    )) {
      return false;
    }
    if (!progress || !context.mounted) return true;
    return ask(
      t.slotDeleteSureTitle,
      t.slotDeleteSureBody(slot),
      t.slotDeleteSureOk,
    );
  }

  Future<void> _delete(
    BuildContext context,
    WidgetRef ref,
    int slot,
    bool progress, {
    bool restart = false,
  }) async {
    _tap(ref);
    if (!await _confirmDelete(context, slot, progress)) return;
    await ref.read(slotStorageProvider).delete(slot);
    HapticFeedback.heavyImpact();
    _refresh(ref, slot);
    if (ref.read(activeSlotProvider) == slot) {
      ref
        ..invalidate(progressStorageProvider)
        ..invalidate(runStorageProvider)
        ..invalidate(runControllerProvider);
    }
    if (restart && context.mounted) await _create(context, ref, slot);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final slots = ref.watch(slotsProvider).value;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(onPressed: () => context.go('/')),
        title: Text(t.slotsTitle),
      ),
      body: SafeArea(
        child: slots == null
            ? const SizedBox.shrink()
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                children: [
                  Text(
                    t.slotsSubtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Palette.textDim,
                    ),
                  ),
                  const SizedBox(height: 16),
                  for (var n = 1; n <= SlotStorage.count; n++) ...[
                    _Appear(
                      index: n,
                      child: slots[n] == null
                          ? _EmptySlot(
                              slot: n,
                              onTap: () => _create(context, ref, n),
                            )
                          : _SlotCard(
                              info: slots[n]!,
                              onTap: () {
                                _tap(ref);
                                _enter(context, ref, n);
                              },
                              onDelete: (progress) =>
                                  _delete(context, ref, n, progress),
                              onRestart: (progress) => _delete(
                                context,
                                ref,
                                n,
                                progress,
                                restart: true,
                              ),
                            ),
                    ),
                    const SizedBox(height: 14),
                  ],
                ],
              ),
      ),
    );
  }
}

/// Las tarjetas entran una detrás de otra.
class _Appear extends StatelessWidget {
  const _Appear({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: Duration(milliseconds: 380 + 120 * index),
    curve: Curves.easeOutCubic,
    builder: (_, v, child) => Opacity(
      opacity: v,
      child: Transform.translate(offset: Offset(0, 18 * (1 - v)), child: child),
    ),
    child: child,
  );
}

class _SlotCard extends ConsumerWidget {
  const _SlotCard({
    required this.info,
    required this.onTap,
    required this.onDelete,
    required this.onRestart,
  });

  final SlotInfo info;
  final VoidCallback onTap;
  final ValueChanged<bool> onDelete;
  final ValueChanged<bool> onRestart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final text = ref.watch(textProvider);
    final stages = ref.watch(dataProvider).balance.stages;
    final sum = ref.watch(slotSummaryProvider(info.slot)).value;
    final run = sum?.run;
    final climbing =
        run != null &&
        run.phase != RunPhase.victory &&
        run.phase != RunPhase.defeat;
    final progress = sum != null && (sum.ascents > 0 || sum.lotus > 0) ||
        climbing;
    final color = difficultyColor(info.difficulty);
    String? where;
    if (climbing) {
      final rows = mapRows(run);
      final floor = rows.indexWhere(
        (r) => r.any((n) => n.id == run.currentNode),
      );
      where = t.slotClimbing(text.stage(stages[run.stage].id), floor + 2);
    }
    return Material(
      color: Palette.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 12, 4, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: color.withValues(alpha: 0.7), width: 2),
          ),
          child: Row(
            children: [
              InkSeal(hanzi: _numerals[info.slot - 1], color: color, size: 56),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          t.slotName(info.slot),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(width: 8),
                        DifficultySeal(difficulty: info.difficulty, size: 20),
                        const SizedBox(width: 4),
                        Flexible(
                          child: Text(
                            info.pico > 0
                                ? '${t.difficultyName(info.difficulty)} · ${t.picoName(info.pico)}'
                                : t.difficultyName(info.difficulty),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: color,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (sum != null) ...[
                      const SizedBox(height: 3),
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            t.discipleN(sum.disciple),
                            style: const TextStyle(
                              fontSize: 13,
                              color: Palette.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          LotusCount(lotus: sum.lotus, size: 15),
                          Text(
                            t.slotAscents(sum.ascents, sum.wins),
                            style: const TextStyle(
                              fontSize: 12.5,
                              color: Palette.textDim,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        where ?? t.slotResting,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontStyle: climbing ? null : FontStyle.italic,
                          color: climbing ? Palette.jade : Palette.textDim,
                          fontWeight: climbing ? FontWeight.w700 : null,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              PopupMenuButton<String>(
                tooltip: t.slotOptions,
                icon: const Icon(Icons.more_vert_rounded),
                color: Palette.bg,
                onSelected: (v) =>
                    v == 'restart' ? onRestart(progress) : onDelete(progress),
                itemBuilder: (_) => [
                  PopupMenuItem(
                    value: 'restart',
                    child: Row(
                      children: [
                        const Icon(Icons.restart_alt_rounded),
                        const SizedBox(width: 12),
                        Text(t.slotRestart),
                      ],
                    ),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        const Icon(
                          Icons.delete_outline_rounded,
                          color: Palette.lacquer,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          t.slotDelete,
                          style: const TextStyle(color: Palette.lacquer),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Partida libre: tocar crea una nueva y pregunta la dificultad.
class _EmptySlot extends StatelessWidget {
  const _EmptySlot({required this.slot, required this.onTap});

  final int slot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    return Material(
      color: Palette.surface.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Palette.line, width: 1.5),
          ),
          child: Row(
            children: [
              InkSeal(hanzi: _numerals[slot - 1], color: Palette.line, size: 56, dim: true),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.slotNew,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Palette.lacquer,
                      ),
                    ),
                    Text(
                      t.slotNewHint,
                      style: const TextStyle(
                        fontSize: 12.5,
                        color: Palette.textDim,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.add_circle_rounded, color: Palette.lacquer),
            ],
          ),
        ),
      ),
    );
  }
}
