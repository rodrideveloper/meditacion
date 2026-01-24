import 'package:flutter/material.dart';

import '../../../../core/constants/sound_constants.dart';
import '../../../../core/theme/app_colors.dart';

/// Widget para seleccionar el sonido de la alarma
class SoundSelector extends StatelessWidget {
  final MeditationSound selectedSound;
  final ValueChanged<MeditationSound> onChanged;
  final Function(MeditationSound)? onPreview;

  const SoundSelector({
    super.key,
    required this.selectedSound,
    required this.onChanged,
    this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            'Sonido de alarma',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ),
        ...SoundConstants.availableSounds.map((sound) {
          final isSelected = selectedSound.id == sound.id;
          return _SoundTile(
            sound: sound,
            isSelected: isSelected,
            onTap: () => onChanged(sound),
            onPreview: () => onPreview?.call(sound),
          );
        }),
      ],
    );
  }
}

class _SoundTile extends StatelessWidget {
  final MeditationSound sound;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onPreview;

  const _SoundTile({
    required this.sound,
    required this.isSelected,
    required this.onTap,
    required this.onPreview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: isSelected
            ? AppColors.primary.withValues(alpha: 0.2)
            : AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Radio button
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.textMuted,
                      width: 2,
                    ),
                  ),
                  child: isSelected
                      ? Center(
                          child: Container(
                            width: 12,
                            height: 12,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.primary,
                            ),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 16),

                // Nombre del sonido
                Expanded(
                  child: Text(
                    sound.name,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.textPrimary
                          : AppColors.textSecondary,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),

                // Botón de preview
                IconButton(
                  icon: const Icon(Icons.play_circle_outline),
                  color: AppColors.primary,
                  onPressed: onPreview,
                  tooltip: 'Escuchar',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
