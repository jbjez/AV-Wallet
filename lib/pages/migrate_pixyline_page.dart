import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/catalogue_migration_service.dart';

class MigratePixylinePage extends ConsumerStatefulWidget {
  const MigratePixylinePage({super.key});

  @override
  ConsumerState<MigratePixylinePage> createState() => _MigratePixylinePageState();
}

class _MigratePixylinePageState extends ConsumerState<MigratePixylinePage> {
  bool _isLoading = false;
  String _status = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _migratePixyline() async {
    setState(() {
      _isLoading = true;
      _status = 'Migration en cours...';
      _logs.clear();
    });

    try {
      _addLog('Vérification des nouveaux articles...');
      
      // Vérifier s'il y a de nouveaux articles à migrer
      final needsMigration = await CatalogueMigrationService.needsNewCategoriesMigration();
      
      if (!needsMigration) {
        _addLog('✅ Aucun nouvel article à migrer');
        setState(() {
          _status = '✅ Aucune migration nécessaire';
          _isLoading = false;
        });
        return;
      }

      _addLog('Nouveaux articles détectés, démarrage de la migration...');
      
      // Obtenir le nombre d'éléments avant migration
      final beforeCount = await CatalogueMigrationService.getTotalItemCount();
      _addLog('Articles avant migration: $beforeCount');
      
      // Effectuer la migration
      await CatalogueMigrationService.migrateNewCategories();
      
      // Obtenir le nombre d'éléments après migration
      final afterCount = await CatalogueMigrationService.getTotalItemCount();
      final addedCount = afterCount - beforeCount;
      
      _addLog('Articles après migration: $afterCount');
      _addLog('Nouveaux articles ajoutés: $addedCount');
      
      // Obtenir les catégories existantes
      final categories = await CatalogueMigrationService.getExistingCategories();
      _addLog('Catégories disponibles: ${categories.join(', ')}');
      
      _addLog('✅ Migration terminée avec succès!');
      _addLog('🎯 Ayrton Pixyline 150 ajoutée au catalogue Hive');
      
      setState(() {
        _status = '✅ Migration réussie: +$addedCount articles';
        _isLoading = false;
      });
      
    } catch (e) {
      _addLog('❌ Erreur lors de la migration: $e');
      setState(() {
        _status = '❌ Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkStatus() async {
    setState(() {
      _logs.clear();
    });

    try {
      _addLog('Vérification du statut du catalogue...');
      
      final totalCount = await CatalogueMigrationService.getTotalItemCount();
      _addLog('Total d\'articles dans Hive: $totalCount');
      
      final categories = await CatalogueMigrationService.getExistingCategories();
      _addLog('Catégories disponibles: ${categories.length}');
      for (final category in categories) {
        _addLog('  • $category');
      }
      
      final needsMigration = await CatalogueMigrationService.needsNewCategoriesMigration();
      _addLog('Migration nécessaire: ${needsMigration ? "Oui" : "Non"}');
      
      _addLog('✅ Vérification terminée');
      
    } catch (e) {
      _addLog('❌ Erreur lors de la vérification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Migration Ayrton Pixyline 150'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Migration Ayrton Pixyline 150',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette page migre la nouvelle barre LED Ayrton Pixyline 150 vers la base de données Hive.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ayrton Pixyline 150',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text('• Catégorie: Lumière > Barre LED'),
                          Text('• Dimensions: 1 000 x 130 x 180 mm'),
                          Text('• Poids: 12 kg'),
                          Text('• Consommation: 600 W (Max)'),
                          Text('• Angle: 8° (Zoom jusqu\'à 32°)'),
                          Text('• Lux: 45 000 lx @ 5m (8°)'),
                          Text('• DMX: 10-57'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _migratePixyline,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Migrer'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _checkStatus,
                          child: const Text('Vérifier'),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _status,
                          style: TextStyle(
                            color: _status.contains('✅') 
                                ? Colors.green 
                                : _status.contains('❌') 
                                    ? Colors.red 
                                    : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logs de migration:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _logs.isEmpty
                    ? const Text(
                        'Aucun log pour le moment...',
                        style: TextStyle(color: Colors.grey),
                      )
                    : ListView.builder(
                        itemCount: _logs.length,
                        itemBuilder: (context, index) {
                          final log = _logs[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text(
                              log,
                              style: const TextStyle(
                                fontFamily: 'monospace',
                                fontSize: 12,
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


