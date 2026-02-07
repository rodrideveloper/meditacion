import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../l10n/app_strings.dart';

const String _kLocaleKey = 'app_locale';

/// Manages the current [AppLocale] and persists it in SharedPreferences.
///
/// Wrap your [MaterialApp] with this provider to get rebuild on locale change.
class LocaleProvider extends ChangeNotifier {
  final SharedPreferences _prefs;
  AppLocale _locale;

  LocaleProvider(this._prefs)
    : _locale = _parseLocale(_prefs.getString(_kLocaleKey));

  AppLocale get locale => _locale;

  AppStrings get strings => AppStrings.fromLocale(_locale);

  /// Toggle between English and Spanish.
  Future<void> toggle() async {
    _locale = _locale == AppLocale.en ? AppLocale.es : AppLocale.en;
    await _prefs.setString(_kLocaleKey, _locale.name);
    notifyListeners();
  }

  /// Set a specific locale.
  Future<void> setLocale(AppLocale locale) async {
    if (_locale == locale) return;
    _locale = locale;
    await _prefs.setString(_kLocaleKey, locale.name);
    notifyListeners();
  }

  static AppLocale _parseLocale(String? value) {
    if (value == 'es') return AppLocale.es;
    return AppLocale.en; // default
  }
}
