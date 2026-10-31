import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:meditation_app/core/theme/appearance_controller.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('stores selected appearance and restores it on next launch', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final controller = AppearanceController(prefs);
    expect(controller.mode, ThemeMode.system);
    await controller.setMode(ThemeMode.dark);
    expect(prefs.getString('appearance_mode'), 'dark');
    expect(AppearanceController(prefs).mode, ThemeMode.dark);
    controller.dispose();
  });
}
