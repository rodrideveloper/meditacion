import 'package:equatable/equatable.dart';
import '../../../../core/constants/sound_constants.dart';

/// Entidad que representa la configuración guardada del usuario
class MeditationSettings extends Equatable {
  /// Última duración usada (en minutos)
  final int lastDurationMinutes;

  /// ID del sonido seleccionado
  final String selectedSoundId;

  /// Si la vibración está habilitada
  final bool vibrationEnabled;

  /// Volumen máximo de la alarma (0.0 a 1.0)
  final double alarmVolume;

  const MeditationSettings({
    required this.lastDurationMinutes,
    required this.selectedSoundId,
    required this.vibrationEnabled,
    this.alarmVolume = 0.8,
  });

  /// Obtener el sonido seleccionado
  MeditationSound get selectedSound =>
      MeditationSound.getById(selectedSoundId) ?? MeditationSound.defaultSound;

  /// Obtener la duración como Duration
  Duration get duration => Duration(minutes: lastDurationMinutes);

  /// Configuración por defecto
  factory MeditationSettings.defaults() {
    return const MeditationSettings(
      lastDurationMinutes: 10,
      selectedSoundId: 'angelical',
      vibrationEnabled: true,
      alarmVolume: 0.8,
    );
  }

  /// Crear copia con nuevos valores
  MeditationSettings copyWith({
    int? lastDurationMinutes,
    String? selectedSoundId,
    bool? vibrationEnabled,
    double? alarmVolume,
  }) {
    return MeditationSettings(
      lastDurationMinutes: lastDurationMinutes ?? this.lastDurationMinutes,
      selectedSoundId: selectedSoundId ?? this.selectedSoundId,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      alarmVolume: alarmVolume ?? this.alarmVolume,
    );
  }

  @override
  List<Object> get props => [
    lastDurationMinutes,
    selectedSoundId,
    vibrationEnabled,
    alarmVolume,
  ];
}
