import 'package:uuid/uuid.dart';

class MoodEntry {
  final String id;
  final String date;
  final String time;
  final int moodScore;
  final String? emotionLabel;
  final String? note;
  final String createdAt;

  MoodEntry({
    String? id,
    required this.date,
    required this.time,
    required this.moodScore,
    this.emotionLabel,
    this.note,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      moodScore: json['moodScore'] as int,
      emotionLabel: json['emotionLabel'] as String?,
      note: json['note'] as String?,
      createdAt: json['createdAt'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'moodScore': moodScore,
      'emotionLabel': emotionLabel,
      'note': note,
      'createdAt': createdAt,
    };
  }

  MoodEntry copyWith({
    String? id,
    String? date,
    String? time,
    int? moodScore,
    String? emotionLabel,
    String? note,
    String? createdAt,
    bool clearEmotionLabel = false,
    bool clearNote = false,
  }) {
    return MoodEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      moodScore: moodScore ?? this.moodScore,
      emotionLabel: clearEmotionLabel ? null : emotionLabel ?? this.emotionLabel,
      note: clearNote ? null : note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'MoodEntry(id: $id, date: $date, time: $time, moodScore: $moodScore, emotionLabel: $emotionLabel, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodEntry && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
