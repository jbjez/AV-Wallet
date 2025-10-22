import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import '../services/vip_subscription_service.dart';

/// Dialog VIP pour les utilisateurs premium automatiques
class PremiumVIPDialog extends StatelessWidget {
  final String email;
  final VoidCallback onContinue;

  const PremiumVIPDialog({
    super.key,
    required this.email,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final translationService = TranslationService();
    final screenSize = MediaQuery.of(context).size;
    
    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      backgroundColor: const Color(0xFF0A1128).withOpacity(0.95),
      contentPadding: const EdgeInsets.all(16),
      titlePadding: const EdgeInsets.only(top: 16, left: 16, right: 16),
      title: Center(
        child: Image.asset(
          'assets/logo3.png',
          width: 50,
          height: 50,
          fit: BoxFit.contain,
        ),
      ),
      content: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: screenSize.width * 0.85,
          maxHeight: screenSize.height * 0.6,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.amber.withOpacity(0.1),
                      Colors.orange.withOpacity(0.1),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.amber.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.celebration,
                          color: Colors.amber.shade300,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            translationService.t('premium_vip_welcome_message'),
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.white,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: Colors.green.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade400,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              translationService.t('premium_vip_access_activated'),
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 9,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8),
          child: ElevatedButton(
            onPressed: () async {
              print('DEBUG: Premium VIP dialog OK button pressed');
              try {
                // Créer automatiquement l'abonnement VIP
                final vipService = VIPSubscriptionService();
                await vipService.createVIPSubscription(email);
                print('DEBUG: VIP subscription created successfully');
              } catch (e) {
                print('DEBUG: Error creating VIP subscription: $e');
              }
              
              Navigator.of(context).pop();
              print('DEBUG: Dialog closed, calling onContinue');
              onContinue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1A237E), // Bleu nuit
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              shadowColor: const Color(0xFF1A237E).withOpacity(0.3),
            ),
            child: Text(
              translationService.t('ok'),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
