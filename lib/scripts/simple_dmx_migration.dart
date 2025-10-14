import 'dart:io';
import '../services/catalogue_dmx_migration_service.dart';
import '../services/hive_service.dart';

/// Script simple pour exécuter la migration DMX depuis la ligne de commande
void main() async {
  print('🚀 AV Wallet - DMX Data Migration');
  print('================================');
  
  try {
    // Initialiser Hive
    print('📦 Initializing Hive...');
    await HiveService.init();
    print('✅ Hive initialized');
    
    // Vérifier si la migration est nécessaire
    print('\n🔍 Checking if migration is needed...');
    final needsMigration = await CatalogueDmxMigrationService.needsDmxMigration();
    
    if (!needsMigration) {
      print('✅ No migration needed - all data is up to date');
      await _showStats();
      return;
    }
    
    print('⚠️  Migration needed - proceeding...');
    
    // Obtenir les statistiques avant migration
    print('\n📊 Statistics before migration:');
    await _showStats();
    
    // Exécuter la migration
    print('\n🔄 Running migration...');
    await CatalogueDmxMigrationService.migrateDmxDataAndNewProducts();
    
    // Obtenir les statistiques après migration
    print('\n📊 Statistics after migration:');
    await _showStats();
    
    print('\n✅ Migration completed successfully!');
    
  } catch (e, stackTrace) {
    print('\n❌ Error during migration: $e');
    print('Stack trace: $stackTrace');
    exit(1);
  }
}

Future<void> _showStats() async {
  try {
    final stats = await CatalogueDmxMigrationService.getMigrationStats();
    
    print('   Total items: ${stats['totalItems']}');
    print('   Items with DMX: ${stats['itemsWithDmx']}');
    print('   Items without DMX: ${stats['itemsWithoutDmx']}');
    
    if (stats['categories'] != null) {
      print('   Categories:');
      final categories = stats['categories'] as Map<String, int>;
      categories.forEach((category, count) {
        print('     - $category: $count items');
      });
    }
    
    if (stats['newProducts'] != null && (stats['newProducts'] as List).isNotEmpty) {
      print('   New products: ${(stats['newProducts'] as List).join(', ')}');
    }
    
  } catch (e) {
    print('   Error getting stats: $e');
  }
}
