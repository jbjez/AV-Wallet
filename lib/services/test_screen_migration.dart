import 'package:logging/logging.dart';
import 'screen_migration_service.dart';
import 'hive_service.dart';

/// Script de test pour la migration des données d'écrans
class TestScreenMigration {
  static final _logger = Logger('TestScreenMigration');
  
  /// Teste la migration des données vidéo (écrans et vidéoprojecteurs)
  static Future<void> testMigration() async {
    try {
      _logger.info('🧪 Starting video data migration test...');
      
      // Initialiser Hive
      await HiveService.initialize();
      _logger.info('✅ Hive initialized');
      
      // Vérifier l'état avant migration
      final needsMigration = await ScreenMigrationService.needsMigration();
      final videoItemCountBefore = await ScreenMigrationService.getVideoItemCount();
      
      _logger.info('📊 Before migration:');
      _logger.info('  - Needs migration: $needsMigration');
      _logger.info('  - Video item count: $videoItemCountBefore');
      
      if (needsMigration) {
        // Effectuer la migration
        await ScreenMigrationService.migrateScreenData();
        _logger.info('✅ Migration completed');
        
        // Vérifier l'état après migration
        final videoItemCountAfter = await ScreenMigrationService.getVideoItemCount();
        _logger.info('📊 After migration:');
        _logger.info('  - Video item count: $videoItemCountAfter');
        
        if (videoItemCountAfter > videoItemCountBefore) {
          _logger.info('🎉 Migration successful! Added ${videoItemCountAfter - videoItemCountBefore} video items');
        } else {
          _logger.warning('⚠️ No new video items were added');
        }
      } else {
        _logger.info('ℹ️ Migration not needed - video items already exist');
      }
      
      // Lister quelques items vidéo pour vérification
      final box = await HiveService.getCatalogueBox();
      final videoItems = box.values.where((item) => 
        item.categorie == 'Vidéo' && (item.sousCategorie == 'Écran' || item.sousCategorie == 'Videoprojection')
      ).take(5).toList();
      
      _logger.info('📺 Sample video items:');
      for (final item in videoItems) {
        if (item.sousCategorie == 'Écran') {
          _logger.info('  - ${item.marque} ${item.produit} (${item.taille}") - Écran');
        } else {
          _logger.info('  - ${item.marque} ${item.produit} (${item.lumens}) - Vidéoprojecteur');
        }
      }
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Test failed', e, stackTrace);
      rethrow;
    }
  }
  
  /// Nettoie les données vidéo pour retester la migration
  static Future<void> cleanupVideoItems() async {
    try {
      _logger.info('🧹 Cleaning up video data for retest...');
      
      final box = await HiveService.getCatalogueBox();
      final videoItems = box.values.where((item) => 
        item.categorie == 'Vidéo' && (item.sousCategorie == 'Écran' || item.sousCategorie == 'Videoprojection')
      ).toList();
      
      for (final item in videoItems) {
        await box.delete(item.id);
        _logger.info('🗑️ Deleted video item: ${item.id}');
      }
      
      _logger.info('✅ Cleanup completed');
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Cleanup failed', e, stackTrace);
      rethrow;
    }
  }
}
