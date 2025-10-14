import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';

class DiagnosticOpticsPage extends ConsumerStatefulWidget {
  const DiagnosticOpticsPage({super.key});

  @override
  ConsumerState<DiagnosticOpticsPage> createState() => _DiagnosticOpticsPageState();
}

class _DiagnosticOpticsPageState extends ConsumerState<DiagnosticOpticsPage> {
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

  void _runDiagnostic() {
    _addLog('=== DIAGNOSTIC COMPLET ===');
    _addLog('Distance: ${distanceProjection}m');
    _addLog('Largeur: ${largeurProjection}m');
    _addLog('Format: $selectedFormat');
    _addLog('Ratio calculé: ${ratio.toStringAsFixed(3)}');
    
    if (selectedProjector == null) {
      _addLog('❌ Aucun projecteur sélectionné');
      return;
    }
    
    _addLog('');
    _addLog('=== PROJECTEUR ===');
    _addLog('Nom: ${selectedProjector!.name}');
    _addLog('Marque: ${selectedProjector!.marque}');
    _addLog('Produit: ${selectedProjector!.produit}');
    _addLog('Optiques disponibles: ${selectedProjector!.optiques?.length ?? 0}');
    
    if (selectedProjector!.optiques == null || selectedProjector!.optiques!.isEmpty) {
      _addLog('❌ Aucune optique disponible');
      return;
    }
    
    _addLog('');
    _addLog('=== ANALYSE DES OPTIQUES ===');
    
    // Analyser chaque optique
    for (int i = 0; i < selectedProjector!.optiques!.length; i++) {
      final lens = selectedProjector!.optiques![i];
      final ratioStr = lens.ratio.toLowerCase();
      
      _addLog('${i + 1}. ${lens.reference}');
      _addLog('   Ratio: ${lens.ratio}');
      
      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == -1) {
          _addLog('   ❌ Erreur de parsing du ratio fixe');
        } else {
          final diff = (lensRatio - ratio).abs();
          final inRange = diff < 0.1;
          _addLog('   Ratio fixe: ${lensRatio.toStringAsFixed(3)}');
          _addLog('   Différence: ${diff.toStringAsFixed(3)}');
          _addLog('   Dans la plage: ${inRange ? "✅" : "❌"}');
        }
      }
      // Vérifier si c'est une optique avec plage
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        
        if (min == -1 || max == -1) {
          _addLog('   ❌ Erreur de parsing de la plage');
        } else {
          final inRange = min <= ratio && ratio <= max;
          final avg = (min + max) / 2;
          final diff = (avg - ratio).abs();
          _addLog('   Plage: ${min.toStringAsFixed(3)} - ${max.toStringAsFixed(3)}');
          _addLog('   Moyenne: ${avg.toStringAsFixed(3)}');
          _addLog('   Dans la plage: ${inRange ? "✅" : "❌"}');
          _addLog('   Différence moyenne: ${diff.toStringAsFixed(3)}');
        }
      }
      _addLog('');
    }
    
    _addLog('=== SÉLECTION D\'OPTIQUE ===');
    
    // Appliquer la nouvelle logique
    Lens? selectedLens;
    
    // 1. Chercher d'abord une optique qui contient le ratio dans sa plage
    for (var lens in selectedProjector!.optiques!) {
      final ratioStr = lens.ratio.toLowerCase();
      
      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        if ((lensRatio - ratio).abs() < 0.1) {
          selectedLens = lens;
          _addLog('✅ Optique fixe trouvée: ${lens.reference}');
          break;
        }
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
        final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
        if (min <= ratio && ratio <= max) {
          selectedLens = lens;
          _addLog('✅ Optique avec plage trouvée: ${lens.reference}');
          break;
        }
      }
    }
    
    // 2. Si aucune optique ne contient le ratio, chercher la plus proche
    if (selectedLens == null) {
      _addLog('Aucune optique ne contient le ratio, recherche de la plus proche...');
      
      Lens? bestLens;
      double bestRatioDiff = double.infinity;
      
      for (var lens in selectedProjector!.optiques!) {
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
        
        _addLog('   ${lens.reference}: ratio=${lensRatio.toStringAsFixed(3)}, diff=${ratioDiff.toStringAsFixed(3)}');
        
        // Garder l'optique avec la différence la plus petite
        if (ratioDiff < bestRatioDiff) {
          bestLens = lens;
          bestRatioDiff = ratioDiff;
        }
      }
      
      selectedLens = bestLens;
      if (selectedLens != null) {
        _addLog('✅ Optique la plus proche: ${selectedLens.reference}');
      }
    }
    
    if (selectedLens != null) {
      _addLog('');
      _addLog('=== RÉSULTAT FINAL ===');
      _addLog('✅ Optique sélectionnée: ${selectedLens.reference}');
      _addLog('✅ Ratio: ${selectedLens.ratio}');
    } else {
      _addLog('');
      _addLog('=== RÉSULTAT FINAL ===');
      _addLog('❌ Aucune optique sélectionnée');
    }
  }

  @override
  Widget build(BuildContext context) {
    final projectors = ref.watch(catalogueProvider).where((item) =>
        item.categorie == 'Vidéo' &&
        item.sousCategorie == 'Videoprojection').toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diagnostic Optiques'),
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
                      'Diagnostic Complet des Optiques',
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
                      onPressed: _runDiagnostic,
                      child: const Text('Lancer le Diagnostic'),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            const Text(
              'Logs de diagnostic:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 500,
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
                              fontSize: 11,
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


