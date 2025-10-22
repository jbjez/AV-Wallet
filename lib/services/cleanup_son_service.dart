import 'package:logging/logging.dart';
import 'hive_service.dart';

class CleanupSonService {
  static final _logger = Logger('CleanupSonService');

  /// Supprime tous les items JBL de la catégorie Son
  static Future<void> removeJblItems() async {
    try {
      _logger.info('Starting JBL items cleanup...');

      final box = await HiveService.getCatalogueBox();
      
      // Trouver tous les items JBL dans la catégorie Son
      final jblItems = box.values
          .where((item) => item.categorie == 'Son' && item.marque == 'JBL')
          .toList();

      if (jblItems.isEmpty) {
        _logger.info('No JBL items found in Son category');
        return;
      }

      _logger.info('Found ${jblItems.length} JBL items to remove');

      // Supprimer chaque item JBL
      for (final item in jblItems) {
        await box.delete(item.id);
        _logger.info('Removed JBL item: ${item.id} - ${item.name}');
      }

      _logger.info('JBL items cleanup completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error during JBL items cleanup', e, stackTrace);
      rethrow;
    }
  }

  /// Vérifie et nettoie les items JBL si nécessaire
  static Future<void> checkAndCleanup() async {
    try {
      _logger.info('Checking if JBL items cleanup is needed...');
      
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier s'il y a des items JBL dans la catégorie Son
      final hasJblItems = box.values
          .any((item) => item.categorie == 'Son' && item.marque == 'JBL');

      if (hasJblItems) {
        _logger.info('JBL items found, starting cleanup...');
        await removeJblItems();
      } else {
        _logger.info('No JBL items found, cleanup not needed');
      }
    } catch (e, stackTrace) {
      _logger.severe('Error checking JBL items cleanup', e, stackTrace);
      // Ne pas faire échouer l'application
    }
  }
}
