// Nouvelle version stylée de VideoMenuPage avec sélection marque → produit en slide + outils calculs
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../widgets/preset_widget.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import 'led_wall_schema_page.dart';
import '../providers/preset_provider.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'ar_measure_page.dart';
import 'projection_schema_page.dart';
import '../models/lens.dart';
import '../models/cart_item.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../widgets/action_button.dart';
import '../widgets/export_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class VideoMenuPage extends ConsumerStatefulWidget {
  const VideoMenuPage({super.key});

  @override
  ConsumerState<VideoMenuPage> createState() => _VideoMenuPageState();
}

class _VideoMenuPageState extends ConsumerState<VideoMenuPage>
    with TickerProviderStateMixin {
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedBrand;
  CatalogueItem? selectedProjector;
  double largeurProjection = 5;
  double distanceProjection = 10;
  double largeurMurLed = 12;
  double hauteurMurLed = 7;
  Map<String, List<CatalogueItem>> brandToProducts = {};
  late final AnimationController _slideController;
  late final TabController _tabController;
  CatalogueItem? selectedMurLed;
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  Offset? animationStartPosition;
  late final AnimationController _animationController;
  late final Animation<double> _animation;
  final TextEditingController searchController = TextEditingController();
  bool showProjectionResult = false;
  bool showLedResult = false;
  String selectedFormat = '16/9';
  int nbProjecteurs = 1;
  double chevauchement = 15.0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _projectionResultKey = GlobalKey();
  final GlobalKey _ledResultKey = GlobalKey();
  
  // Gestion des commentaires
  Map<String, String> _comments = {};

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

    _tabController = TabController(length: 2, vsync: this);

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
      _loadComments();
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

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('video_comments');
      if (commentsJson != null) {
        final Map<String, dynamic> commentsMap = json.decode(commentsJson);
        _comments = commentsMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = json.encode(_comments);
      await prefs.setString('video_comments', commentsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
    }
  }

  String _getCommentForTab(String tabKey) {
    return _comments[tabKey] ?? '';
  }

  String _generateProjectionResultKey() {
    return 'projection_tab';
  }

  Future<void> _showCommentDialog(String tabKey, String tabName) async {
    final TextEditingController commentController = TextEditingController(
      text: _getCommentForTab(tabKey),
    );

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0A1128),
          title: Text(
            'Commentaire - $tabName',
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
          content: TextField(
            controller: commentController,
            maxLines: 3,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Entrez votre commentaire...',
              hintStyle: TextStyle(color: Colors.grey),
              border: OutlineInputBorder(),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.blue),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler', style: TextStyle(color: Colors.white)),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                setState(() {
                  if (comment.isEmpty) {
                    _comments.remove(tabKey);
                  } else {
                    _comments[tabKey] = comment;
                  }
                });
                await _saveComments();
                Navigator.of(context).pop();
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  Lens? getRecommendedLens(CatalogueItem proj, double ratio) {
    if (proj.optiques == null || proj.optiques!.isEmpty) return null;

    // Convertir toutes les optiques en Map avec leur ratio moyen
    final optiques = proj.optiques!;
    final validLenses = optiques
        .map((lens) => MapEntry(lens, _parseRatio(lens.ratio)))
        .where((entry) => entry.value != -1)
        .toList();

    if (validLenses.isEmpty) return null;

    // Chercher d'abord une optique avec un ratio exact
    for (var entry in validLenses) {
      final lens = entry.key;
      final ratioStr = lens.ratio.toLowerCase();

      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == ratio) return lens;
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        if (min <= ratio && ratio <= max) return lens;
      }
    }

    // Si aucune optique exacte n'est trouvée, chercher l'optique avec le ratio le plus proche mais inférieur
    Lens? bestLens;
    double? bestRatioDiff;

    for (var entry in validLenses) {
      final lens = entry.key;
      final ratioStr = lens.ratio.toLowerCase();
      double lensRatio;

      // Gérer les optiques fixes
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == -1 || lensRatio > ratio) continue;
      }
      // Gérer les optiques avec plage
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        if (min == -1 || max == -1 || min > ratio) continue;
        lensRatio = min; // On prend le ratio minimum de la plage
      }

      // Calculer la différence avec le ratio calculé
      final ratioDiff = ratio - lensRatio;

      // Si c'est la première optique valide ou si son ratio est plus proche du ratio calculé
      if (bestLens == null || ratioDiff < bestRatioDiff!) {
        bestLens = lens;
        bestRatioDiff = ratioDiff;
      }
    }

    return bestLens;
  }

  double _parseRatio(String ratioStr) {
    try {
      if (ratioStr.isEmpty) return -1;
      
      if (ratioStr.contains('–') || ratioStr.contains('-')) {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length < 2) return -1;
        
        final minPart = parts[0].trim().split(':');
        final maxPart = parts[1].trim().split(':');
        
        if (minPart.length < 2 || maxPart.length < 2) return -1;
        
        final min = double.tryParse(minPart.last) ?? -1;
        final max = double.tryParse(maxPart.last) ?? -1;
        
        if (min == -1 || max == -1) return -1;
        return (min + max) / 2;
      } else {
        final ratioParts = ratioStr.trim().split(':');
        if (ratioParts.length < 2) return -1;
        
        return double.tryParse(ratioParts.last.replaceAll(',', '.')) ?? -1;
      }
    } catch (e) {
      print('Erreur lors du parsing du ratio: $e');
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
    setState(() {
      selectedCategory = null;
      selectedSubCategory = null;
      selectedBrand = null;
      selectedProjector = null;
      selectedMurLed = null;
      largeurMurLed = 1;
      hauteurMurLed = 1;
      searchQuery = '';
      searchResults = [];
      showProjectionResult = false;
      showLedResult = false;
      searchController.clear();
      // Réinitialiser seulement le commentaire de projection
      _comments.remove('projection_tab');
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
    }
  }

  void _calculateSimulation() {
    setState(() {
      if (_tabController.index == 0) {
        showProjectionResult = true;
        showLedResult = false;
      }
    });
    
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

  @override
  void dispose() {
    _scrollController.dispose();
    _slideController.dispose();
    _tabController.dispose();
    _animationController.dispose();
    searchController.dispose();
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

    // Calcul de la largeur par projecteur en fonction de la largeur totale
    double largeurParProjecteur;
    double overlapWidth = 0.0;

    if (nbProjecteurs > 1) {
      // Calcul de la largeur de base par projecteur
      double largeurBase = largeurProjection / nbProjecteurs;

      // Calcul du chevauchement en fonction de la largeur de base
      overlapWidth = largeurBase * (chevauchement / 100);

      // Chaque projecteur a besoin de sa largeur de base plus les chevauchements
      largeurParProjecteur = largeurBase + (2 * overlapWidth);
    } else {
      largeurParProjecteur = largeurProjection;
    }


    // Calcul du ratio en fonction du format
    double baseRatio = distanceProjection / largeurParProjecteur;
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

    Lens? recommendation;
    if (selectedProjector != null) {
      try {
        recommendation = getRecommendedLens(selectedProjector!, ratio);
      } catch (e) {
        print('Erreur lors du calcul de l\'optique recommandée: $e');
        recommendation = null;
      }
    } else {
      recommendation = null;
    }

    // Filtrer les résultats de recherche en fonction de l'onglet actif
    if (searchQuery.isNotEmpty) {
      searchResults = ref.watch(catalogueProvider).where((item) {
        final matchesSearch =
            item.marque.toLowerCase().contains(searchQuery.toLowerCase()) ||
                item.produit.toLowerCase().contains(searchQuery.toLowerCase());

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
            opacity: 0.15,
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
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calculate, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Projection',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.calculate, size: 18),
                                  SizedBox(width: 8),
                                  Text(
                                    'Mur LED',
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
                            SingleChildScrollView(
                              controller: _scrollController,
                              child: Column(
                                children: [
                                  Container(
                                    margin: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF0A1128)
                                          .withAlpha((0.3 * 255).toInt()),
                                      border: Border.all(
                                          color: Colors.white, width: 1),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Column(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: TextField(
                                            controller: searchController,
                                            style: Theme.of(context).textTheme.bodyMedium,
                                            decoration: InputDecoration(
                                              hintText: loc.catalogPage_search,
                                              hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                                              ),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Theme.of(context).textTheme.bodyMedium?.color,
                                                size: 20
                                              ),
                                              filled: true,
                                              fillColor: Colors.transparent,
                                              border: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              contentPadding:
                                                  const EdgeInsets.symmetric(
                                                      vertical: 12),
                                              isDense: true,
                                            ),
                                            onChanged: (value) {
                                              setState(() {
                                                searchQuery = value;
                                                if (value.isEmpty) {
                                                  searchResults = [];
                                                  searchController.clear();
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                        if (searchResults.isNotEmpty)
                                          Container(
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.black.withOpacity(0.4),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: ListView.builder(
                                              shrinkWrap: true,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              padding: const EdgeInsets.all(8),
                                              itemCount: searchResults.length,
                                              itemBuilder: (context, index) {
                                                final item =
                                                    searchResults[index];
                                                return InkWell(
                                                  onTap: () {
                                                    setState(() {
                                                      if (item.sousCategorie ==
                                                          'Mur LED') {
                                                        selectedMurLed = item;
                                                      } else {
                                                        selectedBrand =
                                                            item.marque;
                                                        selectedProjector =
                                                            item;
                                                      }
                                                      searchQuery = '';
                                                      searchResults = [];
                                                      searchController.clear();
                                                    });
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8,
                                                        horizontal: 12),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        Text(
                                                          '${item.marque} - ${item.produit}',
                                                          style: Theme.of(context).textTheme.bodyMedium,
                                                        ),
                                                        Text(
                                                          item.sousCategorie,
                                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                                            color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 16, vertical: 8),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: BorderLabeledDropdown<String>(
                                                      label: 'Marque',
                                                      value: selectedBrand,
                                                      items: projectors
                                                          .map((item) => item.marque)
                                                          .toSet()
                                                          .map((marque) {
                                                        return DropdownMenuItem(
                                                          value: marque,
                                                          child: Text(marque, style: const TextStyle(fontSize: 11)),
                                                        );
                                                      }).toList(),
                                                      onChanged: (brand) {
                                                        setState(() {
                                                          selectedBrand = brand;
                                                          selectedProjector = null;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: BorderLabeledDropdown<CatalogueItem>(
                                                      label: 'Modèle',
                                                      value: selectedProjector,
                                                      items: projectors
                                                          .where((item) => 
                                                            selectedBrand == null || 
                                                            item.marque == selectedBrand)
                                                          .map((item) {
                                                        return DropdownMenuItem(
                                                          value: item,
                                                          child: Text(item.produit, style: const TextStyle(fontSize: 11)),
                                                        );
                                                      }).toList(),
                                                      onChanged: (item) {
                                                        setState(() {
                                                          selectedProjector = item;
                                                        });
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: BorderLabeledDropdown<String>(
                                                      label: 'Format',
                                                      value: selectedFormat,
                                                      items: [
                                                        DropdownMenuItem(
                                                          value: '16/9',
                                                          child: Text('16/9', style: const TextStyle(fontSize: 11)),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: '4/3',
                                                          child: Text('4/3', style: const TextStyle(fontSize: 11)),
                                                        ),
                                                        DropdownMenuItem(
                                                          value: '1/1',
                                                          child: Text('1/1', style: const TextStyle(fontSize: 11)),
                                                        ),
                                                      ],
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            selectedFormat = value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 8),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: BorderLabeledDropdown<int>(
                                                      label: 'Nb VP',
                                                      value: nbProjecteurs,
                                                      items: List.generate(6, (index) => index + 1)
                                                          .map((nb) => DropdownMenuItem(
                                                            value: nb,
                                                            child: Text(nb.toString(), style: const TextStyle(fontSize: 11)),
                                                          ))
                                                          .toList(),
                                                      onChanged: (value) {
                                                        if (value != null) {
                                                          setState(() {
                                                            nbProjecteurs = value;
                                                          });
                                                        }
                                                      },
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: BorderLabeledDropdown<double>(
                                                      label: 'Chevauch.',
                                                      value: chevauchement,
                                                      items: [10.0, 15.0, 20.0]
                                                          .map((value) => DropdownMenuItem(
                                                            value: value,
                                                            child: Text('${value.toInt()}%', style: const TextStyle(fontSize: 11)),
                                                          ))
                                                          .toList(),
                                                      onChanged: nbProjecteurs > 1
                                                          ? (value) {
                                                              if (value != null) {
                                                                setState(() {
                                                                  chevauchement = value;
                                                                });
                                                              }
                                                            }
                                                          : null,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Text(
                                                  'Largeur image : ${largeurProjection.toStringAsFixed(1)} m',
                                                  style: Theme.of(context).textTheme.bodyMedium),
                                              Slider(
                                                value: largeurProjection,
                                                min: 1,
                                                max: 50,
                                                divisions: 49,
                                                label: largeurProjection.toStringAsFixed(1),
                                                onChanged: (value) {
                                                  setState(() {
                                                    largeurProjection = value;
                                                  });
                                                },
                                              ),
                                              Text(
                                                  'Distance projecteur : ${distanceProjection.toStringAsFixed(1)} m',
                                                  style: Theme.of(context).textTheme.bodyMedium),
                                              Slider(
                                                value: distanceProjection,
                                                min: 1,
                                                max: 50,
                                                divisions: 49,
                                                label: distanceProjection.toStringAsFixed(1),
                                                onChanged: (value) {
                                                  setState(() {
                                                    distanceProjection = value;
                                                  });
                                                },
                                              ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          const Color(
                                                                  0xFF0A1128)
                                                              .withOpacity(0.5),
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                    ),
                                                    onPressed: () {
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (_) =>
                                                                const ArMeasurePage()),
                                                      );
                                                    },
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Image.asset(
                                                          'assets/icons/tape_measure.png',
                                                          width: 16,
                                                          height: 16,
                                                          color: Colors.white,
                                                        ),
                                                        const SizedBox(
                                                            width: 4),
                                                        const Text('AR',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .white)),
                                                      ],
                                                    ),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          const Color(
                                                                  0xFF0A1128)
                                                              .withOpacity(0.5),
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _calculateSimulation();
                                                        showProjectionResult = true;
                                                      });
                                                    },
                                                    child: const Icon(
                                                        Icons.calculate,
                                                        size: 20,
                                                        color: Colors.white),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  ElevatedButton(
                                                    style: ElevatedButton
                                                        .styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          const Color(
                                                                  0xFF0A1128)
                                                              .withOpacity(0.5),
                                                      elevation: 0,
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 6),
                                                    ),
                                                    onPressed: () {
                                                      setState(() {
                                                        _resetSelection();
                                                        showProjectionResult = false;
                                                      });
                                                    },
                                                    child: const Icon(
                                                        Icons.refresh,
                                                        size: 20,
                                                        color: Colors.white),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 16),
                                              if (showProjectionResult)
                                                Center(
                                                  key: _projectionResultKey,
                                                  child: Container(
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 32),
                                                    padding:
                                                        const EdgeInsets.all(
                                                            12),
                                                    decoration: BoxDecoration(
                                                      color: const Color(
                                                              0xFF0A1128)
                                                          .withOpacity(0.5),
                                                      border: Border.all(
                                                          color: const Color(
                                                              0xFF0A1128),
                                                          width: 2),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        Text(
                                                          'Ratio : ${ratio.toStringAsFixed(2)}:1',
                                                          style: Theme.of(context).textTheme.titleMedium,
                                                        ),
                                                        const SizedBox(
                                                            height: 8),
                                                        if (selectedProjector !=
                                                            null)
                                                          recommendation != null
                                                              ? Text(
                                                                  'Ratio recommandé : ${recommendation.reference} (${recommendation.ratio})',
                                                                  style:
                                                                      const TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                )
                                                              : const Text(
                                                                  'Aucune optique disponible pour ce ratio',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .redAccent,
                                                                    fontSize:
                                                                        16,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                  ),
                                                                ),
                                                        const SizedBox(
                                                            height: 16),
                                                        
                                                        // Affichage du commentaire s'il existe
                                                        if (_getCommentForTab(_generateProjectionResultKey()).isNotEmpty) ...[
                                                          const SizedBox(height: 12),
                                                          Container(
                                                            width: double.infinity,
                                                            padding: const EdgeInsets.all(12),
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue[900]?.withOpacity(0.3),
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(
                                                                color: Colors.lightBlue[300]!,
                                                                width: 1,
                                                              ),
                                                            ),
                                                            child: Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Icon(
                                                                  Icons.chat_bubble_outline,
                                                                  size: 16,
                                                                  color: Colors.lightBlue[300],
                                                                ),
                                                                const SizedBox(height: 6),
                                                                Text(
                                                                  _getCommentForTab(_generateProjectionResultKey()),
                                                                  style: const TextStyle(
                                                                    color: Colors.white,
                                                                    fontSize: 13,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                        
                                                        const SizedBox(height: 16),
                                                        
                                                        // Boutons d'action
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            // Bouton Commentaire
                                                            ActionButton.comment(
                                                              onPressed: () => _showCommentDialog(_generateProjectionResultKey(), 'Projection'),
                                                              iconSize: 28,
                                                            ),
                                                            const SizedBox(width: 20),
                                                            // Bouton Export (rotated)
                                                            Transform.rotate(
                                                              angle: 3.14159, // 180° en radians
                                                              child: Container(
                                                                decoration: const BoxDecoration(
                                                                  color: Colors.transparent,
                                                                ),
                                                                child: ExportWidget(
                                                                  title: 'Calcul Projection',
                                                                  content: 'Ratio : ${ratio.toStringAsFixed(2)}:1\nOptique recommandée : ${recommendation?.reference ?? 'Aucune'}',
                                                                  projectType: 'video',
                                                                  fileName: 'calcul_projection',
                                                                  customIcon: Icons.cloud_upload,
                                                                  backgroundColor: Colors.blueGrey[900],
                                                                  tooltip: 'Exporter le calcul',
                                                                ),
                                                              ),
                                                            ),
                                                            const SizedBox(width: 20),
                                                            // Bouton Schéma
                                                            ElevatedButton.icon(
                                                              onPressed: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            ProjectionSchemaPage(
                                                                      largeurTotale:
                                                                          largeurProjection,
                                                                      hauteurTotale:
                                                                          largeurParProjecteur *
                                                                              (9 /
                                                                                  16),
                                                                      nbProjecteurs:
                                                                          nbProjecteurs,
                                                                      chevauchement:
                                                                          chevauchement,
                                                                      largeurParProjecteur:
                                                                          largeurParProjecteur,
                                                                      ratio: ratio,
                                                                      optiqueRecommandee:
                                                                          recommendation
                                                                              ?.reference,
                                                                    ),
                                                                  ),
                                                                );
                                                              },
                                                              icon: const Icon(
                                                                  Icons.visibility),
                                                              label: const Text(
                                                                  'Schéma'),
                                                              style: ElevatedButton
                                                                  .styleFrom(
                                                                backgroundColor:
                                                                    Colors.blueGrey[
                                                                        900],
                                                                foregroundColor:
                                                                    Colors.white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
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
                                              child: DropdownButton<String>(
                                                isExpanded: true,
                                                value: selectedMurLed?.marque,
                                                hint: Text('Marque',
                                                    style: Theme.of(context).textTheme.bodyMedium),
                                                dropdownColor: Theme.of(context).brightness == Brightness.light 
                                                    ? Colors.white 
                                                    : Theme.of(context).colorScheme.surface,
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                items: _getLedWalls()
                                                    .map((item) => item.marque)
                                                    .toSet()
                                                    .map((marque) =>
                                                        DropdownMenuItem(
                                                          value: marque,
                                                          child: Text(marque,
                                                              style: Theme.of(context).textTheme.bodyMedium),
                                                        ))
                                                    .toList(),
                                                onChanged: (marque) {
                                                  if (marque != null) {
                                                    final items = _getLedWalls()
                                                        .where((item) =>
                                                            item.marque == marque)
                                                        .toList();
                                                    if (items.isNotEmpty) {
                                                      setState(() {
                                                        selectedMurLed = items.first;
                                                        largeurMurLed = 1;
                                                        hauteurMurLed = 1;
                                                        showLedResult = false;
                                                      });
                                                    }
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: DropdownButtonFormField<CatalogueItem>(
                                                isExpanded: true,
                                                value: selectedMurLed,
                                                hint: Text('Choisir un mur LED',
                                                    style: Theme.of(context).textTheme.bodyMedium),
                                                dropdownColor: Theme.of(context).brightness == Brightness.light 
                                                    ? Colors.white 
                                                    : Theme.of(context).colorScheme.surface,
                                                style: Theme.of(context).textTheme.bodyMedium,
                                                decoration: const InputDecoration(
                                                  border: InputBorder.none,
                                                  enabledBorder: InputBorder.none,
                                                  focusedBorder: InputBorder.none,
                                                  contentPadding: EdgeInsets.symmetric(horizontal: 0),
                                                  fillColor: Colors.transparent,
                                                  filled: true,
                                                ),
                                                items: _getLedWalls()
                                                    .where((item) => 
                                                      selectedMurLed?.marque == null || 
                                                      item.marque == selectedMurLed?.marque)
                                                    .map((item) =>
                                                        DropdownMenuItem(
                                                          value: item,
                                                          child: Text(
                                                            '${item.marque} - ${item.produit}',
                                                            style: Theme.of(context).textTheme.bodyMedium,
                                                          ),
                                                        ))
                                                    .toList(),
                                                onChanged: (item) {
                                                  if (item != null) {
                                                    setState(() {
                                                      selectedMurLed = item;
                                                      largeurMurLed = 1;
                                                      hauteurMurLed = 1;
                                                      showLedResult = false;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                            'Largeur : ${largeurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * largeurMurLed).toStringAsFixed(2)} m',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                        Slider(
                                          value: largeurMurLed,
                                          min: 1,
                                          max: 50,
                                          divisions: 49,
                                          label:
                                              '${largeurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * largeurMurLed).toStringAsFixed(2)} m',
                                          onChanged: (value) {
                                            setState(() {
                                              largeurMurLed = value;
                                              showLedResult = false;
                                            });
                                          },
                                        ),
                                        Text(
                                            'Hauteur : ${hauteurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * hauteurMurLed).toStringAsFixed(2)} m',
                                            style: Theme.of(context).textTheme.bodyMedium),
                                        Slider(
                                          value: hauteurMurLed,
                                          min: 1,
                                          max: 20,
                                          divisions: 19,
                                          label:
                                              '${hauteurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * hauteurMurLed).toStringAsFixed(2)} m',
                                          onChanged: (value) {
                                            setState(() {
                                              hauteurMurLed = value;
                                              showLedResult = false;
                                            });
                                          },
                                        ),
                                        const SizedBox(height: 16),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    const Color(0xFF0A1128)
                                                        .withOpacity(0.5),
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                              ),
                                              onPressed: () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (_) =>
                                                          const ArMeasurePage()),
                                                );
                                              },
                                              child: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Image.asset(
                                                    'assets/icons/tape_measure.png',
                                                    width: 16,
                                                    height: 16,
                                                    color: Colors.white,
                                                  ),
                                                  const SizedBox(width: 4),
                                                  const Text('AR',
                                                      style: TextStyle(
                                                          fontSize: 12,
                                                          color: Colors.white)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    const Color(0xFF0A1128)
                                                        .withOpacity(0.5),
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                              ),
                                              onPressed: () {
                                                setState(() {
                                                  if (_tabController.index == 1) {
                                                    showLedResult = true;
                                                    showProjectionResult = false;
                                                    _scrollToResult();
                                                  }
                                                });
                                              },
                                              child: const Icon(Icons.calculate,
                                                  size: 20,
                                                  color: Colors.white),
                                            ),
                                            const SizedBox(width: 8),
                                            ElevatedButton(
                                              style: ElevatedButton.styleFrom(
                                                foregroundColor: Colors.white,
                                                backgroundColor:
                                                    const Color(0xFF0A1128)
                                                        .withOpacity(0.5),
                                                elevation: 0,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 12,
                                                        vertical: 6),
                                              ),
                                              onPressed: _resetSelection,
                                              child: const Icon(Icons.refresh,
                                                  size: 20,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                        if (showLedResult)
                                          Container(
                                            key: _ledResultKey,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 16, vertical: 8),
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFF0A1128)
                                                  .withOpacity(0.8),
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
                                                Center(
                                                  child: Text(
                                                      '${(largeurMurLed * hauteurMurLed).toInt()} dalles (${_getMurLedDimensions(selectedMurLed)} /u)',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      'Esp. pixellaire : ${(int.tryParse(_getMurLedResolution(selectedMurLed).split('x')[0].trim().replaceAll('px', '')) ?? 200) * largeurMurLed.toInt()}px x ${(int.tryParse(_getMurLedResolution(selectedMurLed).split('x')[1].trim().replaceAll('px', '')) ?? 200) * hauteurMurLed.toInt()}px (${_getMurLedResolution(selectedMurLed).split('x')[0].trim().replaceAll('px', '')} x ${_getMurLedResolution(selectedMurLed).split('x')[1].trim().replaceAll('px', '')} /u)',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      '${((int.tryParse(_getMurLedResolution(selectedMurLed).split('x')[0].trim().replaceAll('px', '')) ?? 200) * largeurMurLed.toInt() * (int.tryParse(_getMurLedResolution(selectedMurLed).split('x')[1].trim().replaceAll('px', '')) ?? 200) * hauteurMurLed.toInt() / 1000000).toStringAsFixed(1)} Mpx / Ratio ${(largeurMurLed / hauteurMurLed).toStringAsFixed(2)}:1',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      'Poids total : ${(_getMurLedWeight(selectedMurLed) * largeurMurLed * hauteurMurLed).toStringAsFixed(1)} kg',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                Center(
                                                  child: Text(
                                                      'Consommation totale : ${(_getMurLedConsumption(selectedMurLed) * largeurMurLed * hauteurMurLed).toStringAsFixed(0)} W',
                                                      style: const TextStyle(
                                                          color: Colors.white)),
                                                ),
                                                const SizedBox(height: 16),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      onPressed: () {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                const LedWallSchemaPage(),
                                                          ),
                                                        );
                                                      },
                                                      icon: const Icon(
                                                          Icons.schema,
                                                          color: Color(
                                                              0xFF0A1128)),
                                                      label: const Text(
                                                          'Voir le schéma',
                                                          style: TextStyle(
                                                              color: Color(
                                                                  0xFF0A1128))),
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            const Color(
                                                                0xFF0A1128),
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 24,
                                                                vertical: 12),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 16),
                                                    ElevatedButton(
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
                                                                  (largeurMurLed *
                                                                          hauteurMurLed)
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
                                                      style: ElevatedButton
                                                          .styleFrom(
                                                        backgroundColor:
                                                            Colors.white,
                                                        foregroundColor:
                                                            const Color(
                                                                0xFF0A1128),
                                                        elevation: 0,
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 18,
                                                                vertical: 10),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                      ),
                                                      child: const Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          Icon(Icons.notes,
                                                              size: 20,
                                                              color: Color(
                                                                  0xFF0A1128)),
                                                          SizedBox(width: 6),
                                                          Icon(Icons.add,
                                                              size: 20,
                                                              color: Color(
                                                                  0xFF0A1128)),
                                                        ],
                                                      ),
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

