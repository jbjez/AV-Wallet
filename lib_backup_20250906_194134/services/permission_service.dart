import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Demande la permission microphone et gère les cas de refus permanent
  static Future<bool> ensureMicPermission() async {
    final status = await Permission.microphone.status;
    
    if (status.isGranted) {
      print('Permission microphone déjà accordée');
      return true;
    }

    print('Demande de permission microphone...');
    final result = await Permission.microphone.request();
    
    if (result.isGranted) {
      print('Permission microphone accordée');
      return true;
    }

    if (result.isPermanentlyDenied) {
      print('Permission microphone définitivement refusée - redirection vers paramètres');
      await openAppSettings();
    } else {
      print('Permission microphone refusée');
    }
    
    return false;
  }

  /// Demande la permission caméra et gère les cas de refus permanent
  static Future<bool> ensureCameraPermission() async {
    final status = await Permission.camera.status;
    
    if (status.isGranted) {
      print('Permission caméra déjà accordée');
      return true;
    }

    print('Demande de permission caméra...');
    final result = await Permission.camera.request();
    
    if (result.isGranted) {
      print('Permission caméra accordée');
      return true;
    }

    if (result.isPermanentlyDenied) {
      print('Permission caméra définitivement refusée - redirection vers paramètres');
      await openAppSettings();
    } else {
      print('Permission caméra refusée');
    }
    
    return false;
  }

  /// Vérifie le statut actuel des permissions
  static Future<Map<String, PermissionStatus>> getPermissionStatus() async {
    return {
      'microphone': await Permission.microphone.status,
      'camera': await Permission.camera.status,
    };
  }
}


