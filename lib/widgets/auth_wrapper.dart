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
  bool _showSplash = true;

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
        // Essayer de récupérer l'utilisateur actuel
        _currentUser = Supabase.instance.client.auth.currentUser;
        logger.info('Current user: ${_currentUser?.email ?? 'null'}');
      }
      
      // Écouter les changements d'authentification
      Supabase.instance.client.auth.onAuthStateChange.listen((data) {
        logger.info('Auth state changed: ${data.event}');
        if (mounted) {
          setState(() {
            _currentUser = data.session?.user;
            if (data.event == AuthChangeEvent.signedOut) {
              _forceLogin = true;
            }
          });
        }
      });
      
    } catch (e) {
      logger.severe('Error initializing auth: $e');
      _forceLogin = true;
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        
        // Attendre 3 secondes avant de masquer le splash screen
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _showSplash = false;
            });
          }
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

  @override
  Widget build(BuildContext context) {
    // TOUJOURS AFFICHER LE SPLASH SCREEN AU DÉMARRAGE
    if (!_isInitialized || _showSplash) {
      logger.info('Showing splash screen (initialization or delay)');
      return const SplashScreen();
    }

    // Si on force la connexion (après reset), afficher la page de connexion
    if (_forceLogin) {
      logger.info('Forcing login after reset, showing sign in page');
      return const SignInPage();
    }

    // Si l'utilisateur est connecté, afficher la page d'accueil
    if (_currentUser != null) {
      logger.info('User is authenticated, showing home page');
      return const HomePage();
    }

    // Sinon, afficher la page de connexion
    logger.info('User not authenticated, showing sign in page');
    return const SignInPage();
  }
}