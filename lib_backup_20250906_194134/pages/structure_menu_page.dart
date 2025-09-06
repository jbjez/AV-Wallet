// lib/pages/structure_menu_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../data/asd_data.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../providers/catalogue_provider.dart';

import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';

class StructureMenuPage extends ConsumerStatefulWidget {
  const StructureMenuPage({super.key});

  @override
  ConsumerState<StructureMenuPage> createState() => _StructureMenuPageState();
}

class _StructureMenuPageState extends ConsumerState<StructureMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String selectedStructure = 'H30V';
  double distance = 6;
  String selectedCharge = 'Charge répartie uniformément';
  double additionalLoad = 0;
  bool showResult = false;
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  bool showSearchResults = false;

  final Map<String, double> coeffCharge = {
    'Charge répartie uniformément': 1.0,
    '1 point d\'accroche au centre': 1.5,
    '2 points d\'accroche aux extrémités': 1.2,
    '3 points d\'accroche': 1.1,
    '4 points d\'accroche': 1.05,
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
                    'Modifier',
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
  }

  @override
  void dispose() {
    _tabController.dispose();
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
      selectedCharge == 'Charge répartie uniformément' ? '/m' : '/pt';

  void _calculateLoad() {
    setState(() {
      showResult = true;
    });
  }

  void _resetCalculation() {
    setState(() {
      showResult = false;
    });
  }

  Widget _buildLoadCalculationTab() {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
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
              Text(loc.selectStructure,
                  style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 4),
              DropdownButton<String>(
                value: selectedStructure,
                dropdownColor: Colors.blueGrey[900],
                style: Theme.of(context).textTheme.bodyMedium,
                isExpanded: true,
                items: asdStructures
                    .map((s) => DropdownMenuItem<String>(
                          value: s.reference,
                          child: Text(s.reference,
                              style: Theme.of(context).textTheme.bodyMedium),
                        ))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedStructure = v!;
                    showResult = false;
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(
                'Distance : ${distance.toStringAsFixed(1)} m',
                style: Theme.of(context).textTheme.bodyMedium
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
                  });
                },
              ),
              const SizedBox(height: 12),
              Text(loc.structurePage_selectCharge,
                  style: Theme.of(context).textTheme.bodyMedium),
              DropdownButton<String>(
                value: selectedCharge,
                dropdownColor: Colors.blueGrey[900],
                style: Theme.of(context).textTheme.bodyMedium,
                isExpanded: true,
                items: chargeOptions
                    .map((c) => DropdownMenuItem<String>(
                        value: c,
                        child: Text(c,
                            style: Theme.of(context).textTheme.bodyMedium)))
                    .toList(),
                onChanged: (v) {
                  setState(() {
                    selectedCharge = v!;
                    showResult = false;
                  });
                },
              ),
              const SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: showResult ? _resetCalculation : _calculateLoad,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueGrey[700],
                    padding: const EdgeInsets.all(12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Icon(
                    showResult ? Icons.refresh : Icons.calculate,
                    color: Colors.white,
                    size: 24,
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
                        Text(
                          'Charge maximale : ${chargeMaximale.toStringAsFixed(1)} kg$unitCharge',
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Poids de la structure : ${poidsStructure.toStringAsFixed(1)} kg/m',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Flèche maximale : ${flecheMaximale.toStringAsFixed(0)} mm',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Ratio de flèche : 1/${(distance * 1000 / flecheMaximale).round()}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
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
    final preset = ref.read(presetProvider.notifier).activePreset;

    if (preset == null) {
      return Center(
        child: Text(
          'Aucun preset sélectionné',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final items = preset.items;

    final grouped = <String, List<CatalogueItem>>{};
    final totalsPerCategory = <String, double>{};
    double totalPreset = 0;

    // 🔹 Calcule pour le preset sélectionné
    for (var item in items) {
      final cat = item.item.categorie;
      grouped.putIfAbsent(cat, () => []).add(item.item);

      final value = item.item.poids.contains('kg')
          ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
          : 0;

      totalsPerCategory.update(
        cat,
        (existing) => existing + value,
        ifAbsent: () => value.toDouble(),
      );

      totalPreset += value;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
              hintText: 'Rechercher un produit...',
              hintStyle: Theme.of(context).textTheme.bodyMedium!.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.7)
                      : Colors.black.withOpacity(0.7)),
              prefixIcon: Icon(Icons.search,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                  size: 20),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white.withOpacity(0.5)
                      : Colors.black.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            onChanged: _handleSearch,
          ),
          if (showSearchResults && searchResults.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? const Color(0xFF0A1128).withOpacity(0.9)
                    : Colors.white.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.white
                        : Colors.black,
                    width: 1),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(8),
                itemCount: searchResults.length,
                itemBuilder: (context, index) {
                  final item = searchResults[index];
                  return InkWell(
                    onTap: () {
                      _showQuantityDialog(item, 1);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 8, horizontal: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${item.marque} - ${item.produit}',
                              style: Theme.of(context).textTheme.bodyMedium),
                          Text(
                            item.sousCategorie,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? Colors.white.withOpacity(0.7)
                                        : Colors.black.withOpacity(0.7)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          const SizedBox(height: 16),
          Text(
            preset.name,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize:
                      Theme.of(context).textTheme.titleLarge!.fontSize! - 3,
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 16),
          ...grouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            final total = totalsPerCategory[category] ?? 0;

            // Filtrer les items en fonction de la recherche
            final filteredItems = searchQuery.length >= 3
                ? items.where((item) =>
                    item.produit
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()) ||
                    item.marque
                        .toLowerCase()
                        .contains(searchQuery.toLowerCase()))
                : items;

            if (filteredItems.isEmpty) return const SizedBox();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontSize:
                            Theme.of(context).textTheme.titleLarge!.fontSize! -
                                3,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                ...filteredItems.map((item) {
                  final value = item.poids.contains('kg')
                      ? double.tryParse(
                              item.poids.replaceAll('kg', '').trim()) ??
                          0
                      : 0;

                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.produit} - ${item.marque}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                final preset = ref
                                    .read(presetProvider.notifier)
                                    .activePreset;
                                if (preset != null) {
                                  final cartItem = preset.items.firstWhere(
                                    (cartItem) => cartItem.item.id == item.id,
                                    orElse: () => CartItem(
                                        item: item, quantity: 0),
                                  );
                                  if (cartItem.quantity > 1) {
                                    cartItem.quantity--;
                                    ref
                                        .read(presetProvider.notifier)
                                        .updatePreset(preset);
                                    setState(() {});
                                  }
                                }
                              },
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            GestureDetector(
                              onTap: () {
                                final preset = ref
                                    .read(presetProvider.notifier)
                                    .activePreset;
                                if (preset != null) {
                                  final cartItem = preset.items.firstWhere(
                                    (cartItem) => cartItem.item.id == item.id,
                                    orElse: () => CartItem(
                                        item: item, quantity: 0),
                                  );
                                  _showQuantityDialog(item, cartItem.quantity);
                                }
                              },
                              child: Container(
                                width: 32,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 4),
                                child: Text(
                                  preset.items
                                      .firstWhere(
                                        (cartItem) =>
                                            cartItem.item.id == item.id,
                                        orElse: () => CartItem(
                                            item: item, quantity: 0),
                                      )
                                      .quantity
                                      .toString(),
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                final preset = ref
                                    .read(presetProvider.notifier)
                                    .activePreset;
                                if (preset != null) {
                                  final cartItem = preset.items.firstWhere(
                                    (cartItem) => cartItem.item.id == item.id,
                                    orElse: () => CartItem(
                                        item: item, quantity: 0),
                                  );
                                  cartItem.quantity++;
                                  ref
                                      .read(presetProvider.notifier)
                                      .updatePreset(preset);
                                  setState(() {});
                                }
                              },
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              onPressed: () {
                                final preset = ref
                                    .read(presetProvider.notifier)
                                    .activePreset;
                                if (preset != null) {
                                  preset.items.removeWhere((cartItem) =>
                                      cartItem.item.id == item.id);
                                  ref
                                      .read(presetProvider.notifier)
                                      .updatePreset(preset);
                                  setState(() {});
                                }
                              },
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                Padding(
                  padding: const EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Total poids ${category.toLowerCase()} : ${total.toStringAsFixed(2)} kg',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const Divider(color: Colors.white30),
          const SizedBox(height: 8),
          Text(
            'Total poids preset : ${totalPreset.toStringAsFixed(2)} kg',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize:
                      Theme.of(context).textTheme.titleLarge!.fontSize! - 3,
                  fontWeight: FontWeight.bold,
                ),
          ),
        ],
      ),
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
                Container(
                  decoration: const BoxDecoration(),
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.calculate, size: 18),
                            SizedBox(width: 6),
                            Text('Charges'),
                          ],
                        ),
                      ),
                      Tab(text: 'Projet Poids'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoadCalculationTab(),
                      _buildProjectTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
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
}
