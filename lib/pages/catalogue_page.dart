import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/catalogue_item.dart';
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
    return items
        .where((item) => item.categorie.isNotEmpty)
        .map((item) => item.categorie)
        .toSet()
        .toList()
      ..sort();
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
        content.writeln('• ${optique}');
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
    final TextEditingController quantityController =
        TextEditingController(text: '1');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(String value) {
              final newQuantity = int.tryParse(value) ?? 1;
              if (newQuantity > 0) {
                setState(() {
                  quantity = newQuantity;
                  quantityController.text = quantity.toString();
                });
              }
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0A1128)
                  : Colors.white,
              title: Text(
                'Quantité',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.produit,
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              quantityController.text = quantity.toString();
                            });
                          }
                        },
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          onTap: () {
                            quantityController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: quantityController.text.length,
                            );
                          },
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.black),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          onChanged: updateQuantity,
                          onSubmitted: updateQuantity,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            quantityController.text = quantity.toString();
                          });
                        },
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ],
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
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    _startAddToProjectAnimation(item, quantity);
                  },
                  child: Text(
                    'Ajouter',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
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

  void _startAddToProjectAnimation(CatalogueItem item, int quantity) {
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
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
                        : const Color(0xFF0A1128),  // Bleu nuit en mode jour
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
                        : const Color(0xFF0A1128),  // Bleu nuit en mode jour
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.list,
                              size: 16,
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
                                  : const Color(0xFF0A1128),  // Bleu nuit en mode jour
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Catalogue AV',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
                                    : const Color(0xFF0A1128),  // Bleu nuit en mode jour
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40), // Descendu de 10 à 40 (+30px)
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildCatalogueContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // PresetWidget fixe sous le titre - centré et transparent
          Positioned(
            top: 70, // Descendu de 60 à 70 (+10px)
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                color: Colors.transparent, // Fond complètement transparent
                child: const PresetWidget(
                  loadOnInit: true,
                ),
              ),
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
        )).toList(),
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
                        color: const Color(0xFF0A1128).withOpacity(0.3),
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
                                      iconSize: 18,
                                              ),
                                              const SizedBox(width: 8),
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
                                            _showQuantityDialog(selectedItem);
                                          }
                                        } else {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('Veuillez sélectionner un produit d\'abord'),
                                            ),
                                          );
                                        }
                                      },
                                      iconSize: 18,
                                              ),
                                              const SizedBox(width: 8),
                                    ActionButton(
                                      icon: Icons.refresh,
                                                onPressed: _resetFilters,
                                      iconSize: 18,
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
                                              // Bouton Export
                                              ExportWidget(
                                                title: 'Catalogue AV Wallet',
                                                content: _buildExportContent(selectedItem),
                                                fileName: 'catalogue_${DateTime.now().millisecondsSinceEpoch}',
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
