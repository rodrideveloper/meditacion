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
  bool _isPlaying = false;

  /// Estado de reproducción
  bool get isPlaying => _isPlaying;

  /// Inicializar el servicio de audio
  Future<void> initialize() async {
    _player = AudioPlayer();

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

  /// Reproducir sonido de preview (una vez)
  Future<void> playPreview(MeditationSound sound) async {
    try {
      await stop();
      _player ??= AudioPlayer();

      await _player!.setAsset(sound.assetPath);
      await _player!.setLoopMode(LoopMode.off);
      await _player!.play();

      _isPlaying = true;

      // Escuchar cuando termine
      _player!.playerStateStream.listen((state) {
        if (state.processingState == ProcessingState.completed) {
          _isPlaying = false;
        }
      });
    } catch (e) {
      debugPrint('Error playing preview: $e');
      _isPlaying = false;
    }
  }

  /// Reproducir alarma (en loop)
  Future<void> playAlarm(MeditationSound sound) async {
    try {
      await stop();
      _player ??= AudioPlayer();

      await _player!.setAsset(sound.assetPath);
      await _player!.setLoopMode(LoopMode.one);
      await _player!.setVolume(1.0);
      await _player!.play();

      _isPlaying = true;
      debugPrint('Alarm sound started');
    } catch (e) {
      debugPrint('Error playing alarm: $e');
      _isPlaying = false;
    }
  }

  /// Detener reproducción
  Future<void> stop() async {
    try {
      if (_player != null) {
        await _player!.stop();
        _isPlaying = false;
        debugPrint('Audio stopped');
      }
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
      await _player?.dispose();
      _player = null;
      _isPlaying = false;
      debugPrint('AudioService disposed');
    } catch (e) {
      debugPrint('Error disposing audio: $e');
    }
  }
}
