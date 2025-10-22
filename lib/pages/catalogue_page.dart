import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catalogue_item.dart';
import '../models/amplifier_spec.dart';
import '../services/amplification_calculator_service.dart';
import '../providers/amplification_providers.dart';
import '../models/cart_item.dart';
import '../models/lens.dart';
import 'calcul_projet_page.dart';
import 'ar_measure_page.dart';
import '../widgets/preset_widget.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../widgets/action_button.dart';
import '../widgets/export_widget.dart';
import '../widgets/uniform_bottom_nav_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../providers/preset_provider.dart';
import '../theme/app_theme.dart';
import '../theme/colors.dart';
import '../services/freemium_access_service.dart';

class CataloguePage extends ConsumerStatefulWidget {
  const CataloguePage({super.key});

  @override
  ConsumerState<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends ConsumerState<CataloguePage> with TickerProviderStateMixin {
  String searchQuery = '';
  String? selectedBrand;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedProduct;
  List<CatalogueItem> searchResults = [];
  bool isLoading = true;
  String? error;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _resultKey = GlobalKey();
  bool _isAnimating = false;
  Offset? _startPosition;
  Size? _startSize;
  late final TextEditingController _searchController;
  late TabController _tabController;
  
  // Gestion des commentaires
  Map<String, String> _comments = {}; // Clé: "marque_produit", Valeur: commentaire
  
  // Gestion de la quantité et des sélections pour l'ajout direct
  int _selectedQuantity = 1;
  String? _selectedDmxType;
  bool _isWifiMode = false;
  // Sélection d'ampli pour la catégorie Son
  String? _selectedAmpModel; // ex: LA4X, LA8, LA12X, D30, D80

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _tabController = TabController(length: 1, vsync: this);
    _searchController.addListener(() {
      if (_searchController.text != searchQuery) {
        setState(() {
          searchQuery = _searchController.text;
        });
      }
    });
    // Charger les données du catalogue au démarrage (avec vérification freemium)
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print('Initializing catalogue page...');
      
      // Vérifier l'accès au catalogue (premium uniquement)
      final hasAccess = await FreemiumAccessService.canAccessCatalogue(context, ref);
      if (!hasAccess) {
        // L'utilisateur n'a pas accès, ne pas charger le catalogue
        setState(() {
          isLoading = false;
          error = 'Accès au catalogue refusé - Premium requis';
        });
        return;
      }
      
      setState(() {
        isLoading = true;
        error = null;
      });
      try {
        await ref.read(catalogueProvider.notifier).loadCatalogue();
        print('Catalogue loaded in page');
      } catch (e) {
        print('Error loading catalogue in page: $e');
        setState(() {
          error = 'Erreur lors du chargement du catalogue';
        });
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    });
    // Charger l'état persisté après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadComments();
        _loadPersistedState();
      }
    });
  }

  List<Widget> _buildAmpButtonsForBrand(String brand) {
    final List<String> models;
    if (brand.toLowerCase().contains('l-acoust')) {
      models = ['LA4X', 'LA8', 'LA12X'];
    } else if (brand.toLowerCase().contains('d&b')) {
      models = ['D30', 'D80'];
    } else {
      models = [];
    }

    return models.map((m) => Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAmpModel = m;
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: _selectedAmpModel == m ? Colors.lightBlue[300] : Colors.grey[600],
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            m,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    )).toList();
  }

  @override
  void dispose() {
    _savePersistedState();
    _scrollController.dispose();
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // Méthodes de persistance
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('catalogue_comments');
      if (commentsJson != null) {
        final Map<String, dynamic> commentsMap = Map<String, dynamic>.from(
          json.decode(commentsJson)
        );
        _comments = commentsMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = json.encode(_comments);
      await prefs.setString('catalogue_comments', commentsJson);
    } catch (e) {
      print('Error saving comments: $e');
    }
  }

  Future<void> _loadPersistedState() async {
    try {
      print('Starting persistence restoration...');
      
      // Vérifier que le widget est encore monté
      if (!mounted) return;
      
      // Attendre un peu que le catalogue se charge
      await Future.delayed(const Duration(milliseconds: 1000));
      
      // Vérifier que le widget est encore monté après l'attente
      if (!mounted) return;
      
      // Vérifier que le catalogue est chargé
      final items = ref.read(catalogueProvider);
      if (items.isEmpty) {
        print('Catalogue not loaded yet, skipping persistence restoration');
        return;
      }
      
      print('Catalogue loaded with ${items.length} items, proceeding with persistence restoration');
      
      final prefs = await SharedPreferences.getInstance();
      
      // Vérifier toutes les clés disponibles
      final allKeys = prefs.getKeys();
      print('All SharedPreferences keys: $allKeys');
      
      // Restaurer la requête de recherche
      final savedSearchQuery = prefs.getString('catalogue_search_query') ?? '';
      print('Restoring search query: "$savedSearchQuery"');
      
      if (savedSearchQuery.isNotEmpty && mounted) {
        _searchController.text = savedSearchQuery;
        searchQuery = savedSearchQuery;
      }
      
      // Restaurer les filtres avec validation
      final savedBrand = prefs.getString('catalogue_selected_brand');
      final savedCategory = prefs.getString('catalogue_selected_category');
      final savedSubCategory = prefs.getString('catalogue_selected_subcategory');
      final savedProduct = prefs.getString('catalogue_selected_product');
      
      print('Restoring filters - Brand: $savedBrand, Category: $savedCategory, SubCategory: $savedSubCategory, Product: $savedProduct');
      
      // Valider que les valeurs existent dans les listes disponibles
      final availableCategories = items
          .where((item) => item.categorie.isNotEmpty)
          .map((item) => item.categorie)
          .toSet()
          .toList()
        ..sort();
      
      print('Available categories: $availableCategories');
      
      // Restaurer la catégorie d'abord
      selectedCategory = (savedCategory != null && savedCategory.isNotEmpty && availableCategories.contains(savedCategory)) ? savedCategory : null;
      print('Restored category: $selectedCategory');
      
      // Si pas de catégorie mais un produit sélectionné, essayer de trouver la catégorie du produit
      if (selectedCategory == null && savedProduct != null && savedProduct.isNotEmpty) {
        final productItem = items.firstWhere(
          (item) => item.produit == savedProduct,
          orElse: () => CatalogueItem(
            id: '', name: '', description: '', categorie: '', sousCategorie: '', 
            marque: '', produit: '', dimensions: '', poids: '', conso: ''
          ),
        );
        if (productItem.categorie.isNotEmpty && availableCategories.contains(productItem.categorie)) {
          selectedCategory = productItem.categorie;
          print('Found category from product: $selectedCategory');
        }
      }
      
      // Puis restaurer les autres filtres en fonction de la catégorie
      if (selectedCategory != null) {
        // Calculer les marques disponibles pour la catégorie et sous-catégorie sélectionnées
        final availableBrands = items
            .where((item) =>
                item.marque.isNotEmpty &&
                item.categorie == selectedCategory &&
                (selectedSubCategory == null || item.sousCategorie == selectedSubCategory))
            .map((item) => item.marque)
            .toSet()
            .toList()
          ..sort();
        
        // Calculer les sous-catégories disponibles
        final availableSubCategories = items
            .where((item) =>
                item.categorie == selectedCategory && item.sousCategorie.isNotEmpty)
            .map((item) => item.sousCategorie)
            .toSet()
            .toList()
          ..sort();
        
        // Calculer les produits disponibles en respectant tous les filtres
        final availableProducts = items
            .where((item) =>
                item.categorie == selectedCategory &&
                (selectedBrand == null || item.marque == selectedBrand) &&
                (selectedSubCategory == null || item.sousCategorie == selectedSubCategory) &&
                item.produit.isNotEmpty)
            .map((item) => item.produit)
            .toSet()
            .toList()
          ..sort();
        
        print('Available brands for category $selectedCategory: $availableBrands');
        print('Available subcategories: $availableSubCategories');
        print('Available products: $availableProducts');
        
        selectedBrand = (savedBrand != null && availableBrands.contains(savedBrand)) ? savedBrand : null;
        selectedSubCategory = (savedSubCategory != null && availableSubCategories.contains(savedSubCategory)) ? savedSubCategory : null;
        selectedProduct = (savedProduct != null && availableProducts.contains(savedProduct)) ? savedProduct : null;
        
        print('Restored filters - Brand: $selectedBrand, SubCategory: $selectedSubCategory, Product: $selectedProduct');
      } else {
        // Si aucune catégorie valide, essayer de restaurer au moins le produit
        if (savedProduct != null && savedProduct.isNotEmpty) {
          // Chercher le produit dans tout le catalogue
          final productItem = items.firstWhere(
            (item) => item.produit == savedProduct,
            orElse: () => CatalogueItem(
              id: '', name: '', description: '', categorie: '', sousCategorie: '', 
              marque: '', produit: '', dimensions: '', poids: '', conso: ''
            ),
          );
          if (productItem.produit.isNotEmpty) {
            selectedProduct = savedProduct;
            selectedBrand = productItem.marque.isNotEmpty ? productItem.marque : null;
            selectedSubCategory = productItem.sousCategorie.isNotEmpty ? productItem.sousCategorie : null;
            print('Restored product without category - Product: $selectedProduct, Brand: $selectedBrand, SubCategory: $selectedSubCategory');
          } else {
            selectedBrand = null;
            selectedSubCategory = null;
            selectedProduct = null;
            print('Product not found, resetting all filters');
          }
        } else {
          selectedBrand = null;
          selectedSubCategory = null;
          selectedProduct = null;
          print('No valid category or product found, resetting all filters');
        }
      }
      
      // Restaurer les résultats de recherche si une recherche était active
      if (savedSearchQuery.isNotEmpty && mounted) {
        print('Performing search with restored query: $savedSearchQuery');
        _performSearch(savedSearchQuery);
      }
      
      if (mounted) {
        setState(() {});
        print('Persistence restoration completed successfully');
      }
    } catch (e) {
      print('Error loading persisted state: $e');
    }
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('Saving persisted state - Search: "$searchQuery", Brand: $selectedBrand, Category: $selectedCategory, SubCategory: $selectedSubCategory, Product: $selectedProduct');
      
      // Sauvegarder la requête de recherche
      await prefs.setString('catalogue_search_query', searchQuery);
      
      // Sauvegarder les filtres
      await prefs.setString('catalogue_selected_brand', selectedBrand ?? '');
      await prefs.setString('catalogue_selected_category', selectedCategory ?? '');
      await prefs.setString('catalogue_selected_subcategory', selectedSubCategory ?? '');
      await prefs.setString('catalogue_selected_product', selectedProduct ?? '');
      
      // Vérifier que les données ont été sauvegardées
      final savedSearch = prefs.getString('catalogue_search_query');
      final savedCategory = prefs.getString('catalogue_selected_category');
      print('Verification - Saved search: "$savedSearch", Saved category: "$savedCategory"');
      
      print('Persistence state saved successfully');
    } catch (e) {
      print('Error saving persisted state: $e');
    }
  }

  void _performSearch(String query) {
    if (query.length >= 3 && mounted) {
      try {
        // Utiliser ref.watch pour s'assurer que le provider est disponible
        final items = ref.watch(catalogueProvider);
        if (items.isNotEmpty) {
          searchResults = items
              .where((item) =>
                  item.name.toLowerCase().contains(query.toLowerCase()) ||
                  item.marque.toLowerCase().contains(query.toLowerCase()) ||
                  item.produit.toLowerCase().contains(query.toLowerCase()))
              .toList();
          print('Search performed: found ${searchResults.length} results for "$query"');
        } else {
          searchResults = [];
          print('Search performed: no items available for search');
        }
      } catch (e) {
        print('Error performing search: $e');
        searchResults = [];
      }
    } else {
      searchResults = [];
      print('Search query too short or widget not mounted: "$query"');
    }
  }

  void _scrollToResult() {
    if (selectedProduct != null && selectedProduct!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_resultKey.currentContext != null) {
          Scrollable.ensureVisible(
            _resultKey.currentContext!,
            duration: const Duration(milliseconds: 800),
            curve: Curves.easeInOut,
            alignment: 0.3, // Centre le résultat dans la vue (0.3 pour laisser de l'espace en haut)
          );
        }
      });
    }
  }

  @override
  void didUpdateWidget(CataloguePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedProduct != null) {
      _scrollToResult();
    }
  }

  List<String> get _uniqueBrands {
    final items = ref.watch(catalogueProvider);
    if (items.isEmpty) return [];
    return items
        .where((item) =>
            item.marque.isNotEmpty &&
            (selectedCategory == null || item.categorie == selectedCategory) &&
            (selectedSubCategory == null || item.sousCategorie == selectedSubCategory))
        .map((item) => item.marque)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _categories {
    final items = ref.watch(catalogueProvider);
    if (items.isEmpty) return [];
    
    // Ordre personnalisé des catégories
    const customOrder = ['Lumière', 'Son', 'Vidéo', 'Régie', 'Truss/rigg', 'Divers'];
    
    final categories = items
        .where((item) => item.categorie.isNotEmpty)
        .map((item) => item.categorie)
        .toSet()
        .toList();
    
    // Trier selon l'ordre personnalisé
    categories.sort((a, b) {
      final indexA = customOrder.indexOf(a);
      final indexB = customOrder.indexOf(b);
      
      // Si les deux sont dans l'ordre personnalisé, utiliser cet ordre
      if (indexA != -1 && indexB != -1) {
        return indexA.compareTo(indexB);
      }
      
      // Si seulement A est dans l'ordre personnalisé, A vient en premier
      if (indexA != -1) return -1;
      
      // Si seulement B est dans l'ordre personnalisé, B vient en premier
      if (indexB != -1) return 1;
      
      // Si aucun n'est dans l'ordre personnalisé, trier alphabétiquement
      return a.compareTo(b);
    });
    
    return categories;
  }

  List<String> get _subCategoriesForSelectedCategory {
    final items = ref.watch(catalogueProvider);
    if (items.isEmpty || selectedCategory == null) return [];
    return items
        .where((item) =>
            item.categorie == selectedCategory && item.sousCategorie.isNotEmpty)
        .map((item) => item.sousCategorie)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _productsForSelectedFilters {
    final items = ref.watch(catalogueProvider);
    if (items.isEmpty) return [];
    return items
        .where((item) =>
            (selectedCategory == null || item.categorie == selectedCategory) &&
            (selectedBrand == null || item.marque == selectedBrand) &&
            (selectedSubCategory == null ||
                item.sousCategorie == selectedSubCategory) &&
            item.produit.isNotEmpty)
        .map((item) => item.produit)
        .toSet()
        .toList()
      ..sort();
  }

  void _resetFilters() {
    setState(() {
      selectedBrand = null;
      selectedCategory = null;
      selectedSubCategory = null;
      selectedProduct = null;
      searchQuery = '';
      _searchController.clear(); // Réinitialiser le champ de recherche
    });
    _savePersistedState();
  }

  List<CatalogueItem> get filteredItems {
    final items = ref.watch(catalogueProvider);
    
    // Si une recherche est active, rechercher dans tout le catalogue
    if (searchQuery.isNotEmpty && searchQuery.length >= 3) {
      return items.where((item) {
        return item.produit.toLowerCase().contains(searchQuery.toLowerCase()) ||
               item.marque.toLowerCase().contains(searchQuery.toLowerCase()) ||
               (item.description.isNotEmpty &&
                   item.description.toLowerCase().contains(searchQuery.toLowerCase())) ||
               item.categorie.toLowerCase().contains(searchQuery.toLowerCase()) ||
               item.sousCategorie.toLowerCase().contains(searchQuery.toLowerCase());
      }).toList();
    }
    
    // Sinon, appliquer les filtres normaux
    return items.where((item) {
      final matchesBrand =
          selectedBrand == null || item.marque == selectedBrand;
      final matchesCategory =
          selectedCategory == null || item.categorie == selectedCategory;
      final matchesSubCategory = selectedSubCategory == null ||
          item.sousCategorie == selectedSubCategory;
      final matchesProduct =
          selectedProduct == null || item.produit == selectedProduct;

      return matchesBrand &&
          matchesCategory &&
          matchesSubCategory &&
          matchesProduct;
    }).toList();
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
    });
    _performSearch(value);
    _savePersistedState();
  }

  void _handleCategorySelection(String? category) {
    setState(() {
      selectedCategory = category;
      selectedSubCategory = null;
      selectedBrand = null;
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
    _savePersistedState();
  }

  void _handleBrandSelection(String? brand) {
    setState(() {
      selectedBrand = brand;
      // Ne pas réinitialiser selectedSubCategory pour la persistance
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
    _savePersistedState();
  }

  void _handleSubCategorySelection(String? subCategory) {
    setState(() {
      selectedSubCategory = subCategory;
      selectedBrand = null; // Réinitialiser la marque car les marques disponibles changent
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
    _savePersistedState();
  }

  void _handleProductSelection(String? product) {
    setState(() {
      selectedProduct = product;
      searchQuery = ''; // Réinitialiser la recherche
    });
    _savePersistedState();
    
    // Focus automatique vers le résultat
    if (product != null && product.isNotEmpty) {
      _scrollToResult();
    }
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  String _getCommentForItem(CatalogueItem item) {
    final String commentKey = '${item.marque}_${item.produit}';
    return _comments[commentKey] ?? '';
  }

  String _buildExportContent(CatalogueItem item) {
    final StringBuffer content = StringBuffer();
    
    // Informations de base
    content.writeln('Marque: ${item.marque}');
    content.writeln('Produit: ${item.produit}');
    content.writeln('Catégorie: ${item.categorie}');
    content.writeln('Sous-catégorie: ${item.sousCategorie}');
    content.writeln('');
    
    // Description
    if (item.description.isNotEmpty) {
      content.writeln(item.description);
      content.writeln('');
    }
    
    // Caractéristiques physiques
    if (item.taille != null) content.writeln('Taille: ${item.taille}"');
    if (item.dimensions.isNotEmpty) content.writeln('Dimensions: ${item.dimensions}');
    if (item.poids.isNotEmpty) content.writeln('Poids: ${item.poids}');
    if (item.conso.isNotEmpty) content.writeln('Consommation: ${item.conso}');
    content.writeln('');
    
    // Caractéristiques techniques
    if (item.resolutionDalle != null) content.writeln('Résolution dalle: ${item.resolutionDalle}');
    if (item.resolution != null) content.writeln('Résolution: ${item.resolution}');
    if (item.pitch != null) content.writeln('Pitch: ${item.pitch}');
    content.writeln('');
    
    // Caractéristiques lumière
    if (item.angle != null) content.writeln('Angle: ${item.angle}');
    if (item.lux != null) content.writeln('Lux: ${item.lux}');
    if (item.lumens != null) content.writeln('Lumens: ${item.lumens}');
    if (item.definition != null) content.writeln('Définition: ${item.definition}');
    content.writeln('');
    
    // Caractéristiques DMX
    if (item.dmxMax != null) content.writeln('DMX Max: ${item.dmxMax}');
    if (item.dmxMini != null) content.writeln('DMX Mini: ${item.dmxMini}');
    content.writeln('');
    
    // Caractéristiques audio
    if (item.puissanceAdmissible != null) content.writeln('Puissance admissible: ${item.puissanceAdmissible}');
    if (item.impedanceNominale != null) content.writeln('Impédance nominale: ${item.impedanceNominale}');
    if (item.impedanceOhms != null) content.writeln('Impédance: ${item.impedanceOhms} Ω');
    if (item.powerRmsW != null) content.writeln('Puissance RMS: ${item.powerRmsW} W');
    if (item.powerProgramW != null) content.writeln('Puissance Program: ${item.powerProgramW} W');
    if (item.powerPeakW != null) content.writeln('Puissance Peak: ${item.powerPeakW} W');
    if (item.maxVoltageVrms != null) content.writeln('Tension max: ${item.maxVoltageVrms} Vrms');
    content.writeln('');
    
    // Commentaire utilisateur
    final comment = _getCommentForItem(item);
    if (comment.isNotEmpty) {
      content.writeln(comment);
      content.writeln('');
    }
    
    // Lentilles de projection
    if (item.optiques != null && item.optiques!.isNotEmpty) {
      for (final optique in item.optiques!) {
        content.writeln('• $optique');
      }
      content.writeln('');
    }
    
    return content.toString();
  }

  void _showCommentDialog(CatalogueItem item) {
    final TextEditingController commentController = TextEditingController();
    final String commentKey = '${item.marque}_${item.produit}';
    
    // Charger le commentaire existant s'il y en a un
    final existingComment = _comments[commentKey] ?? '';
    commentController.text = existingComment;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1128)
              : Colors.white,
          title: Row(
            children: [
              Icon(
                Icons.chat_bubble_outline,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.lightBlue[300]
                    : const Color(0xFF0A1128),
              ),
              const SizedBox(width: 8),
              Text(
                'Commentaire',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${item.marque} - ${item.produit}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: commentController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Ajoutez votre commentaire...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[800]
                      : Colors.grey[100],
                ),
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.grey[400]
                      : Colors.grey[600],
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                // Sauvegarder le commentaire
                setState(() {
                  if (commentController.text.trim().isEmpty) {
                    _comments.remove(commentKey);
                  } else {
                    _comments[commentKey] = commentController.text.trim();
                  }
                });
                _saveComments();
                
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(commentController.text.trim().isEmpty 
                        ? 'Commentaire supprimé' 
                        : 'Commentaire sauvegardé'),
                    backgroundColor: Colors.green,
                  ),
                );
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).brightness == Brightness.dark
                    ? Colors.lightBlue[300]
                    : const Color(0xFF0A1128),
                foregroundColor: Colors.white,
              ),
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  void _showQuantityDialog(CatalogueItem item) {
    int quantity = 1;

    // Déterminer si c'est un produit lumière pour utiliser le style approprié
    final isLightProduct = item.categorie == 'Lumière';
    
    // Variables pour le choix DMX (uniquement pour les produits lumière)
    String? selectedDmxType;
    List<String> dmxTypes = ['DMX mini', 'DMX max'];
    if (isLightProduct) {
      selectedDmxType = 'DMX mini'; // Valeur par défaut
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: isLightProduct 
                  ? Colors.blueGrey[900]
                  : (Theme.of(context).brightness == Brightness.dark
                      ? const Color(0xFF0A1128)
                      : Colors.white),
              title: Text(
                AppLocalizations.of(context)!.catalogueQuantityDialog_title,
                style: TextStyle(
                  color: isLightProduct 
                      ? Colors.white
                      : (Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black),
                  fontSize: isLightProduct ? 16 : null,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.produit,
                    style: TextStyle(
                      color: isLightProduct 
                          ? Colors.white
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Contrôleur de quantité avec boutons - et +
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove, color: Colors.white, size: 12),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                          minimumSize: const Size(24, 24),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 60,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final quantityController = TextEditingController(text: quantity.toString());
                                return AlertDialog(
                                  backgroundColor: isLightProduct ? Colors.blueGrey[900] : Colors.blueGrey[900],
                                  title: Text(AppLocalizations.of(context)!.catalogueQuantityDialog_title,
                                      style: TextStyle(color: Colors.white)),
                                  content: TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!.catalogueQuantityDialog_enterQuantity,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(AppLocalizations.of(context)!.catalogueQuantityDialog_cancel,
                                          style: TextStyle(color: Colors.lightBlue[300])),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final newQuantity = int.tryParse(quantityController.text) ?? 1;
                                        if (newQuantity > 0) {
                                          setState(() {
                                            quantity = newQuantity;
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text('OK',
                                          style: TextStyle(color: Colors.lightBlue[300])),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.grey[400]!, width: 1),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white, size: 12),
                        onPressed: () {
                          setState(() {
                            quantity++;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                          minimumSize: const Size(24, 24),
                          padding: EdgeInsets.zero,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sélection du type DMX (uniquement pour les produits lumière)
                  if (isLightProduct) ...[
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedDmxType,
                        decoration: InputDecoration(
                          labelText: AppLocalizations.of(context)!.catalogueQuantityDialog_dmxType,
                          labelStyle: TextStyle(color: Colors.white),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                          ),
                        ),
                        dropdownColor: Colors.blueGrey[800],
                        style: const TextStyle(color: Colors.white),
                        items: dmxTypes.map((String type) {
                          return DropdownMenuItem<String>(
                            value: type,
                            child: Text(
                              type == 'DMX mini' 
                                  ? AppLocalizations.of(context)!.catalogueQuantityDialog_dmxMini
                                  : AppLocalizations.of(context)!.catalogueQuantityDialog_dmxMax, 
                              style: const TextStyle(color: Colors.white)
                            ),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedDmxType = newValue;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Affichage des informations DMX du produit (vraies valeurs)
                    if (item.dmxMini != null || item.dmxMax != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[800],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          children: [
                            if (item.dmxMini != null)
                              Text('${AppLocalizations.of(context)!.catalogueQuantityDialog_dmxMini}: ${item.dmxMini}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                            if (item.dmxMax != null)
                              Text('${AppLocalizations.of(context)!.catalogueQuantityDialog_dmxMax}: ${item.dmxMax}',
                                  style: const TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(
                    AppLocalizations.of(context)!.catalogueQuantityDialog_cancel,
                    style: TextStyle(
                      color: isLightProduct 
                          ? Colors.lightBlue[300]
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startAddToProjectAnimation(item, quantity, selectedDmxType);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.catalogueQuantityDialog_confirm,
                    style: TextStyle(
                      color: isLightProduct 
                          ? Colors.lightBlue[300]
                          : (Theme.of(context).brightness == Brightness.dark
                              ? Colors.white
                              : Colors.black),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _startAddToProjectAnimation(CatalogueItem item, int quantity, [String? dmxType]) {
    if (_resultKey.currentContext == null) return;

    final RenderBox renderBox =
        _resultKey.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    setState(() {
      _isAnimating = true;
      _startPosition = position;
      _startSize = size;
    });

    // Ajouter l'item au preset après un court délai
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) {
        final preset = ref.read(presetProvider.notifier).activePreset;
        if (preset != null) {
          final cartItem = CartItem(
            item: item,
            quantity: quantity,
          );
          preset.items.add(cartItem);
          ref.read(presetProvider.notifier).updatePreset(preset);
        }
        setState(() {
          _isAnimating = false;
          _startPosition = null;
          _startSize = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.list,
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
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border(
                      bottom: BorderSide(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.lightBlue[300]!
                            : const Color(0xFF0A1128),
                        width: 2,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.mainBlue.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
         child: TabBar(
           controller: _tabController,
           dividerColor: Colors.transparent, // Supprime la ligne de séparation
           indicatorColor: Colors.transparent, // Supprime l'indicateur bleu
           labelColor: Theme.of(context).tabBarTheme.labelColor, // Utilise le thème
           unselectedLabelColor: Theme.of(context).tabBarTheme.unselectedLabelColor, // Utilise le thème
           tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Theme.of(context).tabBarTheme.labelColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.catalogAccess,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).tabBarTheme.labelColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    children: [
                      const SizedBox(height: 6),
                      const PresetWidget(
                        loadOnInit: true,
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildCatalogueContent(),
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
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 0),
    );
  }

  // Méthode helper pour vérifier si un item a des données à afficher
  bool _hasDataToShow(CatalogueItem item) {
    return item.marque.isNotEmpty ||
           item.description.isNotEmpty ||
           item.taille != null ||
           item.dimensions.isNotEmpty ||
           item.poids.isNotEmpty ||
           item.conso.isNotEmpty ||
           item.resolutionDalle != null ||
           item.resolution != null ||
           item.pitch != null ||
           item.angle != null ||
           item.lux != null ||
           item.lumens != null ||
           item.definition != null ||
           item.dmxMax != null ||
           item.dmxMini != null ||
           item.puissanceAdmissible != null ||
           item.impedanceNominale != null ||
           item.impedanceOhms != null ||
           item.powerRmsW != null ||
           item.powerProgramW != null ||
           item.powerPeakW != null ||
           item.maxVoltageVrms != null ||
           (item.optiques != null && item.optiques!.isNotEmpty);
  }

  // Méthode helper pour afficher une caractéristique
  Widget _buildCharacteristicRow(String label, String value) {
    // Nettoyer la valeur pour supprimer les deux-points en fin de chaîne
    String cleanValue = value.trim();
    
    // Supprimer les deux-points en fin de chaîne
    while (cleanValue.endsWith(':')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 1).trim();
    }
    
    // Supprimer les espaces multiples
    cleanValue = cleanValue.replaceAll(RegExp(r'\s+'), ' ');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label :',
              style: Theme.of(context)
                  .extension<ResultContainerTheme>()
                  ?.textStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(
                        color: Colors.white70,
                        fontWeight: FontWeight.w500,
                      ),
            ),
          ),
          Expanded(
            child: Text(
              cleanValue,
              style: Theme.of(context)
                  .extension<ResultContainerTheme>()
                  ?.textStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  // Méthode helper pour afficher la description sur toute la largeur
  Widget _buildDescriptionRow(String label, String value) {
    // Nettoyer la valeur pour supprimer les deux-points en fin de chaîne
    String cleanValue = value.trim();
    
    // Supprimer les deux-points en fin de chaîne
    while (cleanValue.endsWith(':')) {
      cleanValue = cleanValue.substring(0, cleanValue.length - 1).trim();
    }
    
    // Supprimer les espaces multiples
    cleanValue = cleanValue.replaceAll(RegExp(r'\s+'), ' ');
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '$label :',
            style: Theme.of(context)
                .extension<ResultContainerTheme>()
                ?.textStyle ??
                Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
          ),
          const SizedBox(height: 4),
          Text(
            cleanValue,
            style: Theme.of(context)
                .extension<ResultContainerTheme>()
                ?.textStyle ??
                Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Colors.white),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire les contrôles de quantité intégrés
  bool _isAsteraOrTitan(CatalogueItem item) {
    final marque = item.marque.toLowerCase();
    final produit = item.produit.toLowerCase();
    return marque.contains('astera') || produit.contains('titan');
  }

  bool _isLineArray(CatalogueItem item) {
    final sousCat = (item.sousCategorie).toLowerCase();
    final produit = item.produit.toLowerCase();
    // Heuristique: produits typiques de line array ou mention explicite
    final keywords = ['line', 'array', 'line array', 'k1', 'k2', 'k3', 'kara', 'a15', 'a10'];
    return keywords.any((k) => sousCat.contains(k) || produit.contains(k));
  }

  String? _defaultAmpForSoundItem(CatalogueItem item) {
    final brandLc = item.marque.toLowerCase();
    final isLine = _isLineArray(item);
    if (brandLc.contains('d&b')) {
      return isLine ? 'D80' : 'D30';
    }
    // L-Acoustics (ou autres marques traitées comme L-Acoustics par défaut)
    return isLine ? 'LA12X' : 'LA4X';
  }

  Widget _buildQuantityControls(CatalogueItem item) {
    final isLightProduct = item.categorie == 'Lumière';
    final isSoundProduct = item.categorie == 'Son' || item.categorie == 'SON' || item.categorie == 'Audio';

    // Appliquer défauts automatiques
    if (isLightProduct && _isAsteraOrTitan(item)) {
      _isWifiMode = true;
    }
    // DMX: tous les produits lumière en "Mini" par défaut si non choisi
    if (isLightProduct && (_selectedDmxType == null || _selectedDmxType!.isEmpty)) {
      _selectedDmxType = 'DMX mini';
    }
    if (isSoundProduct && _selectedAmpModel == null) {
      _selectedAmpModel = _defaultAmpForSoundItem(item);
    }
    final preset = ref.watch(activePresetProvider);
    final presetName = preset?.name ?? 'Preset';
    
    return GestureDetector(
      onTap: () => _showAddDialog(item),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blueGrey[900]?.withOpacity(0.3),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.lightBlue[300]!, width: 1),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de la section: Ajouter 'NomPreset'
          Text(
            '${AppLocalizations.of(context)!.catalogue_addToPreset} $presetName',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          // Contrôles de quantité
          Row(
            children: [
              // Bouton -
              GestureDetector(
                onTap: () {
                  if (_selectedQuantity > 1) {
                    setState(() {
                      _selectedQuantity--;
                    });
                  }
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.remove,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Affichage de la quantité
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _selectedQuantity.toString(),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              // Bouton +
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuantity++;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
              const Spacer(),
              // Bouton corbeille pour réinitialiser
              GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedQuantity = 1;
                    _selectedDmxType = null;
                    _isWifiMode = false;
                  });
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.delete_outline,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ],
          ),
          
          // Sélecteurs pour les produits lumière
          if (isLightProduct) ...[
            const SizedBox(height: 12),
            
            // Sélecteur DMX Mini/Maxi
            Row(
              children: [
                Text(
                  'DMX:',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDmxType = 'DMX mini';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedDmxType == 'DMX mini' ? Colors.lightBlue[300] : Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Mini',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedDmxType = 'DMX max';
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _selectedDmxType == 'DMX max' ? Colors.lightBlue[300] : Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Max',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 8),
            
            // Sélecteur WiFi/Filaire
            Row(
              children: [
                Text(
                  'Mode:',
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                const SizedBox(width: 12),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isWifiMode = false;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: !_isWifiMode ? Colors.lightBlue[300] : Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'Filaire',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _isWifiMode = true;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: _isWifiMode ? Colors.orange[600] : Colors.grey[600],
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      'WiFi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Sélecteur d'amplification pour les produits Son (boutons compacts, sans label)
          if (isSoundProduct) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                ..._buildAmpButtonsForBrand(item.marque),
              ],
            ),
          ],
          
          const SizedBox(height: 12),
          
          // Bouton d'ajout direct supprimé (éviter le doublon avec le bouton Add en dessous)
        ],
      ),
    ),
    );
  }

  // Méthode pour ajouter directement au preset
  void _addToPresetDirectly(CatalogueItem item) {
    // Initialiser les valeurs par défaut si nécessaire
    if (item.categorie == 'Lumière' && _selectedDmxType == null) {
      _selectedDmxType = 'DMX mini';
    }
    
    // Utiliser la méthode existante d'ajout au preset pour l'article sélectionné
    _startAddToProjectAnimation(item, _selectedQuantity, _selectedDmxType);

    // Si catégorie Son et un modèle d'ampli est sélectionné, calculer et ajouter les amplis requis
    try {
      final isSoundProduct = item.categorie == 'Son' || item.categorie == 'SON' || item.categorie == 'Audio';
      if (isSoundProduct && _selectedAmpModel != null) {
        final speakerKey = '${item.marque}:${item.produit}';
        // Construire la clé d'ampli d'après la marque
        final String ampBrand = item.marque.toLowerCase().contains('d&b') ? 'd&b audiotechnik' : 'L-Acoustics';
        final amplifierKey = '$ampBrand:${_selectedAmpModel!}';

        final amplifiersMap = ref.read(amplifiersProvider);
        final amplifier = amplifiersMap[amplifierKey];

        final result = AmplificationCalculatorService.calculate(
          AmplificationRequest(
            speakerKey: speakerKey,
            speakerCount: _selectedQuantity,
            amplifierKey: amplifierKey,
            amplifierMode: '4ch',
            parallelChannels: 1,
          ),
          item,
          amplifier,
        );

        if (result.isValid && result.amplifiersNeeded > 0) {
          // Rechercher l'article catalogue correspondant à l'ampli pour l'ajouter au preset
          final allItems = ref.read(catalogueProvider);
          final ampCatalogueItem = allItems.firstWhere(
            (ci) => ci.categorie == 'Son' &&
                    ci.sousCategorie.toLowerCase().contains('ampli') &&
                    ci.marque.toLowerCase() == ampBrand.toLowerCase() &&
                    ci.produit.toLowerCase() == _selectedAmpModel!.toLowerCase(),
            orElse: () => const CatalogueItem(
              id: '',
              name: '',
              description: '',
              categorie: '',
              sousCategorie: '',
              marque: '',
              produit: '',
              dimensions: '',
              poids: '',
              conso: '',
            ),
          );

          if (ampCatalogueItem.id.isNotEmpty) {
            final preset = ref.read(presetProvider.notifier).activePreset;
            if (preset != null) {
              final cartItemAmp = CartItem(item: ampCatalogueItem, quantity: result.amplifiersNeeded);
              preset.items.add(cartItemAmp);
              ref.read(presetProvider.notifier).updatePreset(preset);
            }
          } else {
            // Informer si l'ampli n'existe pas encore dans le catalogue
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Ampli ${_selectedAmpModel!} introuvable dans le catalogue - ajout non effectué"),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      }
    } catch (_) {}
    
    // Réinitialiser les valeurs après ajout
    setState(() {
      _selectedQuantity = 1;
      _selectedDmxType = null;
      _isWifiMode = false;
      _selectedAmpModel = null;
    });
    
    // Afficher un message de confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${item.produit} ajouté au preset (${_selectedQuantity}x)'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // _confirmAndAdd supprimé: on ajoute directement après validation du popup quantité

  Future<void> _showAddDialog(CatalogueItem item) async {
    final preset = ref.read(activePresetProvider);
    final presetName = preset?.name ?? 'Preset';

    // Préparer les valeurs locales pour l'UI du popup
    int localQty = _selectedQuantity;
    String? localDmx = item.categorie == 'Lumière' ? (_selectedDmxType ?? 'DMX mini') : null;
    // Defaults for popup
    bool localWifi = _isAsteraOrTitan(item) ? true : _isWifiMode;
    String? localAmp = (item.categorie == 'Son' || item.categorie == 'SON' || item.categorie == 'Audio')
        ? (_selectedAmpModel ?? _defaultAmpForSoundItem(item))
        : null;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0A1128)
                  : Colors.white,
              contentPadding: const EdgeInsets.all(12),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre "Ajouter 'NomPreset'"
                  Text(
                    '${AppLocalizations.of(context)!.catalogue_addToPreset} $presetName',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Reprise des contrôles quantité/DMX/WiFi du cadre
                  // Quantité
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          if (localQty > 1) setState(() => localQty--);
                        },
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.remove, color: Colors.white, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          '$localQty',
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: () => setState(() => localQty++),
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.white, size: 16),
                        ),
                      ),
                    ],
                  ),

                  if (item.categorie == 'Lumière') ...[
                    const SizedBox(height: 12),
                    // DMX Mini / Max
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => localDmx = 'DMX mini'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: localDmx == 'DMX mini' ? Colors.lightBlue[300] : Colors.grey[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Mini', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => localDmx = 'DMX max'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: localDmx == 'DMX max' ? Colors.lightBlue[300] : Colors.grey[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Max', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // WiFi / Filaire
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => setState(() => localWifi = false),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: !localWifi ? Colors.lightBlue[300] : Colors.grey[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('Filaire', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => setState(() => localWifi = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: localWifi ? Colors.orange[600] : Colors.grey[600],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text('WiFi', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ],

                  // Amplification (Son) - boutons compacts
                  if (item.categorie == 'Son' || item.categorie == 'SON' || item.categorie == 'Audio') ...[
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        ..._buildAmpButtonsForBrand(item.marque).map((w) {
                          // Adapter le onTap pour la variable locale
                          if (w is Padding && w.child is GestureDetector) {
                            final gd = (w.child as GestureDetector);
                            if (gd.child is Container) {
                              final container = gd.child as Container;
                              if (container.child is Text) {
                                final label = (container.child as Text).data ?? '';
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8),
                                  child: GestureDetector(
                                    onTap: () => setState(() => localAmp = label),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: localAmp == label ? Colors.lightBlue[300] : Colors.grey[600],
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                                    ),
                                  ),
                                );
                              }
                            }
                          }
                          return w;
                        }),
                      ],
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppLocalizations.of(context)!.catalogueQuantityDialog_cancel, style: TextStyle(color: Colors.lightBlue[300])),
                ),
                TextButton(
                  onPressed: () {
                    // Synchroniser les valeurs choisies vers l'état principal
                    setState(() {
                      _selectedQuantity = localQty;
                      _selectedDmxType = localDmx;
                      _isWifiMode = localWifi;
                      _selectedAmpModel = localAmp;
                    });
                    Navigator.of(context).pop();
                    _addToPresetDirectly(item);
                  },
                  child: Text(AppLocalizations.of(context)!.catalogueQuantityDialog_confirm, style: TextStyle(color: Colors.lightBlue[300])),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Méthode helper pour afficher la section lentilles de projection
  Widget _buildOptiquesSection(List<Lens> optiques) {
    final loc = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          loc.catalogue_lensesAvailable,
          style: Theme.of(context)
              .extension<ResultContainerTheme>()
              ?.textStyle ??
              Theme.of(context)
                  .textTheme
                  .bodyMedium!
                  .copyWith(
                    color: Colors.white70,
                    fontWeight: FontWeight.w600,
                  ),
        ),
        const SizedBox(height: 4),
        ...optiques.map((optique) => Padding(
          padding: const EdgeInsets.only(left: 16, top: 2),
          child: Text(
            '• ${optique.reference} - ${loc.catalogue_projectionRatio}: ${optique.ratio}',
            style: Theme.of(context)
                .extension<ResultContainerTheme>()
                ?.textStyle ??
                Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(color: Colors.white70),
          ),
        )),
        if (optiques.any((optique) => optique.notes != null && optique.notes!.isNotEmpty))
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 4),
            child: Text(
              'Notes: ${optiques.where((optique) => optique.notes != null && optique.notes!.isNotEmpty).map((optique) => optique.notes).join(', ')}',
              style: Theme.of(context)
                  .extension<ResultContainerTheme>()
                  ?.textStyle ??
                  Theme.of(context)
                      .textTheme
                      .bodySmall!
                      .copyWith(color: Colors.white60, fontStyle: FontStyle.italic),
            ),
          ),
      ],
    );
  }

  Widget _buildCatalogueContent() {

    if (isLoading) {
      return const Center(
              child: CircularProgressIndicator(),
      );
    } else if (error != null) {
      return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                        error = null;
                      });
                      ref.read(catalogueProvider.notifier).loadCatalogue();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
      );
    } else {
      return SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128).withOpacity(0.7),
                        border: Border.all(color: Colors.white, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                TextField(
                                  controller: _searchController,
                                  textDirection: TextDirection.ltr,
                                  textAlign: TextAlign.left,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    hintText: AppLocalizations.of(context)!.catalogPage_search,
                                    hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white.withOpacity(0.7)
                                          : Colors.black.withOpacity(0.7),
                                    ),
                                    prefixIcon: Icon(
                                      Icons.search,
                                      color: Theme.of(context).brightness == Brightness.dark
                                          ? Colors.white
                                          : Colors.black,
                                      size: 20,
                                    ),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                  ),
                                ),
                                if (searchQuery.length >= 3 &&
                                    filteredItems.isNotEmpty)
                                  Container(
                                    margin: const EdgeInsets.symmetric(
                                        horizontal: 16),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? const Color(0xFF0A1128)
                                              .withOpacity(0.9)
                                          : Colors.white.withOpacity(0.9),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black,
                                          width: 1),
                                    ),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      padding: const EdgeInsets.all(8),
                                      itemCount: filteredItems.length,
                                      itemBuilder: (context, index) {
                                        final item = filteredItems[index];
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              selectedBrand = item.marque;
                                              selectedProduct = item.produit;
                                              searchQuery = '';
                                            });
                                            _savePersistedState();
                                            
                                            // Focus automatique vers le résultat
                                            _scrollToResult();
                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8, horizontal: 12),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                    '${item.marque} - ${item.produit}',
                                                    style: Theme.of(context)
                                                        .textTheme
                                                        .bodyMedium),
                                                Text(
                                                  item.sousCategorie,
                                                  style: Theme.of(context)
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? Colors.white
                                                                  .withOpacity(
                                                                      0.7)
                                                              : Colors.black
                                                                  .withOpacity(
                                                                      0.7)),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: BorderLabeledDropdown<String>(
                                        label: AppLocalizations.of(context)!.category,
                                        value: selectedCategory,
                                        items: _categories
                                            .map((cat) => DropdownMenuItem(
                                                  value: cat,
                                                  child: Text(cat,
                                                      style: const TextStyle(fontSize: 11)),
                                                ))
                                            .toList(),
                                        onChanged: _handleCategorySelection,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: BorderLabeledDropdown<String>(
                                        label: AppLocalizations.of(context)!.catalogPage_subCategory,
                                        value: selectedSubCategory,
                                        items: _subCategoriesForSelectedCategory
                                            .map((sub) => DropdownMenuItem(
                                                  value: sub,
                                                  child: Text(sub,
                                                      style: const TextStyle(fontSize: 11)),
                                                ))
                                            .toList(),
                                        onChanged: _handleSubCategorySelection,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                BorderLabeledDropdown<String>(
                                  label: AppLocalizations.of(context)!.brand,
                                  value: selectedBrand,
                                  items: _uniqueBrands
                                      .map((brand) => DropdownMenuItem(
                                            value: brand,
                                            child: Text(brand,
                                                style: const TextStyle(fontSize: 11)),
                                          ))
                                      .toList(),
                                  onChanged: _handleBrandSelection,
                                ),
                                const SizedBox(height: 8),
                                BorderLabeledDropdown<String>(
                                  label: AppLocalizations.of(context)!.product,
                                  value: selectedProduct,
                                  items: _productsForSelectedFilters
                                      .map((prod) => DropdownMenuItem(
                                            value: prod,
                                            child: Text(prod,
                                                style: const TextStyle(fontSize: 11)),
                                          ))
                                      .toList(),
                                  onChanged: _handleProductSelection,
                                ),
                                const SizedBox(height: 12),
                                
                                // Boutons d'action toujours visibles
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                    ActionButton(
                                      icon: Icons.camera_alt,
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ArMeasurePage(),
                                                    ),
                                                  );
                                                },
                                      iconSize: 28,
                                              ),
                                              const SizedBox(width: 20),
                                    ActionButton(
                                      icon: Icons.add,
                                                onPressed: () {
                                                  if (selectedProduct != null) {
                                                    final selectedItem =
                                              filteredItems.firstWhere(
                                                      (item) =>
                                                item.produit == selectedProduct,
                                            orElse: () => CatalogueItem(
                                                        id: '',
                                                        name: '',
                                                        description: '',
                                                        categorie: '',
                                                        sousCategorie: '',
                                                        marque: '',
                                                        produit: '',
                                                        dimensions: '',
                                                        poids: '',
                                                        conso: '',
                                                      ),
                                                    );
                                          if (selectedItem.id.isNotEmpty) {
                                            _showAddDialog(selectedItem);
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Veuillez sélectionner un produit d\'abord'),
                                            ),
                                          );
                                        }
                                      },
                                      iconSize: 28,
                                              ),
                                              const SizedBox(width: 20),
                                    ActionButton(
                                      icon: Icons.refresh,
                                                onPressed: _resetFilters,
                                      iconSize: 28,
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
                                
                                // Résultat du produit sélectionné
                                if (selectedProduct != null &&
                                    selectedProduct!.isNotEmpty)
                                  Builder(
                                    builder: (context) {
                                      final CatalogueItem selectedItem =
                                          filteredItems.firstWhere(
                                        (item) =>
                                            item.produit == selectedProduct,
                                        orElse: () => CatalogueItem(
                                          id: '',
                                          name: '',
                                          description: '',
                                          categorie: '',
                                          sousCategorie: '',
                                          marque: '',
                                          produit: '',
                                          dimensions: '',
                                          poids: '',
                                          conso: '',
                                        ),
                                      );
                                      if (selectedItem.id.isEmpty || !_hasDataToShow(selectedItem)) {
                                        return const SizedBox();
                                      }
                                      return Column(
                                        children: [
                                          Container(
                                            key: _resultKey,
                                            width: double.infinity,
                                            padding: const EdgeInsets.all(16),
                                            margin: const EdgeInsets.only(
                                                bottom: 12),
                                            decoration: BoxDecoration(
                                              color: Theme.of(context)
                                                      .extension<
                                                          ResultContainerTheme>()
                                                      ?.backgroundColor ??
                                                  const Color(0xFF0A1128)
                                                      .withOpacity(0.5),
                                              border: Border.all(
                                                  color: Theme.of(context)
                                                          .extension<
                                                              ResultContainerTheme>()
                                                          ?.borderColor ??
                                                      Colors.white,
                                                  width: 1),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  selectedItem.produit,
                                                  style: Theme.of(context)
                                                          .extension<
                                                              ResultContainerTheme>()
                                                          ?.titleStyle ??
                                                      Theme.of(context)
                                                          .textTheme
                                                          .titleLarge!
                                                          .copyWith(
                                                              color:
                                                                  Colors.white),
                                                ),
                                                const SizedBox(height: 12),
                                                
                                                // Informations de base
                                                if (selectedItem.marque.isNotEmpty)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_brand, selectedItem.marque),
                                                if (selectedItem.description.isNotEmpty)
                                                  _buildDescriptionRow(AppLocalizations.of(context)!.catalogue_description, selectedItem.description),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Caractéristiques physiques
                                                if (selectedItem.taille != null)
                                                  _buildCharacteristicRow('Taille', '${selectedItem.taille}"'),
                                                if (selectedItem.dimensions.isNotEmpty)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_dimensions, selectedItem.dimensions),
                                                if (selectedItem.poids.isNotEmpty)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_weight, selectedItem.poids),
                                                if (selectedItem.conso.isNotEmpty)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_consumption, selectedItem.conso),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Caractéristiques techniques
                                                if (selectedItem.resolutionDalle != null)
                                                  _buildCharacteristicRow('Résolution dalle', selectedItem.resolutionDalle!),
                                                if (selectedItem.resolution != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_resolution, selectedItem.resolution!),
                                                if (selectedItem.pitch != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_pitch, selectedItem.pitch!),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Caractéristiques lumière
                                                if (selectedItem.angle != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_angle, selectedItem.angle!),
                                                if (selectedItem.lux != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_lux, selectedItem.lux!),
                                                if (selectedItem.lumens != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_lumens, selectedItem.lumens!),
                                                if (selectedItem.definition != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_definition, selectedItem.definition!),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Caractéristiques DMX
                                                if (selectedItem.dmxMax != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_dmxMax, selectedItem.dmxMax!),
                                                if (selectedItem.dmxMini != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_dmxMini, selectedItem.dmxMini!),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Caractéristiques audio
                                                if (selectedItem.puissanceAdmissible != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_powerAdmissible, selectedItem.puissanceAdmissible!),
                                                if (selectedItem.impedanceNominale != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_impedanceNominal, selectedItem.impedanceNominale!),
                                                if (selectedItem.impedanceOhms != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_impedance, '${selectedItem.impedanceOhms} Ω'),
                                                if (selectedItem.powerRmsW != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_powerRms, '${selectedItem.powerRmsW} W'),
                                                if (selectedItem.powerProgramW != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_powerProgram, '${selectedItem.powerProgramW} W'),
                                                if (selectedItem.powerPeakW != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_powerPeak, '${selectedItem.powerPeakW} W'),
                                                if (selectedItem.maxVoltageVrms != null)
                                                  _buildCharacteristicRow(AppLocalizations.of(context)!.catalogue_maxVoltage, '${selectedItem.maxVoltageVrms} Vrms'),
                                                
                                                const SizedBox(height: 8),
                                                
                                                // Lentilles de projection (pour projecteurs vidéo)
                                                if (selectedItem.optiques != null && selectedItem.optiques!.isNotEmpty)
                                                  _buildOptiquesSection(selectedItem.optiques!),
                                                
                                                const SizedBox(height: 4),
                                                
                                                // Commentaire utilisateur
                                                if (_getCommentForItem(selectedItem).isNotEmpty) ...[
                                                  const SizedBox(height: 12),
                                                  Container(
                                                    width: double.infinity,
                                                    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
                                                      color: Theme.of(context).brightness == Brightness.dark
                                                          ? Colors.blue[900]?.withOpacity(0.3)
                                                          : Colors.blue[50],
                                                      borderRadius: BorderRadius.circular(8),
                                                      border: Border.all(
                                                        color: Theme.of(context).brightness == Brightness.dark
                                                            ? Colors.lightBlue[300]!
                                                            : Colors.blue[300]!,
                                                        width: 1,
                                                      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
                                                        Icon(
                                                          Icons.chat_bubble_outline,
                                                          size: 16,
                                                          color: Theme.of(context).brightness == Brightness.dark
                                                              ? Colors.lightBlue[300]
                                                              : Colors.blue[700],
                                                        ),
                                                        const SizedBox(height: 6),
                                                        Text(
                                                          _getCommentForItem(selectedItem),
                                                          style: TextStyle(
                                                            fontSize: 13,
                                                            color: Theme.of(context).brightness == Brightness.dark
                                                                ? Colors.white
                                                                : Colors.black87,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                          ),
                                          
                                          // Cadre d'ajout intégré placé en bas du résultat
                                          const SizedBox(height: 8),
                                          _buildQuantityControls(selectedItem),
                                          
                                          // Boutons d'action dans le cadre résultat
                                          const SizedBox(height: 8),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              // Bouton Commentaire (icône uniquement)
                                              ActionButton.comment(
                                                onPressed: () => _showCommentDialog(selectedItem),
                                                iconSize: 28,
                                              ),
                                              const SizedBox(width: 20),
                                              // Bouton Upload (sans rotation) avec fond identique à Add
                                              ExportWidget(
                                                title: '${AppLocalizations.of(context)!.catalogAccess} Wallet',
                                                content: _buildExportContent(selectedItem),
                                                fileName: 'catalogue_${DateTime.now().millisecondsSinceEpoch}',
                                                backgroundColor: Colors.blueGrey[900],
                                              ),
                                              const SizedBox(width: 20),
                                              // Bouton Add Preset (ouvre le popup d'ajout détaillé)
                                              ActionButton(
                                                icon: Icons.add,
                                                onPressed: () => _showAddDialog(selectedItem),
                                                iconSize: 28,
                                              ),
                                            ],
                                          ),
                                        ],
                                      );
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
  }
}
