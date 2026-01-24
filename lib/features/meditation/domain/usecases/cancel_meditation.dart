import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../repositories/meditation_repository.dart';

/// Caso de uso para cancelar una meditación
class CancelMeditation {
  final MeditationRepository repository;

  CancelMeditation(this.repository);

  /// Ejecutar el caso de uso
  Future<Either<Failure, void>> call() {
    return repository.cancelMeditation();
  }
}
