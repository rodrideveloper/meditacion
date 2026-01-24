import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meditation_settings.dart';
import '../repositories/meditation_repository.dart';

/// Caso de uso para obtener la configuración guardada
class GetSavedSettings {
  final MeditationRepository repository;

  GetSavedSettings(this.repository);

  /// Ejecutar el caso de uso
  Future<Either<Failure, MeditationSettings>> call() {
    return repository.getSavedSettings();
  }
}
