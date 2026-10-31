import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/theme/app_theme.dart';
import 'package:meditation_app/features/meditation/presentation/widgets/timer_display.dart';

void main() {
  testWidgets('formats sessions longer than an hour without wrapping minutes', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.darkTheme,
        home: const Scaffold(
          body: TimerDisplay(
            duration: Duration(hours: 1),
            remaining: Duration(hours: 1),
            progress: 0,
          ),
        ),
      ),
    );
    expect(find.text('60:00'), findsOneWidget);
  });
}
