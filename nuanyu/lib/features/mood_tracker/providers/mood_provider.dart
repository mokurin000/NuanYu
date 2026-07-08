import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../data/models/mood_entry.dart';
import '../../../data/repositories/mood_repository.dart';

final moodRepositoryProvider = Provider<MoodRepository>((ref) => MoodRepository());

final moodProvider = NotifierProvider<MoodNotifier, MoodState>(MoodNotifier.new);

class MoodState {
  final List<MoodEntry> entries;
  final DateTime selectedDate;
  final bool isLoading;

  const MoodState({
    this.entries = const [],
    required this.selectedDate,
    this.isLoading = false,
  });

  MoodState copyWith({
    List<MoodEntry>? entries,
    DateTime? selectedDate,
    bool? isLoading,
  }) {
    return MoodState(
      entries: entries ?? this.entries,
      selectedDate: selectedDate ?? this.selectedDate,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class MoodNotifier extends Notifier<MoodState> {
  late final MoodRepository _repository;

  @override
  MoodState build() {
    _repository = ref.read(moodRepositoryProvider);
    loadEntries();
    return MoodState(selectedDate: DateTime.now());
  }

  Future<void> loadEntries() async {
    state = state.copyWith(isLoading: true);
    final entries = await _repository.getAll();
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<void> loadByDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    final dateStr = du.formatDate(date);
    final entries = await _repository.getByDate(dateStr);
    state = state.copyWith(entries: entries);
  }

  Future<void> loadByDateRange(DateTime start, DateTime end) async {
    final startStr = du.formatDate(start);
    final endStr = du.formatDate(end);
    final entries = await _repository.getByDateRange(startStr, endStr);
    state = state.copyWith(entries: entries);
  }

  Future<void> addEntry(MoodEntry entry) async {
    await _repository.insert(entry);
    await loadEntries();
  }

  Future<void> updateEntry(MoodEntry entry) async {
    await _repository.update(entry);
    await loadEntries();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.delete(id);
    await loadEntries();
  }

  void selectDate(DateTime date) {
    state = state.copyWith(selectedDate: date);
  }

  List<MoodEntry> get entriesForDate {
    final dateStr = du.formatDate(state.selectedDate);
    return state.entries.where((e) => e.date == dateStr).toList();
  }
}
