import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';

class TestOpticsSelectionPage extends ConsumerStatefulWidget {
  const TestOpticsSelectionPage({super.key});

  @override
  ConsumerState<TestOpticsSelectionPage> createState() => _TestOpticsSelectionPageState();
}

class _TestOpticsSelectionPageState extends ConsumerState<TestOpticsSelectionPage> {
  double distanceProjection = 10.0;
  double largeurProjection = 5.0;
  String selectedFormat = '16/9';
  CatalogueItem? selectedProjector;
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  double get ratio {
    double baseRatio = distanceProjection / largeurProjection;
    switch (selectedFormat) {
      case '4/3':
        return baseRatio * (4 / 3) / (16 / 9);
      case '1/1':
        return baseRatio * (1 / 1) / (16 / 9);
      default: // 16/9
        return baseRatio;
    }
  }

  Lens? getRecommendedLens(CatalogueItem proj, double ratio) {
    if (proj.optiques == null || proj.optiques!.isEmpty) return null;

    // Convertir toutes les optiques en Map avec leur ratio moyen
    final validLenses = proj.optiques!
        .map((lens) => MapEntry(lens, _parseRatio(lens.ratio)))
        .where((entry) => entry.value != -1)
        .toList();

    if (validLenses.isEmpty) return null;

    // NOUVELLE LOGIQUE : Chercher d'abord une optique qui contient le ratio calculé dans sa plage
    for (var entry in validLenses) {
      final lens = entry.key;
      final ratioStr = lens.ratio.toLowerCase();

      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if ((lensRatio - ratio).abs() < 0.1) return lens; // Tolérance de 0.1
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        if (min <= ratio && ratio <= max) return lens;
      }
    }

    // Si aucune optique ne contient le ratio, chercher l'optique avec le ratio le plus proche (au-dessus ou en-dessous)
    Lens? bestLens;
    double bestRatioDiff = double.infinity;

    for (var entry in validLenses) {
      final lens = entry.key;
      final ratioStr = lens.ratio.toLowerCase();
      double lensRatio;

      // Gérer les optiques fixes
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == -1) continue;
      }
      // Gérer les optiques avec plage
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        if (min == -1 || max == -1) continue;
        
        // Utiliser le ratio moyen de la plage pour la comparaison
        lensRatio = (min + max) / 2;
      }

      // Calculer la différence absolue avec le ratio calculé
      final ratioDiff = (ratio - lensRatio).abs();

      // Garder l'optique avec la différence la plus petite
      if (ratioDiff < bestRatioDiff) {
        bestLens = lens;
        bestRatioDiff = ratioDiff;
      }
    }

    return bestLens;
  }

  double _parseRatio(String ratioStr) {
    try {
      if (ratioStr.contains('–') || ratioStr.contains('-')) {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        return (min + max) / 2;
      } else {
        return double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
      }
    } catch (e) {
      return -1;
    }
  }

  void _testSelection() {
    _addLog('=== Test de sélection d\'optique ===');
    _addLog('Distance: ${distanceProjection}m');
    _addLog('Largeur: ${largeurProjection}m');
    _addLog('Format: $selectedFormat');
    _addLog('Ratio calculé: ${ratio.toStringAsFixed(2)}');
    
    if (selectedProjector == null) {
      _addLog('❌ Aucun projecteur sélectionné');
      return;
    }
    
    _addLog('Projecteur: ${selectedProjector!.name}');
    _addLog('Optiques disponibles: ${selectedProjector!.optiques?.length ?? 0}');
    
    if (selectedProjector!.optiques != null) {
      for (int i = 0; i < selectedProjector!.optiques!.length; i++) {
        final lens = selectedProjector!.optiques![i];
        final parsedRatio = _parseRatio(lens.ratio);
        _addLog('  ${i + 1}. ${lens.reference} - ${lens.ratio} (parsed: ${parsedRatio.toStringAsFixed(2)})');
      }
    }
    
    final recommendation = getRecommendedLens(selectedProjector!, ratio);
    if (recommendation != null) {
      _addLog('✅ Optique recommandée: ${recommendation.reference} (${recommendation.ratio})');
    } else {
      _addLog('❌ Aucune optique recommandée trouvée');
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectors = ref.watch(catalogueProvider).where((item) =>
        item.categorie == 'Vidéo' &&
        item.sousCategorie == 'Videoprojection').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Sélection Optiques'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Test de Sélection d\'Optiques',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    
                    // Distance
                    Row(
                      children: [
                        const Text('Distance (m): '),
                        Expanded(
                          child: Slider(
                            value: distanceProjection,
                            min: 1.0,
                            max: 50.0,
                            divisions: 49,
                            onChanged: (value) {
                              setState(() {
                                distanceProjection = value;
                              });
                            },
                          ),
                        ),
                        Text(distanceProjection.toStringAsFixed(1)),
                      ],
                    ),
                    
                    // Largeur
                    Row(
                      children: [
                        const Text('Largeur (m): '),
                        Expanded(
                          child: Slider(
                            value: largeurProjection,
                            min: 1.0,
                            max: 20.0,
                            divisions: 19,
                            onChanged: (value) {
                              setState(() {
                                largeurProjection = value;
                              });
                            },
                          ),
                        ),
                        Text(largeurProjection.toStringAsFixed(1)),
                      ],
                    ),
                    
                    // Format
                    DropdownButton<String>(
                      value: selectedFormat,
                      items: const [
                        DropdownMenuItem(value: '16/9', child: Text('16/9')),
                        DropdownMenuItem(value: '4/3', child: Text('4/3')),
                        DropdownMenuItem(value: '1/1', child: Text('1/1')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedFormat = value!;
                        });
                      },
                    ),
                    
                    // Projecteur
                    DropdownButton<CatalogueItem?>(
                      value: selectedProjector,
                      hint: const Text('Sélectionner un projecteur'),
                      items: projectors.map((proj) {
                        return DropdownMenuItem(
                          value: proj,
                          child: Text('${proj.marque} ${proj.produit}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedProjector = value;
                        });
                      },
                    ),
                    
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testSelection,
                      child: const Text('Tester la Sélection'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Logs de test:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 400,
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: _logs.isEmpty
                  ? const Text(
                      'Aucun log pour le moment...',
                      style: TextStyle(color: Colors.grey),
                    )
                  : ListView.builder(
                      itemCount: _logs.length,
                      itemBuilder: (context, index) {
                        final log = _logs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            log,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 12,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
