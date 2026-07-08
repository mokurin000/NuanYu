import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/empty_state.dart';
import 'providers/self_care_provider.dart';
import 'daily_affirmation.dart';

class SelfCarePage extends ConsumerWidget {
  const SelfCarePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(selfCareProvider);
    final items = state.items;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('自我关怀'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(selfCareProvider.notifier).loadItems(),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const DailyAffirmation(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '今日关怀',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  '${items.where((i) => i.completed).length}/${items.length}',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (state.isLoading && items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(48),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (items.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: EmptyState(
                  icon: Icons.self_improvement,
                  message: '还没有关怀项目\n点击下方添加一个吧',
                ),
              )
            else
              ...items.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: WarmCard(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Checkbox(
                            value: item.completed,
                            onChanged: (_) {
                              if (!item.completed) {
                                ref
                                    .read(selfCareProvider.notifier)
                                    .toggleCompletedToday(item.id);
                              }
                            },
                            activeColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: item.completed
                                        ? AppColors.textSecondary
                                        : AppColors.textPrimary,
                                    decoration: item.completed
                                        ? TextDecoration.lineThrough
                                        : null,
                                  ),
                                ),
                                Text(
                                  '${item.durationMinutes} 分钟',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.timer_outlined, size: 22),
                            color: AppColors.primaryColor,
                            onPressed: () =>
                                context.push('/selfcare/timer/${item.id}'),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 20),
                            color: AppColors.textSecondary,
                            onPressed: () {
                              ref
                                  .read(selfCareProvider.notifier)
                                  .deleteItem(item.id);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/selfcare/add'),
        backgroundColor: AppColors.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
