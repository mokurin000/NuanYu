/// A single journal entry capturing the user's thoughts, feelings, or reflections.
class JournalEntry {
  final String id;
  final String date;
  final String time;
  final String content;
  final int? moodScore;
  final String createdAt;
  final String? updatedAt;

  const JournalEntry({
    required this.id,
    required this.date,
    required this.time,
    required this.content,
    this.moodScore,
    required this.createdAt,
    this.updatedAt,
  });

  factory JournalEntry.fromJson(Map<String, dynamic> json) {
    return JournalEntry(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      content: json['content'] as String,
      moodScore: json['mood_score'] as int?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'content': content,
      'mood_score': moodScore,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  JournalEntry copyWith({
    String? id,
    String? date,
    String? time,
    String? content,
    int? Function()? moodScore,
    String? createdAt,
    String? Function()? updatedAt,
  }) {
    return JournalEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      content: content ?? this.content,
      moodScore: moodScore != null ? moodScore() : this.moodScore,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt != null ? updatedAt() : this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is JournalEntry && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'JournalEntry(id: $id, date: $date, time: $time, content: ${content.length} chars, moodScore: $moodScore)';
}

String generateUuidV4() {
  final r = List<int>.generate(16, (_) => _randomByte());
  r[6] = (r[6] & 0x0f) | 0x40;
  r[8] = (r[8] & 0x3f) | 0x80;
  return '${_hex(r, 0, 4)}-${_hex(r, 4, 2)}-${_hex(r, 6, 2)}-${_hex(r, 8, 2)}-${_hex(r, 10, 6)}';
}

int _randomByte() {
  final now = DateTime.now().microsecondsSinceEpoch;
  return ((now * 1103515245 + 12345) & 0x7fffffff) % 256;
}

String _hex(List<int> bytes, int start, int count) {
  return bytes.sublist(start, start + count).map((b) => b.toRadixString(16).padLeft(2, '0')).join();
}
