/// Lo que el discípulo anterior le deja al siguiente: el nuevo elige su
/// carta (con la mitad de las mejoras) o algo de lo que alcanzó.
class Legacy {
  const Legacy({
    required this.n,
    this.card,
    this.upgrades = 0,
    this.maxHp = 0,
    this.jade = 0,
  });

  /// Número del discípulo que deja el legado.
  final int n;

  /// Su carta guardada (null si solo tenía iniciales) y las mejoras que
  /// conserva.
  final String? card;
  final int upgrades;

  /// La otra opción: Vida máxima si pasó de la primera etapa; si no, jade.
  final int maxHp;
  final int jade;

  Map<String, dynamic> toJson() => {
    'n': n,
    'card': card,
    'upgrades': upgrades,
    'maxHp': maxHp,
    'jade': jade,
  };

  factory Legacy.fromJson(Map<String, dynamic> j) => Legacy(
    n: j['n'] as int,
    card: j['card'] as String?,
    upgrades: j['upgrades'] as int? ?? 0,
    maxHp: j['maxHp'] as int? ?? 0,
    jade: j['jade'] as int? ?? 0,
  );
}

/// Qué heredar: la carta o los números.
enum LegacyPick { card, stat }
