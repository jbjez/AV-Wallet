import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';
import 'secure_usage_service.dart';
import 'usage_service.dart';

/// Service de gestion d'accès quotidien (24h par utilisation)
class DailyAccessService {
  static const String _sessionStartKey = 'daily_session_start';
  static const String _sessionActiveKey = 'daily_session_active';
  static const String _lastActivityKey = 'daily_last_activity';
  static const int _sessionDurationHours = 24;
  
  final Logger _logger = Logger('DailyAccessService');
  static DailyAccessService? _instance;
  static DailyAccessService get instance => _instance ??= DailyAccessService._();
  
  DailyAccessService._();
  
  /// Initialise le service d'accès quotidien
  Future<void> initialize() async {
    _logger.info('Initializing DailyAccessService...');
    await _checkAndResetSessionIfNeeded();
  }
  
  /// Vérifie si une session de 24h est active
  Future<bool> hasActiveSession() async {
    try {
      await _checkAndResetSessionIfNeeded();
      
      final prefs = await SharedPreferences.getInstance();
      final sessionActive = prefs.getBool(_sessionActiveKey) ?? false;
      final sessionStart = prefs.getInt(_sessionStartKey) ?? 0;
      
      if (!sessionActive || sessionStart == 0) {
        return false;
      }
      
      // Vérifier si la session est encore valide (moins de 24h)
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceStart = (now - sessionStart) / (1000 * 60 * 60);
      
      if (hoursSinceStart >= _sessionDurationHours) {
        _logger.info('Session expired (24h), deactivating...');
        await _deactivateSession();
        return false;
      }
      
      _logger.info('Active session found, ${_sessionDurationHours - hoursSinceStart} hours remaining');
      return true;
    } catch (e) {
      _logger.severe('Error checking active session: $e');
      return false;
    }
  }
  
  /// Démarre une nouvelle session de 24h (consomme 1 utilisation)
  Future<bool> startNewSession() async {
    try {
      // Vérifier si l'utilisateur a encore des utilisations
      final remainingUsage = await SecureUsageService.instance.getRemainingUsage();
      if (remainingUsage <= 0) {
        _logger.warning('Cannot start new session - no remaining usage');
        return false;
      }
      
      // Vérifier si l'utilisateur est premium (accès illimité)
      final isPremium = await SecureUsageService.instance.isPremium();
      if (isPremium) {
        _logger.info('Premium user - unlimited access, no usage consumed');
        await _activateSession();
        return true;
      }
      
      // Consommer 1 utilisation pour démarrer la session
      final success = await UsageService.instance.incrementUsage();
      if (!success) {
        _logger.warning('Failed to consume usage for new session');
        return false;
      }
      
      // Activer la session de 24h
      await _activateSession();
      
      _logger.info('New 24h session started, usage consumed');
      return true;
    } catch (e) {
      _logger.severe('Error starting new session: $e');
      return false;
    }
  }
  
  /// Vérifie si l'utilisateur peut accéder à l'app (session active ou peut en démarrer une)
  Future<bool> canAccessApp() async {
    try {
      // Si une session est active, autoriser l'accès
      if (await hasActiveSession()) {
        return true;
      }
      
      // Si pas de session active, vérifier si on peut en démarrer une
      final remainingUsage = await SecureUsageService.instance.getRemainingUsage();
      final isPremium = await SecureUsageService.instance.isPremium();
      
      return remainingUsage > 0 || isPremium;
    } catch (e) {
      _logger.severe('Error checking app access: $e');
      return false;
    }
  }
  
  /// Active une session de 24h
  Future<void> _activateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now().millisecondsSinceEpoch;
      
      await prefs.setInt(_sessionStartKey, now);
      await prefs.setBool(_sessionActiveKey, true);
      await prefs.setInt(_lastActivityKey, now);
      
      _logger.info('24h session activated');
    } catch (e) {
      _logger.severe('Error activating session: $e');
    }
  }
  
  /// Désactive la session actuelle
  Future<void> _deactivateSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_sessionActiveKey, false);
      
      _logger.info('Session deactivated');
    } catch (e) {
      _logger.severe('Error deactivating session: $e');
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
  
  /// Vérifie et reset la session si nécessaire
  Future<void> _checkAndResetSessionIfNeeded() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStart = prefs.getInt(_sessionStartKey) ?? 0;
      
      if (sessionStart == 0) {
        return; // Pas de session à vérifier
      }
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceStart = (now - sessionStart) / (1000 * 60 * 60);
      
      // Si plus de 24h, désactiver la session
      if (hoursSinceStart >= _sessionDurationHours) {
        _logger.info('Session expired (${hoursSinceStart.toStringAsFixed(1)}h), deactivating...');
        await _deactivateSession();
      }
    } catch (e) {
      _logger.severe('Error checking session: $e');
    }
  }
  
  /// Obtient les informations de session
  Future<Map<String, dynamic>> getSessionInfo() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionStart = prefs.getInt(_sessionStartKey) ?? 0;
      final sessionActive = prefs.getBool(_sessionActiveKey) ?? false;
      final lastActivity = prefs.getInt(_lastActivityKey) ?? 0;
      
      final now = DateTime.now().millisecondsSinceEpoch;
      final hoursSinceStart = sessionStart > 0 ? (now - sessionStart) / (1000 * 60 * 60) : 0;
      final hoursSinceActivity = lastActivity > 0 ? (now - lastActivity) / (1000 * 60 * 60) : 0;
      final hoursRemaining = sessionActive ? (_sessionDurationHours - hoursSinceStart).clamp(0, _sessionDurationHours) : 0;
      
      return {
        'session_start': sessionStart,
        'session_active': sessionActive,
        'last_activity': lastActivity,
        'hours_since_start': hoursSinceStart,
        'hours_since_activity': hoursSinceActivity,
        'hours_remaining': hoursRemaining,
        'can_access_app': await canAccessApp(),
        'has_active_session': await hasActiveSession(),
      };
    } catch (e) {
      _logger.severe('Error getting session info: $e');
      return {};
    }
  }
  
  /// Force le démarrage d'une session (pour les tests)
  Future<void> forceStartSession() async {
    await _activateSession();
    _logger.info('Session force started for testing');
  }
  
  /// Reset complet du service (pour les tests)
  Future<void> reset() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_sessionStartKey);
      await prefs.remove(_sessionActiveKey);
      await prefs.remove(_lastActivityKey);
      
      _logger.info('DailyAccessService reset successfully');
    } catch (e) {
      _logger.severe('Error resetting DailyAccessService: $e');
    }
  }
}
