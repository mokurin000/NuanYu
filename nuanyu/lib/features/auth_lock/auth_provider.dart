import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier();
});

class AuthState {
  final bool isLocked;
  final bool isAvailable;
  final String? error;

  const AuthState({
    required this.isLocked,
    required this.isAvailable,
    this.error,
  });

  AuthState copyWith({bool? isLocked, bool? isAvailable, String? error}) {
    return AuthState(
      isLocked: isLocked ?? this.isLocked,
      isAvailable: isAvailable ?? this.isAvailable,
      error: error,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  AuthNotifier() : super(const AuthState(isLocked: true, isAvailable: false)) {
    _checkAvailability();
  }

  Future<void> _checkAvailability() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      final isAvailable = await _localAuth.isDeviceSupported();
      state = state.copyWith(
        isAvailable: canCheck || isAvailable,
      );
    } catch (e) {
      state = state.copyWith(isAvailable: false);
    }
  }

  Future<bool> authenticate() async {
    if (!state.isAvailable) {
      state = state.copyWith(isLocked: false);
      return true;
    }

    try {
      final authenticated = await _localAuth.authenticate(
        localizedReason: '请验证身份以解锁暖屿',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (authenticated) {
        state = state.copyWith(isLocked: false, error: null);
        return true;
      } else {
        state = state.copyWith(error: '验证失败');
        return false;
      }
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return false;
    }
  }

  void lock() {
    state = state.copyWith(isLocked: true);
  }
}
