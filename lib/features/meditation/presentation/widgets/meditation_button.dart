import 'package:flutter/material.dart';

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
        height: 180,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isActive
                ? [
                    AppColors.accent,
                    AppColors.accent.withValues(alpha: 0.7),
                  ]
                : [
                    AppColors.primary,
                    AppColors.primaryDark,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: (isActive ? AppColors.accent : AppColors.primary)
                  .withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
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
                      size: 64,
                      color: Colors.white,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isActive ? 'DETENER' : 'INICIAR',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
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
