import 'package:flutter/material.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget para seleccionar el sonido de la alarma — diseño horizontal compacto
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

  IconData _iconForSound(String id) {
    return switch (id) {
      'angelical' => Icons.auto_awesome,
      'campana' => Icons.notifications_active_outlined,
      'lluvia' => Icons.water_drop_outlined,
      'bosque' => Icons.park_outlined,
      _ => Icons.music_note,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            S.of(context).alarmSound,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.textMuted,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Row(
          children: SoundConstants.availableSounds.map((sound) {
            final isSelected = selectedSound.id == sound.id;
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: _SoundChip(
                  sound: sound,
                  icon: _iconForSound(sound.id),
                  isSelected: isSelected,
                  onTap: () {
                    if (isSelected) {
                      // Ya seleccionado: toggle stop/play
                      onStopPreview?.call();
                    } else {
                      // Primero reproducir, luego actualizar estado
                      // para evitar que el rebuild interrumpa la carga del asset
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
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.25)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 22,
              color: isSelected ? AppColors.primaryLight : AppColors.textMuted,
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).soundName(sound.id),
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
