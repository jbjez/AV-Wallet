import 'package:logging/logging.dart';
import '../services/hive_service.dart';
import '../data/catalogue_data.dart';
import '../models/catalogue_item.dart';

/// Service de migration pour les nouvelles données DMX et les nouveaux produits
class CatalogueDmxMigrationService {
  static final _logger = Logger('CatalogueDmxMigrationService');
  
  /// Migre les nouvelles données DMX et les nouveaux produits
  static Future<void> migrateDmxDataAndNewProducts() async {
    try {
      _logger.info('Starting DMX data and new products migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Obtenir les items existants
      final existingItems = <String, CatalogueItem>{};
      for (final item in box.values) {
        existingItems[item.id] = item;
      }
      
      _logger.info('Found ${existingItems.length} existing items in Hive');
      
      // Utiliser les données mises à jour du fichier catalogue_data.dart
      final updatedCatalogueItems = catalogueData;
      _logger.info('Found ${updatedCatalogueItems.length} items in updated catalogue_data.dart');
      
      int updatedCount = 0;
      int newCount = 0;
      
      // Mettre à jour ou ajouter chaque item
      for (final item in updatedCatalogueItems) {
        final existingItem = existingItems[item.id];
        
        if (existingItem != null) {
          // Vérifier si l'item a été mis à jour (nouveaux champs DMX)
          if (_hasDmxUpdates(existingItem, item)) {
            await box.put(item.id, item);
            updatedCount++;
            _logger.info('Updated item with DMX data: ${item.id} (${item.produit})');
          }
        } else {
          // Nouvel item
          await box.put(item.id, item);
          newCount++;
          _logger.info('Added new item: ${item.id} (${item.produit})');
        }
      }
      
      _logger.info('DMX data and new products migration completed successfully.');
      _logger.info('Updated: $updatedCount items, Added: $newCount items');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during DMX data and new products migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Vérifie si un item a des mises à jour DMX
  static bool _hasDmxUpdates(CatalogueItem existing, CatalogueItem updated) {
    // Vérifier les champs DMX
    if (existing.dmxMax != updated.dmxMax || existing.dmxMini != updated.dmxMini) {
      return true;
    }
    
    // Vérifier d'autres champs qui pourraient avoir été mis à jour
    if (existing.lux != updated.lux || 
        existing.angle != updated.angle || 
        existing.conso != updated.conso ||
        existing.poids != updated.poids ||
        existing.dimensions != updated.dimensions) {
      return true;
    }
    
    return false;
  }
  
  /// Force la migration complète (vide et recrée tout)
  static Future<void> forceCompleteMigration() async {
    try {
      _logger.info('Starting forced complete migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vider la box
      await box.clear();
      _logger.info('Catalogue box cleared for fresh migration');
      
      // Utiliser les données mises à jour
      final catalogueItems = catalogueData;
      
      // Sauvegarder tous les items
      for (final item in catalogueItems) {
        await box.put(item.id, item);
      }
      
      _logger.info('Forced complete migration completed successfully. Added ${catalogueItems.length} items.');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during forced complete migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Vérifie si la migration DMX est nécessaire
  static Future<bool> needsDmxMigration() async {
    try {
      final box = await HiveService.getCatalogueBox();
      
      if (box.isEmpty) {
        return true;
      }
      
      // Vérifier si des items ont des données DMX manquantes
      for (final item in box.values) {
        if (item.categorie == 'Lumière' && (item.dmxMax == null || item.dmxMini == null)) {
          return true;
        }
      }
      
      return false;
    } catch (e) {
      _logger.warning('Error checking DMX migration status: $e');
      return true;
    }
  }
  
  /// Obtient les statistiques de migration
  static Future<Map<String, dynamic>> getMigrationStats() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final items = box.values.toList();
      
      final stats = <String, dynamic>{
        'totalItems': items.length,
        'categories': <String, int>{},
        'itemsWithDmx': 0,
        'itemsWithoutDmx': 0,
        'newProducts': <String>[],
      };
      
      for (final item in items) {
        // Compter par catégorie
        stats['categories'][item.categorie] = (stats['categories'][item.categorie] ?? 0) + 1;
        
        // Compter les items avec/sans DMX
        if (item.dmxMax != null && item.dmxMini != null) {
          stats['itemsWithDmx']++;
        } else {
          stats['itemsWithoutDmx']++;
        }
        
        // Identifier les nouveaux produits (ex: Esprit, Picasso)
        if (item.produit.toLowerCase().contains('esprit') || 
            item.produit.toLowerCase().contains('picasso')) {
          stats['newProducts'].add(item.produit);
        }
      }
      
      return stats;
    } catch (e) {
      _logger.warning('Error getting migration stats: $e');
      return <String, dynamic>{};
    }
  }
}
