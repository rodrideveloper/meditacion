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
    debugPrint('>>> NativeAlarmService.initialize() START');
    // Escuchar invocaciones desde Android (alarmTriggered)
    _methodChannel.setMethodCallHandler(_handleNativeCall);
    debugPrint('>>> MethodCallHandler set on channel');
    debugPrint('>>> NativeAlarmService.initialize() END');
  }

  /// Verificar si hay alarma pendiente. Retorna el soundId si hay una, o null.
  Future<String?> checkPendingAlarm() async {
    debugPrint('>>> NativeAlarmService.checkPendingAlarm: checking...');
    try {
      final result = await _methodChannel.invokeMethod<Map>(
        'checkPendingAlarm',
      );
      debugPrint('>>> checkPendingAlarm result: $result');
      if (result != null && result['hasPending'] == true) {
        final soundId = result['soundId'] as String? ?? 'angelical';
        debugPrint('>>> PENDING ALARM FOUND! Sound: $soundId');
        return soundId;
      } else {
        debugPrint('>>> No pending alarm found');
        return null;
      }
    } catch (e) {
      debugPrint('>>> Error checking pending alarm: $e');
      return null;
    }
  }

  /// Manejar llamadas desde Android → Flutter
  Future<dynamic> _handleNativeCall(MethodCall call) async {
    debugPrint(
      '>>> NativeAlarmService._handleNativeCall: method=${call.method}',
    );
    debugPrint(
      '>>> NativeAlarmService._handleNativeCall: arguments=${call.arguments}',
    );
    if (call.method == 'alarmTriggered') {
      final args = call.arguments as Map?;
      final soundId = args?['soundId'] as String? ?? 'angelical';
      debugPrint('>>> ALARM TRIGGERED via MethodChannel! Sound: $soundId');
      debugPrint(
        '>>> onAlarmTriggered callback is null: ${onAlarmTriggered == null}',
      );
      onAlarmTriggered?.call(soundId);
      debugPrint('>>> onAlarmTriggered callback invoked');
    } else {
      debugPrint('>>> Unknown method from native: ${call.method}');
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

  /// Cancelar la notificación de alarma nativa
  Future<void> cancelAlarmNotification() async {
    try {
      await _methodChannel.invokeMethod('cancelAlarmNotification');
      debugPrint('Alarm notification cancelled from Flutter');
    } catch (e) {
      debugPrint('Error cancelling alarm notification: $e');
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
