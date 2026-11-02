import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// CTA principal de práctica: una sola acción, con un objetivo táctil amplio.
class MeditationButton extends StatelessWidget {
  final bool isActive;
  final VoidCallback onPressed;
  final bool isLoading;

  const MeditationButton({
    super.key,
    required this.isActive,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final label = isActive ? S.of(context).stop : S.of(context).startMeditation;
    final foreground = Theme.of(context).colorScheme.onPrimary;

    return Semantics(
      button: true,
      label: label,
      child: SizedBox(
        width: 240,
        height: 56,
        child: FilledButton.icon(
          onPressed: isLoading ? null : onPressed,
          icon: isLoading
              ? SizedBox.square(
                  dimension: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: foreground,
                  ),
                )
              : Icon(isActive ? Icons.stop_rounded : Icons.play_arrow_rounded),
          label: Text(label),
          style: FilledButton.styleFrom(
            backgroundColor: isActive
                ? context.palette.error
                : context.palette.primary,
            foregroundColor: foreground,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
