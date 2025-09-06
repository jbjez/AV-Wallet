import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:permission_handler/permission_handler.dart';
import 'ar_measure_unity_page.dart';
import '../utils/permissions.dart';

class ArMeasurePage extends StatefulWidget {
  const ArMeasurePage({Key? key}) : super(key: key);
  @override
  State<ArMeasurePage> createState() => _ArMeasurePageState();
}

class _ArMeasurePageState extends State<ArMeasurePage> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    // Debug log pour vérifier les permissions
    final camStatus = await Permission.camera.status;
    debugPrint('CAM status iOS: $camStatus');
    
    final ok = await AppPermissions.ensureCamera();
    if (mounted) {
      setState(() => _ready = ok);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mesure AR',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0A1128),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.home, color: Colors.white),
            onPressed: () => Navigator.of(context).pushReplacementNamed('/home'),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.camera_alt,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 20),
            const Text(
              'Mesure AR avec Unity',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Cette fonctionnalité utilise Unity pour les mesures AR',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _ready ? () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArMeasureUnityPage(),
                  ),
                );
              } : null,
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: const Text(
                'Lancer Unity AR',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueGrey[700],
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}