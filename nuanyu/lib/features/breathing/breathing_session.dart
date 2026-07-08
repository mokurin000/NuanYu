import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/constants/app_colors.dart';
import 'providers/breathing_provider.dart';
import 'breathing_animation.dart';

class BreathingSession extends ConsumerStatefulWidget {
  const BreathingSession({super.key});

  @override
  ConsumerState<BreathingSession> createState() => _BreathingSessionState();
}

class _BreathingSessionState extends ConsumerState<BreathingSession> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(breathingProvider.notifier).startSession();
      _startTimer();
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(breathingProvider);
      if (state.sessionState == SessionState.running) {
        ref.read(breathingProvider.notifier).tick();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _phaseText(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return '吸气';
      case BreathPhase.hold:
        return '屏息';
      case BreathPhase.exhale:
        return '呼气';
      case BreathPhase.rest:
        return '屏息';
    }
  }

  String _phaseInstruction(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return '缓缓吸入...';
      case BreathPhase.hold:
        return '轻轻屏住...';
      case BreathPhase.exhale:
        return '慢慢呼出...';
      case BreathPhase.rest:
        return '自然停顿...';
    }
  }

  Color _phaseColor(BreathPhase phase) {
    switch (phase) {
      case BreathPhase.inhale:
        return AppColors.primaryColor;
      case BreathPhase.hold:
        return AppColors.accentColor;
      case BreathPhase.exhale:
        return AppColors.secondaryColor;
      case BreathPhase.rest:
        return AppColors.moodMedium;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingProvider);
    final pattern = state.selectedPattern!;
    final phaseProgress = state.phaseSeconds /
        _phaseDuration(state.currentPhase, pattern);

    // Trigger haptic on phase transitions
    if (state.phaseSeconds == 0 && state.sessionState == SessionState.running) {
      HapticFeedback.heavyImpact();
      SystemSound.play(SystemSoundType.click);
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: Text(pattern.name),
        backgroundColor: AppColors.backgroundColor,
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            _timer?.cancel();
            ref.read(breathingProvider.notifier).reset();
            context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            // Phase indicator
            Text(
              _phaseText(state.currentPhase),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _phaseColor(state.currentPhase),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _phaseInstruction(state.currentPhase),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${state.cycleCount + 1}',
              style: TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.w300,
                color: _phaseColor(state.currentPhase).withValues(alpha: 0.4),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '次循环',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(flex: 1),
            // Breathing animation
            SizedBox(
              height: 280,
              child: BreathingAnimation(
                phase: state.currentPhase,
                phaseProgress: phaseProgress,
                sessionState: state.sessionState,
              ),
            ),
            const Spacer(flex: 2),
            // Controls
            Padding(
              padding: const EdgeInsets.all(24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (state.sessionState == SessionState.running)
                    _ControlButton(
                      icon: Icons.pause,
                      label: '暂停',
                      onPressed: () {
                        ref.read(breathingProvider.notifier).pause();
                      },
                    ),
                  if (state.sessionState == SessionState.paused)
                    _ControlButton(
                      icon: Icons.play_arrow,
                      label: '继续',
                      onPressed: () {
                        ref.read(breathingProvider.notifier).resume();
                      },
                    ),
                  const SizedBox(width: 24),
                  _ControlButton(
                    icon: Icons.stop,
                    label: '结束',
                    onPressed: () {
                      _timer?.cancel();
                      ref.read(breathingProvider.notifier).complete();
                      context.pushReplacement('/breathing/complete');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _phaseDuration(BreathPhase phase, BreathingPattern pattern) {
    switch (phase) {
      case BreathPhase.inhale:
        return pattern.inhaleSeconds.toDouble();
      case BreathPhase.hold:
        return pattern.holdSeconds.toDouble();
      case BreathPhase.exhale:
        return pattern.exhaleSeconds.toDouble();
      case BreathPhase.rest:
        return (pattern.postHoldSeconds ?? 0).toDouble();
    }
  }
}

class _ControlButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;

  const _ControlButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
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
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

