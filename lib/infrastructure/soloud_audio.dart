import 'dart:math' as math;

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../delivery/audio/game_audio.dart';

/// Audio real con SoLoud (baja latencia, varias voces a la vez, loops sin corte).
///
/// Busca cada id en `assets/audio/` con cualquiera de las extensiones
/// soportadas; lo que no está en el bundle simplemente no suena.
class SoloudAudio implements GameAudio {
  SoloudAudio._(this._prefs, this._sfxPaths, this._musicPaths)
      : sfxOn = _prefs.getBool(_sfxKey) ?? true,
        musicOn = _prefs.getBool(_musicKey) ?? true;

  static const _sfxKey = 'long_breath.sfxOn';
  static const _musicKey = 'long_breath.musicOn';
  static const _exts = ['.wav', '.ogg', '.mp3', '.flac'];
  static const _musicVolume = 0.35;
  static const _duckedVolume = 0.12;
  static const _fade = Duration(milliseconds: 600);

  final SharedPreferences _prefs;
  final Map<String, String> _sfxPaths;
  final Map<String, String> _musicPaths;
  final _sfx = <String, AudioSource>{};
  final _rnd = math.Random();
  final _soloud = SoLoud.instance;

  Music? _track;
  AudioSource? _trackSource;
  SoundHandle? _trackHandle;
  SoundHandle? _jingleHandle;

  @override
  bool sfxOn;
  @override
  bool musicOn;

  /// Prepara la sesión de audio y precarga los efectos presentes.
  static Future<SoloudAudio> create() async {
    final prefs = await SharedPreferences.getInstance();
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    Map<String, String> index(String dir) => {
          for (final a in manifest.listAssets())
            if (a.startsWith(dir) && _exts.any(a.endsWith))
              a.substring(dir.length, a.lastIndexOf('.')): a,
        };
    final audio = SoloudAudio._(
        prefs, index('assets/audio/sfx/'), index('assets/audio/music/'));

    // Ambient: respeta el modo silencio y convive con la música del usuario.
    final session = await AudioSession.instance;
    await session.configure(const AudioSessionConfiguration(
      avAudioSessionCategory: AVAudioSessionCategory.ambient,
      avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
      androidAudioAttributes: AndroidAudioAttributes(
        contentType: AndroidAudioContentType.sonification,
        usage: AndroidAudioUsage.game,
      ),
      androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
      androidWillPauseWhenDucked: false,
    ));
    await session.setActive(true);
    await audio._soloud.init(bufferSize: 512);
    for (final e in audio._sfxPaths.entries) {
      audio._sfx[e.key] = await audio._soloud.loadAsset(e.value);
    }
    debugPrint('audio: ${audio._sfx.length} efectos y '
        '${audio._musicPaths.length} pistas encontradas');
    return audio;
  }

  @override
  void play(Sfx sfx, {int? variant}) {
    if (!sfxOn) return;
    final n = sfx.variants;
    final name = n == 1 ? sfx.id : '${sfx.id}_${(variant ?? _rnd.nextInt(n)) % n + 1}';
    // Si faltan variantes, cae al archivo sin número.
    final source = _sfx[name] ?? _sfx[sfx.id];
    if (source == null) return;
    _guard(() {
      final h = _soloud.play(source, volume: sfx.volume);
      // Los que se repiten mucho varían un poco el tono para no sonar a máquina.
      if (n > 1 && variant == null) {
        _soloud.setRelativePlaySpeed(h, 0.94 + _rnd.nextDouble() * 0.12);
      }
    });
  }

  @override
  void voice(String enemyId) {
    final source = _sfx['enemy_$enemyId'];
    if (!sfxOn || source == null) return;
    _guard(() => _soloud.play(source, volume: 0.7));
  }

  @override
  void music(Music track) {
    if (_track == track) return;
    _track = track;
    if (musicOn) _startTrack();
  }

  Future<void> _startTrack() async {
    final track = _track;
    final old = _trackHandle;
    final oldSource = _trackSource;
    _trackHandle = null;
    _trackSource = null;
    if (old != null) {
      _guard(() {
        _soloud.fadeVolume(old, 0, _fade);
        _soloud.scheduleStop(old, _fade);
      });
      if (oldSource != null) {
        Future.delayed(_fade + const Duration(milliseconds: 100),
            () => _guard(() => _soloud.disposeSource(oldSource)));
      }
    }
    final path = track == null ? null : _musicPaths[track.id];
    if (path == null) return;
    try {
      // Las pistas largas se decodifican de a poco para no ocupar memoria.
      final source = await _soloud.loadAsset(path, mode: LoadMode.disk);
      if (_track != track || !musicOn) {
        await _soloud.disposeSource(source);
        return;
      }
      final h = _soloud.play(source, volume: 0, looping: true);
      _soloud.fadeVolume(h, _jingleHandle == null ? _musicVolume : _duckedVolume, _fade);
      _trackSource = source;
      _trackHandle = h;
    } catch (e) {
      debugPrint('audio: $e');
    }
  }

  @override
  void jingle(Music track) {
    final path = _musicPaths[track.id];
    if (!musicOn || path == null) return;
    () async {
      try {
        final source = await _soloud.loadAsset(path, mode: LoadMode.disk);
        final h = _soloud.play(source, volume: 0.8);
        _jingleHandle = h;
        final bg = _trackHandle;
        if (bg != null) _soloud.fadeVolume(bg, _duckedVolume, const Duration(milliseconds: 300));
        final len = _soloud.getLength(source);
        await Future.delayed(len + const Duration(milliseconds: 200));
        if (_jingleHandle == h) {
          _jingleHandle = null;
          final bg = _trackHandle;
          if (bg != null) _guard(() => _soloud.fadeVolume(bg, _musicVolume, const Duration(seconds: 2)));
        }
        await _soloud.disposeSource(source);
      } catch (e) {
        debugPrint('audio: $e');
      }
    }();
  }

  @override
  void stopMusic() {
    _track = null;
    _startTrack();
  }

  @override
  Future<void> setSfxOn(bool on) async {
    sfxOn = on;
    await _prefs.setBool(_sfxKey, on);
  }

  @override
  Future<void> setMusicOn(bool on) async {
    musicOn = on;
    await _prefs.setBool(_musicKey, on);
    if (on) {
      _startTrack();
    } else {
      final track = _track;
      _track = null;
      await _startTrack();
      _track = track;
    }
  }

  void _guard(void Function() f) {
    try {
      f();
    } catch (e) {
      debugPrint('audio: $e');
    }
  }
}
