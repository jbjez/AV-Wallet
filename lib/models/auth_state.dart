import '../models/app_user.dart';

class AuthState {
  final AppUser? user;
  final bool isLoading;
  final String? error;
  final bool rememberMe;

  AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.rememberMe = false,
  });

  AuthState copyWith({
    AppUser? user,
    bool? isLoading,
    String? error,
    bool? rememberMe,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
} 