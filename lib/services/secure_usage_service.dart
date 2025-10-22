import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'device_fingerprint_service.dart';

class SecureUsageService {
  static const String _usageCountKey = 'premium_usage_count';
  static const String _maxUsageKey = 'premium_max_usage';
  static const String _lastValidationKey = 'last_validation_timestamp';
  static const int _defaultMaxUsage = 5;
  static const int _validationIntervalHours = 24; // Validation serveur toutes les 24h
  
  final Logger _logger = Logger('SecureUsageService');
  final SupabaseClient _supabase = Supabase.instance.client;
  
  static SecureUsageService? _instance;
  static SecureUsageService get instance => _instance ??= SecureUsageService._();
  
  SecureUsageService._();
  
  /// Initialise le service sécurisé
  Future<void> initialize() async {
    _logger.info('Initializing SecureUsageService');
    
    // Vérifier si l'appareil a déjà utilisé le freemium
    final hasUsedFreemium = await DeviceFingerprintService.instance.hasDeviceUsedFreemium();
    if (hasUsedFreemium) {
      _logger.info('Device has already used freemium, checking server validation');
      await _validateWithServer();
    }
  }
  
  /// Récupère le nombre d'utilisations restantes (avec validation serveur)
  Future<int> getRemainingUsage() async {
    try {
      // Vérifier si une validation serveur est nécessaire
      if (await _shouldValidateWithServer()) {
        await _validateWithServer();
      }
      
      final prefs = await SharedPreferences.getInstance();
      final maxUsage = prefs.getInt(_maxUsageKey) ?? _defaultMaxUsage;
      final usedCount = prefs.getInt(_usageCountKey) ?? 0;
      final remaining = maxUsage - usedCount;
      
      _logger.info('Remaining usage: $remaining (used: $usedCount, max: $maxUsage)');
      return remaining;
    } catch (e) {
      _logger.severe('Error getting remaining usage: $e');
      return _defaultMaxUsage;
    }
  }
  
