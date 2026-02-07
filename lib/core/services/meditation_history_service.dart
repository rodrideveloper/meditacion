import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../constants/app_constants.dart';

@immutable
class MeditationHistoryEntry {
  final DateTime startedAt;
  final DateTime completedAt;
  final int durationMinutes;
  final String soundId;
  final bool vibrationEnabled;

  const MeditationHistoryEntry({
    required this.startedAt,
    required this.completedAt,
    required this.durationMinutes,
    required this.soundId,
    required this.vibrationEnabled,
  });

  Duration get duration => Duration(minutes: durationMinutes);

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'completedAt': completedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'soundId': soundId,
    'vibrationEnabled': vibrationEnabled,
  };

  static MeditationHistoryEntry fromJson(Map<String, dynamic> json) {
    return MeditationHistoryEntry(
      startedAt: DateTime.parse(json['startedAt'] as String),
      completedAt: DateTime.parse(json['completedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      soundId: json['soundId'] as String,
      vibrationEnabled: (json['vibrationEnabled'] as bool?) ?? true,
    );
  }
}

@immutable
class ActiveMeditationSession {
  final DateTime startedAt;
  final int durationMinutes;
  final String soundId;
  final bool vibrationEnabled;

  const ActiveMeditationSession({
    required this.startedAt,
    required this.durationMinutes,
    required this.soundId,
    required this.vibrationEnabled,
  });

  Map<String, dynamic> toJson() => {
    'startedAt': startedAt.toIso8601String(),
    'durationMinutes': durationMinutes,
    'soundId': soundId,
    'vibrationEnabled': vibrationEnabled,
  };

  static ActiveMeditationSession fromJson(Map<String, dynamic> json) {
    return ActiveMeditationSession(
      startedAt: DateTime.parse(json['startedAt'] as String),
      durationMinutes: (json['durationMinutes'] as num).toInt(),
      soundId: json['soundId'] as String,
      vibrationEnabled: (json['vibrationEnabled'] as bool?) ?? true,
    );
  }
}

/// Persiste la sesión activa y un historial simple en SharedPreferences.
class MeditationHistoryService {
  final SharedPreferences _prefs;

  const MeditationHistoryService(this._prefs);

  Future<void> saveActiveSession({
    required Duration duration,
    required String soundId,
    required bool vibrationEnabled,
    DateTime? startedAt,
  }) async {
    final active = ActiveMeditationSession(
      startedAt: startedAt ?? DateTime.now(),
      durationMinutes: duration.inMinutes,
      soundId: soundId,
      vibrationEnabled: vibrationEnabled,
    );

    await _prefs.setString(
      AppConstants.prefActiveSessionJson,
      jsonEncode(active.toJson()),
    );
  }

  Future<void> clearActiveSession() async {
    await _prefs.remove(AppConstants.prefActiveSessionJson);
  }

  ActiveMeditationSession? getActiveSession() {
    final raw = _prefs.getString(AppConstants.prefActiveSessionJson);
    if (raw == null || raw.isEmpty) return null;

    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        return ActiveMeditationSession.fromJson(decoded);
      }
      if (decoded is Map) {
        return ActiveMeditationSession.fromJson(
          decoded.cast<String, dynamic>(),
        );
      }
    } catch (_) {
      return null;
    }

    return null;
  }

  Future<void> completeActiveSession({
    required String soundIdFromAlarm,
    DateTime? completedAt,
  }) async {
    final now = completedAt ?? DateTime.now();
    final active = getActiveSession();

    if (active == null) {
      return;
    }

    final entry = MeditationHistoryEntry(
      startedAt: active.startedAt,
      completedAt: now,
      durationMinutes: active.durationMinutes,
      soundId: active.soundId.isNotEmpty ? active.soundId : soundIdFromAlarm,
      vibrationEnabled: active.vibrationEnabled,
    );

    final list =
        _prefs.getStringList(AppConstants.prefSessionHistoryList) ?? <String>[];
    final updated = <String>[jsonEncode(entry.toJson()), ...list];

    // Limitar historial para evitar crecimiento infinito.
    const maxEntries = 200;
    final trimmed = updated.length > maxEntries
        ? updated.sublist(0, maxEntries)
        : updated;

    await _prefs.setStringList(AppConstants.prefSessionHistoryList, trimmed);
    await clearActiveSession();
  }

  List<MeditationHistoryEntry> getHistory() {
    final list =
        _prefs.getStringList(AppConstants.prefSessionHistoryList) ?? <String>[];
    final result = <MeditationHistoryEntry>[];

    for (final raw in list) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map<String, dynamic>) {
          result.add(MeditationHistoryEntry.fromJson(decoded));
        } else if (decoded is Map) {
          result.add(
            MeditationHistoryEntry.fromJson(decoded.cast<String, dynamic>()),
          );
        }
      } catch (_) {
        // Ignorar entradas corruptas
      }
    }

    return result;
  }

  Future<void> clearHistory() async {
    await _prefs.remove(AppConstants.prefSessionHistoryList);
  }

  /// Devuelve la racha actual en días consecutivos (incluido hoy).
  /// Ejemplo: si meditaste hoy y ayer → 2, solo hoy → 1, nada hoy → 0.
  int getCurrentStreak() {
    final history = getHistory(); // más reciente primero
    if (history.isEmpty) return 0;

    // Recoger las fechas únicas (sin hora) en orden descendente
    final uniqueDays = <DateTime>{};
    for (final entry in history) {
      final d = entry.completedAt;
      uniqueDays.add(DateTime(d.year, d.month, d.day));
    }

    final sorted = uniqueDays.toList()..sort((a, b) => b.compareTo(a));

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);

    // Si el día más reciente no es hoy ni ayer, la racha es 0
    final diff = todayDate.difference(sorted.first).inDays;
    if (diff > 1) return 0;

    int streak = 1;
    for (int i = 1; i < sorted.length; i++) {
      final gap = sorted[i - 1].difference(sorted[i]).inDays;
      if (gap == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
  }
}
