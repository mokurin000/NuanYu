import "package:flutter/material.dart";

import "../constants/app_colors.dart";
import "../constants/app_dimensions.dart";

/// A card with warm styling: white background, rounded corners,
/// subtle shadow, and optional tap interaction.
class WarmCard extends StatelessWidget {
  const WarmCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppDimensions.paddingMedium,
        vertical: AppDimensions.paddingSmall,
      ),
      padding: padding ?? const EdgeInsets.all(AppDimensions.paddingMedium),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );

    if (onTap != null) {
      return InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
        splashColor: AppColors.primaryColor.withValues(alpha: 0.1),
        highlightColor: AppColors.primaryColor.withValues(alpha: 0.05),
        child: card,
      );
    }

    return card;
  }
}
