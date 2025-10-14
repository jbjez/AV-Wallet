import 'package:flutter/material.dart'; 
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../widgets/preset_widget.dart';
import '../widgets/decibel_meter_tab.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/border_labeled_dropdown.dart';
import '../providers/preset_provider.dart';
import '../providers/sound_page_provider.dart';
import '../models/sound_page_state.dart';
import '../widgets/uniform_bottom_nav_bar.dart';
import '../widgets/export_widget.dart';
import '../widgets/action_button.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'patch_scene_page.dart';

/// Capacités mini garanties par sortie (parCanal) et totales par ampli (parAmpli = x2)
/// Base pour calculs d'amplification AV Wallet.
const Map<String, dynamic> DRIVE_CAPACITY = {
  // ========================= L-ACOUSTICS =========================
  "K2": {
    "impedance": "8 Ω",
    "puissanceAES": "800 W",
    "LA12X": {"parCanal": 3, "parAmpli": 6},
    "LA8":   {"parCanal": 2, "parAmpli": 4},
    "LA4X":  {"parCanal": 1, "parAmpli": 2},
  },
  "Kara II": {
    "impedance": "8 Ω",
    "puissanceAES": "450 W",
    "LA12X": {"parCanal": 3, "parAmpli": 6},   // tableau: 3 / 6
    "LA8":   {"parCanal": 2, "parAmpli": 4},   // 2 / 4
    "LA4X":  {"parCanal": 2, "parAmpli": 4},   // 2 / 4
  },
  "Kiva II": {
    "impedance": "16 Ω",
    "puissanceAES": "200 W",
    "LA12X": {"parCanal": 6, "parAmpli": 12},  // 6 / 24 -> x2 sorties = 12
    "LA8":   {"parCanal": 4, "parAmpli": 8},   // 4 / 16
    "LA4X":  {"parCanal": 2, "parAmpli": 4},   // 2 / 8
  },

  // WST courbure constante (A-Series)
  "A15 (Focus/Wide)": {
    "impedance": "8 Ω",
    "puissanceAES": "≈500 W",
    "LA12X": {"parCanal": 3, "parAmpli": 6},   // 3 / 12
    "LA8":   {"parCanal": 2, "parAmpli": 4},   // 2 / 8
    "LA4X":  {"parCanal": 1, "parAmpli": 2},   // 1 / 4
  },

  // SUBS
  "KS28": {
    "impedance": "4 Ω",
    "puissanceAES": "2500 W",
    "LA12X": {"parCanal": 1, "parAmpli": 2},   // 1 / 4
    "LA8":   {"parCanal": 1, "parAmpli": 2},   // 1 / 4
    "LA4X":  {"parCanal": 0, "parAmpli": 0},
  },
  "KS21": {
    "impedance": "8 Ω",
    "puissanceAES": "≈800 W",
    "LA12X": {"parCanal": 2, "parAmpli": 4},   // 2 / 8
    "LA8":   {"parCanal": 2, "parAmpli": 4},   // 2 / 6 (note b) → mini sûr = 2 par sortie
    "LA4X":  {"parCanal": 1, "parAmpli": 2},   // 1 / 4
  },
  "SB18": {
    "impedance": "8 Ω",
    "puissanceAES": "700 W",
    "LA12X": {"parCanal": 3, "parAmpli": 6},   // 3 / 12
    "LA8":   {"parCanal": 2, "parAmpli": 4},   // 2 / 6 (note c) → mini sûr = 2 par sortie
    "LA4X":  {"parCanal": 1, "parAmpli": 2},   // 1 / 4
  },
  "SB118": {
    "impedance": "8 Ω",
    "puissanceAES": "≈600 W",
    "LA12X": {"parCanal": 2, "parAmpli": 4},   // 2 / 8
    "LA8":   {"parCanal": 2, "parAmpli": 4},   // 2 / 8
    "LA4X":  {"parCanal": 1, "parAmpli": 2},   // 1 / 4
  },
  "SB218": {
    "impedance": "4 Ω",
    "puissanceAES": "≈1100 W",
    "LA12X": {"parCanal": 1, "parAmpli": 2},   // 1 / 4
    "LA8":   {"parCanal": 1, "parAmpli": 2},   // 1 / 4
    "LA4X":  {"parCanal": 0, "parAmpli": 0},
  },

  // Quelques points source utiles
  "X12": {
    "impedance": "8 Ω",
    "puissanceAES": "500 W",
    "LA12X": {"parCanal": 2, "parAmpli": 4},
    "LA8":   {"parCanal": 2, "parAmpli": 4},
    "LA4X":  {"parCanal": 1, "parAmpli": 2},
  },
  "X15 HiQ": {
    "impedance": "8 Ω",
    "puissanceAES": "800 W",
    "LA12X": {"parCanal": 2, "parAmpli": 4},
    "LA8":   {"parCanal": 1, "parAmpli": 2},
    "LA4X":  {"parCanal": 1, "parAmpli": 2},
  },

  // ========================= d&b audiotechnik =========================
  // Capacités mini pratiques par sortie (usage courant D80 / 30D) + parAmpli = x2 sorties
  "J8/J12": {
    "impedance": "8 Ω (bi-amp)",
    "puissanceAES": "800 W LF + 200 W MF/HF",
    "D80": {"parCanal": 2, "parAmpli": 4},
    "30D": {"parCanal": 0, "parAmpli": 0},
  },
  "V8/V12": {
    "impedance": "8 Ω (bi-amp)",
    "puissanceAES": "500 W LF + 200 W MF/HF",
    "D80": {"parCanal": 2, "parAmpli": 4},
    "30D": {"parCanal": 1, "parAmpli": 2},
  },
  "Y8/Y12": {
    "impedance": "8 Ω",
    "puissanceAES": "400 W",
    "D80": {"parCanal": 4, "parAmpli": 8},
    "30D": {"parCanal": 2, "parAmpli": 4},
  },
  "A8/A12": {
    "impedance": "8 Ω",
    "puissanceAES": "300–400 W",
    "D80": {"parCanal": 4, "parAmpli": 8},
    "30D": {"parCanal": 2, "parAmpli": 4},
  },
  "J-Sub": {
    "impedance": "8 Ω",
    "puissanceAES": "1600 W",
    "D80": {"parCanal": 1, "parAmpli": 2},
    "30D": {"parCanal": 0, "parAmpli": 0},
  },
  "V-Sub": {
    "impedance": "8 Ω",
    "puissanceAES": "800 W",
    "D80": {"parCanal": 2, "parAmpli": 4},
    "30D": {"parCanal": 1, "parAmpli": 2},
  },
  "B22": {
    "impedance": "4 Ω",
    "puissanceAES": "2000 W",
    "D80": {"parCanal": 1, "parAmpli": 2},
    "30D": {"parCanal": 0, "parAmpli": 0},
  },
  "M4": {
    "impedance": "8 Ω",
    "puissanceAES": "600 W",
    "D80": {"parCanal": 2, "parAmpli": 4},
    "30D": {"parCanal": 1, "parAmpli": 2},
  },
  "E8": {
    "impedance": "16 Ω",
    "puissanceAES": "200 W",
    "D80": {"parCanal": 8, "parAmpli": 16},
    "30D": {"parCanal": 4, "parAmpli": 8},
  },
};

