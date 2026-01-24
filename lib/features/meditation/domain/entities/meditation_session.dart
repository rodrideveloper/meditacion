import 'package:equatable/equatable.dart';
import '../../../../core/constants/sound_constants.dart';

/// Entidad que representa una sesión de meditación
class MeditationSession extends Equatable {
  /// Duración total de la sesión
  final Duration duration;

  /// Sonido seleccionado para la alarma
  final MeditationSound sound;

  /// Si la vibración está habilitada
  final bool vibrationEnabled;

  /// Hora de inicio de la sesión (null si no ha iniciado)
  final DateTime? startTime;

  /// Estado de la sesión
  final MeditationStatus status;

  const MeditationSession({
    required this.duration,
    required this.sound,
    this.vibrationEnabled = true,
    this.startTime,
    this.status = MeditationStatus.idle,
  });

  /// Tiempo restante calculado
  Duration get remainingTime {
    if (startTime == null || status != MeditationStatus.active) {
      return duration;
    }
    final elapsed = DateTime.now().difference(startTime!);
    final remaining = duration - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Hora de finalización esperada
  DateTime? get expectedEndTime {
    if (startTime == null) return null;
    return startTime!.add(duration);
  }

  /// Crear copia con nuevos valores
  MeditationSession copyWith({
    Duration? duration,
    MeditationSound? sound,
    bool? vibrationEnabled,
    DateTime? startTime,
    MeditationStatus? status,
  }) {
    return MeditationSession(
      duration: duration ?? this.duration,
      sound: sound ?? this.sound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      startTime: startTime ?? this.startTime,
      status: status ?? this.status,
    );
  }

  /// Sesión por defecto
  factory MeditationSession.defaultSession() {
    return MeditationSession(
      duration: const Duration(minutes: 10),
      sound: MeditationSound.defaultSound,
      vibrationEnabled: true,
    );
  }

  @override
  List<Object?> get props => [duration, sound, vibrationEnabled, startTime, status];
}

/// Estado de la sesión de meditación
enum MeditationStatus {
  /// Sin sesión activa
  idle,

  /// Sesión en progreso
  active,

  /// Sesión pausada
  paused,

  /// Sesión completada
  completed,

  /// Sesión cancelada
  cancelled,
}
