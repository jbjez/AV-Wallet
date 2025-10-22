import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import '../services/hive_service.dart';

/// Service de migration pour les données d'éclairage vers Hive
class LightMigrationService {
  static final _logger = Logger('LightMigrationService');
  
  /// Migre les données d'éclairage vers Hive
  static Future<void> migrateLightData() async {
    try {
      _logger.info('Starting light data migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si les items lumière sont déjà migrés
      final existingLightItems = box.values.where((item) => 
        item.categorie == 'Lumière'
      ).toList();
      
      if (existingLightItems.isNotEmpty) {
        _logger.info('Light data already exists in Hive (${existingLightItems.length} items)');
        return;
      }
      
      // Créer les données d'éclairage
      final lightItems = _createLightItems();
      
      // Sauvegarder dans Hive
      for (final item in lightItems) {
        await box.put(item.id, item);
        _logger.info('Migrated light item: ${item.id}');
      }
      
      _logger.info('Light data migration completed successfully (${lightItems.length} items)');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during light data migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Crée la liste des items d'éclairage à migrer
  static List<CatalogueItem> _createLightItems() {
    return [
      // Elation - Série Artiste
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

      const CatalogueItem(
        id: 'Artiste-Van-Gogh',
        name: 'Artiste Van Gogh',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Wash',
        marque: 'Elation',
        produit: 'Artiste Van Gogh',
        dimensions: '472 x 690 x 914 mm',
        poids: '32 kg',
        conso: '950 W',
        angle: '16°–55°',
        lux: '15 000 lx @ 5m',
        dmxMax: '66',
        dmxMini: '40',
      ),

      // Elation - Série Proteus
      const CatalogueItem(
        id: 'Proteus-Maximus',
        name: 'Proteus Maximus',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Spot',
        marque: 'Elation',
        produit: 'Proteus Maximus',
        dimensions: '497 x 820 x 875 mm',
        poids: '54 kg',
        conso: '1450 W',
        angle: '6.5°–55°',
        lux: '50 000 lx @ 5m',
        dmxMax: '67',
        dmxMini: '42',
      ),

      const CatalogueItem(
        id: 'Proteus-Hybrid',
        name: 'Proteus Hybrid',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Hybride',
        marque: 'Elation',
        produit: 'Proteus Hybrid',
        dimensions: '505 x 715 x 875 mm',
        poids: '43 kg',
        conso: '780 W',
        angle: '2.2°–32°',
        lux: '14 500 lx @ 5m',
        dmxMax: '49',
        dmxMini: '35',
      ),

      const CatalogueItem(
        id: 'Proteus-Rayzor-760',
        name: 'Proteus Rayzor 760',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Wash',
        marque: 'Elation',
        produit: 'Proteus Rayzor 760',
        dimensions: '432 x 602 x 699 mm',
        poids: '26.5 kg',
        conso: '450 W',
        angle: '8°–77°',
        lux: '9 300 lx @ 5m',
        dmxMax: '45',
        dmxMini: '23',
      ),

      const CatalogueItem(
        id: 'Smarty-Hybrid',
        name: 'Smarty Hybrid',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Hybride',
        marque: 'Elation',
        produit: 'Smarty Hybrid',
        dimensions: '354 x 583 x 678 mm',
        poids: '21.5 kg',
        conso: '470 W',
        angle: '1°–18° (Beam) / 3°–27° (Spot)',
        lux: '12 000 lx @ 5m',
        dmxMax: '49',
        dmxMini: '26',
      ),

      const CatalogueItem(
        id: 'Rayzor-360Z',
        name: 'Rayzor 360Z',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Wash ',
        marque: 'Elation',
        produit: 'Rayzor 360Z',
        dimensions: '281 x 408 x 490 mm',
        poids: '8 kg',
        conso: '220 W',
        angle: '8°–77°',
        lux: '2 600 lx @ 5m',
        dmxMax: '21',
        dmxMini: '14',
      ),

      // Robe - Série Pointe
      const CatalogueItem(
        id: 'Robe-MegaPointe',
        name: 'MegaPointe',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Hybride',
        marque: 'Robe',
        produit: 'MegaPointe',
        dimensions: '396 x 640 x 230 mm',
        poids: '22 kg',
        conso: '670 W',
        angle: 'Beam 1.8°–21° / Spot 3°–42°',
        lux: '2 200 000 lx @ 5m (beam)',
        dmxMax: '39',
        dmxMini: '34',
      ),

      const CatalogueItem(
        id: 'Robe-Pointe',
        name: 'Pointe',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Hybride',
        marque: 'Robe',
        produit: 'Pointe',
        dimensions: '365 x 575 x 250 mm',
        poids: '15 kg',
        conso: '470 W',
        angle: 'Beam 2.5°–10° / Spot 5°–20°',
        lux: '90 000 lx @ 5m (spot)',
        dmxMax: '30',
        dmxMini: '16',
      ),

      // Robe - Série Profile
      const CatalogueItem(
        id: 'Robe-ESPRITE-Profile',
        name: 'ESPRITE Profile',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Profile',
        marque: 'Robe',
        produit: 'ESPRITE Profile',
        dimensions: '443 x 733 x 264 mm',
        poids: '28.2 kg',
        conso: '950 W (HP) / 870 W (Std)',
        angle: '5.5°–50°',
        lux: '85 000 lx @ 5m (HP)',
        dmxMax: '50',
        dmxMini: '42',
      ),

      const CatalogueItem(
        id: 'Robe-FORTE-Profile',
        name: 'FORTE',
        description: '',
        categorie: 'Lumière',
        sousCategorie: 'Profile',
        marque: 'Robe',
        produit: 'FORTE',
        dimensions: '483 x 813 x 335 mm',
        poids: '41 kg',
        conso: '1250 W',
        angle: '5°–55°',
        lux: '113 000 lx @ 5m (HP)',
        dmxMax: '50',
        dmxMini: '42',
      ),

      // Ajoutez ici d'autres items lumière si nécessaire...
      // Pour l'instant, j'ai inclus les premiers items comme exemple
    ];
  }
  
  /// Vérifie si la migration des données lumière est nécessaire
  static Future<bool> needsMigration() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final existingLightItems = box.values.where((item) => 
        item.categorie == 'Lumière'
      ).toList();
      
      return existingLightItems.isEmpty;
    } catch (e) {
      _logger.warning('Error checking migration status: $e');
      return true; // En cas d'erreur, on considère qu'une migration est nécessaire
    }
  }
  
  /// Obtient le nombre d'items lumière actuellement dans Hive
  static Future<int> getLightItemCount() async {
    try {
      final box = await HiveService.getCatalogueBox();
      return box.values.where((item) => 
        item.categorie == 'Lumière'
      ).length;
    } catch (e) {
      _logger.warning('Error getting light item count: $e');
      return 0;
    }
  }
}
