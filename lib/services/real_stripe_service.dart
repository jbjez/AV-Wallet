import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Classe personnalisée pour simuler un PaymentIntent
class CustomPaymentIntent {
  final String id;
  final String clientSecret;
  final int amount;
  final String currency;
  final String status;

  CustomPaymentIntent({
    required this.id,
    required this.clientSecret,
    required this.amount,
    required this.currency,
    required this.status,
  });
}

class RealStripeService {
  static final _logger = Logger('RealStripeService');
  static const String _publishableKey = 'pk_live_51S7G6pGRivW6Q25P0P1gom8tZLkJNTbC2YWEyZsKbkRgEbKhVv4Ts2x6eCAZMnzg5mUJNNEqDmmx7EHz0ZFvwYD400yPcwvWSz';
  
  static Future<void> initialize() async {
    try {
      Stripe.publishableKey = _publishableKey;
      await Stripe.instance.applySettings();
      _logger.info('Stripe initialized successfully');
    } catch (e) {
      _logger.severe('Failed to initialize Stripe: $e');
      rethrow;
    }
  }

  static Future<CustomPaymentIntent> createPaymentIntent({
    required int amount,
    required String currency,
    required String planId,
    required String planName,
  }) async {
    try {
      _logger.info('Creating payment intent for $planName: ${amount / 100}€');

      // Obtenir l'utilisateur actuel
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Appeler la fonction Supabase pour créer le PaymentIntent
      final response = await Supabase.instance.client.rpc('create_payment_intent', params: {
        'amount': amount,
        'currency': currency,
        'plan_id': planId,
        'plan_name': planName,
        'user_id': user.id,
        'user_email': user.email ?? '',
      });
      
      final paymentIntent = CustomPaymentIntent(
        id: response['id'] as String,
        clientSecret: response['client_secret'] as String,
        amount: amount,
        currency: currency,
        status: response['status'] as String,
      );
      
      _logger.info('PaymentIntent created via Supabase: ${paymentIntent.id}');
      
      return paymentIntent;
    } catch (e) {
      _logger.severe('Error creating payment intent: $e');
      rethrow;
    }
  }

  static Future<bool> confirmPayment({
    required String paymentIntentId,
    required String clientSecret,
  }) async {
    try {
      _logger.info('Confirming payment: $paymentIntentId');

      // Confirmer le paiement avec Stripe
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
      );

      if (paymentIntent.status.toString() == 'PaymentIntentStatus.succeeded') {
        _logger.info('Payment confirmed successfully');
        
        // Mettre à jour le statut d'abonnement dans Supabase
        await _updateSubscriptionStatus(paymentIntentId);
        
        return true;
      } else {
        _logger.warning('Payment not succeeded: ${paymentIntent.status}');
        return false;
      }
    } catch (e) {
      _logger.severe('Error confirming payment: $e');
      rethrow;
    }
  }

  static Future<void> _updateSubscriptionStatus(String paymentIntentId) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;

      // Mettre à jour le statut d'abonnement dans Supabase
      await Supabase.instance.client.from('subscriptions').insert({
        'user_id': user.id,
        'payment_intent_id': paymentIntentId,
        'status': 'active',
        'created_at': DateTime.now().toIso8601String(),
      });

      _logger.info('Subscription status updated successfully');
    } catch (e) {
      _logger.warning('Failed to update subscription status: $e');
    }
  }

  static Future<List<PaymentMethod>> getPaymentMethods() async {
    try {
      // Note: Cette méthode nécessite une implémentation côté serveur
      // pour récupérer les méthodes de paiement sauvegardées
      _logger.info('Retrieving payment methods...');
      return [];
    } catch (e) {
      _logger.warning('Failed to retrieve payment methods: $e');
      return [];
    }
  }

  static Future<void> savePaymentMethod({
    required String cardNumber,
    required String expiryMonth,
    required String expiryYear,
    required String cvc,
  }) async {
    try {
      // Créer un PaymentMethod avec les détails de la carte
      final paymentMethod = await Stripe.instance.createPaymentMethod(
        params: PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(
            billingDetails: BillingDetails(
              email: Supabase.instance.client.auth.currentUser?.email,
            ),
          ),
        ),
      );

      _logger.info('Payment method saved: ${paymentMethod.id}');
    } catch (e) {
      _logger.severe('Failed to save payment method: $e');
      rethrow;
    }
  }

  static List<String> getSupportedPaymentMethods() {
    return [
      'Visa',
      'Mastercard', 
      'American Express',
      'CB (Carte Bancaire)',
      'Diners Club',
      'Discover',
      'JCB',
      'UnionPay',
    ];
  }

  static Map<String, String> getPaymentMethodIcons() {
    return {
      'Visa': '💳',
      'Mastercard': '💳',
      'American Express': '💳',
      'CB (Carte Bancaire)': '💳',
      'Diners Club': '💳',
      'Discover': '💳',
      'JCB': '💳',
      'UnionPay': '💳',
    };
  }
}
