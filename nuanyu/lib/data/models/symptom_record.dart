import 'package:uuid/uuid.dart';

class SymptomRecord {
  final String id;
  final String date;
  final String time;
  final String symptomType;
  final int intensity;
  final String? trigger;
  final String? note;
  final String createdAt;

  SymptomRecord({
    String? id,
    required this.date,
    required this.time,
    required this.symptomType,
    required this.intensity,
    this.trigger,
    this.note,
    String? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().toIso8601String();

  factory SymptomRecord.fromJson(Map<String, dynamic> json) {
    return SymptomRecord(
      id: json['id'] as String,
      date: json['date'] as String,
      time: json['time'] as String,
      symptomType: json['symptom_type'] as String,
      intensity: json['intensity'] as int,
      trigger: json['trigger'] as String?,
      note: json['note'] as String?,
      createdAt: json['created_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date,
      'time': time,
      'symptom_type': symptomType,
      'intensity': intensity,
      'trigger': trigger,
      'note': note,
      'created_at': createdAt,
    };
  }

  SymptomRecord copyWith({
    String? id,
    String? date,
    String? time,
    String? symptomType,
    int? intensity,
    String? trigger,
    String? note,
    String? createdAt,
    bool clearTrigger = false,
    bool clearNote = false,
  }) {
    return SymptomRecord(
      id: id ?? this.id,
      date: date ?? this.date,
      time: time ?? this.time,
      symptomType: symptomType ?? this.symptomType,
      intensity: intensity ?? this.intensity,
      trigger: clearTrigger ? null : trigger ?? this.trigger,
      note: clearNote ? null : note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'SymptomRecord(id: $id, date: $date, time: $time, symptomType: $symptomType, intensity: $intensity, trigger: $trigger, note: $note)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SymptomRecord && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

