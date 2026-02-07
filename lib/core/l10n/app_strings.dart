/// Lightweight localization – English (default) + Spanish.
///
/// Usage: `AppStrings.of(context).start`  or  `S.of(context).start`
///
/// The current locale is managed by [LocaleProvider] and persisted in
/// SharedPreferences.
library;

import 'package:flutter/widgets.dart';

// ─── Convenience alias ─────────────────────────────────────────
typedef S = AppStrings;

// ─── Supported locales ─────────────────────────────────────────
enum AppLocale { en, es }

// ─── InheritedWidget to propagate strings down the tree ────────
class AppStringsScope extends InheritedWidget {
  final AppStrings strings;

  const AppStringsScope({
    super.key,
    required this.strings,
    required super.child,
  });

  @override
  bool updateShouldNotify(AppStringsScope oldWidget) =>
      strings.locale != oldWidget.strings.locale;
}

// ─── Main strings class ────────────────────────────────────────
class AppStrings {
  final AppLocale locale;

  const AppStrings._(this.locale);

  factory AppStrings.of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStringsScope>();
    return scope?.strings ?? const AppStrings._(AppLocale.en);
  }

  /// Create from locale enum
  factory AppStrings.fromLocale(AppLocale locale) => AppStrings._(locale);

  // ────────────────────────────────────────────────────────────
  //  App-level
  // ────────────────────────────────────────────────────────────
  String get appTitle => _t('Meditation Timer', 'Temporizador de Meditación');

  // ────────────────────────────────────────────────────────────
  //  Home page
  // ────────────────────────────────────────────────────────────
  String get homeTitle => _t('Meditation', 'Meditación');
  String get viewHistory => _t('View history', 'Ver historial');
  String get vibration => _t('Vibration', 'Vibración');
  String get reminder => _t('Reminder', 'Recordatorio');

  // ────────────────────────────────────────────────────────────
  //  Duration picker
  // ────────────────────────────────────────────────────────────
  String get durationLabel => _t('Duration', 'Duración');
  String get minutesShort => _t('min', 'min');

  // ────────────────────────────────────────────────────────────
  //  Sound selector
  // ────────────────────────────────────────────────────────────
  String get alarmSound => _t('Alarm sound', 'Sonido de alarma');

  // Sound names
  String get soundAngelical => _t('Angelic', 'Angelical');
  String get soundBell => _t('Bell', 'Campana');
  String get soundRain => _t('Rain', 'Lluvia');
  String get soundForest => _t('Forest', 'Bosque');

  String soundName(String id) {
    return switch (id) {
      'angelical' => soundAngelical,
      'campana' => soundBell,
      'lluvia' => soundRain,
      'bosque' => soundForest,
      _ => id,
    };
  }

  // ────────────────────────────────────────────────────────────
  //  Meditation button
  // ────────────────────────────────────────────────────────────
  String get stop => _t('STOP', 'DETENER');
  String get start => _t('START', 'INICIAR');

  // ────────────────────────────────────────────────────────────
  //  Meditation page (active session)
  // ────────────────────────────────────────────────────────────
  String get meditating => _t('Meditating...', 'Meditando...');
  String get pause => _t('Pause', 'Pausar');
  String get stopAction => _t('Stop', 'Detener');
  String get resume => _t('Resume', 'Reanudar');
  String get remaining => _t('remaining', 'restante');

  // Motivational messages
  String get motivPaused => _t(
    'Take a moment. When you\'re ready, continue your practice.',
    'Toma un momento. Cuando estés listo, continúa tu práctica.',
  );
  String get motivEarly => _t(
    'Breathe deeply. Let go of the day\'s tensions.',
    'Respira profundo. Deja ir las tensiones del día.',
  );
  String get motivMid => _t(
    'Observe your thoughts without judging them.',
    'Observa tus pensamientos sin juzgarlos.',
  );
  String get motivLate => _t(
    'You\'re doing great. Stay focused.',
    'Estás haciendo un gran trabajo. Mantén el enfoque.',
  );
  String get motivFinal => _t(
    'Almost done. Enjoy these last moments of peace.',
    'Ya casi terminas. Disfruta estos últimos momentos de paz.',
  );

  // Cancel dialog
  String get cancelMeditation =>
      _t('Cancel meditation?', '¿Cancelar meditación?');
  String get cancelMeditationBody => _t(
    'Your progress won\'t be saved and the alarm will be cancelled.',
    'Tu progreso no se guardará y la alarma será cancelada.',
  );
  String get continueAction => _t('Continue', 'Continuar');
  String get cancel => _t('Cancel', 'Cancelar');

  // ────────────────────────────────────────────────────────────
  //  Alarm fullscreen page
  // ────────────────────────────────────────────────────────────
  String get meditationCompleted =>
      _t('🧘 Meditation Completed', '🧘 Meditación Completada');
  String get meditationCompletedBody => _t(
    'Your meditation session is over.\nTake a moment to return to the present.',
    'Tu sesión de meditación ha terminado.\nToma un momento para volver al presente.',
  );
  String get stopAlarm => _t('STOP ALARM', 'DETENER ALARMA');
  String get orSwipeToStop => _t('or swipe to stop', 'o desliza para detener');
  String get swipe => _t('Swipe →', 'Desliza →');

  // ────────────────────────────────────────────────────────────
  //  History page
  // ────────────────────────────────────────────────────────────
  String get history => _t('History', 'Historial');
  String get clearHistory => _t('Clear history', 'Borrar historial');
  String get clearHistoryConfirm =>
      _t('This action cannot be undone.', 'Esta acción no se puede deshacer.');
  String get delete => _t('Delete', 'Borrar');
  String get noSessionsYet =>
      _t('No sessions recorded yet.', 'Aún no hay sesiones registradas.');

  // ────────────────────────────────────────────────────────────
  //  Notifications
  // ────────────────────────────────────────────────────────────
  String get notifChannelName => _t('Reminders', 'Recordatorios');
  String get notifChannelDesc => _t(
    'Meditation reminders and achievements',
    'Recordatorios y logros de meditación',
  );

  String get notifDailyTitle => _t('🧘 Time to meditate', '🧘 Hora de meditar');
  String get notifDailyBody => _t(
    'Take a few minutes to connect with yourself.',
    'Tómate unos minutos para conectar contigo.',
  );

  String notifStreakTitle(int streak) =>
      _t('🔥 $streak-day streak', '🔥 Racha de $streak días');
  String notifStreakBody(int streak) => _t(
    'Keep it up! You\'ve meditated $streak days in a row.',
    '¡Sigue así! Llevas $streak días meditando seguidos.',
  );

  String get notifInactivityTitle =>
      _t('💤 We miss you', '💤 Te echamos de menos');
  String get notifInactivityBody => _t(
    'It\'s been a while since you meditated. Shall we start again?',
    'Hace tiempo que no meditas. ¿Retomamos?',
  );

  // ────────────────────────────────────────────────────────────
  //  Notification channel (alarm)
  // ────────────────────────────────────────────────────────────
  String get alarmChannelName =>
      _t('Meditation Alarms', 'Alarmas de Meditación');
  String get alarmChannelDesc => _t(
    'End-of-meditation notifications with sound',
    'Notificaciones de fin de meditación con sonido',
  );

  // ────────────────────────────────────────────────────────────
  //  Privacy policy
  // ────────────────────────────────────────────────────────────
  String get privacyPolicy => _t('Privacy Policy', 'Política de Privacidad');

  String get privacySection1Title =>
      _t('1. Information We Collect', '1. Información que Recopilamos');
  String get privacySection1Body => _t(
    'We do not collect, transmit, or store any personal data on external servers.\n\n'
        'All data generated by the App is stored exclusively on your device using local storage. This includes:\n'
        '• Meditation session history (duration, date, sound used)\n'
        '• Your preferences (duration, alarm sound, volume, vibration)\n'
        '• Daily reminder schedule\n'
        '• Language preference',
    'No recopilamos, transmitimos ni almacenamos ningún dato personal en servidores externos.\n\n'
        'Todos los datos generados por la App se almacenan exclusivamente en tu dispositivo. Esto incluye:\n'
        '• Historial de sesiones de meditación (duración, fecha, sonido utilizado)\n'
        '• Tus preferencias (duración, sonido de alarma, volumen, vibración)\n'
        '• Horario de recordatorio diario\n'
        '• Preferencia de idioma',
  );

  String get privacySection2Title =>
      _t('2. Data Sharing', '2. Compartición de Datos');
  String get privacySection2Body => _t(
    'We do not share any data with third parties. The App does not contain analytics, advertising, social login, or cloud storage.',
    'No compartimos ningún dato con terceros. La App no contiene analítica, publicidad, inicio de sesión social ni almacenamiento en la nube.',
  );

  String get privacySection3Title => _t('3. Permissions', '3. Permisos');
  String get privacySection3Body => _t(
    'The App requests the following permissions, all used solely for core functionality:\n\n'
        '• Notifications – To display meditation reminders and streak achievements.\n'
        '• Exact Alarms – To trigger the end-of-meditation alarm at the precise time.\n'
        '• Vibration – Optional haptic feedback when the timer ends.\n'
        '• Boot Completed – To reschedule pending alarms after a device restart.\n'
        '• Wake Lock – To ensure the alarm sounds when the screen is off.',
    'La App solicita los siguientes permisos, todos utilizados exclusivamente para la funcionalidad principal:\n\n'
        '• Notificaciones – Para mostrar recordatorios de meditación y logros de racha.\n'
        '• Alarmas exactas – Para disparar la alarma de fin de meditación en el momento preciso.\n'
        '• Vibración – Retroalimentación háptica opcional cuando el temporizador termine.\n'
        '• Inicio completado – Para reprogramar alarmas después de reiniciar el dispositivo.\n'
        '• Bloqueo de activación – Para asegurar que la alarma suene con la pantalla apagada.',
  );

  String get privacySection4Title =>
      _t('4. Children\'s Privacy', '4. Privacidad de los Niños');
  String get privacySection4Body => _t(
    'The App does not collect personal information from children under 13. Since the App does not collect any personal data from any user, it is safe for all ages.',
    'La App no recopila información personal de niños menores de 13 años. Dado que la App no recopila datos personales de ningún usuario, es segura para todas las edades.',
  );

  String get privacySection5Title =>
      _t('5. Data Retention & Deletion', '5. Retención y Eliminación de Datos');
  String get privacySection5Body => _t(
    'All data is stored locally on your device. You can delete your meditation history at any time from within the App. Uninstalling the App will permanently remove all stored data.',
    'Todos los datos se almacenan localmente en tu dispositivo. Puedes eliminar tu historial de meditación en cualquier momento desde la App. Desinstalar la App eliminará permanentemente todos los datos.',
  );

  String get privacySection6Title => _t('6. Security', '6. Seguridad');
  String get privacySection6Body => _t(
    'Since all data remains on your device and is never transmitted over the internet, there is no risk of data interception or server-side breaches.',
    'Dado que todos los datos permanecen en tu dispositivo y nunca se transmiten por internet, no existe riesgo de interceptación de datos o brechas de seguridad.',
  );

  String get privacySection7Title => _t('7. Contact', '7. Contacto');
  String get privacySection7Body => _t(
    'If you have any questions about this privacy policy, you can contact us at:\nrodrigo.rodriguez@example.com',
    'Si tienes alguna pregunta sobre esta política de privacidad, puedes contactarnos en:\nrodrigo.rodriguez@example.com',
  );

  String get privacyLastUpdated => _t(
    'Last updated: February 7, 2026',
    'Última actualización: 7 de febrero de 2026',
  );

  // ────────────────────────────────────────────────────────────
  //  Private helper
  // ────────────────────────────────────────────────────────────
  String _t(String en, String es) => locale == AppLocale.en ? en : es;
}
