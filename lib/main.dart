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

  // Configurar callback de alarma nativa
  nativeAlarmService.onAlarmTriggered = _onAlarmTriggered;

  // Remove splash screen now that init is complete
  FlutterNativeSplash.remove();

  runApp(const MeditationApp(initialRoute: '/'));
}

/// Solicitar todos los permisos necesarios para la alarma
Future<void> _requestPermissions() async {
  // Permiso de notificaciones (Android 13+)
  final notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    final result = await Permission.notification.request();
    debugPrint('Notification permission: $result');
  }

  // Permiso de alarmas exactas (Android 12+)
  final alarmStatus = await Permission.scheduleExactAlarm.status;
  if (!alarmStatus.isGranted) {
    final result = await Permission.scheduleExactAlarm.request();
    debugPrint('Exact alarm permission: $result');
  }
}

/// Callback cuando la alarma nativa se dispara
void _onAlarmTriggered(String soundId) {
  debugPrint('Alarm triggered with sound: $soundId');

  // Persistir en historial (best-effort)
  try {
    unawaited(
      getIt<MeditationHistoryService>().completeActiveSession(
        soundIdFromAlarm: soundId,
      ),
    );
  } catch (_) {
    // Ignorar si el DI aún no está listo o hay error de persistencia
  }

  // Notificar streak + resetear nudge de inactividad
  try {
    unawaited(getIt<NotificationService>().onSessionCompleted());
  } catch (_) {
    // best-effort
  }

  // Navegar a la pantalla de alarma
  navigatorKey.currentState?.pushNamedAndRemoveUntil(
    '/alarm',
    (route) => false,
    arguments: {'soundId': soundId},
  );
}
