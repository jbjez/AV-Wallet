import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';

class VIPSubscriptionService {
  final _supabase = Supabase.instance.client;
  final _logger = Logger('VIPSubscriptionService');

  /// Crée automatiquement un abonnement premium pour un utilisateur VIP
  Future<bool> createVIPSubscription(String userEmail) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        _logger.warning('No authenticated user found');
        return false;
      }

      // Vérifier si l'utilisateur est déjà premium
      final existingSubscription = await _checkExistingSubscription(user.id);
      if (existingSubscription) {
        _logger.info('User already has premium subscription');
        return true;
      }

      // Créer un abonnement VIP permanent (expire dans 10 ans)
      final expiresAt = DateTime.now().add(const Duration(days: 3650));
      
      await _supabase.from('subscriptions').insert({
        'user_id': user.id,
        'plan_id': 'vip_lifetime',
        'plan_name': 'VIP Lifetime',
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
        'expires_at': expiresAt.toIso8601String(),
        'stripe_subscription_id': null,
        'stripe_customer_id': null,
        'updated_at': DateTime.now().toIso8601String(),
      });

      _logger.info('VIP subscription created for user: $userEmail');
      return true;
    } catch (e) {
      _logger.severe('Error creating VIP subscription: $e');
      return false;
    }
  }

  /// Vérifie si l'utilisateur a déjà un abonnement
  Future<bool> _checkExistingSubscription(String userId) async {
    try {
      final response = await _supabase
          .from('subscriptions')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      return response != null;
    } catch (e) {
      _logger.warning('Error checking existing subscription: $e');
      return false;
    }
  }

  /// Vérifie si un utilisateur est VIP et devrait avoir un abonnement premium
  Future<bool> isVIPUser(String email) async {
    try {
      final response = await _supabase
          .from('premium_emails')
          .select('email')
          .eq('email', email.toLowerCase())
          .maybeSingle();

      return response != null;
    } catch (e) {
      _logger.warning('Error checking VIP status: $e');
      return false;
    }
  }

  /// Synchronise le statut VIP avec l'abonnement
  Future<bool> syncVIPStatus(String userEmail) async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return false;
      }

      final isVIP = await isVIPUser(userEmail);
      if (isVIP) {
        return await createVIPSubscription(userEmail);
      }

      return true;
    } catch (e) {
      _logger.severe('Error syncing VIP status: $e');
      return false;
    }
  }
}
