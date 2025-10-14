import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/preset_widget.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/preset.dart';

class AmpliCalcPage extends ConsumerStatefulWidget {
  const AmpliCalcPage({super.key});

  @override
  ConsumerState<AmpliCalcPage> createState() => _AmpliCalcPageState();
}

class _AmpliCalcPageState extends ConsumerState<AmpliCalcPage> {
  final TextEditingController _presetNameController = TextEditingController();
  final List<Map<String, dynamic>> _speakers = [];
  final List<Map<String, dynamic>> savedPresets = [];
  String _query = '';
  Preset? _currentPreset;
  final List<_SelectedItem> _selectedItems = [];

  final List<String> availableSpeakers = [
    'K1',
    'K2',
    'Kara II',
    'Kara',
    'KS28',
    'SB18',
    'A15 Focus',
    'A15 Wide',
    'A15 Focus',
    'A15 Wide',
    '5XT',
    'X8',
    'X12',
    'X15 HiQ',
    'Syva',
    'Syva Low',
  ];

  // Table de puissance nominale des enceintes (en Watts RMS)
  final Map<String, int> speakerPowerMap = {
    // Enceintes de scène principales
    'K1': 1500,
    'K2': 1200,
    'Kara II': 700,
    'Kara': 700,
    'KS28': 1500,
    'SB18': 1000,
    'A15 Focus': 1000,
    'A15 Wide': 1000,
    
    // Enceintes de ligne
    '5XT': 100,
    'X8': 300,
    'X12': 600,
    'X15 HiQ': 1100,
    
    // Enceintes de monitoring
    'Syva': 600,
    'Syva Low': 1200,
    
    // Enceintes de retour
    'Kiva II': 800,
    'Kiva': 800,
    'Kilo': 800,
    'X15': 800,
    'SB15M': 800,
    'SB118': 800,
    'SB218': 800,
  };

  // Spécifications des amplificateurs
  final Map<String, Map<String, dynamic>> amplifierSpecs = {
    'LA4X': {
      'powerPerChannel': 1000,    // W par canal @ 8Ω
      'totalPower': 4000,         // W total
      'channels': 4,              // Nombre de canaux
      'impedance': 8,             // Ω
      'efficiency': 0.85,         // Rendement
      'cost': 1.0,                // Coût relatif (base)
    },
    'LA8': {
      'powerPerChannel': 1800,    // W par canal @ 8Ω
      'totalPower': 7200,         // W total
      'channels': 4,              // Nombre de canaux
      'impedance': 8,             // Ω
      'efficiency': 0.88,         // Rendement
      'cost': 1.5,                // Coût relatif
    },
    'LA12X': {
      'powerPerChannel': 3300,    // W par canal @ 8Ω
      'totalPower': 13200,        // W total
      'channels': 4,              // Nombre de canaux
      'impedance': 8,             // Ω
      'efficiency': 0.90,         // Rendement
      'cost': 2.2,                // Coût relatif
    },
  };

  void _addSpeaker() {
    setState(() {
      _speakers.add({'type': null, 'quantity': 1});
    });
  }

  void _removeSpeaker(int index) {
    setState(() {
      _speakers.removeAt(index);
    });
  }

  // Méthode de calcul optimisée pour déterminer la meilleure combinaison d'amplis
  void _calculateRack() {
    if (_speakers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ajoutez d\'abord des enceintes pour calculer l\'amplification'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Calculer la puissance totale nécessaire
    int totalPowerNeeded = 0;
    Map<String, int> speakerBreakdown = {};
    
    for (var speaker in _speakers) {
      final type = speaker['type'];
      final qty = speaker['quantity'];

      if (type != null && speakerPowerMap.containsKey(type)) {
        final power = speakerPowerMap[type]! * qty;
        totalPowerNeeded += power.round();
        speakerBreakdown[type] = (speakerBreakdown[type] ?? 0) + qty;
      }
    }

    if (totalPowerNeeded == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune enceinte valide trouvée pour le calcul'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Calculer la marge de sécurité (20% pour éviter la surcharge)
    final powerWithMargin = (totalPowerNeeded * 1.2).ceil().toInt();
    
    // Déterminer la meilleure combinaison d'amplis
    final recommendation = _calculateOptimalAmplifierCombination(powerWithMargin);
    
    // Construire le message de résultat détaillé
    final resultMessage = _buildDetailedResultMessage(
      totalPowerNeeded,
      powerWithMargin,
      speakerBreakdown,
      recommendation,
    );

    // Afficher le résultat
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          resultMessage,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[700],
        duration: const Duration(seconds: 8),
      ),
    );
  }

