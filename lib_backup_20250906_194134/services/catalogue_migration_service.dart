import 'package:logging/logging.dart';
import '../services/hive_service.dart';
import '../data/catalogue_data.dart';

/// Service de migration du catalogue complet vers Hive
class CatalogueMigrationService {
  static final _logger = Logger('CatalogueMigrationService');
  
  /// Migre toutes les catégories du catalogue vers Hive (force la migration)
  static Future<void> migrateAllCategories() async {
    try {
      _logger.info('Starting complete catalogue migration (forced)...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vider la box pour forcer la migration complète
      await box.clear();
      _logger.info('Catalogue box cleared for fresh migration');
      
      // Utiliser les données du fichier catalogue_data.dart
      final catalogueItems = catalogueData;
      _logger.info('Found ${catalogueItems.length} items in catalogue_data.dart');
      
      // Sauvegarder dans Hive
      for (final item in catalogueItems) {
        await box.put(item.id, item);
      }
      
      _logger.info('Complete catalogue migration completed successfully. Added ${catalogueItems.length} items.');
    } catch (e, stackTrace) {
      _logger.severe('Error during complete catalogue migration', e, stackTrace);
      rethrow;
    }
  }

  /// Migre toutes les données du catalogue vers Hive
  static Future<void> migrateCatalogueData() async {
    try {
      _logger.info('Starting complete catalogue migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si des données existent déjà
      final existingItems = box.values.toList();
      
      if (existingItems.isNotEmpty) {
        _logger.info('Catalogue data already exists in Hive (${existingItems.length} items)');
        return;
      }
      
      // Utiliser les données du fichier catalogue_data.dart
      final catalogueItems = catalogueData;
      
      // Sauvegarder dans Hive
      for (final item in catalogueItems) {
        await box.put(item.id, item);
        _logger.info('Migrated item: ${item.id} (${item.categorie})');
      }
      
      _logger.info('Complete catalogue migration completed successfully (${catalogueItems.length} items)');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during catalogue migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Migre seulement les nouvelles catégories (Lumière, Divers, etc.)
  static Future<void> migrateNewCategories() async {
    try {
      _logger.info('Starting new categories migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Obtenir les IDs déjà présents
      final existingIds = box.values.map((item) => item.id).toSet();
      _logger.info('Existing item IDs: ${existingIds.length} items');
      
      // Filtrer les items qui ne sont pas encore dans Hive
      final newItems = catalogueData.where((item) => 
        !existingIds.contains(item.id)
      ).toList();
      
      if (newItems.isEmpty) {
        _logger.info('No new items to migrate');
        return;
      }
      
      _logger.info('Found ${newItems.length} new items to migrate');
      
      // Sauvegarder les nouveaux items
      for (final item in newItems) {
        await box.put(item.id, item);
        _logger.info('Migrated new category item: ${item.id} (${item.categorie})');
      }
      
      _logger.info('New categories migration completed successfully (${newItems.length} items)');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during new categories migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Vérifie si la migration est nécessaire
  static Future<bool> needsMigration() async {
    try {
      final box = await HiveService.getCatalogueBox();
      return box.isEmpty;
    } catch (e) {
      _logger.warning('Error checking migration status: $e');
      return true;
    }
  }
  
  /// Vérifie si de nouvelles catégories doivent être migrées
  static Future<bool> needsNewCategoriesMigration() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final existingCategories = box.values.map((item) => item.categorie).toSet();
      final allCategories = catalogueData.map((item) => item.categorie).toSet();
      
      return !allCategories.every((category) => existingCategories.contains(category));
    } catch (e) {
      _logger.warning('Error checking new categories migration status: $e');
      return true;
    }
  }
  
  /// Obtient le nombre total d'items dans Hive
  static Future<int> getTotalItemCount() async {
    try {
      final box = await HiveService.getCatalogueBox();
      return box.length;
    } catch (e) {
      _logger.warning('Error getting total item count: $e');
      return 0;
    }
  }
  
  /// Obtient les catégories présentes dans Hive
  static Future<Set<String>> getExistingCategories() async {
    try {
      final box = await HiveService.getCatalogueBox();
      return box.values.map((item) => item.categorie).toSet();
    } catch (e) {
      _logger.warning('Error getting existing categories: $e');
      return <String>{};
    }
  }
}
