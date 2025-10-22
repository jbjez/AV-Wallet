import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet/providers/auth_provider.dart';
import 'package:av_wallet/pages/home_page.dart';
import 'package:av_wallet/pages/sign_in_page.dart';
import 'package:av_wallet/services/supabase_service.dart';

class InitialLoadingPage extends ConsumerStatefulWidget {
  const InitialLoadingPage({super.key});

  @override
  ConsumerState<InitialLoadingPage> createState() => _InitialLoadingPageState();
}

class _InitialLoadingPageState extends ConsumerState<InitialLoadingPage> {
  bool _isInitializing = true;
  String _statusText = 'Initialisation...';

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      setState(() {
        _statusText = 'Connexion aux services...';
      });
      
      // Initialiser Supabase en arrière-plan
      await SB.init();
      
      setState(() {
        _statusText = 'Vérification de l\'authentification...';
      });
      
      // Attendre un peu pour que l'auth soit prêt
      await Future.delayed(const Duration(milliseconds: 500));
      
      setState(() {
        _isInitializing = false;
      });
      
      // Naviguer vers la bonne page
      _checkAuthAndNavigate();
    } catch (e) {
      print('Erreur lors de l\'initialisation: $e');
      setState(() {
        _isInitializing = false;
        _statusText = 'Erreur d\'initialisation';
      });
      
      // En cas d'erreur, rediriger vers la connexion après un délai
      Timer(const Duration(seconds: 2), () {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const SignInPage()),
          );
        }
      });
    }
  }

  void _checkAuthAndNavigate() async {
    if (!mounted) return;
    
    try {
      // Utiliser le provider d'authentification
      final authState = ref.read(authProvider);
      
      if (authState.isAuthenticated) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SignInPage()),
        );
      }
    } catch (e) {
      print('Erreur lors de la vérification d\'authentification: $e');
      // En cas d'erreur, rediriger vers la connexion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SignInPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF0A0E21), // Bleu nuit foncé
              Color(0xFF1A1F35), // Bleu nuit plus clair
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/logo2.png',
                width: 140,
                height: 140,
                fit: BoxFit.contain,
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)), // Bleu clair
              ),
              const SizedBox(height: 20),
              Text(
                _statusText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
