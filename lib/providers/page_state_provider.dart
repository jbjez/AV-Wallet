import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import '../services/page_state_persistence_service.dart';

/// État persistant pour la page de calcul lumière
class LightPageState {
  final List<CatalogueItem> selectedFixtures;
  final Map<CatalogueItem, int> fixtureQuantities;
  final Map<CatalogueItem, String> fixtureDmxModes;
  final Map<CatalogueItem, bool> fixtureWifiModes; // true = WiFi, false = Filaire
  final String? selectedProduct;
  final String? selectedBrand;
  final String? selectedCategory;
  final String searchQuery;
  final String? beamCalculationResult;
  final String? driverCalculationResult;
  final String? dmxCalculationResult;
  final double angle;
  final double height;
  final double distance;
  final double ampereParVoie;
  final int nbVoies;
  final int tension;
  final String selectedDriver;
  final double longueurLed;
  final String selectedRubanType;
  final int selectedPower;
  final String selectedLedType;
  final String selectedLedPower;
  final String selectedDriverNew;
  final int customChannels;
  final double customIntensity;

  const LightPageState({
    this.selectedFixtures = const [],
    this.fixtureQuantities = const {},
    this.fixtureDmxModes = const {},
    this.fixtureWifiModes = const {},
    this.selectedProduct,
    this.selectedBrand,
    this.selectedCategory,
    this.searchQuery = '',
    this.beamCalculationResult,
    this.driverCalculationResult,
    this.dmxCalculationResult,
    this.angle = 35,
    this.height = 10,
    this.distance = 20,
    this.ampereParVoie = 3,
    this.nbVoies = 5,
    this.tension = 24,
    this.selectedDriver = 'S04x5A',
    this.longueurLed = 5,
    this.selectedRubanType = 'blanc',
    this.selectedPower = 15,
    this.selectedLedType = 'Blanc (W)',
    this.selectedLedPower = '5W',
    this.selectedDriverNew = 'S04x5A',
    this.customChannels = 4,
    this.customIntensity = 5.0,
  });

  LightPageState copyWith({
    List<CatalogueItem>? selectedFixtures,
    Map<CatalogueItem, int>? fixtureQuantities,
    Map<CatalogueItem, String>? fixtureDmxModes,
    Map<CatalogueItem, bool>? fixtureWifiModes,
    String? selectedProduct,
    String? selectedBrand,
    String? selectedCategory,
    String? searchQuery,
    String? beamCalculationResult,
    String? driverCalculationResult,
    String? dmxCalculationResult,
    double? angle,
    double? height,
    double? distance,
    double? ampereParVoie,
    int? nbVoies,
    int? tension,
    String? selectedDriver,
    double? longueurLed,
    String? selectedRubanType,
    int? selectedPower,
    String? selectedLedType,
    String? selectedLedPower,
    String? selectedDriverNew,
    int? customChannels,
    double? customIntensity,
  }) {
    return LightPageState(
      selectedFixtures: selectedFixtures ?? this.selectedFixtures,
      fixtureQuantities: fixtureQuantities ?? this.fixtureQuantities,
      fixtureDmxModes: fixtureDmxModes ?? this.fixtureDmxModes,
      fixtureWifiModes: fixtureWifiModes ?? this.fixtureWifiModes,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      beamCalculationResult: beamCalculationResult ?? this.beamCalculationResult,
      driverCalculationResult: driverCalculationResult ?? this.driverCalculationResult,
      dmxCalculationResult: dmxCalculationResult ?? this.dmxCalculationResult,
      angle: angle ?? this.angle,
      height: height ?? this.height,
      distance: distance ?? this.distance,
      ampereParVoie: ampereParVoie ?? this.ampereParVoie,
      nbVoies: nbVoies ?? this.nbVoies,
      tension: tension ?? this.tension,
      selectedDriver: selectedDriver ?? this.selectedDriver,
      longueurLed: longueurLed ?? this.longueurLed,
      selectedRubanType: selectedRubanType ?? this.selectedRubanType,
      selectedPower: selectedPower ?? this.selectedPower,
      selectedLedType: selectedLedType ?? this.selectedLedType,
      selectedLedPower: selectedLedPower ?? this.selectedLedPower,
      selectedDriverNew: selectedDriverNew ?? this.selectedDriverNew,
      customChannels: customChannels ?? this.customChannels,
      customIntensity: customIntensity ?? this.customIntensity,
    );
  }

