// Unity wrapper pour éviter les conflits avec flutter_unity_widget
// Ce fichier permet d'utiliser Unity sans le plugin problématique

import 'package:flutter/material.dart';

/// Widget Unity simulé qui utilise notre bridge natif
class UnityWidget extends StatefulWidget {
  final Function(UnityWidgetController)? onUnityCreated;
  final Function(UnityWidgetController)? onUnityMessage;
  
  const UnityWidget({
    Key? key,
    this.onUnityCreated,
    this.onUnityMessage,
  }) : super(key: key);

  @override
  State<UnityWidget> createState() => _UnityWidgetState();
}

class _UnityWidgetState extends State<UnityWidget> {
  @override
  void initState() {
    super.initState();
    // Simuler la création du contrôleur Unity
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.onUnityCreated != null) {
        widget.onUnityCreated!(UnityWidgetController());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: const Center(
        child: Text(
          'Unity AR Measure\n(Bridge natif activé)',
          style: TextStyle(color: Colors.white, fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

/// Contrôleur Unity simulé
class UnityWidgetController {
  /// Envoyer un message à Unity
  Future<void> postMessage(String gameObject, String methodName, String message) async {
    print('Unity: Message envoyé à $gameObject.$methodName: $message (simulation)');
  }
  
  /// Pause Unity
  Future<void> pause() async {
    print('Unity: Pause (simulation)');
  }
  
  /// Resume Unity
  Future<void> resume() async {
    print('Unity: Resume (simulation)');
  }
  
  /// Dispose Unity
  void dispose() {
    print('Unity: Dispose (simulation)');
  }
}
