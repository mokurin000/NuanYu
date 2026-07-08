import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/mood_utils.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/mood_indicator.dart';
import 'mood_record_sheet.dart';
import 'providers/mood_provider.dart';

class MoodDetailPage extends ConsumerWidget {
  final String entryId;

  const MoodDetailPage({super.key, required this.entryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(moodProvider);
    final entry = state.entries.where((e) => e.id == entryId).firstOrNull;

    if (entry == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('记录详情')),
        body: const Center(child: Text('记录不存在')),
      );
    }

    final color = moodColor(entry.moodScore);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('记录详情'),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => MoodRecordSheet(existingEntry: entry),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            onPressed: () => _confirmDelete(context, ref, entry),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            WarmCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    MoodIndicator(moodScore: entry.moodScore, size: 64),
                    const SizedBox(height: 16),
                    Text(
                      '${entry.moodScore} 分',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      moodLabel(entry.moodScore),
                      style: TextStyle(fontSize: 16, color: color),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (entry.emotionLabel != null)
              WarmCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.label_outline, color: AppColors.textSecondary, size: 20),
                      const SizedBox(width: 12),
                      Text(
                        entry.emotionLabel!,
                        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            if (entry.emotionLabel != null) const SizedBox(height: 12),
            if (entry.note != null && entry.note!.isNotEmpty)
              WarmCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '备注',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        entry.note!,
                        style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 12),
            Text(
              '${entry.date} ${entry.time}',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, dynamic entry) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: const Text('删除后无法恢复，确定要删除这条记录吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              await ref.read(moodProvider.notifier).deleteEntry(entry.id);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) context.pop();
            },
            child: const Text('删除', style: TextStyle(color: Colors.redAccent)),
          ),
        ],
      ),
    );
  }
}

