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

    // Configurar animación de pulso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // Mantener pantalla encendida
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Iniciar sonido de alarma después del primer frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeAndPlayAlarm();
    });
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
      await _audioService.stop();
      await _nativeAlarmService.cancelAlarm();
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
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF1A1A2E), Color(0xFF0F0F1A)],
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
                              AppColors.primary.withValues(alpha: 0.8),
                              AppColors.primaryDark.withValues(alpha: 0.4),
                              Colors.transparent,
                            ],
                            stops: const [0.0, 0.5, 1.0],
                          ),
                        ),
                        child: const Icon(
                          Icons.self_improvement,
                          size: 80,
                          color: Colors.white,
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
                      color: AppColors.textSecondary,
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
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32),
                        ),
                        elevation: 8,
                        shadowColor: AppColors.primary.withValues(alpha: 0.5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.stop_rounded, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            S.of(context).stopAlarm,
                            style: const TextStyle(
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

                // Deslizar para descartar (alternativa)
                _SwipeToStopWidget(onStop: _stopAlarm),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget de deslizar para detener
class _SwipeToStopWidget extends StatefulWidget {
  final VoidCallback onStop;

  const _SwipeToStopWidget({required this.onStop});

  @override
  State<_SwipeToStopWidget> createState() => _SwipeToStopWidgetState();
}

class _SwipeToStopWidgetState extends State<_SwipeToStopWidget> {
  double _dragPosition = 0;
  final double _maxDrag = 200;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          S.of(context).orSwipeToStop,
          style: TextStyle(color: AppColors.textMuted, fontSize: 12),
        ),
        const SizedBox(height: 12),
        Container(
          width: 280,
          height: 60,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Stack(
            children: [
              // Fondo de progreso
              AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                width: 80 + _dragPosition,
                height: 60,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              // Indicador de arrastre
              Positioned(
                left: _dragPosition,
                top: 5,
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dragPosition += details.delta.dx;
                      _dragPosition = _dragPosition.clamp(0, _maxDrag);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    if (_dragPosition >= _maxDrag * 0.8) {
                      widget.onStop();
                    } else {
                      setState(() {
                        _dragPosition = 0;
                      });
                    }
                  },
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                    ),
                    child: const Icon(Icons.chevron_right, color: Colors.white),
                  ),
                ),
              ),
              // Texto
              Center(
                child: Text(
                  S.of(context).swipe,
                  style: TextStyle(color: AppColors.textMuted, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
