import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

/// Widget para seleccionar la duración de la meditación
class DurationPicker extends StatelessWidget {
  final int selectedMinutes;
  final ValueChanged<int> onChanged;
  final int minMinutes;
  final int maxMinutes;

  const DurationPicker({
    super.key,
    required this.selectedMinutes,
    required this.onChanged,
    this.minMinutes = 1,
    this.maxMinutes = 120,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Valor actual
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$selectedMinutes',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w300,
                  ),
            ),
            const SizedBox(width: 8),
            Text(
              'min',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: AppColors.textMuted,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppColors.primary,
            inactiveTrackColor: AppColors.surface,
            thumbColor: AppColors.primaryLight,
            overlayColor: AppColors.primary.withValues(alpha: 0.2),
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
          ),
          child: Slider(
            value: selectedMinutes.toDouble(),
            min: minMinutes.toDouble(),
            max: maxMinutes.toDouble(),
            divisions: maxMinutes - minMinutes,
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
        const SizedBox(height: 16),

        // Presets rápidos
        Wrap(
          spacing: 12,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [5, 10, 15, 20, 30, 45, 60].map((minutes) {
            final isSelected = selectedMinutes == minutes;
            return _PresetButton(
              minutes: minutes,
              isSelected: isSelected,
              onTap: () => onChanged(minutes),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PresetButton extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetButton({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: isSelected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Text(
            '$minutes min',
            style: TextStyle(
              color: isSelected ? Colors.white : AppColors.textSecondary,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
