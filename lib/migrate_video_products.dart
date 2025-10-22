import 'package:logging/logging.dart';
import 'services/hive_service.dart';
import 'services/catalogue_migration_service.dart';

void main() async {
  // Configurer le logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  try {
    print('🚀 Starting video products migration...');
    
    // Initialiser Hive
    await HiveService.init();
    print('✅ Hive initialized');
    
    // Vérifier l'état actuel
    final totalItems = await CatalogueMigrationService.getTotalItemCount();
    final existingCategories = await CatalogueMigrationService.getExistingCategories();
    
    print('📊 Current state:');
    print('   - Total items in Hive: $totalItems');
    print('   - Existing categories: ${existingCategories.join(', ')}');
    
    // Exécuter la migration des nouvelles catégories
    await CatalogueMigrationService.migrateNewCategories();
    
    // Vérifier le résultat
    final newTotalItems = await CatalogueMigrationService.getTotalItemCount();
    final newCategories = await CatalogueMigrationService.getExistingCategories();
    
    print('📈 After migration:');
    print('   - Total items in Hive: $newTotalItems');
    print('   - New categories: ${newCategories.join(', ')}');
    print('   - Items added: ${newTotalItems - totalItems}');
    
    print('✅ Video products migration completed successfully!');
    
  } catch (e, stackTrace) {
    print('❌ Error during migration: $e');
    print('Stack trace: $stackTrace');
  } finally {
    // Fermer Hive
    await HiveService.close();
  }
}
