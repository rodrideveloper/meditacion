// Excepciones personalizadas de la aplicación

/// Excepción base de la aplicación
class AppException implements Exception {
  final String message;
  final String? code;

  AppException(this.message, {this.code});

  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Excepción de notificaciones
class NotificationException extends AppException {
  NotificationException(super.message, {super.code});
}

/// Excepción de permisos
class PermissionException extends AppException {
  PermissionException(super.message, {super.code});
}

/// Excepción de almacenamiento local
class StorageException extends AppException {
  StorageException(super.message, {super.code});
}

/// Excepción de audio
class AudioException extends AppException {
  AudioException(super.message, {super.code});
}
