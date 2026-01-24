import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:flutter_timezone/flutter_timezone.dart';

import '../constants/app_constants.dart';
import '../constants/sound_constants.dart';

/// Callback para manejar respuestas de notificación en background
@pragma('vm:entry-point')
void notificationBackgroundHandler(NotificationResponse response) {
  // Este callback se ejecuta cuando la app está cerrada
  // La navegación se maneja en el main.dart
  debugPrint('Background notification response: ${response.payload}');
}

/// Servicio para manejar notificaciones y alarmas
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  /// Callback que se ejecuta cuando el usuario toca la notificación
  Function(String? payload)? onNotificationTapped;

  /// Plugin getter para acceso externo
  FlutterLocalNotificationsPlugin get plugin => _plugin;

  /// Inicializar el servicio de notificaciones
  Future<void> initialize() async {
    if (_initialized) return;

    // Inicializar timezone
    tz_data.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));

    // Configuración para Android
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    // Configuración para iOS
    final darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: [
        DarwinNotificationCategory(
          'meditation_complete',
          actions: [
            DarwinNotificationAction.plain(
              'stop_alarm',
              'Detener',
              options: {DarwinNotificationActionOption.foreground},
            ),
          ],
        ),
      ],
    );

    final initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse: notificationBackgroundHandler,
    );

    // Crear canal de notificaciones en Android
    await _createNotificationChannel();

    _initialized = true;
    debugPrint('NotificationService initialized');
  }

  /// Crear canal de notificaciones para Android
  Future<void> _createNotificationChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin != null) {
      // Eliminar canal anterior si existe
      await androidPlugin.deleteNotificationChannel('meditation_alarm_channel');
      await androidPlugin.deleteNotificationChannel(
        'meditation_alarm_channel_v2',
      );

      // Crear canal con sonido personalizado y stream de ALARMA
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          AppConstants.notificationChannelId,
          AppConstants.notificationChannelName,
          description: AppConstants.notificationChannelDescription,
          importance: Importance.max,
          playSound: true,
          sound: RawResourceAndroidNotificationSound('angelical'),
          enableVibration: true,
          showBadge: true,
          enableLights: true,
          // Usar el stream de ALARMA para que suene aunque esté en silencio
          audioAttributesUsage: AudioAttributesUsage.alarm,
        ),
      );
    }
  }

  /// Manejar respuesta de notificación
  void _onNotificationResponse(NotificationResponse response) {
    debugPrint('Notification tapped: ${response.payload}');
    onNotificationTapped?.call(response.payload);
  }

  /// Programar alarma de meditación
  Future<bool> scheduleMeditationAlarm({
    required Duration duration,
    required MeditationSound sound,
    bool vibrate = true,
  }) async {
    try {
      final scheduledTime = tz.TZDateTime.now(tz.local).add(duration);

      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.max,
        priority: Priority.high,
        // Full screen intent para mostrar sobre lock screen
        fullScreenIntent: true,
        // Categoría de alarma
        category: AndroidNotificationCategory.alarm,
        // Sonido personalizado
        sound: RawResourceAndroidNotificationSound(sound.androidRawName),
        playSound: true,
        // Vibración
        enableVibration: vibrate,
        vibrationPattern: vibrate
            ? Int64List.fromList([0, 500, 200, 500, 200, 500])
            : null,
        // Configuraciones adicionales
        visibility: NotificationVisibility.public,
        autoCancel: false,
        ongoing: true,
        // Icono grande
        largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
        // Estilo
        styleInformation: const BigTextStyleInformation(
          'Tu sesión de meditación ha terminado. Toca para detener la alarma.',
          contentTitle: '🧘 Meditación Completada',
          summaryText: 'Meditation Timer',
        ),
        // Acciones
        actions: const [
          AndroidNotificationAction(
            'stop_alarm',
            'Detener',
            showsUserInterface: true,
            cancelNotification: true,
          ),
        ],
      );

      const iosDetails = DarwinNotificationDetails(
        sound: 'angelical.aiff',
        presentAlert: true,
        presentSound: true,
        presentBadge: true,
        interruptionLevel: InterruptionLevel.timeSensitive,
        categoryIdentifier: 'meditation_complete',
      );

      final notificationDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      await _plugin.zonedSchedule(
        AppConstants.meditationAlarmNotificationId,
        '🧘 Meditación Completada',
        'Tu sesión de meditación ha terminado',
        scheduledTime,
        notificationDetails,
        // Usa AlarmManager.setAlarmClock() internamente
        androidScheduleMode: AndroidScheduleMode.alarmClock,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        // Parámetro requerido en v18+ - null para alarma única (no repetitiva)
        matchDateTimeComponents: null,
        payload: 'meditation_complete',
      );

      debugPrint('Alarm scheduled for: $scheduledTime');
      return true;
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
      return false;
    }
  }

  /// Cancelar alarma programada
  Future<void> cancelAlarm() async {
    await _plugin.cancel(AppConstants.meditationAlarmNotificationId);
    debugPrint('Alarm cancelled');
  }

  /// Cancelar todas las notificaciones
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
    debugPrint('All notifications cancelled');
  }

  /// Verificar si hay una notificación pendiente
  Future<bool> hasPendingAlarm() async {
    final pending = await _plugin.pendingNotificationRequests();
    return pending.any(
      (n) => n.id == AppConstants.meditationAlarmNotificationId,
    );
  }

  /// Obtener detalles de lanzamiento de la app
  Future<NotificationAppLaunchDetails?> getAppLaunchDetails() async {
    return await _plugin.getNotificationAppLaunchDetails();
  }

  /// Solicitar permisos de notificación en Android
  Future<bool> requestAndroidPermissions() async {
    if (!Platform.isAndroid) return true;

    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    if (androidPlugin == null) return false;

    // Permiso de notificaciones (Android 13+)
    final notifGranted = await androidPlugin.requestNotificationsPermission();

    // Permiso de alarmas exactas (Android 12+)
    final exactAlarmGranted = await androidPlugin
        .requestExactAlarmsPermission();

    // Permiso de full-screen intent
    final fullScreenGranted = await androidPlugin
        .requestFullScreenIntentPermission();

    debugPrint(
      'Permissions - Notifications: $notifGranted, '
      'Exact Alarms: $exactAlarmGranted, Full Screen: $fullScreenGranted',
    );

    return (notifGranted ?? false) && (exactAlarmGranted ?? false);
  }

  /// Solicitar permisos de notificación en iOS
  Future<bool> requestIOSPermissions() async {
    if (!Platform.isIOS) return true;

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();

    if (iosPlugin == null) return false;

    final granted = await iosPlugin.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
      critical: true,
    );

    debugPrint('iOS permissions granted: $granted');
    return granted ?? false;
  }

  /// Solicitar todos los permisos necesarios
  Future<bool> requestAllPermissions() async {
    if (Platform.isAndroid) {
      return await requestAndroidPermissions();
    } else if (Platform.isIOS) {
      return await requestIOSPermissions();
    }
    return true;
  }

  /// Verificar si los permisos están concedidos
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final androidPlugin = _plugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidPlugin == null) return false;

      final areNotificationsEnabled = await androidPlugin
          .areNotificationsEnabled();

      return areNotificationsEnabled ?? false;
    } else if (Platform.isIOS) {
      // En iOS, verificamos solicitando permisos (no hay método directo)
      return true;
    }
    return true;
  }
}
