import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'providers/self_care_provider.dart';

class CareTimerPage extends ConsumerStatefulWidget {
  final String itemId;

  const CareTimerPage({super.key, required this.itemId});

  @override
  ConsumerState<CareTimerPage> createState() => _CareTimerPageState();
}

class _CareTimerPageState extends ConsumerState<CareTimerPage> {
  Timer? _timer;
  int _remainingSeconds = 0;
  int _totalSeconds = 0;
  bool _isRunning = false;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(selfCareProvider).items;
      final item = items.where((i) => i.id == widget.itemId).firstOrNull;
      if (item != null) {
        setState(() {
          _remainingSeconds = item.durationMinutes * 60;
          _totalSeconds = _remainingSeconds;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _start() {
    setState(() => _isRunning = true);
    HapticFeedback.lightImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _pause() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resume() {
    setState(() => _isRunning = true);
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        if (_remainingSeconds > 0) {
          _remainingSeconds--;
        } else {
          _timer?.cancel();
          _isRunning = false;
          _isCompleted = true;
          HapticFeedback.heavyImpact();
        }
      });
    });
  }

  void _markComplete() {
    ref.read(selfCareProvider.notifier).toggleCompletedToday(widget.itemId);
    context.pop();
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  double get _progress {
    if (_totalSeconds == 0) return 0;
    return _remainingSeconds / _totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(selfCareProvider).items;
    final item = items.where((i) => i.id == widget.itemId).firstOrNull;

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(item?.title ?? '计时器'),
        backgroundColor: AppColors.backgroundColor,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            // Circular progress
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
                      value: 1 - _progress,
                      strokeWidth: 8,
                      backgroundColor: AppColors.secondaryColor.withValues(alpha: 0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _isCompleted ? AppColors.moodGreat : AppColors.primaryColor,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _isCompleted ? '完成！' : _formatTime(_remainingSeconds),
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.w300,
                          color: _isCompleted ? AppColors.moodGreat : AppColors.textPrimary,
                        ),
                      ),
                      if (!_isCompleted)
                        Text(
                          _isRunning ? '进行中' : (_totalSeconds > 0 ? '准备开始' : ''),
                          style: const TextStyle(color: AppColors.textSecondary),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(flex: 2),
            // Controls
            if (!_isCompleted && _totalSeconds > 0) ...[
              if (!_isRunning)
                ElevatedButton.icon(
                  onPressed: _start,
                  icon: const Icon(Icons.play_arrow),
                  label: const Text('开始'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                )
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _CircleButton(
                      icon: Icons.pause,
                      onPressed: _pause,
                    ),
                    const SizedBox(width: 24),
                    _CircleButton(
                      icon: Icons.stop,
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _remainingSeconds = _totalSeconds;
                          _isRunning = false;
                        });
                      },
                    ),
                  ],
                ),
            ],
            if (_isCompleted)
              ElevatedButton.icon(
                onPressed: _markComplete,
                icon: const Icon(Icons.check),
                label: const Text('标记完成'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.moodGreat,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            const Spacer(),
          ],
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
