import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// 🎮 Service Unity pour la communication Flutter ↔ Unity
/// Ce service utilise MethodChannel pour communiquer avec UnityBridge.swift
class UnityService {
  static const MethodChannel _channel = MethodChannel('unity_bridge');
  
  /// Singleton instance
  static final UnityService _instance = UnityService._internal();
  factory UnityService() => _instance;
  UnityService._internal();
  
  /// Affiche Unity en plein écran
  Future<void> showUnity() async {
    try {
      print('🎮 Flutter: Demande d\'affichage Unity');
      await _channel.invokeMethod('showUnity');
      print('✅ Flutter: Unity affiché avec succès');
    } catch (e) {
      print('❌ Flutter: Erreur lors de l\'affichage Unity: $e');
      rethrow;
    }
  }
  
  /// Cache Unity et retourne à Flutter
  Future<void> hideUnity() async {
    try {
      print('🎮 Flutter: Demande de masquage Unity');
      await _channel.invokeMethod('hideUnity');
      print('✅ Flutter: Unity masqué avec succès');
    } catch (e) {
      print('❌ Flutter: Erreur lors du masquage Unity: $e');
      rethrow;
    }
  }
  
  /// Envoie un message à Unity
  Future<void> sendMessageToUnity({
    required String gameObject,
    required String method,
    required String message,
  }) async {
    try {
      print('🎮 Flutter: Envoi message à Unity: $gameObject.$method("$message")');
      await _channel.invokeMethod('sendMessage', {
        'gameObject': gameObject,
        'method': method,
        'message': message,
      });
      print('✅ Flutter: Message envoyé à Unity');
    } catch (e) {
      print('❌ Flutter: Erreur lors de l\'envoi du message: $e');
      rethrow;
    }
  }
  
  /// Vérifie si Unity est chargé
  Future<bool> isUnityLoaded() async {
    try {
      final result = await _channel.invokeMethod('isUnityLoaded');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ Flutter: Erreur lors de la vérification du statut Unity: $e');
      return false;
    }
  }
  
  /// Vérifie si Unity est visible
  Future<bool> isUnityVisible() async {
    try {
      final result = await _channel.invokeMethod('isUnityVisible');
      return result as bool? ?? false;
    } catch (e) {
      print('❌ Flutter: Erreur lors de la vérification de la visibilité Unity: $e');
      return false;
    }
  }
  
  /// Pause/Reprend Unity
  Future<void> pauseUnity(bool pause) async {
    try {
      print('🎮 Flutter: ${pause ? "Pause" : "Reprise"} Unity');
      await _channel.invokeMethod('pauseUnity', {'pause': pause});
      print('✅ Flutter: Unity ${pause ? "pausé" : "repris"}');
    } catch (e) {
      print('❌ Flutter: Erreur lors de la ${pause ? "pause" : "reprise"} Unity: $e');
      rethrow;
    }
  }
  
  /// Méthodes spécifiques pour la mesure AR
  
  /// Démarre la mesure AR
  Future<void> startARMeasurement() async {
    await sendMessageToUnity(
      gameObject: 'ARMeasureController',
      method: 'StartMeasurement',
      message: 'start',
    );
  }
  
  /// Arrête la mesure AR
  Future<void> stopARMeasurement() async {
    await sendMessageToUnity(
      gameObject: 'ARMeasureController',
      method: 'StopMeasurement',
      message: 'stop',
    );
  }
  
  /// Reset la mesure AR
  Future<void> resetARMeasurement() async {
    await sendMessageToUnity(
      gameObject: 'ARMeasureController',
      method: 'ResetMeasurement',
      message: 'reset',
    );
  }
  
  /// Sélectionne un type d'objet
  Future<void> selectObjectType(String objectType) async {
    await sendMessageToUnity(
      gameObject: 'ARMeasureController',
      method: 'SelectObjectType',
      message: objectType,
    );
  }
}

/// Provider Riverpod pour UnityService
final unityServiceProvider = Provider<UnityService>((ref) {
  return UnityService();
});

/// Provider pour le statut Unity
final unityStatusProvider = FutureProvider<bool>((ref) async {
  final unityService = ref.read(unityServiceProvider);
  return await unityService.isUnityLoaded();
});

/// Provider pour la visibilité Unity
final unityVisibilityProvider = FutureProvider<bool>((ref) async {
  final unityService = ref.read(unityServiceProvider);
  return await unityService.isUnityVisible();
});
