import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/catalogue_migration_service.dart';

class MigrateRegieArticlesPage extends ConsumerStatefulWidget {
  const MigrateRegieArticlesPage({super.key});

  @override
  ConsumerState<MigrateRegieArticlesPage> createState() => _MigrateRegieArticlesPageState();
}

class _MigrateRegieArticlesPageState extends ConsumerState<MigrateRegieArticlesPage> {
  bool _isLoading = false;
  String _status = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _migrateRegieArticles() async {
    setState(() {
      _isLoading = true;
      _status = 'Migration en cours...';
      _logs.clear();
    });

    try {
      _addLog('Vérification des nouveaux articles de régie...');
      
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
      _addLog('🎯 Articles de régie ajoutés au catalogue Hive');
      
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
        title: const Text('Migration Articles Régie'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
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
                      'Migration Articles de Régie Son',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette page migre les nouveaux articles de régie son vers la base de données Hive.',
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
                            'Nouveaux articles de régie:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('🎛️ Yamaha CL1 - Console numérique compacte'),
                          Text('🎛️ Yamaha RIO 1608-D2 - Stagebox 16 entrées'),
                          Text('🎛️ Yamaha RIO 3224-D2 - Stagebox 32 entrées'),
                          Text('🎛️ Midas M32R Live - Console 40 entrées'),
                          Text('🎛️ Midas MR18 - Rack numérique 18 entrées'),
                          Text('🎛️ Allen & Heath dLive S5000 - Surface de mixage'),
                          Text('🎛️ Allen & Heath dLive S7000 - Grande surface'),
                          Text('🎛️ Midas M32 Live - Console numérique'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _migrateRegieArticles,
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
            Container(
              height: 300, // Hauteur fixe pour les logs
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
            const SizedBox(height: 16), // Espace en bas pour éviter le débordement
          ],
        ),
      ),
    );
  }
}
