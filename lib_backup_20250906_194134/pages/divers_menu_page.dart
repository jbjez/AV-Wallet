// lib/pages/divers_menu_page.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../widgets/custom_app_bar.dart';
import '../widgets/preset_widget.dart';
import '../providers/preset_provider.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_products_page.dart';
// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class DiversMenuPage extends ConsumerStatefulWidget {
  const DiversMenuPage({super.key});

  @override
  ConsumerState<DiversMenuPage> createState() => _DiversMenuPageState();
}

class _DiversMenuPageState extends ConsumerState<DiversMenuPage>
    with SingleTickerProviderStateMixin {
  final _logger = Logger('DiversMenuPage');
  bool _isScanning = false;
  List<dynamic> networks = [];
  late TabController _tabController;
  String result = '';
  double downloadSpeed = 0;
  double uploadSpeed = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  Future<void> _scanNetworks() async {
    try {
      setState(() => _isScanning = true);
      // Fonctionnalité désactivée temporairement
      setState(() {
        _isScanning = false;
      });
    } catch (e, stackTrace) {
      _logger.severe('Error scanning networks', e, stackTrace);
      setState(() => _isScanning = false);
    }
  }

  Future<void> testBandwidth() async {
    setState(() {
      result = 'Test de bande passante en cours...';
    });
    final stopwatch = Stopwatch()..start();
    final response =
        await http.get(Uri.parse('https://speed.hetzner.de/100MB.bin'));
    stopwatch.stop();
    if (response.statusCode == 200) {
      final timeSec = stopwatch.elapsedMilliseconds / 1000;
      final speedMbps = (response.contentLength ?? 0) * 8 / timeSec / 1000000;
      setState(() {
        downloadSpeed = speedMbps;
        uploadSpeed = speedMbps / 10;
        result =
            'Download: ${downloadSpeed.toStringAsFixed(2)} Mbps\nUpload: ${uploadSpeed.toStringAsFixed(2)} Mbps';
      });
    } else {
      setState(() {
        result = 'Erreur lors du téléchargement';
      });
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

  Widget _buildProduits() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2,
            size: 80,
            color: Colors.blueGrey[300],
          ),
          const SizedBox(height: 24),
          Text(
            'Produits Divers',
            style: TextStyle(
              fontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Backstage et Traiteur',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[300],
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DiversProductsPage(),
                ),
              );
            },
            icon: const Icon(Icons.arrow_forward),
            label: const Text('Voir les produits'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueGrey[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.more_horiz,
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
                const SizedBox(height: 6),
                Expanded(
                  child: DefaultTabController(
                    length: 3,
                    child: Column(
                      children: [
                        const TabBar(
                          tabs: [
                            Tab(text: 'Produits'),
                            Tab(text: 'Bande Passante'),
                            Tab(text: 'Scan Réseau'),
                          ],
                        ),
                        const SizedBox(height: 6),
                        PresetWidget(
                          onPresetSelected: (preset) {
                            setState(() {
                              final presets = ref.read(presetProvider);
                              final index = presets.indexWhere((p) => p.id == preset.id);
                              if (index != -1) {
                                ref.read(presetProvider.notifier).selectPreset(index);
                              }
                            });
                          },
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: TabBarView(
                            children: [
                              _buildProduits(),
                              _buildBandePassante(),
                              _buildScanReseau(),
                            ],
                          ),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 6,
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

  Widget _buildBandePassante() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Aucun réseau détecté',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: testBandwidth,
            child: const Text('Lancer le test'),
          ),
          const SizedBox(height: 20),
          Center(
            child: SpeedTestGauge(speedMbps: downloadSpeed),
          ),
          const SizedBox(height: 20),
          Text(
            result,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildScanReseau() {
    return const Center(
      child: Text('Scan réseau local à venir',
          style: TextStyle(color: Colors.white)),
    );
  }
}

class SpeedTestGauge extends StatelessWidget {
  final double speedMbps;

  const SpeedTestGauge({super.key, required this.speedMbps});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      height: 160,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 160,
            height: 160,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.shade800,
            ),
          ),
          CircularProgressIndicator(
            value: (speedMbps / 100).clamp(0, 1),
            strokeWidth: 12,
            backgroundColor: Colors.grey,
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Text(
            '${speedMbps.toStringAsFixed(1)} Mbps',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}
