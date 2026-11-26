import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/combat/combat_engine.dart';
import '../domain/model/game_data.dart';
import '../domain/run/run_engine.dart';
import '../infrastructure/asset_game_data_loader.dart';
import '../infrastructure/content_text_loader.dart';
import 'audio/game_audio.dart';
import 'content_text.dart';
import '../domain/model/enums.dart';
import '../domain/model/meta_bonus.dart';
import '../domain/run/ascent.dart';
import '../domain/run/chronicle.dart';
import '../domain/run/cultivation.dart';
import '../domain/run/run_state.dart';
import '../domain/run/school_story.dart';
import '../infrastructure/progress_storage.dart';
import '../infrastructure/run_log_storage.dart';
import '../infrastructure/run_storage.dart';
import '../infrastructure/slot_storage.dart';
import '../infrastructure/tutorial_storage.dart';

final gameDataProvider = FutureProvider<GameData>(
  (ref) => loadGameDataFromAssets(),
);

/// Solo usar una vez cargado [gameDataProvider].
final dataProvider = Provider<GameData>(
  (ref) => ref.watch(gameDataProvider).requireValue,
);

/// Textos del contenido en el idioma del dispositivo (respaldo: español).
final contentTextProvider = FutureProvider<ContentText>(
  (ref) => loadContentText(
    WidgetsBinding.instance.platformDispatcher.locale.languageCode,
  ),
);

/// Solo usar una vez cargado [contentTextProvider].
final textProvider = Provider<ContentText>(
  (ref) => ref.watch(contentTextProvider).requireValue,
);

/// Ids de las cartas que tienen ilustración (`assets/art/cards/<id>.webp`).
/// Las que no, muestran su hanzi de marca de agua.
final cardArtProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return {
    for (final a in manifest.listAssets())
      if (a.startsWith('assets/art/cards/') && !a.contains('/frame_'))
        a.split('/').last.replaceAll('.webp', ''),
  };
});

/// Ids de las armas que tienen imagen (`assets/art/weapons/<id>.webp`).
/// Las que no, se dibujan por código.
final weaponArtProvider = FutureProvider<Set<String>>((ref) async {
  final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
  return {
    for (final a in manifest.listAssets())
      if (a.startsWith('assets/art/weapons/'))
        a.split('/').last.replaceAll('.webp', ''),
  };
});

final combatEngineProvider = Provider<CombatEngine>(
  (ref) => CombatEngine(ref.watch(dataProvider)),
);

final runEngineProvider = Provider<RunEngine>(
  (ref) => RunEngine(ref.watch(dataProvider)),
);

final slotStorageProvider = Provider<SlotStorage>((ref) => SlotStorage());

/// Las partidas creadas (hasta [SlotStorage.count]).
final slotsProvider = FutureProvider<Map<int, SlotInfo>>(
  (ref) => ref.watch(slotStorageProvider).slots(),
);

/// Partida en juego: todo el progreso y la subida se leen y guardan en ella.
final activeSlotProvider = NotifierProvider<ActiveSlot, int>(ActiveSlot.new);

class ActiveSlot extends Notifier<int> {
  @override
  int build() => 1;

  void select(int slot) => state = slot;
}

/// Datos de la partida en juego (null si todavía no se creó).
final slotInfoProvider = FutureProvider<SlotInfo?>((ref) async {
  final slot = ref.watch(activeSlotProvider);
  return (await ref.watch(slotsProvider.future))[slot];
});

/// Lo que muestra la tarjeta de una partida en la pantalla de partidas.
typedef SlotSummary = ({
  int disciple,
  int lotus,
  int ascents,
  int wins,
  RunState? run,
});

final slotSummaryProvider = FutureProvider.autoDispose.family<SlotSummary, int>((
  ref,
  slot,
) async {
  final store = ref.watch(slotStorageProvider);
  final progress = store.progress(slot);
  final past = await progress.ascents();
  return (
    disciple: await progress.discipleNumber(),
    lotus: await progress.lotus(),
    ascents: past.length,
    wins: past.where((a) => !a.fell).length,
    run: await store.runs(slot).load(),
  );
});

/// Dificultades ganadas en cualquier partida (abren Shifu al crear otra).
final anyWinsProvider = FutureProvider<Set<Difficulty>>(
  (ref) => ref.watch(slotStorageProvider).allWins(),
);

/// Pico más alto abierto en cualquier partida.
final bestPicoProvider = FutureProvider<int>(
  (ref) => ref.watch(slotStorageProvider).bestPico(),
);

final runStorageProvider = Provider<RunStorage>(
  (ref) => RunStorage(SlotStorage.prefixOf(ref.watch(activeSlotProvider))),
);

/// Registro de la subida en curso de la partida activa (para el balance).
final runLogProvider = Provider<RunLogStorage>(
  (ref) => RunLogStorage(ref.watch(activeSlotProvider)),
);

final savedRunProvider = FutureProvider(
  (ref) => ref.watch(runStorageProvider).load(),
);

final tutorialStorageProvider = Provider<TutorialStorage>(
  (ref) => TutorialStorage(),
);

final progressStorageProvider = Provider<ProgressStorage>(
  (ref) => ProgressStorage(SlotStorage.prefixOf(ref.watch(activeSlotProvider))),
);

/// Dificultades en las que el jugador ya ganó una subida.
final winsProvider = FutureProvider<Set<Difficulty>>(
  (ref) => ref.watch(progressStorageProvider).wins(),
);

