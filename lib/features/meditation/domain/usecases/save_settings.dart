import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/meditation_settings.dart';
import '../repositories/meditation_repository.dart';

/// Caso de uso para guardar la configuración
class SaveSettings {
  final MeditationRepository repository;

  SaveSettings(this.repository);

  /// Ejecutar el caso de uso
  Future<Either<Failure, void>> call(MeditationSettings settings) {
    return repository.saveSettings(settings);
  }
}
