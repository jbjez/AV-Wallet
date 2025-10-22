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
import 'dmx_tab.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../models/catalogue_item.dart';
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
  double angle = 35;
  double height = 10;
  double distance = 20;
  double ampereParVoie = 3;
  int nbVoies = 5;
  int tension = 24;
  String selectedDriver = 'S04x5A';
  double longueurLed = 5;
  String? beamCalculationResult;
  String? driverCalculationResult;

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
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _calculateBeam() {
    final beamDiameter = 2 * distance * tan(angle * pi / 180);
    setState(() {
      beamCalculationResult = 
          '${AppLocalizations.of(context)!.lightPage_beamDiameter}: ${beamDiameter.toStringAsFixed(2)} m';
    });
  }

  void _calculateDriver() {
    final loc = AppLocalizations.of(context)!;
    final driver = drivers[selectedDriver];
    if (driver == null) return;

    int nbDrivers = (longueurLed * ampereParVoie / (driver.voies * driver.ampereParVoie)).ceil();
    
    setState(() {
      driverCalculationResult = 
          '$nbDrivers x $selectedDriver\n'
          '${loc.lightPage_total}: ${(nbDrivers * driver.voies * driver.ampereParVoie).toStringAsFixed(1)}A';
    });
  }

  void _loadPreset(Preset preset) {
    // Logique pour charger un preset
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
            opacity: Theme.of(context).brightness == Brightness.light ? 0.15 : 0.3,
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
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
                            const Text('DMX'),
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
                      // Premier onglet - DMX
                      const DMXTab(),
                      // Deuxième onglet - Faisceau
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1128).withAlpha((0.3 * 255).round()),
                            border: Border.all(color: Colors.white, width: 1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${loc.lightPage_angleRange}: ${angle.toStringAsFixed(1)}°',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                value: angle,
                                min: 1,
                                max: 70,
                                divisions: 69,
                                label: '${angle.round()}°',
                                onChanged: (value) => setState(() => angle = value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_heightRange}: ${height.toStringAsFixed(1)} m',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 20,
                                divisions: 19,
                                value: height,
                                label: '${height.round()}m',
                                onChanged: (value) => setState(() => height = value),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${loc.lightPage_distanceRange}: ${distance.toStringAsFixed(1)} m',
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle,
                              ),
                              Slider(
                                min: 1,
                                max: 40,
                                divisions: 39,
                                value: distance,
                                label: '${distance.round()}m',
                                onChanged: (value) => setState(() => distance = value),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _calculateBeam,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(loc.lightPage_calculate),
                              ),
                              const SizedBox(height: 16),
                              if (beamCalculationResult != null)
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.2),
                                    border: Border.all(color: Colors.green),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    beamCalculationResult!,
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                      // Troisième onglet - Driver
                      SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xFF0A1128).withAlpha((0.3 * 255).round()),
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
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        isExpanded: true,
                                        items: [9, 12, 24].map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Text('$v V', style: Theme.of(context).textTheme.bodyMedium),
                                        )).toList(),
                                        onChanged: (v) => setState(() => tension = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<int>(
                                        value: nbVoies,
                                        dropdownColor: Colors.blueGrey[900],
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        isExpanded: true,
                                        items: List.generate(5, (i) => i + 1).map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Text('$v ${v > 1 ? loc.lightPage_channels : loc.lightPage_channel}', 
                                              style: Theme.of(context).textTheme.bodyMedium),
                                        )).toList(),
                                        onChanged: (v) => setState(() => nbVoies = v!),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<int>(
                                        value: ampereParVoie.toInt(),
                                        dropdownColor: Colors.blueGrey[900],
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        isExpanded: true,
                                        items: List.generate(10, (i) => i + 1).map((v) => DropdownMenuItem(
                                          value: v,
                                          child: Text('$v A', style: Theme.of(context).textTheme.bodyMedium),
                                        )).toList(),
                                        onChanged: (v) => setState(() => ampereParVoie = v!.toDouble()),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: DropdownButton<String>(
                                        value: selectedDriver,
                                        dropdownColor: Colors.blueGrey[900],
                                        style: Theme.of(context).textTheme.bodyMedium,
                                        isExpanded: true,
                                        items: drivers.keys.map((d) => DropdownMenuItem(
                                          value: d,
                                          child: Text(d, style: Theme.of(context).textTheme.bodyMedium),
                                        )).toList(),
                                        onChanged: (v) => setState(() => selectedDriver = v!),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                loc.lightPage_ledLength,
                                style: Theme.of(context).extension<ResultContainerTheme>()?.textStyle ??
                                    Theme.of(context).textTheme.bodyMedium!.copyWith(color: Colors.white),
                              ),
                              Slider(
                                min: 1,
                                max: 100,
                                divisions: 99,
                                value: longueurLed,
                                label: '${longueurLed.round()} m',
                                onChanged: (v) => setState(() => longueurLed = v),
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _calculateDriver,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF0A1128).withAlpha((0.5 * 255).round()),
                                    side: BorderSide(
                                      color: const Color(0xFF0A1128).withAlpha((0.8 * 255).round()),
                                      width: 1,
                                    ),
                                    padding: const EdgeInsets.all(12),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                  ),
                                  child: const Icon(Icons.calculate, color: Colors.white, size: 24),
                                ),
                              ),
                              if (driverCalculationResult != null) ...[
                                const SizedBox(height: 16),
                                Center(
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.2),
                                      border: Border.all(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      driverCalculationResult!,
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StructureMenuPage()),
              );
              break;
            case 1:
              // Déjà sur la page lumière
              break;
            case 2:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SoundMenuPage()),
              );
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VideoMenuPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ElectriciteMenuPage()),
              );
              break;
            case 5:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DiversMenuPage()),
              );
              break;
          }
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Structure',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.lightbulb),
            label: 'Lumière',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.volume_up),
            label: 'Son',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.videocam),
            label: 'Vidéo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bolt),
            label: 'Électricité',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.more_horiz),
            label: 'Divers',
          ),
        ],
      ),
    );
  }
}
