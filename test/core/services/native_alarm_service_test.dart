import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meditation_app/core/services/native_alarm_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('com.rodrigorodriguez.meditationtimer/alarm');
  final service = NativeAlarmService();

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('schedules alarms with the expected duration and sound', () async {
    MethodCall? received;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          received = call;
          return true;
        });

    final scheduled = await service.scheduleAlarm(
      duration: const Duration(minutes: 10),
      soundId: 'campana',
    );

    expect(scheduled, isTrue);
    expect(received?.method, 'scheduleAlarm');
    expect(received?.arguments, {
      'delayMillis': const Duration(minutes: 10).inMilliseconds,
      'soundId': 'campana',
    });
  });

  test('reports native scheduling failure to the caller', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (_) async => false);

    final scheduled = await service.scheduleAlarm(
      duration: const Duration(seconds: 2),
      soundId: 'campana',
    );

    expect(scheduled, isFalse);
  });
}
