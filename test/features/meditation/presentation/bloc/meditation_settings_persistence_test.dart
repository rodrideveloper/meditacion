import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/errors/failures.dart';
import 'package:meditation_app/features/meditation/domain/entities/meditation_settings.dart';
import 'package:meditation_app/features/meditation/domain/repositories/meditation_repository.dart';
import 'package:meditation_app/features/meditation/domain/usecases/cancel_meditation.dart';
import 'package:meditation_app/features/meditation/domain/usecases/get_saved_settings.dart';
import 'package:meditation_app/features/meditation/domain/usecases/save_settings.dart';
import 'package:meditation_app/features/meditation/domain/usecases/start_meditation.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/meditation_bloc.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/meditation_event.dart';
import 'package:meditation_app/features/meditation/presentation/bloc/meditation_state.dart';

class _GetSettings extends GetSavedSettings {
  _GetSettings() : super(_UnusedRepository());
  @override
  Future<Either<Failure, MeditationSettings>> call() async =>
      Right(MeditationSettings.defaults());
}

class _SaveSettings extends SaveSettings {
  _SaveSettings() : super(_UnusedRepository());
  MeditationSettings? saved;
  @override
  Future<Either<Failure, void>> call(MeditationSettings settings) async {
    saved = settings;
    return const Right(null);
  }
}

class _Start extends StartMeditation {
  _Start() : super(_UnusedRepository());
}

class _Cancel extends CancelMeditation {
  _Cancel() : super(_UnusedRepository());
}

class _UnusedRepository implements MeditationRepository {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('persists changed preferences after the user pauses input', () async {
    final save = _SaveSettings();
    final bloc = MeditationBloc(
      startMeditation: _Start(),
      cancelMeditation: _Cancel(),
      getSavedSettings: _GetSettings(),
      saveSettings: save,
    );
    bloc.add(const LoadSettingsEvent());
    await bloc.stream.firstWhere((state) => state is MeditationReady);

    bloc.add(const ChangeDurationEvent(25));
    bloc.add(const ChangeVolumeEvent(0.35));
    await Future<void>.delayed(const Duration(milliseconds: 500));

    expect(save.saved?.lastDurationMinutes, 25);
    expect(save.saved?.alarmVolume, 0.35);
    await bloc.close();
  });
}
