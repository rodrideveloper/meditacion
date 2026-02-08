import 'dart:async';

import 'package:audio_session/audio_session.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

import '../constants/sound_constants.dart';

/// Servicio para manejar la reproducción de audio
class AudioService {
  static final AudioService _instance = AudioService._internal();
  factory AudioService() => _instance;
  AudioService._internal();

  AudioPlayer? _player;
  StreamSubscription? _playerStateSub;
  bool _isPlaying = false;
  String? _currentPreviewId;

  /// Estado de reproducción
  bool get isPlaying => _isPlaying;

  /// ID del sonido en preview actualmente (null si no hay)
  String? get currentPreviewId => _isPlaying ? _currentPreviewId : null;

  /// Inicializar el servicio de audio
  Future<void> initialize() async {
    // Configurar audio session para usar el canal de alarma
    final session = await AudioSession.instance;
    await session.configure(
      const AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playback,
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.mixWithOthers,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        avAudioSessionRouteSharingPolicy:
            AVAudioSessionRouteSharingPolicy.defaultPolicy,
        avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.none,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.sonification,
          usage: AndroidAudioUsage.alarm, // Usar canal de ALARMA
          flags: AndroidAudioFlags.audibilityEnforced,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
        androidWillPauseWhenDucked: false,
      ),
    );

    debugPrint('AudioService initialized with ALARM stream');
  }

  /// Crea un AudioPlayer limpio, liberando el anterior si existe
  Future<AudioPlayer> _freshPlayer() async {
    await _playerStateSub?.cancel();
    _playerStateSub = null;
    // Dispose en background para no bloquear la creación del nuevo player
    final oldPlayer = _player;
    _player = null;
    oldPlayer?.dispose(); // fire-and-forget
    final player = AudioPlayer();
    _player = player;
    return player;
  }

  /// Reproducir sonido de preview (una vez)
  Future<void> playPreview(MeditationSound sound) async {
    try {
      final player = await _freshPlayer();

      debugPrint('Preview: loading asset ${sound.assetPath} (id: ${sound.id})');
      final duration = await player.setAsset(sound.assetPath);
      debugPrint('Preview: asset loaded, duration=$duration');
      await player.setLoopMode(LoopMode.off);
      await player.setVolume(1.0);
      await player.seek(Duration.zero);
      await player.play();
      debugPrint('Preview: playing ${sound.id}');

      _isPlaying = true;
      _currentPreviewId = sound.id;

      // Escuchar cuando termine
      _playerStateSub = player.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
          _currentPreviewId = null;
        }
      });
    } catch (e) {
      debugPrint('Error playing preview: $e');
      _isPlaying = false;
      _currentPreviewId = null;
    }
  }

  /// Reproducir alarma (en loop con fade-in suave)
  Future<void> playAlarm(
    MeditationSound sound, {
    double maxVolume = 1.0,
  }) async {
    try {
      final player = await _freshPlayer();

      final targetVolume = maxVolume.clamp(0.0, 1.0);
      debugPrint('Alarm: loading asset ${sound.assetPath}');
      final duration = await player.setAsset(sound.assetPath);
      debugPrint('Alarm: asset loaded, duration=$duration');
      await player.setLoopMode(LoopMode.one);
      debugPrint('Alarm: loop mode set');

      // Arrancar directamente al volumen objetivo (sin fade-in problemático)
      await player.setVolume(targetVolume);
      debugPrint('Alarm: volume set to $targetVolume');
      player
          .play(); // No await — play() es un Future que se completa cuando termina
      _isPlaying = true;
      debugPrint('Alarm sound started at volume $targetVolume');
    } catch (e) {
      debugPrint('Error playing alarm: $e');
      _isPlaying = false;
    }
  }

  /// Sube el volumen gradualmente de 0 a [targetVolume] en ~5 segundos
  Future<void> _fadeIn(double targetVolume) async {
    const steps = 25;
    const stepDuration = Duration(milliseconds: 200); // 25 × 200ms = 5s
    for (var i = 1; i <= steps; i++) {
      if (!_isPlaying || _player == null) return;
      final volume = (i / steps) * targetVolume;
      await _player!.setVolume(volume);
      await Future.delayed(stepDuration);
    }
  }

  /// Detener reproducción
  Future<void> stop() async {
    try {
      await _playerStateSub?.cancel();
      _playerStateSub = null;
      if (_player != null) {
        await _player!.stop();
        await _player!.dispose();
        _player = null;
      }
      _isPlaying = false;
      _currentPreviewId = null;
      debugPrint('Audio stopped');
    } catch (e) {
      debugPrint('Error stopping audio: $e');
    }
  }

  /// Pausar reproducción
  Future<void> pause() async {
    try {
      if (_player != null && _isPlaying) {
        await _player!.pause();
        _isPlaying = false;
      }
    } catch (e) {
      debugPrint('Error pausing audio: $e');
    }
  }

  /// Reanudar reproducción
  Future<void> resume() async {
    try {
      if (_player != null && !_isPlaying) {
        await _player!.play();
        _isPlaying = true;
      }
    } catch (e) {
      debugPrint('Error resuming audio: $e');
    }
  }

  /// Ajustar volumen (0.0 a 1.0)
  Future<void> setVolume(double volume) async {
    try {
      if (_player != null) {
        await _player!.setVolume(volume.clamp(0.0, 1.0));
      }
    } catch (e) {
      debugPrint('Error setting volume: $e');
    }
  }

  /// Liberar recursos
  Future<void> dispose() async {
    try {
      await _playerStateSub?.cancel();
      _playerStateSub = null;
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
      _currentPreviewId = null;
      debugPrint('AudioService disposed');
    } catch (e) {
      debugPrint('Error disposing audio: $e');
    }
  }
}