  // Méthode pour calculer la combinaison optimale d'amplificateurs
  Map<String, dynamic> _calculateOptimalAmplifierCombination(int powerNeeded) {
    final combinations = <Map<String, dynamic>>[];
    
    // Calculer les limites maximales pour chaque type d'amplificateur
    final maxLA4X = (powerNeeded / amplifierSpecs['LA4X']!['totalPower']).ceil().toInt();
    final maxLA8 = (powerNeeded / amplifierSpecs['LA8']!['totalPower']).ceil().toInt();
    final maxLA12X = (powerNeeded / amplifierSpecs['LA12X']!['totalPower']).ceil().toInt();
    
    // Essayer toutes les combinaisons possibles
    for (int la4x = 0; la4x <= maxLA4X; la4x++) {
      for (int la8 = 0; la8 <= maxLA8; la8++) {
        for (int la12x = 0; la12x <= maxLA12X; la12x++) {
          final totalPower = (la4x * amplifierSpecs['LA4X']!['totalPower']) +
                           (la8 * amplifierSpecs['LA8']!['totalPower']) +
                           (la12x * amplifierSpecs['LA12X']!['totalPower']);
          
          if (totalPower >= powerNeeded) {
            final totalCost = (la4x * amplifierSpecs['LA4X']!['cost']) +
                            (la8 * amplifierSpecs['LA8']!['cost']) +
                            (la12x * amplifierSpecs['LA12X']!['cost']);
            
            final efficiency = _calculateCombinationEfficiency(la4x, la8, la12x, powerNeeded);
            
            combinations.add({
              'LA4X': la4x,
              'LA8': la8,
              'LA12X': la12x,
              'totalPower': totalPower,
              'totalCost': totalCost,
              'efficiency': efficiency,
              'overhead': totalPower - powerNeeded,
            });
          }
        }
      }
    }
    
    if (combinations.isEmpty) {
      // Fallback : utiliser seulement des LA12X
      final la12xCount = (powerNeeded / amplifierSpecs['LA12X']!['totalPower']).ceil().toInt();
      return {
        'LA4X': 0,
        'LA8': 0,
        'LA12X': la12xCount,
        'totalPower': la12xCount * amplifierSpecs['LA12X']!['totalPower'],
        'totalCost': la12xCount * amplifierSpecs['LA12X']!['cost'],
        'efficiency': 1.0,
        'overhead': (la12xCount * amplifierSpecs['LA12X']!['totalPower']) - powerNeeded,
      };
    }
    
    // Trier par coût, puis par efficacité, puis par overhead minimal
    combinations.sort((a, b) {
      if ((a['totalCost'] - b['totalCost']).abs() > 0.1) {
        return a['totalCost'].compareTo(b['totalCost']);
      }
      if ((a['efficiency'] - b['efficiency']).abs() > 0.01) {
        return b['efficiency'].compareTo(a['efficiency']);
      }
      return a['overhead'].compareTo(b['overhead']);
    });
    
    return combinations.first;
  }

  // Calculer l'efficacité de la combinaison
  double _calculateCombinationEfficiency(int la4x, int la8, int la12x, int powerNeeded) {
    if (la4x + la8 + la12x == 0) return 0.0;
    
    final totalPower = (la4x * amplifierSpecs['LA4X']!['totalPower']) +
                       (la8 * amplifierSpecs['LA8']!['totalPower']) +
                       (la12x * amplifierSpecs['LA12X']!['totalPower']);
    
    // Efficacité basée sur l'utilisation de la puissance
    final powerUtilization = powerNeeded / totalPower;
    
    // Bonus pour les combinaisons équilibrées
    final balanceBonus = _calculateBalanceBonus(la4x, la8, la12x);
    
    return (powerUtilization * 0.7) + (balanceBonus * 0.3);
  }

  // Bonus pour les combinaisons équilibrées
  double _calculateBalanceBonus(int la4x, int la8, int la12x) {
    final total = la4x + la8 + la12x;
    if (total == 0) return 0.0;
    
    // Bonus pour utiliser moins de types d'amplis différents
    final typeVariety = [la4x, la8, la12x].where((count) => count > 0).length;
    final varietyBonus = 1.0 - (typeVariety - 1) * 0.1;
    
    // Bonus pour les combinaisons logiques (LA4X pour petites charges, LA12X pour grosses)
    double logicBonus = 1.0;
    if (la4x > 0 && la12x > 0 && la8 == 0) {
      logicBonus = 0.9; // Éviter de mélanger LA4X et LA12X sans LA8
    }
    
    return varietyBonus * logicBonus;
  }

