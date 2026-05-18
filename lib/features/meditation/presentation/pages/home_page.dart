import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/review_service.dart';
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
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: BlocConsumer<MeditationBloc, MeditationState>(
            listener: (context, state) {
              if (state is MeditationInProgress) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => BlocProvider.value(
                      value: context.read<MeditationBloc>(),
                      child: MeditationPage(session: state.session),
                    ),
                  ),
                );
              } else if (state is MeditationCompleted) {
                // Solicitar reseña en Play Store tras 3+ sesiones completadas
                getIt<ReviewService>().onSessionCompleted();
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
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primary,
                    ),
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          // ── Top bar ──
          Row(
            children: [
              const Icon(
                Icons.self_improvement,
                size: 28,
                color: AppColors.primaryLight,
              ),
              const SizedBox(width: 10),
              Text(
                S.of(context).homeTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              // Language toggle
              _LanguageToggle(),
              IconButton(
                tooltip: S.of(context).viewHistory,
                icon: const Icon(Icons.history, color: AppColors.textSecondary),
                onPressed: () => Navigator.of(context).pushNamed('/history'),
              ),
              IconButton(
                tooltip: S.of(context).privacyPolicy,
                icon: const Icon(
                  Icons.shield_outlined,
                  size: 22,
                  color: AppColors.textSecondary,
                ),
                onPressed: () => Navigator.of(context).pushNamed('/privacy'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ── Duración ──
          DurationPicker(
            selectedMinutes: state.durationMinutes,
            onChanged: (minutes) => bloc.add(ChangeDurationEvent(minutes)),
          ),

          const SizedBox(height: 20),

          // ── Sonido ──
          SoundSelector(
            selectedSound: state.selectedSound,
            onChanged: (sound) => bloc.add(ChangeSoundEvent(sound.id)),
            onPreview: (sound) => audioService.playPreview(sound),
            onStopPreview: () => audioService.stop(),
          ),

          const SizedBox(height: 12),

          // ── Volumen + Vibración ──
          _SettingsRow(
            alarmVolume: state.alarmVolume,
            onVolumeChanged: (v) {
              bloc.add(ChangeVolumeEvent(v));
              // Ajustar en tiempo real si hay un preview sonando
              if (audioService.isPlaying) {
                audioService.setVolume(v);
              }
            },
          ),

          const SizedBox(height: 12),

          // ── Recordatorio diario ──
          const _ReminderRow(),

          // ── Botón centrado en el espacio restante ──
          const Spacer(),

          MeditationButton(
            isActive: false,
            onPressed: () => bloc.add(const StartMeditationEvent()),
          ),

          const Spacer(),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final double alarmVolume;
  final ValueChanged<double> onVolumeChanged;

  const _SettingsRow({
    required this.alarmVolume,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Volumen
          Row(
            children: [
              Icon(
                alarmVolume == 0
                    ? Icons.volume_off
                    : alarmVolume < 0.5
                    ? Icons.volume_down
                    : Icons.volume_up,
                size: 20,
                color: AppColors.textSecondary,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: AppColors.primary,
                    inactiveTrackColor: AppColors.background,
                    thumbColor: AppColors.primaryLight,
                    overlayColor: AppColors.primary.withValues(alpha: 0.15),
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 7,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                  ),
                  child: Slider(
                    value: alarmVolume,
                    min: 0.0,
                    max: 1.0,
                    onChanged: onVolumeChanged,
                  ),
                ),
              ),
              SizedBox(
                width: 36,
                child: Text(
                  '${(alarmVolume * 100).round()}%',
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Recordatorio diario ───────────────────────────────────────

class _ReminderRow extends StatefulWidget {
  const _ReminderRow();

  @override
  State<_ReminderRow> createState() => _ReminderRowState();
}

class _ReminderRowState extends State<_ReminderRow> {
  late final NotificationService _notifService;
  late bool _enabled;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _notifService = getIt<NotificationService>();
    _enabled = _notifService.isDailyReminderEnabled;
    _time = TimeOfDay(
      hour: _notifService.dailyReminderHour,
      minute: _notifService.dailyReminderMinute,
    );
  }

  Future<void> _toggle(bool value) async {
    setState(() => _enabled = value);
    if (value) {
      await _notifService.scheduleDailyReminder(
        hour: _time.hour,
        minute: _time.minute,
      );
    } else {
      await _notifService.cancelDailyReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              surface: AppColors.surface,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _time) {
      setState(() => _time = picked);
      if (_enabled) {
        await _notifService.scheduleDailyReminder(
          hour: picked.hour,
          minute: picked.minute,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final timeStr =
        '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.notifications_active,
            size: 20,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              S.of(context).reminder,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          // Hora (solo visible si activo)
          if (_enabled)
            GestureDetector(
              onTap: _pickTime,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.primaryLight,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          const SizedBox(width: 8),
          SizedBox(
            height: 28,
            child: FittedBox(
              child: Switch(
                value: _enabled,
                onChanged: _toggle,
                activeTrackColor: AppColors.primary,
                activeThumbColor: AppColors.primaryLight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Language toggle ───────────────────────────────────────────

class _LanguageToggle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final provider = getIt<LocaleProvider>();
    final isEnglish = provider.locale == AppLocale.en;

    return GestureDetector(
      onTap: () => provider.toggle(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isEnglish ? 'ES' : 'EN',
          style: const TextStyle(
            color: AppColors.primaryLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
