import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../services/emergency_catalogue_restore.dart';

class TestCataloguePage extends ConsumerStatefulWidget {
  const TestCataloguePage({super.key});

  @override
  ConsumerState<TestCataloguePage> createState() => _TestCataloguePageState();
}

class _TestCataloguePageState extends ConsumerState<TestCataloguePage> {
  String _log = '';

  void _addLog(String message) {
    setState(() {
      _log += '${DateTime.now().toString().substring(11, 19)}: $message\n';
    });
  }

  Future<void> _testRestore() async {
    _addLog('🚀 Début du test de restauration...');
    
    try {
      // Vérifier l'état actuel
      final currentItems = ref.read(catalogueProvider);
      _addLog('📊 Items actuels: ${currentItems.length}');
      
      // Forcer la restauration
      _addLog('🔄 Lancement de la restauration...');
      final restoredItems = await EmergencyCatalogueRestore.emergencyRestore();
      _addLog('✅ Restauration terminée: ${restoredItems.length} items');
      
      // Recharger le provider
      _addLog('🔄 Rechargement du provider...');
      ref.invalidate(catalogueProvider);
      await ref.read(catalogueProvider.notifier).loadCatalogue();
      
      // Vérifier le nouveau état
      final newItems = ref.read(catalogueProvider);
      _addLog('📊 Nouveaux items: ${newItems.length}');
      
      if (newItems.isNotEmpty) {
        _addLog('🎉 SUCCÈS ! Catalogue restauré avec ${newItems.length} produits');
        _addLog('📂 Première catégorie: ${newItems.first.categorie}');
        _addLog('🏷️ Première marque: ${newItems.first.marque}');
      } else {
        _addLog('❌ ÉCHEC: Aucun item trouvé après restauration');
      }
      
    } catch (e, stackTrace) {
      _addLog('❌ ERREUR: $e');
      _addLog('📋 Stack: ${stackTrace.toString().substring(0, 200)}...');
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(catalogueProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Catalogue'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'État actuel: ${items.length} items',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _testRestore,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('🧪 TESTER LA RESTAURATION', 
                               style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
            const SizedBox(height: 20),
            const Text('Logs:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(
              child: Container(
                width: double.infinity,
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
            ),
          ],
        ),
      ),
    );
  }
}
