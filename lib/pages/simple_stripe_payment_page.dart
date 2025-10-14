import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SimpleStripePaymentPage extends ConsumerStatefulWidget {
  final String planId;
  final String planName;
  final int amount;
  final String currency;
  final String interval;

  const SimpleStripePaymentPage({
    super.key,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.interval,
  });

  @override
  ConsumerState<SimpleStripePaymentPage> createState() => _SimpleStripePaymentPageState();
}

class _SimpleStripePaymentPageState extends ConsumerState<SimpleStripePaymentPage> {
  final _logger = Logger('SimpleStripePaymentPage');
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;

  Future<void> _processPayment() async {
    if (_isProcessing) return;

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      _logger.info('Starting payment process for ${widget.planName}');

      // Obtenir l'utilisateur actuel
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Simuler le processus de paiement
      await Future.delayed(const Duration(seconds: 2));

      _logger.info('Payment successful (simulated)');
      _showSuccessDialog();

    } catch (e) {
      _logger.severe('Payment error: $e');
      setState(() {
        _errorMessage = 'Erreur de paiement: $e';
      });
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 32),
            SizedBox(width: 12),
            Text('Paiement Réussi !'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Votre abonnement premium a été activé avec succès !'),
            const SizedBox(height: 16),
            Text(
              'Plan: ${widget.planName}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text('Prix: ${(widget.amount / 100).toStringAsFixed(2)}€/${widget.interval}'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(true); // Retour avec succès
            },
            child: const Text('Continuer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paiement'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Résumé de la commande
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Résumé de la commande',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildOrderRow('Plan', widget.planName),
                          _buildOrderRow('Prix', '${(widget.amount / 100).toStringAsFixed(2)}€'),
                          _buildOrderRow('Période', widget.interval),
                          const Divider(),
                          _buildOrderRow(
                            'Total',
                            '${(widget.amount / 100).toStringAsFixed(2)}€',
                            isTotal: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Informations de sécurité
                  Card(
                    color: Colors.blue.shade50,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          const Icon(Icons.security, color: Colors.blue),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Paiement sécurisé par Stripe. Vos informations sont protégées.',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.blue.shade800,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Moyens de paiement acceptés
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Moyens de paiement acceptés',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _buildPaymentMethodIcon('Visa', '💳'),
                              const SizedBox(width: 8),
                              _buildPaymentMethodIcon('Mastercard', '💳'),
                              const SizedBox(width: 8),
                              _buildPaymentMethodIcon('American Express', '💳'),
                              const SizedBox(width: 8),
                              _buildPaymentMethodIcon('CB', '💳'),
                            ],
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Toutes les cartes bancaires sont acceptées',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Message d'erreur
                  if (_errorMessage != null)
                    Card(
                      color: Colors.red.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.error, color: Colors.red),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  
                  const SizedBox(height: 24),
                  
                  // Bouton de paiement
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isProcessing ? null : _processPayment,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isProcessing
                          ? const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Traitement en cours...'),
                              ],
                            )
                          : Text('Payer ${(widget.amount / 100).toStringAsFixed(2)}€'),
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Informations supplémentaires
                  const Text(
                    'En procédant au paiement, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité.',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildOrderRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              fontSize: isTotal ? 16 : 14,
              color: isTotal ? Colors.deepPurple : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentMethodIcon(String name, String emoji) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 4),
          Text(
            name,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
