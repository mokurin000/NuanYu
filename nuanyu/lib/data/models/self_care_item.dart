/// A self-care activity item that the user can configure and track daily.
class SelfCareItem {
  final String id;
  final String title;
  final String? description;
  final int durationMinutes;
  final int isCompletedToday;
  final String? lastCompletedDate;
  final String createdAt;

  /// Computed: returns true when [isCompletedToday] equals 1.
  bool get completed => isCompletedToday == 1;

  const SelfCareItem({
    required this.id,
    required this.title,
    this.description,
    required this.durationMinutes,
    this.isCompletedToday = 0,
    this.lastCompletedDate,
    required this.createdAt,
  });

  factory SelfCareItem.fromJson(Map<String, dynamic> json) {
    return SelfCareItem(
      id: json['id'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      durationMinutes: json['duration_minutes'] as int,
      isCompletedToday: json['is_completed_today'] as int? ?? 0,
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
      'is_completed_today': isCompletedToday,
      'last_completed_date': lastCompletedDate,
      'created_at': createdAt,
    };
  }

  SelfCareItem copyWith({
    String? id,
    String? title,
    String? Function()? description,
    int? durationMinutes,
    int? isCompletedToday,
    String? Function()? lastCompletedDate,
    String? createdAt,
  }) {
    return SelfCareItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description != null ? description() : this.description,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      isCompletedToday: isCompletedToday ?? this.isCompletedToday,
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
