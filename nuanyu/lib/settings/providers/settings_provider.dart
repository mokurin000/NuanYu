import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/utils/export_utils.dart';
import '../../data/repositories/mood_repository.dart';
import '../../data/repositories/symptom_repository.dart';
import '../../data/repositories/journal_repository.dart';
import '../../data/repositories/self_care_repository.dart';

enum ExportStatus { idle, exporting, done, error }

final settingsProvider = StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  return SettingsNotifier();
});

class SettingsState {
  final ExportStatus exportStatus;
  final String? exportPath;
  final String? exportError;

  const SettingsState({
    this.exportStatus = ExportStatus.idle,
    this.exportPath,
    this.exportError,
  });

  SettingsState copyWith({
    ExportStatus? exportStatus,
    String? exportPath,
    String? exportError,
  }) {
    return SettingsState(
      exportStatus: exportStatus ?? this.exportStatus,
      exportPath: exportPath ?? this.exportPath,
      exportError: exportError ?? this.exportError,
    );
  }
}

class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier() : super(const SettingsState());

  Future<void> exportAllData() async {
    state = state.copyWith(exportStatus: ExportStatus.exporting, exportError: null);

    try {
      final moodRepo = MoodRepository();
      final symptomRepo = SymptomRepository();
      final journalRepo = JournalRepository();
      final selfCareRepo = SelfCareRepository();

      final moodEntries = await moodRepo.getAll();
      final symptomRecords = await symptomRepo.getAll();
      final journalEntries = await journalRepo.getAll();
      final selfCareItems = await selfCareRepo.getAll();

      final data = {
        'exported_at': DateTime.now().toIso8601String(),
        'app': '暖屿',
        'mood_entries': moodEntries.map((e) => e.toJson()).toList(),
        'symptom_records': symptomRecords.map((e) => e.toJson()).toList(),
        'journal_entries': journalEntries.map((e) => e.toJson()).toList(),
        'self_care_items': selfCareItems.map((e) => e.toJson()).toList(),
      };

      final path = await ExportUtils.exportToJson(data);
      state = state.copyWith(
        exportStatus: ExportStatus.done,
        exportPath: path,
      );
    } catch (e) {
      state = state.copyWith(
        exportStatus: ExportStatus.error,
        exportError: e.toString(),
      );
    }
  }

  void resetExportStatus() {
    state = state.copyWith(exportStatus: ExportStatus.idle);
  }
}
