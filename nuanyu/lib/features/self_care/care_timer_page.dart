import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'providers/care_timer_provider.dart';
import 'providers/self_care_provider.dart';

class CareTimerPage extends ConsumerStatefulWidget {
  final String itemId;

  const CareTimerPage({super.key, required this.itemId});

  @override
  ConsumerState<CareTimerPage> createState() => _CareTimerPageState();
}

class _CareTimerPageState extends ConsumerState<CareTimerPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(selfCareProvider).items;
      final item = items.where((i) => i.id == widget.itemId).firstOrNull;
      if (item != null) {
        // Provider.init() is defensive: if the same item is already
        // running or paused, it preserves the live countdown.
        ref.read(careTimerProvider.notifier).init(
          widget.itemId,
          item.durationMinutes * 60,
        );
      }
    });
  }

  @override
  void dispose() {
    // The timer lives in the provider — don't cancel it here.
    super.dispose();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double _progress(int remaining, int total) {
    if (total == 0) return 0;
    return remaining / total;
  }

  @override
  Widget build(BuildContext context) {
    final timerState = ref.watch(careTimerProvider);
    final items = ref.watch(selfCareProvider).items;
    final item = items.where((i) => i.id == widget.itemId).firstOrNull;

    final isRunning = timerState.status == CareTimerStatus.running;
    final isPaused = timerState.status == CareTimerStatus.paused;
    final isCompleted = timerState.status == CareTimerStatus.completed;
    final canStart =
        timerState.status == CareTimerStatus.idle || isPaused;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(item?.title ?? '计时器'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),
              SizedBox(
                width: 220,
                height: 220,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: 1 -
                            _progress(
                              timerState.remainingSeconds,
                              timerState.totalSeconds,
                            ),
                        strokeWidth: 8,
                        backgroundColor:
                            AppColors.secondaryColor.withValues(alpha: 0.3),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isCompleted
                              ? AppColors.moodGreat
                              : AppColors.primaryColor,
                        ),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isCompleted
                              ? '完成！'
                              : _formatTime(timerState.remainingSeconds),
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.w300,
                            color: isCompleted
                                ? AppColors.moodGreat
                                : AppColors.textPrimary,
                          ),
                        ),
                        if (!isCompleted)
                          Text(
                            isRunning
                                ? '进行中'
                                : (timerState.totalSeconds > 0
                                    ? (isPaused ? '已暂停' : '准备开始')
                                    : ''),
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
              if (!isCompleted && timerState.totalSeconds > 0) ...[
                if (canStart)
                  ElevatedButton.icon(
                    onPressed: () {
                      ref.read(careTimerProvider.notifier).start();
                    },
                    icon: Icon(isPaused ? Icons.play_arrow : Icons.play_arrow),
                    label: Text(isPaused ? '继续' : '开始'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  )
                else if (isRunning)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _CircleButton(
                        icon: Icons.pause,
                        onPressed: () {
                          ref.read(careTimerProvider.notifier).pause();
                        },
                      ),
                      const SizedBox(width: 24),
                      _CircleButton(
                        icon: Icons.stop,
                        onPressed: () {
                          ref.read(careTimerProvider.notifier).reset();
                        },
                      ),
                    ],
                  ),
              ],
              if (isCompleted)
                ElevatedButton.icon(
                  onPressed: () {
                    ref
                        .read(selfCareProvider.notifier)
                        .toggleCompletedToday(widget.itemId);
                    ref.read(careTimerProvider.notifier).markCompleted();
                    context.pop();
                  },
                  icon: const Icon(Icons.check),
                  label: const Text('标记完成'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.moodGreat,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 48,
                      vertical: 16,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              const Spacer(),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _CircleButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primaryColor.withValues(alpha: 0.1),
      ),
      child: IconButton(
        icon: Icon(icon, size: 32),
        color: AppColors.primaryColor,
        onPressed: onPressed,
      ),
    );
  }
}