  /// Incrémente l'utilisation avec validation serveur
  Future<bool> incrementUsage() async {
    try {
      // Vérifier d'abord si l'appareil peut utiliser le freemium
      final canUseFreemium = await _canDeviceUseFreemium();
      if (!canUseFreemium) {
        _logger.warning('Device cannot use freemium - already used or blocked');
        return false;
      }
      
      // Vérifier les utilisations restantes
      final remaining = await getRemainingUsage();
      if (remaining <= 0) {
        _logger.warning('No remaining usage available');
        return false;
      }
      
      // Incrémenter via Supabase
      final deviceId = await DeviceFingerprintService.instance.getDeviceId();
      final user = _supabase.auth.currentUser;
      
      final response = await _supabase.rpc('increment_usage', params: {
        'p_device_id': deviceId,
        'p_user_id': user?.id,
        'p_max_usage': _defaultMaxUsage,
      });
      
      if (response != null && response['success'] == true) {
        final usedCount = response['used_count'] as int;
        final canUse = response['can_use'] as bool;
        
        // Mettre à jour le cache local
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_usageCountKey, usedCount);
        
        // Marquer l'appareil comme ayant utilisé le freemium SEULEMENT si c'est la dernière utilisation
        if (!canUse) {
          await DeviceFingerprintService.instance.markDeviceAsUsed();
          _logger.info('Device marked as used - freemium exhausted');
        }
        
        _logger.info('Usage incremented via Supabase: $usedCount/$_defaultMaxUsage');
        return true;
      } else {
        _logger.warning('Failed to increment usage via Supabase, falling back to local');
        return await _incrementUsageLocally();
      }
    } catch (e) {
      _logger.severe('Error incrementing usage: $e');
      _logger.info('Falling back to local increment');
      return await _incrementUsageLocally();
    }
  }
  
  /// Incrémente l'utilisation localement (fallback)
  Future<bool> _incrementUsageLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_usageCountKey) ?? 0;
      final newCount = currentCount + 1;
      await prefs.setInt(_usageCountKey, newCount);
      
      // Marquer l'appareil comme ayant utilisé le freemium SEULEMENT si c'est la dernière utilisation
      if (newCount >= _defaultMaxUsage) {
        await DeviceFingerprintService.instance.markDeviceAsUsed();
        _logger.info('Device marked as used - freemium exhausted');
      }
      
      _logger.info('Usage incremented locally: $currentCount -> $newCount');
      return true;
    } catch (e) {
      _logger.severe('Error incrementing usage locally: $e');
      return false;
    }
  }
  
  /// Vérifie si l'appareil peut utiliser le freemium
  Future<bool> _canDeviceUseFreemium() async {
    try {
      // Vérifier si l'appareil a déjà épuisé le freemium
      final hasUsedFreemium = await DeviceFingerprintService.instance.hasDeviceUsedFreemium();
      if (hasUsedFreemium) {
        _logger.info('Device has already exhausted freemium');
        return false;
      }
      
      // Vérifier si l'utilisateur est premium
      final user = _supabase.auth.currentUser;
      if (user != null) {
        // TODO: Vérifier le statut premium dans la base de données
        // Pour l'instant, on considère que l'utilisateur connecté peut utiliser le freemium
        return true;
      }
      
      // Utilisateur non connecté - peut utiliser le freemium
      return true;
    } catch (e) {
      _logger.severe('Error checking freemium eligibility: $e');
      return false;
    }
  }
  
  /// Vérifie si une validation serveur est nécessaire
  Future<bool> _shouldValidateWithServer() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastValidation = prefs.getInt(_lastValidationKey);
      
      if (lastValidation == null) {
        return true; // Première validation
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastValidation = (now - lastValidation) / (1000 * 60 * 60);
      
      return hoursSinceLastValidation >= _validationIntervalHours;
    } catch (e) {
      _logger.severe('Error checking validation interval: $e');
      return true; // En cas d'erreur, valider
    }
  }
  
  /// Valide les données avec le serveur Supabase
  Future<void> _validateWithServer() async {
    try {
      final deviceId = await DeviceFingerprintService.instance.getDeviceId();
      final user = _supabase.auth.currentUser;
      final usageCount = await getUsedUsage();
      
      _logger.info('Validating usage with Supabase server');
      _logger.info('Device ID: ${deviceId.substring(0, 8)}...');
      _logger.info('User ID: ${user?.id ?? 'Not authenticated'}');
      _logger.info('Usage count: $usageCount');
      
      // Utiliser la fonction RPC pour synchroniser les données
      final response = await _supabase.rpc('increment_usage', params: {
        'p_device_id': deviceId,
        'p_user_id': user?.id,
        'p_max_usage': _defaultMaxUsage,
      });
      
      if (response != null && response['success'] == true) {
        // Mettre à jour le cache local avec les données du serveur
        final serverUsedCount = response['used_count'] as int;
        final prefs = await SharedPreferences.getInstance();
        await prefs.setInt(_usageCountKey, serverUsedCount);
        await prefs.setInt(_lastValidationKey, DateTime.now().millisecondsSinceEpoch);
        
        _logger.info('Server validation successful - data synced to Supabase');
        _logger.info('Server usage count: $serverUsedCount');
      } else {
        _logger.warning('Server validation failed - no response from Supabase');
      }
    } catch (e) {
      _logger.severe('Error validating with server: $e');
      // En cas d'erreur, on continue avec les données locales
      _logger.info('Continuing with local data due to server error');
    }
  }
  
  /// Récupère le nombre d'utilisations déjà effectuées
  Future<int> getUsedUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_usageCountKey) ?? 0;
    } catch (e) {
      _logger.severe('Error getting used usage: $e');
      return 0;
    }
  }
  
  /// Récupère le nombre maximum d'utilisations
  Future<int> getMaxUsage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_maxUsageKey) ?? _defaultMaxUsage;
    } catch (e) {
      _logger.severe('Error getting max usage: $e');
      return _defaultMaxUsage;
    }
  }
  
  /// Vérifie si l'utilisateur a encore des utilisations disponibles
  Future<bool> hasUsageRemaining() async {
    final remaining = await getRemainingUsage();
    return remaining > 0;
  }
  
  /// Réinitialise le compteur d'utilisations (pour les tests)
  Future<bool> resetUsage() async {
    try {
      final deviceId = await DeviceFingerprintService.instance.getDeviceId();
      final user = _supabase.auth.currentUser;
      
      // Réinitialiser via Supabase
      final response = await _supabase.rpc('reset_usage', params: {
        'p_device_id': deviceId,
        'p_user_id': user?.id,
      });
      
      if (response != null && response['success'] == true) {
        // Réinitialiser le cache local
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove(_usageCountKey);
        await prefs.remove(_lastValidationKey);
        
        // Réinitialiser aussi le statut de l'appareil
        await DeviceFingerprintService.instance.resetDeviceFreemiumStatus();
        
        _logger.info('Usage reset via Supabase successfully');
        return true;
      } else {
        _logger.warning('Failed to reset usage via Supabase, falling back to local');
        return await _resetUsageLocally();
      }
    } catch (e) {
      _logger.severe('Error resetting usage: $e');
      _logger.info('Falling back to local reset');
      return await _resetUsageLocally();
    }
  }
  
  /// Réinitialise l'utilisation localement (fallback)
  Future<bool> _resetUsageLocally() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usageCountKey);
      await prefs.remove(_lastValidationKey);
      
      // Réinitialiser aussi le statut de l'appareil
      await DeviceFingerprintService.instance.resetDeviceFreemiumStatus();
      
      _logger.info('Usage counter and device status reset locally for testing');
      return true;
    } catch (e) {
      _logger.severe('Error resetting usage locally: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur est premium
  Future<bool> isPremium() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        return await hasUsageRemaining();
      }
      
      // TODO: Vérifier le statut premium dans la base de données
      // Pour l'instant, on considère que l'utilisateur connecté est premium
      return true;
    } catch (e) {
      _logger.severe('Error checking premium status: $e');
      return await hasUsageRemaining();
    }
  }
  
  /// Obtient des informations de debug sur l'état du service
  Future<Map<String, dynamic>> getDebugInfo() async {
    try {
      final deviceInfo = await DeviceFingerprintService.instance.getDeviceInfo();
      final remaining = await getRemainingUsage();
      final used = await getUsedUsage();
      final maxUsage = await getMaxUsage();
      final hasUsedFreemium = await DeviceFingerprintService.instance.hasDeviceUsedFreemium();
      
      return {
        'device_info': deviceInfo,
        'usage': {
          'remaining': remaining,
          'used': used,
          'max': maxUsage,
        },
        'freemium_status': {
          'has_used_freemium': hasUsedFreemium,
          'can_use_freemium': await _canDeviceUseFreemium(),
        },
        'user': {
          'is_authenticated': _supabase.auth.currentUser != null,
          'user_id': _supabase.auth.currentUser?.id,
        },
      };
    } catch (e) {
      _logger.severe('Error getting debug info: $e');
      return {'error': e.toString()};
    }
  }
}
