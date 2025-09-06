import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';
import '../models/auth_state.dart';

// État global pour SharedPreferences
final sharedPreferencesProvider = StateProvider<SharedPreferences?>((ref) => null);

// État de l'authentification
final authStateProvider = StateProvider<AuthState>((ref) {
  return AuthState(
    user: null,
    isLoading: true,
    error: null,
    rememberMe: false,
  );
});

// Service d'authentification
final authServiceProvider = Provider<AuthService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(prefs);
});

// Fonction pour initialiser les SharedPreferences
Future<void> initializeAuth(ProviderContainer container) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    container.read(sharedPreferencesProvider.notifier).state = prefs;
    
    // Initialiser le service d'authentification
    final authService = container.read(authServiceProvider);
    final rememberMe = prefs.getBool('remember_me') ?? false;
    
    // Mettre à jour l'état initial
    container.read(authStateProvider.notifier).state = AuthState(
      user: null,
      isLoading: false,
      error: null,
      rememberMe: rememberMe,
    );
  } catch (e) {
    print('Error initializing auth: $e');
    container.read(authStateProvider.notifier).state = AuthState(
      user: null,
      isLoading: false,
      error: e.toString(),
      rememberMe: false,
    );
  }
}
