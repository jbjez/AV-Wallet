import 'dart:io';
import 'package:logging/logging.dart';
import '../services/catalogue_migration_service.dart';
import '../services/hive_service.dart';

/// Script exécutable pour tester la migration du catalogue
/// Usage: dart run lib/scripts/test_catalogue_migration_script.dart
void main() async {
  // Configurer le logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
  });
  
  final logger = Logger('Main');
  
  try {
    logger.info('🚀 Starting catalogue migration test script...');
    
    // Initialiser Hive
    await HiveService.initialize();
    logger.info('✅ Hive initialized');
    
    // Vérifier l'état avant migration
    final needsMigration = await CatalogueMigrationService.needsMigration();
    final needsNewCategories = await CatalogueMigrationService.needsNewCategoriesMigration();
    final totalCountBefore = await CatalogueMigrationService.getTotalItemCount();
    final existingCategories = await CatalogueMigrationService.getExistingCategories();
    
    logger.info('📊 Before migration:');
    logger.info('  - Needs migration: $needsMigration');
    logger.info('  - Needs new categories migration: $needsNewCategories');
    logger.info('  - Total item count: $totalCountBefore');
    logger.info('  - Existing categories: $existingCategories');
    
    if (needsNewCategories) {
      // Effectuer la migration des nouvelles catégories
      await CatalogueMigrationService.migrateNewCategories();
      logger.info('✅ New categories migration completed');
      
      // Vérifier l'état après migration
      final totalCountAfter = await CatalogueMigrationService.getTotalItemCount();
      final newCategories = await CatalogueMigrationService.getExistingCategories();
      
      logger.info('📊 After migration:');
      logger.info('  - Total item count: $totalCountAfter');
      logger.info('  - All categories: $newCategories');
      
      if (totalCountAfter > totalCountBefore) {
        logger.info('🎉 Migration successful! Added ${totalCountAfter - totalCountBefore} new items');
      } else {
        logger.info('ℹ️ No new items were added');
      }
    } else {
      logger.info('ℹ️ No new categories migration needed');
    }
    
    // Lister quelques items par catégorie pour vérification
    final box = await HiveService.getCatalogueBox();
    final categories = box.values.map((item) => item.categorie).toSet();
    
    logger.info('📋 Sample items by category:');
    for (final category in categories) {
      final categoryItems = box.values.where((item) => item.categorie == category).take(2).toList();
      logger.info('  $category (${box.values.where((item) => item.categorie == category).length} items):');
      for (final item in categoryItems) {
        logger.info('    - ${item.marque} ${item.produit}');
      }
    }
    
    logger.info('✅ Test script completed successfully');
    
  } catch (e, stackTrace) {
    logger.severe('❌ Test script failed', e, stackTrace);
    exit(1);
  }
}