  /// Reset complet de la page
  LightPageState reset() {
    return const LightPageState();
  }
}

/// État persistant pour la page catalogue
class CataloguePageState {
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String? selectedBrand;
  final String? selectedProduct;
  final String searchQuery;

  const CataloguePageState({
    this.selectedCategory,
    this.selectedSubCategory,
    this.selectedBrand,
    this.selectedProduct,
    this.searchQuery = '',
  });

  CataloguePageState copyWith({
    String? selectedCategory,
    String? selectedSubCategory,
    String? selectedBrand,
    String? selectedProduct,
    String? searchQuery,
  }) {
    return CataloguePageState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedProduct: selectedProduct ?? this.selectedProduct,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  /// Reset complet de la page
  CataloguePageState reset() {
    return const CataloguePageState();
  }
}

/// État persistant pour la page vidéo
class VideoPageState {
  final String? selectedProduct;
  final String? selectedBrand;
  final String? selectedCategory;
  final String? selectedSubCategory;
  final String searchQuery;
  final bool showProjectionResult;
  final bool showLedResult;
  final double? projectionDistance;
  final double? projectionWidth;
  final double? projectionHeight;
  final double? largeurMurLed;
  final double? hauteurMurLed;
  final String? projectionCalculationResult;
  final String? ledCalculationResult;

  const VideoPageState({
    this.selectedProduct,
    this.selectedBrand,
    this.selectedCategory,
    this.selectedSubCategory,
    this.searchQuery = '',
    this.showProjectionResult = false,
    this.showLedResult = false,
    this.projectionDistance,
    this.projectionWidth,
    this.projectionHeight,
    this.largeurMurLed,
    this.hauteurMurLed,
    this.projectionCalculationResult,
    this.ledCalculationResult,
  });

  VideoPageState copyWith({
    String? selectedProduct,
    String? selectedBrand,
    String? selectedCategory,
    String? selectedSubCategory,
    String? searchQuery,
    bool? showProjectionResult,
    bool? showLedResult,
    double? projectionDistance,
    double? projectionWidth,
    double? projectionHeight,
    double? largeurMurLed,
    double? hauteurMurLed,
    String? projectionCalculationResult,
    String? ledCalculationResult,
  }) {
    return VideoPageState(
      selectedProduct: selectedProduct ?? this.selectedProduct,
      selectedBrand: selectedBrand ?? this.selectedBrand,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      selectedSubCategory: selectedSubCategory ?? this.selectedSubCategory,
      searchQuery: searchQuery ?? this.searchQuery,
      showProjectionResult: showProjectionResult ?? this.showProjectionResult,
      showLedResult: showLedResult ?? this.showLedResult,
      projectionDistance: projectionDistance ?? this.projectionDistance,
      projectionWidth: projectionWidth ?? this.projectionWidth,
      projectionHeight: projectionHeight ?? this.projectionHeight,
      largeurMurLed: largeurMurLed ?? this.largeurMurLed,
      hauteurMurLed: hauteurMurLed ?? this.hauteurMurLed,
      projectionCalculationResult: projectionCalculationResult ?? this.projectionCalculationResult,
      ledCalculationResult: ledCalculationResult ?? this.ledCalculationResult,
    );
  }

  /// Reset complet de la page
  VideoPageState reset() {
    return const VideoPageState();
  }
}

/// État persistant pour la page structure
class StructurePageState {
  final String selectedStructure;
  final double distance;
  final String selectedCharge;
  final bool showResult;
  final double? calculatedLoad;

  const StructurePageState({
    this.selectedStructure = 'Poutre simple',
    this.distance = 5,
    this.selectedCharge = 'Charge légère',
    this.showResult = false,
    this.calculatedLoad,
  });

