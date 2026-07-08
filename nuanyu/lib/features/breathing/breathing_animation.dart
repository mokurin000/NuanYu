import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'providers/breathing_provider.dart';

class BreathingAnimation extends StatelessWidget {
  final BreathPhase phase;
  final double phaseProgress;
  final SessionState sessionState;

  const BreathingAnimation({
    super.key,
    required this.phase,
    required this.phaseProgress,
    required this.sessionState,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final maxRadius = min(size.width, size.height) * 0.25;

    double scale;
    Color color;

    switch (phase) {
      case BreathPhase.inhale:
        scale = 0.5 + 0.5 * phaseProgress;
        color = AppColors.primaryColor;
        break;
      case BreathPhase.hold:
        scale = 1.0;
        color = AppColors.accentColor;
        break;
      case BreathPhase.exhale:
        scale = 1.0 - 0.5 * phaseProgress;
        color = AppColors.secondaryColor;
        break;
      case BreathPhase.rest:
        scale = 0.5;
        color = AppColors.moodMedium;
        break;
    }

    return Center(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: maxRadius * 2 * scale,
        height: maxRadius * 2 * scale,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color.withValues(alpha: 0.3),
          border: Border.all(
            color: color.withValues(alpha: 0.6),
            width: 3,
          ),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.2),
              blurRadius: 30,
              spreadRadius: 5,
            ),
          ],
        ),
      ),
    );
  }
}

