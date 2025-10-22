import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

/// Service pour gérer les emails premium
class PremiumEmailService {
  static final _logger = Logger('PremiumEmailService');
  static final _supabase = Supabase.instance.client;

  /// Vérifier si un email est dans la liste premium
  static Future<bool> isPremiumEmail(String email) async {
    try {
      print('DEBUG: Checking if email is premium: $email');
      _logger.info('Checking if email is premium: $email');
      
      // Nettoyer l'email (supprimer les espaces)
      final cleanEmail = email.trim().toLowerCase();
      print('DEBUG: Clean email: $cleanEmail');
      
      // Test direct de la requête
      final response = await _supabase
          .from('premium_emails')
          .select('email')
          .eq('email', cleanEmail)
          .maybeSingle();

      print('DEBUG: Supabase response: $response');
      _logger.info('Raw response: $response');
      
      final isPremium = response != null;
      print('DEBUG: Is premium result: $isPremium');
      _logger.info('Email $email is premium: $isPremium');
      
      // Test supplémentaire : vérifier tous les emails pour debug
      if (!isPremium) {
        print('DEBUG: Email not found, checking all premium emails...');
        final allEmails = await _supabase
            .from('premium_emails')
            .select('email')
            .limit(10);
        print('DEBUG: First 10 premium emails: $allEmails');
      }
      
      return isPremium;
    } catch (e) {
      print('DEBUG: Error checking premium email: $e');
      _logger.warning('Error checking premium email: $e');
      return false; // En cas d'erreur, considérer comme non-premium
    }
  }

  /// Ajouter un email à la liste premium (pour les admins)
  static Future<bool> addPremiumEmail(String email, {String? notes}) async {
    try {
      _logger.info('Adding premium email: $email');
      
      await _supabase
          .from('premium_emails')
          .insert({
            'email': email.toLowerCase(),
          });

      _logger.info('Premium email added successfully: $email');
      return true;
    } catch (e) {
      _logger.warning('Error adding premium email: $e');
      return false;
    }
  }

  /// Obtenir tous les emails premium (pour les admins)
  static Future<List<Map<String, dynamic>>> getAllPremiumEmails() async {
    try {
      final response = await _supabase
          .from('premium_emails')
          .select('*')
          .order('created_at', ascending: false);

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      _logger.warning('Error getting premium emails: $e');
      return [];
    }
  }

  /// Désactiver un email premium (supprimer de la liste)
  static Future<bool> deactivatePremiumEmail(String email) async {
    try {
      await _supabase
          .from('premium_emails')
          .delete()
          .eq('email', email.toLowerCase());

      _logger.info('Premium email deactivated: $email');
      return true;
    } catch (e) {
      _logger.warning('Error deactivating premium email: $e');
      return false;
    }
  }
}
