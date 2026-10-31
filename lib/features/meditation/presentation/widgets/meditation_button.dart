import 'package:flutter/material.dart';

import '../../../../core/l10n/app_strings.dart';
import '../../../../core/theme/app_colors.dart';

/// Botón principal para iniciar/detener meditación
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
    return Semantics(
      button: true,
      label: isActive ? S.of(context).stop : S.of(context).start,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(14),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            width: 180,
            height: 58,
            decoration: BoxDecoration(
              color: isActive ? context.palette.error : context.palette.primary,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isActive
                              ? Icons.stop_rounded
                              : Icons.play_arrow_rounded,
                          size: 52,
                          color: Theme.of(context).colorScheme.onPrimary,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isActive ? S.of(context).stop : S.of(context).start,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.onPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
