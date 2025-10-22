import 'package:flutter/material.dart';
import '../services/catalogue_dmx_migration_service.dart';
import '../services/hive_service.dart';

/// Script pour exécuter la migration des données DMX et nouveaux produits
class RunDmxMigration {
  static Future<void> runMigration() async {
    try {
      print('🚀 Starting DMX data and new products migration...');
      
      // Initialiser Hive
      await HiveService.init();
      
      // Vérifier si la migration est nécessaire
      final needsMigration = await CatalogueDmxMigrationService.needsDmxMigration();
      
      if (!needsMigration) {
        print('✅ No DMX migration needed - all data is up to date');
        return;
      }
      
      // Obtenir les statistiques avant migration
      final statsBefore = await CatalogueDmxMigrationService.getMigrationStats();
      print('📊 Stats before migration:');
      print('   Total items: ${statsBefore['totalItems']}');
      print('   Items with DMX: ${statsBefore['itemsWithDmx']}');
      print('   Items without DMX: ${statsBefore['itemsWithoutDmx']}');
      print('   Categories: ${statsBefore['categories']}');
      
      // Exécuter la migration
      await CatalogueDmxMigrationService.migrateDmxDataAndNewProducts();
      
      // Obtenir les statistiques après migration
      final statsAfter = await CatalogueDmxMigrationService.getMigrationStats();
      print('📊 Stats after migration:');
      print('   Total items: ${statsAfter['totalItems']}');
      print('   Items with DMX: ${statsAfter['itemsWithDmx']}');
      print('   Items without DMX: ${statsAfter['itemsWithoutDmx']}');
      print('   New products: ${statsAfter['newProducts']}');
      
      print('✅ DMX data and new products migration completed successfully!');
      
    } catch (e, stackTrace) {
      print('❌ Error during migration: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  /// Force la migration complète (vide et recrée tout)
  static Future<void> runForceMigration() async {
    try {
      print('🚀 Starting FORCED complete migration...');
      
      // Initialiser Hive
      await HiveService.init();
      
      // Exécuter la migration forcée
      await CatalogueDmxMigrationService.forceCompleteMigration();
      
      // Obtenir les statistiques après migration
      final statsAfter = await CatalogueDmxMigrationService.getMigrationStats();
      print('📊 Stats after forced migration:');
      print('   Total items: ${statsAfter['totalItems']}');
      print('   Items with DMX: ${statsAfter['itemsWithDmx']}');
      print('   Items without DMX: ${statsAfter['itemsWithoutDmx']}');
      print('   New products: ${statsAfter['newProducts']}');
      
      print('✅ FORCED complete migration completed successfully!');
      
    } catch (e, stackTrace) {
      print('❌ Error during forced migration: $e');
      print('Stack trace: $stackTrace');
      rethrow;
    }
  }
}

/// Widget pour exécuter la migration depuis l'interface
class DmxMigrationWidget extends StatefulWidget {
  const DmxMigrationWidget({super.key});

  @override
  State<DmxMigrationWidget> createState() => _DmxMigrationWidgetState();
}

class _DmxMigrationWidgetState extends State<DmxMigrationWidget> {
  bool _isLoading = false;
  String _status = 'Ready to migrate';
  Map<String, dynamic>? _stats;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final stats = await CatalogueDmxMigrationService.getMigrationStats();
      setState(() {
        _stats = stats;
      });
    } catch (e) {
      setState(() {
        _status = 'Error loading stats: $e';
      });
    }
  }

  Future<void> _runMigration() async {
    setState(() {
      _isLoading = true;
      _status = 'Running migration...';
    });

    try {
      await RunDmxMigration.runMigration();
      setState(() {
        _status = 'Migration completed successfully!';
      });
      await _loadStats();
    } catch (e) {
      setState(() {
        _status = 'Migration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _runForceMigration() async {
    setState(() {
      _isLoading = true;
      _status = 'Running forced migration...';
    });

    try {
      await RunDmxMigration.runForceMigration();
      setState(() {
        _status = 'Forced migration completed successfully!';
      });
      await _loadStats();
    } catch (e) {
      setState(() {
        _status = 'Forced migration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('DMX Migration'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Migration Status',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Status: $_status'),
                    const SizedBox(height: 8),
                    if (_stats != null) ...[
                      Text('Total items: ${_stats!['totalItems']}'),
                      Text('Items with DMX: ${_stats!['itemsWithDmx']}'),
                      Text('Items without DMX: ${_stats!['itemsWithoutDmx']}'),
                      if (_stats!['newProducts'].isNotEmpty)
                        Text('New products: ${_stats!['newProducts'].join(', ')}'),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runMigration,
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Run Migration'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _runForceMigration,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Force Migration'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadStats,
              child: const Text('Refresh Stats'),
            ),
          ],
        ),
      ),
    );
  }
}
