import '../../domain/combat/combat_action.dart';
import '../../domain/combat/combat_engine.dart';
import '../../domain/combat/combat_event.dart';
import '../../domain/combat/combat_state.dart';
import '../../domain/run/run_state.dart';
import '../../domain/run/map_rows.dart';

/// Texto del registro de una subida: ids (no nombres traducidos) para que se
/// pueda analizar el balance. Funciones puras; quien escribe es
/// `RunLogStorage`.

String _clock() {
  final n = DateTime.now();
  String two(int v) => v.toString().padLeft(2, '0');
  return '${two(n.hour)}:${two(n.minute)}:${two(n.second)}';
}

/// Una línea con hora.
String logLine(String s) => '[${_clock()}] $s';

/// Piso del nodo dentro de la etapa (1 = abajo).
int floorOf(RunState r, String nodeId) =>
    mapRows(r).indexWhere((row) => row.any((n) => n.id == nodeId)) + 1;

String _node(RunState r, String id) {
  final n = r.node(id);
  if (n.foes.isEmpty) return n.type.name;
  return '${n.type.name}(${n.foes.join('+')}${n.together ? ' juntos' : ''})';
}

String _cards(Iterable<CombatCard> cards) => cards
    .map((c) => c.upgrades > 0 ? '${c.cardId}+${c.upgrades}' : c.cardId)
    .join(', ');

/// Encabezado al empezar una subida.
List<String> runHeader(RunState r, int slot) => [
  '=== Long Breath · subida ${DateTime.now().toIso8601String().split('.').first} ===',
  'partida $slot · dificultad ${r.difficulty.name} · pico ${r.pico}',
  'vida ${r.hp}/${r.maxHp} · jade ${r.jade} · lotos ${r.lotus}',
  'mazo (${r.deck.length}): ${_cards(r.deck)}',
  if (r.talismans.isNotEmpty) 'talismanes: ${r.talismans.join(', ')}',
  if (r.weapon != null) 'arma: ${r.weapon} nv ${r.weaponLevel}',
  if (r.legacy != null) 'legado: ${r.legacy!.toJson()}',
];

