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

  const MeditationSettings({
    required this.lastDurationMinutes,
    required this.selectedSoundId,
    required this.vibrationEnabled,
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
    );
  }

  /// Crear copia con nuevos valores
  MeditationSettings copyWith({
    int? lastDurationMinutes,
    String? selectedSoundId,
    bool? vibrationEnabled,
  }) {
    return MeditationSettings(
      lastDurationMinutes: lastDurationMinutes ?? this.lastDurationMinutes,
      selectedSoundId: selectedSoundId ?? this.selectedSoundId,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  @override
  List<Object> get props => [
    lastDurationMinutes,
    selectedSoundId,
    vibrationEnabled,
  ];
}
