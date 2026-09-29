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

enum Age {
  young,
  adult,
  elder;

  static Age parse(String s) => Age.values.byName(s);
}

enum EnemyRank {
  common,
  elite,
  boss;

  static EnemyRank parse(String s) => EnemyRank.values.byName(s);
}
