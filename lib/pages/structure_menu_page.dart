// lib/pages/structure_menu_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../data/asd_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../widgets/preset_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../models/preset.dart';
import '../providers/catalogue_provider.dart';
import '../providers/project_provider.dart';
import '../providers/imported_files_provider.dart';
import '../widgets/export_widget.dart';
import '../widgets/action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../widgets/uniform_bottom_nav_bar.dart';

class StructureMenuPage extends ConsumerStatefulWidget {
  const StructureMenuPage({super.key});

  @override
  ConsumerState<StructureMenuPage> createState() => _StructureMenuPageState();
}

class _StructureMenuPageState extends ConsumerState<StructureMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedStructure = 'SC300';
  double distance = 6;
  String selectedCharge = 'structurePage_chargeRepartie';
  double additionalLoad = 0;
  bool showResult = false;
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  bool showSearchResults = false;
  
  // Gestion des commentaires
  Map<String, String> _comments = {};
  String _currentStructureResult = ''; // Clé unique pour le résultat actuel

  final Map<String, double> coeffCharge = {
    'structurePage_chargeRepartie': 1.0,
    'structurePage_pointAccrocheCentre': 1.5,
    'structurePage_pointsAccrocheExtremites': 1.2,
    'structurePage_3pointsAccroche': 1.1,
    'structurePage_4pointsAccroche': 1.05,
  };

  late final List<String> chargeOptions = coeffCharge.keys.toList();

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
      if (value.length >= 3) {
        final items = ref.read(catalogueProvider);
        searchResults = items
            .where((item) =>
                item.produit.toLowerCase().contains(value.toLowerCase()) ||
                item.marque.toLowerCase().contains(value.toLowerCase()))
            .toList();
        showSearchResults = true;
      } else {
        showSearchResults = false;
      }
    });
  }

  void _showQuantityDialog(CatalogueItem item, int initialQuantity) {
    final loc = AppLocalizations.of(context)!;
    int quantity = initialQuantity;
    final TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

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
                loc.quantity,
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
                    loc.cancel,
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
                    final preset =
                        ref.read(presetProvider.notifier).activePreset;
                    if (preset != null) {
                      final cartItem = preset.items.firstWhere(
                        (cartItem) => cartItem.item.id == item.id,
                        orElse: () => CartItem(item: item, quantity: 0),
                      );
                      cartItem.quantity = quantity;
                      ref.read(presetProvider.notifier).updatePreset(preset);
                      setState(() {});
                    }
                  },
                  child: Text(
                    loc.structurePage_modifier,
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

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Charger la persistance après que le widget soit construit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadPersistedState();
      _loadComments();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les commentaires quand on change de projet
    _loadComments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    // Sauvegarder l'état avant de fermer
    _savePersistedState();
    super.dispose();
  }

  ASDStructure? get currentStructure =>
      asdStructures.firstWhere((s) => s.reference == selectedStructure);

  ASDLoadEntry? get currentLoadEntry {
    if (currentStructure == null) return null;
    return currentStructure!.loadTable.firstWhere(
      (entry) => entry.span >= distance,
      orElse: () => currentStructure!.loadTable.last,
    );
  }

  double get poidsStructure => currentStructure?.selfWeightPerMeter ?? 0;
  double get chargeMaximale {
    if (currentLoadEntry == null) return 0;
    final baseLoad = currentLoadEntry!.udl;
    final chargeCoef = coeffCharge[selectedCharge] ?? 1.0;
    return (baseLoad - poidsStructure) * chargeCoef;
  }

  double get flecheMaximale => currentLoadEntry?.deflection ?? 0;

  String get unitCharge =>
      selectedCharge == 'structurePage_chargeRepartie' ? '/m' : '/pt';

  void _calculateLoad() {
    setState(() {
      showResult = true;
      // Générer une nouvelle clé unique pour ce résultat
      _currentStructureResult = _generateStructureResultKey();
    });
    _savePersistedState();
  }

  void _resetCalculation() {
    setState(() {
      showResult = false;
      // Effacer le commentaire du résultat précédent
      if (_currentStructureResult.isNotEmpty) {
        _comments.remove(_currentStructureResult);
        _saveComments();
      }
      _currentStructureResult = '';
    });
    _savePersistedState();
  }

  // Méthodes de persistance
  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Attendre un peu pour s'assurer que le widget est prêt
      await Future.delayed(const Duration(milliseconds: 500));
      
      if (!mounted) return;
      
      print('Structure: Loading persisted state...');
      
      // Restaurer les paramètres de calcul
      final savedStructure = prefs.getString('structure_selected_structure');
      final savedDistance = prefs.getDouble('structure_distance');
      final savedCharge = prefs.getString('structure_selected_charge');
      final savedShowResult = prefs.getBool('structure_show_result');
      
      print('Structure: Saved values - Structure: $savedStructure, Distance: $savedDistance, Charge: $savedCharge, ShowResult: $savedShowResult');
      
      if (!mounted) return;
      
      setState(() {
        if (savedStructure != null && asdStructures.any((s) => s.reference == savedStructure)) {
          selectedStructure = savedStructure;
          print('Structure: Restored structure: $selectedStructure');
        }
        
        if (savedDistance != null && savedDistance >= 3 && savedDistance <= 20) {
          distance = savedDistance;
          print('Structure: Restored distance: $distance');
        }
        
        if (savedCharge != null && coeffCharge.containsKey(savedCharge)) {
          selectedCharge = savedCharge;
          print('Structure: Restored charge: $selectedCharge');
        }
        
        if (savedShowResult != null) {
          showResult = savedShowResult;
          print('Structure: Restored showResult: $showResult');
        }
      });
      
      print('Structure: Persistence restoration completed successfully');
    } catch (e) {
      print('Structure: Error loading persisted state: $e');
    }
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('Structure: Saving state - Structure: $selectedStructure, Distance: $distance, Charge: $selectedCharge, ShowResult: $showResult');
      
      await prefs.setString('structure_selected_structure', selectedStructure);
      await prefs.setDouble('structure_distance', distance);
      await prefs.setString('structure_selected_charge', selectedCharge);
      await prefs.setBool('structure_show_result', showResult);
      
      print('Structure: State saved successfully');
    } catch (e) {
      print('Structure: Error saving state: $e');
    }
  }

  Widget _buildLoadCalculationTab() {
    final loc = AppLocalizations.of(context)!;
    
    // Map pour les traductions des types de charge
    final chargeTranslations = {
      'structurePage_chargeRepartie': loc.structurePage_chargeRepartie,
      'structurePage_pointAccrocheCentre': loc.structurePage_pointAccrocheCentre,
      'structurePage_pointsAccrocheExtremites': loc.structurePage_pointsAccrocheExtremites,
      'structurePage_3pointsAccroche': loc.structurePage_3pointsAccroche,
      'structurePage_4pointsAccroche': loc.structurePage_4pointsAccroche,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 16), // Réduit le padding top de 16 à 6 (remonte de 10px)
      child: Container(
        padding: const EdgeInsets.fromLTRB(16, 26, 16, 16), // Augmente le padding top de 16 à 26 (descend de 10px)
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(color: Colors.white),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BorderLabeledDropdown<String>(
                label: loc.selectStructure,
                value: selectedStructure,
                items: asdStructures
                    .map((s) => DropdownMenuItem<String>(
                          value: s.reference,
                          child: Text(s.reference,
                              style: const TextStyle(fontSize: 11)),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedStructure = v!;
                    showResult = false;
                    // Effacer le commentaire du résultat précédent
                    if (_currentStructureResult.isNotEmpty) {
                      _comments.remove(_currentStructureResult);
                      _saveComments();
                    }
                    _currentStructureResult = '';
                  });
                  _savePersistedState();
                },
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    loc.structurePage_distance(distance.toStringAsFixed(1)),
                    style: Theme.of(context).textTheme.bodyMedium
                  ),
                  Text(
                    '${distance.toStringAsFixed(1)} m',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Slider(
                value: distance,
                min: 3,
                max: currentStructure?.loadTable.last.span ?? 20,
                divisions:
                    ((currentStructure?.loadTable.last.span ?? 20) - 3).round(),
                label: '${distance.round()} m',
                onChanged: (v) {
                  setState(() {
                    distance = v;
                    showResult = false;
                    // Effacer le commentaire du résultat précédent
                    if (_currentStructureResult.isNotEmpty) {
                      _comments.remove(_currentStructureResult);
                      _saveComments();
                    }
                    _currentStructureResult = '';
                  });
                  _savePersistedState();
                },
              ),
              const SizedBox(height: 12),
              BorderLabeledDropdown<String>(
                label: loc.structurePage_selectCharge,
                value: selectedCharge,
                items: chargeOptions
                    .map((c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(chargeTranslations[c] ?? c,
                            style: const TextStyle(fontSize: 11))))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedCharge = v!;
                    showResult = false;
                    // Effacer le commentaire du résultat précédent
                    if (_currentStructureResult.isNotEmpty) {
                      _comments.remove(_currentStructureResult);
                      _saveComments();
                    }
                    _currentStructureResult = '';
                  });
                  _savePersistedState();
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: showResult ? _resetCalculation : _calculateLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[900],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(
                    showResult ? Icons.refresh : Icons.calculate,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ),
              if (showResult) ...[
                const SizedBox(height: 16),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.5),
                      border: Border.all(color: const Color(0xFF0A1128), width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Paramètres de la demande
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.structurePage_structure,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  selectedStructure,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  loc.structurePage_length,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                Text(
                                  '${distance.toStringAsFixed(1)} m',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  loc.structurePage_chargeType,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  chargeTranslations[selectedCharge] ?? selectedCharge,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                          ],
                        ),
                        Text(
                          '${loc.structurePage_maxLoadTitle}: ${chargeMaximale.toStringAsFixed(1)} kg$unitCharge',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! - 2,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.structurePage_structureWeightTitle}: ${poidsStructure.toStringAsFixed(1)} kg/m',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.structurePage_maxDeflectionTitle}: ${flecheMaximale.toStringAsFixed(0)} mm',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${loc.structurePage_deflectionRatioTitle}: 1/${(distance * 1000 / flecheMaximale).round()}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        
                        // Commentaire utilisateur (au-dessus des boutons)
                        if (_getCommentForTab('structure_tab').isNotEmpty) ...[
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
                                  _getCommentForTab('structure_tab'),
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
                          const SizedBox(height: 16),
                        ],
                        
                        // Boutons d'action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bouton Commentaire (icône uniquement)
                            ActionButton.comment(
                              onPressed: () => _showCommentDialog('structure_tab', 'Structure'),
                              iconSize: 28,
                            ),
                            const SizedBox(width: 20),
                            // Bouton Export (rotated)
                            Transform.rotate(
                              angle: 3.14159, // 180° en radians
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                ),
                                child: ExportWidget(
                                  title: 'Calcul de structure - ${selectedStructure}',
                                  content: 'Résultats du calcul de charge pour une structure ${selectedStructure} de ${distance.toStringAsFixed(1)}m',
                                  presetName: 'Structure ${selectedStructure}',
                                  exportDate: DateTime.now(),
                                  projectType: 'structure',
                                  projectSummary: {
                                    'structure': selectedStructure,
                                    'distance': '${distance.toStringAsFixed(1)} m',
                                    'chargeType': chargeTranslations[selectedCharge] ?? selectedCharge,
                                    'maxLoad': '${chargeMaximale.toStringAsFixed(1)} kg$unitCharge',
                                    'structureWeight': '${poidsStructure.toStringAsFixed(1)} kg/m',
                                    'maxDeflection': '${flecheMaximale.toStringAsFixed(0)} mm',
                                    'deflectionRatio': '1/${(distance * 1000 / flecheMaximale).round()}',
                                  },
                                  projectData: [],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProjectTab() {
    // Récupérer tous les presets du projet actuel au lieu d'un seul
    final presets = ref.watch(presetProvider);
    
    if (presets.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noPresetSelected,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final grouped = <String, List<CatalogueItem>>{};
    final totalsPerCategory = <String, double>{};
    double totalProjet = 0;
    int totalItems = 0;
    int totalExports = 0;
    bool showConso = false; // Toujours false pour l'onglet poids

    // 🔹 Calcule pour TOUS les presets du projet
    for (final preset in presets) {
      for (var item in preset.items) {
        final cat = item.item.categorie;
        grouped.putIfAbsent(cat, () => []).add(item.item);

        final value = showConso
            ? (item.item.conso.contains('W')
                ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                : 0)
            : (item.item.poids.contains('kg')
                ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                : 0);

        totalsPerCategory.update(
          cat,
          (existing) => existing + value,
          ifAbsent: () => value.toDouble(),
        );

        totalProjet += value;
        
        // Compter les exports
        if (item.item.categorie == 'Export') {
          totalExports += item.quantity;
        } else {
          // Compter seulement les vrais articles (pas les exports)
          totalItems += item.quantity;
        }
      }
    }

    return Center(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9, // Réduire la largeur de 10%
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Laisser respirer les bordures
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 1), // Bordure blanche
        ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche pour ajouts d'articles de dernière minute
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    if (value.length >= 3) {
                      final items = ref.read(catalogueProvider);
                      searchResults = items
                          .where((item) =>
                              item.name.toLowerCase().contains(value.toLowerCase()) ||
                              item.marque.toLowerCase().contains(value.toLowerCase()) ||
                              item.produit.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                      showSearchResults = true;
                    } else {
                      showSearchResults = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchArticlePlaceholder,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF0A1128).withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            
            // Résultats de recherche
            if (showSearchResults && searchResults.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...searchResults.take(5).map((item) => InkWell(
                      onTap: () {
                        // Fermer la recherche
                        setState(() {
                          searchQuery = '';
                          showSearchResults = false;
                          searchResults.clear();
                        });
                        // Lancer automatiquement le popup quantité
                        _showQuantityDialog(item, 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.marque} - ${item.produit}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            if (item.sousCategorie.isNotEmpty)
                              Text(
                                item.sousCategorie,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            // Résumé global du projet
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: 400, // Largeur fixe basée sur un maximum de 999 articles
              ),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.presetCount} : ${presets.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.totalArticlesCount} : $totalItems',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.exportCount} : $totalExports',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Détail par preset
            ...presets.asMap().entries.map((presetEntry) {
              final presetIndex = presetEntry.key;
              final preset = presetEntry.value;
              
              // Calculer le total pour ce preset
              double totalPreset = 0;
              final groupedByCategory = <String, List<CartItem>>{};
              
              for (var item in preset.items) {
                final cat = item.item.categorie;
                groupedByCategory.putIfAbsent(cat, () => []).add(item);
                
                final value = item.item.poids.contains('kg')
                    ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                    : 0;
                
                totalPreset += value;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1), // Bordure blanche pour le cadre preset
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du preset
                      Text(
                        preset.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Catégorie du preset (si tous les articles ont la même catégorie)
                      if (preset.items.isNotEmpty && preset.items.where((item) => item.item.categorie != 'Export').isNotEmpty) ...[
                        Text(
                          preset.items.where((item) => item.item.categorie != 'Export').first.item.categorie,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[300],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Articles du preset (sans groupement par catégorie et sans exports)
                      ...preset.items
                          .where((item) => item.item.categorie != 'Export') // Filtrer les exports
                          .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1: Nom de l'article
                            Text(
                              '${item.item.name} (${item.item.marque})',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ligne 2: Quantité avec + et - et poids à droite
                            Row(
                              children: [
                                // Bouton -
                                GestureDetector(
                                  onTap: () async {
                                    if (item.quantity > 1) {
                                      final newQuantity = item.quantity - 1;
                                      // Mettre à jour le preset
                                      final updatedItems = preset.items.map((i) {
                                        if (i.item.id == item.item.id) {
                                          return i.copyWith(quantity: newQuantity);
                                        }
                                        return i;
                                      }).toList();
                                      
                                      final updatedPreset = preset.copyWith(items: updatedItems);
                                      await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                                      
                                      // Le provider notifiera automatiquement le changement
                                    }
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Quantité (cliquable pour modification)
                                GestureDetector(
                                  onTap: () {
                                    _showPresetItemQuantityDialog(item, preset);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Bouton +
                                GestureDetector(
                                  onTap: () async {
                                    final newQuantity = item.quantity + 1;
                                    // Mettre à jour le preset
                                    final updatedItems = preset.items.map((i) {
                                      if (i.item.id == item.item.id) {
                                        return i.copyWith(quantity: newQuantity);
                                      }
                                      return i;
                                    }).toList();
                                    
                                    final updatedPreset = preset.copyWith(items: updatedItems);
                                    await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                                    
                                    // Le provider notifiera automatiquement le changement
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Poids à droite
                                Text(
                                  '${((double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity).toStringAsFixed(2)} ${AppLocalizations.of(context)!.unitKilogram}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                      
                      // Total de ce preset
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.lightBlue[300]!, width: 1), // Bordure bleu ciel pour le total preset
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1: Total Poids
                            Text(
                              '${AppLocalizations.of(context)!.totalPreset} ${AppLocalizations.of(context)!.weight}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ligne 2: Projet + résultat
                            Text(
                              '${preset.name} : ${totalPreset.toStringAsFixed(2)} ${AppLocalizations.of(context)!.unitKilogram}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Total global du projet (tout en bas)
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1), // Bordure blanche pour le total projet
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1: Total Puissance
                  Text(
                    '${AppLocalizations.of(context)!.totalProject} ${AppLocalizations.of(context)!.weight}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2: Nom Projet + calcul du total en kW
                  Text(
                    '${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName} : ${totalProjet.toStringAsFixed(2)} ${AppLocalizations.of(context)!.unitKilogram}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Commentaire utilisateur (au-dessus des boutons)
            if (_getCommentForTab('weight_tab').isNotEmpty) ...[
              const SizedBox(height: 20),
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
                      _getCommentForTab('weight_tab'),
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
            
            // Cadre des fichiers importés (PDF et photos)
            Consumer(
              builder: (context, ref, child) {
                final importedFiles = ref.watch(importedFilesProvider);
                if (importedFiles.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128).withOpacity(0.3),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.folder_open,
                                color: Colors.white.withOpacity(0.8),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Fichiers importés (${importedFiles.length})',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.9),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ...(importedFiles.map((fileName) {
                            final isPdf = fileName.toLowerCase().endsWith('.pdf');
                            final isImage = fileName.toLowerCase().endsWith('.jpg') || 
                                           fileName.toLowerCase().endsWith('.jpeg') || 
                                           fileName.toLowerCase().endsWith('.png');
                            
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.white.withOpacity(0.2),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    isPdf ? Icons.picture_as_pdf : 
                                    isImage ? Icons.image : Icons.insert_drive_file,
                                    color: isPdf ? Colors.red.withOpacity(0.8) : 
                                           isImage ? Colors.blue.withOpacity(0.8) : 
                                           Colors.grey.withOpacity(0.8),
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      fileName,
                                      style: TextStyle(
                                        color: Colors.white.withOpacity(0.9),
                                        fontSize: 12,
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => ref.read(importedFilesProvider.notifier).removeFile(fileName),
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.withOpacity(0.8),
                                      size: 18,
                                    ),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(
                                      minWidth: 24,
                                      minHeight: 24,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList()),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Boutons d'action
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton Commentaire (icône uniquement)
                ActionButton.comment(
                  onPressed: () => _showCommentDialog('weight_tab', 'Poids'),
                  iconSize: 28,
                ),
                const SizedBox(width: 20),
                // Bouton Export (rotated)
                Transform.rotate(
                  angle: 3.14159, // 180° en radians
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                    ),
                    child: ExportWidget(
                      title: '${AppLocalizations.of(context)!.defaultProjectName} ${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : ""}',
                      content: 'Résumé complet du projet avec tous les presets et articles',
                      presetName: ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName,
                      exportDate: DateTime.now(),
                      projectType: 'weight',
                      projectSummary: {
                        'totalItems': totalItems.toString(),
                        'totalExports': totalExports.toString(),
                        'presetCount': presets.length.toString(),
                        'totalWeight': totalProjet.toStringAsFixed(2),
                      },
                      projectData: presets.map((preset) {
                        double presetWeight = 0;
                        int presetItemCount = 0;
                        
                        for (var item in preset.items) {
                          if (item.item.categorie != 'Export') {
                            presetWeight += (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity;
                            presetItemCount += item.quantity;
                          }
                        }
                        
                        return {
                          'presetName': preset.name,
                          'totalWeight': presetWeight.toStringAsFixed(2),
                          'itemCount': presetItemCount.toString(),
                        };
                      }).toList(),
                      fileName: 'poids_projet_${DateTime.now().millisecondsSinceEpoch}',
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }

  void _showPresetItemQuantityDialog(CartItem item, Preset preset) {
    int quantity = item.quantity;
    final TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A1128),
              title: Text(
                'Modifier la quantité',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.item.name} (${item.item.marque})',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
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
                        color: Colors.white,
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
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onChanged: (value) {
                            final newQuantity = int.tryParse(value) ?? 1;
                            if (newQuantity > 0) {
                              setState(() {
                                quantity = newQuantity;
                              });
                            }
                          },
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
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (quantity != item.quantity) {
                      // Mettre à jour le preset
                      final updatedItems = preset.items.map((i) {
                        if (i.item.id == item.item.id) {
                          return i.copyWith(quantity: quantity);
                        }
                        return i;
                      }).toList();
                      
                      final updatedPreset = preset.copyWith(items: updatedItems);
                      await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                      
                      // Fermer le dialog et laisser le provider notifier le changement
                      if (context.mounted) {
                        Navigator.pop(context);
                      }
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Confirmer'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        customIcon: Image.asset('assets/structureicon.png',
            width: 28, height: 28, color: Colors.white),
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
                  decoration: const BoxDecoration(),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: TabBar(
                    controller: _tabController,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, size: 18),
                            SizedBox(width: 6),
                            Text(loc.structurePage_chargesTab),
                          ],
                        ),
                      ),
                      Tab(text: loc.structurePage_projectWeightTab),
                    ],
                  ),
                ),
                // Widget preset sous les titres des onglets
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: const PresetWidget(),
                ),
                // Contenu des onglets avec marge de 10px
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 10),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildLoadCalculationTab(),
                        _buildProjectTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 2),
    );
  }

  // Méthodes de gestion des commentaires (liées à la page calcul projet)
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('calcul_projet_comments');
      if (commentsJson != null) {
        setState(() {
          _comments = Map<String, String>.from(json.decode(commentsJson));
        });
      }
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calcul_projet_comments', json.encode(_comments));
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
    }
  }

  String _getCommentForTab(String tabKey) {
    if (tabKey == 'structure_tab') {
      // Pour l'onglet structure, utiliser la clé unique du résultat
      return _comments[_currentStructureResult] ?? '';
    } else {
      // Pour les autres onglets, utiliser le système normal
      final projectId = ref.read(projectProvider).selectedProject?.id ?? 'default';
      final commentKey = '${projectId}_$tabKey';
      return _comments[commentKey] ?? '';
    }
  }

  String _generateStructureResultKey() {
    // Générer une clé unique basée sur les paramètres du calcul
    return 'structure_${selectedStructure}_${distance.toStringAsFixed(1)}_${selectedCharge}_${chargeMaximale.toStringAsFixed(1)}';
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
            style: const TextStyle(color: Colors.white, fontSize: 10),
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
              child: const Text(
                'Annuler',
                style: TextStyle(color: Colors.white),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                String commentKey;
                
                if (tabKey == 'structure_tab') {
                  // Pour l'onglet structure, utiliser la clé unique du résultat
                  commentKey = _currentStructureResult;
                } else {
                  // Pour les autres onglets, utiliser le système normal
                  final projectId = ref.read(projectProvider).selectedProject?.id ?? 'default';
                  commentKey = '${projectId}_$tabKey';
                }
                
                _comments[commentKey] = comment;
                await _saveComments();
                if (mounted) {
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }
}
