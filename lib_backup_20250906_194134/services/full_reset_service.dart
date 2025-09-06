import 'package:logging/logging.dart';
import 'hive_service.dart';

class FullResetService {
  static final _logger = Logger('FullResetService');

  /// Effectue un reset complet de l'application (comme un nouvel utilisateur)
  static Future<void> performFullReset() async {
    try {
      _logger.info('Starting full application reset...');

      // 1. Fermer toutes les boxes Hive
      await HiveService.clearAllData();
      _logger.info('All Hive data cleared');

      // 2. Réinitialiser Hive
      await HiveService.initialize();
      _logger.info('Hive reinitialized');

      // 4. Forcer la migration complète du catalogue
      await _forceCatalogueMigration();
      _logger.info('Catalogue migration forced');

      _logger.info('Full reset completed successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error during full reset', e, stackTrace);
      rethrow;
    }
  }


  /// Force la migration complète du catalogue
  static Future<void> _forceCatalogueMigration() async {
    try {
      // Cette méthode sera appelée par le CatalogueProvider
      // qui détectera l'absence de données et fera la migration complète
      _logger.info('Catalogue migration will be triggered on next load');
    } catch (e) {
      _logger.warning('Error during catalogue migration: $e');
    }
  }
}
