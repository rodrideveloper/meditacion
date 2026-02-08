import 'package:flutter/material.dart';

import 'core/di/injection_container.dart';
import 'core/l10n/app_strings.dart';
import 'core/l10n/locale_provider.dart';
import 'core/theme/app_theme.dart';
import 'features/meditation/presentation/pages/home_page.dart';
import 'features/meditation/presentation/pages/alarm_fullscreen_page.dart';
import 'features/meditation/presentation/pages/history_page.dart';
import 'features/meditation/presentation/pages/privacy_policy_page.dart';

/// Clave global del Navigator para navegación desde callbacks
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class MeditationApp extends StatefulWidget {
  final String initialRoute;
  final String? alarmSoundId;

  const MeditationApp({super.key, this.initialRoute = '/', this.alarmSoundId});

  @override
  State<MeditationApp> createState() => _MeditationAppState();
}

class _MeditationAppState extends State<MeditationApp> {
  final LocaleProvider _localeProvider = getIt<LocaleProvider>();

  @override
  void initState() {
    super.initState();
    _localeProvider.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    _localeProvider.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final strings = _localeProvider.strings;

    return AppStringsScope(
      strings: strings,
      child: MaterialApp(
        title: strings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        navigatorKey: navigatorKey,
        initialRoute: widget.initialRoute,
        onGenerateRoute: (settings) {
          // Si es la ruta /alarm abierta desde cold-start, inyectar soundId
          if (settings.name == '/alarm') {
            final args =
                settings.arguments as Map<String, dynamic>? ??
                (widget.alarmSoundId != null
                    ? {'soundId': widget.alarmSoundId}
                    : <String, dynamic>{});
            return MaterialPageRoute(
              settings: RouteSettings(name: '/alarm', arguments: args),
              builder: (context) => const AlarmFullScreenPage(),
            );
          }
          // Rutas estándar
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => const HomePage(),
              );
            case '/history':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => const HistoryPage(),
              );
            case '/privacy':
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => const PrivacyPolicyPage(),
              );
            default:
              return MaterialPageRoute(
                settings: settings,
                builder: (context) => const HomePage(),
              );
          }
        },
      ),
    );
  }
}
