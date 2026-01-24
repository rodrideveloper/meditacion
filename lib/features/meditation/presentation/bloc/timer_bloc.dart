import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'timer_event.dart';
import 'timer_state.dart';

/// BLoC para manejar el countdown del timer
class TimerBloc extends Bloc<TimerEvent, TimerState> {
  Timer? _timer;
  Duration _initialDuration = Duration.zero;

  TimerBloc() : super(const TimerInitial()) {
    on<StartTimerEvent>(_onStartTimer);
    on<TimerTickEvent>(_onTimerTick);
    on<PauseTimerEvent>(_onPauseTimer);
    on<ResumeTimerEvent>(_onResumeTimer);
    on<StopTimerEvent>(_onStopTimer);
    on<TimerCompletedEvent>(_onTimerCompleted);
  }

  void _onStartTimer(
    StartTimerEvent event,
    Emitter<TimerState> emit,
  ) {
    _timer?.cancel();
    _initialDuration = event.duration;

    emit(TimerRunning(
      duration: event.duration,
      remaining: event.duration,
    ));

    _startTicking();
  }

  void _onTimerTick(
    TimerTickEvent event,
    Emitter<TimerState> emit,
  ) {
    if (event.remaining.inSeconds <= 0) {
      _timer?.cancel();
      add(const TimerCompletedEvent());
    } else {
      emit(TimerRunning(
        duration: _initialDuration,
        remaining: event.remaining,
      ));
    }
  }

  void _onPauseTimer(
    PauseTimerEvent event,
    Emitter<TimerState> emit,
  ) {
    _timer?.cancel();
    final currentState = state;
    if (currentState is TimerRunning) {
      emit(TimerPaused(
        duration: currentState.duration,
        remaining: currentState.remaining,
      ));
    }
  }

  void _onResumeTimer(
    ResumeTimerEvent event,
    Emitter<TimerState> emit,
  ) {
    final currentState = state;
    if (currentState is TimerPaused) {
      emit(TimerRunning(
        duration: currentState.duration,
        remaining: currentState.remaining,
      ));
      _startTicking();
    }
  }

  void _onStopTimer(
    StopTimerEvent event,
    Emitter<TimerState> emit,
  ) {
    _timer?.cancel();
    emit(const TimerStopped());
  }

  void _onTimerCompleted(
    TimerCompletedEvent event,
    Emitter<TimerState> emit,
  ) {
    _timer?.cancel();
    emit(TimerCompleted(duration: _initialDuration));
  }

  void _startTicking() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final currentState = state;
      if (currentState is TimerRunning) {
        final newRemaining = currentState.remaining - const Duration(seconds: 1);
        add(TimerTickEvent(newRemaining));
      }
    });
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }
}
