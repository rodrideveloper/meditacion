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

        // Presets rápidos; el selector completo aparece bajo demanda.
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          runSpacing: 6,
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
        TextButton(
          onPressed: () async {
            final value = await showDialog<int>(
              context: context,
              builder: (_) => _CustomDurationDialog(
                initial: selectedMinutes,
                min: minMinutes,
                max: maxMinutes,
              ),
            );
            if (value != null) onChanged(value);
          },
          child: Text(S.of(context).customDuration),
        ),
      ],
    );
  }
}

class _CustomDurationDialog extends StatefulWidget {
  const _CustomDurationDialog({
    required this.initial,
    required this.min,
    required this.max,
  });
  final int initial, min, max;
  @override
  State<_CustomDurationDialog> createState() => _CustomDurationDialogState();
}

class _CustomDurationDialogState extends State<_CustomDurationDialog> {
  late int value = widget.initial;

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: Text(S.of(context).chooseDuration),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$value ${S.of(context).minutesShort}',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        Slider(
          key: const ValueKey('custom-duration-slider'),
          value: value.toDouble(),
          min: widget.min.toDouble(),
          max: widget.max.toDouble(),
          divisions: widget.max - widget.min,
          semanticFormatterCallback: (v) =>
              '${v.round()} ${S.of(context).minutesShort}',
          onChanged: (v) => setState(() => value = v.round()),
        ),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: Text(S.of(context).cancel),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context, value),
        child: Text(S.of(context).continueAction),
      ),
    ],
  );
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
