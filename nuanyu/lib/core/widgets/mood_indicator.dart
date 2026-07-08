import "package:flutter/material.dart";

import "../utils/mood_utils.dart";

/// A small colored circle that indicates mood level by color.
/// Defaults to 24x24 pixels; size can be overridden.
class MoodIndicator extends StatelessWidget {
  const MoodIndicator({
    super.key,
    required this.moodScore,
    this.size = 24.0,
  });

  final int moodScore;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: moodColor(moodScore),
        shape: BoxShape.circle,
      ),
    );
  }
}
