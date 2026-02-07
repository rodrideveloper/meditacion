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

  const MeditationApp({super.key, this.initialRoute = '/'});

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
        routes: {
          '/': (context) => const HomePage(),
          '/alarm': (context) => const AlarmFullScreenPage(),
          '/history': (context) => const HistoryPage(),
          '/privacy': (context) => const PrivacyPolicyPage(),
        },
      ),
    );
  }
}