/// Lo que cambió en la subida entre [a] y [b] (con la acción [what] y las
/// opciones de camino que había, si entró a un nodo).
List<String> runDiff(
  RunState? a,
  RunState? b, {
  String? what,
  List<String> options = const [],
}) {
  if (b == null) return [logLine('subida abandonada')];
  final out = <String>[];
  void add(String s) => out.add(s);
  if (a == null) return out;
  if (a.stage != b.stage) add('ETAPA ${b.stage + 1}');
  if (b.currentNode != null && a.currentNode != b.currentNode) {
    final id = b.currentNode!;
    final alts = options.where((o) => o != id).map((o) => _node(a, o));
    add(
      'CAMINO etapa ${b.stage + 1} piso ${floorOf(b, id)}: ${_node(b, id)}'
      '${alts.isEmpty ? '' : '  (otras: ${alts.join(' | ')})'}',
    );
  }
  if (a.phase != b.phase) add('fase ${a.phase.name} → ${b.phase.name}');
  if (a.style != b.style) add('camino elegido: ${b.style?.name}');
  if (a.hp != b.hp || a.maxHp != b.maxHp) {
    add('vida ${a.hp}/${a.maxHp} → ${b.hp}/${b.maxHp}');
  }
  if (a.jade != b.jade) add('jade ${a.jade} → ${b.jade}');
  if (a.lotus != b.lotus) add('lotos ${a.lotus} → ${b.lotus}');
  final before = {for (final c in a.deck) c.uid: c};
  final after = {for (final c in b.deck) c.uid: c};
  final added = [for (final c in b.deck) if (!before.containsKey(c.uid)) c];
  final removed = [for (final c in a.deck) if (!after.containsKey(c.uid)) c];
  final upgraded = [
    for (final c in b.deck)
      if (before[c.uid] case final o? when o.upgrades != c.upgrades) c,
  ];
  if (added.isNotEmpty) add('carta nueva: ${_cards(added)}');
  if (removed.isNotEmpty) add('carta quitada: ${_cards(removed)}');
  if (upgraded.isNotEmpty) add('carta mejorada: ${_cards(upgraded)}');
  for (final t in b.talismans) {
    if (!a.talismans.contains(t)) add('talismán: $t');
  }
  if (a.weapon != b.weapon || a.weaponLevel != b.weaponLevel) {
    add('arma: ${b.weapon} nv ${b.weaponLevel}');
  }
  for (final w in b.awakenings) {
    if (!a.awakenings.contains(w)) add('despertar: $w');
  }
  for (final f in b.knownForms) {
    if (!a.knownForms.contains(f)) add('forma aprendida: $f');
  }
  // Lo que se ofrece (para ver qué se eligió y qué no).
  if (b.phase == RunPhase.reward &&
      (a.phase != RunPhase.reward ||
          a.rewardKind != b.rewardKind ||
          a.rewardOptions.join() != b.rewardOptions.join())) {
    add(
      'botín ${b.rewardKind.name}'
      '${b.rewardAmount > 0 ? ' ${b.rewardAmount}' : ''}'
      '${b.rewardOptions.isEmpty ? '' : ': ${b.rewardOptions.join(', ')}'}',
    );
  }
  if (b.pathOptions.isNotEmpty && a.pathOptions.join() != b.pathOptions.join()) {
    add('caminos ofrecidos: ${b.pathOptions.map((s) => s.name).join(', ')}');
  }
  if (b.awakeningOptions.isNotEmpty &&
      a.awakeningOptions.join() != b.awakeningOptions.join()) {
    add('despertares ofrecidos: ${b.awakeningOptions.join(', ')}');
  }
  if (b.talismanOptions.isNotEmpty &&
      a.talismanOptions.join() != b.talismanOptions.join()) {
    add('talismanes ofrecidos: ${b.talismanOptions.join(', ')}');
  }
  if (b.weaponOptions.isNotEmpty &&
      a.weaponOptions.join() != b.weaponOptions.join()) {
    add('armas ofrecidas: ${b.weaponOptions.join(', ')}');
  }
  if (b.shopCards.isNotEmpty && a.shopCards.join() != b.shopCards.join()) {
    add(
      'mercader: cartas ${b.shopCards.join(', ')}'
      '${b.shopTalisman == null ? '' : ' · talismán ${b.shopTalisman}'}'
      '${b.shopRare == null ? '' : ' · vitrina ${b.shopRare}'}'
      '${b.shopWeapon == null ? '' : ' · arma ${b.shopWeapon}'}',
    );
  }
  if (b.eventId != null && a.eventId != b.eventId) add('evento: ${b.eventId}');
  if (b.lastEvent != null && !identical(a.lastEvent, b.lastEvent)) {
    final e = b.lastEvent!;
    add(
      'evento ${e.eventId}: elige ${e.optionId}'
      '${e.success == null ? '' : e.success! ? ' (sale bien)' : ' (sale mal)'}',
    );
  }
  if (out.isEmpty && what == null) return out;
  return [logLine([?what, ...out].join(' · '))];
}

/// La jugada, con lo que había antes (para saber qué carta y desde qué
/// postura).
String actionLine(CombatAction a, CombatState s) => switch (a) {
  PlayCard(:final uid) => () {
    final c = s.hand.where((c) => c.uid == uid).firstOrNull;
    return 'juega ${c == null ? uid : _cards([c])} desde ${s.player.stance.name}';
  }(),
  Target(:final index) => 'apunta a ${s.enemies[index].id}',
  Dingbu(:final stance) => 'dingbu a ${stance.name}',
  Breathe() => 'respira (cambia la mano)',
  EndTurn(:final retain) => retain.isEmpty
      ? 'termina el turno'
      : 'termina el turno reteniendo ${_cards(s.hand.where((c) => retain.contains(c.uid)))}',
  ChooseDiscard(:final uid) =>
    'descarta ${_cards(s.hand.where((c) => c.uid == uid))}',
  ChooseBreather(:final breather) => 'respiro: ${breather.name}',
};