  StructurePageState copyWith({
    String? selectedStructure,
    double? distance,
    String? selectedCharge,
    bool? showResult,
    double? calculatedLoad,
  }) {
    return StructurePageState(
      selectedStructure: selectedStructure ?? this.selectedStructure,
      distance: distance ?? this.distance,
      selectedCharge: selectedCharge ?? this.selectedCharge,
      showResult: showResult ?? this.showResult,
      calculatedLoad: calculatedLoad ?? this.calculatedLoad,
    );
  }

  /// Reset complet de la page
  StructurePageState reset() {
    return const StructurePageState();
  }
}

/// Providers pour chaque page
final lightPageStateProvider = StateNotifierProvider<LightPageStateNotifier, LightPageState>((ref) {
  return LightPageStateNotifier();
});

final cataloguePageStateProvider = StateNotifierProvider<CataloguePageStateNotifier, CataloguePageState>((ref) {
  return CataloguePageStateNotifier();
});

final videoPageStateProvider = StateNotifierProvider<VideoPageStateNotifier, VideoPageState>((ref) {
  return VideoPageStateNotifier();
});

final structurePageStateProvider = StateNotifierProvider<StructurePageStateNotifier, StructurePageState>((ref) {
  return StructurePageStateNotifier();
});

/// Notifiers pour chaque page
class LightPageStateNotifier extends StateNotifier<LightPageState> {
  LightPageStateNotifier() : super(const LightPageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedState = await PageStatePersistenceService.loadLightPageState();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'état lumière: $e');
    }
  }

  void _saveState() {
    PageStatePersistenceService.saveLightPageState(state);
  }

  void updateState(LightPageState newState) {
    state = newState;
    _saveState();
  }

  void reset() {
    state = state.reset();
    _saveState();
  }

  void updateSelectedFixtures(List<CatalogueItem> fixtures) {
    state = state.copyWith(selectedFixtures: fixtures);
    _saveState();
  }

  void updateFixtureQuantities(Map<CatalogueItem, int> quantities) {
    state = state.copyWith(fixtureQuantities: quantities);
    _saveState();
  }

  void updateSingleFixtureQuantity(CatalogueItem fixture, int quantity) {
    final newQuantities = Map<CatalogueItem, int>.from(state.fixtureQuantities);
    newQuantities[fixture] = quantity;
    state = state.copyWith(fixtureQuantities: newQuantities);
    _saveState();
  }

  void updateFixtureDmxModes(Map<CatalogueItem, String> modes) {
    state = state.copyWith(fixtureDmxModes: modes);
    _saveState();
  }

  void updateFixtureWifiModes(Map<CatalogueItem, bool> modes) {
    state = state.copyWith(fixtureWifiModes: modes);
    _saveState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _saveState();
  }

  void updateBeamCalculation(String? result) {
    state = state.copyWith(beamCalculationResult: result);
    _saveState();
  }

  void updateDriverCalculation(String? result) {
    state = state.copyWith(driverCalculationResult: result);
    _saveState();
  }

  void updateDmxCalculation(String? result) {
    state = state.copyWith(dmxCalculationResult: result);
    _saveState();
  }

  void clearDmxCalculation() {
    state = state.copyWith(dmxCalculationResult: null);
    _saveState();
  }

  void updateSelectedBrand(String? brand) {
    state = state.copyWith(selectedBrand: brand);
    _saveState();
  }

  void updateSelectedProduct(String? product) {
    state = state.copyWith(selectedProduct: product);
    _saveState();
  }

  void updateSelectedLedType(String ledType) {
    state = state.copyWith(selectedLedType: ledType);
    _saveState();
  }

  void updateSelectedLedPower(String ledPower) {
    state = state.copyWith(selectedLedPower: ledPower);
    _saveState();
  }

  void updateSelectedDriverNew(String driverNew) {
    state = state.copyWith(selectedDriverNew: driverNew);
    _saveState();
  }

  void updateCustomChannels(int channels) {
    state = state.copyWith(customChannels: channels);
    _saveState();
  }

  void updateCustomIntensity(double intensity) {
    state = state.copyWith(customIntensity: intensity);
    _saveState();
  }

  void updateLedLength(double length) {
    state = state.copyWith(longueurLed: length);
    _saveState();
  }

  void updateAngle(double angle) {
    state = state.copyWith(angle: angle);
    _saveState();
  }

  void updateHeight(double height) {
    state = state.copyWith(height: height);
    _saveState();
  }

  void updateDistance(double distance) {
    state = state.copyWith(distance: distance);
    _saveState();
  }

  void updateSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _saveState();
  }
}

