import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/date_utils.dart' as du;
import '../../core/utils/mood_utils.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/mood_indicator.dart';
import '../../data/models/mood_entry.dart';
import 'mood_record_sheet.dart';
import 'providers/mood_provider.dart';

class MoodTrackerPage extends ConsumerStatefulWidget {
  const MoodTrackerPage({super.key});

  @override
  ConsumerState<MoodTrackerPage> createState() => _MoodTrackerPageState();
}

class _MoodTrackerPageState extends ConsumerState<MoodTrackerPage> {
  DateTime _currentMonth = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final now = DateTime.now();
      ref.read(moodProvider.notifier).selectDate(
        DateTime(now.year, now.month, now.day),
      );
      _loadMonth(now);
    });
  }

  void _loadMonth(DateTime date) {
    final start = DateTime(date.year, date.month, 1);
    final end = DateTime(date.year, date.month + 1, 0);
    ref.read(moodProvider.notifier).loadByDateRange(start, end);
  }

  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      _loadMonth(_currentMonth);
    });
  }

  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      _loadMonth(_currentMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(moodProvider);
    final entries = state.entries;
    final dateEntries = entries.where(
      (e) => e.date == du.formatDate(state.selectedDate),
    ).toList();

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('情绪追踪'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Today summary
            if (dateEntries.isNotEmpty) ...[
              WarmCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      MoodIndicator(moodScore: dateEntries.first.moodScore, size: 40),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              moodLabel(dateEntries.first.moodScore),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            if (dateEntries.first.emotionLabel != null)
                              Text(
                                dateEntries.first.emotionLabel!,
                                style: const TextStyle(color: AppColors.textSecondary),
                              ),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () => _showRecordSheet(context),
                        child: const Text('记录'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Trend chart link
              InkWell(
                onTap: () => context.push('/mood/trend'),
                child: WarmCard(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        const Icon(Icons.trending_up, color: AppColors.primaryColor),
                        const SizedBox(width: 8),
                        const Text('查看情绪趋势', style: TextStyle(color: AppColors.textSecondary)),
                        const Spacer(),
                        const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ),
            ] else ...[
              WarmCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      const Icon(Icons.mood, size: 48, color: AppColors.textSecondary),
                      const SizedBox(height: 12),
                      const Text(
                        '今天还没有记录',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: () => _showRecordSheet(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('记录今日情绪'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            // Calendar header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  du.formatMonth(_currentMonth),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Day of week headers
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: ['一', '二', '三', '四', '五', '六', '日']
                  .map((d) => SizedBox(
                        width: 40,
                        child: Text(
                          d,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            // Calendar grid
            _buildCalendarGrid(state, entries),
            const SizedBox(height: 16),
            // History entries
            const Text(
              '历史记录',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('暂无记录', style: TextStyle(color: AppColors.textSecondary)),
                ),
              )
            else
              ...entries.take(10).map((entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: WarmCard(
                      onTap: () => context.push('/mood/detail/${entry.id}'),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            MoodIndicator(moodScore: entry.moodScore),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${entry.date} ${entry.time}',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  if (entry.emotionLabel != null)
                                    Text(
                                      entry.emotionLabel!,
                                      style: const TextStyle(color: AppColors.textPrimary),
                                    ),
                                ],
                              ),
                            ),
                            const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
                          ],
                        ),
                      ),
                    ),
                  )),
          ],
        ),
      ),
      floatingActionButton: dateEntries.isNotEmpty
          ? FloatingActionButton(
              onPressed: () => _showRecordSheet(context),
              backgroundColor: AppColors.primaryColor,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildCalendarGrid(MoodState state, List<MoodEntry> entries) {
    final firstDay = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDay = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startOffset = firstDay.weekday - 1; // Monday = 0

    final cells = <Widget>[];
    for (var i = 0; i < startOffset; i++) {
      cells.add(const SizedBox(width: 40, height: 40));
    }

    for (var day = 1; day <= lastDay.day; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final dateStr = du.formatDate(date);
      final dayEntries = entries.where((e) => e.date == dateStr).toList();
      final isSelected = date.year == state.selectedDate.year &&
          date.month == state.selectedDate.month &&
          date.day == state.selectedDate.day;

      cells.add(
        GestureDetector(
          onTap: () {
            ref.read(moodProvider.notifier).selectDate(date);
          },
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.primaryColor.withValues(alpha: 0.2) : null,
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Text(
                  '$day',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    color: isSelected ? AppColors.primaryColor : AppColors.textPrimary,
                  ),
                ),
                if (dayEntries.isNotEmpty)
                  Positioned(
                    bottom: 4,
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: moodColor(dayEntries.first.moodScore),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      );
    }

    return Wrap(
      spacing: 0,
      runSpacing: 4,
      children: cells,
    );
  }

  void _showRecordSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const MoodRecordSheet(),
    );
  }
}