/// Los efectos de una jugada, en una línea.
String eventsLine(List<CombatEvent> events) {
  final parts = <String>[];
  for (final e in events) {
    final p = switch (e) {
      TurnStarted() || CardPlayed() || EnemyActing() => null,
      CardsDrawn(:final count) => 'roba $count',
      DeckShuffled() => 'baraja',
      StanceChanged(:final stance) => 'postura ${stance.name}',
      StanceChained(:final cardId, :final from) =>
        'encadena $cardId desde ${from.name}',
      StanceCircle(:final breath, :final draw) =>
        'CÍRCULO +$breath aliento +$draw cartas',
      GuardGained(:final amount, :final height) =>
        'guardia +$amount${height == null ? '' : ' ${height.name}'}',
      EnemyDamaged(:final damage, :final structure, :final absorbed) =>
        'daño $damage, estructura $structure'
            '${absorbed > 0 ? ', absorbe $absorbed' : ''}',
      EnemyBroken() => 'ENEMIGO DESEQUILIBRADO',
      ScaleShed(:final remaining) => 'escama cae (quedan $remaining)',
      ScalesRegrown(:final scales) => 'escamas vuelven ($scales)',
      EnemyRecovered() => 'enemigo se recupera',
      EnemyActionSkipped() => 'enemigo pierde la acción',
      EnemyGuarded(:final amount, :final blocks) =>
        'enemigo guardia $amount${blocks == null ? '' : ' bloquea ${blocks.name}'}',
      EnemyCharged(:final amount) => 'enemigo carga $amount',
      EnemyPhaseChanged(:final phase) => 'enemigo fase $phase',
      PlayerHit(:final damage, :final structure, :final blocked) =>
        'RECIBE $damage${structure > 0 ? ' (estr $structure)' : ''}'
            '${blocked ? ' bloqueado' : ''}',
      Deflected() => 'DESVÍA',
      PlayerBroken() => 'HÉROE DESEQUILIBRADO',
      FormAdvanced(:final formId, :final progress) => 'forma $formId $progress',
      FormInterrupted(:final formId) => 'forma $formId cortada',
      FormCompleted(:final formId) => 'FORMA $formId completa',
      BreathGained(:final amount) => 'aliento +$amount',
      PlayerHealed(:final amount) => 'cura $amount',
      FistBonusGained(:final amount, :final total) =>
        'puño +$amount (total $total)',
      TalismanTriggered(:final talismanId) => 'talismán $talismanId',
      WeaponTriggered() => 'arma actúa',
      FormsResetByEnemy() => 'enemigo corta las formas',
      DiscardRequired(:final count) => 'debe descartar $count',
      Parried(:final damage) => 'enemigo contraataca $damage',
      EnemyEnraged(:final total) => 'ira $total',
      WrathCalmed() => 'ira calmada',
      JadeStolen(:final amount, :final total) => 'roba jade $amount ($total)',
      EnemyFled(:final stolen) => 'enemigo huye con $stolen jade',
      EnemyDefeated(:final enemyId) => 'VENCE a $enemyId',
      TargetChanged(:final index) => 'blanco $index',
      BreatherOffered() => 'respiro entre oleadas',
      BreatherTaken(:final breather) => 'toma ${breather.name}',
      WaveStarted(:final enemyId, :final index, :final total) =>
        'entra $enemyId ($index/$total)',
      Victory() => 'VICTORIA',
      Defeat() => 'DERROTA',
      ThornsHurt(:final damage) => 'espinas $damage',
      EnemyRegenerated(:final amount) => 'enemigo regenera $amount',
      BreathDrained(:final amount) => 'pierde $amount aliento',
      HandFrozen(:final amount) => 'mano congelada $amount',
      GuardBypassed() => 'guardia atravesada',
    };
    if (p != null) parts.add(p);
  }
  return parts.join('; ');
}

/// Cómo está la pelea al empezar un turno.
List<String> turnSnapshot(CombatState s, CombatEngine engine) {
  final p = s.player;
  return [
    '  -- turno ${s.turn}: vida ${p.hp}/${p.maxHp} · estr ${p.structure}/${p.maxStructure}'
        ' · guardia ${p.guard} · aliento ${p.breath} · postura ${p.stance.name}'
        ' · mazo ${s.drawPile.length} descarte ${s.discard.length}',
    '     mano: ${_cards(s.hand)}',
    for (final (i, e) in s.enemies.indexed)
      () {
        if (e.hp <= 0 || s.isOver) {
          return '     ${e.id}: vida ${e.hp}/${e.maxHp} · estr ${e.structure}/${e.maxStructure}';
        }
        final iv = engine.intentView(s, i);
        final it = iv.intent;
        return '     ${e.id}: vida ${e.hp}/${e.maxHp} · estr ${e.structure}/${e.maxStructure}'
            '${e.guard > 0 ? ' · guardia ${e.guard}' : ''}'
            '${e.staggered ? ' · DESEQUILIBRADO' : ''}'
            ' · intención ${it.kind.name}'
            '${it.height == null ? '' : ' ${it.height!.name}'}'
            '${iv.damage > 0 ? ' ${iv.damage}${it.hits > 1 ? 'x${it.hits}' : ''}' : ''}'
            '${iv.structure > 0 ? ' E${iv.structure}' : ''}'
            '${iv.skipped ? ' (pierde la acción)' : ''}';
      }(),
  ];
}

/// Inicio de un combate.
List<String> combatHeader(CombatState s, List<String> pack) => [
  logLine(
    'COMBATE contra ${pack.join(' → ')}: vida ${s.player.hp}/${s.player.maxHp}'
    ' · mazo ${s.drawPile.length + s.hand.length + s.discard.length}',
  ),
];
