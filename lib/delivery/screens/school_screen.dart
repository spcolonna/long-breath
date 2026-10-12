import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../domain/run/run_state.dart';
import '../../l10n/app_localizations.dart';
import '../audio/game_audio.dart';
import '../controllers/run_controller.dart';
import '../providers.dart';
import '../theme.dart';
import '../widgets/debug_menu.dart';
import '../widgets/hero_sprite.dart';
import '../widgets/difficulty_sheet.dart';
import '../widgets/menu_button.dart';
import '../widgets/slot_badge.dart';
import '../widgets/lore_scroll.dart';
import '../widgets/npc_portrait.dart';
import '../widgets/cultivation_view.dart';
import '../widgets/lotus.dart';
import '../../infrastructure/progress_storage.dart';
import '../../infrastructure/slot_storage.dart';
import '../controllers/climb.dart';
import 'home_screen.dart' show routeFor;
import '../../domain/model/enums.dart';

/// La escuela de una partida: quién sube, el reino, los meridianos, el
/// registro y la subida.
class SchoolScreen extends ConsumerStatefulWidget {
  const SchoolScreen({super.key});

  @override
  ConsumerState<SchoolScreen> createState() => _SchoolScreenState();
}

class _SchoolScreenState extends ConsumerState<SchoolScreen> {
  @override
  void initState() {
    super.initState();
    ref.read(audioProvider).music(Music.menu);
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context);
    final saved = ref.watch(savedRunProvider).value;
    final stats = ref.watch(dataProvider).balance.novice;
    final cultivation = ref.watch(cultivationProvider).value;
    final info = ref.watch(slotInfoProvider).value;
    final slot = ref.watch(activeSlotProvider);
    final resumable =
        saved != null &&
        saved.phase != RunPhase.victory &&
        saved.phase != RunPhase.defeat;

    void tap() {
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.uiButton);
    }

    Future<void> climb() async {
      tap();
      if (resumable) {
        final ok = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(t.menuReplaceRunTitle),
            content: Text(t.menuReplaceRunBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(t.cancelAction),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.menuReplaceRunOk),
              ),
            ],
          ),
        );
        if (ok != true || !context.mounted) return;
      }
      // La primera vez, antes de subir, la escuela cuenta por qué se sube.
      final lore = await ref.read(loreProvider.future);
      if (!context.mounted) return;
      if (!lore.contains('prologue')) {
        final go = await _prologue(context);
        if (go != true || !context.mounted) return;
        await ref.read(progressStorageProvider).unlockLore('prologue');
        ref.invalidate(loreProvider);
        if (!context.mounted) return;
      }
      // La dificultad es la de la partida: no se pregunta en cada subida.
      await startClimb(context, ref);
    }

    void resume() {
      tap();
      // Un combate a medias se reinicia desde el mapa.
      final r = ref.read(runEngineProvider).retreat(saved!);
      ref.read(runControllerProvider.notifier).resume(r);
      context.go(routeFor(r));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 4, 24, 24),
          child: Column(
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: t.slotsChange,
                    icon: const Icon(Icons.arrow_back_rounded),
                    onPressed: () {
                      tap();
                      context.go('/slots');
                    },
                  ),
                  Expanded(
                    child: info == null
                        ? const SizedBox.shrink()
                        : SlotBadge(slot: slot, info: info),
                  ),
                  if (kDebugMode) DebugButton(onDone: () => setState(() {})),
                  const AudioToggles(),
                ],
              ),
              // El héroe empieza de lino crudo: el camino se elige en la montaña.
              Expanded(
                child: LayoutBuilder(
                  builder: (context, box) => HeroSprite(
                    style: null,
                    height: math.min(box.maxHeight, box.maxWidth * 1.3),
                    glyph: stats.hanzi,
                    aura: cultivation == null || !cultivation.active
                        ? 0
                        : cultivation.realm /
                              (cultivation.def.realms.length - 1),
                  ),
                ),
              ),
              const _SchoolLine(),
              const SizedBox(height: 6),
              const RealmLine(),
              const _MeridianLine(),
              if (info != null && info.difficulty == Difficulty.normal)
                _PicoLine(info: info),
              const SizedBox(height: 10),
              MenuButton(
                icon: Icons.landscape_rounded,
                title: t.menuClimb,
                subtitle: t.menuClimbSubtitle,
                primary: !resumable,
                onTap: climb,
              ),
              if (resumable) ...[
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: FilledButton.icon(
                    onPressed: resume,
                    icon: const Icon(Icons.play_arrow_rounded),
                    label: Text(
                      t.continueRun,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Pico con el que sube esta partida: se cambia con − y + entre el 1 y el
/// más alto abierto en ella. Solo aparece si ya se abrió alguno.
class _PicoLine extends ConsumerWidget {
  const _PicoLine({required this.info});

  final SlotInfo info;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final open = math.max(
      ref.watch(picoUnlockedProvider).value ?? 0,
      info.pico,
    );
    if (open < 1) return const SizedBox.shrink();
    Future<void> set(int p) async {
      HapticFeedback.selectionClick();
      ref.read(audioProvider).play(Sfx.cardSelect);
      await ref.read(slotStorageProvider).setPico(info.slot, p);
      ref.invalidate(slotsProvider);
    }

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: t.picoLower,
            visualDensity: VisualDensity.compact,
            color: picoColor,
            onPressed: info.pico > 0 ? () => set(info.pico - 1) : null,
            icon: const Icon(Icons.remove_circle_outline_rounded),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: Palette.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: picoColor.withValues(alpha: 0.6)),
            ),
            child: Text(
              info.pico == 0 ? t.picoNone : '${t.picoName(info.pico)} · 峰',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: picoColor,
              ),
            ),
          ),
          IconButton(
            tooltip: t.picoHigher,
            visualDensity: VisualDensity.compact,
            color: picoColor,
            onPressed: info.pico < open ? () => set(info.pico + 1) : null,
            icon: const Icon(Icons.add_circle_outline_rounded),
          ),
        ],
      ),
    );
  }
}

