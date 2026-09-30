enum CardType {
  fist,
  palm,
  kick,
  defense,
  technique;

  bool get isAttack => this == fist || this == palm || this == kick;

  static CardType parse(String s) => CardType.values.byName(s);
}

enum Height {
  high,
  mid,
  low;

  static Height? parse(String? s) => s == null ? null : Height.values.byName(s);
}

enum Stance {
  mabu,
  gongbu,
  xubu;

  static Stance? parse(String? s) => s == null ? null : Stance.values.byName(s);
}

enum Style {
  tiger,
  snake,
  crane;

  /// Acepta los nombres viejos (young/adult/elder) de runs guardadas.
  static Style parse(String s) => Style.values.byName(
      const {'young': 'tiger', 'adult': 'snake', 'elder': 'crane'}[s] ?? s);
}

enum EnemyRank {
  common,
  elite,
  boss;

  static EnemyRank parse(String s) => EnemyRank.values.byName(s);
}
