import 'package:flutter/material.dart';
import '../services/unity_dynamic_service.dart';

class UnityDemoPage extends StatefulWidget {
  const UnityDemoPage({super.key});

  @override
  State<UnityDemoPage> createState() => _UnityDemoPageState();
}

class _UnityDemoPageState extends State<UnityDemoPage> {
  final UnityDynamicService _unityService = UnityDynamicService.instance;
  bool _isLoading = false;
  String _status = 'Unity non chargé';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Unity Dynamique'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status Unity',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _status,
                      style: TextStyle(
                        color: _unityService.isUnityLoaded ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Boutons de contrôle
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _loadUnity,
              icon: _isLoading 
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.download),
              label: Text(_isLoading ? 'Chargement...' : 'Charger Unity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _unityService.isUnityLoaded ? _showUnity : null,
              icon: const Icon(Icons.play_arrow),
              label: const Text('Afficher Unity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _unityService.isUnityLoaded ? _hideUnity : null,
              icon: const Icon(Icons.pause),
              label: const Text('Masquer Unity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _unityService.isUnityLoaded ? _getUnityVersion : null,
              icon: const Icon(Icons.info),
              label: const Text('Version Unity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 12),
            
            ElevatedButton.icon(
              onPressed: _unityService.isUnityLoaded ? _unloadUnity : null,
              icon: const Icon(Icons.stop),
              label: const Text('Décharger Unity'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Instructions
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Instructions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. Cliquez sur "Charger Unity" pour charger le framework Unity\n'
                      '2. Utilisez "Afficher Unity" pour lancer l\'expérience AR\n'
                      '3. "Masquer Unity" pour revenir à l\'app Flutter\n'
                      '4. "Décharger Unity" pour libérer la mémoire',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _loadUnity() async {
    setState(() {
      _isLoading = true;
      _status = 'Chargement d\'Unity...';
    });

    try {
      final success = await _unityService.loadUnity();
      setState(() {
        _status = success ? 'Unity chargé avec succès' : 'Échec du chargement d\'Unity';
      });
    } catch (e) {
      setState(() {
        _status = 'Erreur: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showUnity() async {
    await _unityService.showUnity();
    setState(() {
      _status = 'Unity affiché';
    });
  }

  Future<void> _hideUnity() async {
    await _unityService.hideUnity();
    setState(() {
      _status = 'Unity masqué';
    });
  }

  Future<void> _getUnityVersion() async {
    final version = await _unityService.getUnityVersion();
    setState(() {
      _status = 'Version Unity: ${version ?? 'Inconnue'}';
    });
  }

  Future<void> _unloadUnity() async {
    await _unityService.unloadUnity();
    setState(() {
      _status = 'Unity déchargé';
    });
  }
}
