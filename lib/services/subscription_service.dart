import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:logging/logging.dart';
import 'premium_email_service.dart';

class SubscriptionService {
  final _supabase = Supabase.instance.client;
  final _logger = Logger('SubscriptionService');

  /// Vérifie le statut d'abonnement de l'utilisateur
  Future<SubscriptionStatus> getSubscriptionStatus() async {
    try {
      print('DEBUG: Checking subscription status...');
      final user = _supabase.auth.currentUser;
      if (user == null) {
        print('DEBUG: No user, returning standard');
        return SubscriptionStatus.standard;
      }

      print('DEBUG: User email: ${user.email}');
      
      // Vérifier d'abord si l'utilisateur est VIP
      final isVIP = await PremiumEmailService.isPremiumEmail(user.email ?? '');
      print('DEBUG: Is VIP: $isVIP');
      if (isVIP) {
        _logger.info('User is VIP, returning premium status');
        print('DEBUG: Returning premium status (VIP)');
        return SubscriptionStatus.premium;
      }

      // Vérifier dans la table des abonnements
      print('DEBUG: Checking subscriptions table...');
      final response = await _supabase
          .from('subscriptions')
          .select('status, expires_at')
          .eq('user_id', user.id)
          .single();

      print('DEBUG: Subscription response: $response');
      if (response.isNotEmpty) {
        final status = response['status'] as String?;
        final expiresAt = response['expires_at'] as String?;
        
        print('DEBUG: Status: $status, Expires: $expiresAt');
        if (status == 'active' && expiresAt != null) {
          final expiryDate = DateTime.parse(expiresAt);
          if (expiryDate.isAfter(DateTime.now())) {
            print('DEBUG: Returning premium status (active subscription)');
            return SubscriptionStatus.premium;
          }
        }
      }

      print('DEBUG: Returning standard status');
      return SubscriptionStatus.standard;
    } catch (e) {
      print('DEBUG: Error checking subscription: $e');
      _logger.warning('Error checking subscription status: $e');
      return SubscriptionStatus.standard;
    }
  }

  /// S'abonner (simulation - à remplacer par Stripe)
  Future<bool> subscribeToPremium() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Simuler un abonnement de 30 jours
      final expiresAt = DateTime.now().add(const Duration(days: 30));
      
      await _supabase.from('subscriptions').upsert({
        'user_id': user.id,
        'status': 'active',
        'expires_at': expiresAt.toIso8601String(),
        'created_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      _logger.info('User subscribed to premium successfully');
      return true;
    } catch (e) {
      _logger.severe('Error subscribing to premium: $e');
      return false;
    }
  }

  /// Se désabonner
  Future<bool> unsubscribe() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      await _supabase
          .from('subscriptions')
          .update({
            'status': 'cancelled',
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('user_id', user.id);

      _logger.info('User unsubscribed successfully');
      return true;
    } catch (e) {
      _logger.severe('Error unsubscribing: $e');
      return false;
    }
  }

  /// Obtenir les détails de l'abonnement
  Future<Map<String, dynamic>?> getSubscriptionDetails() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return null;
      }

      final response = await _supabase
          .from('subscriptions')
          .select('*')
          .eq('user_id', user.id)
          .single();

      return response;
    } catch (e) {
      _logger.warning('Error getting subscription details: $e');
      return null;
    }
  }
}

enum SubscriptionStatus {
  standard,
  premium,
}