/// Semillas de loto de la escuela y el acceso al árbol de meridianos; un
/// punto late si hay algo para abrir.
class _MeridianLine extends ConsumerWidget {
  const _MeridianLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final c = ref.watch(cultivationProvider).value;
    final m = ref.watch(meridianProvider).value;
    final def = ref.watch(dataProvider).balance.meridians;
    final seen = (ref.watch(ascentsProvider).value ?? const []).isNotEmpty;
    if (c == null || m == null || def.nodes.isEmpty || !seen) {
      return const SizedBox(height: 4);
    }
    final ready = def.nodes.any(
      (n) => def.canOpen(n, c.realm, m.owned) && m.lotus >= n.cost,
    );
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          HapticFeedback.selectionClick();
          ref.read(audioProvider).play(Sfx.uiButton);
          context.go('/meridians');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
          decoration: BoxDecoration(
            color: Palette.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: (ready ? Palette.jade : Palette.blossom).withValues(
                alpha: 0.6,
              ),
              width: ready ? 2 : 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              LotusCount(lotus: m.lotus, size: 18),
              const SizedBox(width: 8),
              Text(
                t.meridiansButton,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (ready) ...[
                const SizedBox(width: 6),
                const _Dot(),
              ],
              const Icon(Icons.chevron_right, size: 18, color: Palette.textDim),
            ],
          ),
        ),
      ),
    );
  }
}

/// Punto que late: hay algo nuevo para hacer.
class _Dot extends StatefulWidget {
  const _Dot();

  @override
  State<_Dot> createState() => _DotState();
}

class _DotState extends State<_Dot> with SingleTickerProviderStateMixin {
  late final _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ScaleTransition(
    scale: Tween(begin: 0.7, end: 1.15).animate(_c),
    child: Container(
      width: 9,
      height: 9,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Palette.jade,
      ),
    ),
  );
}

/// Quién sube ahora y, si ya hubo subidas, el registro de la escuela.
class _SchoolLine extends ConsumerWidget {
  const _SchoolLine();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = AppLocalizations.of(context);
    final n = ref.watch(discipleProvider).value;
    final ascents = ref.watch(ascentsProvider).value ?? const [];
    if (n == null) return const SizedBox(height: 32);
    return SizedBox(
      height: 32,
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: Palette.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Palette.gold.withValues(alpha: 0.6)),
              ),
              child: Text(
                t.discipleN(n),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Palette.gold,
                ),
              ),
            ),
            if (ascents.isNotEmpty) ...[
              const SizedBox(width: 6),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  HapticFeedback.selectionClick();
                  context.go('/registry');
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        '名册 ',
                        style: TextStyle(fontSize: 13, color: Palette.lacquer),
                      ),
                      Text(
                        t.registryTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Palette.lacquer,
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Palette.lacquer,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// La primera subida empieza con el prólogo: un pergamino y "Subir".
Future<bool?> _prologue(BuildContext context) => showModalBottomSheet<bool>(
  context: context,
  backgroundColor: Palette.bg,
  isScrollControlled: true,
  builder: (ctx) {
    final t = AppLocalizations.of(ctx);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // El maestro de la escuela despide al novicio.
            NpcPortrait(
              asset: 'assets/art/npc/master.webp',
              color: Palette.gold,
              height: 180,
              badge: Container(
                width: 56,
                height: 56,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: Palette.lacquer.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '师',
                  style: TextStyle(
                    fontSize: 30,
                    color: Palette.onColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 900),
              curve: Curves.easeOutCubic,
              builder: (_, v, _) => LoreScroll(id: 'prologue', open: v),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(t.prologueClimb),
              ),
            ),
          ],
        ),
      ),
    );
  },
);

