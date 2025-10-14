import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'secure_usage_service.dart';

class SessionUsageService {
  static const String _sessionStartKey = 'session_start_time';
  static const String _sessionUsageKey = 'session_usage_count';
  static const String _lastActivityKey = 'last_activity_time';
  
  final Logger _logger = Logger('SessionUsageService');
  static SessionUsageService? _instance;
  static SessionUsageService get instance => _instance ??= SessionUsageService._();
  
  SessionUsageService._();
  
  /// Initialise le service de session
  Future<void> initialize() async {
    _logger.info('Initializing SessionUsageService...');
    await _checkAndResetSessionIfNeeded();
  }
  
  /// Vérifie et reset la session si nécessaire (24h d'inactivité)
  Future<void> _checkAndResetSessionIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceLastActivity = (now - lastActivity) / (1000 * 60 * 60);
      
      // Si plus de 24h d'inactivité, reset la session
      if (hoursSinceLastActivity >= 24) {
        _logger.info('Session expired (24h inactivity), resetting...');
        await _resetSession();
      }
    } catch (e) {
      _logger.severe('Error checking session: $e');
    }
  }
  
  /// Marque le début d'une nouvelle session
  Future<void> startNewSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setInt(_sessionStartKey, now);
      await prefs.setInt(_sessionUsageKey, 0);
      await prefs.setInt(_lastActivityKey, now);
      
      _logger.info('New session started');
    } catch (e) {
      _logger.severe('Error starting new session: $e');
    }
  }
  
  /// Marque une activité utilisateur
  Future<void> markActivity() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      await prefs.setInt(_lastActivityKey, now);
    } catch (e) {
      _logger.severe('Error marking activity: $e');
    }
  }
  
  /// Vérifie si l'utilisateur peut utiliser une fonctionnalité premium
  Future<bool> canUsePremiumFeature() async {
    try {
      await _checkAndResetSessionIfNeeded();
      
      final prefs = await SharedPreferences.getInstance();
      final sessionUsage = prefs.getInt(_sessionUsageKey) ?? 0;
      
      // Vérifier avec le système freemium global
      final remainingUsage = await SecureUsageService.instance.getRemainingUsage();
      
      if (remainingUsage <= 0) {
        _logger.info('No remaining freemium usage available');
        return false;
      }
      
      // Pour les utilisateurs premium, autoriser sans limite
      final isPremium = await SecureUsageService.instance.isPremium();
      if (isPremium) {
        _logger.info('Premium user, access granted');
        return true;
      }
      
      // Pour les utilisateurs freemium, vérifier la session
      if (sessionUsage >= 1) {
        _logger.info('Session usage limit reached (1 per session)');
        return false;
      }
      
      return true;
    } catch (e) {
      _logger.severe('Error checking premium feature access: $e');
      return false;
    }
  }
  
  /// Utilise une fonctionnalité premium (décompte de session)
  Future<bool> usePremiumFeature() async {
    try {
      if (!await canUsePremiumFeature()) {
        return false;
      }
      
      final prefs = await SharedPreferences.getInstance();
      final sessionUsage = prefs.getInt(_sessionUsageKey) ?? 0;
      
      // Marquer l'utilisation dans la session
      await prefs.setInt(_sessionUsageKey, sessionUsage + 1);
      await markActivity();
      
      // Décompter dans le système freemium global
      final success = await SecureUsageService.instance.incrementUsage();
      
      if (success) {
        _logger.info('Premium feature used successfully (session: ${sessionUsage + 1})');
      }
      
      return success;
    } catch (e) {
      _logger.severe('Error using premium feature: $e');
      return false;
    }
  }
  
  /// Reset la session (déconnexion)
  Future<void> resetSession() async {
    await _resetSession();
  }
  
  /// Reset interne de la session
  Future<void> _resetSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionStartKey);
      await prefs.remove(_sessionUsageKey);
      await prefs.remove(_lastActivityKey);
      
      _logger.info('Session reset successfully');
    } catch (e) {
      _logger.severe('Error resetting session: $e');
    }
  }
  
  /// Obtient les informations de session
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStart = prefs.getInt(_sessionStartKey) ?? 0;
      final sessionUsage = prefs.getInt(_sessionUsageKey) ?? 0;
      final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final sessionDuration = sessionStart > 0 ? (now - sessionStart) / (1000 * 60 * 60) : 0;
      final hoursSinceActivity = lastActivity > 0 ? (now - lastActivity) / (1000 * 60 * 60) : 0;
      
      return {
        'session_start': sessionStart,
        'session_usage': sessionUsage,
        'last_activity': lastActivity,
        'session_duration_hours': sessionDuration,
        'hours_since_activity': hoursSinceActivity,
        'can_use_premium': await canUsePremiumFeature(),
      };
    } catch (e) {
      _logger.severe('Error getting session info: $e');
      return {};
    }
  }
}


