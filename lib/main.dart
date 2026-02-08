import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:permission_handler/permission_handler.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/native_alarm_service.dart';
import 'core/services/audio_service.dart';
import 'core/services/meditation_history_service.dart';
import 'core/services/notification_service.dart';

void main() async {
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Configurar orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  // Inicializar dependencias
  await initializeDependencies();

  // Solicitar permisos necesarios (ANTES de inicializar servicios que los usan)
  await _requestPermissions();

  // Inicializar servicios
  final nativeAlarmService = getIt<NativeAlarmService>();
  await nativeAlarmService.initialize();

  final audioService = getIt<AudioService>();
  await audioService.initialize();

  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();

  // Configurar callback de alarma nativa (para cuando la app ya está corriendo)
  debugPrint('>>> Setting onAlarmTriggered callback on NativeAlarmService');
  nativeAlarmService.onAlarmTriggered = _onAlarmTriggered;
  debugPrint('>>> onAlarmTriggered callback set');

  // Verificar si la app fue abierta por una alarma (cold start)
  String initialRoute = '/';
  String? pendingSoundId;
  final pendingResult = await nativeAlarmService.checkPendingAlarm();
  if (pendingResult != null) {
    debugPrint('>>> Cold-start alarm detected! soundId=${pendingResult}');
    initialRoute = '/alarm';
    pendingSoundId = pendingResult;

    // Persistir historial y notificar (best-effort, como en _onAlarmTriggered)
    try {
      unawaited(
        getIt<MeditationHistoryService>().completeActiveSession(
          soundIdFromAlarm: pendingResult,
        ),
      );
    } catch (e) {
      debugPrint('Error persisting session on cold start: $e');
    }
    try {
      unawaited(getIt<NotificationService>().onSessionCompleted());
    } catch (e) {
      debugPrint('Error notifying session completed on cold start: $e');
    }
  }

  // Remove splash screen now that init is complete
  FlutterNativeSplash.remove();

  debugPrint('>>> Running MeditationApp with initialRoute=$initialRoute...');
  runApp(
    MeditationApp(initialRoute: initialRoute, alarmSoundId: pendingSoundId),
  );
}

/// Solicitar todos los permisos necesarios para la alarma
Future<void> _requestPermissions() async {
  // 1. Permiso de notificaciones (Android 13+)
  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    final result = await Permission.notification.request();
    debugPrint('Notification permission: $result');
  }

  // 2. Permiso de alarmas exactas (Android 12+)
  //    Necesario para NotificationService.zonedSchedule() con exactAllowWhileIdle
  //    (recordatorios diarios). Abre la pantalla de Ajustes del sistema.
  //    Nota: setAlarmClock() para la alarma principal NO lo necesita,
  //    pero los recordatorios programados con flutter_local_notifications sí.
  final alarmStatus = await Permission.scheduleExactAlarm.status;
  debugPrint('Exact alarm permission status: $alarmStatus');
  if (!alarmStatus.isGranted) {
    final result = await Permission.scheduleExactAlarm.request();
    debugPrint('Exact alarm permission after request: $result');
  }

  // SYSTEM_ALERT_WINDOW: Se solicita desde el lado nativo (MainActivity)
  // en onResume() para evitar interrumpir la inicialización de Flutter.
}

/// Callback cuando la alarma nativa se dispara
void _onAlarmTriggered(String soundId) {
  debugPrint('=== _onAlarmTriggered START ===');
  debugPrint('Sound ID: $soundId');

  // Persistir en historial (best-effort)
  try {
    debugPrint('Persisting session to history...');
    unawaited(
      getIt<MeditationHistoryService>().completeActiveSession(
        soundIdFromAlarm: soundId,
      ),
    );
    debugPrint('Session history persist initiated');
  } catch (e) {
    debugPrint('Error persisting session: $e');
  }

  // Notificar streak + resetear nudge de inactividad
  try {
    debugPrint('Notifying session completed...');
    unawaited(getIt<NotificationService>().onSessionCompleted());
    debugPrint('Session completed notification initiated');
  } catch (e) {
    debugPrint('Error notifying session completed: $e');
  }

  // Navegar a la pantalla de alarma
  debugPrint('navigatorKey.currentState: ${navigatorKey.currentState}');
  debugPrint(
    'navigatorKey.currentState is null: ${navigatorKey.currentState == null}',
  );

  if (navigatorKey.currentState != null) {
    debugPrint('>>> Navigating to /alarm with soundId=$soundId');
    navigatorKey.currentState!.pushNamedAndRemoveUntil(
      '/alarm',
      (route) => false,
      arguments: {'soundId': soundId},
    );
    debugPrint('>>> Navigation to /alarm completed');
  } else {
    debugPrint(
      '>>> ERROR: navigatorKey.currentState is NULL! Cannot navigate to /alarm',
    );
    debugPrint(
      '>>> This means the MaterialApp is not mounted or navigatorKey is not attached',
    );
  }
  debugPrint('=== _onAlarmTriggered END ===');
}
