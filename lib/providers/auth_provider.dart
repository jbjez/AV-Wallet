import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/app_user.dart';
import '../main.dart'; // Pour accéder à navigatorKey

// Simple auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final AppUser? user;
  final bool rememberMe;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.user,
    this.rememberMe = false,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    AppUser? user,
    bool? rememberMe,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error ?? this.error,
      user: user ?? this.user,
      rememberMe: rememberMe ?? this.rememberMe,
    );
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authService = ref.watch(authServiceProvider).value;
  if (authService == null) {
    throw Exception('AuthService not initialized');
  }
  return AuthNotifier(authService);
});

final authServiceProvider = FutureProvider<AuthService>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return AuthService(prefs);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _authService;

  AuthNotifier(this._authService) : super(const AuthState()) {
    _init();
  }

  Future<void> _init() async {
    // Vérifier l'état d'authentification au démarrage
    await checkAuthStatus();
  }

  Future<void> signIn(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signIn(email: email, password: password);
      final user = _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Échec de la connexion',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  Future<void> signUp(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signUp(email: email, password: password);
      final user = _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Échec de l\'inscription',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur: $e',
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      await _authService.signOut();
      state = const AuthState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la déconnexion: $e',
      );
    }
  }

  Future<void> checkAuthStatus() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = _authService.getCurrentUser();
      if (user != null) {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: user,
        );
      } else {
        state = const AuthState();
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Erreur lors de la vérification: $e',
      );
    }
  }

  /// Met à jour l'utilisateur (utilisé pour les connexions OAuth)
  void updateUser(AppUser? user) {
    if (user != null) {
      state = state.copyWith(
        isAuthenticated: true,
        user: user,
        error: null,
      );
    } else {
      state = const AuthState();
    }
  }
}