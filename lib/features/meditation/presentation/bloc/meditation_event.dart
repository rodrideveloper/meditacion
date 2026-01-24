import 'package:equatable/equatable.dart';

/// Eventos del BLoC de meditación
abstract class MeditationEvent extends Equatable {
  const MeditationEvent();

  @override
  List<Object?> get props => [];
}

/// Cargar configuración guardada
class LoadSettingsEvent extends MeditationEvent {
  const LoadSettingsEvent();
}

/// Cambiar duración seleccionada
class ChangeDurationEvent extends MeditationEvent {
  final int minutes;

  const ChangeDurationEvent(this.minutes);

  @override
  List<Object> get props => [minutes];
}

/// Cambiar sonido seleccionado
class ChangeSoundEvent extends MeditationEvent {
  final String soundId;

  const ChangeSoundEvent(this.soundId);

  @override
  List<Object> get props => [soundId];
}

/// Cambiar estado de vibración
class ToggleVibrationEvent extends MeditationEvent {
  const ToggleVibrationEvent();
}

/// Iniciar meditación
class StartMeditationEvent extends MeditationEvent {
  const StartMeditationEvent();
}

/// Cancelar meditación
class CancelMeditationEvent extends MeditationEvent {
  const CancelMeditationEvent();
}

/// Meditación completada (alarma sonó)
class MeditationCompletedEvent extends MeditationEvent {
  const MeditationCompletedEvent();
}

/// Resetear estado
class ResetMeditationEvent extends MeditationEvent {
  const ResetMeditationEvent();
}
