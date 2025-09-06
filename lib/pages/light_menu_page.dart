import 'package:flutter/material.dart';
import 'dart:math';
import '../widgets/custom_app_bar.dart';
import 'catalogue_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import 'ar_measure_page.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/catalogue_item.dart';
import '../models/cart_data.dart';
import '../models/cart_item.dart';
import '../widgets/preset_widget.dart';
import '../models/preset.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../providers/catalogue_provider.dart';
import '../theme/app_theme.dart';

class Driver {
  final int voies;
  final int ampereParVoie;

  const Driver({required this.voies, required this.ampereParVoie});
}

class LightMenuPage extends ConsumerStatefulWidget {
  const LightMenuPage({super.key});

  @override
  ConsumerState<LightMenuPage> createState() => _LightMenuPageState();
}

class _LightMenuPageState extends ConsumerState<LightMenuPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _dmxScrollController = ScrollController();
  double angle = 35;
  double height = 10;
  double distance = 20;
  double ampereParVoie = 3;
  int nbVoies = 5;
  int tension = 24;
  String selectedDriver = 'S04x5A';
  double longueurLed = 5;
  String searchQuery = '';
  String? selectedProduct;
  String? selectedBrand;
  List<CatalogueItem> selectedFixtures = [];
  Map<CatalogueItem, int> fixtureQuantities = {};
  String? beamCalculationResult;
  String? driverCalculationResult;
  String? dmxCalculationResult;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;

  final Map<String, Driver> drivers = {
    'S04x5A': const Driver(voies: 4, ampereParVoie: 5),
    'S04x10A': const Driver(voies: 4, ampereParVoie: 10),
    'S05x6A': const Driver(voies: 5, ampereParVoie: 6),
    'S32x3A': const Driver(voies: 32, ampereParVoie: 3),
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _initializeCatalogue();
  }

  Future<void> _initializeCatalogue() async {
    try {
      await ref.read(catalogueProvider.notifier).loadCatalogue();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _dmxScrollController.dispose();
    super.dispose();
  }

  List<String> get _uniqueBrands {
    return ref
        .watch(catalogueProvider)
        .where((item) => item.categorie == 'Lumière')
        .map((item) => item.marque)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _productsForSelectedBrand {
    if (selectedBrand == null) return [];
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Lumière' && item.marque == selectedBrand)
        .map((item) => item.produit)
        .toSet()
        .toList()
      ..sort();
  }

  List<CatalogueItem> get _filteredProducts {
    if (_searchController.text.isEmpty) return [];
    final query = _searchController.text.toLowerCase();
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Lumière' &&
            (item.produit.toLowerCase().contains(query) ||
                item.marque.toLowerCase().contains(query)))
        .toList()
      ..sort((a, b) => a.produit.compareTo(b.produit));
  }

  List<String> get _dmxUniqueBrands {
    return ref
        .watch(catalogueProvider)
        .where((item) => 
            item.categorie == 'Lumière' && 
            item.dmxMax != null && 
            item.dmxMax!.isNotEmpty)
        .map((item) => item.marque)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _dmxProductsForSelectedBrand {
    if (selectedBrand == null) return [];
    return ref
        .watch(catalogueProvider)
        .where((item) => 
            item.categorie == 'Lumière' && 
            item.marque == selectedBrand &&
            item.dmxMax != null &&
            item.dmxMax!.isNotEmpty)
        .map((item) => item.produit)
        .toSet()
        .toList()
      ..sort();
  }

  List<CatalogueItem> get _dmxFilteredProducts {
    if (_searchController.text.isEmpty) return [];
    final query = _searchController.text.toLowerCase();
    return ref
        .watch(catalogueProvider)
        .where((item) => 
            item.categorie == 'Lumière' &&
            item.dmxMax != null &&
            item.dmxMax!.isNotEmpty &&
            (item.produit.toLowerCase().contains(query) ||
             item.marque.toLowerCase().contains(query)))
        .toList()
      ..sort((a, b) => a.produit.compareTo(b.produit));
  }

  double get diameter {
    double rad = angle * pi / 180;
    double hypotenuse = sqrt(pow(height, 2) + pow(distance, 2));
    return 2 * (hypotenuse * tan(rad / 2));
  }

  void _navigateTo(Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showQuantityDialog(CatalogueItem fixture) {
    final TextEditingController quantityController = TextEditingController();
    final loc = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(fixture.produit,
            style: Theme.of(context).textTheme.bodyMedium),
        content: TextField(
          controller: quantityController,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: loc.lightPage_quantity,
            hintText: loc.lightPage_enterQuantity,
          ),
          style: Theme.of(context).textTheme.bodyMedium,
          onSubmitted: (value) {
            if (value.isNotEmpty) {
              setState(() {
                final quantity = int.parse(value);
                fixtureQuantities[fixture] = quantity;
                if (!selectedFixtures.contains(fixture)) {
                  selectedFixtures.add(fixture);
                }

                // Mettre à jour le preset actif
                if (ref.read(presetProvider.notifier).selectedPresetIndex >=
                    0) {
                  final preset = ref.read(presetProvider.notifier).state[
                      ref.read(presetProvider.notifier).selectedPresetIndex];
                  final existingIndex =
                      preset.items.indexWhere((i) => i.item.id == fixture.id);
                  if (existingIndex != -1) {
                    preset.items[existingIndex] = CartItem(
                        item: fixture,
                        quantity: fixtureQuantities[fixture] ?? 1);
                  } else {
                    preset.items.add(CartItem(
                        item: fixture,
                        quantity: fixtureQuantities[fixture] ?? 1));
                  }
                  ref.read(presetProvider.notifier).updatePreset(preset);
                }

                selectedProduct = null;
              });
              Navigator.pop(context);
            }
          },
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                selectedProduct = null;
              });
              Navigator.pop(context);
            },
            child: Text(loc.lightPage_cancel,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              final value = quantityController.text;
              if (value.isNotEmpty) {
                setState(() {
                  final quantity = int.parse(value);
                  fixtureQuantities[fixture] = quantity;
                  if (!selectedFixtures.contains(fixture)) {
                    selectedFixtures.add(fixture);
                  }

                  // Mettre à jour le preset actif
                  if (ref.read(presetProvider.notifier).selectedPresetIndex >=
                      0) {
                    final preset = ref.read(presetProvider.notifier).state[
                        ref.read(presetProvider.notifier).selectedPresetIndex];
                    final existingIndex =
                        preset.items.indexWhere((i) => i.item.id == fixture.id);
                    if (existingIndex != -1) {
                      preset.items[existingIndex] = CartItem(
                          item: fixture,
                          quantity: fixtureQuantities[fixture] ?? 1);
                    } else {
                      preset.items.add(CartItem(
                          item: fixture,
                          quantity: fixtureQuantities[fixture] ?? 1));
                    }
                    ref.read(presetProvider.notifier).updatePreset(preset);
                  }

                  selectedProduct = null;
                });
                Navigator.pop(context);
              }
            },
            child: Text(loc.lightPage_confirm,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _loadPreset(Preset preset) {
    setState(() {
      selectedFixtures.clear();
      fixtureQuantities.clear();
      searchQuery = '';

      // Charger les projecteurs du preset
      for (var presetItem in preset.items) {
        final fixture = ref.watch(catalogueProvider).firstWhere(
              (f) => f.id == presetItem.item.id,
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

        if (fixture.id.isNotEmpty) {
          selectedFixtures.add(fixture);
          fixtureQuantities[fixture] = 1;
        }
      }
    });
  }

  void _savePreset() {
    final loc = AppLocalizations.of(context)!;
    if (selectedFixtures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loc.lightPage_noFixturesSelected,
              style: Theme.of(context).textTheme.bodyMedium),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(loc.lightPage_savePreset,
            style: Theme.of(context).textTheme.bodyMedium),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: loc.lightPage_presetName,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.lightPage_cancel,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
          TextButton(
            onPressed: () {
              final preset = Preset(
                id: DateTime.now().toString(),
                name: searchQuery,
                description: '',
                items: selectedFixtures
                    .map((fixture) => CartItem(
                          item: fixture,
                          quantity: fixtureQuantities[fixture] ?? 1,
                        ))
                    .toList(),
              );
              final presetRef = ref;
              presetRef.read(presetProvider.notifier).addPreset(preset);
              Navigator.pop(context);
            },
            child: Text(loc.lightPage_save,
                style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }

  void _calculateBeam() {
    double rad = angle * pi / 180;
    double hypotenuse = sqrt(pow(height, 2) + pow(distance, 2));
    double diameter = 2 * (hypotenuse * tan(rad / 2));

    final loc = AppLocalizations.of(context)!;
    setState(() {
      beamCalculationResult = '${loc.lightPage_beamDiameter}: ${diameter.toStringAsFixed(2)} ${loc.lightPage_meters}';
    });
  }

  void _calculateDriver() {
    final loc = AppLocalizations.of(context)!;
    final driver = drivers[selectedDriver];
    if (driver == null) return;

    double totalAmpere = 0;
    for (var fixture in selectedFixtures) {
      final quantity = fixtureQuantities[fixture] ?? 0;
      final powerInWatts =
          double.tryParse(fixture.conso.replaceAll('W', '').trim()) ?? 0;
      totalAmpere += (powerInWatts / tension) * quantity;
    }

    int nbDrivers =
        (totalAmpere / (driver.voies * driver.ampereParVoie)).ceil();

    setState(() {
      driverCalculationResult = '${loc.lightPage_recommendedConfig}:\n'
          '$nbDrivers x $selectedDriver\n'
          '${loc.lightPage_total}: ${(nbDrivers * driver.voies * driver.ampereParVoie).toStringAsFixed(1)}A';
    });
  }

  void _calculateDMX() {
    final loc = AppLocalizations.of(context)!;
    Map<int, List<Map<String, dynamic>>> universes = {};
    int currentUniverse = 1;
    int remainingChannels = 512;

    List<Map<String, dynamic>> allFixtures = [];
    for (var fixture in selectedFixtures) {
      final channels = int.parse(fixture.dmxMax?.toString() ?? '0');
      final quantity = fixtureQuantities[fixture] ?? 0;
      for (int i = 0; i < quantity; i++) {
        allFixtures.add({
          'name': fixture.produit,
          'channels': channels,
        });
      }
    }

    allFixtures.sort((a, b) => b['channels'].compareTo(a['channels']));

    for (var fixture in allFixtures) {
      if (fixture['channels'] > remainingChannels) {
        currentUniverse++;
        remainingChannels = 512;
      }

      if (!universes.containsKey(currentUniverse)) {
        universes[currentUniverse] = [];
      }
      universes[currentUniverse]!.add(fixture);
      remainingChannels -= fixture['channels'] as int;
    }

    String result = '\n${universes.length} ${loc.lightPage_dmxUniverses}\n\n';

    result += '${loc.lightPage_universe} | ${loc.lightPage_quantity} | ${loc.lightPage_fixture}\n';
    result += '-' * 40 + '\n';

    for (var entry in universes.entries) {
      final universe = entry.key;
      final fixtures = entry.value;

      Map<String, int> groupedFixtures = {};
      for (var fixture in fixtures) {
        final name = fixture['name'] as String;
        groupedFixtures[name] = (groupedFixtures[name] ?? 0) + 1;
      }

      bool isFirstInUniverse = true;
      for (var fixture in groupedFixtures.entries) {
        if (isFirstInUniverse) {
          result += '   ${universe.toString().padRight(4)} | ';
          isFirstInUniverse = false;
        } else {
          result += '        | ';
        }
        result += '${fixture.value.toString().padRight(8)} | ${fixture.key}\n';
      }
      result += '-' * 40 + '\n';
    }

    final totalChannels = allFixtures.fold<int>(0, (sum, fixture) => sum + (fixture['channels'] as int));
    result += '\n${loc.lightPage_total}: $totalChannels ${loc.lightPage_dmxChannelsUsed}\n';

    setState(() {
      dmxCalculationResult = result;
    });

    Future.delayed(const Duration(milliseconds: 100), () {
      if (_dmxScrollController.hasClients) {
        _dmxScrollController.animateTo(
          _dmxScrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _resetPage() {
    setState(() {
      selectedFixtures.clear();
      fixtureQuantities.clear();
      selectedProduct = null;
      selectedBrand = null;
      _searchController.clear();
      beamCalculationResult = null;
      driverCalculationResult = null;
      dmxCalculationResult = null;
    });
  }

  void _resetDmx() {
    setState(() {
      selectedFixtures.clear();
      fixtureQuantities.clear();
      selectedProduct = null;
      selectedBrand = null;
      _searchController.clear();
      beamCalculationResult = null;
      driverCalculationResult = null;
      dmxCalculationResult = null;
    });
  }

  void _onSearchChanged(String value) {
    setState(() {
      if (value.isNotEmpty) {
        final results = _dmxFilteredProducts;
        if (results.isNotEmpty) {
          final firstResult = results.first;
          selectedBrand = firstResult.marque;
          selectedProduct = firstResult.produit;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.lightbulb,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: Theme.of(context).brightness == Brightness.light ? 0.15 : 0.5,
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
                const SizedBox(height: 6),
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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate, size: 16),
                            const SizedBox(width: 4),
                            const Text('Faisceau'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate, size: 16),
                            const SizedBox(width: 4),
                            const Text('Driver'),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate, size: 16),
                            const SizedBox(width: 4),
                            const Text('DMX'),
                          ],
                        ),
                      ),
                    ],
                    labelColor: Theme.of(context).extension<LightPageTheme>()?.tabSelectedColor,
                    unselectedLabelColor: Theme.of(context).extension<LightPageTheme>()?.tabUnselectedColor,
                    indicatorColor: Theme.of(context).extension<LightPageTheme>()?.tabIndicatorColor,
                    labelStyle: Theme.of(context).extension<LightPageTheme>()?.tabSelectedTextStyle,
                    unselectedLabelStyle: Theme.of(context).extension<LightPageTheme>()?.tabTextStyle,
                  ),
                ),
                const SizedBox(height: 6),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Premier onglet - Faisceau
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1128)
                                .withAlpha((0.3 * 255).round()),
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${loc.lightPage_angleRange}: ${angle.toStringAsFixed(1)}°',
                                style: Theme.of(context)
                                    .extension<ResultContainerTheme>()
                                    ?.textStyle,
                              ),
                              Slider(
                                value: angle,
                                min: 1,
                                max: 70,
                                divisions: 69,
                                label: '${angle.round()}°',
                                onChanged: (value) =>
                                    setState(() => angle = value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_heightRange}: ${height.toStringAsFixed(1)} m',
                                style: Theme.of(context)
                                    .extension<ResultContainerTheme>()
                                    ?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 20,
                                divisions: 19,
                                value: height,
                                label: '${height.round()}m',
                                onChanged: (value) =>
                                    setState(() => height = value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_distanceRange}: ${distance.toStringAsFixed(1)} m',
                                style: Theme.of(context)
                                    .extension<ResultContainerTheme>()
                                    ?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 40,
                                divisions: 39,
                                value: distance,
                                label: '${distance.round()}m',
                                onChanged: (value) =>
                                    setState(() => distance = value),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () =>
                                          _navigateTo(const ArMeasurePage()),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0A1128)
                                            .withAlpha((0.5 * 255).round()),
                                        side: BorderSide(
                                            color: const Color(0xFF0A1128)
                                                .withAlpha((0.8 * 255).round()),
                                            width: 1),
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 8, vertical: 8),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Image.asset(
                                              'assets/icons/tape_measure.png',
                                              width: 18,
                                              height: 18,
                                              color: Colors.white),
                                          const SizedBox(width: 6),
                                          const Text('AR',
                                              style: TextStyle(
                                                  color: Colors.white)),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 40),
                                    ElevatedButton(
                                      onPressed: _calculateBeam,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0A1128)
                                            .withAlpha((0.5 * 255).round()),
                                        side: BorderSide(
                                            color: const Color(0xFF0A1128)
                                                .withAlpha((0.8 * 255).round()),
                                            width: 1),
                                        padding: const EdgeInsets.all(12),
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8)),
                                      ),
                                      child: const Icon(Icons.calculate,
                                          color: Colors.white, size: 24),
                                    ),
                                  ],
                                ),
                              ),
                              if (beamCalculationResult != null) ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                              .extension<ResultContainerTheme>()
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      beamCalculationResult!,
                                      style: Theme.of(context)
                                              .extension<ResultContainerTheme>()
                                              ?.textStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Deuxième onglet - Driver
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1128)
                                .withAlpha((0.3 * 255).round()),
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.white24),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                        child: DropdownButton<int>(
                                            value: tension,
                                            dropdownColor: Colors.blueGrey[900],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            isExpanded: true,
                                            items: [9, 12, 24]
                                                .map((v) => DropdownMenuItem(
                                                      value: v,
                                                      child: Text('$v V',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                    ))
                                                .toList(),
                                            onChanged: (v) =>
                                                setState(() => tension = v!))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: DropdownButton<int>(
                                            value: nbVoies,
                                            dropdownColor: Colors.blueGrey[900],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            isExpanded: true,
                                            items: List.generate(
                                                    5, (i) => i + 1)
                                                .map((v) => DropdownMenuItem(
                                                      value: v,
                                                      child: Text(
                                                          '$v ${v > 1 ? loc.lightPage_channels : loc.lightPage_channel}',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                    ))
                                                .toList(),
                                            onChanged: (v) =>
                                                setState(() => nbVoies = v!))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: DropdownButton<int>(
                                            value: ampereParVoie.toInt(),
                                            dropdownColor: Colors.blueGrey[900],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            isExpanded: true,
                                            items: List.generate(
                                                    10, (i) => i + 1)
                                                .map((v) => DropdownMenuItem(
                                                      value: v,
                                                      child: Text('$v A',
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                    ))
                                                .toList(),
                                            onChanged: (v) => setState(() =>
                                                ampereParVoie =
                                                    v!.toDouble()))),
                                    const SizedBox(width: 8),
                                    Expanded(
                                        child: DropdownButton<String>(
                                            value: selectedDriver,
                                            dropdownColor: Colors.blueGrey[900],
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium,
                                            isExpanded: true,
                                            items: drivers.keys
                                                .map((d) => DropdownMenuItem(
                                                      value: d,
                                                      child: Text(d,
                                                          style:
                                                              Theme.of(context)
                                                                  .textTheme
                                                                  .bodyMedium),
                                                    ))
                                                .toList(),
                                            onChanged: (v) => setState(
                                                () => selectedDriver = v!))),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.lightPage_ledLength,
                                style: Theme.of(context)
                                        .extension<ResultContainerTheme>()
                                        ?.textStyle ??
                                    Theme.of(context)
                                        .textTheme
                                        .bodyMedium!
                                        .copyWith(color: Colors.white),
                              ),
                              Slider(
                                min: 1,
                                max: 100,
                                divisions: 99,
                                value: longueurLed,
                                label: '${longueurLed.round()} m',
                                onChanged: (v) =>
                                    setState(() => longueurLed = v),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _calculateDriver,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A1128)
                                        .withAlpha((0.5 * 255).round()),
                                    side: BorderSide(
                                        color: const Color(0xFF0A1128)
                                            .withAlpha((0.8 * 255).round()),
                                        width: 1),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Icon(Icons.calculate,
                                      color: Colors.white, size: 24),
                                ),
                              ),
                              if (driverCalculationResult != null) ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(context)
                                              .extension<ResultContainerTheme>()
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
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      driverCalculationResult!,
                                      style: Theme.of(context)
                                              .extension<ResultContainerTheme>()
                                              ?.textStyle ??
                                          Theme.of(context)
                                              .textTheme
                                              .bodyMedium!
                                              .copyWith(color: Colors.white),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                      // Troisième onglet - DMX
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: PresetWidget(
                              loadOnInit: true,
                              onPresetSelected: _loadPreset,
                            ),
                          ),
                          Expanded(
                            child: SingleChildScrollView(
                              controller: _dmxScrollController,
                              padding: const EdgeInsets.all(16),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0A1128).withOpacity(0.3),
                                  border: Border.all(color: Colors.white, width: 1),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    if (_isLoading)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: DropdownButtonFormField<String>(
                                                  value: selectedBrand,
                                                  decoration: InputDecoration(
                                                    labelText: loc.lightPage_brand,
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context).extension<LightPageTheme>()?.dropdownTextColor,
                                                    ),
                                                    filled: true,
                                                    fillColor: Theme.of(context).extension<LightPageTheme>()?.dropdownBackgroundColor,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  dropdownColor: Theme.of(context).cardColor,
                                                  style: TextStyle(
                                                    color: Theme.of(context).extension<LightPageTheme>()?.dropdownTextColor,
                                                  ),
                                                  items: _dmxUniqueBrands
                                                      .map((brand) => DropdownMenuItem(
                                                            value: brand,
                                                            child: Text(brand),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    setState(() {
                                                      selectedBrand = value;
                                                      selectedProduct = null;
                                                    });
                                                  },
                                                ),
                                              ),
                                              const SizedBox(width: 2),
                                              Expanded(
                                                child: DropdownButtonFormField<String>(
                                                  value: selectedProduct,
                                                  decoration: InputDecoration(
                                                    labelText: loc.lightPage_product,
                                                    labelStyle: TextStyle(
                                                      color: Theme.of(context).extension<LightPageTheme>()?.dropdownTextColor,
                                                    ),
                                                    filled: true,
                                                    fillColor: Theme.of(context).extension<LightPageTheme>()?.dropdownBackgroundColor,
                                                    border: OutlineInputBorder(
                                                      borderRadius: BorderRadius.circular(8),
                                                      borderSide: BorderSide.none,
                                                    ),
                                                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                                  ),
                                                  dropdownColor: Theme.of(context).cardColor,
                                                  style: TextStyle(
                                                    color: Theme.of(context).extension<LightPageTheme>()?.dropdownTextColor,
                                                  ),
                                                  isExpanded: true,
                                                  menuMaxHeight: 300,
                                                  items: _dmxProductsForSelectedBrand
                                                      .map((product) => DropdownMenuItem(
                                                            value: product,
                                                            child: Text(
                                                              product,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ))
                                                      .toList(),
                                                  onChanged: (value) {
                                                    if (value != null) {
                                                      final item = ref
                                                          .read(catalogueProvider)
                                                          .firstWhere(
                                                            (item) =>
                                                                item.produit == value &&
                                                                item.categorie == 'Lumière' &&
                                                                item.marque == selectedBrand,
                                                            orElse: () => throw Exception('Produit non trouvé'),
                                                          );
                                                      _showQuantityDialog(item);
                                                    }
                                                  },
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 2),
                                          TextField(
                                            controller: _searchController,
                                            decoration: InputDecoration(
                                              labelText: loc.lightPage_searchProduct,
                                              labelStyle: TextStyle(
                                                color: Theme.of(context).extension<LightPageTheme>()?.searchTextColor,
                                              ),
                                              filled: true,
                                              fillColor: Theme.of(context).extension<LightPageTheme>()?.dropdownBackgroundColor,
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(8),
                                                borderSide: BorderSide.none,
                                              ),
                                              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              prefixIcon: Icon(
                                                Icons.search,
                                                color: Theme.of(context).extension<LightPageTheme>()?.searchIconColor,
                                              ),
                                            ),
                                            style: TextStyle(
                                              color: Theme.of(context).extension<LightPageTheme>()?.searchTextColor,
                                            ),
                                            onChanged: _onSearchChanged,
                                          ),
                                        ],
                                      ),
                                    if (selectedFixtures.isNotEmpty) ...[
                                      const SizedBox(height: 2),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        physics: const NeverScrollableScrollPhysics(),
                                        itemCount: selectedFixtures.length,
                                        itemBuilder: (context, index) {
                                          final fixture = selectedFixtures[index];
                                          final quantity = fixtureQuantities[fixture] ?? 0;
                                          return Padding(
                                            padding: const EdgeInsets.symmetric(vertical: 1),
                                            child: ListTile(
                                              title: Text(fixture.produit),
                                              subtitle: Text(fixture.marque),
                                              trailing: Row(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.remove),
                                                    onPressed: () {
                                                      setState(() {
                                                        if (quantity > 1) {
                                                          fixtureQuantities[fixture] = quantity - 1;
                                                        } else {
                                                          fixtureQuantities.remove(fixture);
                                                          selectedFixtures.remove(fixture);
                                                        }
                                                      });
                                                    },
                                                  ),
                                                  Text('$quantity'),
                                                  IconButton(
                                                    icon: const Icon(Icons.add),
                                                    onPressed: () {
                                                      setState(() {
                                                        fixtureQuantities[fixture] = quantity + 1;
                                                      });
                                                    },
                                                  ),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                      const SizedBox(height: 16),
                                      Center(
                                        child: ElevatedButton(
                                          onPressed: _calculateDMX,
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
                                            side: BorderSide(
                                              color: const Color(0xFF0A1128),
                                              width: 1,
                                            ),
                                            padding: const EdgeInsets.all(12),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                          ),
                                          child: const Icon(Icons.calculate, color: Colors.white, size: 24),
                                        ),
                                      ),
                                    ],
                                    if (dmxCalculationResult != null) ...[
                                      const SizedBox(height: 16),
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: Theme.of(context).extension<ResultContainerTheme>()?.backgroundColor,
                                          border: Border.all(
                                            color: Theme.of(context).extension<ResultContainerTheme>()?.borderColor ?? Colors.white,
                                          ),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          dmxCalculationResult!,
                                          style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
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
