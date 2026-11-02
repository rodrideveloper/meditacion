import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/timer_bloc.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/timer_event.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/timer_state.dart';

void main() {
  group('TimerBloc', () {
    test('pause freezes remaining time and resume continues it', () async {
      final bloc = TimerBloc();
      bloc.add(const StartTimerEvent(Duration(seconds: 5)));
      await bloc.stream.firstWhere((state) => state is TimerRunning);
      bloc.add(const PauseTimerEvent());
      final paused = await bloc.stream.firstWhere(
        (state) => state is TimerPaused,
      );
      expect(paused.remaining, const Duration(seconds: 5));
      bloc.add(const ResumeTimerEvent());
      final resumed = await bloc.stream.firstWhere(
        (state) => state is TimerRunning,
      );
      expect(resumed.remaining, const Duration(seconds: 5));
      await bloc.close();
    });

    test('stop cancels countdown', () async {
      final bloc = TimerBloc();
      bloc.add(const StartTimerEvent(Duration(seconds: 30)));
      await bloc.stream.firstWhere((state) => state is TimerRunning);
      bloc.add(const StopTimerEvent());
      expect(
        await bloc.stream.firstWhere((state) => state is TimerStopped),
        isA<TimerStopped>(),
      );
      await bloc.close();
    });
  });
}
