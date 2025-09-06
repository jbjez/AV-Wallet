import 'dart:async';
import 'dart:convert';

/// Service de cache en mémoire avec expiration automatique
class MemoryCacheService {
  static final MemoryCacheService _instance = MemoryCacheService._internal();
  factory MemoryCacheService() => _instance;
  MemoryCacheService._internal();

  final Map<String, _CacheItem> _cache = {};
  Timer? _cleanupTimer;

  /// Durée de vie par défaut des éléments en cache (2 minutes)
  static const Duration defaultTtl = Duration(minutes: 2);

  /// Stocker une valeur dans le cache
  void put<T>(String key, T value, {Duration? ttl}) {
    try {
      final expirationTime = DateTime.now().add(ttl ?? defaultTtl);
      
      // Sérialiser la valeur si c'est un objet complexe
      dynamic serializedValue = value;
      if (value is Map || value is List) {
        serializedValue = jsonEncode(value);
      }
      
      _cache[key] = _CacheItem(
        value: serializedValue,
        expirationTime: expirationTime,
      );
      
      // Démarrer le timer de nettoyage si ce n'est pas déjà fait
      _startCleanupTimer();
    } catch (e) {
      print('MemoryCacheService: Erreur lors de la sauvegarde de $key: $e');
    }
  }

  /// Récupérer une valeur du cache
  T? get<T>(String key) {
    try {
      final item = _cache[key];
      if (item == null) return null;
      
      // Vérifier si l'élément a expiré
      if (DateTime.now().isAfter(item.expirationTime)) {
        _cache.remove(key);
        return null;
      }
      
      // Désérialiser si nécessaire
      dynamic value = item.value;
      if (value is String && (T == Map || T == List)) {
        try {
          value = jsonDecode(value);
        } catch (e) {
          print('MemoryCacheService: Erreur lors de la désérialisation de $key: $e');
          return null;
        }
      }
      
      return value as T?;
    } catch (e) {
      print('MemoryCacheService: Erreur lors de la récupération de $key: $e');
      return null;
    }
  }

  /// Vérifier si une clé existe et n'a pas expiré
  bool containsKey(String key) {
    final item = _cache[key];
    if (item == null) return false;
    
    if (DateTime.now().isAfter(item.expirationTime)) {
      _cache.remove(key);
      return false;
    }
    
    return true;
  }

  /// Supprimer une clé du cache
  void remove(String key) {
    _cache.remove(key);
  }

  /// Vider tout le cache
  void clear() {
    _cache.clear();
  }

  /// Démarrer le timer de nettoyage automatique
  void _startCleanupTimer() {
    if (_cleanupTimer?.isActive == true) return;
    
    _cleanupTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _cleanupExpiredItems();
    });
  }

  /// Nettoyer les éléments expirés
  void _cleanupExpiredItems() {
    final now = DateTime.now();
    final expiredKeys = _cache.entries
        .where((entry) => now.isAfter(entry.value.expirationTime))
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _cache.remove(key);
    }
  }

  /// Arrêter le timer de nettoyage
  void dispose() {
    _cleanupTimer?.cancel();
    _cleanupTimer = null;
  }
}

/// Élément de cache avec expiration
class _CacheItem {
  final dynamic value;
  final DateTime expirationTime;

  _CacheItem({
    required this.value,
    required this.expirationTime,
  });
}

/// Clés de cache pour les différentes pages
class CacheKeys {
  static const String lightPageState = 'light_page_state';
  static const String videoPageState = 'video_page_state';
  static const String soundPageState = 'sound_page_state';
  static const String electricityPageState = 'electricity_page_state';
  static const String structurePageState = 'structure_page_state';
  static const String catalogueSearch = 'catalogue_search';
  static const String catalogueFilters = 'catalogue_filters';
}
