import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';
import '../models/catalogue_item.dart';
import '../models/lens.dart';

class UpdateUdxOpticsPage extends ConsumerStatefulWidget {
  const UpdateUdxOpticsPage({super.key});

  @override
  ConsumerState<UpdateUdxOpticsPage> createState() => _UpdateUdxOpticsPageState();
}

class _UpdateUdxOpticsPageState extends ConsumerState<UpdateUdxOpticsPage> {
  bool _isLoading = false;
  String _status = '';
  final List<String> _logs = [];

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toString().substring(11, 19)}: $message');
    });
  }

  Future<void> _updateUdxOptics() async {
    setState(() {
      _isLoading = true;
      _status = 'Mise à jour en cours...';
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
      
      _addLog('Création des nouvelles optiques...');
      // Créer les nouvelles optiques avec les données correctes
      final newOptiques = [
        Lens(reference: 'TLD+ Ultra Short Throw', ratio: '0.37:1'),
        Lens(reference: 'TLD+ Fixed', ratio: '0.65:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '0.85–1.24:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '1.20–1.70:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '1.50–2.00:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '2.00–2.80:1'),
        Lens(reference: 'TLD+ Zoom', ratio: '2.50–4.10:1'),
        Lens(reference: 'TLD+ Long Zoom', ratio: '4.10–7.00:1'),
      ];
      
      _addLog('Création de l\'élément mis à jour...');
      // Créer un nouvel élément avec les optiques mises à jour
      final updatedItem = CatalogueItem(
        id: udxItem.id,
        name: udxItem.name,
        description: udxItem.description,
        categorie: udxItem.categorie,
        sousCategorie: udxItem.sousCategorie,
        marque: udxItem.marque,
        produit: udxItem.produit,
        taille: udxItem.taille,
        dimensions: udxItem.dimensions,
        poids: udxItem.poids,
        conso: udxItem.conso,
        imageUrl: udxItem.imageUrl,
        resolutionDalle: udxItem.resolutionDalle,
        angle: udxItem.angle,
        lux: udxItem.lux,
        lumens: udxItem.lumens,
        definition: udxItem.definition,
        dmxMax: udxItem.dmxMax,
        dmxMini: udxItem.dmxMini,
        resolution: udxItem.resolution,
        pitch: udxItem.pitch,
        optiques: newOptiques,
        puissanceAdmissible: udxItem.puissanceAdmissible,
        impedanceNominale: udxItem.impedanceNominale,
        impedanceOhms: udxItem.impedanceOhms,
        powerRmsW: udxItem.powerRmsW,
        powerProgramW: udxItem.powerProgramW,
        powerPeakW: udxItem.powerPeakW,
        maxVoltageVrms: udxItem.maxVoltageVrms,
      );
      
      _addLog('Sauvegarde de l\'élément mis à jour...');
      // Sauvegarder l'élément mis à jour
      await box.put('barco_udx_4k40_flex', updatedItem);
      
      _addLog('✅ Optiques mises à jour avec succès!');
      _addLog('🔍 Nouvelles optiques: ${updatedItem.optiques?.length ?? 0}');
      
      for (int i = 0; i < updatedItem.optiques!.length; i++) {
        final lens = updatedItem.optiques![i];
        _addLog('  ${i + 1}. ${lens.reference} - ${lens.ratio}');
      }
      
      setState(() {
        _status = '✅ Mise à jour réussie!';
        _isLoading = false;
      });
      
    } catch (e) {
      _addLog('❌ Erreur lors de la mise à jour: $e');
      setState(() {
        _status = '❌ Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mise à jour UDX-4K40 FLEX'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      body: Padding(
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
                      'Mise à jour des optiques UDX-4K40 FLEX',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cette page met à jour les optiques du vidéoprojecteur Barco UDX-4K40 FLEX dans la base de données Hive.',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        ElevatedButton(
                          onPressed: _isLoading ? null : _updateUdxOptics,
                          child: _isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2),
                                )
                              : const Text('Mettre à jour'),
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
              'Logs de mise à jour:',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
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
            ),
          ],
        ),
      ),
    );
  }
}
