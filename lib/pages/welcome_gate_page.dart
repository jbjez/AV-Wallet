import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/premium_welcome_dialog.dart';
import '../services/translation_service.dart';
import '../services/biometric_auth_service.dart';
import '../providers/usage_provider.dart';
import '../l10n/app_localizations.dart';

/// Page intermédiaire qui affiche le popup welcome une seule fois
/// puis redirige vers la vraie homepage
class WelcomeGatePage extends ConsumerStatefulWidget {
  final String email;
  final bool isPremium;

  const WelcomeGatePage({
    super.key,
    required this.email,
    required this.isPremium,
  });

  @override
  ConsumerState<WelcomeGatePage> createState() => _WelcomeGatePageState();
}

class _WelcomeGatePageState extends ConsumerState<WelcomeGatePage> {
  bool _hasShownDialog = false;
  final BiometricAuthService _biometricService = BiometricAuthService();

  @override
  void initState() {
    super.initState();
    print('DEBUG: WelcomeGatePage initState - isPremium: ${widget.isPremium}');
    // Afficher le dialog après un court délai pour s'assurer que la page est montée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleBiometricAndWelcome();
    });
  }

  void _handleBiometricAndWelcome() async {
    if (_hasShownDialog) return;
    _hasShownDialog = true;

    print('DEBUG: Handling biometric and welcome - isPremium: ${widget.isPremium}');
    
    try {
      // Vérifier si la biométrie est disponible sur l'appareil
      final isBiometricAvailable = await _biometricService.isBiometricAvailable();
      print('🔍 Biométrie disponible sur l\'appareil: $isBiometricAvailable');
      
      if (isBiometricAvailable) {
        print('🔐 Biométrie disponible, vérification biométrique directe');
        // Vérification biométrique directe (permission système gérée automatiquement)
        try {
          final success = await _biometricService.authenticateWithBiometrics(
            reason: 'Vérifiez votre identité pour accéder à l\'application',
          );
          
          if (success) {
            print('✅ Vérification biométrique réussie');
            // Ajouter un délai pour bien montrer que l'auth biométrique est OK
            await Future.delayed(const Duration(milliseconds: 1000));
            _showWelcomeDialog();
          } else {
            print('❌ Vérification biométrique échouée, redirection vers connexion');
            Navigator.of(context).pushReplacementNamed('/sign-in');
          }
        } catch (e) {
          print('❌ Erreur biométrique: $e, redirection vers connexion');
          Navigator.of(context).pushReplacementNamed('/sign-in');
        }
      } else {
        print('✅ Pas de biométrie disponible, affichage popup approprié');
        _showWelcomeDialog();
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification biométrique: $e');
      _showWelcomeDialog();
    }
  }

  void _showWelcomeDialog() {
    print('DEBUG: Showing welcome dialog - isPremium: ${widget.isPremium}');
    
    final loc = AppLocalizations.of(context)!;
    final translationService = TranslationService();
    
    if (widget.isPremium) {
      _showPremiumWelcomeDialog(loc, translationService);
    } else {
      _showStandardWelcomeDialog(loc, translationService);
    }
  }

  void _showPremiumWelcomeDialog(AppLocalizations loc, TranslationService translationService) {
    print('DEBUG: Showing premium welcome dialog');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PremiumWelcomeDialog(
        email: widget.email,
        onContinue: () {
          print('DEBUG: Premium dialog onContinue called');
          Navigator.of(context).pop();
          // Ajouter un délai pour éviter le conflit de navigation
          Future.delayed(const Duration(milliseconds: 100), () {
            if (mounted) {
              _navigateToHome();
            }
          });
        },
      ),
    );
  }

  void _showStandardWelcomeDialog(AppLocalizations loc, TranslationService translationService) {
    final usageState = ref.read(usageProvider);
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF0A1128),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(
            color: Color(0xFF455A64), // Bordure bleu-gris foncé
            width: 2,
          ),
        ),
        title: Column(
          children: [
            // Logo au-dessus du titre
            Image.asset(
              'assets/logo2.png',
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 10),
            Text(
              loc.standard_welcome_title(widget.email.split('@')[0]),
              style: const TextStyle(
                color: Colors.white, 
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Text(
              loc.standard_welcome_usage_remaining(usageState.remainingUsage),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Cadre avantages premium
            Container(
              height: 200, // Hauteur fixe pour permettre le scroll
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // Padding vertical réduit
              decoration: BoxDecoration(
                color: Colors.white, // Fond blanc
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF455A64), // Bordure bleu-gris foncé
                  width: 2,
                ),
              ),
              child: SingleChildScrollView( // Scroll vertical autorisé
                child: Column(
                  children: [
                    Text(
                      loc.premium_benefits_title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8), // Espacement réduit
                    _buildBenefitItem(Icons.inventory_2, loc.premium_benefit_catalogue),
                    const SizedBox(height: 6), // Espacement réduit
                    _buildBenefitItem(Icons.calculate, loc.premium_benefit_calculations),
                    const SizedBox(height: 6), // Espacement réduit
                    _buildBenefitItem(Icons.folder_copy, loc.premium_benefit_project_management),
                    const SizedBox(height: 6), // Espacement réduit
                    _buildBenefitItem(Icons.picture_as_pdf, loc.premium_benefit_pdf_export),
                  ],
                ),
              ),
            ),
          ],
        ),
        actions: [
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min, // Centrer la Row
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Redirection vers PaymentPage avec push au lieu de pushReplacement pour permettre le retour
                    Navigator.of(context).pushNamed('/payment');
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.amber,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.star, // Icône étoile pour Premium
                    size: 24,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    // Ajouter un délai pour éviter le conflit de navigation
                    Future.delayed(const Duration(milliseconds: 100), () {
                      if (mounted) {
                        _navigateToHome();
                      }
                    });
                  },
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Icon(
                    Icons.arrow_forward, // Icône flèche pour Continuer
                    size: 24,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitItem(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: Colors.blue.shade700,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  void _navigateToHome() {
    print('DEBUG: Navigating to home page');
    // Navigation directe vers la homepage via la route nommée
    Navigator.of(context).pushReplacementNamed('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/logo2.png',
              height: 100,
            ),
            const SizedBox(height: 20),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Chargement...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
