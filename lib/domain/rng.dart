/// Generador pseudoaleatorio con semilla (xorshift32), reproducible en
/// cualquier plataforma. Inmutable: cada operación devuelve el nuevo estado.
class Rng {
  const Rng(this.state);

  factory Rng.seeded(int seed) {
    var s = seed & 0xFFFFFFFF;
    if (s == 0) s = 0x9E3779B9;
    return Rng(s);
  }

  final int state;

  (int, Rng) _next() {
    var x = state;
    x ^= (x << 13) & 0xFFFFFFFF;
    x ^= x >> 17;
    x ^= (x << 5) & 0xFFFFFFFF;
    x &= 0xFFFFFFFF;
    return (x, Rng(x));
  }

  /// Entero en [0, max).
  (int, Rng) nextInt(int max) {
    final (v, r) = _next();
    return (v % max, r);
  }

  /// Fisher–Yates.
  (List<T>, Rng) shuffle<T>(List<T> items) {
    final list = [...items];
    var rng = this;
    for (var i = list.length - 1; i > 0; i--) {
      final (j, r) = rng.nextInt(i + 1);
      rng = r;
      final t = list[i];
      list[i] = list[j];
      list[j] = t;
    }
    return (list, rng);
  }
}
