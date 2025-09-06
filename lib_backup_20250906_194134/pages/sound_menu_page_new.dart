import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/preset_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/preset_provider.dart';
import 'catalogue_page.dart';
import 'video_menu_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import '../widgets/export_widget.dart';
import '../widgets/sound_tabs/amplifier_tab.dart';

class SoundMenuPage extends ConsumerStatefulWidget {
  const SoundMenuPage({super.key});

  @override
  ConsumerState<SoundMenuPage> createState() => _SoundMenuPageState();
}

class _SoundMenuPageState extends ConsumerState<SoundMenuPage>
    with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 1, vsync: this);
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
      backgroundColor: const Color(0xFF0A1128),
      appBar: CustomAppBar(
        title: loc.soundPage_title,
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
                const SizedBox(height: 8),
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        decoration: const BoxDecoration(),
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: TabBar(
                          controller: _tabController,
                          tabs: [
                            Tab(
                              child: Row(
                                children: [
                                  const Icon(Icons.calculate, size: 18),
                                  const SizedBox(width: 8),
                                  Text('Amplificateur', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 6),
                      PresetWidget(
                        onPresetSelected: (preset) {
                          final index = ref.read(presetProvider).indexOf(preset);
                          if (index != -1) {
                            ref.read(presetProvider.notifier).selectPreset(index);
                          }
                        },
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: const [
                            AmplifierTab(),
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 2,
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StructureMenuPage()),
              );
              break;
            case 1:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const LightMenuPage()),
              );
              break;
            case 2:
              // Page actuelle
              break;
            case 3:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ElectriciteMenuPage()),
              );
              break;
            case 4:
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const VideoMenuPage()),
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
        items: [
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/structureicon.png', width: 24, height: 24, color: Colors.grey),
            activeIcon: Image.asset('assets/icons/structureicon.png', width: 24, height: 24, color: Colors.white),
            label: loc.structurePage_title,
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/icon_faisceau_violet.png', width: 24, height: 24, color: Colors.grey),
            activeIcon: Image.asset('assets/icons/icon_faisceau_violet.png', width: 24, height: 24, color: Colors.white),
            label: loc.lightPage_title,
          ),
          BottomNavigationBarItem(
            icon: Image.asset('assets/icons/icon_calculate_violet.png', width: 24, height: 24, color: Colors.white),
            activeIcon: Image.asset('assets/icons/icon_calculate_violet.png', width: 24, height: 24, color: Colors.white),
            label: loc.soundPage_title,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.electrical_services, color: Colors.grey),
            activeIcon: const Icon(Icons.electrical_services, color: Colors.white),
            label: 'Électricité',
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.videocam, color: Colors.grey),
            activeIcon: const Icon(Icons.videocam, color: Colors.white),
            label: loc.videoPage_title,
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.more_horiz, color: Colors.grey),
            activeIcon: const Icon(Icons.more_horiz, color: Colors.white),
            label: 'Divers',
          ),
        ],
      ),
    );
  }
}
