import 'package:permission_handler/permission_handler.dart';

class AppPermissions {
  static Future<bool> ensureCamera() async {
    final s = await Permission.camera.status;
    if (s.isGranted) return true;
    final r = await Permission.camera.request();
    if (r.isGranted) return true;
    if (r.isPermanentlyDenied) await openAppSettings();
    return false;
  }

  static Future<bool> ensureMicrophone() async {
    final s = await Permission.microphone.status;
    if (s.isGranted) return true;
    final r = await Permission.microphone.request();
    if (r.isGranted) return true;
    if (r.isPermanentlyDenied) await openAppSettings();
    return false;
  }
}