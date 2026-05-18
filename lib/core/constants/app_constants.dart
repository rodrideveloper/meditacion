/// Constantes de la aplicación de meditación
class AppConstants {
  AppConstants._();

  /// Nombre de la aplicación
  static const String appName = 'Meditation Timer';

  /// ID del canal de notificaciones (v5 con versión estable del plugin)
  static const String notificationChannelId = 'meditation_alarm_channel_v5';
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
  static const String prefAlarmVolume = 'alarm_volume';

  /// Estado de sesión e historial
  static const String prefActiveSessionJson = 'active_session_json';
  static const String prefSessionHistoryList = 'session_history_list';

  /// Notificaciones / recordatorios
  static const String prefDailyReminderEnabled = 'daily_reminder_enabled';
  static const String prefDailyReminderHour = 'daily_reminder_hour';
  static const String prefDailyReminderMinute = 'daily_reminder_minute';
  static const String prefInactivityNudgeEnabled = 'inactivity_nudge_enabled';
  static const String prefStreakNotificationsEnabled =
      'streak_notifications_enabled';

  /// Valores por defecto de recordatorio
  static const int defaultReminderHour = 8; // 08:00
  static const int defaultReminderMinute = 0;

  /// Horas de inactividad para nudge (48 h)
  static const int inactivityNudgeHours = 48;

  /// Contador de sesiones completadas (para in_app_review)
  static const String prefCompletedSessionsCount =
      'completed_sessions_count';
}
