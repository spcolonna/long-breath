import 'card_def.dart';
import 'enemy_def.dart';
import 'enums.dart';
import 'event_def.dart';
import 'form_def.dart';
import 'game_balance.dart';
import 'stance_def.dart';
import 'talisman_def.dart';
import 'weapon_def.dart';

/// Todo el contenido del juego cargado desde assets/data.
class GameData {
  GameData({
    required List<CardDef> cards,
    required List<StanceDef> stances,
    required this.transition,
    required this.forms,
    required List<EnemyDef> enemies,
    required this.balance,
    List<TalismanDef> talismans = const [],
    this.events = const [],
    List<WeaponDef> weapons = const [],
  })  : cards = {for (final c in cards) c.id: c},
        talismans = {for (final t in talismans) t.id: t},
        weapons = {for (final w in weapons) w.id: w},
        stances = {for (final s in stances) s.id: s},
        enemies = {for (final e in enemies) e.id: e};

  final Map<String, CardDef> cards;
  final Map<Stance, StanceDef> stances;
  final TransitionDef transition;
  final List<FormDef> forms;
  final Map<String, EnemyDef> enemies;
  final GameBalance balance;
  final Map<String, TalismanDef> talismans;
  final List<EventDef> events;
  final Map<String, WeaponDef> weapons;

  CardDef card(String id) =>
      cards[id] ?? (throw ArgumentError('Carta desconocida: $id'));

  EnemyDef enemy(String id) =>
      enemies[id] ?? (throw ArgumentError('Enemigo desconocido: $id'));

  StanceDef stance(Stance s) => stances[s]!;

  TalismanDef talisman(String id) =>
      talismans[id] ?? (throw ArgumentError('Talismán desconocido: $id'));

  WeaponDef weapon(String id) =>
      weapons[id] ?? (throw ArgumentError('Arma desconocida: $id'));

  /// El arma a la que pertenece una carta (su pool es el id del arma).
  WeaponDef? weaponOfCard(CardDef c) => weapons[c.pool];

  EventDef event(String id) => events.firstWhere((e) => e.id == id);

  /// Mazo inicial expandido por copias.
  List<String> get starterDeck => [
        for (final c in cards.values.where((c) => c.pool == 'starter'))
          for (var i = 0; i < c.copies; i++) c.id,
      ];

  List<CardDef> get rewardPool => cards.values
      .where((c) => balance.rewardPools.contains(c.pool))
      .toList();

  /// Recompensas que puede ver quien sigue [style]: las cartas de un camino
  /// (pool con el nombre del camino) solo le salen a ese camino, y las que
  /// el cultivo todavía no abrió ([locked]) no salen. Con [weapon] se suman
  /// las cartas de los niveles del arma hasta [weaponLevel].
  List<CardDef> rewardPoolFor(
    Style? style, {
    List<String> locked = const [],
    String? weapon,
    int weaponLevel = 0,
  }) => [
        for (final c in rewardPool)
          if ((!Style.values.any((s) => s.name == c.pool) ||
                  c.pool == style?.name) &&
              !locked.contains(c.id))
            c,
        if (weapon != null && weapons[weapon] != null)
          for (final id in weapons[weapon]!.cardsUpTo(weaponLevel))
            if (!locked.contains(id)) card(id),
      ];

  /// Construye GameData desde los JSON ya decodificados (sin Flutter).
  factory GameData.fromJson({
    required Map<String, dynamic> cards,
    required Map<String, dynamic> stances,
    required Map<String, dynamic> forms,
    required Map<String, dynamic> enemies,
    required Map<String, dynamic> balance,
    Map<String, dynamic>? talismans,
    Map<String, dynamic>? events,
    Map<String, dynamic>? weapons,
  }) =>
      GameData(
        cards: [
          for (final c in cards['cards'] as List)
            CardDef.fromJson(c as Map<String, dynamic>),
        ],
        stances: [
          for (final s in stances['stances'] as List)
            StanceDef.fromJson(s as Map<String, dynamic>),
        ],
        transition: TransitionDef.fromJson(
            stances['transition'] as Map<String, dynamic>),
        forms: [
          for (final f in forms['forms'] as List)
            FormDef.fromJson(f as Map<String, dynamic>),
        ],
        enemies: [
          for (final e in enemies['enemies'] as List)
            EnemyDef.fromJson(e as Map<String, dynamic>),
        ],
        balance: GameBalance.fromJson(balance),
        talismans: [
          for (final t in (talismans?['talismans'] as List?) ?? const [])
            TalismanDef.fromJson(t as Map<String, dynamic>),
        ],
        events: [
          for (final e in (events?['events'] as List?) ?? const [])
            EventDef.fromJson(e as Map<String, dynamic>),
        ],
        weapons: [
          for (final w in (weapons?['weapons'] as List?) ?? const [])
            WeaponDef.fromJson(w as Map<String, dynamic>),
        ],
      );

  static const fileNames = [
    'cards.json',
    'stances.json',
    'forms.json',
    'enemies.json',
    'game_balance.json',
    'talismans.json',
    'events.json',
    'weapons.json',
  ];
}
