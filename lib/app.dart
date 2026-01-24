import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/meditation/presentation/pages/home_page.dart';
import 'features/meditation/presentation/pages/alarm_fullscreen_page.dart';

/// Clave global del Navigator para navegación desde callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MeditationApp extends StatelessWidget {
  final String initialRoute;

  const MeditationApp({
    super.key,
    this.initialRoute = '/',
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meditation Timer',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      navigatorKey: navigatorKey,
      initialRoute: initialRoute,
      routes: {
        '/': (context) => const HomePage(),
        '/alarm': (context) => const AlarmFullScreenPage(),
      },
    );
  }
}
