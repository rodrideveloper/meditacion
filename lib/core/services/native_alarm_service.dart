import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Servicio para manejar alarmas usando código nativo (AlarmManager)
class NativeAlarmService {
  static final NativeAlarmService _instance = NativeAlarmService._internal();
  factory NativeAlarmService() => _instance;
  NativeAlarmService._internal();

  static const _methodChannel = MethodChannel(
    'com.rodrigorodriguez.meditationtimer/alarm',
  );

  /// Callback que se ejecuta cuando la alarma se dispara
  Function(String soundId)? onAlarmTriggered;

  /// Inicializar el servicio y escuchar eventos de alarma
  Future<void> initialize() async {
    // Escuchar invocaciones desde Android (alarmTriggered)
    _methodChannel.setMethodCallHandler(_handleNativeCall);

    // Verificar si hay una alarma pendiente (app abierta por alarma)
    await _checkPendingAlarm();

    debugPrint('NativeAlarmService initialized');
  }

  /// Manejar llamadas desde Android → Flutter
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    if (call.method == 'alarmTriggered') {
      final args = call.arguments as Map?;
      final soundId = args?['soundId'] as String? ?? 'angelical';
      debugPrint('Native alarm triggered! Sound: $soundId');
      onAlarmTriggered?.call(soundId);
    }
  }

  /// Verificar si la app fue abierta por una alarma
  Future<void> _checkPendingAlarm() async {
    try {
      final result = await _methodChannel.invokeMethod<Map>(
        'checkPendingAlarm',
      );
      if (result != null && result['hasPending'] == true) {
        final soundId = result['soundId'] as String? ?? 'angelical';
        debugPrint('Pending alarm found! Sound: $soundId');

        // Pequeño delay para asegurar que Flutter esté listo
        await Future.delayed(const Duration(milliseconds: 500));
        onAlarmTriggered?.call(soundId);
      }
    } catch (e) {
      debugPrint('Error checking pending alarm: $e');
    }
  }

  /// Programar una alarma
  ///
  /// [duration] - Duración hasta que suene la alarma
  /// [soundId] - ID del sonido a reproducir
  Future<bool> scheduleAlarm({
    required Duration duration,
    required String soundId,
  }) async {
    try {
      final result = await _methodChannel.invokeMethod<bool>('scheduleAlarm', {
        'delayMillis': duration.inMilliseconds,
        'soundId': soundId,
      });

      if (result == true) {
        debugPrint(
          'Alarm scheduled for ${duration.inSeconds} seconds from now',
        );
      }

      return result ?? false;
    } catch (e) {
      debugPrint('Error scheduling alarm: $e');
      return false;
    }
  }

  /// Cancelar la alarma programada
  Future<void> cancelAlarm() async {
    try {
      await _methodChannel.invokeMethod('cancelAlarm');
      debugPrint('Alarm cancelled');
    } catch (e) {
      debugPrint('Error cancelling alarm: $e');
    }
  }

  /// Verificar si se pueden programar alarmas exactas
  Future<bool> canScheduleExactAlarms() async {
    try {
      final result = await _methodChannel.invokeMethod<bool>(
        'canScheduleExactAlarms',
      );
      return result ?? false;
    } catch (e) {
      debugPrint('Error checking exact alarms permission: $e');
      return false;
    }
  }

  /// Liberar recursos
  void dispose() {
    _methodChannel.setMethodCallHandler(null);
  }
}
