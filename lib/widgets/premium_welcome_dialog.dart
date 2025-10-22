import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../pages/home_page.dart';

/// Dialog de bienvenue pour les utilisateurs premium
class PremiumWelcomeDialog extends StatelessWidget {
  final String email;
  final VoidCallback onContinue;

  const PremiumWelcomeDialog({
    super.key,
    required this.email,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final screenSize = MediaQuery.of(context).size;
    
    return AlertDialog(
      backgroundColor: const Color(0xFF0A1128), // Fond foncé
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(
          color: Color(0xFF455A64), // Bleu-gris foncé
          width: 2,
        ),
      ),
      title: Center(
        child: Text(
          loc.premium_welcome_title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Texte blanc
          ),
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
              Center(
                child: Column(
                  children: [
                    Text(
                      'Bienvenue sur AV Wallet, ${email.split('@')[0]}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Texte blanc
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Félicitation, Premium Activé',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white, // Texte blanc
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100, // Fond clair pour les avantages
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              loc.premium_benefits_title,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black, // Texte noir sur fond clair
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildBenefitItem(
                      'Catalogue +220 Produits',
                      Icons.inventory_2,
                    ),
                    _buildBenefitItem(
                      'Calculs Illimités',
                      Icons.calculate,
                    ),
                    _buildBenefitItem(
                      'Gestion Projet/Preset',
                      Icons.folder_copy,
                    ),
                    _buildBenefitItem(
                      'Export PDF',
                      Icons.picture_as_pdf,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(
            loc.premium_welcome_later,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            // Navigation directe vers la homepage
            Future.delayed(const Duration(milliseconds: 100), () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (context) => const HomePage()),
              );
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Text(
            'Accéder',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildBenefitItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black, // Texte noir sur fond clair
              ),
            ),
          ),
        ],
      ),
    );
  }
}
