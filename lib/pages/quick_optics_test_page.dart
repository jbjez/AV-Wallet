import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';

class QuickOpticsTestPage extends ConsumerStatefulWidget {
  const QuickOpticsTestPage({super.key});

  @override
  ConsumerState<QuickOpticsTestPage> createState() => _QuickOpticsTestPageState();
}

class _QuickOpticsTestPageState extends ConsumerState<QuickOpticsTestPage> {
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  void _testUdxOptics() {
    _addLog('=== TEST UDX-4K40 FLEX ===');
    
    final projectors = ref.read(catalogueProvider).where((item) =>
        item.categorie == 'Vidéo' &&
        item.sousCategorie == 'Videoprojection').toList();
    
    final udx = projectors.firstWhere(
      (p) => p.produit == 'UDX-4K40 FLEX',
      orElse: () => throw Exception('UDX-4K40 FLEX non trouvé'),
    );
    
    _addLog('Projecteur trouvé: ${udx.name}');
    _addLog('Optiques disponibles: ${udx.optiques?.length ?? 0}');
    
    if (udx.optiques != null) {
      for (int i = 0; i < udx.optiques!.length; i++) {
        final lens = udx.optiques![i];
        _addLog('${i + 1}. ${lens.reference} - ${lens.ratio}');
      }
    }
    
    // Test avec différents ratios
    final testRatios = [0.5, 1.0, 2.0, 3.0, 4.0, 5.0];
    
    for (final testRatio in testRatios) {
      _addLog('');
      _addLog('--- Test avec ratio $testRatio ---');
      
      final selectedLens = _getRecommendedLens(udx, testRatio);
      if (selectedLens != null) {
        _addLog('✅ Optique sélectionnée: ${selectedLens.reference} (${selectedLens.ratio})');
      } else {
        _addLog('❌ Aucune optique sélectionnée');
      }
    }
  }

  Lens? _getRecommendedLens(CatalogueItem proj, double ratio) {
    if (proj.optiques == null || proj.optiques!.isEmpty) return null;

    _addLog('🔍 getRecommendedLens: ratio calculé = $ratio');
    _addLog('🔍 Projecteur: ${proj.name}');
    _addLog('🔍 Nombre d\'optiques: ${proj.optiques!.length}');

    // LOGIQUE SIMPLIFIÉE ET ROBUSTE
    // 1. Chercher d'abord une optique dont la plage contient le ratio calculé
    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
      _addLog('🔍 Test optique: ${lens.reference} - ${lens.ratio}');

      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').last.replaceAll(',', '.')) ??
            -1;
        _addLog('🔍 Optique fixe: ratio = $lensRatio');
        if (lensRatio != -1 && (lensRatio - ratio).abs() < 0.1) {
          _addLog('✅ Optique fixe trouvée: ${lens.reference}');
          return lens;
        }
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
          _addLog('🔍 Plage: min = $min, max = $max');
          
          if (min != -1 && max != -1 && min <= ratio && ratio <= max) {
            _addLog('✅ Optique avec plage trouvée: ${lens.reference}');
            return lens;
          }
        }
      }
    }

    _addLog('⚠️ Aucune optique ne contient le ratio, recherche de la plus proche...');

    // 2. Si aucune optique ne contient le ratio, chercher la plus proche
    Lens? bestLens;
    double bestRatioDiff = double.infinity;

    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
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
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').last) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').last) ?? -1;
          if (min == -1 || max == -1) continue;
          
          // Utiliser le ratio moyen de la plage pour la comparaison
          lensRatio = (min + max) / 2;
        } else {
          continue;
        }
      }

      // Calculer la différence absolue avec le ratio calculé
      final ratioDiff = (ratio - lensRatio).abs();
      _addLog('🔍 ${lens.reference}: ratio = $lensRatio, diff = $ratioDiff');

      // Garder l'optique avec la différence la plus petite
      if (ratioDiff < bestRatioDiff) {
        bestLens = lens;
        bestRatioDiff = ratioDiff;
      }
    }

    if (bestLens != null) {
      _addLog('✅ Optique la plus proche: ${bestLens.reference}');
    } else {
      _addLog('❌ Aucune optique trouvée');
    }

    return bestLens;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Rapide Optiques'),
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
                      'Test Rapide UDX-4K40 FLEX',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _testUdxOptics,
                      child: const Text('Tester UDX-4K40 FLEX'),
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
              height: 600,
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