/// Pico más alto que el jugador puede elegir (0 = ninguno abierto).
final picoUnlockedProvider = FutureProvider<int>(
  (ref) => ref.watch(progressStorageProvider).picoUnlocked(),
);

/// Número del discípulo que sube ahora.
final discipleProvider = FutureProvider<int>(
  (ref) => ref.watch(progressStorageProvider).discipleNumber(),
);

/// El registro de la escuela: todas las subidas terminadas.
final ascentsProvider = FutureProvider<List<Ascent>>(
  (ref) => ref.watch(progressStorageProvider).ascents(),
);

/// Pergaminos de la escuela ya abiertos.
final loreProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(progressStorageProvider).lore(),
);

/// Marcas de los hilos que cruzan subidas.
final threadsProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(progressStorageProvider).threads(),
);

/// La crónica de la montaña: lo que se sabe de cada enemigo.
final bestiaryProvider = FutureProvider<Map<String, Sighting>>(
  (ref) => ref.watch(progressStorageProvider).bestiary(),
);

/// Hitos 功 cumplidos en la partida.
final hitosProvider = FutureProvider<Set<String>>((ref) {
  final def = ref.watch(dataProvider).balance.cultivation;
  return ref
      .watch(progressStorageProvider)
      .hitos(migrate: (a) => ascentBreath(def, a));
});

/// Aliento de la escuela y reino del cultivo.
final cultivationProvider = FutureProvider<Cultivation>((ref) async {
  final def = ref.watch(dataProvider).balance.cultivation;
  // Los hitos de partidas viejas suman su aliento la primera vez.
  await ref.watch(hitosProvider.future);
  final breath = await ref
      .watch(progressStorageProvider)
      .breath(migrate: (a) => ascentBreath(def, a));
  return Cultivation(def, breath);
});

/// Loto de la escuela y puntos abiertos del árbol de meridianos.
final meridianProvider =
    FutureProvider<({int lotus, List<String> owned})>((ref) async {
  final storage = ref.watch(progressStorageProvider);
  return (lotus: await storage.lotus(), owned: await storage.meridians());
});

/// Jade guardado para la escuela y nivel de cada edificio restaurado.
final schoolProvider =
    FutureProvider<({int jade, Map<String, int> levels})>((ref) async {
  final storage = ref.watch(progressStorageProvider);
  return (
    jade: await storage.schoolJadeTotal(),
    levels: await storage.schoolLevels(),
  );
});

/// Presentaciones ya vistas en la partida (las `intro_*` de los sistemas).
final seenProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(progressStorageProvider).cinematics(),
);

/// Qué le falta al próximo capítulo de cada hilo de la escuela (Ming en la
/// enfermería, Tie en la forja).
final schoolStoryProvider = FutureProvider<Map<String, StoryWait>>((
  ref,
) async {
  final storage = ref.watch(progressStorageProvider);
  final lore = await ref.watch(loreProvider.future);
  final school = await ref.watch(schoolProvider.future);
  final ascents = await ref.watch(ascentsProvider.future);
  final readAt = await storage.schoolStoryReadAt();
  final last = ascents.isEmpty ? 0 : ascents.last.n;
  return {
    for (final MapEntry(key: thread, value: building) in schoolThreads.entries)
      thread: schoolStoryWait(
        thread: thread,
        lore: lore,
        level: school.levels[building] ?? 0,
        lastDisciple: last,
        readAt: readAt[thread] ?? 0,
      ),
  };
});

/// Experiencia de maestría de cada camino.
final masteryProvider = FutureProvider<Map<Style, int>>(
  (ref) => ref.watch(progressStorageProvider).mastery(),
);

/// Lo que sigue cerrado para la próxima subida: lo del cultivo y lo que la
/// maestría de cada camino todavía no abrió.
final lockedProvider = FutureProvider<List<String>>((ref) async {
  final c = await ref.watch(cultivationProvider.future);
  final xp = await ref.watch(masteryProvider.future);
  return [...c.locked, ...ref.watch(dataProvider).balance.mastery.lockedFor(xp)];
});

/// Dones de la escuela para la próxima subida (reinos, meridianos y
/// edificios restaurados).
final metaBonusProvider = FutureProvider<MetaBonus>((ref) async {
  final balance = ref.watch(dataProvider).balance;
  final c = await ref.watch(cultivationProvider.future);
  final m = await ref.watch(meridianProvider.future);
  final s = await ref.watch(schoolProvider.future);
  return balance.meridians.bonusOf(c.def, c.realm, m.owned) +
      balance.school.bonusOf(s.levels);
});

/// La subida que acaba de terminar, ya anotada (con su número y sus
/// pergaminos nuevos), para la pantalla final.
final lastAscentProvider = NotifierProvider<LastAscent, Ascent?>(
  LastAscent.new,
);

class LastAscent extends Notifier<Ascent?> {
  @override
  Ascent? build() {
    ref.watch(activeSlotProvider);
    return null;
  }

  void set(Ascent? a) => state = a;
}

final lessonsDoneProvider = FutureProvider<Set<String>>(
  (ref) => ref.watch(tutorialStorageProvider).lessonsDone(),
);

/// En `main` se reemplaza por el motor real; en tests queda en silencio.
final audioProvider = Provider<GameAudio>((ref) => SilentAudio());

/// Presentaciones de etapa y de jefe. Los tests de flujo la apagan para no
/// esperar la animación.
final cinematicsProvider = Provider<bool>((ref) => true);
