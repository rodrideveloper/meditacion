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
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        width: 180,
        height: 58,
        decoration: BoxDecoration(
          color: isActive ? AppColors.error : AppColors.primary,
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
                      isActive ? Icons.stop_rounded : Icons.play_arrow_rounded,
                      size: 52,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isActive ? S.of(context).stop : S.of(context).start,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 2,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
