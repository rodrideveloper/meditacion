import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';
import 'core/di/injection_container.dart';
import 'core/services/notification_service.dart';
import 'core/services/audio_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configurar orientación solo vertical
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Configurar estilo de la barra de estado
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));

  // Inicializar dependencias
  await initializeDependencies();

  // Inicializar servicios
  final notificationService = getIt<NotificationService>();
  await notificationService.initialize();

  final audioService = getIt<AudioService>();
  await audioService.initialize();

  // Configurar callback de notificación
  notificationService.onNotificationTapped = _onNotificationTapped;

  // Verificar si la app fue lanzada desde una notificación
  final launchDetails = await notificationService.getAppLaunchDetails();
  String initialRoute = '/';

  if (launchDetails?.didNotificationLaunchApp ?? false) {
    final payload = launchDetails?.notificationResponse?.payload;
    if (payload == 'meditation_complete') {
      initialRoute = '/alarm';
    }
  }

  // Solicitar permisos
  await notificationService.requestAllPermissions();

  runApp(MeditationApp(initialRoute: initialRoute));
}

/// Callback cuando se toca una notificación
void _onNotificationTapped(String? payload) {
  debugPrint('Notification tapped with payload: $payload');

  if (payload == 'meditation_complete') {
    // Navegar a la pantalla de alarma
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      '/alarm',
      (route) => false,
    );
  }
}
