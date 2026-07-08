import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/mood_indicator.dart';
import '../../core/widgets/empty_state.dart';
import '../../core/utils/date_utils.dart' as du;
import 'providers/journal_provider.dart';

class JournalListPage extends ConsumerWidget {
  const JournalListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(journalProvider);
    final entries = state.entries;

    // Group by date
    final dateGroups = <String, List<dynamic>>{};
    String? currentDate;
    for (final e in entries) {
      if (e.date != currentDate) {
        currentDate = e.date;
        dateGroups[e.date] = [e.date];
      }
      dateGroups[e.date]!.add(e);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('日记'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: entries.isEmpty
          ? const EmptyState(
              icon: Icons.book_outlined,
              message: '还没有日记\n点击右下角开始记录',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: dateGroups.length,
              itemBuilder: (context, groupIndex) {
                final date = dateGroups.keys.elementAt(groupIndex);
                final items = dateGroups[date]!.skip(1).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        _formatDateHeader(date),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    ...items.map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: WarmCard(
                            onTap: () => context.push('/journal/detail/${entry.id}'),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (entry.moodScore != null)
                                    Padding(
                                      padding: const EdgeInsets.only(right: 10, top: 2),
                                      child: MoodIndicator(moodScore: entry.moodScore!),
                                    ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          entry.content.length > 80
                                              ? '${entry.content.substring(0, 80)}...'
                                              : entry.content,
                                          style: const TextStyle(
                                            fontSize: 15,
                                            color: AppColors.textPrimary,
                                            height: 1.5,
                                          ),
                                          maxLines: 3,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          entry.time,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/journal/edit'),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  String _formatDateHeader(String dateStr) {
    try {
      final parts = dateStr.split('-');
      final date = DateTime(
        int.parse(parts[0]),
        int.parse(parts[1]),
        int.parse(parts[2]),
      );
      return du.relativeDayLabel(date);
    } catch (_) {
      return dateStr;
    }
  }
}

