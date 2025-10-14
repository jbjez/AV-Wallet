import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';

class FixUdxOpticsPage extends ConsumerStatefulWidget {
  const FixUdxOpticsPage({super.key});

  @override
  ConsumerState<FixUdxOpticsPage> createState() => _FixUdxOpticsPageState();
}

class _FixUdxOpticsPageState extends ConsumerState<FixUdxOpticsPage> {
  bool _isLoading = false;
  String _status = '';
  List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _fixUdxOptics() async {
    setState(() {
      _isLoading = true;
      _status = 'Correction en cours...';
      _logs.clear();
    });

    try {
      _addLog('Ouverture de la boîte Hive...');
      final box = await HiveService.getCatalogueBox();
      
      _addLog('Recherche de l\'élément UDX-4K40 FLEX...');
      final udxItem = box.get('barco_udx_4k40_flex');
      
      if (udxItem == null) {
        _addLog('❌ Élément UDX-4K40 FLEX non trouvé dans Hive');
        setState(() {
          _status = 'Erreur: Élément non trouvé';
          _isLoading = false;
        });
        return;
      }
      
      _addLog('✅ Élément trouvé: ${udxItem.name}');
      _addLog('🔍 Optiques actuelles: ${udxItem.optiques?.length ?? 0}');
      
      if (udxItem.optiques != null) {
        for (int i = 0; i < udxItem.optiques!.length; i++) {
          final lens = udxItem.optiques![i];
          _addLog('  ${i + 1}. ${lens.reference} - ${lens.ratio}');
        }
      }
      
      _addLog('Création des optiques complètes...');
      // Créer toutes les optiques avec les données correctes
      final completeOptiques = [
        Lens(reference: 'TLD+ Ultra Short Throw', ratio: '0.37:1'),
        Lens(reference: 'TLD+ Fixed', ratio: '0.65:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '0.85–1.24:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '1.20–1.70:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '1.50–2.00:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '2.00–2.80:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '2.50–4.10:1'),
        Lens(reference: 'TLD+ Long Zoom', ratio: '4.10–7.00:1'),
      ];
      
      _addLog('Création de l\'élément corrigé...');
      // Créer un nouvel élément avec toutes les optiques
      final fixedItem = CatalogueItem(
        id: udxItem.id,
        name: udxItem.name,
        description: udxItem.description,
        categorie: udxItem.categorie,
        sousCategorie: udxItem.sousCategorie,
        marque: udxItem.marque,
        produit: udxItem.produit,
        dimensions: udxItem.dimensions,
        poids: udxItem.poids,
        conso: udxItem.conso,
        lumens: udxItem.lumens,
        optiques: completeOptiques,
      );
      
      _addLog('Sauvegarde dans Hive...');
      await box.put('barco_udx_4k40_flex', fixedItem);
      
      _addLog('Vérification de la correction...');
      final updatedItem = box.get('barco_udx_4k40_flex');
      _addLog('✅ Optiques après correction: ${updatedItem?.optiques?.length ?? 0}');
      
      if (updatedItem?.optiques != null) {
        for (int i = 0; i < updatedItem!.optiques!.length; i++) {
          final lens = updatedItem.optiques![i];
          _addLog('  ${i + 1}. ${lens.reference} - ${lens.ratio}');
        }
      }
      
      _addLog('✅ Correction terminée avec succès!');
      _addLog('🎯 L\'UDX-4K40 FLEX a maintenant toutes ses 8 optiques');
      
      setState(() {
        _status = '✅ Correction réussie: 8 optiques disponibles';
        _isLoading = false;
      });
      
    } catch (e) {
      _addLog('❌ Erreur lors de la correction: $e');
      setState(() {
        _status = '❌ Erreur: $e';
        _isLoading = false;
      });
    }
  }

  Future<void> _checkCurrentStatus() async {
    setState(() {
      _logs.clear();
    });

    try {
      _addLog('Vérification du statut actuel...');
      final box = await HiveService.getCatalogueBox();
      final udxItem = box.get('barco_udx_4k40_flex');
      
      if (udxItem == null) {
        _addLog('❌ UDX-4K40 FLEX non trouvé dans Hive');
        return;
      }
      
      _addLog('✅ UDX-4K40 FLEX trouvé: ${udxItem.name}');
      _addLog('🔍 Nombre d\'optiques: ${udxItem.optiques?.length ?? 0}');
      
      if (udxItem.optiques != null) {
        for (int i = 0; i < udxItem.optiques!.length; i++) {
          final lens = udxItem.optiques![i];
          _addLog('  ${i + 1}. ${lens.reference} - ${lens.ratio}');
        }
      }
      
      if ((udxItem.optiques?.length ?? 0) < 8) {
        _addLog('⚠️ Problème détecté: Seulement ${udxItem.optiques?.length ?? 0} optiques au lieu de 8');
        _addLog('💡 Utilisez le bouton "Corriger" pour résoudre le problème');
      } else {
        _addLog('✅ Statut correct: 8 optiques disponibles');
      }
      
    } catch (e) {
      _addLog('❌ Erreur lors de la vérification: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Correction UDX-4K40 FLEX'),
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
                      'Correction des Optiques UDX-4K40 FLEX',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette page corrige le problème des optiques manquantes de l\'UDX-4K40 FLEX dans Hive.',
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red[200]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Problème identifié:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.red,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('🔍 L\'UDX-4K40 FLEX n\'a que 2 optiques dans Hive'),
                          Text('🔍 Il devrait en avoir 8 pour un calcul correct'),
                          Text('🔍 Cela cause toujours la sélection de "Ultra Short Throw"'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green[200]!),
                      ),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Solution:',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Colors.green,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('✅ Ajouter les 6 optiques manquantes'),
                          Text('✅ TLD+ Fixed (0.65:1)'),
                          Text('✅ TLD+ Zoom (1.20–1.70:1)'),
                          Text('✅ TLD+ Zoom (1.50–2.00:1)'),
                          Text('✅ TLD+ Zoom (2.00–2.80:1)'),
                          Text('✅ TLD+ Zoom (2.50–4.10:1)'),
                          Text('✅ TLD+ Long Zoom (4.10–7.00:1)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _fixUdxOptics,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Corriger'),
                        ),
                        const SizedBox(width: 16),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _checkCurrentStatus,
                          child: const Text('Vérifier'),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          _status,
                          style: TextStyle(
                            color: _status.contains('✅') 
                                ? Colors.green 
                                : _status.contains('❌') 
                                    ? Colors.red 
                                    : Colors.blue,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Logs de correction:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              height: 300,
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
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}


