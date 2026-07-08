library;

/// Date utility functions for the NuanYu app.
/// Provides formatting and comparison helpers for DateTime values.

String formatDate(DateTime date) {
  final y = date.year.toString().padLeft(4, "0");
  final m = date.month.toString().padLeft(2, "0");
  final d = date.day.toString().padLeft(2, "0");
  return "$y-$m-$d";
}

String formatTime(DateTime date) {
  final h = date.hour.toString().padLeft(2, "0");
  final min = date.minute.toString().padLeft(2, "0");
  return "$h:$min";
}

String formatDateTime(DateTime date) {
  return "${formatDate(date)} ${formatTime(date)}";
}

String relativeDayLabel(DateTime date) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final dateStart = DateTime(date.year, date.month, date.day);
  final diff = todayStart.difference(dateStart).inDays;

  if (diff == 0) return "今天";
  if (diff == 1) return "昨天";
  if (diff == 2) return "前天";
  return "${date.month}月${date.day}日";
}

DateTime today() {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
}

String formatMonth(DateTime date) {
  return "${date.year}年${date.month.toString().padLeft(2, "0")}月";
}

bool isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}
