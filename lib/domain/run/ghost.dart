import '../combat/combat_state.dart';
import '../model/enums.dart';
import '../model/game_data.dart';
import 'ascent.dart';

/// Id del rival que lleva la cinta de un caído.
const ghostEnemy = 'disciple';

/// Un discípulo caído del registro que vuelve en la subida como el
/// Discípulo Perdido: su número, su camino, dónde cayó y la carta que
/// lleva (la que suelta al vencerlo).
class Ghost {
  const Ghost({
    required this.n,
    required this.floor,
    this.style,
    this.card,
    this.upgrades = 0,
    this.claimedAt,
    this.dropped,
  });

  final int n;
  final int floor;
  final Style? style;

  /// Su carta guardada en el registro (null en registros viejos: suelta
  /// una de su camino).
  final String? card;
  final int upgrades;

  /// Nodo donde se lo venció (ya soltó su carta) y la carta que dejó.
  final String? claimedAt;
  final String? dropped;

  Ghost claim(String node, String cardId) => Ghost(
    n: n,
    floor: floor,
    style: style,
    card: card,
    upgrades: upgrades,
    claimedAt: node,
    dropped: cardId,
  );

  Map<String, dynamic> toJson() => {
    'n': n,
    'floor': floor,
    'style': style?.name,
    'card': card,
    'upgrades': upgrades,
    'claimedAt': claimedAt,
    'dropped': dropped,
  };

  factory Ghost.fromJson(Map<String, dynamic> j) => Ghost(
    n: j['n'] as int,
    floor: j['floor'] as int? ?? 0,
    style: switch (j['style']) {
      final String s => Style.parse(s),
      _ => null,
    },
    card: j['card'] as String?,
    upgrades: j['upgrades'] as int? ?? 0,
    claimedAt: j['claimedAt'] as String?,
    dropped: j['dropped'] as String?,
  );
}

/// El caído más reciente del registro, o null si nadie cayó todavía.
Ghost? ghostFrom(List<Ascent> ascents) {
  for (final a in ascents.reversed) {
    if (!a.fell) continue;
    return Ghost(
      n: a.n,
      floor: a.floor,
      style: a.style,
      card: a.keepsake,
      upgrades: a.keepsakeUp,
    );
  }
  return null;
}

/// La carta que un discípulo deja en el registro al terminar: la de su
/// camino más mejorada; si no tiene, la más mejorada que no sea de las
/// iniciales; si solo tiene iniciales, ninguna.
CombatCard? keepsakeOf(GameData data, List<CombatCard> deck, Style? style) {
  int rank(CombatCard c) {
    final pool = data.cards[c.cardId]?.pool ?? 'starter';
    if (pool == 'starter') return -1;
    return (pool == style?.name ? 100 : 0) + c.upgrades;
  }

  CombatCard? best;
  for (final c in deck) {
    if (rank(c) < 0) continue;
    if (best == null || rank(c) > rank(best)) best = c;
  }
  return best;
}
