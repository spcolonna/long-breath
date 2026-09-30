/// Efectos de sonido. El id es el nombre del archivo en `assets/audio/sfx/`
/// (sin extensión); con variantes se buscan `<id>_1`, `<id>_2`, ...
/// Ver `docs/arte/sonido.md`.
enum Sfx {
  cardDeal('card_deal', variants: 3, volume: 0.5),
  cardSelect('card_select', volume: 0.5),
  cardDeny('card_deny', volume: 0.6),
  cardPlay('card_play', volume: 0.6),
  hitLight('hit_light', variants: 3),
  hitHeavy('hit_heavy', variants: 2),
  block('block'),
  playerHurt('player_hurt', variants: 2),
  deflect('deflect'),
  guardUp('guard_up', volume: 0.8),
  enemyWindup('enemy_windup', volume: 0.7),
  turnStart('turn_start', volume: 0.8),
  victoryStamp('victory_stamp'),
  defeatStamp('defeat_stamp'),
  fightStart('fight_start', volume: 0.8),
  enemyDrop('enemy_drop', volume: 0.7),
  broken('break'),
  enemyGuard('enemy_guard', volume: 0.8),
  enemyCharge('enemy_charge', volume: 0.8),
  enemySkip('enemy_skip', volume: 0.8),
  enemyDeath('enemy_death'),
  heroVictory('hero_victory', volume: 0.8),
  heroFall('hero_fall'),
  stanceChange('stance_change', volume: 0.7),
  formStep('form_step', variants: 5, volume: 0.8),
  formComplete('form_complete'),
  formBroken('form_broken', volume: 0.8),
  breathGain('breath_gain', volume: 0.7),
  breathSpend('breath_spend', volume: 0.6),
  phaseTwo('phase_two'),
  endRays('end_rays', volume: 0.6),
  uiButton('ui_button', volume: 0.5),
  screenTransition('screen_transition', volume: 0.4),
  mapNode('map_node', volume: 0.6),
  rewardFlip('reward_flip', variants: 3, volume: 0.6),
  rewardTake('reward_take', volume: 0.8),
  fountainHeal('fountain_heal'),
  shrineOath('shrine_oath'),
  runResult('run_result');

  const Sfx(this.id, {this.variants = 1, this.volume = 1});

  final String id;
  final int variants;

  /// Volumen relativo de la mezcla (golpes 100 %, cartas y UI 50 %).
  final double volume;
}

/// Música y jingles. El id es el nombre del archivo en `assets/audio/music/`.
enum Music {
  menu('music_menu'),
  training('music_training'),
  combat('music_combat'),
  elite('music_elite'),
  boss('music_boss'),
  victory('jingle_victory', loop: false),
  defeat('jingle_defeat', loop: false),
  runWon('jingle_run_won', loop: false);

  const Music(this.id, {this.loop = true});

  final String id;
  final bool loop;
}

/// Audio del juego. Los archivos que falten se ignoran en silencio, así el
/// juego funciona igual mientras el arte sonoro se va sumando.
abstract class GameAudio {
  bool get sfxOn;
  bool get musicOn;

  /// Dispara un efecto. Con variantes elige una al azar y le varía el tono.
  /// [variant] fuerza una (0-based), p. ej. la nota de cada paso de forma.
  void play(Sfx sfx, {int? variant});

  /// Voz propia de cada enemigo: `enemy_<id>` en `assets/audio/sfx/`.
  void voice(String enemyId);

  /// Cambia la música de fondo con fundido. La misma pista no se reinicia.
  void music(Music track);

  /// Toca un jingle sin loop y baja la música de fondo mientras suena.
  void jingle(Music track);

  void stopMusic();

  Future<void> setSfxOn(bool on);
  Future<void> setMusicOn(bool on);
}

/// Sin audio: tests y arranque, hasta que el motor real está listo.
class SilentAudio implements GameAudio {
  @override
  bool sfxOn = true;
  @override
  bool musicOn = true;
  @override
  void play(Sfx sfx, {int? variant}) {}
  @override
  void voice(String enemyId) {}
  @override
  void music(Music track) {}
  @override
  void jingle(Music track) {}
  @override
  void stopMusic() {}
  @override
  Future<void> setSfxOn(bool on) async => sfxOn = on;
  @override
  Future<void> setMusicOn(bool on) async => musicOn = on;
}
