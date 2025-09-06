import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import '../services/hive_service.dart';

/// Service de migration général pour toutes les catégories vers Hive
class GeneralMigrationService {
  static final _logger = Logger('GeneralMigrationService');
  
  /// Migre toutes les données du catalogue vers Hive
  static Future<void> migrateAllData() async {
    try {
      _logger.info('Starting general catalogue migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si des données existent déjà
      final existingItems = box.values.toList();
      
      if (existingItems.isNotEmpty) {
        _logger.info('Catalogue data already exists in Hive (${existingItems.length} items)');
        return;
      }
      
      // Créer les données du catalogue
      final catalogueItems = _createCatalogueItems();
      
      // Sauvegarder dans Hive
      for (final item in catalogueItems) {
        await box.put(item.id, item);
        _logger.info('Migrated item: ${item.id} (${item.categorie})');
      }
      
      _logger.info('General catalogue migration completed successfully (${catalogueItems.length} items)');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during general catalogue migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Crée la liste complète des items du catalogue
  static List<CatalogueItem> _createCatalogueItems() {
    // Cette méthode va contenir tous les items du catalogue
    // Pour l'instant, je vais créer un exemple avec quelques items
    return [
      // Items Lumière
      const CatalogueItem(
        id: 'Artiste-Monde',
        name: 'Artiste Mondrian',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Spot',
        marque: 'Elation',
        produit: 'Artiste Mondrian',
        dimensions: '472 x 690 x 914 mm',
        poids: '47.5 kg',
        conso: '1700 W',
        angle: '6°–45°',
        lux: '34 000 lx @ 5m',
        dmxMax: '66',
        dmxMini: '42',
      ),

      const CatalogueItem(
        id: 'Artiste-Rembrandt',
        name: 'Artiste Rembrandt',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Wash',
        marque: 'Elation',
        produit: 'Artiste Rembrandt',
        dimensions: '472 x 690 x 914 mm',
        poids: '47.5 kg',
        conso: '1400 W',
        angle: '13°–70°',
        lux: '22 000 lx @ 5m',
        dmxMax: '66',
        dmxMini: '40',
      ),

      // Items Vidéo - Écrans
      const CatalogueItem(
        id: 'lg_32ul3j',
        name: 'LG 32UL3J-M',
        description: 'Écran LED 32" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 32UL3J-M',
        taille: 32,
        dimensions: '729 x 425 x 44 mm',
        poids: '4.7 kg',
        conso: '40 W',
        resolution: '3840 x 2160',
      ),

      // Items Divers
      const CatalogueItem(
        id: 'Divers-Traiteur-MachineCafe',
        name: 'Machine à café expresso',
        description: 'Machine expresso professionnelle 2 groupes',
        categorie: 'Divers',
        sousCategorie: 'Traiteur',
        marque: 'Nespresso Pro',
        produit: 'Expresso 2 groupes',
        dimensions: '600 x 400 x 450 mm',
        poids: '18 kg',
        conso: '2000 W',
      ),

      // Ajoutez ici tous les autres items du catalogue...
      // Pour l'instant, c'est un exemple avec quelques items
    ];
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
}
