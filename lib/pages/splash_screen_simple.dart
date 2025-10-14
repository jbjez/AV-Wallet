import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/auth_provider.dart';
import '../providers/catalogue_provider.dart';
import 'package:logging/logging.dart';

class SplashScreenSimple extends ConsumerStatefulWidget {
  const SplashScreenSimple({super.key});

  @override
  ConsumerState<SplashScreenSimple> createState() => _SplashScreenSimpleState();
}

class _SplashScreenSimpleState extends ConsumerState<SplashScreenSimple> {
  final _logger = Logger('SplashScreenSimple');
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      _logger.info('Initializing app...');

      // Ajouter un délai minimum pour le splash screen
      await Future.delayed(const Duration(seconds: 2));

      // Vérifier si le widget est encore monté avant d'utiliser ref
      if (!mounted) return;

      // Initialiser le catalogue
      _logger.info('Initializing catalogue...');
      await ref.read(catalogueProvider.notifier).loadCatalogue();
      _logger.info('Catalogue initialized');

      // Vérifier à nouveau si le widget est encore monté
      if (!mounted) return;

      // Vérifier l'état de l'authentification
      final authState = ref.read(authProvider);

      if (!mounted) return;

      setState(() {
        _isInitialized = true;
      });

      // Navigate based on auth state
      if (authState.user != null) {
        _logger.info('Navigating to home screen');
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        _logger.info('Navigating to signup screen');
        Navigator.of(context).pushReplacementNamed('/sign-up');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error during initialization', e, stackTrace);
      if (!mounted) return;

      // Show error dialog
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Erreur'),
          content: const Text(
              'Une erreur est survenue lors de l\'initialisation de l\'application.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Retry initialization
                _initializeApp();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // S'assurer que le thème est appliqué
    final authState = ref.watch(authProvider);
    
    return Theme(
      data: Theme.of(context).copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A0E21),
      ),
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                const Color(0xFF0A0E21),
                const Color(0xFF1A1F35),
              ],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Utiliser le logo principal au lieu de Logo2
                Image.asset(
                  'assets/logo.png',
                  width: 200,
                  height: 200,
                ),
                const SizedBox(height: 20),
                if (!_isInitialized || authState.isLoading)
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF64B5F6)),
                  )
                else
                  const SizedBox(height: 20),
                if (authState.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      authState.error!,
                      style: const TextStyle(
                        color: Colors.red,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
