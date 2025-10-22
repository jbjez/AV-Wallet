import 'dart:io';
import 'package:flutter/services.dart';

/// Service pour charger Unity dynamiquement
class UnityDynamicService {
  static const MethodChannel _channel = MethodChannel('unity_dynamic');
  
  static UnityDynamicService? _instance;
  static UnityDynamicService get instance => _instance ??= UnityDynamicService._();
  
  UnityDynamicService._();
  
  bool _isUnityLoaded = false;
  bool get isUnityLoaded => _isUnityLoaded;
  
  /// Charger Unity dynamiquement
  Future<bool> loadUnity() async {
    if (_isUnityLoaded) return true;
    
    try {
      if (Platform.isIOS) {
        // Sur iOS, charger le framework Unity
        final result = await _channel.invokeMethod('loadUnity');
        _isUnityLoaded = result == true;
        
        if (_isUnityLoaded) {
          print('✅ Unity chargé avec succès sur iOS');
        } else {
          print('❌ Échec du chargement d\'Unity sur iOS');
        }
      } else if (Platform.isAndroid) {
        // Sur Android, charger la librairie Unity
        final result = await _channel.invokeMethod('loadUnity');
        _isUnityLoaded = result == true;
        
        if (_isUnityLoaded) {
          print('✅ Unity chargé avec succès sur Android');
        } else {
          print('❌ Échec du chargement d\'Unity sur Android');
        }
      }
      
      return _isUnityLoaded;
    } catch (e) {
      print('❌ Erreur lors du chargement d\'Unity: $e');
      return false;
    }
  }
  
  /// Afficher Unity
  Future<void> showUnity() async {
    if (!_isUnityLoaded) {
      print('❌ Unity n\'est pas chargé');
      return;
    }
    
    try {
      await _channel.invokeMethod('showUnity');
      print('🎮 Unity affiché');
    } catch (e) {
      print('❌ Erreur lors de l\'affichage d\'Unity: $e');
    }
  }
  
  /// Masquer Unity
  Future<void> hideUnity() async {
    if (!_isUnityLoaded) {
      print('❌ Unity n\'est pas chargé');
      return;
    }
    
    try {
      await _channel.invokeMethod('hideUnity');
      print('🎮 Unity masqué');
    } catch (e) {
      print('❌ Erreur lors du masquage d\'Unity: $e');
    }
  }
  
  /// Décharger Unity
  Future<void> unloadUnity() async {
    if (!_isUnityLoaded) return;
    
    try {
      await _channel.invokeMethod('unloadUnity');
      _isUnityLoaded = false;
      print('🎮 Unity déchargé');
    } catch (e) {
      print('❌ Erreur lors du déchargement d\'Unity: $e');
    }
  }
  
  /// Obtenir la version d'Unity
  Future<String?> getUnityVersion() async {
    if (!_isUnityLoaded) return null;
    
    try {
      final version = await _channel.invokeMethod('getUnityVersion');
      return version?.toString();
    } catch (e) {
      print('❌ Erreur lors de la récupération de la version d\'Unity: $e');
      return null;
    }
  }
}
