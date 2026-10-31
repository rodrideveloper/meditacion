import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/services/review_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/appearance_controller.dart';
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
        decoration: BoxDecoration(gradient: context.palette.backgroundGradient),
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
                    backgroundColor: context.palette.error,
                  ),
                );
              }
            },
            builder: (context, state) {
              if (state is MeditationLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      context.palette.primary,
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
              Text(
                'volver',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontFamily: 'serif',
                  fontSize: 25,
                  letterSpacing: -1,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Ajustes',
                icon: Icon(Icons.tune, color: context.palette.textSecondary),
                onPressed: () => showModalBottomSheet<void>(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: context.palette.background,
                  builder: (sheetContext) => BlocProvider.value(
                    value: bloc,
                    child: BlocBuilder<MeditationBloc, MeditationState>(
                      builder: (sheetContext, settingsState) {
                        if (settingsState is! MeditationReady) {
                          return const SizedBox.shrink();
                        }
                        return SafeArea(
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  S.of(sheetContext).settingsTitle,
                                  style: Theme.of(sheetContext)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontFamily: 'serif'),
                                ),
                                const SizedBox(height: 20),
                                SoundSelector(
                                  selectedSound: settingsState.selectedSound,
                                  onChanged: (sound) =>
                                      bloc.add(ChangeSoundEvent(sound.id)),
                                  onPreview: (sound) =>
                                      audioService.playPreview(sound),
                                  onStopPreview: () => audioService.stop(),
                                ),
                                const SizedBox(height: 12),
                                _SettingsRow(
                                  alarmVolume: settingsState.alarmVolume,
                                  vibrationEnabled:
                                      settingsState.vibrationEnabled,
                                  onVibrationChanged: (_) =>
                                      bloc.add(const ToggleVibrationEvent()),
                                  onVolumeChanged: (v) {
                                    bloc.add(ChangeVolumeEvent(v));
                                    if (audioService.isPlaying) {
                                      audioService.setVolume(v);
                                    }
                                  },
                                ),
                                const SizedBox(height: 12),
                                const _ReminderRow(),
                                _AppearanceRow(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: _LanguageToggle(),
                                ),
                                TextButton.icon(
                                  onPressed: () {
                                    Navigator.pop(sheetContext);
                                    Navigator.of(context).pushNamed('/privacy');
                                  },
                                  icon: Icon(Icons.shield_outlined),
                                  label: Text(S.of(context).privacyPolicy),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              IconButton(
                tooltip: S.of(context).viewHistory,
                icon: Icon(
                  Icons.timeline,
                  color: context.palette.textSecondary,
                ),
                onPressed: () => Navigator.of(context).pushNamed('/history'),
              ),
            ],
          ),

          const SizedBox(height: 22),
          Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  S.of(context).homeGreeting,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontFamily: 'serif',
                    fontSize: 32,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  S.of(context).homeSubtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),

          const SizedBox(height: 26),

          // ── Duración ──
          DurationPicker(
            selectedMinutes: state.durationMinutes,
            onChanged: (minutes) => bloc.add(ChangeDurationEvent(minutes)),
          ),

          const Spacer(),
          MeditationButton(
            isActive: false,
            onPressed: () => bloc.add(const StartMeditationEvent()),
          ),
          const SizedBox(height: 24),
          Text(
            S.of(context).gentleReturn,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: context.palette.textMuted,
              fontStyle: FontStyle.italic,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final double alarmVolume;
  final bool vibrationEnabled;
  final ValueChanged<bool> onVibrationChanged;
  final ValueChanged<double> onVolumeChanged;

  const _SettingsRow({
    required this.alarmVolume,
    required this.vibrationEnabled,
    required this.onVibrationChanged,
    required this.onVolumeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: context.palette.surface,
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
                color: context.palette.textSecondary,
              ),
              Expanded(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: context.palette.primary,
                    inactiveTrackColor: context.palette.background,
                    thumbColor: context.palette.primaryLight,
                    overlayColor: context.palette.primary.withValues(
                      alpha: 0.15,
                    ),
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
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.palette.textMuted,
                  ),
                  textAlign: TextAlign.end,
                ),
              ),
            ],
          ),
          SwitchListTile.adaptive(
            contentPadding: EdgeInsets.zero,
            title: Text(S.of(context).vibration),
            value: vibrationEnabled,
            onChanged: onVibrationChanged,
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
            colorScheme: ColorScheme.fromSeed(
              seedColor: context.palette.primary,
              brightness: Theme.of(context).brightness,
              surface: context.palette.surface,
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
        color: context.palette.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.notifications_active,
            size: 20,
            color: context.palette.textSecondary,
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
                  color: context.palette.background.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  timeStr,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: context.palette.primaryLight,
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
                activeTrackColor: context.palette.primary,
                activeThumbColor: context.palette.primaryLight,
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
          color: context.palette.surface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          isEnglish ? 'ES' : 'EN',
          style: TextStyle(
            color: context.palette.primaryLight,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _AppearanceRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appearance = getIt<AppearanceController>();
    return ListenableBuilder(
      listenable: appearance,
      builder: (context, _) => ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(S.of(context).appearanceLabel),
        trailing: DropdownButton<ThemeMode>(
          value: appearance.mode,
          onChanged: (mode) {
            if (mode != null) appearance.setMode(mode);
          },
          items: [
            DropdownMenuItem(
              value: ThemeMode.system,
              child: Text(S.of(context).themeSystem),
            ),
            DropdownMenuItem(
              value: ThemeMode.light,
              child: Text(S.of(context).themeLight),
            ),
            DropdownMenuItem(
              value: ThemeMode.dark,
              child: Text(S.of(context).themeDark),
            ),
          ],
        ),
      ),
    );
  }
}
