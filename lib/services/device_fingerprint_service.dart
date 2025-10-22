import 'dart:io';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:logging/logging.dart';

class DeviceFingerprintService {
  static const String _deviceIdKey = 'device_id';
  
  final Logger _logger = Logger('DeviceFingerprintService');
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  
  static DeviceFingerprintService? _instance;
  static DeviceFingerprintService get instance => _instance ??= DeviceFingerprintService._();
  
  DeviceFingerprintService._();
  
  /// Génère un fingerprint unique pour l'appareil
  Future<String> generateDeviceFingerprint() async {
    try {
      final Map<String, dynamic> deviceData = {};
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceData.addAll({
          'platform': 'android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'device': androidInfo.device,
          'product': androidInfo.product,
          'hardware': androidInfo.hardware,
          'manufacturer': androidInfo.manufacturer,
          'board': androidInfo.board,
          'bootloader': androidInfo.bootloader,
          'deviceId': androidInfo.id,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceData.addAll({
          'platform': 'ios',
          'name': iosInfo.name,
          'model': iosInfo.model,
          'systemName': iosInfo.systemName,
          'systemVersion': iosInfo.systemVersion,
          'localizedModel': iosInfo.localizedModel,
          'identifierForVendor': iosInfo.identifierForVendor,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        });
      } else if (Platform.isMacOS) {
        final macInfo = await _deviceInfo.macOsInfo;
        deviceData.addAll({
          'platform': 'macos',
          'model': macInfo.model,
          'hostName': macInfo.hostName,
          'computerName': macInfo.computerName,
          'systemGUID': macInfo.systemGUID,
        });
      } else if (Platform.isWindows) {
        final windowsInfo = await _deviceInfo.windowsInfo;
        deviceData.addAll({
          'platform': 'windows',
          'computerName': windowsInfo.computerName,
          'numberOfCores': windowsInfo.numberOfCores,
          'systemMemoryInMegabytes': windowsInfo.systemMemoryInMegabytes,
        });
      }
      
      // Ajouter des données supplémentaires pour plus de sécurité
      deviceData.addAll({
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'appVersion': '1.0.0', // Récupérer depuis pubspec.yaml
      });
      
      // Créer un hash unique du fingerprint
      final jsonString = jsonEncode(deviceData);
      final bytes = utf8.encode(jsonString);
      final digest = sha256.convert(bytes);
      
      final fingerprint = digest.toString();
      _logger.info('Device fingerprint generated: ${fingerprint.substring(0, 8)}...');
      
      return fingerprint;
    } catch (e) {
      _logger.severe('Error generating device fingerprint: $e');
      // Fallback: utiliser un fingerprint basique
      return _generateFallbackFingerprint();
    }
  }
  
  /// Génère un fingerprint de fallback en cas d'erreur
  String _generateFallbackFingerprint() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = timestamp.toString().hashCode;
    return 'fallback_${random.abs()}';
  }
  
  /// Récupère ou génère l'ID de l'appareil
  Future<String> getDeviceId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      
      if (deviceId == null) {
        deviceId = await generateDeviceFingerprint();
        await prefs.setString(_deviceIdKey, deviceId);
        _logger.info('New device ID generated and saved');
      } else {
        _logger.info('Existing device ID retrieved');
      }
      
      return deviceId;
    } catch (e) {
      _logger.severe('Error getting device ID: $e');
      return _generateFallbackFingerprint();
    }
  }
  
  /// Vérifie si l'appareil a déjà utilisé le freemium
  Future<bool> hasDeviceUsedFreemium() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await getDeviceId();
      final usedDevices = prefs.getStringList('used_devices') ?? [];
      
      return usedDevices.contains(deviceId);
    } catch (e) {
      _logger.severe('Error checking freemium usage: $e');
      return false;
    }
  }
  
  /// Marque l'appareil comme ayant utilisé le freemium
  Future<bool> markDeviceAsUsed() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await getDeviceId();
      final usedDevices = prefs.getStringList('used_devices') ?? [];
      
      if (!usedDevices.contains(deviceId)) {
        usedDevices.add(deviceId);
        await prefs.setStringList('used_devices', usedDevices);
        _logger.info('Device marked as used for freemium');
        return true;
      }
      
      return false; // Déjà marqué
    } catch (e) {
      _logger.severe('Error marking device as used: $e');
      return false;
    }
  }
  
  /// Réinitialise le statut freemium de l'appareil (pour les tests)
  Future<bool> resetDeviceFreemiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceId = await getDeviceId();
      final usedDevices = prefs.getStringList('used_devices') ?? [];
      
      usedDevices.remove(deviceId);
      await prefs.setStringList('used_devices', usedDevices);
      
      // Réinitialiser aussi le compteur d'utilisations
      await prefs.remove('premium_usage_count');
      
      _logger.info('Device freemium status reset for testing');
      return true;
    } catch (e) {
      _logger.severe('Error resetting device freemium status: $e');
      return false;
    }
  }
  
  /// Obtient des informations détaillées sur l'appareil (pour debug)
  Future<Map<String, dynamic>> getDeviceInfo() async {
    try {
      final Map<String, dynamic> deviceInfo = {};
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        deviceInfo.addAll({
          'platform': 'Android',
          'model': androidInfo.model,
          'brand': androidInfo.brand,
          'version': androidInfo.version.release,
          'sdkInt': androidInfo.version.sdkInt,
          'isPhysicalDevice': androidInfo.isPhysicalDevice,
        });
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        deviceInfo.addAll({
          'platform': 'iOS',
          'model': iosInfo.model,
          'name': iosInfo.name,
          'version': iosInfo.systemVersion,
          'isPhysicalDevice': iosInfo.isPhysicalDevice,
        });
      }
      
      deviceInfo['deviceId'] = await getDeviceId();
      deviceInfo['hasUsedFreemium'] = await hasDeviceUsedFreemium();
      
      return deviceInfo;
    } catch (e) {
      _logger.severe('Error getting device info: $e');
      return {'error': e.toString()};
    }
  }
}
