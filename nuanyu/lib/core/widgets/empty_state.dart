import "package:flutter/material.dart";

import "../constants/app_colors.dart";
import "../constants/app_dimensions.dart";

/// A centered empty-state placeholder with an icon, message,
/// and optional action button. Uses warm colors consistent with
/// the NuanYu design language.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.onAction,
    this.actionLabel,
  });

  final String message;
  final IconData icon;
  final VoidCallback? onAction;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.paddingLarge),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
              color: AppColors.textSecondary.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppDimensions.paddingMedium),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppDimensions.fontSizeBody,
                color: AppColors.textSecondary,
                letterSpacing: 0,
              ),
            ),
            if (onAction != null && actionLabel != null) ...[
              const SizedBox(height: AppDimensions.paddingLarge),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppDimensions.paddingLarge,
                    vertical: AppDimensions.paddingSmall + 4,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppDimensions.borderRadiusMedium,
                    ),
                  ),
                ),
                child: Text(
                  actionLabel!,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
