import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';
import '../services/hive_service.dart';

/// Service de migration pour les données d'écrans et vidéoprojecteurs vers Hive
class ScreenMigrationService {
  static final _logger = Logger('ScreenMigrationService');
  
  /// Migre les données d'écrans et vidéoprojecteurs vers Hive
  static Future<void> migrateScreenData() async {
    try {
      _logger.info('Starting screen data migration...');
      
      // Récupérer la box Hive
      final box = await HiveService.getCatalogueBox();
      
      // Vérifier si les écrans et vidéoprojecteurs sont déjà migrés
      final existingVideoItems = box.values.where((item) => 
        item.categorie == 'Vidéo' && (item.sousCategorie == 'Écran' || item.sousCategorie == 'Videoprojection')
      ).toList();
      
      if (existingVideoItems.isNotEmpty) {
        _logger.info('Video data already exists in Hive (${existingVideoItems.length} items)');
        return;
      }
      
      // Créer les données d'écrans et vidéoprojecteurs
      final videoItems = _createVideoItems();
      
      // Sauvegarder dans Hive
      for (final item in videoItems) {
        await box.put(item.id, item);
        _logger.info('Migrated video item: ${item.id}');
      }
      
      _logger.info('Video data migration completed successfully (${videoItems.length} items)');
      
    } catch (e, stackTrace) {
      _logger.severe('Error during screen data migration', e, stackTrace);
      rethrow;
    }
  }
  
