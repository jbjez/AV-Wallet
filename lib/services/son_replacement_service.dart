import 'package:logging/logging.dart';
import '../data/catalogue_data.dart';
import 'hive_service.dart';

class SonReplacementService {
  static final _logger = Logger('SonReplacementService');

  /// Supprime toutes les données SON existantes et les remplace par les nouvelles
  static Future<void> replaceSonData() async {
    try {
      _logger.info('Starting SON data replacement...');

      final box = await HiveService.getCatalogueBox();
      
      // 1. Supprimer toutes les données SON existantes
      _logger.info('Removing existing SON data...');
      final existingItems = box.values.toList();
      int removedCount = 0;
      
      for (final item in existingItems) {
        if (item.categorie == 'Son') {
          await box.delete(item.id);
          removedCount++;
          _logger.info('Removed SON item: ${item.id} - ${item.name}');
        }
      }
      
      _logger.info('Removed $removedCount existing SON items');

      // 2. Extraire les nouvelles données SON de catalogue_data.dart
      final newSonItems = catalogueData.where((item) => item.categorie == 'Son').toList();
      _logger.info('Found ${newSonItems.length} new SON items to add');

      // 3. Ajouter les nouvelles données SON
      for (final item in newSonItems) {
        await box.put(item.id, item);
        _logger.info('Added new SON item: ${item.id} - ${item.name}');
      }

      _logger.info('SON data replacement completed successfully. Added ${newSonItems.length} new items.');
    } catch (e, stackTrace) {
      _logger.severe('Error during SON data replacement', e, stackTrace);
      rethrow;
    }
  }

  /// Vérifie si le remplacement est nécessaire
  static Future<bool> needsReplacement() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final existingSonItems = box.values.where((item) => item.categorie == 'Son').toList();
      final newSonItems = catalogueData.where((item) => item.categorie == 'Son').toList();
      
      // Si le nombre d'items SON est différent, on a besoin d'un remplacement
      if (existingSonItems.length != newSonItems.length) {
        return true;
      }
      
      // Vérifier si les IDs correspondent
      final existingIds = existingSonItems.map((item) => item.id).toSet();
      final newIds = newSonItems.map((item) => item.id).toSet();
      
      return !existingIds.containsAll(newIds) || !newIds.containsAll(existingIds);
    } catch (e, stackTrace) {
      _logger.severe('Error checking if replacement is needed', e, stackTrace);
      return true; // En cas d'erreur, on fait le remplacement
    }
  }
}





