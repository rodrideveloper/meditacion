/// Constantes de la aplicación de meditación
class AppConstants {
  AppConstants._();

  /// Nombre de la aplicación
  static const String appName = 'Meditation Timer';

  /// ID del canal de notificaciones (v3 con stream de alarma)
  static const String notificationChannelId = 'meditation_alarm_channel_v3';
  static const String notificationChannelName = 'Alarmas de Meditación';
  static const String notificationChannelDescription =
      'Notificaciones de fin de meditación con sonido';

  /// IDs de notificación
  static const int meditationAlarmNotificationId = 1;

  /// Duraciones predefinidas de meditación (en minutos)
  static const List<int> presetDurations = [5, 10, 15, 20, 30, 45, 60];

  /// Duración mínima y máxima en minutos
  static const int minDurationMinutes = 1;
  static const int maxDurationMinutes = 120;

  /// Keys para SharedPreferences
  static const String prefLastDuration = 'last_duration';
  static const String prefSelectedSound = 'selected_sound';
  static const String prefVibrationEnabled = 'vibration_enabled';
}
