/// A self-care activity item that the user can configure and track daily.
class SelfCareItem {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final String? lastCompletedDate;
  final String createdAt;

  /// Returns true when [lastCompletedDate] matches today's date.
  /// This is computed dynamically so it automatically resets after midnight.
  bool get completed {
    if (lastCompletedDate == null) return false;
    final now = DateTime.now();
    final y = now.year.toString().padLeft(4, '0');
    final m = now.month.toString().padLeft(2, '0');
    final d = now.day.toString().padLeft(2, '0');
    return lastCompletedDate == '$y-$m-$d';
  }

  const SelfCareItem({
    required this.id,
    required this.title,
    this.description,
    required this.durationMinutes,
    this.lastCompletedDate,
    required this.createdAt,
  });

  factory SelfCareItem.fromJson(Map<String, dynamic> json) {
    return SelfCareItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      lastCompletedDate: json['last_completed_date'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'duration_minutes': durationMinutes,
      'last_completed_date': lastCompletedDate,
      'created_at': createdAt,
    };
  }

  SelfCareItem copyWith({
    String? id,
    String? title,
    String? Function()? description,
    int? durationMinutes,
    String? Function()? lastCompletedDate,
    String? createdAt,
  }) {
    return SelfCareItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      lastCompletedDate:
          lastCompletedDate != null ? lastCompletedDate() : this.lastCompletedDate,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SelfCareItem && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'SelfCareItem(id: $id, title: $title, durationMinutes: $durationMinutes, completed: $completed)';
}
