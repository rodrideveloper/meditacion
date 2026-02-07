import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meditation_session.dart';
import '../entities/meditation_settings.dart';

/// Contrato del repositorio de meditación
abstract class MeditationRepository {
  /// Iniciar una sesión de meditación y programar alarma
  Future<Either<Failure, MeditationSession>> startMeditation({
    required Duration duration,
    required String soundId,
    required bool vibrationEnabled,
    double alarmVolume = 0.8,
  });

  /// Cancelar la sesión de meditación activa
  Future<Either<Failure, void>> cancelMeditation();

  /// Obtener la configuración guardada del usuario
  Future<Either<Failure, MeditationSettings>> getSavedSettings();

  /// Guardar la configuración del usuario
  Future<Either<Failure, void>> saveSettings(MeditationSettings settings);

  /// Verificar si hay una alarma programada
  Future<bool> hasActiveAlarm();
}
