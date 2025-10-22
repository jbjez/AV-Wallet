// lib/pages/structure_menu_page.dart
import 'package:flutter/material.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../data/asd_data.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../widgets/preset_widget.dart';
import '../utils/consumption_parser.dart';
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
import '../theme/colors.dart';

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

  // Données constructeur SC300, SC390, SC500, E20D (Charges préconisées 1/300)
  final Map<String, Map<int, Map<String, double>>> structureData = {
    'SC300': {
      1:  {'Q': 1543, 'P1': 1543, 'P2': 772, 'P3': 514, 'P4': 386, 'SW': 7,   'deflection': 3},
      2:  {'Q': 768,  'P1': 1537, 'P2': 768, 'P3': 512, 'P4': 384, 'SW': 13,  'deflection': 7},
      3:  {'Q': 510,  'P1': 1530, 'P2': 765, 'P3': 510, 'P4': 383, 'SW': 20,  'deflection': 10},
      4:  {'Q': 381,  'P1': 1169, 'P2': 762, 'P3': 508, 'P4': 381, 'SW': 26,  'deflection': 13},
      5:  {'Q': 303,  'P1': 924,  'P2': 701, 'P3': 467, 'P4': 379, 'SW': 33,  'deflection': 17},
      6:  {'Q': 252,  'P1': 758,  'P2': 578, 'P3': 385, 'P4': 322, 'SW': 39,  'deflection': 20},
      7:  {'Q': 177,  'P1': 637,  'P2': 449, 'P3': 323, 'P4': 254, 'SW': 46,  'deflection': 23},
      8:  {'Q': 117,  'P1': 546,  'P2': 335, 'P3': 242, 'P4': 190, 'SW': 52,  'deflection': 27},
      9:  {'Q': 80,   'P1': 428,  'P2': 256, 'P3': 185, 'P4': 146, 'SW': 59,  'deflection': 30},
      10: {'Q': 56,   'P1': 329,  'P2': 199, 'P3': 144, 'P4': 114, 'SW': 65,  'deflection': 33},
      11: {'Q': 41,   'P1': 254,  'P2': 155, 'P3': 113, 'P4': 90,  'SW': 72,  'deflection': 37},
      12: {'Q': 30,   'P1': 195,  'P2': 121, 'P3': 89,  'P4': 71,  'SW': 78,  'deflection': 40},
      13: {'Q': 22,   'P1': 148,  'P2': 94,  'P3': 70,  'P4': 56,  'SW': 85,  'deflection': 43},
      14: {'Q': 16,   'P1': 110,  'P2': 72,  'P3': 54,  'P4': 44,  'SW': 91,  'deflection': 47},
      15: {'Q': 12,   'P1': 77,   'P2': 54,  'P3': 41,  'P4': 33,  'SW': 98,  'deflection': 50},
      16: {'Q': 9,    'P1': 50,   'P2': 38,  'P3': 30,  'P4': 25,  'SW': 104, 'deflection': 53},
      17: {'Q': 6,    'P1': 26,   'P2': 25,  'P3': 21,  'P4': 17,  'SW': 111, 'deflection': 57},
      18: {'Q': 4,    'P1': 5,    'P2': 13,  'P3': 12,  'P4': 11,  'SW': 117, 'deflection': 60},
      19: {'Q': 3,    'P1': 0,    'P2': 2,   'P3': 5,   'P4': 5,   'SW': 124, 'deflection': 63},
      20: {'Q': 1,    'P1': 0,    'P2': 0,   'P3': 0,   'P4': 0,   'SW': 130, 'deflection': 67},
    },
    'SC390': {
      1:  {'Q': 2441, 'P1': 2441, 'P2': 1221, 'P3': 814, 'P4': 610, 'SW': 8,   'deflection': 3},
      2:  {'Q': 1217, 'P1': 2433, 'P2': 1217, 'P3': 811, 'P4': 608, 'SW': 15,  'deflection': 7},
      3:  {'Q': 809,  'P1': 2237, 'P2': 1213, 'P3': 809, 'P4': 606, 'SW': 23,  'deflection': 10},
      4:  {'Q': 604,  'P1': 1664, 'P2': 1209, 'P3': 806, 'P4': 604, 'SW': 31,  'deflection': 13},
      5:  {'Q': 482,  'P1': 1318, 'P2': 998,  'P3': 665, 'P4': 555, 'SW': 39,  'deflection': 17},
      6:  {'Q': 369,  'P1': 1084, 'P2': 824,  'P3': 550, 'P4': 459, 'SW': 46,  'deflection': 20},
      7:  {'Q': 269,  'P1': 915,  'P2': 699,  'P3': 466, 'P4': 390, 'SW': 54,  'deflection': 23},
      8:  {'Q': 204,  'P1': 786,  'P2': 605,  'P3': 403, 'P4': 338, 'SW': 62,  'deflection': 27},
      9:  {'Q': 160,  'P1': 684,  'P2': 530,  'P3': 354, 'P4': 297, 'SW': 69,  'deflection': 30},
      10: {'Q': 118,  'P1': 601,  'P2': 422,  'P3': 305, 'P4': 240, 'SW': 77,  'deflection': 33},
      11: {'Q': 87,   'P1': 532,  'P2': 338,  'P3': 245, 'P4': 193, 'SW': 85,  'deflection': 37},
      12: {'Q': 65,   'P1': 452,  'P2': 274,  'P3': 199, 'P4': 157, 'SW': 92,  'deflection': 40},
      13: {'Q': 49,   'P1': 364,  'P2': 222,  'P3': 162, 'P4': 128, 'SW': 100, 'deflection': 43},
      14: {'Q': 38,   'P1': 292,  'P2': 181,  'P3': 133, 'P4': 105, 'SW': 108, 'deflection': 47},
      15: {'Q': 29,   'P1': 233,  'P2': 147,  'P3': 108, 'P4': 86,  'SW': 116, 'deflection': 50},
      16: {'Q': 23,   'P1': 183,  'P2': 118,  'P3': 88,  'P4': 71,  'SW': 123, 'deflection': 53},
      17: {'Q': 18,   'P1': 141,  'P2': 94,   'P3': 71,  'P4': 57,  'SW': 131, 'deflection': 57},
      18: {'Q': 14,   'P1': 104,  'P2': 73,   'P3': 56,  'P4': 45,  'SW': 139, 'deflection': 60},
      19: {'Q': 11,   'P1': 70,   'P2': 55,   'P3': 43,  'P4': 35,  'SW': 147, 'deflection': 63},
      20: {'Q': 8,    'P1': 40,   'P2': 40,   'P3': 32,  'P4': 26,  'SW': 154, 'deflection': 67},
    },
    'SC500': {
      1:  {'Q': 4000, 'P1': 4000, 'P2': 2000, 'P3': 1333, 'P4': 1000, 'SW': 10, 'deflection': 3},
      2:  {'Q': 2000, 'P1': 4000, 'P2': 2000, 'P3': 1333, 'P4': 1000, 'SW': 20, 'deflection': 7},
      3:  {'Q': 1333, 'P1': 4000, 'P2': 2000, 'P3': 1333, 'P4': 1000, 'SW': 30, 'deflection': 10},
      4:  {'Q': 1000, 'P1': 3000, 'P2': 2000, 'P3': 1333, 'P4': 1000, 'SW': 40, 'deflection': 13},
      5:  {'Q': 800,  'P1': 2400, 'P2': 1800, 'P3': 1200, 'P4': 1000, 'SW': 50, 'deflection': 17},
      6:  {'Q': 667,  'P1': 2000, 'P2': 1500, 'P3': 1000, 'P4': 833,  'SW': 60, 'deflection': 20},
      7:  {'Q': 571,  'P1': 1714, 'P2': 1286, 'P3': 857,  'P4': 714,  'SW': 70, 'deflection': 23},
      8:  {'Q': 500,  'P1': 1500, 'P2': 1125, 'P3': 750,  'P4': 625,  'SW': 80, 'deflection': 27},
      9:  {'Q': 444,  'P1': 1333, 'P2': 1000, 'P3': 667,  'P4': 556,  'SW': 90, 'deflection': 30},
      10: {'Q': 400,  'P1': 1200, 'P2': 900,  'P3': 600,  'P4': 500,  'SW': 100,'deflection': 33},
      11: {'Q': 364,  'P1': 1091, 'P2': 818,  'P3': 545,  'P4': 455,  'SW': 110,'deflection': 37},
      12: {'Q': 333,  'P1': 1000, 'P2': 750,  'P3': 500,  'P4': 417,  'SW': 120,'deflection': 40},
      13: {'Q': 308,  'P1': 923,  'P2': 692,  'P3': 462,  'P4': 385,  'SW': 130,'deflection': 43},
      14: {'Q': 286,  'P1': 857,  'P2': 643,  'P3': 429,  'P4': 357,  'SW': 140,'deflection': 47},
      15: {'Q': 267,  'P1': 800,  'P2': 600,  'P3': 400,  'P4': 333,  'SW': 150,'deflection': 50},
      16: {'Q': 250,  'P1': 750,  'P2': 563,  'P3': 375,  'P4': 313,  'SW': 160,'deflection': 53},
      17: {'Q': 235,  'P1': 706,  'P2': 529,  'P3': 353,  'P4': 294,  'SW': 170,'deflection': 57},
      18: {'Q': 222,  'P1': 667,  'P2': 500,  'P3': 333,  'P4': 278,  'SW': 180,'deflection': 60},
      19: {'Q': 211,  'P1': 632,  'P2': 474,  'P3': 316,  'P4': 263,  'SW': 190,'deflection': 63},
      20: {'Q': 200,  'P1': 600,  'P2': 450,  'P3': 300,  'P4': 250,  'SW': 200,'deflection': 67},
    },
    'E20D': {
      1:  {'Q': 2000, 'P1': 2000, 'P2': 1000, 'P3': 667,  'P4': 500,  'SW': 5,  'deflection': 3},
      2:  {'Q': 1000, 'P1': 2000, 'P2': 1000, 'P3': 667,  'P4': 500,  'SW': 10, 'deflection': 7},
      3:  {'Q': 667,  'P1': 2000, 'P2': 1000, 'P3': 667,  'P4': 500,  'SW': 15, 'deflection': 10},
      4:  {'Q': 500,  'P1': 1500, 'P2': 1000, 'P3': 667,  'P4': 500,  'SW': 20, 'deflection': 13},
      5:  {'Q': 400,  'P1': 1200, 'P2': 900,  'P3': 600,  'P4': 500,  'SW': 25, 'deflection': 17},
      6:  {'Q': 333,  'P1': 1000, 'P2': 750,  'P3': 500,  'P4': 417,  'SW': 30, 'deflection': 20},
      7:  {'Q': 286,  'P1': 857,  'P2': 643,  'P3': 429,  'P4': 357,  'SW': 35, 'deflection': 23},
      8:  {'Q': 250,  'P1': 750,  'P2': 563,  'P3': 375,  'P4': 313,  'SW': 40, 'deflection': 27},
      9:  {'Q': 222,  'P1': 667,  'P2': 500,  'P3': 333,  'P4': 278,  'SW': 45, 'deflection': 30},
      10: {'Q': 200,  'P1': 600,  'P2': 450,  'P3': 300,  'P4': 250,  'SW': 50, 'deflection': 33},
      11: {'Q': 182,  'P1': 545,  'P2': 409,  'P3': 273,  'P4': 227,  'SW': 55, 'deflection': 37},
      12: {'Q': 167,  'P1': 500,  'P2': 375,  'P3': 250,  'P4': 208,  'SW': 60, 'deflection': 40},
      13: {'Q': 154,  'P1': 462,  'P2': 346,  'P3': 231,  'P4': 192,  'SW': 65, 'deflection': 43},
      14: {'Q': 143,  'P1': 429,  'P2': 321,  'P3': 214,  'P4': 179,  'SW': 70, 'deflection': 47},
      15: {'Q': 133,  'P1': 400,  'P2': 300,  'P3': 200,  'P4': 167,  'SW': 75, 'deflection': 50},
      16: {'Q': 125,  'P1': 375,  'P2': 281,  'P3': 188,  'P4': 156,  'SW': 80, 'deflection': 53},
      17: {'Q': 118,  'P1': 353,  'P2': 265,  'P3': 176,  'P4': 147,  'SW': 85, 'deflection': 57},
      18: {'Q': 111,  'P1': 333,  'P2': 250,  'P3': 167,  'P4': 139,  'SW': 90, 'deflection': 60},
      19: {'Q': 105,  'P1': 316,  'P2': 237,  'P3': 158,  'P4': 132,  'SW': 95, 'deflection': 63},
      20: {'Q': 100,  'P1': 300,  'P2': 225,  'P3': 150,  'P4': 125,  'SW': 100,'deflection': 67},
    },
  };
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
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.5),
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
                      border: Border.all(color: Colors.blueGrey[900]!, width: 1),
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
                            // Bouton Export
                            Transform.rotate(
                              angle: 0, // Pas de rotation - flèche vers le haut naturellement
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blueGrey[900], // Identique au bouton comment
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ExportWidget(
                                  title: 'Charge 1',
                                  content: _buildStructureCalculationContent(),
                                  presetName: 'Structure $selectedStructure',
                                  exportDate: DateTime.now(),
                                  projectType: 'structure',
                                  backgroundColor: Colors.blueGrey[900], // Identique au bouton comment
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
            ? ConsumptionParser.parseConsumption(item.item.conso) * item.quantity
            : ConsumptionParser.parseWeight(item.item.poids) * item.quantity;

        totalsPerCategory.update(
          cat,
          (existing) => existing + value,
          ifAbsent: () => value.toDouble(),
        );

        totalProjet += value;
        
        // Compter les exports
        if (item.item.categorie == 'Export') {
          totalExports += item.quantity.toInt();
        } else {
          // Compter seulement les vrais articles (pas les exports)
          totalItems += item.quantity.toInt();
        }
      }
    }
    
    // Ajouter 10% de câblage pour le mode poids au total global
    totalProjet = totalProjet * 1.1; // +10% de câblage

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
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
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName,
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
              
              // Ajouter 10% de câblage pour le mode poids
              totalPreset = totalPreset * 1.1; // +10% de câblage
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  border: Border.all(
                    color: presetIndex % 2 == 0 ? Colors.blue : Colors.white, // Alternance bleu/blanc
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(12),
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
                            // Ligne 1: Total Poids avec câblage
                            Text(
                              'Total ${preset.name} ${AppLocalizations.of(context)!.weight} ${AppLocalizations.of(context)!.cabling_addition}',
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
                border: Border.all(color: const Color(0xFF2C3E50), width: 1), // Bordure bleu-gris foncé
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1: Total Poids
                  Text(
                    'Total ${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName} ${AppLocalizations.of(context)!.weight}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2: Nom Projet + calcul du total en kg
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
                // Bouton Export
                Transform.rotate(
                  angle: 0, // Pas de rotation - flèche vers le haut naturellement
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900], // Identique au bouton comment
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ExportWidget(
                      title: '${AppLocalizations.of(context)!.defaultProjectName} ${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : ""}',
                      content: 'Résumé complet du projet avec tous les presets et articles',
                      presetName: ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName,
                      exportDate: DateTime.now(),
                      projectType: 'weight',
                      backgroundColor: Colors.blueGrey[900], // Identique au bouton comment
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
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Tailles fixes pour iPhone SE et autres appareils
    final iconSize = 14.0; // 14px pour les icônes
    final fontSize = 12.0; // 12px pour le texte

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
            child: Padding(
              padding: const EdgeInsets.only(top: 15), // Descendre toute la page de 15 pixels (remonté de 5px)
              child: Column(
              children: [
                Container(
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
                  ),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                  padding: const EdgeInsets.symmetric(vertical: 0),
         child: TabBar(
           controller: _tabController,
           dividerColor: Colors.transparent, // Supprime la ligne de séparation
           indicatorColor: Colors.transparent, // Supprime l'indicateur bleu
           labelColor: Theme.of(context).brightness == Brightness.dark
               ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
               : const Color(0xFF0A1128),  // Bleu nuit en mode jour
           unselectedLabelColor: Colors.white.withOpacity(0.7), // Blanc transparent pour les onglets non sélectionnés
           labelStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
           unselectedLabelStyle: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
           tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, size: iconSize),
                            SizedBox(width: 6),
                            Text(loc.structurePage_chargesTab),
                          ],
                        ),
                      ),
                      Tab(text: loc.structurePage_projectWeightTab),
                    ],
                  ),
                ),
                const SizedBox(height: 6),
                // Widget preset sous les titres des onglets avec cadre bleu-gris foncé
                const PresetWidget(),
                const SizedBox(height: 6),
                // Contenu des onglets avec marge de 10px
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
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
      final projectId = ref.read(projectProvider).selectedProject.id ?? 'default';
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
                  final projectId = ref.read(projectProvider).selectedProject.id ?? 'default';
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

  // Méthode pour générer le contenu exact des calculs de structure
  String _buildStructureCalculationContent() {
    // Map pour les traductions des types de charge
    final loc = AppLocalizations.of(context)!;
    final chargeTranslations = {
      'structurePage_chargeRepartie': loc.structurePage_chargeRepartie,
      'structurePage_pointAccrocheCentre': loc.structurePage_pointAccrocheCentre,
      'structurePage_pointsAccrocheExtremites': loc.structurePage_pointsAccrocheExtremites,
      'structurePage_3pointsAccroche': loc.structurePage_3pointsAccroche,
      'structurePage_4pointsAccroche': loc.structurePage_4pointsAccroche,
    };
    
    // Obtenir les données pour la structure et la portée sélectionnées
    final span = distance.round();
    final data = structureData[selectedStructure]?[span] ?? {};
    
    if (data.isEmpty) return 'Aucune donnée disponible';
    
    // Calculer les valeurs
    final poidsStructure = data['SW'] ?? 0;
    final flecheMaximale = data['deflection'] ?? 0;
    final unitCharge = selectedCharge == 'structurePage_chargeRepartie' ? ' kg/m' : ' kg/pt';
    
    double chargeMaximale = 0;
    switch (selectedCharge) {
      case 'structurePage_pointAccrocheCentre':
        chargeMaximale = data['P1'] ?? 0;
        break;
      case 'structurePage_pointsAccrocheExtremites':
        chargeMaximale = data['P2'] ?? 0;
        break;
      case 'structurePage_chargeRepartie':
        chargeMaximale = data['Q'] ?? 0;
        break;
      default:
        chargeMaximale = 0;
    }
    
    return '''
CALCUL DE CHARGE STRUCTURE
==========================

PARAMÈTRES:
-----------
Structure: $selectedStructure
Portée: ${distance.toStringAsFixed(1)} m
Type de charge: ${chargeTranslations[selectedCharge] ?? selectedCharge}

RÉSULTATS CALCULÉS:
-------------------
Charge maximale: ${chargeMaximale.toStringAsFixed(1)}$unitCharge
Poids structure: ${poidsStructure.toStringAsFixed(1)} kg/m
Flèche maximale: ${flecheMaximale.toStringAsFixed(0)} mm
Ratio de flèche: 1/${(distance * 1000 / flecheMaximale).round()}

DONNÉES CONSTRUCTEUR:
--------------------
Charge répartie (Q): ${data['Q']?.toStringAsFixed(0) ?? 'N/A'} kg/m
1 point d'accroche (P1): ${data['P1']?.toStringAsFixed(0) ?? 'N/A'} kg
2 points d'accroche (P2): ${data['P2']?.toStringAsFixed(0) ?? 'N/A'} kg/pt
3 points d'accroche (P3): ${data['P3']?.toStringAsFixed(0) ?? 'N/A'} kg/pt
4 points d'accroche (P4): ${data['P4']?.toStringAsFixed(0) ?? 'N/A'} kg/pt
Poids propre (SW): ${data['SW']?.toStringAsFixed(0) ?? 'N/A'} kg/m
Flèche réelle: ${data['deflection']?.toStringAsFixed(0) ?? 'N/A'} mm

RECOMMANDATIONS:
---------------
• Ratio de flèche recommandé: 1/300e
• Vérifier la compatibilité des points d'accroche
• Considérer les charges dynamiques supplémentaires
• Respecter les marges de sécurité constructeur

Généré le: ${DateTime.now().toString().split('.')[0]}
''';
  }
}