  /// Crée la liste des items d'écrans et vidéoprojecteurs à migrer
  static List<CatalogueItem> _createVideoItems() {
    return [
      // LG - Série UL3J
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

      const CatalogueItem(
        id: 'lg_43ul3j',
        name: 'LG 43UL3J-M',
        description: 'Écran LED 43" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 43UL3J-M',
        taille: 43,
        dimensions: '967 x 563 x 57 mm',
        poids: '9.0 kg',
        conso: '75 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'lg_55ul3j',
        name: 'LG 55UL3J-M',
        description: 'Écran LED 55" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 55UL3J-M',
        taille: 55,
        dimensions: '1235 x 715 x 57 mm',
        poids: '14.2 kg',
        conso: '110 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'lg_65ul3j',
        name: 'LG 65UL3J-M',
        description: 'Écran LED 65" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 65UL3J-M',
        taille: 65,
        dimensions: '1456 x 838 x 57 mm',
        poids: '22.5 kg',
        conso: '150 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'lg_75ul3j',
        name: 'LG 75UL3J-M',
        description: 'Écran LED 75" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 75UL3J-M',
        taille: 75,
        dimensions: '1686 x 963 x 59 mm',
        poids: '34.3 kg',
        conso: '195 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'lg_86ul3j',
        name: 'LG 86UL3J-M',
        description: 'Écran LED 86" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 86UL3J-M',
        taille: 86,
        dimensions: '1927 x 1100 x 59 mm',
        poids: '45.8 kg',
        conso: '250 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'lg_98um5j',
        name: 'LG 98UM5J-B',
        description: 'Écran LED 98" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'LG',
        produit: 'LG 98UM5J-B',
        taille: 98,
        dimensions: '2194 x 1249 x 95 mm',
        poids: '85.0 kg',
        conso: '400 W',
        resolution: '3840 x 2160',
      ),

      // SAMSUNG - Série QB
      const CatalogueItem(
        id: 'samsung_qb32r',
        name: 'Samsung QB32R',
        description: 'Écran LED 32" Full HD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB32R',
        taille: 32,
        dimensions: '726 x 425 x 45 mm',
        poids: '5.0 kg',
        conso: '40 W',
        resolution: '1920 x 1080',
      ),

      const CatalogueItem(
        id: 'samsung_qb43b',
        name: 'Samsung QB43B',
        description: 'Écran LED 43" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB43B',
        taille: 43,
        dimensions: '967 x 563 x 49 mm',
        poids: '8.9 kg',
        conso: '75 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'samsung_qb55b',
        name: 'Samsung QB55B',
        description: 'Écran LED 55" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB55B',
        taille: 55,
        dimensions: '1235 x 707 x 49 mm',
        poids: '16.9 kg',
        conso: '110 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'samsung_qb65b',
        name: 'Samsung QB65B',
        description: 'Écran LED 65" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB65B',
        taille: 65,
        dimensions: '1453 x 831 x 49 mm',
        poids: '22.8 kg',
        conso: '150 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'samsung_qb75b',
        name: 'Samsung QB75B',
        description: 'Écran LED 75" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB75B',
        taille: 75,
        dimensions: '1675 x 957 x 60 mm',
        poids: '36.1 kg',
        conso: '195 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'samsung_qb85b',
        name: 'Samsung QB85B',
        description: 'Écran LED 85" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QB85B',
        taille: 85,
        dimensions: '1892 x 1080 x 60 mm',
        poids: '45.7 kg',
        conso: '280 W',
        resolution: '3840 x 2160',
      ),

      const CatalogueItem(
        id: 'samsung_qm98f',
        name: 'Samsung QM98F',
        description: 'Écran LED 98" 4K UHD pour affichage professionnel',
        categorie: 'Vidéo',
        sousCategorie: 'Écran',
        marque: 'Samsung',
        produit: 'Samsung QM98F',
        taille: 98,
        dimensions: '2195 x 1245 x 95 mm',
        poids: '90.0 kg',
        conso: '450 W',
        resolution: '3840 x 2160',
      ),

      // Vidéoprojecteurs
      CatalogueItem(
        id: 'panasonic_pt_dz10k',
        name: 'Panasonic PT-DZ10K',
        description: 'Vidéoprojecteur professionnel 10 600 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Panasonic',
        produit: 'PT-DZ10K',
        dimensions: '530 x 200 x 548 mm',
        poids: '24.3 kg',
        conso: '1200 W',
        lumens: '10 600 lm',
        optiques: [
          Lens(reference: 'LE1', ratio: '1.5–2.1:1'),
          Lens(reference: 'LE2', ratio: '2.3–2.8:1'),
          Lens(reference: 'LE3', ratio: '3.5–4.6:1'),
          Lens(reference: 'LE4', ratio: '5.8–6.7:1'),
          Lens(reference: 'LE5', ratio: '0.8/0.7:1'),
          Lens(reference: 'LE6', ratio: '0.9–1.1:1'),
        ],
      ),

      CatalogueItem(
        id: 'barco_udx_4k40_flex',
        name: 'Barco UDX-4K40 FLEX',
        description: 'Vidéoprojecteur 4K professionnel 37 500 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Barco',
        produit: 'UDX-4K40 FLEX',
        dimensions: '660 x 830 x 350 mm',
        poids: '92 kg',
        conso: '3750 W',
        lumens: '37 500 lm',
        optiques: [
          Lens(reference: 'TLD+ Ultra Short Throw', ratio: '0.37:1'),
          Lens(reference: 'TLD+ Zoom', ratio: '0.85-1.24:1'),
        ],
      ),

      CatalogueItem(
        id: 'panasonic_pt_rz12k',
        name: 'Panasonic PT-RZ12K',
        description: 'Vidéoprojecteur professionnel 12 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Panasonic',
        produit: 'PT-RZ12K',
        dimensions: '598 x 270 x 725 mm',
        poids: '44 kg',
        conso: '1200 W',
        lumens: '12 000 lm',
        optiques: [
          Lens(reference: 'ET-DLE020', ratio: '0.28:1'),
          Lens(reference: 'ET-DLE030', ratio: '0.38:1'),
          Lens(reference: 'ET-DLE035', ratio: '0.39–0.47:1'),
          Lens(reference: 'ET-DLE150', ratio: '1.3–1.8:1'),
          Lens(reference: 'ET-DLE250', ratio: '2.4–4.7:1'),
          Lens(reference: 'ET-DLE350', ratio: '4.6–7.4:1'),
        ],
      ),

      CatalogueItem(
        id: 'christie_crimson_wu31',
        name: 'Christie Crimson WU31',
        description: 'Vidéoprojecteur professionnel 31 500 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Christie',
        produit: 'Crimson WU31',
        dimensions: '620 x 720 x 280 mm',
        poids: '51 kg',
        conso: '1320 W',
        lumens: '31 500 lm',
        optiques: [
          Lens(reference: 'ILS1 0.73–0.93:1', ratio: '0.73–0.93:1'),
          Lens(reference: 'ILS1', ratio: '0.95–1.22:1'),
          Lens(reference: 'ILS1', ratio: '1.22–1.52:1'),
          Lens(reference: 'ILS1', ratio: '1.52–2.03:1'),
          Lens(reference: 'ILS1', ratio: '2.03–2.71:1'),
          Lens(reference: 'ILS1', ratio: '2.71–3.89:1'),
          Lens(reference: 'ILS1', ratio: '3.89–5.43:1'),
          Lens(reference: 'ILS1', ratio: '4.98–7.69:1'),
        ],
      ),

      CatalogueItem(
        id: 'christie_m_4k25_rgb',
        name: 'Christie M 4K25 RGB',
        description: 'Vidéoprojecteur 4K RGB 25 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Christie',
        produit: 'M 4K25 RGB',
        dimensions: '585 x 686 x 306 mm',
        poids: '41.5 kg',
        conso: '1800 W',
        lumens: '25 000 lm',
        optiques: [
          Lens(reference: 'ILS1', ratio: '1.45–1.8:1 D4K Zoom'),
          Lens(reference: 'ILS3 0.72:1', ratio: '0.72:1'),
          Lens(reference: 'ILS3 0.9–1.2:1', ratio: '0.9–1.2:1'),
          Lens(reference: 'ILS3 1.25–1.6:1', ratio: '1.25–1.6:1'),
          Lens(reference: 'ILS3 1.6–2.0:1', ratio: '1.6–2.0:1'),
          Lens(reference: 'ILS3 2.0–4.0:1', ratio: '2.0–4.0:1'),
          Lens(reference: 'ILS3 4.3–6.0:1', ratio: '4.3–6.0:1'),
        ],
      ),

      CatalogueItem(
        id: 'epson_eb_l20000u',
        name: 'Epson EB-L20000U',
        description: 'Vidéoprojecteur professionnel 20 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Epson',
        produit: 'EB-L20000U',
        dimensions: '586 x 734 x 264 mm',
        poids: '49.6 kg',
        conso: '1400 W',
        lumens: '20 000 lm',
        optiques: [
          Lens(reference: 'ELPLX02S', ratio: '0.35:1'),
          Lens(reference: 'ELPLU03', ratio: '0.65:1'),
          Lens(reference: 'ELPLU04', ratio: '0.87–1.06:1'),
          Lens(reference: 'ELPLW06', ratio: '1.31–1.64:1'),
          Lens(reference: 'ELPLM15', ratio: '1.57–2.56:1'),
          Lens(reference: 'ELPLM11', ratio: '2.2–3.6:1'),
          Lens(reference: 'ELPLL08', ratio: '3.6–5.4:1'),
          Lens(reference: 'ELPLL09', ratio: '4.2–7.0:1'),
        ],
      ),

      CatalogueItem(
        id: 'barco_f80_q12',
        name: 'Barco F80-Q12',
        description: 'Vidéoprojecteur professionnel 12 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Barco',
        produit: 'F80-Q12',
        dimensions: '560 x 680 x 220 mm',
        poids: '24.5 kg',
        conso: '1400 W',
        lumens: '12 000 lm',
        optiques: [
          Lens(reference: 'GC LENS 0.75:1', ratio: '0.75:1'),
          Lens(reference: 'GC LENS 0.95–1.22:1', ratio: '0.95–1.22:1'),
          Lens(reference: 'GC LENS 1.22–1.52:1', ratio: '1.22–1.52:1'),
          Lens(reference: 'GC LENS 1.52–2.03:1', ratio: '1.52–2.03:1'),
          Lens(reference: 'GC LENS 2.03–2.71:1', ratio: '2.03–2.71:1'),
          Lens(reference: 'GC LENS 2.71–3.89:1', ratio: '2.71–3.89:1'),
          Lens(reference: 'GC LENS 3.89–5.43:1', ratio: '3.89–5.43:1'),
        ],
      ),

      CatalogueItem(
        id: 'christie_m_4k25_rgb_2',
        name: 'Christie M 4K25 RGB (2)',
        description: 'Vidéoprojecteur 4K RGB 25 300 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Christie',
        produit: 'M 4K25 RGB',
        dimensions: '585 x 686 x 306 mm',
        poids: '41.5 kg',
        conso: '1800 W',
        lumens: '25 300 lm',
        optiques: [
          Lens(reference: 'ILS1 - 1.45–1.8:1 D4K Zoom', ratio: '1.45–1.8:1'),
          Lens(reference: 'ILS3 0.72:1', ratio: '0.72:1'),
          Lens(reference: 'ILS3 0.9–1.2:1', ratio: '0.9–1.2:1'),
          Lens(reference: 'ILS3 1.25–1.6:1', ratio: '1.25–1.6:1'),
          Lens(reference: 'ILS3 1.6–2.0:1', ratio: '1.6–2.0:1'),
          Lens(reference: 'ILS3 2.0–4.0:1', ratio: '2.0–4.0:1'),
          Lens(reference: 'ILS3 4.3–6.0:1', ratio: '4.3–6.0:1'),
        ],
      ),

      CatalogueItem(
        id: 'lg_probeam_bu60pst',
        name: 'LG ProBeam BU60PST',
        description: 'Vidéoprojecteur portable 6 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'LG',
        produit: 'ProBeam BU60PST',
        dimensions: '370 x 290 x 155 mm',
        poids: '9.2 kg',
        conso: '430 W',
        lumens: '6 000 lm',
        optiques: [
          Lens(reference: 'Optique intégrée', ratio: '1.30–2.08:1'),
        ],
      ),

      CatalogueItem(
        id: 'lg_bf60pst',
        name: 'LG BF60PST',
        description: 'Vidéoprojecteur portable 6 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'LG',
        produit: 'BF60PST',
        dimensions: '370 x 290 x 155 mm',
        poids: '9.2 kg',
        conso: '450 W',
        lumens: '6 000 lm',
        optiques: [
          Lens(reference: 'Optique intégrée', ratio: '1.30–2.08:1'),
        ],
      ),

      CatalogueItem(
        id: 'christie_roadie_4k45',
        name: 'Christie Roadie 4K45',
        description: 'Vidéoprojecteur professionnel 43 000 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Christie',
        produit: 'Roadie 4K45',
        dimensions: '1016 x 760 x 584 mm',
        poids: '97 kg',
        conso: '6500 W',
        lumens: '43 000 lm',
        optiques: [
          Lens(reference: 'Monture motorisée', ratio: 'NC'),
        ],
      ),

      CatalogueItem(
        id: 'barco_g62_w14',
        name: 'Barco G62-W14',
        description: 'Vidéoprojecteur professionnel 11 500 lumens',
        categorie: 'Vidéo',
        sousCategorie: 'Videoprojection',
        marque: 'Barco',
        produit: 'G62-W14',
        dimensions: '484 x 509 x 181 mm',
        poids: '16 kg',
        conso: '1400 W',
        lumens: '11 500 lm',
        optiques: [
          Lens(reference: 'R9801785', ratio: '0.36:1'),
          Lens(reference: 'R9801840', ratio: '0.75–0.95:1'),
          Lens(reference: 'R9801784', ratio: '1.22–1.53:1'),
          Lens(reference: 'R9832756', ratio: '1.52–2.92:1'),
          Lens(reference: 'R9832778', ratio: '2.90–5.50:1'),
        ],
      ),
    ];
  }
  
  /// Vérifie si la migration des données vidéo est nécessaire
  static Future<bool> needsMigration() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final existingVideoItems = box.values.where((item) => 
        item.categorie == 'Vidéo' && (item.sousCategorie == 'Écran' || item.sousCategorie == 'Videoprojection')
      ).toList();
      
      return existingVideoItems.isEmpty;
    } catch (e) {
      _logger.warning('Error checking migration status: $e');
      return true; // En cas d'erreur, on considère qu'une migration est nécessaire
    }
  }
  
  /// Obtient le nombre d'items vidéo actuellement dans Hive
  static Future<int> getVideoItemCount() async {
    try {
      final box = await HiveService.getCatalogueBox();
      return box.values.where((item) => 
        item.categorie == 'Vidéo' && (item.sousCategorie == 'Écran' || item.sousCategorie == 'Videoprojection')
      ).length;
    } catch (e) {
      _logger.warning('Error getting video item count: $e');
      return 0;
    }
  }
}
