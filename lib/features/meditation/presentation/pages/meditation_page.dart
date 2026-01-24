import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/meditation_session.dart';
import '../bloc/meditation_bloc.dart';
import '../bloc/meditation_event.dart';
import '../bloc/timer_bloc.dart';
import '../bloc/timer_event.dart';
import '../bloc/timer_state.dart';
import '../widgets/timer_display.dart';

/// Página de meditación activa
class MeditationPage extends StatelessWidget {
  final MeditationSession session;

  const MeditationPage({
    super.key,
    required this.session,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<TimerBloc>()..add(StartTimerEvent(session.duration)),
      child: _MeditationPageContent(session: session),
    );
  }
}

class _MeditationPageContent extends StatelessWidget {
  final MeditationSession session;

  const _MeditationPageContent({required this.session});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _showCancelDialog(context);
        }
      },
      child: Scaffold(
        body: Container(
          decoration: const BoxDecoration(
            gradient: AppColors.backgroundGradient,
          ),
          child: SafeArea(
            child: BlocConsumer<TimerBloc, TimerState>(
              listener: (context, state) {
                if (state is TimerCompleted) {
                  // El timer terminó, pero la notificación ya fue programada
                  // así que solo cerramos esta pantalla
                  context.read<MeditationBloc>().add(const MeditationCompletedEvent());
                  Navigator.of(context).pop();
                }
              },
              builder: (context, state) {
                return Column(
                  children: [
                    // Header
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () => _showCancelDialog(context),
                          ),
                          Text(
                            'Meditando...',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(width: 48), // Placeholder para centrar
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Timer circular
                    TimerDisplay(
                      duration: state.duration,
                      remaining: state.remaining,
                      progress: state.progress,
                    ),

                    const SizedBox(height: 40),

                    // Mensaje motivacional
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        _getMotivationalMessage(state),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: AppColors.textSecondary,
                              fontStyle: FontStyle.italic,
                            ),
                      ),
                    ),

                    const Spacer(),

                    // Controles
                    _buildControls(context, state),

                    const SizedBox(height: 40),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildControls(BuildContext context, TimerState state) {
    final timerBloc = context.read<TimerBloc>();

    if (state is TimerRunning) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón de pausar
          _ControlButton(
            icon: Icons.pause_rounded,
            label: 'Pausar',
            onPressed: () => timerBloc.add(const PauseTimerEvent()),
          ),
          const SizedBox(width: 24),
          // Botón de cancelar
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'Detener',
            color: AppColors.accent,
            onPressed: () => _showCancelDialog(context),
          ),
        ],
      );
    } else if (state is TimerPaused) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Botón de reanudar
          _ControlButton(
            icon: Icons.play_arrow_rounded,
            label: 'Reanudar',
            onPressed: () => timerBloc.add(const ResumeTimerEvent()),
          ),
          const SizedBox(width: 24),
          // Botón de cancelar
          _ControlButton(
            icon: Icons.stop_rounded,
            label: 'Detener',
            color: AppColors.accent,
            onPressed: () => _showCancelDialog(context),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  String _getMotivationalMessage(TimerState state) {
    if (state is TimerPaused) {
      return 'Toma un momento. Cuando estés listo, continúa tu práctica.';
    }

    final progress = state.progress;
    if (progress < 0.25) {
      return 'Respira profundo. Deja ir las tensiones del día.';
    } else if (progress < 0.5) {
      return 'Observa tus pensamientos sin juzgarlos.';
    } else if (progress < 0.75) {
      return 'Estás haciendo un gran trabajo. Mantén el enfoque.';
    } else {
      return 'Ya casi terminas. Disfruta estos últimos momentos de paz.';
    }
  }

  void _showCancelDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('¿Cancelar meditación?'),
        content: const Text(
          'Tu progreso no se guardará y la alarma será cancelada.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Continuar'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MeditationBloc>().add(const CancelMeditationEvent());
              context.read<TimerBloc>().add(const StopTimerEvent());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(foregroundColor: AppColors.accent),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  final Color? color;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final buttonColor = color ?? AppColors.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: buttonColor.withValues(alpha: 0.2),
          shape: const CircleBorder(),
          child: InkWell(
            onTap: onPressed,
            customBorder: const CircleBorder(),
            child: Container(
              width: 72,
              height: 72,
              alignment: Alignment.center,
              child: Icon(
                icon,
                size: 36,
                color: buttonColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}
