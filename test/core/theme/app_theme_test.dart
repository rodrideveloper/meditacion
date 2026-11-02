import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/theme/app_colors.dart';
import 'package:meditation_app/core/theme/app_theme.dart';

void main() {
  test('light and dark themes expose their palette tokens and local fonts', () {
    expect(
      AppTheme.lightTheme.extension<AppPalette>()?.background,
      AppPalette.light.background,
    );
    expect(
      AppTheme.darkTheme.extension<AppPalette>()?.background,
      AppPalette.dark.background,
    );
    expect(
      AppTheme.lightTheme.textTheme.headlineMedium?.fontFamily,
      'Newsreader',
    );
    expect(AppTheme.lightTheme.textTheme.bodyMedium?.fontFamily, 'SourceSans3');
  });

  test('palette interpolates colors when theme brightness changes', () {
    final middle = AppPalette.light.lerp(AppPalette.dark, .5);
    expect(middle.background, isNot(AppPalette.light.background));
    expect(middle.background, isNot(AppPalette.dark.background));
  });
}
