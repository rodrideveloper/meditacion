import 'package:equatable/equatable.dart';

/// Eventos del BLoC del timer
abstract class TimerEvent extends Equatable {
  const TimerEvent();

  @override
  List<Object?> get props => [];
}

/// Iniciar el timer
class StartTimerEvent extends TimerEvent {
  final Duration duration;

  const StartTimerEvent(this.duration);

  @override
  List<Object> get props => [duration];
}

/// Tick del timer (cada segundo)
class TimerTickEvent extends TimerEvent {
  final Duration remaining;

  const TimerTickEvent(this.remaining);

  @override
  List<Object> get props => [remaining];
}

/// Pausar el timer
class PauseTimerEvent extends TimerEvent {
  const PauseTimerEvent();
}

/// Reanudar el timer
class ResumeTimerEvent extends TimerEvent {
  const ResumeTimerEvent();
}

/// Detener el timer
class StopTimerEvent extends TimerEvent {
  const StopTimerEvent();
}

/// Timer completado
class TimerCompletedEvent extends TimerEvent {
  const TimerCompletedEvent();
}
