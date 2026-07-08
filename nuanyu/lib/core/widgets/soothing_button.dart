import "package:flutter/material.dart";
import "package:flutter/services.dart";

import "../constants/app_colors.dart";
import "../constants/app_dimensions.dart";

/// A soothing button with a subtle press animation and haptic feedback.
/// Uses the primary coral color with white text on a rounded shape.
class SoothingButton extends StatefulWidget {
  const SoothingButton({
    super.key,
    required this.label,
    required this.onPressed, // ignore: avoid-nullable-callbacks
    this.icon,
    this.minHeight = 48.0,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double minHeight;

  @override
  State<SoothingButton> createState() => _SoothingButtonState();
}

class _SoothingButtonState extends State<SoothingButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 120),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.96).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    HapticFeedback.lightImpact();
    widget.onPressed?.call();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _controller.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      onTapDown: _handleTapDown,
      onTapUp: _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeInOut,
        transform: Matrix4.diagonal3Values(_scaleAnimation.value, _scaleAnimation.value, 1.0),
        constraints: BoxConstraints(minHeight: widget.minHeight),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(AppDimensions.borderRadiusMedium),
          boxShadow: _isPressed
              ? null
              : const [
                  BoxShadow(
                    color: AppColors.shadowColor,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
        ),
        alignment: Alignment.center,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.paddingMedium,
            vertical: AppDimensions.paddingSmall + 4,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
              ],
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
