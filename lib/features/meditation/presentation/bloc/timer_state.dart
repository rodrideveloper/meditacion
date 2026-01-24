import 'package:equatable/equatable.dart';

/// Estados del BLoC del timer
abstract class TimerState extends Equatable {
  final Duration duration;
  final Duration remaining;

  const TimerState({
    required this.duration,
    required this.remaining,
  });

  @override
  List<Object> get props => [duration, remaining];

  /// Progreso del timer (0.0 a 1.0)
  double get progress {
    if (duration.inSeconds == 0) return 0.0;
    return 1.0 - (remaining.inSeconds / duration.inSeconds);
  }
}

/// Estado inicial del timer
class TimerInitial extends TimerState {
  const TimerInitial()
      : super(
          duration: Duration.zero,
          remaining: Duration.zero,
        );
}

/// Timer en ejecución
class TimerRunning extends TimerState {
  const TimerRunning({
    required super.duration,
    required super.remaining,
  });
}

/// Timer pausado
class TimerPaused extends TimerState {
  const TimerPaused({
    required super.duration,
    required super.remaining,
  });
}

/// Timer completado
class TimerCompleted extends TimerState {
  const TimerCompleted({required super.duration})
      : super(remaining: Duration.zero);
}

/// Timer detenido
class TimerStopped extends TimerState {
  const TimerStopped()
      : super(
          duration: Duration.zero,
          remaining: Duration.zero,
        );
}
