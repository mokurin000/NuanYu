import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/warm_card.dart';
import 'providers/self_care_provider.dart';

class DailyAffirmation extends ConsumerWidget {
  const DailyAffirmation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final affirmation = ref.watch(dailyAffirmationProvider);

    return WarmCard(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.wb_sunny, color: AppColors.primaryColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                affirmation,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
