import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/soothing_button.dart';
import 'providers/breathing_provider.dart';

class BreathingPage extends ConsumerWidget {
  const BreathingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final breathingState = ref.watch(breathingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('呼吸练习'),
        backgroundColor: AppColors.backgroundColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                '选择呼吸模式',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: breathingPatterns.length,
                  itemBuilder: (context, index) {
                    final pattern = breathingPatterns[index];
                    final isSelected = breathingState.selectedPattern?.name == pattern.name;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: WarmCard(
                        onTap: () {
                          ref.read(breathingProvider.notifier).selectPattern(pattern);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Container(
                                width: 48,
                                height: 48,
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppColors.primaryColor
                                      : AppColors.secondaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.air,
                                  color: isSelected ? Colors.white : AppColors.textSecondary,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      pattern.name,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: isSelected
                                            ? AppColors.primaryColor
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      pattern.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: AppColors.primaryColor,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 16),
              SoothingButton(
                label: '开始练习',
                onPressed: breathingState.selectedPattern != null
                    ? () => context.push('/breathing/session')
                    : null,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

