import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
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
  late final SoLoud _soLoud;
  AudioSource? _inhaleSource;
  AudioSource? _holdSource;
  AudioSource? _exhaleSource;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();
    _soLoud = SoLoud.instance;
    WakelockPlus.enable();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _initAudio();
      ref.read(breathingProvider.notifier).startSession();
      _startTimer();
    });
  }

  Future<void> _initAudio() async {
    await _soLoud.init();
    _inhaleSource = await _soLoud.loadAsset('assets/laura_inhale.mp3');
    _holdSource = await _soLoud.loadAsset('assets/laura_hold.mp3');
    _exhaleSource = await _soLoud.loadAsset('assets/laura_exhale.mp3');
    _initialized = true;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      final state = ref.read(breathingProvider);
      if (state.sessionState == SessionState.running) {
        ref.read(breathingProvider.notifier).tick();
      }
    });
  }

  void _playPhaseSound(BreathPhase phase) {
    if (!_initialized) return;
    final source = switch (phase) {
      BreathPhase.inhale => _inhaleSource,
      BreathPhase.hold || BreathPhase.rest => _holdSource,
      BreathPhase.exhale => _exhaleSource,
    };
    if (source != null) {
      _soLoud.play(source);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _soLoud.deinit();
    WakelockPlus.disable();
    super.dispose();
  }

  String _phaseText(BreathPhase phase) {
    return switch (phase) {
      BreathPhase.inhale => '吸气',
      BreathPhase.hold || BreathPhase.rest => '屏息',
      BreathPhase.exhale => '呼气',
    };
  }

  String _phaseInstruction(BreathPhase phase) {
    return switch (phase) {
      BreathPhase.inhale => '缓缓吸入...',
      BreathPhase.hold => '轻轻屏住...',
      BreathPhase.exhale => '慢慢呼出...',
      BreathPhase.rest => '自然停顿...',
    };
  }

  Color _phaseColor(BreathPhase phase) {
    return switch (phase) {
      BreathPhase.inhale => AppColors.primaryColor,
      BreathPhase.hold => AppColors.accentColor,
      BreathPhase.exhale => AppColors.secondaryColor,
      BreathPhase.rest => AppColors.moodMedium,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(breathingProvider);
    final pattern = state.selectedPattern!;
    final phaseProgress =
        state.phaseSeconds / _phaseDuration(state.currentPhase, pattern);

    if (state.phaseSeconds == 0 && state.sessionState == SessionState.running) {
      HapticFeedback.heavyImpact();
      _playPhaseSound(state.currentPhase);
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
            SizedBox(
              height: 280,
              child: BreathingAnimation(
                phase: state.currentPhase,
                phaseProgress: phaseProgress,
                sessionState: state.sessionState,
              ),
            ),
            const Spacer(flex: 2),
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
    final duration = switch (phase) {
      BreathPhase.inhale => pattern.inhaleSeconds.toDouble(),
      BreathPhase.hold => pattern.holdSeconds.toDouble(),
      BreathPhase.exhale => pattern.exhaleSeconds.toDouble(),
      BreathPhase.rest => (pattern.postHoldSeconds ?? 0).toDouble(),
    };
    // Guard against division by zero for zero-second phases
    return duration == 0 ? 1.0 : duration;
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
