import 'package:local_auth/local_auth.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricAuthService {
  static final _logger = Logger('BiometricAuthService');
  static const String _biometricEnabledKey = 'biometric_enabled';
  
  // Instance singleton
  static final BiometricAuthService _instance = BiometricAuthService._internal();
  factory BiometricAuthService() => _instance;
  BiometricAuthService._internal();

  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Vérifie si l'authentification biométrique est disponible
  Future<bool> isBiometricAvailable() async {
    try {
      final isAvailable = await _localAuth.canCheckBiometrics;
      final isDeviceSupported = await _localAuth.isDeviceSupported();
      final availableBiometrics = await _localAuth.getAvailableBiometrics();
      
      _logger.info('Biometric available: $isAvailable, Device supported: $isDeviceSupported, Available biometrics: $availableBiometrics');
      
      // Vérifier qu'il y a au moins une méthode biométrique disponible
      return isAvailable && isDeviceSupported && availableBiometrics.isNotEmpty;
    } catch (e) {
      _logger.warning('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Obtient les types d'authentification biométrique disponibles
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final biometrics = await _localAuth.getAvailableBiometrics();
      _logger.info('Available biometrics: $biometrics');
      return biometrics;
    } catch (e) {
      _logger.warning('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authentifie l'utilisateur avec la biométrie
  Future<bool> authenticateWithBiometrics({String? reason}) async {
    try {
      _logger.info('Starting biometric authentication');
      
      // Vérifier d'abord si la biométrie est disponible
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.warning('Biometric authentication not available');
        return false;
      }

      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        _logger.warning('No biometric methods available');
        return false;
      }

      _logger.info('Attempting authentication with biometrics: $biometrics');

      final result = await _localAuth.authenticate(
        localizedReason: reason ?? 'Authentifiez-vous pour accéder à votre compte',
        options: const AuthenticationOptions(
          biometricOnly: false, // Permettre d'autres méthodes si Face ID échoue
          stickyAuth: false, // Ne pas rester collé
        ),
      );

      _logger.info('Biometric authentication result: $result');
      return result;
    } catch (e) {
      _logger.severe('Error during biometric authentication: $e');
      return false;
    }
  }

  /// Active l'authentification biométrique pour l'utilisateur
  Future<bool> enableBiometricAuth(String userId) async {
    try {
      _logger.info('Enabling biometric auth for user: $userId');
      
      // Vérifier d'abord si la biométrie est disponible
      final isAvailable = await isBiometricAvailable();
      if (!isAvailable) {
        _logger.warning('Biometric authentication not available');
        return false;
      }

      // Vérifier les méthodes disponibles
      final biometrics = await getAvailableBiometrics();
      if (biometrics.isEmpty) {
        _logger.warning('No biometric methods available');
        return false;
      }

      _logger.info('Available biometric methods: $biometrics');

      // Tester l'authentification avec une gestion d'erreur plus robuste
      try {
        final success = await authenticateWithBiometrics(
          reason: 'Activez l\'authentification biométrique pour votre compte',
        );

        if (success) {
          // Sauvegarder la préférence
          await _setBiometricEnabled(userId, true);
          _logger.info('Biometric authentication enabled successfully');
          return true;
        } else {
          _logger.warning('Biometric authentication test failed or was cancelled');
          return false;
        }
      } catch (authError) {
        _logger.severe('Error during biometric authentication test: $authError');
        return false;
      }
    } catch (e) {
      _logger.severe('Error enabling biometric auth: $e');
      return false;
    }
  }

  /// Désactive l'authentification biométrique
  Future<bool> disableBiometricAuth(String userId) async {
    try {
      _logger.info('Disabling biometric auth for user: $userId');
      await _setBiometricEnabled(userId, false);
      _logger.info('Biometric authentication disabled successfully');
      return true;
    } catch (e) {
      _logger.severe('Error disabling biometric auth: $e');
      return false;
    }
  }

  /// Vérifie si l'authentification biométrique est activée pour l'utilisateur
  Future<bool> isBiometricEnabled(String userId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool('${_biometricEnabledKey}_$userId') ?? false;
    } catch (e) {
      _logger.warning('Error checking biometric enabled status: $e');
      return false;
    }
  }

  /// Obtient le nom de la méthode biométrique disponible
  Future<String> getBiometricMethodName() async {
    try {
      final biometrics = await getAvailableBiometrics();
      
      if (biometrics.contains(BiometricType.face)) {
        return 'Face ID';
      } else if (biometrics.contains(BiometricType.fingerprint)) {
        return 'Touch ID';
      } else if (biometrics.contains(BiometricType.iris)) {
        return 'Iris';
      } else {
        return 'Authentification biométrique';
      }
    } catch (e) {
      _logger.warning('Error getting biometric method name: $e');
      return 'Authentification biométrique';
    }
  }

  /// Sauvegarde l'état d'activation de la biométrie
  Future<void> _setBiometricEnabled(String userId, bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_biometricEnabledKey}_$userId', enabled);
  }
}
