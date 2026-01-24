import 'package:equatable/equatable.dart';

/// Clase base para representar fallos en la aplicación
abstract class Failure extends Equatable {
  final String message;

  const Failure(this.message);

  @override
  List<Object> get props => [message];
}

/// Fallo de notificaciones
class NotificationFailure extends Failure {
  const NotificationFailure(super.message);
}

/// Fallo de permisos
class PermissionFailure extends Failure {
  const PermissionFailure(super.message);
}

/// Fallo de almacenamiento
class StorageFailure extends Failure {
  const StorageFailure(super.message);
}

/// Fallo de audio
class AudioFailure extends Failure {
  const AudioFailure(super.message);
}

/// Fallo desconocido
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'Ha ocurrido un error desconocido']);
}
