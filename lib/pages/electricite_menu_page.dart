import 'package:flutter/material.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'divers_menu_page.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/preset_widget.dart';
import '../widgets/custom_app_bar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../models/catalogue_item.dart';
import '../models/cart_data.dart';
import '../models/cart_item.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../theme/colors.dart';

class ElectriciteMenuPage extends ConsumerStatefulWidget {
  const ElectriciteMenuPage({super.key});

  @override
  ConsumerState<ElectriciteMenuPage> createState() =>
      _ElectriciteMenuPageState();
}

class _ElectriciteMenuPageState extends ConsumerState<ElectriciteMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  double puissanceTotale = 0;
  double puissanceParPhase = 0;
  int nombrePhases = 1;
  bool showResult = false;

  // Module P = U * I
  final TextEditingController _currentController = TextEditingController();
  final TextEditingController _powerController = TextEditingController();
  String _selectedVoltage = '220';
  bool _isThreePhase = true;

  // Module conversion kW <-> kVA
  final TextEditingController _kwController = TextEditingController();
  final TextEditingController _kvaController = TextEditingController();
  final TextEditingController _pfController = TextEditingController();
  final String _selectedPf = '0.8';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _pfController.text = _selectedPf;

    _currentController.addListener(_updatePowerCalculations);
    _powerController.addListener(_updatePowerCalculations);

    _kwController.addListener(_updateKvaCalculations);
    _kvaController.addListener(_updateKvaCalculations);
    _pfController.addListener(_updateKvaCalculations);
  }

  @override
  void dispose() {
    _currentController.dispose();
    _powerController.dispose();
    _kwController.dispose();
    _kvaController.dispose();
    _pfController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _updatePowerCalculations() {
    if (_currentController.text.isEmpty && _powerController.text.isEmpty) {
      return;
    }

    final voltage = double.parse(_selectedVoltage);
    final phaseMultiplier = _isThreePhase ? 3.0 : 1.0;

    if (_currentController.text.isNotEmpty && _powerController.text.isEmpty) {
      final current = double.tryParse(_currentController.text) ?? 0;
      final power = current * voltage * phaseMultiplier;
      _powerController.text = power.toStringAsFixed(0);
    } else if (_powerController.text.isNotEmpty &&
        _currentController.text.isEmpty) {
      final power = double.tryParse(_powerController.text) ?? 0;
      final current = power / (voltage * phaseMultiplier);
      _currentController.text = current.toStringAsFixed(1);
    }
  }

  void _updateKvaCalculations() {
    if (_pfController.text.isEmpty ||
        (_kwController.text.isEmpty && _kvaController.text.isEmpty)) {
      return;
    }

    final pf = double.tryParse(_pfController.text) ?? 0;
    if (pf == 0) return;

    if (_kwController.text.isNotEmpty && _kvaController.text.isEmpty) {
      final kw = double.tryParse(_kwController.text) ?? 0;
      final kva = kw / pf;
      _kvaController.text = kva.toStringAsFixed(2);
    } else if (_kvaController.text.isNotEmpty && _kwController.text.isEmpty) {
      final kva = double.tryParse(_kvaController.text) ?? 0;
      final kw = kva * pf;
      _kwController.text = kw.toStringAsFixed(2);
    }
  }

  void _navigateTo(int index) {
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
  }

  Widget _buildProjectTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final preset = ref.read(presetProvider.notifier).activePreset;

    if (preset == null) {
      return Center(
        child: Text(
          'Aucun preset sélectionné',
          style: TextStyle(
            color: isDark ? AppColors.lightText : AppColors.mainBlue
          ),
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

      final value = item.item.conso.contains('W')
          ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
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
          Text(
            preset.name,
            style: TextStyle(
              color: isDark ? AppColors.lightText : AppColors.mainBlue,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...grouped.entries.map((entry) {
            final category = entry.key;
            final items = entry.value;
            final total = totalsPerCategory[category] ?? 0;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: TextStyle(
                    color: isDark ? AppColors.lightText : AppColors.mainBlue,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ...items.map((item) {
                  final cartItem = preset.items.firstWhere(
                    (cartItem) => cartItem.item.id == item.id,
                    orElse: () => CartItem(item: item, quantity: 0),
                  );
                  
                  return Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${item.produit} - ${item.marque}',
                            style: TextStyle(
                              color: isDark ? Colors.white70 : AppColors.mainBlue.withOpacity(0.7)
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 16),
                              onPressed: () {
                                if (cartItem.quantity > 1) {
                                  cartItem.quantity--;
                                  ref.read(presetProvider.notifier).updatePreset(preset);
                                  setState(() {});
                                }
                              },
                              color: isDark ? Colors.white : Colors.black,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            Container(
                              width: 32,
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Text(
                                cartItem.quantity.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: isDark ? Colors.white70 : AppColors.mainBlue.withOpacity(0.7)
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 16),
                              onPressed: () {
                                cartItem.quantity++;
                                ref.read(presetProvider.notifier).updatePreset(preset);
                                setState(() {});
                              },
                              color: isDark ? Colors.white : Colors.black,
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline, size: 16),
                              onPressed: () {
                                preset.items.removeWhere((item) => item.item.id == cartItem.item.id);
                                ref.read(presetProvider.notifier).updatePreset(preset);
                                setState(() {});
                              },
                              color: isDark ? Colors.white : Colors.black,
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
                    'Total puissance ${category.toLowerCase()} : ${total.toStringAsFixed(2)}W',
                    style: TextStyle(
                      color: isDark ? AppColors.lightText : AppColors.mainBlue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            );
          }),
          const Divider(color: Colors.white30),
          const SizedBox(height: 8),
          Text(
            'Total puissance preset : ${totalPreset.toStringAsFixed(2)}W',
            style: TextStyle(
              color: isDark ? AppColors.lightText : AppColors.mainBlue,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPowerCalculationTab() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Module P = U * I
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.5),
              border: Border.all(
                color: isDark ? Colors.white : AppColors.mainBlue,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'P = U × I',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Transform.scale(
                      scale: 0.5,
                      child: Switch(
                        value: _isThreePhase,
                        onChanged: (value) {
                          setState(() {
                            _isThreePhase = value;
                            _updatePowerCalculations();
                          });
                        },
                      ),
                    ),
                    Text(
                      _isThreePhase ? 'Triphasé' : 'Monophasé',
                      style: const TextStyle(
                        color: Colors.white
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          canvasColor: const Color(0xFF0A1128),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: _selectedVoltage,
                          isExpanded: true,
                          isDense: true,
                          style: const TextStyle(
                            color: Colors.white
                          ),
                          decoration: const InputDecoration(
                            filled: true,
                            fillColor: Colors.transparent,
                            labelText: 'U (V)',
                            labelStyle: TextStyle(
                              color: Colors.white70
                            ),
                            enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white30
                              ),
                            ),
                            focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(
                                color: Colors.white
                              ),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(value: '110', child: Text('110')),
                            DropdownMenuItem(value: '120', child: Text('120')),
                            DropdownMenuItem(value: '220', child: Text('220')),
                            DropdownMenuItem(value: '230', child: Text('230')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedVoltage = value;
                                _updatePowerCalculations();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _currentController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: _isThreePhase
                              ? 'I phase (A)'
                              : 'I (A)',
                          labelStyle: const TextStyle(
                            color: Colors.white70
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _powerController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: _isThreePhase
                              ? 'P totale (W)'
                              : 'P (W)',
                          labelStyle: const TextStyle(
                            color: Colors.white70
                          ),
                          enabledBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _currentController.clear();
                      _powerController.clear();
                    });
                  },
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Module conversion kW ↔ kVA
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.5),
              border: Border.all(
                color: isDark ? Colors.white : AppColors.mainBlue,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'kW ↔ kVA',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _kwController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'P (kW)',
                          labelStyle: TextStyle(
                            color: Colors.white70
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _pfController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'cos φ',
                          labelStyle: TextStyle(
                            color: Colors.white70
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _kvaController,
                        style: const TextStyle(
                          color: Colors.white
                        ),
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          filled: true,
                          fillColor: Colors.transparent,
                          labelText: 'P (kVA)',
                          labelStyle: TextStyle(
                            color: Colors.white70
                          ),
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white30
                            ),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.white
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _pfController.text = _selectedPf;
                      _kwController.clear();
                      _kvaController.clear();
                    });
                  },
                  child: const Text(
                    'Réinitialiser',
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.bolt,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: isDark ? 0.5 : 0.15,
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
                TabBar(
                  controller: _tabController,
                  labelColor: isDark ? AppColors.lightText : AppColors.mainBlue,
                  unselectedLabelColor: Colors.grey,
                  indicatorColor: isDark ? AppColors.lightText : AppColors.mainBlue,
                  tabs: const [
                    Tab(text: 'Calcul Projet'),
                    Tab(text: 'Calcul Puissance'),
                  ],
                ),
                const SizedBox(height: 6),
                PresetWidget(
                  onPresetSelected: (preset) {
                    ref.read(presetProvider.notifier).clear();
                    for (var item in preset.items) {
                      ref
                          .read(presetProvider.notifier)
                          .addItemToActivePreset(item.item);
                    }
                    // Calculer la puissance totale
                    puissanceTotale = 0;
                    for (var item in preset.items) {
                      final value = item.item.conso.contains('W')
                          ? double.tryParse(
                                  item.item.conso.replaceAll('W', '').trim()) ??
                              0
                          : 0;
                      puissanceTotale += value;
                    }
                    puissanceParPhase = puissanceTotale / nombrePhases;
                  },
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Container(
                    margin:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.cardBlue : const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(
                        color: isDark ? Colors.white : AppColors.mainBlue,
                        width: 1
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        _buildProjectTab(),
                        _buildPowerCalculationTab(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.cardBlue,
        selectedItemColor: AppColors.lightText,
        unselectedItemColor: Colors.grey,
        currentIndex: 5,
        onTap: _navigateTo,
        items: [
          BottomNavigationBarItem(
              icon: const Icon(Icons.list), label: loc.catalogAccess),
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
