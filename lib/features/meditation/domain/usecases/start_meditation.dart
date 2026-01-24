import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meditation_session.dart';
import '../repositories/meditation_repository.dart';

/// Caso de uso para iniciar una meditación
class StartMeditation {
  final MeditationRepository repository;

  StartMeditation(this.repository);

  /// Ejecutar el caso de uso
  Future<Either<Failure, MeditationSession>> call(StartMeditationParams params) {
    return repository.startMeditation(
      duration: params.duration,
      soundId: params.soundId,
      vibrationEnabled: params.vibrationEnabled,
    );
  }
}

/// Parámetros para iniciar meditación
class StartMeditationParams {
  final Duration duration;
  final String soundId;
  final bool vibrationEnabled;

  const StartMeditationParams({
    required this.duration,
    required this.soundId,
    this.vibrationEnabled = true,
  });
}