class CataloguePageStateNotifier extends StateNotifier<CataloguePageState> {
  CataloguePageStateNotifier() : super(const CataloguePageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedState = await PageStatePersistenceService.loadCataloguePageState();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'état catalogue: $e');
    }
  }

  void _saveState() {
    PageStatePersistenceService.saveCataloguePageState(state);
  }

  void updateState(CataloguePageState newState) {
    state = newState;
    _saveState();
  }

  void reset() {
    state = state.reset();
    _saveState();
  }

  void updateSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _saveState();
  }

  void updateSelectedSubCategory(String? subCategory) {
    state = state.copyWith(selectedSubCategory: subCategory);
    _saveState();
  }

  void updateSelectedBrand(String? brand) {
    state = state.copyWith(selectedBrand: brand);
    _saveState();
  }

  void updateSelectedProduct(String? product) {
    state = state.copyWith(selectedProduct: product);
    _saveState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _saveState();
  }
}

class VideoPageStateNotifier extends StateNotifier<VideoPageState> {
  VideoPageStateNotifier() : super(const VideoPageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedState = await PageStatePersistenceService.loadVideoPageState();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'état vidéo: $e');
    }
  }

  void _saveState() {
    PageStatePersistenceService.saveVideoPageState(state);
  }

  void updateState(VideoPageState newState) {
    state = newState;
    _saveState();
  }

  void reset() {
    state = state.reset();
    _saveState();
  }

  void updateSelectedProduct(String? product) {
    state = state.copyWith(selectedProduct: product);
    _saveState();
  }

  void updateSelectedBrand(String? brand) {
    state = state.copyWith(selectedBrand: brand);
    _saveState();
  }

  void updateSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
    _saveState();
  }

  void updateProjectionResult(bool show, {double? distance, double? width, double? height}) {
    state = state.copyWith(
      showProjectionResult: show,
      projectionDistance: distance,
      projectionWidth: width,
      projectionHeight: height,
    );
    _saveState();
  }

  void updateSelectedCategory(String? category) {
    state = state.copyWith(selectedCategory: category);
    _saveState();
  }

  void updateSelectedSubCategory(String? subCategory) {
    state = state.copyWith(selectedSubCategory: subCategory);
    _saveState();
  }

  void updateLedResult(bool show, {double? largeur, double? hauteur}) {
    state = state.copyWith(
      showLedResult: show,
      largeurMurLed: largeur,
      hauteurMurLed: hauteur,
    );
    _saveState();
  }

  void updateProjectionCalculation(String? result) {
    state = state.copyWith(projectionCalculationResult: result);
    _saveState();
  }

  void updateLedCalculation(String? result) {
    state = state.copyWith(ledCalculationResult: result);
    _saveState();
  }
}

class StructurePageStateNotifier extends StateNotifier<StructurePageState> {
  StructurePageStateNotifier() : super(const StructurePageState()) {
    _loadState();
  }

  Future<void> _loadState() async {
    try {
      final savedState = await PageStatePersistenceService.loadStructurePageState();
      if (savedState != null) {
        state = savedState;
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'état structure: $e');
    }
  }

  void _saveState() {
    PageStatePersistenceService.saveStructurePageState(state);
  }

  void updateState(StructurePageState newState) {
    state = newState;
    _saveState();
  }

  void reset() {
    state = state.reset();
    _saveState();
  }

  void updateSelectedStructure(String structure) {
    state = state.copyWith(selectedStructure: structure);
    _saveState();
  }

  void updateDistance(double distance) {
    state = state.copyWith(distance: distance);
    _saveState();
  }

  void updateSelectedCharge(String charge) {
    state = state.copyWith(selectedCharge: charge);
    _saveState();
  }

  void updateCalculationResult(bool show, double? load) {
    state = state.copyWith(showResult: show, calculatedLoad: load);
    _saveState();
  }
}
