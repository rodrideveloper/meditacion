import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/sound_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/native_alarm_service.dart';
import '../../../../core/theme/app_colors.dart';

/// Página de alarma full-screen que aparece sobre el lock screen
class AlarmFullScreenPage extends StatefulWidget {
  const AlarmFullScreenPage({super.key});

  @override
  State<AlarmFullScreenPage> createState() => _AlarmFullScreenPageState();
}

class _AlarmFullScreenPageState extends State<AlarmFullScreenPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;
  final AudioService _audioService = getIt<AudioService>();
  final NativeAlarmService _nativeAlarmService = getIt<NativeAlarmService>();
  String? _soundId;

  @override
  void initState() {
    super.initState();
    debugPrint('=== AlarmFullScreenPage.initState START ===');

    // Configurar animación de pulso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Mantener pantalla encendida
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar sonido de alarma después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint(
        'AlarmFullScreenPage: postFrameCallback fired, initializing alarm...',
      );
      _initializeAndPlayAlarm();
    });
    debugPrint('=== AlarmFullScreenPage.initState END ===');
  }

  Future<void> _initializeAndPlayAlarm() async {
    // Obtener el soundId de los argumentos de la ruta
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    _soundId = args?['soundId'] as String?;

    debugPrint('AlarmFullScreenPage: soundId from args = $_soundId');

    await _startAlarmSound();
  }

  Future<void> _startAlarmSound() async {
    try {
      await _audioService.initialize();

      // Obtener el sonido basado en soundId o usar el default
      final sound = _soundId != null
          ? (MeditationSound.getById(_soundId!) ?? MeditationSound.defaultSound)
          : MeditationSound.defaultSound;

      // Leer volumen configurado por el usuario
      final prefs = getIt<SharedPreferences>();
      final maxVolume = prefs.getDouble(AppConstants.prefAlarmVolume) ?? 0.8;

      debugPrint(
        'AlarmFullScreenPage: Playing sound ${sound.id} at volume $maxVolume',
      );
      await _audioService.playAlarm(sound, maxVolume: maxVolume);
    } catch (e) {
      debugPrint('AlarmFullScreenPage: Error playing alarm sound: $e');
    }
  }

  Future<void> _stopAlarm() async {
    try {
      // Detener sonido Flutter
      await _audioService.stop();
      // Cancelar notificación nativa de alarma
      await _nativeAlarmService.cancelAlarmNotification();
    } catch (e) {
      debugPrint('AlarmFullScreenPage: Error stopping alarm: $e');
    }

    if (mounted) {
      // Restaurar UI del sistema
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

      // Navegar a la página principal
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _audioService.stop();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                context.palette.background,
                context.palette.backgroundLight,
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Icono animado
                AnimatedBuilder(
                  animation: _pulseAnimation,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _pulseAnimation.value,
                      child: Container(
                        width: 150,
                        height: 150,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              context.palette.primary.withValues(alpha: 0.18),
                              context.palette.primary.withValues(alpha: 0.08),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: Icon(
                          Icons.self_improvement,
                          size: 80,
                          color: context.palette.primary,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 48),

                // Título
                Text(
                  S.of(context).meditationCompleted,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                // Subtítulo
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Text(
                    S.of(context).meditationCompletedBody,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: context.palette.textSecondary,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // Botón de detener
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: SizedBox(
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                      onPressed: _stopAlarm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.palette.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_rounded, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context).stopAlarm,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
