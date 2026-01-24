import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../domain/entities/meditation_settings.dart';

/// Contrato del datasource local
abstract class MeditationLocalDatasource {
  /// Obtener configuración guardada
  Future<MeditationSettings> getSavedSettings();

  /// Guardar configuración
  Future<void> saveSettings(MeditationSettings settings);
}

/// Implementación del datasource local usando SharedPreferences
class MeditationLocalDatasourceImpl implements MeditationLocalDatasource {
  final SharedPreferences _prefs;

  MeditationLocalDatasourceImpl(this._prefs);

  @override
  Future<MeditationSettings> getSavedSettings() async {
    final duration = _prefs.getInt(AppConstants.prefLastDuration) ?? 10;
    final soundId =
        _prefs.getString(AppConstants.prefSelectedSound) ?? 'angelical';
    final vibration = _prefs.getBool(AppConstants.prefVibrationEnabled) ?? true;

    return MeditationSettings(
      lastDurationMinutes: duration,
      selectedSoundId: soundId,
      vibrationEnabled: vibration,
    );
  }

  @override
  Future<void> saveSettings(MeditationSettings settings) async {
    await _prefs.setInt(
      AppConstants.prefLastDuration,
      settings.lastDurationMinutes,
    );
    await _prefs.setString(
      AppConstants.prefSelectedSound,
      settings.selectedSoundId,
    );
    await _prefs.setBool(
      AppConstants.prefVibrationEnabled,
      settings.vibrationEnabled,
    );
  }
}
