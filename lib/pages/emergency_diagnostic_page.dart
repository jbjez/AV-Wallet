import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/emergency_catalogue_restore.dart';
import '../providers/catalogue_provider.dart';

class EmergencyDiagnosticPage extends ConsumerStatefulWidget {
  const EmergencyDiagnosticPage({super.key});

  @override
  ConsumerState<EmergencyDiagnosticPage> createState() => _EmergencyDiagnosticPageState();
}

class _EmergencyDiagnosticPageState extends ConsumerState<EmergencyDiagnosticPage> {
  bool _isRestoring = false;
  Map<String, dynamic>? _status;
  String _log = '';

  @override
  void initState() {
    super.initState();
    _checkStatus();
  }

  Future<void> _checkStatus() async {
    setState(() {
      _log += '🔍 Vérification de l\'état du catalogue...\n';
    });

    final status = await EmergencyCatalogueRestore.getDetailedStatus();
    setState(() {
      _status = status;
      _log += '📊 État actuel: ${status['totalItems']} items\n';
      _log += '📂 Catégories: ${status['categories'].join(', ')}\n';
      _log += '🏷️ Marques: ${status['brands'].length}\n';
    });
  }

  Future<void> _forceEmergencyRestore() async {
    setState(() {
      _isRestoring = true;
      _log += '\n🚨 DÉMARRAGE DE LA RESTAURATION D\'URGENCE...\n';
    });

    try {
      // Forcer la restauration
      final restoredItems = await EmergencyCatalogueRestore.emergencyRestore();
      
      setState(() {
        _log += '✅ RESTAURATION TERMINÉE: ${restoredItems.length} items\n';
      });

      // Recharger le provider
      ref.invalidate(catalogueProvider);
      await ref.read(catalogueProvider.notifier).loadCatalogue();
      
      // Vérifier le nouveau statut
      await _checkStatus();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('🎉 CATALOGUE RESTAURÉ: ${restoredItems.length} produits !'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _log += '❌ ERREUR: $e\n';
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Erreur: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isRestoring = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🚨 DIAGNOSTIC URGENCE'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'DIAGNOSTIC DU CATALOGUE',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.red),
            ),
            const SizedBox(height: 20),
            
            if (_status != null) ...[
              Card(
                color: _status!['totalItems'] > 0 ? Colors.green.shade50 : Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '📊 ÉTAT ACTUEL',
                        style: TextStyle(
                          fontSize: 18, 
                          fontWeight: FontWeight.bold,
                          color: _status!['totalItems'] > 0 ? Colors.green : Colors.red,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text('Total d\'items: ${_status!['totalItems']}', 
                           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      Text('Catégories: ${_status!['categories'].join(', ')}'),
                      const SizedBox(height: 8),
                      Text('Marques: ${_status!['brands'].length}'),
                      const SizedBox(height: 8),
                      Text('Vide: ${_status!['isEmpty'] ? 'OUI ❌' : 'NON ✅'}'),
                      if (_status!['categoryCounts'] != null) ...[
                        const SizedBox(height: 8),
                        const Text('Détail par catégorie:'),
                        ..._status!['categoryCounts'].entries.map((e) => 
                          Text('  • ${e.key}: ${e.value} items')),
                      ],
                    ],
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 20),
            const Text(
              'ACTIONS D\'URGENCE',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            ElevatedButton(
              onPressed: _isRestoring ? null : _forceEmergencyRestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 60),
              ),
              child: _isRestoring
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(color: Colors.white),
                        SizedBox(width: 16),
                        Text('RESTAURATION EN COURS...'),
                      ],
                    )
                  : const Text('🚨 RESTAURER LE CATALOGUE', 
                               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _checkStatus,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('🔄 Vérifier l\'état'),
            ),
            
            const SizedBox(height: 20),
            const Text(
              'LOGS',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              height: 200,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _log.isEmpty ? 'Aucun log pour le moment...' : _log,
                  style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushReplacementNamed('/catalogue');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('📱 Aller au Catalogue'),
            ),
          ],
        ),
      ),
    );
  }
}