class SoundMenuPage extends ConsumerStatefulWidget {
  const SoundMenuPage({super.key});

  @override
  ConsumerState<SoundMenuPage> createState() => _SoundMenuPageState();
}

class _SoundMenuPageState extends ConsumerState<SoundMenuPage>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _scrollController = ScrollController();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        pageIcon: Icons.volume_up,
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
                const SizedBox(height: 6),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicatorColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue 
                        : const Color(0xFF0A1128),
                    indicatorWeight: 3,
                    labelColor: Theme.of(context).brightness == Brightness.dark 
                        ? Colors.lightBlue 
                        : const Color(0xFF0A1128),
                    unselectedLabelColor: Colors.grey,
                    tabs: [
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.calculate, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              AppLocalizations.of(context)!.soundPage_amplificationTabShort,
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.volume_up, size: 16),
                            const SizedBox(width: 3),
                            const Text(
                              'dB',
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                      Tab(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.settings, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              'Rider',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                    onTap: (index) {
                      // Logique de changement d'onglet si nécessaire
                    },
                  ),
                  ),
                const SizedBox(height: 6),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      AmplificationLATab(),
                      DecibelMeterTab(),
                      PatchScenePage(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const UniformBottomNavBar(currentIndex: 3),
    );
  }
}

class AmplificationLATab extends ConsumerStatefulWidget {
  const AmplificationLATab({super.key});

  @override
  ConsumerState<AmplificationLATab> createState() => _AmplificationLATabState();
}

