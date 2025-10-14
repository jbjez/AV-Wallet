// lib/pages/structure_menu_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'home_page.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import '../widgets/uniform_bottom_nav_bar.dart';
import '../widgets/border_labeled_dropdown.dart';

class StructureMenuPage extends StatefulWidget {
  const StructureMenuPage({super.key});

  @override
  State<StructureMenuPage> createState() => _StructureMenuPageState();
}

class _StructureMenuPageState extends State<StructureMenuPage> {
  String selectedStructure = 'SC300';
  double distance = 6;
  String selectedCharge = '1 point d\'accroche au centre';

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
    19: {'Q': 11,   'P1': 71,   'P2': 54,   'P3': 43,  'P4': 35,  'SW': 146, 'deflection': 63},
    20: {'Q': 8,    'P1': 42,   'P2': 38,   'P3': 31,  'P4': 26,  'SW': 154, 'deflection': 67},
  },
  'SC500': {
      1: {'Q': 4240, 'P1': 2860, 'P2': 1910, 'P3': 1430, 'P4': 1072, 'SW': 18, 'deflection': 3},
      2: {'Q': 4240, 'P1': 2860, 'P2': 1910, 'P3': 1430, 'P4': 1072, 'SW': 37, 'deflection': 7},
      3: {'Q': 1413, 'P1': 2860, 'P2': 1910, 'P3': 1430, 'P4': 1072, 'SW': 55, 'deflection': 10},
      4: {'Q': 795, 'P1': 2145, 'P2': 1430, 'P3': 1072, 'P4': 804, 'SW': 74, 'deflection': 13},
      5: {'Q': 509, 'P1': 1716, 'P2': 1144, 'P3': 858, 'P4': 643, 'SW': 92, 'deflection': 17},
      6: {'Q': 353, 'P1': 1430, 'P2': 954, 'P3': 715, 'P4': 536, 'SW': 111, 'deflection': 20},
      7: {'Q': 259, 'P1': 1226, 'P2': 817, 'P3': 613, 'P4': 460, 'SW': 129, 'deflection': 23},
      8: {'Q': 199, 'P1': 1072, 'P2': 715, 'P3': 536, 'P4': 402, 'SW': 148, 'deflection': 27},
      9: {'Q': 157, 'P1': 954, 'P2': 636, 'P3': 477, 'P4': 357, 'SW': 166, 'deflection': 30},
      10: {'Q': 127, 'P1': 858, 'P2': 572, 'P3': 429, 'P4': 321, 'SW': 185, 'deflection': 33},
      11: {'Q': 105, 'P1': 780, 'P2': 520, 'P3': 390, 'P4': 292, 'SW': 203, 'deflection': 37},
      12: {'Q': 88, 'P1': 715, 'P2': 477, 'P3': 357, 'P4': 268, 'SW': 222, 'deflection': 40},
      13: {'Q': 75, 'P1': 660, 'P2': 440, 'P3': 330, 'P4': 247, 'SW': 240, 'deflection': 43},
      14: {'Q': 65, 'P1': 612, 'P2': 408, 'P3': 306, 'P4': 229, 'SW': 259, 'deflection': 47},
      15: {'Q': 1950, 'P1': 1080, 'P2': 810, 'P3': 540, 'P4': 405, 'SW': 277, 'deflection': 84},
      16: {'Q': 1490, 'P1': 860, 'P2': 550, 'P3': 390, 'P4': 293, 'SW': 296, 'deflection': 116},
      17: {'Q': 930, 'P1': 580, 'P2': 340, 'P3': 240, 'P4': 180, 'SW': 314, 'deflection': 135},
      18: {'Q': 540, 'P1': 340, 'P2': 200, 'P3': 140, 'P4': 105, 'SW': 333, 'deflection': 154},
      19: {'Q': 320, 'P1': 200, 'P2': 120, 'P3': 80, 'P4': 60, 'SW': 351, 'deflection': 173},
      20: {'Q': 200, 'P1': 120, 'P2': 70, 'P3': 50, 'P4': 38, 'SW': 370, 'deflection': 200},
    },
  'E20D': {
    1:  {'Q': 400, 'P1': 180, 'P2': 130, 'P3': 100, 'P4': 80, 'SW': 1.6, 'deflection': 3}, // Extrapolé
    2:  {'Q': 340, 'P1': 150, 'P2': 110, 'P3': 85, 'P4': 68, 'SW': 1.6, 'deflection': 6}, // Extrapolé
    3:  {'Q': 292, 'P1': 126, 'P2': 88, 'P3': 68, 'P4': 54, 'SW': 1.6, 'deflection': 10},
    4:  {'Q': 216, 'P1': 97,  'P2': 69, 'P3': 51, 'P4': 41, 'SW': 1.6, 'deflection': 18},
    5:  {'Q': 170, 'P1': 78,  'P2': 56, 'P3': 41, 'P4': 33, 'SW': 1.6, 'deflection': 28},
    6:  {'Q': 139, 'P1': 65,  'P2': 47, 'P3': 34, 'P4': 27, 'SW': 1.6, 'deflection': 40},
    7:  {'Q': 117, 'P1': 55,  'P2': 40, 'P3': 28, 'P4': 23, 'SW': 1.6, 'deflection': 54},
    8:  {'Q': 99,  'P1': 47,  'P2': 35, 'P3': 24, 'P4': 20, 'SW': 1.6, 'deflection': 71},
    9:  {'Q': 86,  'P1': 41,  'P2': 30, 'P3': 21, 'P4': 17, 'SW': 1.6, 'deflection': 89},
    10: {'Q': 74,  'P1': 36,  'P2': 27, 'P3': 18, 'P4': 15, 'SW': 1.6, 'deflection': 110},
    11: {'Q': 65,  'P1': 31,  'P2': 24, 'P3': 16, 'P4': 13, 'SW': 1.6, 'deflection': 133},
    12: {'Q': 56,  'P1': 28,  'P2': 21, 'P3': 14, 'P4': 12, 'SW': 1.6, 'deflection': 159},
    13: {'Q': 49,  'P1': 24,  'P2': 18, 'P3': 12, 'P4': 10, 'SW': 1.6, 'deflection': 186},
    14: {'Q': 43,  'P1': 21,  'P2': 16, 'P3': 11, 'P4': 9,  'SW': 1.6, 'deflection': 216},
    15: {'Q': 38,  'P1': 18,  'P2': 14, 'P3': 9,  'P4': 8,  'SW': 1.6, 'deflection': 248},
    16: {'Q': 32,  'P1': 16,  'P2': 12, 'P3': 8,  'P4': 7,  'SW': 1.6, 'deflection': 282},
    17: {'Q': 27,  'P1': 14,  'P2': 10, 'P3': 7,  'P4': 6,  'SW': 1.6, 'deflection': 319},
    18: {'Q': 23,  'P1': 12,  'P2': 9,  'P3': 6,  'P4': 5,  'SW': 1.6, 'deflection': 357},
  },
  };

  final Map<String, double> coeffCharge = {
    '1 point d\'accroche au centre': 1.0,
    '2 points d\'accroche aux extrémités': 1.0,
    'Charge répartie uniformément': 1.0,
  };

  late final List<String> chargeOptions = coeffCharge.keys.toList();
  late final List<String> structureOptions = ['SC300', 'SC390', 'SC500', 'E20D'];

  // Obtenir les données pour la structure et la portée sélectionnées
  Map<String, double> get currentData {
    final span = distance.round();
    return structureData[selectedStructure]?[span] ?? {};
  }

  double get poidsStructure => currentData['SW'] ?? 0;
  
  double get chargeMaximale {
    final data = currentData;
    if (data.isEmpty) return 0;
    
    switch (selectedCharge) {
      case '1 point d\'accroche au centre':
        return data['P1'] ?? 0;
      case '2 points d\'accroche aux extrémités':
        return data['P2'] ?? 0;
      case 'Charge répartie uniformément':
        return data['Q'] ?? 0;
      default:
        return 0;
    }
  }
  
  double get flecheReelle => currentData['deflection'] ?? 0;
  
  String get unitCharge => selectedCharge == 'Charge répartie uniformément' ? ' kg/m' : ' kg/pt';

  // Méthode d'export des résultats
  void _exportResults() {
    final data = currentData;
    if (data.isEmpty) return;
    
    final exportText = '''
RÉSULTATS CALCUL STRUCTURE
========================

Structure: $selectedStructure
Portée: ${distance.round()}m
Type de charge: $selectedCharge

RÉSULTATS:
----------
Charge maximale: ${chargeMaximale.toStringAsFixed(0)}$unitCharge
Poids structure: ${poidsStructure.toStringAsFixed(0)} kg
Flèche: ${flecheReelle.toStringAsFixed(0)} mm
Ratio préconisé: 1/300e

DONNÉES CONSTRUCTEUR:
-------------------
Charge répartie: ${data['Q']?.toStringAsFixed(0) ?? 'N/A'} kg/m
1 point: ${data['P1']?.toStringAsFixed(0) ?? 'N/A'} kg
2 points: ${data['P2']?.toStringAsFixed(0) ?? 'N/A'} kg/pt
3 points: ${data['P3']?.toStringAsFixed(0) ?? 'N/A'} kg/pt
4 points: ${data['P4']?.toStringAsFixed(0) ?? 'N/A'} kg/pt

Généré le: ${DateTime.now().toString().split('.')[0]}
''';

    // Afficher les résultats dans un dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Résultats d\'export'),
        content: SingleChildScrollView(
          child: SelectableText(exportText),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      body: Stack(
        children: [
          // Background image
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
                // Header
                Container(
                  color: Colors.black.withOpacity(0.4),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                      Text(
                        loc.structurePage_title,
                        style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                // Home icon
                IconButton(
                  icon: const Icon(Icons.home, color: Colors.white),
                  onPressed: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
                ),
                // Logo
                GestureDetector(
                  onTap: () => Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomePage()),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.4),
                      border: Border.all(color: Colors.white, width: 2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Image.asset('assets/Logo2.png', height: 60),
                  ),
                ),
                // Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(5),
                    child: SingleChildScrollView(
                      child: Container(
                        padding: const EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128).withOpacity(0.5),
                          border: Border.all(color: const Color(0xFF0A1128), width: 2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Structure selector
                            BorderLabeledDropdown<String>(
                              label: loc.selectStructure,
                              value: selectedStructure,
                              items: structureOptions
                                  .map((s) => DropdownMenuItem(
                                    value: s, 
                                    child: Text(s, style: const TextStyle(fontSize: 11))
                                  ))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedStructure = v!),
                            ),
                            const SizedBox(height: 12),
                            // Distance slider
                            Text(loc.distance_label(distance.round().toString()), style: const TextStyle(color: Colors.white)),
                            Slider(
                              value: distance,
                              min: 1,
                              max: 20,
                              divisions: 19,
                              label: loc.distance_label(distance.round().toString()),
                              onChanged: (v) => setState(() => distance = v),
                            ),
                            const SizedBox(height: 12),
                            // Charge selector
                            BorderLabeledDropdown<String>(
                              label: 'Type de charge',
                              value: selectedCharge,
                              items: chargeOptions
                                  .map((c) => DropdownMenuItem(
                                    value: c, 
                                    child: Text(c, style: const TextStyle(fontSize: 11))
                                  ))
                                  .toList(),
                              onChanged: (v) => setState(() => selectedCharge = v!),
                            ),
                            const SizedBox(height: 16),
                            // Bouton calcul
                            Center(
                              child: ElevatedButton(
                                onPressed: () {
                                  // Les calculs se font automatiquement, mais on peut forcer un rebuild
                                  setState(() {});
                                },
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
                            ),
                            const SizedBox(height: 16),
                            // Results
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0xFF0A1128).withOpacity(0.7),
                                border: Border.all(color: const Color(0xFF0A1128), width: 2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Charge maximale selon le type sélectionné
                                  Text('Charge maximale: ${chargeMaximale.toStringAsFixed(0)}$unitCharge', 
                                       style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14)),
                                  const SizedBox(height: 8),
                                  
                                  // Poids de la structure
                                  Text('Poids structure: ${poidsStructure.toStringAsFixed(0)} kg', 
                                       style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  
                                  // Flèche réelle
                                  Text('Flèche: ${flecheReelle.toStringAsFixed(0)} mm', 
                                       style: const TextStyle(color: Colors.white)),
                                  const SizedBox(height: 8),
                                  
                                  // Taux de flèche
                                  Text('Ratio préconisé: 1/300e', 
                                       style: const TextStyle(fontSize: 12, color: Colors.orange)),
                                  const SizedBox(height: 8),
                                  
                                  // Widget d'export
                                  const SizedBox(height: 12),
                                  Container(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: () => _exportResults(),
                                      icon: const Icon(Icons.download, color: Colors.white),
                                      label: const Text('Exporter les résultats', style: TextStyle(color: Colors.white)),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: const Color(0xFF0A1128),
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
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
}
