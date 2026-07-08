import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_soloud/flutter_soloud.dart';
import '../../../core/services/notification_service.dart';

enum CareTimerStatus { idle, running, paused, completed }

class CareTimerState {
  final String? itemId;
  final String title;
  final CareTimerStatus status;
  final int remainingSeconds;
  final int totalSeconds;

  const CareTimerState({
    this.itemId,
    this.title = '',
    this.status = CareTimerStatus.idle,
    this.remainingSeconds = 0,
    this.totalSeconds = 0,
  });

  CareTimerState copyWith({
    String? itemId,
    String? title,
    CareTimerStatus? status,
    int? remainingSeconds,
    int? totalSeconds,
  }) {
    return CareTimerState(
      itemId: itemId ?? this.itemId,
      title: title ?? this.title,
      status: status ?? this.status,
      remainingSeconds: remainingSeconds ?? this.remainingSeconds,
      totalSeconds: totalSeconds ?? this.totalSeconds,
    );
  }
}

final careTimerProvider = NotifierProvider<CareTimerNotifier, CareTimerState>(
  CareTimerNotifier.new,
);

class CareTimerNotifier extends Notifier<CareTimerState> {
  Timer? _timer;
  final SoLoud _soLoud = SoLoud.instance;
  AudioSource? _alarmSource;
  bool _alarmReady = false;
  bool _alarmLoading = false;

  @override
  CareTimerState build() => const CareTimerState();

  Future<void> _initAlarm() async {
    if (_alarmReady || _alarmLoading) return;
    _alarmLoading = true;
    try {
      await _soLoud.init();
      _alarmSource = await _soLoud.loadAsset('assets/ding.mp3');
      _alarmReady = true;
    } finally {
      _alarmLoading = false;
    }
  }

  void _playAlarm() {
    if (_alarmReady && _alarmSource != null) {
      _soLoud.play(_alarmSource!);
    }
  }

  /// Initialize or re-acquire the timer state for a care item.
  /// If the same item is already running or paused, this is a no-op so
  /// returning to the page after navigating away preserves the countdown.
  void init(String itemId, String title, int durationSeconds) {
    final isSameActiveTimer =
        state.itemId == itemId &&
        (state.status == CareTimerStatus.running ||
            state.status == CareTimerStatus.paused);

    if (isSameActiveTimer) {
      return;
    }

    _timer?.cancel();
    state = CareTimerState(
      itemId: itemId,
      title: title,
      totalSeconds: durationSeconds,
      remainingSeconds: durationSeconds,
      status: CareTimerStatus.idle,
    );
    _initAlarm();
  }

  void start() {
    if (state.status != CareTimerStatus.idle &&
        state.status != CareTimerStatus.paused) {
      return;
    }

    _timer?.cancel();

    if (state.status == CareTimerStatus.idle) {
      NotificationService().showCareTimerNotification(
        title: state.title,
        remainingSeconds: state.remainingSeconds,
        totalSeconds: state.totalSeconds,
      );
    }

    HapticFeedback.lightImpact();
    state = state.copyWith(status: CareTimerStatus.running);

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state.status != CareTimerStatus.running) {
        _timer?.cancel();
        return;
      }

      final newRemaining = state.remainingSeconds - 1;
      if (newRemaining > 0) {
        state = state.copyWith(remainingSeconds: newRemaining);
        NotificationService().updateCareTimerProgress(
          title: state.title,
          remainingSeconds: newRemaining,
          totalSeconds: state.totalSeconds,
        );
      } else {
        _timer?.cancel();
        HapticFeedback.heavyImpact();
        _playAlarm();
        NotificationService().cancelCareTimerNotification();
        NotificationService().showCareTimerCompleteNotification(
          title: state.title,
        );
        state = state.copyWith(
          status: CareTimerStatus.completed,
          remainingSeconds: 0,
        );
      }
    });
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(status: CareTimerStatus.paused);
    NotificationService().cancelCareTimerNotification();
  }

  void reset() {
    _timer?.cancel();
    NotificationService().cancelCareTimerNotification();
    state = state.copyWith(
      status: CareTimerStatus.idle,
      remainingSeconds: state.totalSeconds,
    );
  }

  void markCompleted() {
    state = state.copyWith(status: CareTimerStatus.idle);
  }

  void dispose() {
    _timer?.cancel();
    _soLoud.deinit();
    NotificationService().cancelCareTimerNotification();
  }
}
