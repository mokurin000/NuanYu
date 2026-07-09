import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/self_care_item.dart';
import '../../../data/repositories/self_care_repository.dart';

final selfCareRepositoryProvider = Provider<SelfCareRepository>(
  (ref) => SelfCareRepository(),
);

final selfCareProvider = NotifierProvider<SelfCareNotifier, SelfCareState>(
  SelfCareNotifier.new,
);

final currentMinuteProvider = StreamProvider<DateTime>((ref) async* {
  while (true) {
    final now = DateTime.now();
    yield now;

    final nextMinute = DateTime(
      now.year,
      now.month,
      now.day,
      now.hour,
      now.minute + 1,
    );

    await Future.delayed(nextMinute.difference(now));
  }
});

final dailyAffirmationProvider = Provider<String>((ref) {
  final now = ref.watch(currentMinuteProvider).value ?? DateTime.now();

  const affirmations = [
    '今天我允许自己慢慢来',
    '我的感受是被允许的',
    '我已经做得很好了',
    '温柔对待自己，就像对待最好的朋友',
    '每一个呼吸都是新的开始',
    '我不需要完美，我只需要真实',
    '此刻的我，已经足够好',
    '允许自己休息，不是软弱',
    '我值得被温柔对待',
    '今天的我，比昨天更有力量',
    '小小的进步，也是进步',
    '我在学着爱自己',
  ];

  final rng = Random(now.hour * 60 + now.minute);
  return affirmations[rng.nextInt(affirmations.length)];
});

class SelfCareState {
  final List<SelfCareItem> items;
  final bool isLoading;

  const SelfCareState({this.items = const [], this.isLoading = false});

  SelfCareState copyWith({List<SelfCareItem>? items, bool? isLoading}) {
    return SelfCareState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class SelfCareNotifier extends Notifier<SelfCareState> {
  late final SelfCareRepository _repository;
  bool _initialized = false;

  @override
  SelfCareState build() {
    _repository = ref.read(selfCareRepositoryProvider);
    // Schedule async init after build completes so state mutations
    // happen outside the synchronous build phase.
    Future.microtask(() => _init());
    return const SelfCareState(isLoading: true);
  }

  Future<void> _init() async {
    if (_initialized) return;
    _initialized = true;
    try {
      // seed defaults if repo is empty
      if ((await _repository.getAll()).isEmpty) {
        await _seedDefaults();
      }

      await loadItems();
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> _seedDefaults() async {
    final defaults = [
      SelfCareItem(
        id: '',
        title: '喝一杯温水',
        durationMinutes: 5,
        createdAt: DateTime.now().toIso8601String(),
      ),
      SelfCareItem(
        id: '',
        title: '出门散步',
        durationMinutes: 15,
        createdAt: DateTime.now().toIso8601String(),
      ),
      SelfCareItem(
        id: '',
        title: '写下3件感恩的事',
        durationMinutes: 10,
        createdAt: DateTime.now().toIso8601String(),
      ),
      SelfCareItem(
        id: '',
        title: '听一首喜欢的歌',
        durationMinutes: 5,
        createdAt: DateTime.now().toIso8601String(),
      ),
      SelfCareItem(
        id: '',
        title: '给植物浇水',
        durationMinutes: 5,
        createdAt: DateTime.now().toIso8601String(),
      ),
      SelfCareItem(
        id: '',
        title: '深呼吸5次',
        durationMinutes: 3,
        createdAt: DateTime.now().toIso8601String(),
      ),
    ];
    for (final item in defaults) {
      await _repository.insert(item);
    }
  }

  Future<void> loadItems() async {
    state = state.copyWith(isLoading: true);
    final items = await _repository.getAll();
    state = state.copyWith(items: items, isLoading: false);
  }

  Future<void> addItem(SelfCareItem item) async {
    await _repository.insert(item);
    await loadItems();
  }

  Future<void> updateItem(SelfCareItem item) async {
    await _repository.update(item);
    await loadItems();
  }

  Future<void> deleteItem(String id) async {
    await _repository.delete(id);
    await loadItems();
  }

  Future<void> toggleCompletedToday(String id) async {
    await _repository.markCompletedToday(id);
    await loadItems();
  }
}
