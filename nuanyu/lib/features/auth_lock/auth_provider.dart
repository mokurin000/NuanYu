import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_auth/local_auth.dart';

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

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

class AuthNotifier extends Notifier<AuthState> {
  final LocalAuthentication _localAuth = LocalAuthentication();

  @override
  AuthState build() {
    _checkAvailability();
    return const AuthState(isLocked: true, isAvailable: false);
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
        localizedReason: '\u8bf7\u9a8c\u8bc1\u8eab\u4efd\u4ee5\u89e3\u9501\u6696\u5c7f',
      );

      if (authenticated) {
        state = state.copyWith(isLocked: false, error: null);
        return true;
      } else {
        state = state.copyWith(error: '\u9a8c\u8bc1\u5931\u8d25');
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
