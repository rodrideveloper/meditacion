import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:meditation_app/core/l10n/app_strings.dart';
import 'package:meditation_app/core/services/meditation_history_service.dart';
import 'package:meditation_app/core/theme/app_theme.dart';
import 'package:meditation_app/features/meditation/presentation/pages/history_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final getIt = GetIt.instance;
  late SharedPreferences preferences;

  setUp(() async {
    await getIt.reset();
    SharedPreferences.setMockInitialValues({});
    preferences = await SharedPreferences.getInstance();
    getIt.registerSingleton<MeditationHistoryService>(
      MeditationHistoryService(preferences),
    );
  });

  tearDown(() async => getIt.reset());

  Widget app() => AppStringsScope(
    strings: AppStrings.fromLocale(AppLocale.es),
    child: MaterialApp(theme: AppTheme.lightTheme, home: const HistoryPage()),
  );

  testWidgets('shows a calm empty state when there are no sessions', (
    tester,
  ) async {
    await tester.pumpWidget(app());

    expect(find.text('Tu práctica empieza acá.'), findsOneWidget);
    expect(find.textContaining('Cada vez que volvés'), findsOneWidget);
  });

  testWidgets('deletes history only after confirmation', (tester) async {
    final entry = MeditationHistoryEntry(
      startedAt: DateTime(2026, 11, 2, 9),
      completedAt: DateTime(2026, 11, 2, 9, 10),
      durationMinutes: 10,
      soundId: 'campana',
      vibrationEnabled: true,
    );
    await preferences.setStringList('session_history_list', [
      jsonEncode(entry.toJson()),
    ]);
    await tester.pumpWidget(app());

    expect(find.text('10 min · Campana'), findsOneWidget);
    await tester.tap(find.byTooltip('Borrar historial'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Borrar').last);
    await tester.pumpAndSettle();

    expect(find.text('Tu práctica empieza acá.'), findsOneWidget);
  });
}
