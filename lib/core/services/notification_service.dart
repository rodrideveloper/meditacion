import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../constants/app_constants.dart';
import '../l10n/app_strings.dart';
import '../l10n/locale_provider.dart';
import '../di/injection_container.dart';
import 'meditation_history_service.dart';

/// IDs fijos de notificación
const int _kDailyReminderId = 3001;
const int _kStreakId = 3002;
const int _kInactivityNudgeId = 3003;

/// Canal de Android para recordatorios (separado del canal de alarma)
const String _kChannelId = 'meditation_reminders';

/// Gestiona las notificaciones de la app usando flutter_local_notifications:
///  1. Recordatorio diario – zonedSchedule con matchDateTimeComponents.time
///  2. Racha (streak) – show() inmediato después de completar sesión
///  3. Nudge de inactividad – zonedSchedule one-shot a 48 h
class NotificationService {
  final SharedPreferences _prefs;
  final MeditationHistoryService _historyService;
  final FlutterLocalNotificationsPlugin _plugin;

  NotificationService(this._prefs, this._historyService)
    : _plugin = FlutterLocalNotificationsPlugin();

  // ──────────────────────────────────────────────
  //  Inicialización
  // ──────────────────────────────────────────────

  Future<void> initialize() async {
    // Timezone
    tz.initializeTimeZones();
    final tzInfo = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(tzInfo.identifier));

    // Plugin init
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const darwinSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(settings: settings);

    // Re-programar lo que esté activo
    if (isDailyReminderEnabled) {
      await scheduleDailyReminder(
        hour: dailyReminderHour,
        minute: dailyReminderMinute,
      );
    }

    if (isInactivityNudgeEnabled) {
      await _scheduleInactivityNudge();
    }

    debugPrint('NotificationService initialized');
  }

  // ──────────────────────────────────────────────
  //  Detalles de notificación reutilizables
  // ──────────────────────────────────────────────

  /// Current localized strings based on persisted locale.
  AppStrings get _s => getIt<LocaleProvider>().strings;

  NotificationDetails get _notificationDetails {
    final androidDetails = AndroidNotificationDetails(
      _kChannelId,
      _s.notifChannelName,
      channelDescription: _s.notifChannelDesc,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    return NotificationDetails(
      android: androidDetails,
      iOS: const DarwinNotificationDetails(),
    );
  }

  // ──────────────────────────────────────────────
  //  1. Recordatorio diario
  // ──────────────────────────────────────────────

  bool get isDailyReminderEnabled =>
      _prefs.getBool(AppConstants.prefDailyReminderEnabled) ?? false;

  int get dailyReminderHour =>
      _prefs.getInt(AppConstants.prefDailyReminderHour) ??
      AppConstants.defaultReminderHour;

  int get dailyReminderMinute =>
      _prefs.getInt(AppConstants.prefDailyReminderMinute) ??
      AppConstants.defaultReminderMinute;

  /// Programa un recordatorio diario a la hora indicada.
  Future<void> scheduleDailyReminder({
    required int hour,
    required int minute,
  }) async {
    await _prefs.setBool(AppConstants.prefDailyReminderEnabled, true);
    await _prefs.setInt(AppConstants.prefDailyReminderHour, hour);
    await _prefs.setInt(AppConstants.prefDailyReminderMinute, minute);

    // Cancelar la anterior si existía
    await _plugin.cancel(id: _kDailyReminderId);

    // Próxima instancia de esa hora
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    try {
      await _plugin.zonedSchedule(
        id: _kDailyReminderId,
        title: _s.notifDailyTitle,
        body: _s.notifDailyBody,
        scheduledDate: scheduled,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // repite diario
      );
      debugPrint(
        'Daily reminder scheduled at $hour:${minute.toString().padLeft(2, '0')}',
      );
    } catch (e) {
      debugPrint('Could not schedule daily reminder: $e');
    }
  }

  /// Cancela el recordatorio diario.
  Future<void> cancelDailyReminder() async {
    await _prefs.setBool(AppConstants.prefDailyReminderEnabled, false);
    await _plugin.cancel(id: _kDailyReminderId);
    debugPrint('Daily reminder cancelled');
  }

  // ──────────────────────────────────────────────
  //  2. Notificación de racha (streak)
  // ──────────────────────────────────────────────

  bool get isStreakNotificationsEnabled =>
      _prefs.getBool(AppConstants.prefStreakNotificationsEnabled) ?? true;

  Future<void> setStreakNotificationsEnabled(bool value) async {
    await _prefs.setBool(AppConstants.prefStreakNotificationsEnabled, value);
  }

  /// Llamar después de completar una sesión.
  Future<void> notifyStreakIfNeeded() async {
    if (!isStreakNotificationsEnabled) return;

    final streak = _historyService.getCurrentStreak();
    if (streak < 2) return;

    await _plugin.show(
      id: _kStreakId,
      title: _s.notifStreakTitle(streak),
      body: _s.notifStreakBody(streak),
      notificationDetails: _notificationDetails,
    );

    debugPrint('Streak notification shown: $streak days');
  }

  // ──────────────────────────────────────────────
  //  3. Nudge de inactividad
  // ──────────────────────────────────────────────

  bool get isInactivityNudgeEnabled =>
      _prefs.getBool(AppConstants.prefInactivityNudgeEnabled) ?? true;

  Future<void> setInactivityNudgeEnabled(bool value) async {
    await _prefs.setBool(AppConstants.prefInactivityNudgeEnabled, value);
    if (value) {
      await _scheduleInactivityNudge();
    } else {
      await _plugin.cancel(id: _kInactivityNudgeId);
    }
  }

  /// (Re)programa el nudge a 48 h desde ahora.
  Future<void> resetInactivityNudge() async {
    if (!isInactivityNudgeEnabled) return;
    await _scheduleInactivityNudge();
  }

  Future<void> _scheduleInactivityNudge() async {
    await _plugin.cancel(id: _kInactivityNudgeId);

    final scheduled = tz.TZDateTime.now(
      tz.local,
    ).add(Duration(hours: AppConstants.inactivityNudgeHours));

    try {
      await _plugin.zonedSchedule(
        id: _kInactivityNudgeId,
        title: _s.notifInactivityTitle,
        body: _s.notifInactivityBody,
        scheduledDate: scheduled,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      debugPrint(
        'Inactivity nudge scheduled in ${AppConstants.inactivityNudgeHours} h',
      );
    } catch (e) {
      debugPrint('Could not schedule inactivity nudge: $e');
    }
  }

  // ──────────────────────────────────────────────
  //  Callback post-sesión (central)
  // ──────────────────────────────────────────────

  /// Llama a esto cada vez que una sesión se completa.
  Future<void> onSessionCompleted() async {
    await notifyStreakIfNeeded();
    await resetInactivityNudge();
  }
}
