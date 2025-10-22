import 'package:logging/logging.dart';
import '../data/son_items_data.dart';
import 'hive_service.dart';

class SonMigrationService {
  static final _logger = Logger('SonMigrationService');

  static Future<void> migrateSonItems() async {
    try {
      _logger.info('Starting Son items migration...');

      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si les items Son existent déjà
      final sonItems = SonItemsData.getSonItems();
      bool needsMigration = false;
      
      for (final item in sonItems) {
        if (!box.containsKey(item.id)) {
          needsMigration = true;
          break;
        }
      }

      if (!needsMigration) {
        _logger.info('Son items already exist, no migration needed');
        return;
      }

      _logger.info('Adding ${sonItems.length} new Son items...');

      // Ajouter les nouveaux items Son
      for (final item in sonItems) {
        if (!box.containsKey(item.id)) {
          await box.put(item.id, item);
          _logger.info('Added Son item: ${item.id} - ${item.name}');
        }
      }

      _logger.info('Son items migration completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error during Son items migration', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> checkAndMigrate() async {
    try {
      _logger.info('Checking if Son items migration is needed...');
      
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si au moins un item Son existe
      final sonItems = SonItemsData.getSonItems();
      bool hasSonItems = false;
      
      for (final item in sonItems) {
        if (box.containsKey(item.id)) {
          hasSonItems = true;
          break;
        }
      }

      if (!hasSonItems) {
        _logger.info('No Son items found, starting migration...');
        await migrateSonItems();
      } else {
        _logger.info('Son items already exist, skipping migration');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error checking Son items migration', e, stackTrace);
      // Ne pas faire échouer l'application
      // rethrow;
    }
  }
}
