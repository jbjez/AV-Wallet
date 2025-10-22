import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/app_user.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/widgets.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'hive_service.dart';
import 'reset_service.dart';
import 'session_usage_service.dart';

class AuthService with WidgetsBindingObserver {
  final _supabase = Supabase.instance.client;
  final _logger = Logger('AuthService');
  final SharedPreferences? _prefs;
  static const String _rememberMeKey = 'remember_me';

  AuthService(this._prefs) {
    _init();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      _logger.info('App resumed, checking session...');
      try {
        final session = await _supabase.auth.refreshSession();
        _logger.info('Session refreshed: ${session != null}');
      } catch (e) {
        _logger.warning('Failed to refresh session: $e');
      }
    }
  }

  Future<void> _init() async {
    final rememberMe = _prefs?.getBool(_rememberMeKey) ?? false;

    if (rememberMe) {
      try {
        final currentUser = _supabase.auth.currentUser;
        if (currentUser != null) {
          _logger.info('Recovered session for user: ${currentUser.email}');
          await _supabase.auth.refreshSession();
        }
      } catch (e) {
        _logger.warning('Failed to recover session: $e');
      }
    }

    // Écouter les changements d'état d'authentification
    _supabase.auth.onAuthStateChange.listen((event) async {
      _logger.info('Auth state changed: ${event.event}');
      _logger.info('Session: ${event.session?.toJson()}');
      
      final session = event.session;
      final user = session?.user;

      if (user != null) {
        _logger.info('User state updated: ${user.email}');
        
        // Sauvegarder les informations de session si "Se souvenir de moi" est activé
        final rememberMe = _prefs?.getBool(_rememberMeKey) ?? false;
        if (rememberMe) {
          await _persistUserInfo(user);
        }
      } else {
        _logger.info('User signed out');
        await _clearPersistedUserInfo();
      }
    });
  }

  Future<void> setRememberMe(bool value) async {
    await _prefs?.setBool(_rememberMeKey, value);
    _logger.info('Remember me set to: $value');
  }

  Future<bool> getRememberMe() async {
    return _prefs?.getBool(_rememberMeKey) ?? false;
  }

  // Persister les informations de l'utilisateur
  Future<void> _persistUserInfo(User user) async {
    try {
      await _prefs?.setString('user_id', user.id);
      await _prefs?.setString('user_email', user.email ?? '');
      _logger.info('User info persisted successfully');
    } catch (e) {
      _logger.warning('Failed to persist user info: $e');
    }
  }

  // Nettoyer les informations de l'utilisateur persistées
  Future<void> _clearPersistedUserInfo() async {
    try {
      await _prefs?.remove('user_id');
      await _prefs?.remove('user_email');
      _logger.info('Persisted user info cleared');
    } catch (e) {
      _logger.warning('Failed to clear persisted user info: $e');
    }
  }

  Future<void> signUp({required String email, required String password}) async {
    try {
      _logger.info('Starting sign up process for email: $email');

      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
        emailRedirectTo: 'io.supabase.avwallet://login-callback/',
      );

      if (response.user == null) {
        throw 'L\'inscription a échoué. Veuillez réessayer.';
      }

      if (response.session == null) {
        throw 'Un code de vérification a été envoyé à $email. Veuillez vérifier votre boîte de réception et vos spams.';
      }
    } catch (e) {
      if (e.toString().contains('User already registered')) {
        throw 'Cette adresse email est déjà utilisée.';
      }
      if (e.toString().contains('AuthWeakPasswordException')) {
        throw 'Le mot de passe doit contenir au moins 8 caractères avec une lettre minuscule, une majuscule, un chiffre et un caractère spécial.';
      }
      if (e.toString().contains('Invalid email')) {
        throw 'Adresse email invalide.';
      }
      rethrow;
    }
  }

  Future<bool> checkEmailConfirmation(String email) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null && user.email == email) {
        return user.emailConfirmedAt != null;
      }
      return false;
    } catch (e) {
      _logger.warning('Error checking email confirmation: $e');
      return false;
    }
  }

  Future<void> resendConfirmationEmail(String email) async {
    try {
      _logger.info('Resending confirmation code to: $email');
      
      await _supabase.auth.resend(
        type: OtpType.signup,
        email: email,
        emailRedirectTo: 'io.supabase.avwallet://login-callback/',
      );
      
      _logger.info('Confirmation code sent successfully to: $email');
    } catch (e) {
      _logger.warning('Error resending confirmation code: $e');
      rethrow;
    }
  }

  Future<void> verifyEmailCode(String email, String code) async {
    try {
      _logger.info('Verifying email code for: $email');
      
      final response = await _supabase.auth.verifyOTP(
        type: OtpType.signup,
        token: code,
        email: email,
      );

      if (response.user == null) {
        throw 'Code de vérification invalide.';
      }

      if (response.session == null) {
        throw 'Erreur lors de la vérification du code.';
      }

      _logger.info('Email code verified successfully for: $email');
    } catch (e) {
      _logger.warning('Error verifying email code: $e');
      if (e.toString().contains('Invalid token')) {
        throw 'Code de vérification invalide ou expiré.';
      }
      rethrow;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw 'Email ou mot de passe incorrect.';
      }

      // Vérifier si l'email est confirmé
      if (response.user!.emailConfirmedAt == null) {
        throw 'Veuillez vérifier votre email avant de vous connecter. Un email de confirmation a été envoyé à $email.';
      }

      if (response.session == null) {
        throw 'Veuillez vérifier votre email avant de vous connecter.';
      }
      
      // Démarrer une nouvelle session
      await SessionUsageService.instance.startNewSession();
      _logger.info('New session started after email sign in');
      
    } catch (e) {
      if (e.toString().contains('Invalid login credentials')) {
        throw 'Email ou mot de passe incorrect.';
      } else if (e.toString().contains('Email not confirmed')) {
        throw 'Veuillez vérifier votre email avant de vous connecter. Un email de confirmation a été envoyé à $email.';
      }
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      _logger.info('Starting complete sign out...');
      
      // 1. Déconnexion Supabase
      await _supabase.auth.signOut();
      _logger.info('Supabase sign out completed');
      
      // 2. Désactiver remember me
      await setRememberMe(false);
      _logger.info('Remember me disabled');
      
      // 3. Reset de la session
      await SessionUsageService.instance.resetSession();
      _logger.info('Session reset completed');
      
      // 4. Vider toutes les données locales Hive
      await _clearAllLocalData();
      _logger.info('All local data cleared');
      
      // 5. Le changement d'état sera géré automatiquement par Supabase
      _logger.info('Sign out completed, state will be updated by Supabase');
      
    } catch (e) {
      _logger.severe('Error during sign out: $e');
      throw 'Erreur lors de la déconnexion: ${e.toString()}';
    }
  }

  /// Vide toutes les données locales (reset complet)
  Future<void> _clearAllLocalData() async {
    try {
      // Utiliser le service de reset complet
      await ResetService.performCompleteReset();
      _logger.info('Complete reset performed via ResetService');
      
    } catch (e) {
      _logger.warning('Error during complete reset: $e');
      // Fallback vers l'ancienne méthode si le nouveau service échoue
      await _fallbackClearLocalData();
    }
  }

  /// Méthode de fallback pour le nettoyage des données locales
  Future<void> _fallbackClearLocalData() async {
    try {
      // Fermer les boxes Hive ouvertes
      if (Hive.isBoxOpen('catalogue')) {
        await Hive.box('catalogue').close();
      }
      if (Hive.isBoxOpen('presets')) {
        await Hive.box('presets').close();
      }
      if (Hive.isBoxOpen('projects')) {
        await Hive.box('projects').close();
      }
      
      // Supprimer les boxes Hive du disque
      await Hive.deleteBoxFromDisk('catalogue');
      await Hive.deleteBoxFromDisk('presets');
      await Hive.deleteBoxFromDisk('projects');
      _logger.info('Hive boxes deleted from disk (fallback)');
      
      // Réinitialiser Hive
      await HiveService.initialize();
      _logger.info('Hive reinitialized (fallback)');
      
    } catch (e) {
      _logger.warning('Error in fallback clear local data: $e');
    }
  }


  Future<void> signInWithGoogle() async {
    try {
      _logger.info('Starting Google sign-in process');
      
      // Deep link de ton app mobile
      const mobileRedirect = 'io.supabase.avwallet://login-callback/';
      
      _logger.info('Attempting Supabase OAuth with PKCE...');
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: mobileRedirect,
        authScreenLaunchMode: LaunchMode.externalApplication,
        queryParams: {
          'access_type': 'offline',
          'prompt': 'consent',
        },
      );
      
      _logger.info('OAuth flow initiated successfully');
      
      // Note: La session sera démarrée automatiquement quand l'utilisateur sera connecté
      // via l'écouteur d'état d'authentification dans DeepLinkService
      
    } catch (e) {
      _logger.severe('Error during Google sign-in: $e');
      rethrow;
    }
  }

  // Méthode pour vérifier et récupérer la session si nécessaire
  Future<bool> checkAndRecoverSession() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        _logger.info('Valid session found');
        return true;
      }

      _logger.info('No valid session, attempting to recover...');
      final newSession = await _supabase.auth.refreshSession();
      return newSession != null;
    } catch (e) {
      _logger.warning('Error checking/recovering session: $e');
      return false;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'io.supabase.avwallet://reset-callback/',
      );
    } catch (e) {
      throw 'Erreur lors de la réinitialisation du mot de passe: ${e.toString()}';
    }
  }

  AppUser? getCurrentUser() {
    final user = _supabase.auth.currentUser;
    if (user == null) return null;
    return _convertSupabaseUser(user);
  }

  AppUser _convertSupabaseUser(User user) {
    if (user.email == null) {
      throw Exception('Email is required for user creation');
    }

    // Extraire le nom d'affichage depuis les métadonnées
    String? displayName;
    final userMetadata = user.userMetadata;
    if (userMetadata != null && userMetadata.isNotEmpty) {
      // Google OAuth fournit souvent 'full_name' ou 'name'
      displayName = userMetadata['full_name'] as String? ?? 
                   userMetadata['name'] as String? ??
                   userMetadata['display_name'] as String?;
      
      // Si pas de nom complet, essayer de construire à partir de given_name et family_name
      if (displayName == null || displayName.isEmpty) {
        final givenName = userMetadata['given_name'] as String?;
        final familyName = userMetadata['family_name'] as String?;
        if (givenName != null && givenName.isNotEmpty) {
          displayName = familyName != null && familyName.isNotEmpty 
              ? '$givenName $familyName' 
              : givenName;
        }
      }
    }

    return AppUser(
      id: user.id,
      email: user.email!,
      displayName: displayName ?? '',
      photoURL: user.userMetadata?['photo_url'] as String? ?? 
                user.userMetadata?['picture'] as String?,
      createdAt: DateTime.parse(user.createdAt),
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Effectue un reset complet de l'application (simule une première visite)
  Future<void> performCompleteReset() async {
    try {
      _logger.info('Starting complete app reset...');
      await ResetService.performCompleteReset();
      _logger.info('Complete app reset completed successfully');
    } catch (e) {
      _logger.severe('Error during complete reset: $e');
      throw 'Erreur lors du reset complet: ${e.toString()}';
    }
  }

  /// Effectue un reset uniquement des données utilisateur
  Future<void> performUserDataReset() async {
    try {
      _logger.info('Starting user data reset...');
      await ResetService.performUserDataReset();
      _logger.info('User data reset completed successfully');
    } catch (e) {
      _logger.severe('Error during user data reset: $e');
      throw 'Erreur lors du reset des données utilisateur: ${e.toString()}';
    }
  }
}
