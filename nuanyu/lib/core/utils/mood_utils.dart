import "package:flutter/material.dart";

import "../constants/app_colors.dart";

/// Returns a mood color based on the score (1-10).
Color moodColor(int score) {
  if (score <= 3) return AppColors.moodLow;
  if (score <= 6) return AppColors.moodMedium;
  if (score <= 8) return AppColors.moodGood;
  return AppColors.moodGreat;
}

/// Returns an emoji string based on the mood score.
String moodEmoji(int score) {
  if (score <= 1) return "😔";
  if (score <= 2) return "😟";
  if (score <= 4) return "😐";
  if (score <= 6) return "🙂";
  if (score <= 8) return "😊";
  return "😄";
}

/// Returns a Chinese text label for the mood score.
String moodLabel(int score) {
  if (score <= 2) return "很低落";
  if (score <= 4) return "低落";
  if (score <= 6) return "一般";
  if (score <= 8) return "较好";
  return "很好";
}
