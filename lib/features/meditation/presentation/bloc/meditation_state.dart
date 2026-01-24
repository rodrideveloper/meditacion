import 'package:equatable/equatable.dart';
import '../../../../core/constants/sound_constants.dart';
import '../../domain/entities/meditation_session.dart';

/// Estados del BLoC de meditación
abstract class MeditationState extends Equatable {
  const MeditationState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class MeditationInitial extends MeditationState {
  const MeditationInitial();
}

/// Cargando configuración
class MeditationLoading extends MeditationState {
  const MeditationLoading();
}

/// Estado listo para iniciar meditación
class MeditationReady extends MeditationState {
  final int durationMinutes;
  final MeditationSound selectedSound;
  final bool vibrationEnabled;

  const MeditationReady({
    required this.durationMinutes,
    required this.selectedSound,
    required this.vibrationEnabled,
  });

  @override
  List<Object> get props => [durationMinutes, selectedSound, vibrationEnabled];

  MeditationReady copyWith({
    int? durationMinutes,
    MeditationSound? selectedSound,
    bool? vibrationEnabled,
  }) {
    return MeditationReady(
      durationMinutes: durationMinutes ?? this.durationMinutes,
      selectedSound: selectedSound ?? this.selectedSound,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }
}

/// Meditación en progreso
class MeditationInProgress extends MeditationState {
  final MeditationSession session;

  const MeditationInProgress(this.session);

  @override
  List<Object> get props => [session];
}

/// Meditación completada (alarma activa)
class MeditationCompleted extends MeditationState {
  final MeditationSession session;

  const MeditationCompleted(this.session);

  @override
  List<Object> get props => [session];
}

/// Error
class MeditationError extends MeditationState {
  final String message;

  const MeditationError(this.message);

  @override
  List<Object> get props => [message];
}
