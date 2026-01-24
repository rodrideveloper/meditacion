import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/meditation_bloc.dart';
import '../bloc/meditation_event.dart';
import '../bloc/meditation_state.dart';
import '../widgets/duration_picker.dart';
import '../widgets/sound_selector.dart';
import '../widgets/meditation_button.dart';
import 'meditation_page.dart';

/// Página principal donde se configura la meditación
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<MeditationBloc>()..add(const LoadSettingsEvent()),
      child: const _HomePageContent(),
    );
  }
}

class _HomePageContent extends StatelessWidget {
  const _HomePageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: BlocConsumer<MeditationBloc, MeditationState>(
            listener: (context, state) {
              if (state is MeditationInProgress) {
                // Navegar a la página de meditación activa
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<MeditationBloc>(),
                      child: MeditationPage(session: state.session),
                    ),
                  ),
                );
              } else if (state is MeditationError) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.message),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MeditationLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                );
              }

              if (state is MeditationReady) {
                return _buildReadyContent(context, state);
              }

              return const SizedBox.shrink();
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReadyContent(BuildContext context, MeditationReady state) {
    final bloc = context.read<MeditationBloc>();
    final audioService = getIt<AudioService>();

    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          // Header
          const SizedBox(height: 20),
          const Icon(
            Icons.self_improvement,
            size: 48,
            color: AppColors.primaryLight,
          ),
          const SizedBox(height: 12),
          Text(
            'Meditation Timer',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Configura tu sesión de meditación',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 40),

          // Selector de duración
          DurationPicker(
            selectedMinutes: state.durationMinutes,
            onChanged: (minutes) => bloc.add(ChangeDurationEvent(minutes)),
          ),
          const SizedBox(height: 40),

          // Selector de sonido
          SoundSelector(
            selectedSound: state.selectedSound,
            onChanged: (sound) => bloc.add(ChangeSoundEvent(sound.id)),
            onPreview: (sound) => audioService.playPreview(sound),
          ),
          const SizedBox(height: 24),

          // Toggle de vibración
          _VibrationToggle(
            enabled: state.vibrationEnabled,
            onChanged: () => bloc.add(const ToggleVibrationEvent()),
          ),
          const SizedBox(height: 40),

          // Botón de iniciar
          MeditationButton(
            isActive: false,
            onPressed: () => bloc.add(const StartMeditationEvent()),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _VibrationToggle extends StatelessWidget {
  final bool enabled;
  final VoidCallback onChanged;

  const _VibrationToggle({
    required this.enabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onChanged,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              const Icon(
                Icons.vibration,
                color: AppColors.textSecondary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  'Vibración',
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
              Switch(
                value: enabled,
                onChanged: (_) => onChanged(),
                activeTrackColor: AppColors.primary,
                activeThumbColor: AppColors.primaryLight,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
