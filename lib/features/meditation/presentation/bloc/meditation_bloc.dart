import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../domain/entities/meditation_session.dart';
import '../../domain/entities/meditation_settings.dart';
import '../../domain/usecases/start_meditation.dart';
import '../../domain/usecases/cancel_meditation.dart';
import '../../domain/usecases/get_saved_settings.dart';
import '../../domain/usecases/save_settings.dart';
import 'meditation_event.dart';
import 'meditation_state.dart';

/// BLoC para manejar el estado de la meditación
class MeditationBloc extends Bloc<MeditationEvent, MeditationState> {
  final StartMeditation startMeditation;
  final CancelMeditation cancelMeditation;
  final GetSavedSettings getSavedSettings;
  final SaveSettings saveSettings;

  MeditationSession? _currentSession;
  Timer? _settingsSaveTimer;

  MeditationBloc({
    required this.startMeditation,
    required this.cancelMeditation,
    required this.getSavedSettings,
    required this.saveSettings,
  }) : super(const MeditationInitial()) {
    on<LoadSettingsEvent>(_onLoadSettings);
    on<ChangeDurationEvent>(_onChangeDuration);
    on<ChangeSoundEvent>(_onChangeSound);
    on<ToggleVibrationEvent>(_onToggleVibration);
    on<ChangeVolumeEvent>(_onChangeVolume);
    on<StartMeditationEvent>(_onStartMeditation);
    on<CancelMeditationEvent>(_onCancelMeditation);
    on<MeditationCompletedEvent>(_onMeditationCompleted);
    on<ResetMeditationEvent>(_onResetMeditation);
  }

  /// Obtener sesión actual
  MeditationSession? get currentSession => _currentSession;

  /// Asegura que las preferencias pendientes queden guardadas antes de salir
  /// de Ajustes o de suspender la aplicación.
  Future<bool> persistSettingsNow() async {
    _settingsSaveTimer?.cancel();
    final current = state;
    if (current is! MeditationReady) return true;
    final result = await saveSettings(
      MeditationSettings(
        lastDurationMinutes: current.durationMinutes,
        selectedSoundId: current.selectedSound.id,
        vibrationEnabled: current.vibrationEnabled,
        alarmVolume: current.alarmVolume,
      ),
    );
    return result.isRight();
  }

  Future<void> _onLoadSettings(
    LoadSettingsEvent event,
    Emitter<MeditationState> emit,
  ) async {
    emit(const MeditationLoading());

    final result = await getSavedSettings();

    result.fold(
      (failure) {
        // Si hay error, usar valores por defecto
        emit(
          MeditationReady(
            durationMinutes: 10,
            selectedSound: MeditationSound.defaultSound,
            vibrationEnabled: true,
            alarmVolume: 0.8,
          ),
        );
      },
      (settings) {
        emit(
          MeditationReady(
            durationMinutes: settings.lastDurationMinutes,
            selectedSound: settings.selectedSound,
            vibrationEnabled: settings.vibrationEnabled,
            alarmVolume: settings.alarmVolume,
          ),
        );
      },
    );
  }

  void _onChangeDuration(
    ChangeDurationEvent event,
    Emitter<MeditationState> emit,
  ) {
    final currentState = state;
    if (currentState is MeditationReady) {
      final updated = currentState.copyWith(durationMinutes: event.minutes);
      emit(updated);
      _saveSettingsSoon(updated);
    }
  }

  void _onChangeSound(ChangeSoundEvent event, Emitter<MeditationState> emit) {
    final currentState = state;
    if (currentState is MeditationReady) {
      final sound = MeditationSound.getById(event.soundId);
      if (sound != null) {
        final updated = currentState.copyWith(selectedSound: sound);
        emit(updated);
        _saveSettingsSoon(updated);
      }
    }
  }

  void _onToggleVibration(
    ToggleVibrationEvent event,
    Emitter<MeditationState> emit,
  ) {
    final currentState = state;
    if (currentState is MeditationReady) {
      final updated = currentState.copyWith(
        vibrationEnabled: !currentState.vibrationEnabled,
      );
      emit(updated);
      _saveSettingsSoon(updated);
    }
  }

  void _onChangeVolume(ChangeVolumeEvent event, Emitter<MeditationState> emit) {
    final currentState = state;
    if (currentState is MeditationReady) {
      final updated = currentState.copyWith(alarmVolume: event.volume);
      emit(updated);
      _saveSettingsSoon(updated);
    }
  }

  void _saveSettingsSoon(MeditationReady state) {
    _settingsSaveTimer?.cancel();
    _settingsSaveTimer = Timer(const Duration(milliseconds: 350), () {
      if (isClosed) return;
      saveSettings(
        MeditationSettings(
          lastDurationMinutes: state.durationMinutes,
          selectedSoundId: state.selectedSound.id,
          vibrationEnabled: state.vibrationEnabled,
          alarmVolume: state.alarmVolume,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _settingsSaveTimer?.cancel();
    return super.close();
  }

  Future<void> _onStartMeditation(
    StartMeditationEvent event,
    Emitter<MeditationState> emit,
  ) async {
    final currentState = state;
    if (currentState is! MeditationReady) return;

    emit(const MeditationLoading());

    final params = StartMeditationParams(
      duration: Duration(minutes: currentState.durationMinutes),
      soundId: currentState.selectedSound.id,
      vibrationEnabled: currentState.vibrationEnabled,
      alarmVolume: currentState.alarmVolume,
    );

    final result = await startMeditation(params);

    result.fold(
      (failure) {
        emit(MeditationError(failure.message));
        // Volver al estado ready después de un momento
        Future.delayed(const Duration(seconds: 2), () {
          if (!isClosed) {
            add(const LoadSettingsEvent());
          }
        });
      },
      (session) {
        _currentSession = session;
        emit(MeditationInProgress(session));
      },
    );
  }

  Future<void> _onCancelMeditation(
    CancelMeditationEvent event,
    Emitter<MeditationState> emit,
  ) async {
    await cancelMeditation();
    _currentSession = null;
    add(const LoadSettingsEvent());
  }

  void _onMeditationCompleted(
    MeditationCompletedEvent event,
    Emitter<MeditationState> emit,
  ) {
    if (_currentSession != null) {
      final completedSession = _currentSession!.copyWith(
        status: MeditationStatus.completed,
      );
      emit(MeditationCompleted(completedSession));
    }
  }

  Future<void> _onResetMeditation(
    ResetMeditationEvent event,
    Emitter<MeditationState> emit,
  ) async {
    _currentSession = null;
    add(const LoadSettingsEvent());
  }
}
