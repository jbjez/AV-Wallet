import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../pages/home_page.dart';
import '../pages/sign_in_page.dart';
import '../pages/splash_screen.dart';
import 'package:logging/logging.dart';

final logger = Logger('AuthWrapper');

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  bool _isInitialized = false;
  User? _currentUser;
  bool _forceLogin = false;

  @override
  void initState() {
    super.initState();
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    try {
      logger.info('Initializing auth state...');
      
      // Vérifier si un reset a été effectué (pas de données utilisateur)
      final prefs = await SharedPreferences.getInstance();
      final hasUserData = prefs.containsKey('user_id') || prefs.containsKey('user_email');
      final rememberMe = prefs.getBool('remember_me') ?? false;
      
      logger.info('Has user data: $hasUserData, Remember me: $rememberMe');
      
      // Si pas de données utilisateur ET pas de remember me, forcer la connexion
      if (!hasUserData && !rememberMe) {
        logger.info('No user data found, forcing login');
        _forceLogin = true;
        _currentUser = null; // Forcer null pour garantir l'affichage de la page de connexion
        
        // Nettoyer aussi les données Hive en arrière-plan
        _clearHiveDataInBackground();
      } else {
        // Écouter les changements d'état d'authentification
        Supabase.instance.client.auth.onAuthStateChange.listen((data) {
          logger.info('Auth state changed: ${data.event}');
          logger.info('User: ${data.session?.user?.email}');
          
          if (mounted) {
            setState(() {
              _currentUser = data.session?.user;
            });
          }
        });

        // Vérifier la session actuelle
        final session = Supabase.instance.client.auth.currentSession;
        _currentUser = session?.user;
        logger.info('Current user: ${_currentUser?.email}');
      }
      
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      logger.severe('Error initializing auth: $e');
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  /// Nettoie les données Hive en arrière-plan après un reset
  void _clearHiveDataInBackground() {
    Future.microtask(() async {
      try {
        logger.info('Clearing Hive data in background...');
        
        // Liste des boxes à nettoyer
        final boxNames = ['catalogue', 'presets', 'projects', 'cart', 'lenses'];
        
        for (final boxName in boxNames) {
          try {
            if (Hive.isBoxOpen(boxName)) {
              await Hive.box(boxName).close();
            }
            await Hive.deleteBoxFromDisk(boxName);
            logger.info('Cleared box: $boxName');
          } catch (e) {
            logger.warning('Could not clear box $boxName: $e');
          }
        }
        
        logger.info('Hive data cleared successfully');
      } catch (e) {
        logger.warning('Error clearing Hive data: $e');
      }
    });
  }

  void _showWelcomeDialog() {
    if (!mounted) return;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green, size: 30),
              SizedBox(width: 10),
              Text('Connexion réussie !'),
            ],
          ),
          content: Text(
            'Bienvenue dans AV Wallet !\n\nVous êtes maintenant connecté avec Google.',
            style: TextStyle(fontSize: 16),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Continuer'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // TOUJOURS AFFICHER LE SPLASH SCREEN AU DÉMARRAGE
    if (!_isInitialized) {
      logger.info('Showing splash screen (initialization)');
      return const SplashScreen();
    }

    // Afficher le splash screen pendant 2 secondes après l'initialisation
    return FutureBuilder<void>(
      future: Future.delayed(const Duration(seconds: 2)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          logger.info('Showing splash screen (2 second delay)');
          return const SplashScreen();
        }

        // Si on force la connexion (après reset), afficher la page de connexion
        if (_forceLogin) {
          logger.info('Forcing login after reset, showing sign in page');
          return const SignInPage();
        }

        // Si l'utilisateur est connecté, afficher la page d'accueil
        if (_currentUser != null) {
          logger.info('User authenticated, showing home page');
          return const HomePage();
        }

        // Sinon, afficher la page de connexion
        logger.info('User not authenticated, showing sign in page');
        return const SignInPage();
      },
    );
  }
}

class _WelcomeScreen extends StatelessWidget {
  final String userEmail;
  final VoidCallback onContinue;

  const _WelcomeScreen({
    required this.userEmail,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[50],
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(30),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icône de succès
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  color: Colors.green[600],
                  size: 50,
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Titre
              Text(
                'Connexion réussie !',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 20),
              
              // Message de bienvenue
              Text(
                'Bienvenue dans AV Wallet !',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 10),
              
              Text(
                'Vous êtes connecté avec :\n$userEmail',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[500],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 40),
              
              // Bouton continuer
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: onContinue,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25),
                    ),
                    elevation: 5,
                  ),
                  child: const Text(
                    'Continuer',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}