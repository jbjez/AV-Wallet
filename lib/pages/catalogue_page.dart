import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/catalogue_item.dart';
import '../models/cart_data.dart';
import '../models/cart_item.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'calcul_projet_page.dart';
import 'ar_measure_page.dart';
import '../widgets/preset_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../providers/preset_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/catalogue_item_form.dart';

class CataloguePage extends ConsumerStatefulWidget {
  const CataloguePage({super.key});

  @override
  ConsumerState<CataloguePage> createState() => _CataloguePageState();
}

class _CataloguePageState extends ConsumerState<CataloguePage> {
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

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(catalogueServiceProvider).loadCatalogue());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToResult() {
    if (selectedProduct != null && selectedProduct!.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_resultKey.currentContext != null) {
          Scrollable.ensureVisible(
            _resultKey.currentContext!,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
            alignment: 0.5, // Centre le résultat dans la vue
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
    return items
        .where((item) =>
            item.marque.isNotEmpty &&
            (selectedCategory == null || item.categorie == selectedCategory))
        .map((item) => item.marque)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _categories {
    final items = ref.watch(catalogueProvider);
    return items
        .where((item) => item.categorie.isNotEmpty)
        .map((item) => item.categorie)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _subCategoriesForSelectedCategory {
    final items = ref.watch(catalogueProvider);
    if (selectedCategory == null) return [];
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
    });
  }

  List<CatalogueItem> get filteredItems {
    final items = ref.watch(catalogueProvider);
    return items.where((item) {
      final matchesBrand =
          selectedBrand == null || item.marque == selectedBrand;
      final matchesCategory =
          selectedCategory == null || item.categorie == selectedCategory;
      final matchesSubCategory = selectedSubCategory == null ||
          item.sousCategorie == selectedSubCategory;
      final matchesProduct =
          selectedProduct == null || item.produit == selectedProduct;
      final matchesSearch = searchQuery.isEmpty ||
          (searchQuery.length >= 3 &&
              (item.produit.toLowerCase().contains(searchQuery.toLowerCase()) ||
                  item.marque
                      .toLowerCase()
                      .contains(searchQuery.toLowerCase()) ||
                  (item.description.isNotEmpty &&
                      item.description
                          .toLowerCase()
                          .contains(searchQuery.toLowerCase()))));

      return matchesBrand &&
          matchesCategory &&
          matchesSubCategory &&
          matchesProduct &&
          matchesSearch;
    }).toList();
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
      if (value.length >= 3) {
        final results = filteredItems;
        if (results.isNotEmpty) {
          // Si on trouve une marque correspondante, on la sélectionne
          final matchingBrand = results.first.marque;
          if (matchingBrand.toLowerCase().contains(value.toLowerCase())) {
            selectedBrand = matchingBrand;
            selectedProduct = null;
          }
          // Si on trouve un produit correspondant, on le sélectionne
          else if (results.length == 1) {
            selectedProduct = results.first.produit;
            selectedBrand = results.first.marque;
          }
        }
      } else {
        // Réinitialiser les sélections si la recherche est vide
        selectedBrand = null;
        selectedCategory = null;
        selectedSubCategory = null;
        selectedProduct = null;
      }
    });
  }

  void _handleCategorySelection(String? category) {
    setState(() {
      selectedCategory = category;
      selectedSubCategory = null;
      selectedBrand = null;
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
  }

  void _handleBrandSelection(String? brand) {
    setState(() {
      selectedBrand = brand;
      selectedSubCategory = null;
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
  }

  void _handleSubCategorySelection(String? subCategory) {
    setState(() {
      selectedSubCategory = subCategory;
      selectedBrand = null;
      selectedProduct = null;
      searchQuery = ''; // Réinitialiser la recherche
    });
  }

  void _handleProductSelection(String? product) {
    setState(() {
      selectedProduct = product;
      searchQuery = ''; // Réinitialiser la recherche
    });
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
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
    final loc = AppLocalizations.of(context)!;
    final catalogueService = ref.watch(catalogueServiceProvider);
    final items = ref.watch(catalogueProvider);

    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.list,
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
          if (catalogueService.isLoading)
            const Center(
              child: CircularProgressIndicator(),
            )
          else if (catalogueService.error != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    catalogueService.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(catalogueServiceProvider).loadCatalogue();
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            )
          else if (items.isEmpty)
            const Center(child: Text('Aucun élément dans le catalogue'))
          else
            SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const PresetWidget(
                      loadOnInit: true,
                    ),
                    const SizedBox(height: 6),
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
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  decoration: InputDecoration(
                                    hintText: loc.catalogPage_search,
                                    hintStyle: Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(
                                            color: Theme.of(context)
                                                        .brightness ==
                                                    Brightness.dark
                                                ? Colors.white.withOpacity(0.7)
                                                : Colors.black
                                                    .withOpacity(0.7)),
                                    prefixIcon: Icon(Icons.search,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.black,
                                        size: 20),
                                    filled: true,
                                    fillColor: Colors.transparent,
                                    border: InputBorder.none,
                                  ),
                                  onChanged: _handleSearch,
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
                                      child: DropdownButton<String>(
                                        value: selectedCategory,
                                        hint: Text('Catégorie',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                            .withOpacity(0.7)
                                                        : Colors.black
                                                            .withOpacity(0.7))),
                                        dropdownColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF0A1128)
                                                : Colors.white,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black),
                                        items: _categories
                                            .map((cat) => DropdownMenuItem(
                                                  value: cat,
                                                  child: Text(cat,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black)),
                                                ))
                                            .toList(),
                                        onChanged: _handleCategorySelection,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: selectedSubCategory,
                                        hint: Text('Sous-catégorie',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium!
                                                .copyWith(
                                                    color: Theme.of(context)
                                                                .brightness ==
                                                            Brightness.dark
                                                        ? Colors.white
                                                            .withOpacity(0.7)
                                                        : Colors.black
                                                            .withOpacity(0.7))),
                                        dropdownColor:
                                            Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? const Color(0xFF0A1128)
                                                : Colors.white,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium!
                                            .copyWith(
                                                color: Theme.of(context)
                                                            .brightness ==
                                                        Brightness.dark
                                                    ? Colors.white
                                                    : Colors.black),
                                        items: _subCategoriesForSelectedCategory
                                            .map((sub) => DropdownMenuItem(
                                                  value: sub,
                                                  child: Text(sub,
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .bodyMedium!
                                                          .copyWith(
                                                              color: Theme.of(context)
                                                                          .brightness ==
                                                                      Brightness
                                                                          .dark
                                                                  ? Colors.white
                                                                  : Colors
                                                                      .black)),
                                                ))
                                            .toList(),
                                        onChanged: _handleSubCategorySelection,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: selectedBrand,
                                  hint: Text('Marque',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                      .withOpacity(0.7)
                                                  : Colors.black
                                                      .withOpacity(0.7))),
                                  dropdownColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF0A1128)
                                      : Colors.white,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                  isExpanded: true,
                                  items: _uniqueBrands
                                      .map((brand) => DropdownMenuItem(
                                            value: brand,
                                            child: Text(brand,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black)),
                                          ))
                                      .toList(),
                                  onChanged: _handleBrandSelection,
                                ),
                                const SizedBox(height: 8),
                                DropdownButton<String>(
                                  value: selectedProduct,
                                  hint: Text('Produit',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium!
                                          .copyWith(
                                              color: Theme.of(context)
                                                          .brightness ==
                                                      Brightness.dark
                                                  ? Colors.white
                                                      .withOpacity(0.7)
                                                  : Colors.black
                                                      .withOpacity(0.7))),
                                  dropdownColor: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color(0xFF0A1128)
                                      : Colors.white,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .copyWith(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? Colors.white
                                              : Colors.black),
                                  isExpanded: true,
                                  items: _productsForSelectedFilters
                                      .map((prod) => DropdownMenuItem(
                                            value: prod,
                                            child: Text(prod,
                                                style: Theme.of(context)
                                                    .textTheme
                                                    .bodyMedium!
                                                    .copyWith(
                                                        color: Theme.of(context)
                                                                    .brightness ==
                                                                Brightness.dark
                                                            ? Colors.white
                                                            : Colors.black)),
                                          ))
                                      .toList(),
                                  onChanged: _handleProductSelection,
                                ),
                                const SizedBox(height: 12),
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
                                      if (selectedItem.id.isEmpty) {
                                        return const SizedBox();
                                      }
                                      return Column(
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          const ArMeasurePage(),
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                          0xFF0A1128)
                                                      .withAlpha(
                                                          (0.5 * 255).round()),
                                                  side: BorderSide(
                                                      color: const Color(
                                                              0xFF0A1128)
                                                          .withAlpha((0.8 * 255)
                                                              .round()),
                                                      width: 1),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    Image.asset(
                                                      'assets/icons/tape_measure.png',
                                                      width: 18,
                                                      height: 18,
                                                      color: Colors.white,
                                                    ),
                                                    const SizedBox(width: 6),
                                                    const Text('AR',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: () {
                                                  if (selectedProduct != null) {
                                                    final selectedItem =
                                                        filteredItems
                                                            .firstWhere(
                                                      (item) =>
                                                          item.produit ==
                                                          selectedProduct,
                                                      orElse: () =>
                                                          CatalogueItem(
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
                                                    if (selectedItem
                                                        .id.isNotEmpty) {
                                                      _showQuantityDialog(
                                                          selectedItem);
                                                    }
                                                  }
                                                },
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                          0xFF0A1128)
                                                      .withAlpha(
                                                          (0.5 * 255).round()),
                                                  side: BorderSide(
                                                      color: const Color(
                                                              0xFF0A1128)
                                                          .withAlpha((0.8 * 255)
                                                              .round()),
                                                      width: 1),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.add,
                                                        color: Colors.white,
                                                        size: 18),
                                                    const SizedBox(width: 6),
                                                    const Text('Projet',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                              ElevatedButton(
                                                onPressed: _resetFilters,
                                                style: ElevatedButton.styleFrom(
                                                  backgroundColor: const Color(
                                                          0xFF0A1128)
                                                      .withAlpha(
                                                          (0.5 * 255).round()),
                                                  side: BorderSide(
                                                      color: const Color(
                                                              0xFF0A1128)
                                                          .withAlpha((0.8 * 255)
                                                              .round()),
                                                      width: 1),
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 8,
                                                      vertical: 8),
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                ),
                                                child: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Icon(Icons.refresh,
                                                        color: Colors.white,
                                                        size: 18),
                                                    const SizedBox(width: 6),
                                                    const Text('Réinit',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 12),
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
                                                const SizedBox(height: 8),
                                                if (selectedItem
                                                    .marque.isNotEmpty)
                                                  Text(
                                                      'Marque : ${selectedItem.marque}',
                                                      style: Theme.of(context)
                                                              .extension<
                                                                  ResultContainerTheme>()
                                                              ?.textStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                                if (selectedItem
                                                    .description.isNotEmpty)
                                                  Text(
                                                      'Description : ${selectedItem.description}',
                                                      style: Theme.of(context)
                                                              .extension<
                                                                  ResultContainerTheme>()
                                                              ?.textStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                                if (selectedItem
                                                    .dimensions.isNotEmpty)
                                                  Text(
                                                      'Dimensions : ${selectedItem.dimensions}',
                                                      style: Theme.of(context)
                                                              .extension<
                                                                  ResultContainerTheme>()
                                                              ?.textStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                                if (selectedItem
                                                    .poids.isNotEmpty)
                                                  Text(
                                                      'Poids : ${selectedItem.poids}',
                                                      style: Theme.of(context)
                                                              .extension<
                                                                  ResultContainerTheme>()
                                                              ?.textStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                                if (selectedItem
                                                    .conso.isNotEmpty)
                                                  Text(
                                                      'Consommation : ${selectedItem.conso}',
                                                      style: Theme.of(context)
                                                              .extension<
                                                                  ResultContainerTheme>()
                                                              ?.textStyle ??
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium!
                                                              .copyWith(
                                                                  color: Colors
                                                                      .white)),
                                              ],
                                            ),
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
              ),
            ),
          Positioned(
            right: 16,
            bottom: 16,
            child: FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const CalculProjetPage()),
                );
              },
              backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
              child: const Icon(Icons.visibility, color: Colors.white),
            ),
          ),
          if (_isAnimating && _startPosition != null && _startSize != null)
            AnimatedCardShrink(
              startPosition: _startPosition!,
              endPosition: const Offset(16, 16), // Position du preset widget
              startSize: _startSize!,
              onCompleted: () {
                setState(() {
                  _isAnimating = false;
                  _startPosition = null;
                  _startSize = null;
                });
              },
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: (index) {
          final pages = [
            const CataloguePage(),
            const LightMenuPage(),
            const StructureMenuPage(),
            const SoundMenuPage(),
            const VideoMenuPage(),
            const ElectriciteMenuPage(),
            const DiversMenuPage(),
          ];

          Offset beginOffset;
          if (index == 0 || index == 1) {
            beginOffset = const Offset(-1.0, 0.0);
          } else if (index == 5 || index == 6) {
            beginOffset = const Offset(1.0, 0.0);
          } else {
            beginOffset = Offset.zero;
          }

          Navigator.push(
            context,
            PageRouteBuilder(
              pageBuilder: (_, __, ___) => pages[index],
              transitionsBuilder: (_, animation, __, child) {
                if (beginOffset == Offset.zero) {
                  return FadeTransition(opacity: animation, child: child);
                } else {
                  final tween = Tween(begin: beginOffset, end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeInOut));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                }
              },
              transitionDuration: const Duration(milliseconds: 400),
            ),
          );
        },
        items: [
          const BottomNavigationBarItem(
              icon: Icon(Icons.list), label: 'Catalogue'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb), label: 'Lumière'),
          BottomNavigationBarItem(
              icon: Image.asset('assets/truss_icon_grey.png',
                  width: 24, height: 24),
              label: 'Structure'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.volume_up), label: 'Son'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: 'Vidéo'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.bolt), label: 'Électricité'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: 'Divers'),
        ],
      ),
    );
  }

  Future<void> _showAddItemDialog(BuildContext context) async {
    final result = await showDialog<CatalogueItem>(
      context: context,
      builder: (context) => const CatalogueItemForm(),
    );

    if (result != null) {
      await ref.read(catalogueServiceProvider).addItem(result);
    }
  }

  Future<void> _showEditItemDialog(
      BuildContext context, CatalogueItem item) async {
    final result = await showDialog<CatalogueItem>(
      context: context,
      builder: (context) => CatalogueItemForm(item: item),
    );

    if (result != null) {
      await ref.read(catalogueServiceProvider).updateItem(result);
    }
  }

  Future<void> _showDeleteConfirmation(
      BuildContext context, CatalogueItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text('Voulez-vous vraiment supprimer ${item.name} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await ref.read(catalogueServiceProvider).deleteItem(item.id);
    }
  }
}

class AnimatedCardShrink extends StatefulWidget {
  final Offset startPosition;
  final Offset endPosition;
  final Size startSize;
  final VoidCallback onCompleted;

  const AnimatedCardShrink({
    super.key,
    required this.startPosition,
    required this.endPosition,
    required this.startSize,
    required this.onCompleted,
  });

  @override
  _AnimatedCardShrinkState createState() => _AnimatedCardShrinkState();
}

class _AnimatedCardShrinkState extends State<AnimatedCardShrink>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _positionAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _controller.forward().then((_) {
      widget.onCompleted();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _scaleAnimation.value,
              child: Container(
                width: widget.startSize.width,
                height: widget.startSize.height,
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: const Center(
                  child: Icon(Icons.notes, color: Colors.white),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
