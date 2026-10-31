import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
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
        // Valor actual centrado y prominente
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '$selectedMinutes',
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontWeight: FontWeight.w200,
                fontSize: 72,
                color: context.palette.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              S.of(context).minutesShort,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: context.palette.textMuted,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          S.of(context).durationLabel,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: context.palette.textMuted,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),

        // Slider
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: context.palette.primary,
            inactiveTrackColor: context.palette.surface,
            thumbColor: context.palette.primaryLight,
            overlayColor: context.palette.primary.withValues(alpha: 0.2),
            trackHeight: 4,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
          ),
          child: Slider(
            value: selectedMinutes.toDouble(),
            min: minMinutes.toDouble(),
            max: maxMinutes.toDouble(),
            divisions: maxMinutes - minMinutes,
            onChanged: (value) => onChanged(value.round()),
          ),
        ),
        const SizedBox(height: 10),

        // Presets rápidos — solo los más comunes
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [5, 10, 15, 20, 30, 60].map((minutes) {
            final isSelected = selectedMinutes == minutes;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: _PresetChip(
                minutes: minutes,
                isSelected: isSelected,
                onTap: () => onChanged(minutes),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _PresetChip extends StatelessWidget {
  final int minutes;
  final bool isSelected;
  final VoidCallback onTap;

  const _PresetChip({
    required this.minutes,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: isSelected,
      label: '$minutes ${S.of(context).minutesShort}',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            constraints: const BoxConstraints(minHeight: 44, minWidth: 44),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected
                  ? context.palette.primary
                  : context.palette.surface,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '$minutes',
              style: TextStyle(
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : context.palette.textMuted,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
