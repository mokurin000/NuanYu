import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/date_utils.dart' as du;
import '../../../data/models/journal_entry.dart';
import '../../../data/repositories/journal_repository.dart';

final journalRepositoryProvider = Provider<JournalRepository>((ref) => JournalRepository());

final journalProvider = StateNotifierProvider<JournalNotifier, JournalState>((ref) {
  return JournalNotifier(ref.read(journalRepositoryProvider));
});

class JournalState {
  final List<JournalEntry> entries;
  final bool isLoading;

  const JournalState({this.entries = const [], this.isLoading = false});

  JournalState copyWith({List<JournalEntry>? entries, bool? isLoading}) {
    return JournalState(
      entries: entries ?? this.entries,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class JournalNotifier extends StateNotifier<JournalState> {
  final JournalRepository _repository;

  JournalNotifier(this._repository) : super(const JournalState()) {
    loadAll();
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true);
    final entries = await _repository.getAll();
    state = state.copyWith(entries: entries, isLoading: false);
  }

  Future<JournalEntry?> getById(String id) async {
    return await _repository.getById(id);
  }

  Future<void> addEntry(JournalEntry entry) async {
    await _repository.insert(entry);
    await loadAll();
  }

  Future<void> updateEntry(JournalEntry entry) async {
    await _repository.update(entry);
    await loadAll();
  }

  Future<void> deleteEntry(String id) async {
    await _repository.delete(id);
    await loadAll();
  }

  List<JournalEntry> get entriesByDate {
    final grouped = <String, List<JournalEntry>>{};
    for (final e in state.entries) {
      grouped.putIfAbsent(e.date, () => []).add(e);
    }
    final sorted = grouped.entries.toList()
      ..sort((a, b) => b.key.compareTo(a.key));
    return sorted.expand((e) => e.value).toList();
  }
}
