import 'package:flutter/material.dart';
import '../services/son_replacement_service.dart';
import '../services/hive_service.dart';
import '../data/catalogue_data.dart';

class DebugSonMigrationPage extends StatefulWidget {
  const DebugSonMigrationPage({super.key});

  @override
  State<DebugSonMigrationPage> createState() => _DebugSonMigrationPageState();
}

class _DebugSonMigrationPageState extends State<DebugSonMigrationPage> {
  String _status = 'Prêt à analyser...';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _analyzeSonData() async {
    setState(() {
      _status = 'Analyse en cours...';
      _logs.clear();
    });

    try {
      _addLog('🚀 Début de l\'analyse des données SON...');
      
      // Analyser les données SON dans catalogue_data.dart
      final sonItems = catalogueData.where((item) => item.categorie == 'Son').toList();
      _addLog('📊 Items SON dans catalogue_data.dart: ${sonItems.length}');
      
      if (sonItems.isNotEmpty) {
        // Afficher les marques
        final brands = sonItems.map((item) => item.marque).toSet().toList()..sort();
        _addLog('🏷️ Marques: ${brands.join(', ')}');
        
        // Afficher les sous-catégories
        final subCategories = sonItems.map((item) => item.sousCategorie).toSet().toList()..sort();
        _addLog('📂 Sous-catégories: ${subCategories.join(', ')}');
        
        // Vérifier les doublons par ID
        final ids = sonItems.map((item) => item.id).toList();
        final uniqueIds = ids.toSet();
        if (ids.length != uniqueIds.length) {
          _addLog('⚠️ Doublons d\'ID détectés!');
          final duplicates = <String, int>{};
          for (final id in ids) {
            duplicates[id] = (duplicates[id] ?? 0) + 1;
          }
          duplicates.removeWhere((key, value) => value == 1);
          _addLog('Doublons: $duplicates');
        } else {
          _addLog('✅ Aucun doublon d\'ID trouvé');
        }
      }
      
      // Vérifier les données SON existantes dans Hive
      final box = await HiveService.getCatalogueBox();
      final existingSonItems = box.values.where((item) => item.categorie == 'Son').toList();
      _addLog('📈 Items SON existants dans Hive: ${existingSonItems.length}');
      
      if (existingSonItems.isNotEmpty) {
        final existingBrands = existingSonItems.map((item) => item.marque).toSet().toList()..sort();
        _addLog('🏷️ Marques existantes dans Hive: ${existingBrands.join(', ')}');
      }
      
      // Vérifier si le remplacement est nécessaire
      final needsReplacement = await SonReplacementService.needsReplacement();
      _addLog('🔄 Remplacement nécessaire: $needsReplacement');
      
      if (needsReplacement) {
        _addLog('⚠️ Les données SON doivent être mises à jour');
      } else {
        _addLog('✅ Les données SON sont à jour');
      }
      
      _addLog('🏁 Analyse terminée');
      setState(() {
        _status = 'Analyse terminée';
      });
      
    } catch (e, stackTrace) {
      _addLog('❌ Erreur lors de l\'analyse: $e');
      _addLog('Stack trace: $stackTrace');
      setState(() {
        _status = 'Erreur lors de l\'analyse';
      });
    }
  }

  Future<void> _migrateSonData() async {
    setState(() {
      _status = 'Migration en cours...';
    });

    try {
      _addLog('🚀 Début de la migration des données SON...');
      
      await SonReplacementService.replaceSonData();
      
      _addLog('✅ Migration terminée avec succès');
      
      // Vérifier le résultat
      final box = await HiveService.getCatalogueBox();
      final sonItems = box.values.where((item) => item.categorie == 'Son').toList();
      _addLog('📈 Total items SON dans la base: ${sonItems.length}');
      
      final brands = sonItems.map((item) => item.marque).toSet().toList()..sort();
      _addLog('🏷️ Marques disponibles: ${brands.join(', ')}');
      
      setState(() {
        _status = 'Migration terminée';
      });
      
    } catch (e, stackTrace) {
      _addLog('❌ Erreur lors de la migration: $e');
      _addLog('Stack trace: $stackTrace');
      setState(() {
        _status = 'Erreur lors de la migration';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Migration SON'),
        backgroundColor: Colors.blueGrey[900],
      ),
      backgroundColor: Colors.blueGrey[900],
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Status: $_status',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _analyzeSonData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Analyser les données SON'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _migrateSonData,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text('Migrer les données SON'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white24),
                ),
                child: ListView.builder(
                  itemCount: _logs.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Text(
                        _logs[index],
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontFamily: 'monospace',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}





