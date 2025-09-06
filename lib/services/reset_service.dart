import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'hive_service.dart';

/// Service pour effectuer un reset complet de l'application
/// Simule une première visite en supprimant toutes les données locales
class ResetService {
  static final _logger = Logger('ResetService');

  /// Effectue un reset complet de l'application
  /// Supprime toutes les données locales (Hive + SharedPreferences)
  static Future<void> performCompleteReset() async {
    try {
      _logger.info('Starting complete app reset...');
      
      // 1. Déconnexion Supabase (si connecté)
      await _signOutFromSupabase();
      
      // 2. Nettoyer toutes les données Hive
      await _clearAllHiveData();
      
      // 3. Nettoyer toutes les SharedPreferences
      await _clearAllSharedPreferences();
      
      // 4. Réinitialiser Hive
      await HiveService.initialize();
      
      _logger.info('Complete app reset completed successfully');
      
    } catch (e) {
      _logger.severe('Error during complete reset: $e');
      throw 'Erreur lors du reset: ${e.toString()}';
    }
  }

  /// Déconnexion de Supabase
  static Future<void> _signOutFromSupabase() async {
    try {
      final supabase = Supabase.instance.client;
      
      // Forcer la déconnexion avec nettoyage complet
      await supabase.auth.signOut();
      
      // Attendre un peu pour que la déconnexion soit effective
      await Future.delayed(const Duration(milliseconds: 500));
      
      // Vérifier que la session est bien supprimée
      final session = supabase.auth.currentSession;
      if (session != null) {
        _logger.warning('Session still exists after signOut, forcing clear');
        // Forcer la suppression de la session
        await supabase.auth.signOut();
      }
      
      _logger.info('Supabase sign out completed');
    } catch (e) {
      _logger.warning('Error signing out from Supabase: $e');
      // Continue même si la déconnexion Supabase échoue
    }
  }

  /// Nettoie toutes les données Hive
  static Future<void> _clearAllHiveData() async {
    try {
      _logger.info('Clearing all Hive data...');
      
      // Liste de toutes les boxes Hive connues
      final boxNames = [
        'catalogue',
        'presets', 
        'projects',
        'cart',
        'page_states',
        'lenses',
        'user_data',
        'app_settings'
      ];

      // Fermer toutes les boxes ouvertes
      for (final boxName in boxNames) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
          _logger.info('Closed box: $boxName');
        }
      }

      // Supprimer toutes les boxes du disque
      for (final boxName in boxNames) {
        try {
          await Hive.deleteBoxFromDisk(boxName);
          _logger.info('Deleted box from disk: $boxName');
        } catch (e) {
          _logger.warning('Could not delete box $boxName: $e');
          // Continue même si une box ne peut pas être supprimée
        }
      }

      _logger.info('All Hive data cleared');
      
    } catch (e) {
      _logger.warning('Error clearing Hive data: $e');
      // Continue même si le nettoyage Hive échoue partiellement
    }
  }

  /// Nettoie toutes les SharedPreferences
  static Future<void> _clearAllSharedPreferences() async {
    try {
      _logger.info('Clearing all SharedPreferences...');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Liste de toutes les clés connues dans SharedPreferences
      final keysToRemove = [
        'remember_me',
        'user_id', 
        'user_email',
        'theme_mode',
        'languageCode',
        'click_count',
        'first_launch',
        'onboarding_completed',
        'app_version',
        'last_sync',
        'user_preferences',
        'app_settings'
      ];

      // Supprimer toutes les clés connues
      for (final key in keysToRemove) {
        try {
          await prefs.remove(key);
          _logger.info('Removed preference: $key');
        } catch (e) {
          _logger.warning('Could not remove preference $key: $e');
        }
      }

      // Essayer de supprimer toutes les clés (méthode alternative)
      try {
        await prefs.clear();
        _logger.info('Cleared all SharedPreferences');
      } catch (e) {
        _logger.warning('Could not clear all SharedPreferences: $e');
      }

      _logger.info('SharedPreferences cleared');
      
    } catch (e) {
      _logger.warning('Error clearing SharedPreferences: $e');
      // Continue même si le nettoyage SharedPreferences échoue
    }
  }

  /// Reset uniquement les données utilisateur (garde les préférences d'app)
  static Future<void> performUserDataReset() async {
    try {
      _logger.info('Starting user data reset...');
      
      // 1. Déconnexion Supabase
      await _signOutFromSupabase();
      
      // 2. Nettoyer les données utilisateur Hive
      await _clearUserHiveData();
      
      // 3. Nettoyer les préférences utilisateur
      await _clearUserPreferences();
      
      _logger.info('User data reset completed');
      
    } catch (e) {
      _logger.severe('Error during user data reset: $e');
      throw 'Erreur lors du reset des données utilisateur: ${e.toString()}';
    }
  }

  /// Nettoie uniquement les données utilisateur dans Hive
  static Future<void> _clearUserHiveData() async {
    try {
      final userDataBoxes = ['projects', 'cart', 'user_data'];
      
      for (final boxName in userDataBoxes) {
        if (Hive.isBoxOpen(boxName)) {
          await Hive.box(boxName).close();
        }
        try {
          await Hive.deleteBoxFromDisk(boxName);
          _logger.info('Deleted user data box: $boxName');
        } catch (e) {
          _logger.warning('Could not delete user data box $boxName: $e');
        }
      }
    } catch (e) {
      _logger.warning('Error clearing user Hive data: $e');
    }
  }

  /// Nettoie uniquement les préférences utilisateur
  static Future<void> _clearUserPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPrefs = ['remember_me', 'user_id', 'user_email'];
      
      for (final key in userPrefs) {
        await prefs.remove(key);
        _logger.info('Removed user preference: $key');
      }
    } catch (e) {
      _logger.warning('Error clearing user preferences: $e');
    }
  }

  /// Vérifie si c'est la première visite après un reset
  static Future<bool> isFirstVisit() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final firstLaunch = prefs.getBool('first_launch') ?? true;
      return firstLaunch;
    } catch (e) {
      _logger.warning('Error checking first visit: $e');
      return true; // Par défaut, considérer comme première visite
    }
  }

  /// Marque que l'utilisateur a terminé la première visite
  static Future<void> markFirstVisitCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('first_launch', false);
      _logger.info('First visit marked as completed');
    } catch (e) {
      _logger.warning('Error marking first visit completed: $e');
    }
  }
}
