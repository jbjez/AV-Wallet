import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'session_usage_service.dart';
import '../models/app_user.dart';
import '../main.dart'; // Pour accéder à navigatorKey

final logger = Logger('DeepLinkService');

class DeepLinkService {
  static final _supabase = Supabase.instance.client;

  /// Initialise la gestion des deep links
  static void initialize() {
    logger.info('Initializing deep link service...');
    
    // Écouter les changements d'authentification
    _supabase.auth.onAuthStateChange.listen((data) {
      logger.info('Auth state changed: ${data.event}');
      
      if (data.event == AuthChangeEvent.signedIn) {
        logger.info('User signed in successfully');
        _handleSuccessfulSignIn(data.session?.user);
      } else if (data.event == AuthChangeEvent.signedOut) {
        logger.info('User signed out');
        _handleSignOut();
      }
    });
  }

  /// Gère la connexion réussie
  static void _handleSuccessfulSignIn(User? user) {
    if (user == null) return;
    
    logger.info('Handling successful sign in for user: ${user.email}');
    logger.info('User metadata at sign in: ${user.userMetadata}');
    
    // Convertir l'utilisateur Supabase en AppUser
    final appUser = _convertSupabaseUser(user);
    
    // Mettre à jour l'AuthProvider
    _updateAuthProvider(appUser);
    
    // Démarrer une nouvelle session
    SessionUsageService.instance.startNewSession();
    logger.info('New session started after Google sign in');
    
    // Ne pas interférer avec le processus normal - laisser le système d'auth gérer
    logger.info('Google sign in completed successfully, letting normal auth flow handle the rest');
  }

  /// Convertit un utilisateur Supabase en AppUser
  static AppUser _convertSupabaseUser(User user) {
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
                user.userMetadata?['picture'] as String? ?? '',
      createdAt: user.createdAt != null
          ? DateTime.parse(user.createdAt)
          : DateTime.now(),
      isEmailVerified: user.emailConfirmedAt != null,
    );
  }

  /// Met à jour l'AuthProvider avec le nouvel utilisateur
  static void _updateAuthProvider(AppUser appUser) {
    // Note: Cette méthode nécessite un ProviderContainer ou un contexte
    // Pour l'instant, on va utiliser une approche différente
    logger.info('User converted to AppUser: ${appUser.email}');
  }

  /// Gère la déconnexion
  static void _handleSignOut() {
    final context = navigatorKey.currentContext;
    if (context == null) return;
    
    // Ne pas rediriger automatiquement - laisser chaque page gérer sa propre redirection
    logger.info('User signed out, letting individual pages handle navigation');
  }
}
