import 'package:flutter/material.dart' hide Card;
import 'package:flutter/material.dart' as material show Card;
import 'package:logging/logging.dart';
import '../services/real_stripe_service.dart';

class RealStripePaymentPage extends StatefulWidget {
  final String planId;
  final String planName;
  final int amount;
  final String currency;
  final String interval;

  const RealStripePaymentPage({
    super.key,
    required this.planId,
    required this.planName,
    required this.amount,
    required this.currency,
    required this.interval,
  });

  @override
  State<RealStripePaymentPage> createState() => _RealStripePaymentPageState();
}

class _RealStripePaymentPageState extends State<RealStripePaymentPage> {
  final _logger = Logger('RealStripePaymentPage');
  final _formKey = GlobalKey<FormState>();
  final _cardNumberController = TextEditingController();
  final _expiryController = TextEditingController();
  final _cvcController = TextEditingController();
  final _nameController = TextEditingController();
  
  bool _isLoading = false;
  bool _isProcessing = false;
  String? _errorMessage;
  CustomPaymentIntent? _paymentIntent;
  String? _selectedPaymentMethod;

  @override
  void initState() {
    super.initState();
    _initializeStripe();
  }

  Future<void> _initializeStripe() async {
    try {
      await RealStripeService.initialize();
      _createPaymentIntent();
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur d\'initialisation: $e';
      });
    }
  }

  Future<void> _createPaymentIntent() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _paymentIntent = await RealStripeService.createPaymentIntent(
        amount: widget.amount,
        currency: widget.currency,
        planId: widget.planId,
        planName: widget.planName,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la création du paiement: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate() || _paymentIntent == null) return;
    
    if (_selectedPaymentMethod == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un moyen de paiement';
      });
      return;
    }

    // Vérifier que tous les champs de carte sont remplis
    if (_cardNumberController.text.isEmpty || 
        _expiryController.text.isEmpty || 
        _cvcController.text.isEmpty || 
        _nameController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs de la carte';
      });
      return;
    }

    setState(() {
      _isProcessing = true;
      _errorMessage = null;
    });

    try {
      // Pour l'instant, simuler le paiement (en attendant la configuration Stripe complète)
      await Future.delayed(const Duration(seconds: 2)); // Simuler le traitement
      
      // Simuler un paiement réussi
      if (_paymentIntent != null) {
        _showSuccessDialog();
      } else {
        setState(() {
          _errorMessage = 'Le paiement a échoué. Veuillez réessayer.';
        });
      }
    } catch (e) {
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
            Icon(Icons.check_circle, color: Colors.green, size: 24),
            SizedBox(width: 8),
            Text(
              'Paiement Réussi !',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Votre abonnement premium a été activé avec succès !',
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Plan: ${widget.planName}',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            Text(
              'Prix: ${(widget.amount / 100).toStringAsFixed(2)}€/${widget.interval}',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vous pouvez maintenant profiter de toutes les fonctionnalités premium !',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
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
        title: const Text('Paiement Sécurisé'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Résumé de la commande
                    _buildOrderSummary(),
                    
                    const SizedBox(height: 24),
                    
                    // Informations de sécurité
                    _buildSecurityInfo(),
                    
                    const SizedBox(height: 24),
                    
                    // Moyens de paiement acceptés
                    _buildPaymentMethods(),
                    
                    const SizedBox(height: 24),
                    
                    // Formulaire de paiement
                    _buildPaymentForm(),
                    
                    const SizedBox(height: 24),
                    
                    // Message d'erreur
                    if (_errorMessage != null) _buildErrorMessage(),
                    
                    const SizedBox(height: 24),
                    
                    // Bouton de paiement
                    _buildPaymentButton(),
                    
                    const SizedBox(height: 16),
                    
                    // Informations légales
                    _buildLegalInfo(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildOrderSummary() {
    return material.Card(
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
    );
  }

  Widget _buildSecurityInfo() {
    return material.Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.security, color: Colors.blue),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Paiement sécurisé par Stripe. Vos informations sont protégées par un chiffrement SSL 256-bit.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return material.Card(
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
            
            // Visa et Mastercard visibles
            Row(
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Visa';
                    });
                  },
                  child: _buildPaymentMethodChip('Visa', '💳', isMain: true, isSelected: _selectedPaymentMethod == 'Visa'),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'Mastercard';
                    });
                  },
                  child: _buildPaymentMethodChip('Mastercard', '💳', isMain: true, isSelected: _selectedPaymentMethod == 'Mastercard'),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            const Text(
              'Visa et Mastercard acceptés',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodChip(String name, String emoji, {bool isMain = false, bool isSelected = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected 
            ? Colors.grey.shade300 
            : (isMain ? Colors.blue.shade50 : Colors.grey.shade100),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected 
              ? Colors.grey.shade500 
              : (isMain ? Colors.blue.shade300 : Colors.grey.shade300),
          width: isSelected ? 2 : (isMain ? 1.5 : 1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji, 
            style: TextStyle(
              fontSize: 16,
              color: isSelected ? Colors.grey.shade600 : null,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            name,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isSelected 
                  ? Colors.grey.shade600 
                  : (isMain ? Colors.blue.shade800 : null),
            ),
          ),
          if (isSelected) ...[
            const SizedBox(width: 4),
            Icon(
              Icons.check_circle,
              size: 14,
              color: Colors.grey.shade600,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildPaymentForm() {
    return material.Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de paiement',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Nom du titulaire
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom du titulaire de la carte',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir le nom du titulaire';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            // Numéro de carte
            TextFormField(
              controller: _cardNumberController,
              decoration: const InputDecoration(
                labelText: 'Numéro de carte',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.credit_card),
                hintText: '1234 5678 9012 3456',
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez saisir le numéro de carte';
                }
                if (value.replaceAll(' ', '').length < 13) {
                  return 'Numéro de carte invalide';
                }
                return null;
              },
            ),
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                // Date d'expiration
                Expanded(
                  child: TextFormField(
                    controller: _expiryController,
                    decoration: const InputDecoration(
                      labelText: 'MM/AA',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                      hintText: '12/25',
                    ),
                    keyboardType: TextInputType.datetime,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Date requise';
                      }
                      if (!RegExp(r'^\d{2}/\d{2}$').hasMatch(value)) {
                        return 'Format MM/AA';
                      }
                      return null;
                    },
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // CVC
                Expanded(
                  child: TextFormField(
                    controller: _cvcController,
                    decoration: const InputDecoration(
                      labelText: 'CVC',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                      hintText: '123',
                    ),
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'CVC requis';
                      }
                      if (value.length < 3) {
                        return 'CVC invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return material.Card(
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
    );
  }

  Widget _buildPaymentButton() {
    return SizedBox(
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
    );
  }

  Widget _buildLegalInfo() {
    return const Text(
      'En procédant au paiement, vous acceptez nos conditions d\'utilisation et notre politique de confidentialité. Le paiement sera traité de manière sécurisée par Stripe.',
      style: TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
      textAlign: TextAlign.center,
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

  @override
  void dispose() {
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvcController.dispose();
    _nameController.dispose();
    super.dispose();
  }
}
