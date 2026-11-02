import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/l10n/app_strings.dart';
import 'package:meditation_app/core/theme/app_theme.dart';
import 'package:meditation_app/features/meditation/presentation/widgets/duration_picker.dart';

Widget _app({required ValueChanged<int> onChanged}) => AppStringsScope(
  strings: AppStrings.fromLocale(AppLocale.es),
  child: MaterialApp(
    theme: AppTheme.lightTheme,
    home: Scaffold(
      body: Center(
        child: DurationPicker(selectedMinutes: 10, onChanged: onChanged),
      ),
    ),
  ),
);

void main() {
  testWidgets('quick presets update the selected duration', (tester) async {
    var selected = 0;
    await tester.pumpWidget(_app(onChanged: (minutes) => selected = minutes));
    await tester.tap(find.text('15'));
    expect(selected, 15);
  });

  testWidgets('custom duration supports the 120 minute limit', (tester) async {
    var selected = 0;
    await tester.pumpWidget(_app(onChanged: (minutes) => selected = minutes));
    await tester.tap(find.text('Otra duración'));
    await tester.pumpAndSettle();

    final slider = tester.getRect(
      find.byKey(const ValueKey('custom-duration-slider')),
    );
    await tester.tapAt(Offset(slider.right - 2, slider.center.dy));
    await tester.pumpAndSettle();
    expect(find.text('120 min'), findsOneWidget);
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(selected, 120);
  });

  testWidgets('presets wrap on a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: _app(onChanged: (_) {}),
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.text('Otra duración'), findsOneWidget);
  });
}
