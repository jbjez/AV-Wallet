import 'package:hive/hive.dart';
import 'dart:convert';
import '../providers/page_state_provider.dart';
import '../models/catalogue_item.dart';

class PageStatePersistenceService {
  static const String _boxName = 'page_states';
  static Box<String>? _box;
  
  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }
  
  static Future<void> saveLightPageState(LightPageState state) async {
    if (_box == null) await init();
    
    try {
      final stateJson = {
        'selectedFixtures': state.selectedFixtures.map((item) => {
          'id': item.id,
          'name': item.name,
          'description': item.description,
          'categorie': item.categorie,
          'sousCategorie': item.sousCategorie,
          'marque': item.marque,
          'produit': item.produit,
          'dimensions': item.dimensions,
          'poids': item.poids,
          'conso': item.conso,
          'dmxMax': item.dmxMax,
          'dmxMini': item.dmxMini,
        }).toList(),
        'fixtureQuantities': state.fixtureQuantities.map((key, value) => MapEntry(
          key.id, value
        )),
        'fixtureDmxModes': state.fixtureDmxModes.map((key, value) => MapEntry(
          key.id, value
        )),
        'selectedProduct': state.selectedProduct,
        'selectedBrand': state.selectedBrand,
        'searchQuery': state.searchQuery,
        'beamCalculationResult': state.beamCalculationResult,
        'driverCalculationResult': state.driverCalculationResult,
        'dmxCalculationResult': state.dmxCalculationResult,
        'angle': state.angle,
        'height': state.height,
        'distance': state.distance,
        'ampereParVoie': state.ampereParVoie,
        'nbVoies': state.nbVoies,
        'tension': state.tension,
        'selectedDriver': state.selectedDriver,
        'longueurLed': state.longueurLed,
        'selectedRubanType': state.selectedRubanType,
        'selectedPower': state.selectedPower,
      };
      
      await _box!.put('light_page_state', jsonEncode(stateJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'état lumière: $e');
    }
  }
  
  static Future<LightPageState?> loadLightPageState() async {
    if (_box == null) await init();
    
    try {
      final stateJson = _box!.get('light_page_state');
      if (stateJson == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(stateJson);
      
      // Reconstruire les CatalogueItem
      final List<CatalogueItem> selectedFixtures = (data['selectedFixtures'] as List?)
          ?.map((item) => CatalogueItem(
                id: item['id'] ?? '',
                name: item['name'] ?? '',
                description: item['description'] ?? '',
                categorie: item['categorie'] ?? '',
                sousCategorie: item['sousCategorie'] ?? '',
                marque: item['marque'] ?? '',
                produit: item['produit'] ?? '',
                dimensions: item['dimensions'] ?? '',
                poids: item['poids'] ?? '',
                conso: item['conso'] ?? '',
                dmxMax: item['dmxMax'],
                dmxMini: item['dmxMini'],
              ))
          .toList() ?? [];
      
      // Reconstruire les maps avec les objets CatalogueItem
      final Map<CatalogueItem, int> fixtureQuantities = {};
      final Map<CatalogueItem, String> fixtureDmxModes = {};
      
      if (data['fixtureQuantities'] != null) {
        for (final entry in (data['fixtureQuantities'] as Map).entries) {
          final item = selectedFixtures.firstWhere(
            (fixture) => fixture.id == entry.key,
            orElse: () => CatalogueItem(id: '', name: '', description: '', categorie: '', sousCategorie: '', marque: '', produit: '', dimensions: '', poids: '', conso: ''),
          );
          if (item.id.isNotEmpty) {
            fixtureQuantities[item] = entry.value;
          }
        }
      }
      
      if (data['fixtureDmxModes'] != null) {
        for (final entry in (data['fixtureDmxModes'] as Map).entries) {
          final item = selectedFixtures.firstWhere(
            (fixture) => fixture.id == entry.key,
            orElse: () => CatalogueItem(id: '', name: '', description: '', categorie: '', sousCategorie: '', marque: '', produit: '', dimensions: '', poids: '', conso: ''),
          );
          if (item.id.isNotEmpty) {
            fixtureDmxModes[item] = entry.value;
          }
        }
      }
      
      return LightPageState(
        selectedFixtures: selectedFixtures,
        fixtureQuantities: fixtureQuantities,
        fixtureDmxModes: fixtureDmxModes,
        selectedProduct: data['selectedProduct'],
        selectedBrand: data['selectedBrand'],
        searchQuery: data['searchQuery'] ?? '',
        beamCalculationResult: data['beamCalculationResult'],
        driverCalculationResult: data['driverCalculationResult'],
        dmxCalculationResult: data['dmxCalculationResult'],
        angle: (data['angle'] ?? 35).toDouble(),
        height: (data['height'] ?? 10).toDouble(),
        distance: (data['distance'] ?? 20).toDouble(),
        ampereParVoie: (data['ampereParVoie'] ?? 3).toDouble(),
        nbVoies: data['nbVoies'] ?? 5,
        tension: data['tension'] ?? 24,
        selectedDriver: data['selectedDriver'] ?? 'S04x5A',
        longueurLed: (data['longueurLed'] ?? 5).toDouble(),
        selectedRubanType: data['selectedRubanType'] ?? 'blanc',
        selectedPower: data['selectedPower'] ?? 15,
      );
    } catch (e) {
      print('Erreur lors du chargement de l\'état lumière: $e');
      return null;
    }
  }
  
  static Future<void> saveCataloguePageState(CataloguePageState state) async {
    if (_box == null) await init();
    
    try {
      final stateJson = {
        'searchQuery': state.searchQuery,
        'selectedCategory': state.selectedCategory,
        'selectedSubCategory': state.selectedSubCategory,
        'selectedBrand': state.selectedBrand,
        'selectedProduct': state.selectedProduct,
      };
      
      await _box!.put('catalogue_page_state', jsonEncode(stateJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'état catalogue: $e');
    }
  }
  
  static Future<CataloguePageState?> loadCataloguePageState() async {
    if (_box == null) await init();
    
    try {
      final stateJson = _box!.get('catalogue_page_state');
      if (stateJson == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(stateJson);
      
      return CataloguePageState(
        searchQuery: data['searchQuery'] ?? '',
        selectedCategory: data['selectedCategory'],
        selectedSubCategory: data['selectedSubCategory'],
        selectedBrand: data['selectedBrand'],
        selectedProduct: data['selectedProduct'],
      );
    } catch (e) {
      print('Erreur lors du chargement de l\'état catalogue: $e');
      return null;
    }
  }
  
  static Future<void> saveVideoPageState(VideoPageState state) async {
    if (_box == null) await init();
    
    try {
      final stateJson = {
        'selectedProduct': state.selectedProduct,
        'selectedBrand': state.selectedBrand,
        'searchQuery': state.searchQuery,
        'showProjectionResult': state.showProjectionResult,
        'projectionDistance': state.projectionDistance,
        'projectionWidth': state.projectionWidth,
        'projectionHeight': state.projectionHeight,
      };
      
      await _box!.put('video_page_state', jsonEncode(stateJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'état vidéo: $e');
    }
  }
  
  static Future<VideoPageState?> loadVideoPageState() async {
    if (_box == null) await init();
    
    try {
      final stateJson = _box!.get('video_page_state');
      if (stateJson == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(stateJson);
      
      return VideoPageState(
        selectedProduct: data['selectedProduct'],
        selectedBrand: data['selectedBrand'],
        searchQuery: data['searchQuery'] ?? '',
        showProjectionResult: data['showProjectionResult'] ?? false,
        projectionDistance: data['projectionDistance']?.toDouble(),
        projectionWidth: data['projectionWidth']?.toDouble(),
        projectionHeight: data['projectionHeight']?.toDouble(),
      );
    } catch (e) {
      print('Erreur lors du chargement de l\'état vidéo: $e');
      return null;
    }
  }
  
  static Future<void> saveStructurePageState(StructurePageState state) async {
    if (_box == null) await init();
    
    try {
      final stateJson = {
        'selectedStructure': state.selectedStructure,
        'distance': state.distance,
        'selectedCharge': state.selectedCharge,
        'showResult': state.showResult,
        'calculatedLoad': state.calculatedLoad,
      };
      
      await _box!.put('structure_page_state', jsonEncode(stateJson));
    } catch (e) {
      print('Erreur lors de la sauvegarde de l\'état structure: $e');
    }
  }
  
  static Future<StructurePageState?> loadStructurePageState() async {
    if (_box == null) await init();
    
    try {
      final stateJson = _box!.get('structure_page_state');
      if (stateJson == null) return null;
      
      final Map<String, dynamic> data = jsonDecode(stateJson);
      
      return StructurePageState(
        selectedStructure: data['selectedStructure'] ?? 'Poutre simple',
        distance: (data['distance'] ?? 5).toDouble(),
        selectedCharge: data['selectedCharge'] ?? 'Charge légère',
        showResult: data['showResult'] ?? false,
        calculatedLoad: data['calculatedLoad']?.toDouble(),
      );
    } catch (e) {
      print('Erreur lors du chargement de l\'état structure: $e');
      return null;
    }
  }
  
  static Future<void> clearAllStates() async {
    if (_box == null) await init();
    await _box!.clear();
  }
}
