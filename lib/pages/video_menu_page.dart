// Nouvelle version stylée de VideoMenuPage avec sélection marque → produit en slide + outils calculs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../providers/page_state_provider.dart';
import '../models/catalogue_item.dart';
import '../widgets/preset_widget.dart';
import '../widgets/export_widget.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../providers/preset_provider.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'ar_measure_page.dart';
import '../models/lens.dart';
import '../widgets/action_button.dart';
import '../models/cart_item.dart';
import '../widgets/light_tabs/projection_tab.dart';
import 'timer_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VideoMenuPage extends ConsumerStatefulWidget {
  const VideoMenuPage({super.key});

  @override
  ConsumerState<VideoMenuPage> createState() => _VideoMenuPageState();
}

class _VideoMenuPageState extends ConsumerState<VideoMenuPage>
    with TickerProviderStateMixin {
  // Utilisation du provider de persistance
  VideoPageState get videoState => ref.watch(videoPageStateProvider);
  
  Map<String, List<CatalogueItem>> brandToProducts = {};
  late final AnimationController _slideController;
  late final TabController _tabController;
  CatalogueItem? selectedMurLed;
  List<CatalogueItem> searchResults = [];
  Offset? animationStartPosition;
  final GlobalKey _cardKey = GlobalKey();
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final GlobalKey _resultKey = GlobalKey();
  final TextEditingController searchController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String selectedFormat = '16/9';
  int nbProjecteurs = 1;
  double chevauchement = 15.0;
  final List<CatalogueItem> _selectedProducts = [];
  final Map<String, int> _fixtureQuantities = {};
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _projectionResultKey = GlobalKey();
  final GlobalKey _ledResultKey = GlobalKey();

  // Map pour stocker les sous-catégories par catégorie
  final Map<String, List<String>> categoryToSubCategories = {
    'Vidéo': ['Videoprojection', 'Mur LED', 'Écrans', 'Accessoires'],
  };

  // Map pour stocker les marques par sous-catégorie
  final Map<String, List<String>> subCategoryToBrands = {};

  @override
  void initState() {
    super.initState();

    // Initialiser les contrôleurs d'animation
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _tabController = TabController(length: 3, vsync: this);
    
    // Ajouter un listener pour sauvegarder l'onglet actif
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        _savePersistedState();
      }
    });

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    // Initialiser les données du catalogue
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCatalogueData();
      _loadPersistedState();
    });
  }

  void _initializeCatalogueData() {
    try {
      final items = ref.read(catalogueProvider);
      if (items.isEmpty) {
        // Si les données sont vides, on recharge le catalogue
        ref.read(catalogueProvider.notifier).loadCatalogue();
        return;
      }

      final projectors = items
          .where((item) =>
              item.categorie == 'Vidéo' &&
              item.sousCategorie == 'Videoprojection')
          .toList();

      brandToProducts = {};
      for (var item in projectors) {
        brandToProducts.putIfAbsent(item.marque, () => []).add(item);
      }

      // Initialiser les marques par sous-catégorie
      for (var item in items) {
        if (item.categorie == 'Vidéo') {
          subCategoryToBrands
              .putIfAbsent(item.sousCategorie, () => [])
              .add(item.marque);
        }
      }

      // Dédupliquer les marques
      subCategoryToBrands.forEach((key, value) {
        subCategoryToBrands[key] = value.toSet().toList()..sort();
      });

      // Notifier le widget que les données sont chargées
      setState(() {});
    } catch (e) {
      print('Error initializing catalogue data: $e');
      brandToProducts = {};
      subCategoryToBrands.clear();
    }
  }

  Lens? getRecommendedLens(CatalogueItem proj, double ratio) {
    if (proj.optiques == null || proj.optiques!.isEmpty) return null;

    print('🔍 getRecommendedLens: ratio calculé = $ratio');
    print('🔍 Projecteur: ${proj.name}');
    print('🔍 Nombre d\'optiques: ${proj.optiques!.length}');

    // LOGIQUE SIMPLIFIÉE ET ROBUSTE
    // 1. Chercher d'abord une optique dont la plage contient le ratio calculé
    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
      print('🔍 Test optique: ${lens.reference} - ${lens.ratio}');

      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        print('🔍 Optique fixe: ratio = $lensRatio');
        if (lensRatio != -1 && (lensRatio - ratio).abs() < 0.1) {
          print('✅ Optique fixe trouvée: ${lens.reference}');
          return lens;
        }
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
          print('🔍 Plage: min = $min, max = $max');
          
          if (min != -1 && max != -1 && min <= ratio && ratio <= max) {
            print('✅ Optique avec plage trouvée: ${lens.reference}');
            return lens;
          }
        }
      }
    }

    print('⚠️ Aucune optique ne contient le ratio, recherche de la plus proche...');

    // 2. Si aucune optique ne contient le ratio, chercher la plus proche
    Lens? bestLens;
    double bestRatioDiff = double.infinity;

    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
      double lensRatio;

      // Gérer les optiques fixes
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == -1) continue;
      }
      // Gérer les optiques avec plage
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
          if (min == -1 || max == -1) continue;
          
          // Utiliser le ratio moyen de la plage pour la comparaison
          lensRatio = (min + max) / 2;
        } else {
          continue;
        }
      }

      // Calculer la différence absolue avec le ratio calculé
      final ratioDiff = (ratio - lensRatio).abs();
      print('🔍 ${lens.reference}: ratio = $lensRatio, diff = $ratioDiff');

      // Garder l'optique avec la différence la plus petite
      if (ratioDiff < bestRatioDiff) {
        bestLens = lens;
        bestRatioDiff = ratioDiff;
      }
    }

    if (bestLens != null) {
      print('✅ Optique la plus proche: ${bestLens.reference}');
    } else {
      print('❌ Aucune optique trouvée');
    }

    return bestLens;
  }

  double _parseRatio(String ratioStr) {
    try {
      if (ratioStr.contains('–') || ratioStr.contains('-')) {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        return (min + max) / 2;
      } else {
        return double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
      }
    } catch (_) {
      return -1;
    }
  }

  void _navigateTo(int index) {
    switch (index) {
      case 0:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CataloguePage()),
        );
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LightMenuPage()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StructureMenuPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SoundMenuPage()),
        );
        break;
      case 4:
        // Already on video page
        break;
      case 5:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ElectriciteMenuPage()),
        );
        break;
      case 6:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DiversMenuPage()),
        );
        break;
    }
  }

  void _resetSelection() {
    ref.read(videoPageStateProvider.notifier).updateSelectedCategory(null);
    ref.read(videoPageStateProvider.notifier).updateSelectedSubCategory(null);
    ref.read(videoPageStateProvider.notifier).updateSelectedBrand(null);
    ref.read(videoPageStateProvider.notifier).updateSearchQuery('');
    ref.read(videoPageStateProvider.notifier).updateProjectionResult(false);
    ref.read(videoPageStateProvider.notifier).updateLedResult(false);
    setState(() {
      selectedMurLed = null;
      searchResults = [];
      searchController.clear();
    });
  }

  void _scrollToResult() {
    final key = _tabController.index == 0 ? _projectionResultKey : _ledResultKey;
    if (key.currentContext != null) {
      final RenderBox box = key.currentContext!.findRenderObject() as RenderBox;
      final position = box.localToGlobal(Offset.zero);
      final scrollPosition = position.dy - MediaQuery.of(context).size.height / 2;
      
      _scrollController.animateTo(
        _scrollController.offset + scrollPosition,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
      );
    } else {
      // Si le contexte n'est pas encore disponible, attendre un peu et réessayer
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          _scrollToResult();
        }
      });
    }
  }

  void _calculateSimulation() {
    if (_tabController.index == 0) {
      ref.read(videoPageStateProvider.notifier).updateProjectionResult(true);
      ref.read(videoPageStateProvider.notifier).updateLedResult(false);
    }
    
    // Attendre que le widget soit construit avant de faire défiler
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToResult();
    });
  }

  String _getMurLedDimensions(CatalogueItem? item) {
    if (item == null) return '500 x 500';
    final dims = item.dimensions.split('x').map((e) => e.trim()).toList();
    if (dims.length >= 2) {
      return '${dims[0]} x ${dims[1]}';
    }
    return item.dimensions;
  }

  String _getMurLedResolution(CatalogueItem? item) {
    if (item == null) return '200 x 200';
    return item.resolutionDalle ?? '200 x 200';
  }

  double _getMurLedWeight(CatalogueItem? item) {
    if (item == null) return 10.0;
    return double.tryParse(item.poids.replaceAll(' kg', '')) ?? 10.0;
  }

  double _getMurLedConsumption(CatalogueItem? item) {
    if (item == null) return 200.0;
    return double.tryParse(item.conso.replaceAll(' W', '')) ?? 200.0;
  }

  // Fonction utilitaire pour calculer les dimensions pixellaires du mur LED
  Map<String, int> _calculateLedWallPixels(CatalogueItem? item, double largeur, double hauteur) {
    if (item == null) {
      return {'largeur': 200, 'hauteur': 200, 'total': 40000};
    }
    
    final resolution = _getMurLedResolution(item);
    print('DEBUG: Resolution from item: $resolution'); // Debug
    
    // Utiliser une regex pour extraire directement les nombres
    final regex = RegExp(r'(\d+)\s*x\s*(\d+)');
    final match = regex.firstMatch(resolution);
    
    if (match == null) {
      print('DEBUG: Invalid resolution format: $resolution');
      return {'largeur': 200, 'hauteur': 200, 'total': 40000};
    }
    
    final cleanX = match.group(1)!;
    final cleanY = match.group(2)!;
    
    print('DEBUG: Cleaned X: "$cleanX", Cleaned Y: "$cleanY"'); // Debug
    
    final resX = int.tryParse(cleanX) ?? 200;
    final resY = int.tryParse(cleanY) ?? 200;
    
    print('DEBUG: Parsed resX: $resX, resY: $resY'); // Debug
    
    final largeurPixels = resX * largeur.toInt();
    final hauteurPixels = resY * hauteur.toInt();
    final totalPixels = largeurPixels * hauteurPixels;
    
    return {
      'largeur': largeurPixels,
      'hauteur': hauteurPixels,
      'total': totalPixels,
      'resX': resX,
      'resY': resY,
    };
  }

  String _generateSchemaContent() {
    if (selectedMurLed == null) return 'Aucun mur LED sélectionné';
    
    final nbDalles = ((videoState.largeurMurLed ?? 1) * (videoState.hauteurMurLed ?? 1)).toInt();
    final dimensions = _getMurLedDimensions(selectedMurLed);
    final resolution = _getMurLedResolution(selectedMurLed);
    final poids = _getMurLedWeight(selectedMurLed);
    final conso = _getMurLedConsumption(selectedMurLed);
    
    final presetName = ref.watch(activePresetProvider)?.name ?? 'Projet';
    final largeur = videoState.largeurMurLed ?? 1;
    final hauteur = videoState.hauteurMurLed ?? 1;
    
    // Utilisation de la fonction utilitaire pour les calculs
    final pixels = _calculateLedWallPixels(selectedMurLed, largeur, hauteur);
    final megapixels = pixels['total']! / 1000000;
    final ratio = largeur / hauteur;
    
    return '''
MUR LED - $presetName

Configuration:
- Nombre de dalles: $nbDalles
- Dimensions par dalle: $dimensions
- Résolution par dalle: $resolution
- Poids total: ${(poids * nbDalles).toStringAsFixed(1)} kg
- Consommation totale: ${(conso * nbDalles).toStringAsFixed(0)} W

Calculs détaillés:
- Espace pixellaire: ${pixels['largeur']}px x ${pixels['hauteur']}px
- Résolution totale: ${megapixels.toStringAsFixed(1)} Mpx
- Ratio: ${ratio.toStringAsFixed(2)}:1

Schéma de montage:
- Largeur: ${largeur.toInt()} dalles
- Hauteur: ${hauteur.toInt()} dalles
- Disposition: ${largeur.toInt()}x${hauteur.toInt()}
''';
  }

  Map<String, dynamic> _buildLedWallProjectSummary() {
    if (selectedMurLed == null) return {};
    
    final nbDalles = ((videoState.largeurMurLed ?? 1) * (videoState.hauteurMurLed ?? 1)).toInt();
    final dimensions = _getMurLedDimensions(selectedMurLed);
    final resolution = _getMurLedResolution(selectedMurLed);
    final poids = _getMurLedWeight(selectedMurLed);
    final conso = _getMurLedConsumption(selectedMurLed);
    
    final largeur = videoState.largeurMurLed ?? 1;
    final hauteur = videoState.hauteurMurLed ?? 1;
    
    // Calculer les dimensions totales du mur en mètres
    final dimensionsParts = dimensions.split(' x ');
    final dalleLargeur = double.tryParse(dimensionsParts[0].trim().replaceAll(' mm', '')) ?? 500;
    final dalleHauteur = double.tryParse(dimensionsParts[1].trim().replaceAll(' mm', '')) ?? 500;
    
    final largeurTotale = (dalleLargeur / 1000) * largeur;
    final hauteurTotale = (dalleHauteur / 1000) * hauteur;
    
    // Utilisation de la fonction utilitaire pour les calculs
    final pixels = _calculateLedWallPixels(selectedMurLed, largeur, hauteur);
    final megapixels = pixels['total']! / 1000000;
    final ratio = largeur / hauteur;
    
    return {
      'mur_led': selectedMurLed!.name,
      'marque': selectedMurLed!.marque,
      'produit': selectedMurLed!.produit,
      'dimensions': '${largeur.toInt()} x ${hauteur.toInt()}',
      'dimensions_totales': '${largeurTotale.toStringAsFixed(2)}m x ${hauteurTotale.toStringAsFixed(2)}m',
      'nb_dalles': nbDalles,
      'dimensions_dalle': dimensions,
      'resolution_dalle': resolution,
      'resolution_totale': '${pixels['largeur']}px x ${pixels['hauteur']}px',
      'megapixels': '${megapixels.toStringAsFixed(1)} Mpx',
      'ratio': '${ratio.toStringAsFixed(2)}:1',
      'poids_total': '${(poids * nbDalles).toStringAsFixed(1)} kg',
      'consommation_total': '${(conso * nbDalles).toStringAsFixed(0)} W',
      'poids_dalle': '${poids.toStringAsFixed(1)} kg',
      'consommation_dalle': '${conso.toStringAsFixed(0)} W',
      'largeur_dalles': largeur.toInt(),
      'hauteur_dalles': hauteur.toInt(),
      'resX': pixels['resX'],
      'resY': pixels['resY'],
    };
  }

  // Méthodes de persistance
  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Attendre un peu pour s'assurer que le widget est prêt
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      print('Video: Loading persisted state...');
      
      // Restaurer l'onglet actif
      final savedTabIndex = prefs.getInt('video_tab_index');
      if (savedTabIndex != null && savedTabIndex >= 0 && savedTabIndex < 3) {
        _tabController.index = savedTabIndex;
        print('Video: Restored tab index: $savedTabIndex');
      }
      
      // Restaurer les paramètres de projection
      final savedProjectionWidth = prefs.getDouble('video_projection_width');
      final savedProjectionDistance = prefs.getDouble('video_projection_distance');
      final savedSelectedFormat = prefs.getString('video_selected_format');
      final savedNbProjecteurs = prefs.getInt('video_nb_projecteurs');
      final savedChevauchement = prefs.getDouble('video_chevauchement');
      final savedSelectedProduct = prefs.getString('video_selected_product');
      final savedShowProjectionResult = prefs.getBool('video_show_projection_result');
      
      if (!mounted) return;
      
      // Restaurer les paramètres de projection via le provider
      if (savedProjectionWidth != null) {
        ref.read(videoPageStateProvider.notifier).updateProjectionResult(false, width: savedProjectionWidth);
        print('Video: Restored projection width: $savedProjectionWidth');
      }
      
      if (savedProjectionDistance != null) {
        ref.read(videoPageStateProvider.notifier).updateProjectionResult(false, distance: savedProjectionDistance);
        print('Video: Restored projection distance: $savedProjectionDistance');
      }
      
      if (savedSelectedFormat != null && ['16/9', '4/3', '1/1'].contains(savedSelectedFormat)) {
        setState(() {
          selectedFormat = savedSelectedFormat;
        });
        print('Video: Restored selected format: $selectedFormat');
      }
      
      if (savedNbProjecteurs != null && savedNbProjecteurs >= 1 && savedNbProjecteurs <= 10) {
        setState(() {
          nbProjecteurs = savedNbProjecteurs;
        });
        print('Video: Restored nb projecteurs: $nbProjecteurs');
      }
      
      if (savedChevauchement != null && savedChevauchement >= 0 && savedChevauchement <= 50) {
        setState(() {
          chevauchement = savedChevauchement;
        });
        print('Video: Restored chevauchement: $chevauchement');
      }
      
      if (savedSelectedProduct != null) {
        ref.read(videoPageStateProvider.notifier).updateSelectedProduct(savedSelectedProduct);
        print('Video: Restored selected product: $savedSelectedProduct');
      }
      
      if (savedShowProjectionResult != null) {
        ref.read(videoPageStateProvider.notifier).updateProjectionResult(savedShowProjectionResult);
        print('Video: Restored show projection result: $savedShowProjectionResult');
      }
      
      // Restaurer les paramètres de mur LED
      final savedLargeurMurLed = prefs.getDouble('video_largeur_mur_led');
      final savedHauteurMurLed = prefs.getDouble('video_hauteur_mur_led');
      final savedSelectedMurLedBrand = prefs.getString('video_selected_mur_led_brand');
      final savedSelectedMurLedProduct = prefs.getString('video_selected_mur_led_product');
      final savedShowLedResult = prefs.getBool('video_show_led_result');
      
      if (savedLargeurMurLed != null && savedLargeurMurLed >= 1 && savedLargeurMurLed <= 50) {
        ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: savedLargeurMurLed, hauteur: videoState.hauteurMurLed);
        print('Video: Restored largeur mur LED: $savedLargeurMurLed');
      }
      
      if (savedHauteurMurLed != null && savedHauteurMurLed >= 1 && savedHauteurMurLed <= 20) {
        ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: videoState.largeurMurLed, hauteur: savedHauteurMurLed);
        print('Video: Restored hauteur mur LED: $savedHauteurMurLed');
      }
      
      if (savedSelectedMurLedBrand != null) {
        // Restaurer la marque sélectionnée
        final ledWalls = _getLedWalls();
        final brandWalls = ledWalls.where((item) => item.marque == savedSelectedMurLedBrand).toList();
        if (brandWalls.isNotEmpty) {
          setState(() {
            selectedMurLed = brandWalls.first;
          });
          print('Video: Restored selected mur LED brand: $savedSelectedMurLedBrand');
        }
      }
      
      if (savedSelectedMurLedProduct != null) {
        // Restaurer le produit sélectionné
        final ledWalls = _getLedWalls();
        try {
          final product = ledWalls.firstWhere((item) => item.produit == savedSelectedMurLedProduct);
          setState(() {
            selectedMurLed = product;
          });
          print('Video: Restored selected mur LED product: $savedSelectedMurLedProduct');
        } catch (e) {
          print('Video: Could not restore mur LED product: $e');
        }
      }
      
      if (savedShowLedResult != null) {
        ref.read(videoPageStateProvider.notifier).updateLedResult(savedShowLedResult);
        print('Video: Restored show LED result: $savedShowLedResult');
      }
      
      print('Video: Persistence restoration completed successfully');
    } catch (e) {
      print('Video: Error loading persisted state: $e');
    }
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('Video: Saving state...');
      
      // Sauvegarder l'onglet actif
      await prefs.setInt('video_tab_index', _tabController.index);
      
      // Sauvegarder les paramètres de projection
      await prefs.setDouble('video_projection_width', videoState.projectionWidth ?? 5);
      await prefs.setDouble('video_projection_distance', videoState.projectionDistance ?? 10);
      await prefs.setString('video_selected_format', selectedFormat);
      await prefs.setInt('video_nb_projecteurs', nbProjecteurs);
      await prefs.setDouble('video_chevauchement', chevauchement);
      await prefs.setString('video_selected_product', videoState.selectedProduct ?? '');
      await prefs.setBool('video_show_projection_result', videoState.showProjectionResult);
      
      // Sauvegarder les paramètres de mur LED
      await prefs.setDouble('video_largeur_mur_led', videoState.largeurMurLed ?? 1);
      await prefs.setDouble('video_hauteur_mur_led', videoState.hauteurMurLed ?? 1);
      await prefs.setString('video_selected_mur_led_brand', selectedMurLed?.marque ?? '');
      await prefs.setString('video_selected_mur_led_product', selectedMurLed?.produit ?? '');
      await prefs.setBool('video_show_led_result', videoState.showLedResult);
      
      print('Video: State saved successfully');
    } catch (e) {
      print('Video: Error saving state: $e');
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    searchController.dispose();
    _savePersistedState();
    super.dispose();
  }

  List<CatalogueItem> _getProjectors() {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' &&
            item.sousCategorie == 'Videoprojection')
        .toList();
  }

  List<CatalogueItem> _getScreens() {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' && item.sousCategorie == 'Écrans')
        .toList();
  }

  List<CatalogueItem> _getAccessories() {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' && item.sousCategorie == 'Accessoires')
        .toList();
  }

  void _showQuantityDialog(CatalogueItem item) {
    showDialog(
      context: context,
      builder: (context) {
        final loc = AppLocalizations.of(context)!;
        int quantity = _fixtureQuantities[item.id] ?? 1;
        return AlertDialog(
          title: Text(item.produit),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${loc.quantity}: $quantity'),
              Slider(
                value: quantity.toDouble(),
                min: 1,
                max: 100,
                divisions: 99,
                label: quantity.toString(),
                onChanged: (value) {
                  setState(() {
                    quantity = value.toInt();
                  });
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _fixtureQuantities[item.id] = quantity;
                  if (!_selectedProducts.contains(item)) {
                    _selectedProducts.add(item);
                  }
                });
                Navigator.pop(context);
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }

  List<CatalogueItem> _getLedWalls() {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' &&
            item.sousCategorie == 'Mur LED')
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final projectors = _getProjectors();
    final screens = _getScreens();
    final accessories = _getAccessories();

    // Calcul de la largeur par projecteur en fonction de la largeur totale
    double largeurParProjecteur;
    double overlapWidth = 0.0;

    if (nbProjecteurs > 1) {
      // Calcul de la largeur de base par projecteur
      double largeurBase = (videoState.projectionWidth ?? 5) / nbProjecteurs;

      // Calcul du chevauchement en fonction de la largeur de base
      overlapWidth = largeurBase * (chevauchement / 100);

      // Chaque projecteur a besoin de sa largeur de base plus les chevauchements
      largeurParProjecteur = largeurBase + (2 * overlapWidth);
    } else {
      largeurParProjecteur = videoState.projectionWidth ?? 5;
    }

    // Calcul de la hauteur en fonction du format 16/9 pour la largeur par projecteur
    double hauteurTotale = largeurParProjecteur * (9 / 16);

    // Calcul du ratio en fonction du format
    // Pour le softage, utiliser la largeur de base de chaque VP (sans chevauchement)
    double largeurPourRatio = nbProjecteurs > 1 
        ? (videoState.projectionWidth ?? 5) / nbProjecteurs  // Largeur de base par VP
        : (videoState.projectionWidth ?? 5);  // Largeur totale si un seul VP
    
    double baseRatio = (videoState.projectionDistance ?? 10) / largeurPourRatio;
    double ratio;
    switch (selectedFormat) {
      case '4/3':
        ratio = baseRatio * (4 / 3) / (16 / 9);
        break;
      case '1/1':
        ratio = baseRatio * (1 / 1) / (16 / 9);
        break;
      default: // 16/9
        ratio = baseRatio;
    }

    CatalogueItem? selectedProjector;
    if (videoState.selectedProduct != null) {
      try {
        selectedProjector = ref.watch(catalogueProvider).firstWhere(
          (item) => item.produit == videoState.selectedProduct,
        );
      } catch (e) {
        selectedProjector = null;
      }
    }
    final recommendation = selectedProjector != null
        ? getRecommendedLens(selectedProjector, ratio)
        : null;

    // Filtrer les résultats de recherche en fonction de l'onglet actif
    if (videoState.searchQuery.isNotEmpty) {
      searchResults = ref.watch(catalogueProvider).where((item) {
        final matchesSearch =
            item.marque.toLowerCase().contains(videoState.searchQuery.toLowerCase()) ||
                item.produit.toLowerCase().contains(videoState.searchQuery.toLowerCase());

        // Filtrer selon l'onglet actif
        if (_tabController.index == 0) {
          // Onglet Calcul Projection
          return item.categorie == 'Vidéo' &&
              item.sousCategorie == 'Videoprojection' &&
              matchesSearch;
        } else {
          // Onglet Calcul Mur LED
          return item.categorie == 'Vidéo' &&
              item.sousCategorie == 'Mur LED' &&
              matchesSearch;
        }
      }).toList();
    } else {
      searchResults = [];
    }

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.videocam,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        margin: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Theme.of(context).brightness == Brightness.dark 
                              ? Colors.lightBlue[300] 
                              : const Color(0xFF0A1128),
                          unselectedLabelColor: Colors.white.withOpacity(0.7),
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calculate, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Proj', // Abrégé de "Projection"
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.calculate, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'LED', // Déjà court
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(Icons.timer, size: 16),
                                  SizedBox(width: 4),
                                  Text(
                                    'Timer', // Déjà court
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      PresetWidget(
                        onPresetSelected: (preset) {
                          final index =
                              ref.read(presetProvider).indexOf(preset);
                          if (index != -1) {
                            ref
                                .read(presetProvider.notifier)
                                .selectPreset(index);
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            const ProjectionTab(),
                            SingleChildScrollView(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A1128)
                                          .withAlpha((0.3 * 255).toInt()),
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: BorderLabeledDropdown<String>(
                                                label: loc.videoPage_brand,
                                                value: selectedMurLed?.marque,
                                                items: _getLedWalls()
                                                    .map((item) => item.marque)
                                                    .toSet()
                                                    .map((marque) =>
                                                        DropdownMenuItem(
                                                          value: marque,
                                                          child: Text(marque, style: const TextStyle(fontSize: 11)),
                                                        ))
                                                    .toList(),
                                          onChanged: (marque) {
                                            if (marque != null) {
                                              final items = _getLedWalls()
                                                  .where((item) =>
                                                      item.marque == marque)
                                                  .toList();
                                              if (items.isNotEmpty) {
                                                ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: 1, hauteur: 1);
                                                setState(() {
                                                  selectedMurLed = items.first;
                                                });
                                                _savePersistedState();
                                              }
                                            }
                                          },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: BorderLabeledDropdown<CatalogueItem>(
                                                label: loc.videoPage_selectLedWall,
                                                value: selectedMurLed,
                                                items: _getLedWalls()
                                                    .where((item) => 
                                                      selectedMurLed?.marque == null || 
                                                      item.marque == selectedMurLed?.marque)
                                                    .map((item) =>
                                                        DropdownMenuItem(
                                                          value: item,
                                                          child: Text(
                                                            '${item.marque} - ${item.produit}',
                                                            style: const TextStyle(fontSize: 11),
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (item) {
                                                  if (item != null) {
                                                    ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: 1, hauteur: 1);
                                                    setState(() {
                                                      selectedMurLed = item;
                                                    });
                                                    _savePersistedState();
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                            'Largeur : ${(videoState.largeurMurLed ?? 1).toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * (videoState.largeurMurLed ?? 1)).toStringAsFixed(2)} m',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                        Slider(
                                          value: videoState.largeurMurLed ?? 1,
                                          min: 1,
                                          max: 50,
                                          divisions: 49,
                                          label:
                                              '${(videoState.largeurMurLed ?? 1).toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * (videoState.largeurMurLed ?? 1)).toStringAsFixed(2)} m',
                                          onChanged: (value) {
                                            ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: value, hauteur: videoState.hauteurMurLed);
                                            _savePersistedState();
                                          },
                                        ),
                                        Text(
                                            'Hauteur : ${(videoState.hauteurMurLed ?? 1).toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * (videoState.hauteurMurLed ?? 1)).toStringAsFixed(2)} m',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                        Slider(
                                          value: videoState.hauteurMurLed ?? 1,
                                          min: 1,
                                          max: 20,
                                          divisions: 19,
                                          label:
                                              '${(videoState.hauteurMurLed ?? 1).toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * (videoState.hauteurMurLed ?? 1)).toStringAsFixed(2)} m',
                                          onChanged: (value) {
                                            ref.read(videoPageStateProvider.notifier).updateLedResult(false, largeur: videoState.largeurMurLed, hauteur: value);
                                            _savePersistedState();
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        ActionButtonRow(
                                          buttons: [
                                            ActionButton.photo(
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const ArMeasurePage()),
                                                );
                                              },
                                            ),
                                            ActionButton.calculate(
                                              onPressed: () {
                                                if (_tabController.index == 1) {
                                                  ref.read(videoPageStateProvider.notifier).updateLedResult(true);
                                                  ref.read(videoPageStateProvider.notifier).updateProjectionResult(false);
                                                  
                                                  // Attendre que le widget soit construit avant de faire défiler
                                                  WidgetsBinding.instance.addPostFrameCallback((_) {
                                                    _scrollToResult();
                                                  });
                                                  
                                                  _savePersistedState();
                                                }
                                              },
                                            ),
                                            ActionButton.reset(
                                              onPressed: _resetSelection,
                                            ),
                                          ],
                                        ),
                                        if (videoState.showLedResult)
                                          Container(
                                            key: _ledResultKey,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A1128)
                                                  .withOpacity(0.3),
                                              border: Border.all(
                                                  color:
                                                      const Color(0xFF0A1128),
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                // Titre "Mur LED 'NomProjet'"
                                                Center(
                                                  child: Text(
                                                    'Mur LED \'${ref.watch(activePresetProvider)?.name ?? 'Projet'}\'',
                                                    style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 18,
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(height: 16),
                                                Center(
                                                  child: Text(
                                                      '${((videoState.largeurMurLed ?? 1) * (videoState.hauteurMurLed ?? 1)).toInt()} ${loc.videoLedResult_dalles} (${_getMurLedDimensions(selectedMurLed)} /u)',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Builder(
                                                    builder: (context) {
                                                      final pixels = _calculateLedWallPixels(
                                                        selectedMurLed, 
                                                        videoState.largeurMurLed ?? 1, 
                                                        videoState.hauteurMurLed ?? 1
                                                      );
                                                      return Text(
                                                          '${loc.videoLedResult_espacePixellaire} : ${pixels['largeur']}px x ${pixels['hauteur']}px (${pixels['resX']} x ${pixels['resY']} /dalle)',
                                                          style: const TextStyle(
                                                              color: Colors.white),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Center(
                                                  child: Builder(
                                                    builder: (context) {
                                                      final pixels = _calculateLedWallPixels(
                                                        selectedMurLed, 
                                                        videoState.largeurMurLed ?? 1, 
                                                        videoState.hauteurMurLed ?? 1
                                                      );
                                                      final megapixels = pixels['total']! / 1000000;
                                                      final ratio = (videoState.largeurMurLed ?? 1) / (videoState.hauteurMurLed ?? 1);
                                                      return Text(
                                                          '${megapixels.toStringAsFixed(1)} Mpx / Ratio ${ratio.toStringAsFixed(2)}:1',
                                                          style: const TextStyle(
                                                              color: Colors.white),
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Center(
                                                  child: Text(
                                                      '${loc.videoLedResult_poidsTotal} : ${(_getMurLedWeight(selectedMurLed) * (videoState.largeurMurLed ?? 1) * (videoState.hauteurMurLed ?? 1)).toStringAsFixed(1)} kg',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      '${loc.videoLedResult_consommationTotale} : ${(_getMurLedConsumption(selectedMurLed) * (videoState.largeurMurLed ?? 1) * (videoState.hauteurMurLed ?? 1)).toStringAsFixed(0)} W',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    Transform.rotate(
                                                      angle: 3.14159, // 180° en radians
                                                      child: ExportWidget(
                                                        title: 'Schémas Mur LED',
                                                        content: _generateSchemaContent(),
                                                        projectType: 'led_wall',
                                                        fileName: 'schemas_mur_led',
                                                        customIcon: Icons.schema,
                                                        backgroundColor: Colors.white,
                                                        tooltip: 'Exporter les schémas',
                                                        projectSummary: _buildLedWallProjectSummary(),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    ActionButton(
                                                      icon: Icons.shopping_cart,
                                                      onPressed: selectedMurLed ==
                                                                  null ||
                                                              ref
                                                                      .read(presetProvider
                                                                          .notifier)
                                                                      .selectedPresetIndex <
                                                                  0
                                                          ? null
                                                          : () {
                                                              final preset = ref
                                                                  .read(
                                                                      presetProvider)[ref
                                                                  .read(presetProvider
                                                                      .notifier)
                                                                  .selectedPresetIndex];
                                                              final int
                                                                  nbDalles =
                                                                  ((videoState.largeurMurLed ?? 1) *
                                                                          (videoState.hauteurMurLed ?? 1))
                                                                      .toInt();
                                                              setState(() {
                                                                final existingIndex =
                                                                    preset.items
                                                                        .indexWhere(
                                                                  (item) =>
                                                                      item.item.id ==
                                                                      selectedMurLed!
                                                                          .id,
                                                                );
                                                                if (existingIndex !=
                                                                    -1) {
                                                                  preset.items[existingIndex] = CartItem(
                                                                    item: selectedMurLed!,
                                                                    quantity: nbDalles,
                                                                  );
                                                                } else {
                                                                  preset.items.add(
                                                                    CartItem(
                                                                      item: selectedMurLed!,
                                                                      quantity: nbDalles,
                                                                    ),
                                                                  );
                                                                }
                                                                ref
                                                                    .read(presetProvider
                                                                        .notifier)
                                                                    .updatePreset(
                                                                        preset);
                                                              });
                                                            },
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const TimerTab(),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (animationStartPosition != null)
            Positioned(
              left: animationStartPosition!.dx,
              top: animationStartPosition!.dy,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: Offset.zero,
                  end: const Offset(0, -1),
                ).animate(_animation),
                child: FadeTransition(
                  opacity: _animation,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Calcul effectué !',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 4,
        onTap: _navigateTo,
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Catalogue'),
          BottomNavigationBarItem(
              icon: const Icon(Icons.lightbulb), label: loc.lightMenu),
          BottomNavigationBarItem(
              icon: Image.asset('assets/truss_icon_grey.png',
                  width: 24, height: 24),
              label: loc.structureMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.volume_up), label: loc.soundMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.videocam), label: loc.videoMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.bolt), label: loc.electricityMenu),
          BottomNavigationBarItem(
              icon: const Icon(Icons.more_horiz), label: loc.networkMenu),
        ],
      ),
    );
  }
}