  // Construire le message de résultat détaillé
  String _buildDetailedResultMessage(
    int powerNeeded,
    int powerWithMargin,
    Map<String, int> speakerBreakdown,
    Map<String, dynamic> recommendation,
  ) {
    final buffer = StringBuffer();
    
    buffer.writeln('🎵 **CALCUL AMPLIFICATION**');
    buffer.writeln('');
    
    // Détail des enceintes
    buffer.writeln('📻 **Enceintes sélectionnées :**');
    speakerBreakdown.forEach((speaker, qty) {
      final power = speakerPowerMap[speaker]! * qty;
      buffer.writeln('  • $qty x $speaker = ${power}W');
    });
    
    buffer.writeln('');
    buffer.writeln('⚡ **Puissance totale : ${powerNeeded}W**');
    buffer.writeln('🛡️ **Avec marge de sécurité (20%) : ${powerWithMargin}W**');
    buffer.writeln('');
    
    // Recommandation d'amplification
    buffer.writeln('🔊 **RECOMMANDATION :**');
    
    final la4x = recommendation['LA4X'] as int;
    final la8 = recommendation['LA8'] as int;
    final la12x = recommendation['LA12X'] as int;
    
    final parts = <String>[];
    if (la4x > 0) parts.add('${la4x}x LA4X');
    if (la8 > 0) parts.add('${la8}x LA8');
    if (la12x > 0) parts.add('${la12x}x LA12X');
    
    if (parts.isEmpty) {
      buffer.writeln('  ❌ Aucun amplificateur nécessaire');
    } else {
      buffer.writeln('  ✅ ${parts.join(' + ')}');
    }
    
    buffer.writeln('');
    buffer.writeln('📊 **Détails techniques :**');
    buffer.writeln('  • Puissance disponible : ${recommendation['totalPower']}W');
    buffer.writeln('  • Marge de sécurité : ${recommendation['overhead']}W');
    buffer.writeln('  • Efficacité : ${(recommendation['efficiency'] * 100).toStringAsFixed(1)}%');
    
    return buffer.toString();
  }

  void _newPreset() {
    setState(() {
      _presetNameController.clear();
      _speakers.clear();
    });
  }

  void _saveCurrentPreset() {
    if (_presetNameController.text.isNotEmpty && _speakers.isNotEmpty) {
      savedPresets.add({
        'name': _presetNameController.text,
        'speakers': List.from(_speakers),
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Preset enregistré !')),
      );
    }
  }

  void _showSavedPresets() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.blueGrey[800],
        title: const Text('Presets enregistrés',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            itemCount: savedPresets.length,
            itemBuilder: (context, index) {
              final preset = savedPresets[index];
              return ListTile(
                title: Text(preset['name'],
                    style: const TextStyle(color: Colors.white)),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _query.isEmpty
        ? <CatalogueItem>[]
        : ref.watch(catalogueProvider)
            .where((item) => item.produit.toLowerCase().startsWith(_query))
            .toList();
    final totalQty =
        _selectedItems.fold<int>(0, (sum, sel) => sum + sel.quantity);

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1) Sélection du preset avec badge intégré
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  PresetWidget(
                    loadOnInit: true,
                    onPresetSelected: (preset) {
                      setState(() {
                        _currentPreset = preset;
                        _selectedItems.clear();
                      });
                    },
                  ),
                  if (totalQty > 0)
                    Positioned(
                      top: -4,
                      right: -4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$totalQty',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const Divider(),

            // 2) Barre de recherche
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Recherche par nom',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onChanged: (str) => setState(() => _query = str.toLowerCase()),
              ),
            ),
            const SizedBox(height: 12),

            // 3) Affichage des items sélectionnés
            if (_selectedItems.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Sélection de ${_currentPreset?.name ?? ''}',
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _selectedItems.length,
                  itemBuilder: (context, idx) {
                    final sel = _selectedItems[idx];
                    return Card(
                      margin: const EdgeInsets.only(right: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(sel.item.produit),
                            Text('Qté: ${sel.quantity}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Divider(),
            ],

            // 4) Liste des résultats de recherche
            Expanded(
              child: filteredItems.isEmpty
                  ? const Center(
                      child: Text(
                        'Aucun résultat',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredItems.length,
                      itemBuilder: (context, index) {
                        final item = filteredItems[index];
                        return ListTile(
                          title: Text(item.produit),
                          subtitle: Text(item.marque),
                          onTap: () => _showQuantityDialog(item),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// Popup pour saisir quantité et synchroniser dans le preset
  void _showQuantityDialog(CatalogueItem item) {
    final qtyController = TextEditingController(text: '1');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quantité pour "${item.produit}"'),
        content: TextField(
          controller: qtyController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(labelText: 'Quantité'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              final qty = int.tryParse(qtyController.text) ?? 1;
              setState(() {
                final idx = _selectedItems
                    .indexWhere((sel) => sel.item.produit == item.produit);
                if (idx >= 0) {
                  _selectedItems[idx] =
                      _SelectedItem(item, _selectedItems[idx].quantity + qty);
                } else {
                  _selectedItems.add(_SelectedItem(item, qty));
                }
              });
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

/// Modèle interne pour gérer les items sélectionnés avec quantité
class _SelectedItem {
  final CatalogueItem item;
  final int quantity;
  _SelectedItem(this.item, this.quantity);
}
