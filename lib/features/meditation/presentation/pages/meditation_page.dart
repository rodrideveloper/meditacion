import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/services/native_alarm_service.dart';
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

  const MeditationPage({super.key, required this.session});

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
          decoration: BoxDecoration(
            gradient: context.palette.backgroundGradient,
          ),
          child: SafeArea(
            child: BlocConsumer<TimerBloc, TimerState>(
              listener: (context, state) {
                if (state is TimerCompleted) {
                  // El timer terminó, pero la notificación ya fue programada
                  // así que solo cerramos esta pantalla
                  context.read<MeditationBloc>().add(
                    const MeditationCompletedEvent(),
                  );
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
                            icon: Icon(Icons.close),
                            onPressed: () => _showCancelDialog(context),
                          ),
                          Text(
                            S.of(context).meditating,
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
                        _getMotivationalMessage(context, state),
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: context.palette.textSecondary,
                          height: 1.5,
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
            label: S.of(context).pause,
            onPressed: () => _pauseSession(context, timerBloc, state),
          ),
          const SizedBox(width: 24),
          // Botón de cancelar
          _ControlButton(
            icon: Icons.stop_rounded,
            label: S.of(context).stopAction,
            color: context.palette.accent,
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
            label: S.of(context).resume,
            onPressed: () => _resumeSession(context, timerBloc, state),
          ),
          const SizedBox(width: 24),
          // Botón de cancelar
          _ControlButton(
            icon: Icons.stop_rounded,
            label: S.of(context).stopAction,
            color: context.palette.accent,
            onPressed: () => _showCancelDialog(context),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Future<void> _pauseSession(
    BuildContext context,
    TimerBloc timerBloc,
    TimerState state,
  ) async {
    final alarm = getIt<NativeAlarmService>();
    await alarm.cancelAlarm();
    timerBloc.add(const PauseTimerEvent());
  }

  Future<void> _resumeSession(
    BuildContext context,
    TimerBloc timerBloc,
    TimerState state,
  ) async {
    if (state is! TimerPaused) return;
    final scheduled = await getIt<NativeAlarmService>().scheduleAlarm(
      duration: state.remaining,
      soundId: session.sound.id,
    );
    if (!scheduled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(S.of(context).alarmRescheduleError)),
        );
      }
      return;
    }
    timerBloc.add(const ResumeTimerEvent());
  }

  String _getMotivationalMessage(BuildContext context, TimerState state) {
    final s = S.of(context);
    if (state is TimerPaused) {
      return s.motivPaused;
    }

    final progress = state.progress;
    if (progress < 0.25) {
      return s.motivEarly;
    } else if (progress < 0.5) {
      return s.motivMid;
    } else if (progress < 0.75) {
      return s.motivLate;
    } else {
      return s.motivFinal;
    }
  }

  void _showCancelDialog(BuildContext context) {
    final s = S.of(context);
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: context.palette.surface,
        title: Text(s.cancelMeditation),
        content: Text(s.cancelMeditationBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(s.continueAction),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              context.read<MeditationBloc>().add(const CancelMeditationEvent());
              context.read<TimerBloc>().add(const StopTimerEvent());
              Navigator.of(context).pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: context.palette.accent,
            ),
            child: Text(s.cancel),
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
    final buttonColor = color ?? context.palette.primary;

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
              child: Icon(icon, size: 36, color: buttonColor),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(color: context.palette.textSecondary, fontSize: 12),
        ),
      ],
    );
  }
}
