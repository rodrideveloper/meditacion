import 'package:in_app_review/in_app_review.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

/// Servicio para gestionar la solicitud de reseñas en la Play Store.
///
/// Lógica:
/// - Cada vez que se completa una sesión de meditación, se incrementa un contador.
/// - Cuando el contador alcanza [thresholdSessions] (por defecto 3), se intenta
///   mostrar el diálogo nativo de reseña de Google Play.
/// - Después de la primera solicitud, se repite cada [repeatInterval] sesiones
///   (por defecto 10) para no ser intrusivo.
class ReviewService {
  final SharedPreferences _prefs;

  static const int _thresholdSessions = 3;
  static const int _repeatInterval = 10;

  ReviewService(this._prefs);

  /// Debe llamarse cuando el usuario completa una sesión de meditación.
  Future<void> onSessionCompleted() async {
    final count = _incrementSessionCount();

    if (_shouldRequestReview(count)) {
      await _requestReview();
    }
  }

  /// Incrementa y devuelve el nuevo contador de sesiones completadas.
  int _incrementSessionCount() {
    final current = _prefs.getInt(AppConstants.prefCompletedSessionsCount) ?? 0;
    final updated = current + 1;
    _prefs.setInt(AppConstants.prefCompletedSessionsCount, updated);
    return updated;
  }

  /// Determina si se debe solicitar una reseña basándose en el contador.
  bool _shouldRequestReview(int count) {
    if (count == _thresholdSessions) return true;
    if (count > _thresholdSessions &&
        (count - _thresholdSessions) % _repeatInterval == 0) {
      return true;
    }
    return false;
  }

  /// Intenta mostrar el diálogo nativo de reseña si está disponible.
  Future<void> _requestReview() async {
    final inAppReview = InAppReview.instance;

    if (await inAppReview.isAvailable()) {
      await inAppReview.requestReview();
    }
  }
}
