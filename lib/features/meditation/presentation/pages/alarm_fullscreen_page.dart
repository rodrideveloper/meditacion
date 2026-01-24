import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
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
  final NotificationService _notificationService = getIt<NotificationService>();

  @override
  void initState() {
    super.initState();

    // Configurar animación de pulso
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    // Iniciar sonido de alarma
    _startAlarmSound();

    // Mantener pantalla encendida
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  Future<void> _startAlarmSound() async {
    await _audioService.initialize();
    await _audioService.playAlarm(MeditationSound.defaultSound);
  }

  Future<void> _stopAlarm() async {
    await _audioService.stop();
    await _notificationService.cancelAlarm();

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
              colors: [
                Color(0xFF1A1A2E),
                Color(0xFF0F0F1A),
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
                  '🧘 Meditación Completada',
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
                    'Tu sesión de meditación ha terminado.\nToma un momento para volver al presente.',
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
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.stop_rounded, size: 28),
                          SizedBox(width: 12),
                          Text(
                            'DETENER ALARMA',
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
          'o desliza para detener',
          style: TextStyle(
            color: AppColors.textMuted,
            fontSize: 12,
          ),
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
                    child: const Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Texto
              Center(
                child: Text(
                  'Desliza →',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
