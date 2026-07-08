import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/warm_card.dart';
import '../../core/widgets/soothing_button.dart';
import 'providers/breathing_provider.dart';

class BreathingComplete extends ConsumerWidget {
  const BreathingComplete({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(breathingProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primaryColor.withValues(alpha: 0.1),
                ),
                child: const Icon(
                  Icons.spa,
                  size: 64,
                  color: AppColors.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                '练习完成',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '你做得很好，给自己一些肯定',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              WarmCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _StatItem(
                        label: '完成循环',
                        value: '${state.cycleCount}',
                      ),
                      const SizedBox(width: 32),
                      _StatItem(
                        label: '总时长',
                        value: _formatDuration(state.elapsedSeconds),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(flex: 2),
              SoothingButton(
                label: '再来一次',
                onPressed: () {
                  ref.read(breathingProvider.notifier).reset();
                  context.pop();
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ref.read(breathingProvider.notifier).reset();
                  context.go('/breathing');
                },
                child: const Text(
                  '返回首页',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
              ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDuration(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    if (min > 0) {
      return '$min分$sec秒';
    }
    return '$sec秒';
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;

  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryColor,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

