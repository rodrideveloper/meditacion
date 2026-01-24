import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/services/notification_service.dart';
import '../../domain/entities/meditation_session.dart';
import '../../domain/entities/meditation_settings.dart';
import '../../domain/repositories/meditation_repository.dart';
import '../datasources/meditation_local_datasource.dart';

/// Implementación del repositorio de meditación
class MeditationRepositoryImpl implements MeditationRepository {
  final MeditationLocalDatasource localDatasource;
  final NotificationService notificationService;

  MeditationRepositoryImpl({
    required this.localDatasource,
    required this.notificationService,
  });

  @override
  Future<Either<Failure, MeditationSession>> startMeditation({
    required Duration duration,
    required String soundId,
    required bool vibrationEnabled,
  }) async {
    try {
      final sound = MeditationSound.getById(soundId) ?? MeditationSound.defaultSound;

      // Programar la alarma
      final scheduled = await notificationService.scheduleMeditationAlarm(
        duration: duration,
        sound: sound,
        vibrate: vibrationEnabled,
      );

      if (!scheduled) {
        return const Left(NotificationFailure('No se pudo programar la alarma'));
      }

      // Guardar la configuración
      await localDatasource.saveSettings(MeditationSettings(
        lastDurationMinutes: duration.inMinutes,
        selectedSoundId: soundId,
        vibrationEnabled: vibrationEnabled,
      ));

      // Crear la sesión
      final session = MeditationSession(
        duration: duration,
        sound: sound,
        vibrationEnabled: vibrationEnabled,
        startTime: DateTime.now(),
        status: MeditationStatus.active,
      );

      debugPrint('Meditation started: ${session.duration.inMinutes} minutes');
      return Right(session);
    } catch (e) {
      debugPrint('Error starting meditation: $e');
      return Left(NotificationFailure('Error al iniciar la meditación: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> cancelMeditation() async {
    try {
      await notificationService.cancelAlarm();
      debugPrint('Meditation cancelled');
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
  Future<Either<Failure, void>> saveSettings(MeditationSettings settings) async {
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
    return await notificationService.hasPendingAlarm();
  }
}