class _AmplificationLATabState extends ConsumerState<AmplificationLATab> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  final GlobalKey _resultKey = GlobalKey();
  final GlobalKey _buttonsKey = GlobalKey();

  final List<String> amplifierTypes = ['LA4X', 'LA8', 'LA12X', 'Custom'];
  final List<String> soundCategories = ['Toutes', 'Line-Array', 'Wedge/Point Source', 'Sub', 'Ampli'];

  // Gestion des commentaires
  Map<String, String> _comments = {};
  String _currentSoundResult = ''; // Clé unique pour le résultat son actuel

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadComments();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soundState = ref.read(soundPageProvider);
      _searchController.text = soundState.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Getters pour accéder à l'état persistant
  SoundPageState get soundState => ref.watch(soundPageProvider);
  String get searchQuery => soundState.searchQuery;
  String? get selectedSpeaker => soundState.selectedSpeaker;
  int get speakerQuantity => soundState.speakerQuantity;
  List<Map<String, dynamic>> get selectedSpeakers => soundState.selectedSpeakers;
  List<CatalogueItem> get searchResults => soundState.searchResults;
  String? get calculationResult => soundState.calculationResult;
  String? get selectedCategory => soundState.selectedCategory;
  String? get selectedBrand => soundState.selectedBrand;

  // Getters pour récupérer les données du catalogue
  List<CatalogueItem> get soundItems => ref.watch(catalogueProvider)
      .where((item) => item.categorie == 'Son')
      .toList();

  List<String> get availableBrands {
    final brands = soundItems.map((item) => item.marque).toSet().toList()..sort();
    return ['Toutes', ...brands];
  }

  List<String> get availableSpeakers {
    return soundItems.map((item) => item.produit).toList();
  }

  List<CatalogueItem> get filteredSoundItems {
    var items = soundItems;
    
    if (selectedBrand != null && selectedBrand != 'Toutes') {
      items = items.where((item) => item.marque == selectedBrand).toList();
    }
    
    if (selectedCategory != null && selectedCategory != 'Toutes') {
      items = items.where((item) => item.sousCategorie == selectedCategory).toList();
    }
    
    return items;
  }

  // Données techniques des amplificateurs
  final Map<String, Map<String, dynamic>> amplifierSpecs = {
    'LA4X': {
      'power': 1000, // Watts par canal
      'channels': 4,
      'impedance': 4, // Ohms minimum
      'brand': 'L-Acoustics'
    },
    'LA8': {
      'power': 2000, // Watts par canal
      'channels': 8,
      'impedance': 4, // Ohms minimum
      'brand': 'L-Acoustics'
    },
    'LA12X': {
      'power': 3300, // Watts par canal @ 8Ω
      'channels': 4, // 4 canaux
      'impedance': 2, // Ohms minimum
      'brand': 'L-Acoustics'
    },
    'D30': {
      'power': 1500, // Watts par canal
      'channels': 4,
      'impedance': 4, // Ohms minimum
      'brand': 'D&B'
    },
    'D80': {
      'power': 4000, // Watts par canal
      'channels': 8,
      'impedance': 4, // Ohms minimum
      'brand': 'D&B'
    },
  };

  // Données techniques des enceintes (spécifications réelles)
  final Map<String, Map<String, dynamic>> speakerSpecs = {
    // L-Acoustics Line-Array
    'K1': {
      'power': 1000, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Line-Array'
    },
    'K2': {
      'power': 800, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Line-Array'
    },
    'Kara II': {
      'power': 450, // Watts AES
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Line-Array'
    },
    'Kiva II': {
      'power': 150, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Line-Array'
    },
    // L-Acoustics Sub
    'KS28': {
      'power': 1000, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Sub'
    },
    'SB18': {
      'power': 600, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Sub'
    },
    // L-Acoustics Wedge/Point Source
    'X8': {
      'power': 300, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Wedge/Point Source'
    },
    'X12': {
      'power': 400, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Wedge/Point Source'
    },
    'X15 HiQ': {
      'power': 500, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Wedge/Point Source'
    },
    '5XT': {
      'power': 50, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'L-Acoustics',
      'category': 'Wedge/Point Source'
    },
    // D&B Line-Array
    'J8': {
      'power': 1200, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'J12': {
      'power': 1500, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'V8': {
      'power': 800, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'V12': {
      'power': 1000, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'Y8': {
      'power': 400, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'Y12': {
      'power': 600, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'A8': {
      'power': 300, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    'A12': {
      'power': 500, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Line-Array'
    },
    // D&B Sub
    'J-Sub': {
      'power': 2000, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Sub'
    },
    'V-Sub': {
      'power': 1200, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Sub'
    },
    'B22': {
      'power': 1800, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Sub'
    },
    // D&B Wedge/Point Source
    'M4': {
      'power': 400, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Wedge/Point Source'
    },
    'E8': {
      'power': 200, // Watts RMS
      'impedance': 8, // Ohms
      'brand': 'd&b audiotechnik',
      'category': 'Wedge/Point Source'
    },
  };

  // Fonction pour obtenir les amplificateurs disponibles selon la marque de l'enceinte
  List<String> getAvailableAmplifiers(String speakerName) {
    // Trouver la marque de l'enceinte
    final speakerItem = soundItems.firstWhere(
      (item) => item.produit == speakerName,
      orElse: () => throw Exception('Enceinte non trouvée: $speakerName'),
    );
    
    final speakerBrand = speakerItem.marque;
    
    // Retourner les amplificateurs correspondants
    switch (speakerBrand.toLowerCase()) {
      case 'l-acoustics':
        return ['LA4X', 'LA8', 'LA12X'];
      case 'd&b audiotechnik':
        return ['D30', 'D80'];
      default:
        return ['Custom']; // Par défaut si marque non reconnue
    }
  }

  // Fonction pour obtenir l'amplificateur par défaut selon la catégorie
  String getDefaultAmplifier(String speakerName, String category) {
    final availableAmps = getAvailableAmplifiers(speakerName);
    
    switch (category.toLowerCase()) {
      case 'line-array':
        // Pour les line arrays, choisir l'ampli de plus grande capacité
        if (availableAmps.contains('LA12X')) return 'LA12X';
        if (availableAmps.contains('D80')) return 'D80';
        return availableAmps.first;
      case 'wedge/point source':
        // Pour les wedges, choisir l'ampli de plus petite capacité
        if (availableAmps.contains('LA4X')) return 'LA4X';
        if (availableAmps.contains('D30')) return 'D30';
        return availableAmps.first;
      case 'sub':
        // Pour les sub, laisser le choix (pas de défaut)
        return availableAmps.first;
      default:
        return availableAmps.first;
    }
  }

  // Fonction utilitaire pour récupérer les capacités d'amplification
  Map<String, int>? getDriveCapacity(String speakerName, String amplifierName) {
    // Normaliser les noms pour correspondre à la map
    String normalizedSpeaker = speakerName;
    String normalizedAmp = amplifierName;
    
    // Gestion des noms spéciaux
    if (speakerName.contains('J8') || speakerName.contains('J12')) {
      normalizedSpeaker = 'J8/J12';
    } else if (speakerName.contains('V8') || speakerName.contains('V12')) {
      normalizedSpeaker = 'V8/V12';
    } else if (speakerName.contains('Y8') || speakerName.contains('Y12')) {
      normalizedSpeaker = 'Y8/Y12';
    } else if (speakerName.contains('A8') || speakerName.contains('A12')) {
      normalizedSpeaker = 'A8/A12';
    } else if (speakerName.contains('J-Sub')) {
      normalizedSpeaker = 'J-Sub';
    } else if (speakerName.contains('V-Sub')) {
      normalizedSpeaker = 'V-Sub';
    }
    
    // Gestion des amplis D&B
    if (amplifierName == 'D30') {
      normalizedAmp = '30D';
    } else if (amplifierName == 'D80') {
      normalizedAmp = 'D80';
    }
    
    // Récupérer les données de l'enceinte
    final speakerData = DRIVE_CAPACITY[normalizedSpeaker];
    if (speakerData == null) return null;
    
    // Récupérer les capacités pour l'ampli
    final ampData = speakerData[normalizedAmp];
    if (ampData == null) return null;
    
    return {
      'parCanal': ampData['parCanal'] as int,
      'parAmpli': ampData['parAmpli'] as int,
    };
  }

  void _calculateAmplification() {
    String resultMessage = '';
    
    if (selectedSpeakers.isEmpty) {
      resultMessage = AppLocalizations.of(context)!.soundPage_noSpeakersSelected;
    } else {
      // Grouper les enceintes par catégorie
      final Map<String, List<Map<String, dynamic>>> speakersByCategory = {};
      
      for (var speaker in selectedSpeakers) {
        final speakerName = speaker['name'] as String;
        
        // Déterminer la catégorie de l'enceinte
        String category = 'AUTRES';
        if (speakerName.toLowerCase().contains('k2') || 
            speakerName.toLowerCase().contains('kara') ||
            speakerName.toLowerCase().contains('kiva') ||
            speakerName.toLowerCase().contains('a15') ||
            speakerName.toLowerCase().contains('j8') ||
            speakerName.toLowerCase().contains('j12') ||
            speakerName.toLowerCase().contains('v8') ||
            speakerName.toLowerCase().contains('v12') ||
            speakerName.toLowerCase().contains('y8') ||
            speakerName.toLowerCase().contains('y12') ||
            speakerName.toLowerCase().contains('a8') ||
            speakerName.toLowerCase().contains('a12')) {
          category = 'LINE-ARRAY';
        } else if (speakerName.toLowerCase().contains('x8') ||
                   speakerName.toLowerCase().contains('x12') ||
                   speakerName.toLowerCase().contains('x15') ||
                   speakerName.toLowerCase().contains('m4') ||
                   speakerName.toLowerCase().contains('e8')) {
          category = 'WEDGE/POINTSOURCE';
        } else if (speakerName.toLowerCase().contains('ks28') ||
                   speakerName.toLowerCase().contains('ks21') ||
                   speakerName.toLowerCase().contains('sb18') ||
                   speakerName.toLowerCase().contains('sb118') ||
                   speakerName.toLowerCase().contains('sb218') ||
                   speakerName.toLowerCase().contains('j-sub') ||
                   speakerName.toLowerCase().contains('v-sub') ||
                   speakerName.toLowerCase().contains('b22')) {
          category = 'SUB';
        }
        
        if (!speakersByCategory.containsKey(category)) {
          speakersByCategory[category] = [];
        }
        speakersByCategory[category]!.add(speaker);
      }
      
      // Calculer pour chaque catégorie
      for (var category in ['LINE-ARRAY', 'WEDGE/POINTSOURCE', 'SUB']) {
        if (speakersByCategory.containsKey(category)) {
          resultMessage += '=== $category ===\n\n';
          
          for (var speaker in speakersByCategory[category]!) {
            final speakerName = speaker['name'] as String;
            final quantity = speaker['quantity'] as int;
            final amplifier = speaker['amplifier'] as String;
            
            // Obtenir les spécifications de l'enceinte
            final speakerSpec = speakerSpecs[speakerName];
            if (speakerSpec == null) {
              resultMessage += '⚠️ Spécifications non trouvées pour $speakerName\n';
              continue;
            }
            
            // Obtenir les spécifications de l'amplificateur
            final ampSpec = amplifierSpecs[amplifier];
            if (ampSpec == null) {
              resultMessage += '⚠️ Spécifications non trouvées pour $amplifier\n';
              continue;
            }
            
            // Calculer le nombre d'amplificateurs nécessaires
            final speakerPower = speakerSpec['power'] as int;
            final speakerImpedance = speakerSpec['impedance'] as int;
            final ampPower = ampSpec['power'] as int;
            
            // Vérifier la compatibilité d'impédance
            if (speakerImpedance < ampSpec['impedance']) {
              resultMessage += '⚠️ Impédance incompatible: $speakerName (${speakerImpedance}Ω) avec $amplifier (min ${ampSpec['impedance']}Ω)\n';
              continue;
            }
            
            // Utiliser la map de capacités pour obtenir les recommandations
            final capacity = getDriveCapacity(speakerName, amplifier);
            
            if (capacity == null) {
              resultMessage += '⚠️ Configuration non trouvée dans la base de données pour $speakerName + $amplifier\n';
              continue;
            }
            
            final speakersPerChannel = capacity['parCanal']!;
            final speakersPerAmplifier = capacity['parAmpli']!;
            
            // Calculer le nombre d'amplificateurs nécessaires
            final totalSpeakers = quantity;
            final amplifiersNeeded = (totalSpeakers / speakersPerAmplifier).ceil();
            
            resultMessage += '🔊 $speakerName (x$quantity)\n';
            resultMessage += '   ${AppLocalizations.of(context)!.soundPage_power}: ${speakerPower}W AES @ ${speakerImpedance}Ω\n';
            resultMessage += '   ${AppLocalizations.of(context)!.soundPage_amplifier}: $amplifier (${ampPower}W @ ${ampSpec['impedance']}Ω)\n';
            resultMessage += '   ${AppLocalizations.of(context)!.soundPage_capacity}: $speakersPerChannel ${AppLocalizations.of(context)!.soundPage_speakersPerChannel}, $speakersPerAmplifier ${AppLocalizations.of(context)!.soundPage_speakersPerAmp}\n';
            resultMessage += '   **${AppLocalizations.of(context)!.soundPage_amplifiersRequired}: $amplifiersNeeded**\n\n';
          }
        }
      }
    }

    ref.read(soundPageProvider.notifier).updateCalculationResult(resultMessage);
    
    // Générer une nouvelle clé unique pour ce résultat
    setState(() {
      _currentSoundResult = _generateSoundResultKey();
    });
    
    // Centrer la vue sur le résultat après le calcul
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
          alignment: 0.5,
        );
      }
    });
  }

  void _addToPreset() {
    if (selectedSpeakers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune enceinte sélectionnée'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final presetNotifier = ref.read(presetProvider.notifier);
    final selectedPresetIndex = presetNotifier.selectedPresetIndex;
    
    if (selectedPresetIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun preset sélectionné'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final preset = ref.read(presetProvider)[selectedPresetIndex];
    
    // Convertir les enceintes sélectionnées en CatalogueItem et les ajouter au preset
    for (var speaker in selectedSpeakers) {
      final speakerName = speaker['name'] as String;
      final quantity = speaker['quantity'] as int;
      
      final catalogueItem = soundItems.firstWhere(
        (item) => item.produit == speakerName,
        orElse: () => throw Exception('Item non trouvé: $speakerName'),
      );
      
      final existingIndex = preset.items.indexWhere(
        (item) => item.item.id == catalogueItem.id,
      );
      
      if (existingIndex != -1) {
        preset.items[existingIndex] = CartItem(
          item: catalogueItem,
          quantity: quantity,
        );
      } else {
        preset.items.add(
          CartItem(
            item: catalogueItem,
            quantity: quantity,
          ),
        );
      }
    }
    
    presetNotifier.updatePreset(preset);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedSpeakers.length} enceinte(s) ajoutée(s) au preset'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _resetSelection() {
    ref.read(soundPageProvider.notifier).updateSelectedSpeakers([]);
    ref.read(soundPageProvider.notifier).clearCalculationResult();
    
    // Effacer le commentaire du résultat précédent
    if (_currentSoundResult.isNotEmpty) {
      _comments.remove(_currentSoundResult);
      _saveComments();
    }
    
    // Forcer la mise à jour de l'interface
    setState(() {
      _currentSoundResult = '';
    });
  }

  void _showQuantityDialog(BuildContext context, String speaker) {
    final loc = AppLocalizations.of(context)!;
    
    // Obtenir les amplificateurs disponibles selon la marque de l'enceinte
    final availableAmplifiers = getAvailableAmplifiers(speaker);
    
    // Obtenir la catégorie de l'enceinte pour le choix par défaut
    final speakerItem = soundItems.firstWhere(
      (item) => item.produit == speaker,
      orElse: () => throw Exception('Enceinte non trouvée: $speaker'),
    );
    final speakerCategory = speakerItem.sousCategorie;
    
    // Obtenir l'amplificateur par défaut
    final defaultAmplifier = getDefaultAmplifier(speaker, speakerCategory);
    
    String? selectedAmplifier = defaultAmplifier;
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              title: Text('${loc.soundPage_quantity} $speaker',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                    fontSize: 16,
                  )),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contrôleur de quantité avec boutons - et +
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: const Icon(Icons.remove, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          final textController = TextEditingController(text: quantity.toString());
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.blueGrey[900],
                              title: Text('Modifier la quantité',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                  )),
                              content: TextField(
                                controller: textController,
                    keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                ),
                    decoration: InputDecoration(
                                  hintText: 'Quantité',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white70 : null,
                                  ),
                      enabledBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white70),
                      ),
                      focusedBorder: const UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.white),
                      ),
                    ),
                                autofocus: true,
                                onTap: () {
                                  textController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: textController.text.length,
                                  );
                                },
                                onSubmitted: (value) {
                                  final newQuantity = int.tryParse(value) ?? 1;
                                  if (newQuantity > 0) {
                                    setDialogState(() {
                                      quantity = newQuantity;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Annuler',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                      )),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final newQuantity = int.tryParse(textController.text) ?? 1;
                                    if (newQuantity > 0) {
                                      setDialogState(() {
                                        quantity = newQuantity;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text('Confirmer',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                      )),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey[600]!),
                          ),
                          child: Text(
                            quantity.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                          });
                        },
                        icon: const Icon(Icons.add, color: Colors.white, size: 24),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BorderLabeledDropdown<String>(
                    label: AppLocalizations.of(context)!.amplifier,
                    value: selectedAmplifier,
                    items: availableAmplifiers.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(fontSize: 11)),
                    )).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedAmplifier = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.catalogPage_cancel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                      )),
                ),
                TextButton(
                  onPressed: () {
                    final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                    newSpeakers.add({
                      'name': speaker,
                      'quantity': quantity,
                      'amplifier': selectedAmplifier,
                    });
                    ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                    ref.read(soundPageProvider.notifier).updateSearchResults([]);
                    ref.read(soundPageProvider.notifier).updateSearchQuery('');
                    _searchController.clear();
                    Navigator.pop(context);
                    
                    // Centrer la vue sur les boutons après avoir ajouté une enceinte
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_buttonsKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _buttonsKey.currentContext!,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          alignment: 0.5,
                        );
                      }
                    });
                  },
                  child: Text(loc.catalogPage_confirm,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                      )),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _performSearch() {
    if (searchQuery.isEmpty) {
      ref.read(soundPageProvider.notifier).updateSearchResults([]);
      return;
    }

    final allItems = ref.watch(catalogueProvider);
    final results = allItems.where((item) {
      if (item.categorie != 'Son') return false;
      
      if (selectedBrand != null && selectedBrand != 'Toutes') {
        if (!item.marque.toLowerCase().contains(selectedBrand!.toLowerCase())) {
          return false;
        }
      }
      
      if (selectedCategory != null && selectedCategory != 'Toutes') {
        final productName = item.produit.toLowerCase();
        
        switch (selectedCategory) {
          case 'Line-Array':
            if (!productName.contains('line') && 
                !productName.contains('array') && 
                !productName.contains('kiva') && 
                !productName.contains('kara') &&
                !productName.contains('k2') &&
                !productName.contains('syva')) {
              return false;
            }
            break;
          case 'Wedge/Pointsource':
            if (!productName.contains('wedge') && 
                !productName.contains('point') && 
                !productName.contains('x8') && 
                !productName.contains('x12') &&
                !productName.contains('x15')) {
              return false;
            }
            break;
          case 'Sub':
            if (!productName.contains('sub') && 
                !productName.contains('sb') && 
                !productName.contains('ks28')) {
              return false;
            }
            break;
          case 'Ampli':
            if (!productName.contains('ampli') && 
                !productName.contains('la') && 
                !productName.contains('amplifier')) {
              return false;
            }
            break;
        }
      }
      
      return item.marque.toLowerCase().contains(searchQuery.toLowerCase()) ||
             item.produit.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    
    ref.read(soundPageProvider.notifier).updateSearchResults(results);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
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
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              child: Stack(
                children: [
                  Column(
                    children: [
                      // Barre de recherche
                      TextField(
                        controller: _searchController,
                        textDirection: TextDirection.ltr,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                          hintText: AppLocalizations.of(context)!.search_speaker,
                          hintStyle: Theme.of(context).textTheme.bodyMedium,
                          prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
                          filled: true,
                          fillColor: Colors.transparent,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12),
                          isDense: true,
                        ),
                        onChanged: (value) {
                          ref.read(soundPageProvider.notifier).updateSearchQuery(value);
                          _performSearch();
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Menus déroulants
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.brand,
                          value: selectedBrand,
                          items: availableBrands.map((brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            ref.read(soundPageProvider.notifier).updateSelectedBrand(newValue);
                            if (searchQuery.isNotEmpty) {
                              _performSearch();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.category,
                          value: selectedCategory,
                          items: soundCategories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            ref.read(soundPageProvider.notifier).updateSelectedCategory(newValue);
                            if (searchQuery.isNotEmpty) {
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                      
                      // Menu enceinte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.speaker,
                          value: selectedSpeaker,
                          items: filteredSoundItems.map((CatalogueItem item) => DropdownMenuItem(
                            value: item.produit,
                            child: Text(item.produit, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _showQuantityDialog(context, newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                      
                  // Bouton Import Preset
                  Center(
                    child: ElevatedButton(
                          onPressed: () {
                            // Logique d'import preset
                          },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1565C0),
                            side: const BorderSide(color: Color(0xFF1976D2), width: 1),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                          child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.download, color: Colors.white, size: 16),
                          SizedBox(width: 8),
                          Text(
                            'Import Preset',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                      const SizedBox(height: 16),
                      
                      // Enceintes sélectionnées
                  if (selectedSpeakers.isNotEmpty) ...[
                    Text('Enceintes sélectionnées :',
                        style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedSpeakers.length,
                      itemBuilder: (context, index) {
                        final speaker = selectedSpeakers[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(vertical: 4),
                              color: const Color(0xFF0A1128).withOpacity(0.3),
                              child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                            children: [
                                    Text(
                                      speaker['name'],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                              IconButton(
                                          icon: const Icon(Icons.remove, color: Colors.white, size: 20),
                                onPressed: () {
                                  if (speaker['quantity'] > 1) {
                                    final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                                    newSpeakers[index]['quantity'] = (speaker['quantity'] as int) - 1;
                                    ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                                  }
                                },
                              ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                '${speaker['quantity']}',
                                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                              fontWeight: FontWeight.bold,
                              ),
                                          ),
                                        ),
                              IconButton(
                                          icon: const Icon(Icons.add, color: Colors.white, size: 20),
                                onPressed: () {
                                  final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                                  newSpeakers[index]['quantity'] = (speaker['quantity'] as int) + 1;
                                  ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                                },
                              ),
                              const SizedBox(width: 8),
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () {
                              final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                              newSpeakers.removeAt(index);
                              ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                            },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                          ),
                        );
                      },
                    ),
                        const SizedBox(height: 16),
                      ],
                      
                      // Boutons icônes
                      Row(
                        key: _buttonsKey,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            onPressed: _addToPreset,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.add,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 25),
                          ElevatedButton(
                            onPressed: _calculateAmplification,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.calculate,
                                color: Colors.white, size: 28),
                          ),
                          const SizedBox(width: 25),
                          ElevatedButton(
                            onPressed: _resetSelection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueGrey[900],
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(12),
                            ),
                            child: const Icon(Icons.refresh,
                                color: Colors.white, size: 28),
                          ),
                        ],
                      ),
                      
                      // RÉSULTAT DE CALCUL - EN DESSOUS DES 3 BOUTONS
                      if (calculationResult != null) ...[
                        const SizedBox(height: 16),
                    Container(
                          key: _resultKey,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                            color: const Color(0xFF0A1128).withOpacity(0.5),
                            border: Border.all(color: const Color(0xFF0A1128), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                              Center(
                                child: Text(
                                  AppLocalizations.of(context)!.soundPage_ampConfigTitle,
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                          Text(
                            calculationResult!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Commentaire utilisateur (au-dessus des boutons)
                          if (_getCommentForTab('sound_tab').isNotEmpty) ...[
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
                                    _getCommentForTab('sound_tab'),
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
                                onPressed: () => _showCommentDialog('sound_tab', 'AMP'),
                                iconSize: 28,
                              ),
                              const SizedBox(width: 20),
                              // Bouton Export (rotated)
                              ExportWidget(
                                title: 'Configuration Amplification',
                                content: calculationResult!,
                                projectType: 'sound',
                                fileName: 'configuration_amplification',
                                customIcon: Icons.cloud_upload,
                                backgroundColor: Colors.blueGrey[900],
                                tooltip: 'Exporter la configuration',
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                      ],
                    ],
                  ),
                  
                  // Résultats de recherche en volant
                  if (searchResults.isNotEmpty)
                    Positioned(
                      top: 50,
                      left: 0,
                      right: 0,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF0A1128).withOpacity(0.95)
                              : Colors.white.withOpacity(0.95),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white
                                  : Colors.black,
                              width: 1),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
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
                                _showQuantityDialog(context, item.produit);
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${item.marque} - ${item.produit}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                    Text(
                                      item.sousCategorie,
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('sound_comments');
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
      await prefs.setString('sound_comments', json.encode(_comments));
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
    }
  }

  String _getCommentForTab(String tabKey) {
    if (tabKey == 'sound_tab') {
      // Pour l'onglet son, utiliser la clé unique du résultat
      return _comments[_currentSoundResult] ?? '';
    } else {
      // Pour les autres onglets, utiliser le système normal
      return _comments[tabKey] ?? '';
    }
  }

  String _generateSoundResultKey() {
    // Générer une clé unique basée sur les paramètres du calcul son
    final selectedSpeakers = soundState.selectedSpeakers;
    final speakerNames = selectedSpeakers.map((s) => s['name'] as String).join('_');
    final quantities = selectedSpeakers.map((s) => s['quantity'] as int).join('_');
    final category = soundState.selectedCategory ?? 'none';
    final brand = soundState.selectedBrand ?? 'none';
    return 'sound_${speakerNames}_${quantities}_${category}_${brand}';
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
                
                if (tabKey == 'sound_tab') {
                  // Pour l'onglet son, utiliser la clé unique du résultat
                  commentKey = _currentSoundResult;
                } else {
                  // Pour les autres onglets, utiliser le système normal
                  commentKey = tabKey;
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