import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'secure_usage_service.dart';

class UsageService {
  static const String _usageCountKey = 'premium_usage_count';
  static const String _maxUsageKey = 'premium_max_usage';
  static const int _defaultMaxUsage = 5;
  
  final Logger _logger = Logger('UsageService');
  
  static UsageService? _instance;
  static UsageService get instance => _instance ??= UsageService._();
  
  UsageService._();
  
  /// Initialise le service avec les préférences partagées
  Future<void> initialize() async {
    _logger.info('Initializing UsageService');
  }
  
  /// Récupère le nombre d'utilisations restantes (délègue au service sécurisé)
  Future<int> getRemainingUsage() async {
    try {
      return await SecureUsageService.instance.getRemainingUsage();
    } catch (e) {
      _logger.severe('Error getting remaining usage', e);
      return _defaultMaxUsage;
    }
  }
  
  /// Récupère le nombre maximum d'utilisations (délègue au service sécurisé)
  Future<int> getMaxUsage() async {
    try {
      return await SecureUsageService.instance.getMaxUsage();
    } catch (e) {
      _logger.severe('Error getting max usage', e);
      return _defaultMaxUsage;
    }
  }
  
  /// Récupère le nombre d'utilisations déjà effectuées (délègue au service sécurisé)
  Future<int> getUsedUsage() async {
    try {
      return await SecureUsageService.instance.getUsedUsage();
    } catch (e) {
      _logger.severe('Error getting used usage', e);
      return 0;
    }
  }
  
  /// Incrémente le compteur d'utilisations (délègue au service sécurisé)
  Future<bool> incrementUsage() async {
    try {
      return await SecureUsageService.instance.incrementUsage();
    } catch (e) {
      _logger.severe('Error incrementing usage', e);
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur a encore des utilisations disponibles
  Future<bool> hasUsageRemaining() async {
    final remaining = await getRemainingUsage();
    return remaining > 0;
  }
  
  /// Réinitialise le compteur d'utilisations (délègue au service sécurisé)
  Future<bool> resetUsage() async {
    try {
      return await SecureUsageService.instance.resetUsage();
    } catch (e) {
      _logger.severe('Error resetting usage', e);
      return false;
    }
  }
  
  /// Définit le nombre maximum d'utilisations (pour les tests ou configuration)
  Future<bool> setMaxUsage(int maxUsage) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_maxUsageKey, maxUsage);
      
      _logger.info('Max usage set to: $maxUsage');
      return true;
    } catch (e) {
      _logger.severe('Error setting max usage', e);
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur est premium (délègue au service sécurisé)
  Future<bool> isPremium() async {
    try {
      return await SecureUsageService.instance.isPremium();
    } catch (e) {
      _logger.severe('Error checking premium status', e);
      return await hasUsageRemaining();
    }
  }
}
