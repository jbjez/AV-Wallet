import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet/providers/auth_provider.dart';

// -- Déclare des signatures faibles (références tardives) pour pages existantes --
// Adapter si les chemins diffèrent dans ton projet.
import 'package:av_wallet/pages/sign_up_page.dart';
import 'package:av_wallet/pages/welcome_gate_page.dart';
import 'package:av_wallet/services/premium_email_service.dart';

class SplashGate extends ConsumerStatefulWidget {
  final AuthState authState;
  const SplashGate({super.key, required this.authState});
  @override
  ConsumerState<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends ConsumerState<SplashGate> with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late Animation<double> _logoSizeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialiser l'animation du logo
    _logoAnimationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _logoSizeAnimation = Tween<double>(
      begin: 100.0,
      end: 130.0,
    ).animate(CurvedAnimation(
      parent: _logoAnimationController,
      curve: Curves.easeInOut,
    ));
    
    // Démarrer l'animation du logo
    _logoAnimationController.forward();
    
    // Attendre 2 secondes puis continuer
    Timer(const Duration(milliseconds: 2000), _routeNext);
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    super.dispose();
  }

  void _routeNext() async {
    if (!mounted) return;
    
    try {
      // Utiliser l'authState passé en paramètre pour la redirection
      print('🔍 Auth state: ${widget.authState.isAuthenticated}');
      print('🔍 User: ${widget.authState.user?.email}');
      
      if (widget.authState.isAuthenticated) {
        print('✅ Utilisateur connecté, redirection vers WelcomeGatePage');
        
        // Vérifier si l'utilisateur a un ID
        final userId = widget.authState.user?.id;
        print('🔍 User ID: $userId');
        
        if (userId == null) {
          print('❌ Pas d\'ID utilisateur, redirection vers SignUpPage');
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignUpPage()),
          );
          return;
        }
        
        // Rediriger vers WelcomeGatePage qui gérera la biométrie et les popups
        final userEmail = widget.authState.user?.email ?? '';
        final isPremium = await PremiumEmailService.isPremiumEmail(userEmail);
        
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => WelcomeGatePage(
              email: userEmail,
              isPremium: isPremium,
            ),
          ),
        );
      } else {
        print('❌ Utilisateur non connecté, redirection vers SignUpPage');
        // Rediriger vers la page d'inscription
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignUpPage()),
        );
      }
    } catch (e) {
      print('Erreur lors de la redirection: $e');
      // En cas d'erreur, rediriger vers l'inscription
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignUpPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A1128),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Logo animé centré
            AnimatedBuilder(
              animation: _logoSizeAnimation,
              builder: (context, child) {
                return Image.asset(
                  'assets/logo2.png',
                  height: _logoSizeAnimation.value,
                  width: _logoSizeAnimation.value,
                );
              },
            ),
            const SizedBox(height: 40),
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 30),
            Text(
              'Chargement...',
              style: TextStyle(
                color: const Color(0xFF0A1128), // Bleu nuit
                fontSize: 12, // Réduit de 4 points (16 -> 12)
              ),
            ),
          ],
        ),
      ),
    );
  }
}