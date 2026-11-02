import 'package:flutter/material.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Selector compacto de sonidos con previsualización y estado accesible.
class SoundSelector extends StatelessWidget {
  final MeditationSound selectedSound;
  final ValueChanged<MeditationSound> onChanged;
  final Function(MeditationSound)? onPreview;
  final VoidCallback? onStopPreview;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.onChanged,
    this.onPreview,
    this.onStopPreview,
  });

  IconData _iconForSound(String id) => switch (id) {
    'angelical' => Icons.auto_awesome,
    'campana' => Icons.notifications_active_outlined,
    'lluvia' => Icons.water_drop_outlined,
    'bosque' => Icons.park_outlined,
    _ => Icons.music_note,
  };

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Padding(
        padding: const EdgeInsets.only(left: 4, bottom: 10),
        child: Text(
          S.of(context).alarmSound,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.palette.textMuted,
            letterSpacing: 1.5,
          ),
        ),
      ),
      Row(
        children: SoundConstants.availableSounds.map((sound) {
          final selected = selectedSound.id == sound.id;
          return Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 3),
              child: _SoundChip(
                sound: sound,
                icon: _iconForSound(sound.id),
                isSelected: selected,
                onTap: () {
                  if (selected) {
                    onStopPreview?.call();
                  } else {
                    onPreview?.call(sound);
                    onChanged(sound);
                  }
                },
              ),
            ),
          );
        }).toList(),
      ),
    ],
  );
}

class _SoundChip extends StatelessWidget {
  final MeditationSound sound;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SoundChip({
    required this.sound,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final label = S.of(context).soundName(sound.id);
    return Semantics(
      button: true,
      selected: isSelected,
      label: label,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            constraints: const BoxConstraints(minHeight: 56),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.palette.primary.withValues(alpha: 0.15)
                  : context.palette.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? context.palette.primary
                    : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: isSelected
                      ? context.palette.primary
                      : context.palette.textMuted,
                ),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: context.palette.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
