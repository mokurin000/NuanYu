import 'package:flutter_riverpod/flutter_riverpod.dart';

enum BreathPhase { inhale, hold, exhale, rest }

enum SessionState { idle, running, paused, completed }

class BreathingPattern {
  final String name;
  final String description;
  final int inhaleSeconds;
  final int holdSeconds;
  final int exhaleSeconds;
  final int? postHoldSeconds;

  const BreathingPattern({
    required this.name,
    required this.description,
    required this.inhaleSeconds,
    required this.holdSeconds,
    required this.exhaleSeconds,
    this.postHoldSeconds,
  });

  int get totalSecondsPerCycle => inhaleSeconds + holdSeconds + exhaleSeconds + (postHoldSeconds ?? 0);
}

final breathingPatterns = [
  const BreathingPattern(
    name: '4-7-8 呼吸法',
    description: '放松身心，缓解焦虑',
    inhaleSeconds: 4,
    holdSeconds: 7,
    exhaleSeconds: 8,
  ),
  const BreathingPattern(
    name: '方块呼吸',
    description: '平静思绪，集中注意',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
    postHoldSeconds: 4,
  ),
  const BreathingPattern(
    name: '4-4-4 呼吸',
    description: '舒缓情绪，恢复平衡',
    inhaleSeconds: 4,
    holdSeconds: 4,
    exhaleSeconds: 4,
  ),
  const BreathingPattern(
    name: '2-4-6 呼吸',
    description: '放松入眠，深度休息',
    inhaleSeconds: 2,
    holdSeconds: 4,
    exhaleSeconds: 6,
  ),
];

class BreathingState {
  final BreathingPattern? selectedPattern;
  final SessionState sessionState;
  final BreathPhase currentPhase;
  final int elapsedSeconds;
  final int phaseSeconds;
  final int cycleCount;

  const BreathingState({
    this.selectedPattern,
    this.sessionState = SessionState.idle,
    this.currentPhase = BreathPhase.inhale,
    this.elapsedSeconds = 0,
    this.phaseSeconds = 0,
    this.cycleCount = 0,
  });

  BreathingState copyWith({
    BreathingPattern? selectedPattern,
    SessionState? sessionState,
    BreathPhase? currentPhase,
    int? elapsedSeconds,
    int? phaseSeconds,
    int? cycleCount,
  }) {
    return BreathingState(
      selectedPattern: selectedPattern ?? this.selectedPattern,
      sessionState: sessionState ?? this.sessionState,
      currentPhase: currentPhase ?? this.currentPhase,
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      phaseSeconds: phaseSeconds ?? this.phaseSeconds,
      cycleCount: cycleCount ?? this.cycleCount,
    );
  }
}

final breathingProvider = NotifierProvider<BreathingNotifier, BreathingState>(BreathingNotifier.new);

class BreathingNotifier extends Notifier<BreathingState> {
  @override
  BreathingState build() => const BreathingState();

  void selectPattern(BreathingPattern pattern) {
    state = state.copyWith(selectedPattern: pattern);
  }

  void startSession() {
    if (state.selectedPattern == null) return;
    state = BreathingState(
      selectedPattern: state.selectedPattern,
      sessionState: SessionState.running,
      currentPhase: BreathPhase.inhale,
      elapsedSeconds: 0,
      phaseSeconds: 0,
      cycleCount: 0,
    );
  }

  void tick() {
    if (state.sessionState != SessionState.running) return;
    final pattern = state.selectedPattern!;

    var newPhaseSeconds = state.phaseSeconds + 1;
    var newPhase = state.currentPhase;
    var newCycleCount = state.cycleCount;
    var newElapsed = state.elapsedSeconds + 1;

    int maxPhaseSeconds;
    BreathPhase nextPhase;

    switch (newPhase) {
      case BreathPhase.inhale:
        maxPhaseSeconds = pattern.inhaleSeconds;
        nextPhase = BreathPhase.hold;
      case BreathPhase.hold:
        maxPhaseSeconds = pattern.holdSeconds;
        nextPhase = BreathPhase.exhale;
      case BreathPhase.exhale:
        maxPhaseSeconds = pattern.exhaleSeconds;
        nextPhase = pattern.postHoldSeconds != null ? BreathPhase.rest : BreathPhase.inhale;
      case BreathPhase.rest:
        maxPhaseSeconds = pattern.postHoldSeconds!;
        nextPhase = BreathPhase.inhale;
    }

    if (newPhaseSeconds >= maxPhaseSeconds) {
      newPhaseSeconds = 0;
      newPhase = nextPhase;
      if (nextPhase == BreathPhase.inhale) {
        newCycleCount++;
      }
    }

    state = state.copyWith(
      currentPhase: newPhase,
      phaseSeconds: newPhaseSeconds,
      elapsedSeconds: newElapsed,
      cycleCount: newCycleCount,
    );
  }

  void pause() {
    state = state.copyWith(sessionState: SessionState.paused);
  }

  void resume() {
    state = state.copyWith(sessionState: SessionState.running);
  }

  void reset() {
    state = BreathingState(selectedPattern: state.selectedPattern);
  }

  void complete() {
    state = state.copyWith(sessionState: SessionState.completed);
  }
}
