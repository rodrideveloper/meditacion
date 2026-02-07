import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/meditation_history_service.dart';
import '../../../../core/services/native_alarm_service.dart';
import '../../domain/entities/meditation_session.dart';
import '../../domain/entities/meditation_settings.dart';
import '../../domain/repositories/meditation_repository.dart';
import '../datasources/meditation_local_datasource.dart';

/// Implementación del repositorio de meditación
class MeditationRepositoryImpl implements MeditationRepository {
  final MeditationLocalDatasource localDatasource;
  final NativeAlarmService nativeAlarmService;
  final MeditationHistoryService historyService;

  MeditationRepositoryImpl({
    required this.localDatasource,
    required this.nativeAlarmService,
    required this.historyService,
  });

  @override
  Future<Either<Failure, MeditationSession>> startMeditation({
    required Duration duration,
    required String soundId,
    required bool vibrationEnabled,
    double alarmVolume = 0.8,
  }) async {
    try {
      final sound =
          MeditationSound.getById(soundId) ?? MeditationSound.defaultSound;

      // Verificar si podemos programar alarmas exactas
      final canSchedule = await nativeAlarmService.canScheduleExactAlarms();
      if (!canSchedule) {
        debugPrint('Cannot schedule exact alarms - permission needed');
        // Aún así intentamos programar, Android mostrará el diálogo de permisos
      }

      // Programar la alarma nativa
      final scheduled = await nativeAlarmService.scheduleAlarm(
        duration: duration,
        soundId: soundId,
      );

      if (!scheduled) {
        return const Left(
          NotificationFailure('No se pudo programar la alarma'),
        );
      }

      // Guardar la configuración
      await localDatasource.saveSettings(
        MeditationSettings(
          lastDurationMinutes: duration.inMinutes,
          selectedSoundId: soundId,
          vibrationEnabled: vibrationEnabled,
          alarmVolume: alarmVolume,
        ),
      );

      // Guardar sesión activa para completar historial cuando suene la alarma
      await historyService.saveActiveSession(
        duration: duration,
        soundId: soundId,
        vibrationEnabled: vibrationEnabled,
      );

      // Crear la sesión
      final session = MeditationSession(
        duration: duration,
        sound: sound,
        vibrationEnabled: vibrationEnabled,
        startTime: DateTime.now(),
        status: MeditationStatus.active,
      );

      debugPrint(
        'Meditation started: ${session.duration.inMinutes} minutes with native alarm',
      );
      return Right(session);
    } catch (e) {
      debugPrint('Error starting meditation: $e');
      return Left(NotificationFailure('Error al iniciar la meditación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMeditation() async {
    try {
      await nativeAlarmService.cancelAlarm();
      await historyService.clearActiveSession();
      debugPrint('Meditation cancelled - native alarm removed');
      return const Right(null);
    } catch (e) {
      debugPrint('Error cancelling meditation: $e');
      return Left(NotificationFailure('Error al cancelar la meditación: $e'));
    }
  }

  @override
  Future<Either<Failure, MeditationSettings>> getSavedSettings() async {
    try {
      final settings = await localDatasource.getSavedSettings();
      return Right(settings);
    } catch (e) {
      debugPrint('Error getting saved settings: $e');
      return Left(StorageFailure('Error al obtener la configuración: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSettings(
    MeditationSettings settings,
  ) async {
    try {
      await localDatasource.saveSettings(settings);
      return const Right(null);
    } catch (e) {
      debugPrint('Error saving settings: $e');
      return Left(StorageFailure('Error al guardar la configuración: $e'));
    }
  }

  @override
  Future<bool> hasActiveAlarm() async {
    // Con el servicio nativo no tenemos una forma directa de verificar
    // Retornamos false por ahora - podríamos guardar el estado en SharedPreferences
    return false;
  }
}
