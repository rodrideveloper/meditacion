import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection_container.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/l10n/locale_provider.dart';
import '../../../../core/services/audio_service.dart';
import '../../../../core/services/notification_service.dart';
import '../../../../core/theme/appearance_controller.dart';
import '../bloc/meditation_bloc.dart';
import '../bloc/meditation_event.dart';
import '../bloc/meditation_state.dart';
import '../widgets/sound_selector.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _canPop = false;
  bool _savingBeforeExit = false;

  Future<void> _saveBeforeExit() async {
    if (_savingBeforeExit) return;
    _savingBeforeExit = true;
    final saved = await context.read<MeditationBloc>().persistSettingsNow();
    if (!mounted) return;
    if (!saved) {
      _savingBeforeExit = false;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(S.of(context).settingsSaveError)));
      return;
    }
    setState(() => _canPop = true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: _canPop,
    onPopInvokedWithResult: (didPop, _) {
      if (!didPop) _saveBeforeExit();
    },
    child: Scaffold(
      appBar: AppBar(title: Text(S.of(context).settingsTitle)),
      body: BlocBuilder<MeditationBloc, MeditationState>(
        builder: (context, state) {
          if (state is! MeditationReady) {
            return const Center(child: CircularProgressIndicator());
          }
          final bloc = context.read<MeditationBloc>();
          final audio = getIt<AudioService>();
          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: ListView(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
                children: [
                  Text(
                    S.of(context).alarmSound,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 12),
                  SoundSelector(
                    selectedSound: state.selectedSound,
                    onChanged: (sound) => bloc.add(ChangeSoundEvent(sound.id)),
                    onPreview: audio.playPreview,
                    onStopPreview: audio.stop,
                  ),
                  const SizedBox(height: 12),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(context).alarmVolume),
                    subtitle: Slider(
                      value: state.alarmVolume,
                      min: 0,
                      max: 1,
                      label: '${(state.alarmVolume * 100).round()}%',
                      onChanged: (value) {
                        bloc.add(ChangeVolumeEvent(value));
                        if (audio.isPlaying) audio.setVolume(value);
                      },
                    ),
                  ),
                  SwitchListTile.adaptive(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(context).vibration),
                    value: state.vibrationEnabled,
                    onChanged: (_) => bloc.add(const ToggleVibrationEvent()),
                  ),
                  const Divider(height: 32),
                  const _ReminderSettings(),
                  const Divider(height: 32),
                  _AppearanceSetting(),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(S.of(context).languageLabel),
                    trailing: TextButton(
                      onPressed: () => getIt<LocaleProvider>().toggle(),
                      child: Text(
                        getIt<LocaleProvider>().locale == AppLocale.es
                            ? 'Español · ES'
                            : 'English · EN',
                      ),
                    ),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.shield_outlined),
                    title: Text(S.of(context).privacyPolicy),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => Navigator.of(context).pushNamed('/privacy'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  );
}

class _AppearanceSetting extends StatelessWidget {
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
            if (mode != null) {
              appearance.setMode(mode);
            }
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

class _ReminderSettings extends StatefulWidget {
  const _ReminderSettings();
  @override
  State<_ReminderSettings> createState() => _ReminderSettingsState();
}

class _ReminderSettingsState extends State<_ReminderSettings> {
  late final NotificationService service = getIt<NotificationService>();
  late bool enabled = service.isDailyReminderEnabled;
  late TimeOfDay time = TimeOfDay(
    hour: service.dailyReminderHour,
    minute: service.dailyReminderMinute,
  );

  Future<void> _setEnabled(bool value) async {
    setState(() => enabled = value);
    if (value) {
      await service.scheduleDailyReminder(hour: time.hour, minute: time.minute);
    } else {
      await service.cancelDailyReminder();
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: time);
    if (picked == null || !mounted) return;
    setState(() => time = picked);
    if (enabled) {
      await service.scheduleDailyReminder(
        hour: picked.hour,
        minute: picked.minute,
      );
    }
  }

  @override
  Widget build(BuildContext context) => Column(
    children: [
      SwitchListTile.adaptive(
        contentPadding: EdgeInsets.zero,
        title: Text(S.of(context).reminder),
        value: enabled,
        onChanged: _setEnabled,
      ),
      if (enabled)
        ListTile(
          contentPadding: EdgeInsets.zero,
          title: Text(S.of(context).reminderTime),
          trailing: TextButton(
            onPressed: _pickTime,
            child: Text(time.format(context)),
          ),
        ),
    ],
  );
}
