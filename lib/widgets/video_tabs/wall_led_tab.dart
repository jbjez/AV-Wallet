import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/page_state_provider.dart';
import '../../providers/project_provider.dart';
import '../../models/catalogue_item.dart';
import '../../models/project.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../unified_search_widget.dart';
import '../export_widget.dart';
import '../../pages/ar_measure_page.dart';

class WallLedTab extends ConsumerStatefulWidget {
  const WallLedTab({super.key});

  @override
  ConsumerState<WallLedTab> createState() => _WallLedTabState();
}

class _WallLedTabState extends ConsumerState<WallLedTab> {
  CatalogueItem? selectedMurLed;
  double largeurMurLed = 12;
  double hauteurMurLed = 7;
  bool showLedResult = false;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _ledResultKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          UnifiedSearchWidget(
            hintText: 'Rechercher un mur LED...',
            category: 'Vidéo',
            onItemSelected: (item) {
              if (item.sousCategorie == 'Mur LED') {
                setState(() {
                  selectedMurLed = item;
                  largeurMurLed = 1;
                  hauteurMurLed = 1;
                  showLedResult = false;
                });
                // Lancer automatiquement le popup quantité
                _showQuantityDialog(item);
              }
            },
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withAlpha((0.3 * 255).toInt()),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: DropdownButton<String>(
                        value: selectedMurLed?.marque,
                        hint: Text('Sélectionner une marque'),
                        items: () {
                          final marques = _getLedWalls()
                              .map((item) => item.marque)
                              .toSet()
                              .toList();
                          marques.sort();
                          return marques.map((marque) => DropdownMenuItem<String>(
                                value: marque,
                                child: Text(marque),
                              )).toList();
                        }(),
                        onChanged: (marque) {
                          if (marque != null) {
                            final items = _getLedWalls()
                                .where((item) => item.marque == marque)
                                .toList();
                            if (items.isNotEmpty) {
                              setState(() {
                                selectedMurLed = items.first;
                                largeurMurLed = 1;
                                hauteurMurLed = 1;
                                showLedResult = false;
                              });
                            }
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: DropdownButton<CatalogueItem?>(
                        value: selectedMurLed,
                        hint: Text(selectedMurLed?.marque == null 
                            ? 'Sélectionnez une marque d\'abord' 
                            : 'Sélectionner un modèle'),
                        items: selectedMurLed?.marque == null 
                            ? []
                            : _getLedWalls()
                                .where((item) => item.marque == selectedMurLed?.marque)
                                .map((item) => DropdownMenuItem<CatalogueItem?>(
                                      value: item,
                                      child: Text(item.produit),
                                    ))
                                .toList(),
                        onChanged: (item) {
                          if (item != null) {
                            setState(() {
                              selectedMurLed = item;
                              largeurMurLed = 1;
                              hauteurMurLed = 1;
                              showLedResult = false;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  'Largeur : ${largeurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * largeurMurLed).toStringAsFixed(2)} m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)
                ),
                Slider(
                  value: largeurMurLed,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: '${largeurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * largeurMurLed).toStringAsFixed(2)} m',
                  onChanged: (value) {
                    setState(() {
                      largeurMurLed = value.roundToDouble();
                      showLedResult = false;
                    });
                  },
                ),
                Text(
                  'Hauteur : ${hauteurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * hauteurMurLed).toStringAsFixed(2)} m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)
                ),
                Slider(
                  value: hauteurMurLed,
                  min: 1,
                  max: 20,
                  divisions: 19,
                  label: '${hauteurMurLed.toInt()} Dalles / ${((double.tryParse(selectedMurLed?.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * hauteurMurLed).toStringAsFixed(2)} m',
                  onChanged: (value) {
                    setState(() {
                      hauteurMurLed = value;
                      showLedResult = false;
                    });
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ArMeasurePage()),
                        );
                      },
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/icons/tape_measure.png',
                            width: 16,
                            height: 16,
                            color: Colors.white,
                          ),
                          const SizedBox(width: 4),
                          const Text('AR', style: TextStyle(fontSize: 12, color: Colors.white)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      ),
                      onPressed: () {
                        setState(() {
                          showLedResult = true;
                          ref.read(videoPageStateProvider.notifier).updateProjectionResult(false);
                          _scrollToResult();
                        });
                      },
                      child: const Icon(Icons.calculate, size: 20, color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    Tooltip(
                      message: loc.button_reset,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: const Color(0xFF0A1128).withOpacity(0.5),
                          elevation: 0,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        ),
                        onPressed: () {
                          setState(() {
                            selectedMurLed = null;
                            largeurMurLed = 12;
                            hauteurMurLed = 7;
                            showLedResult = false;
                          });
                        },
                        child: const Icon(Icons.refresh, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (showLedResult && selectedMurLed != null)
                  Container(
                    key: _ledResultKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.blueGrey[900]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résultat Mur LED',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildLedResult(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFF455A64), // Gris foncé
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: ExportWidget(
                                title: 'Calcul Mur LED',
                                content: _buildCompleteLedWallExportContent(),
                                fileName: 'mur_led_${selectedMurLed!.produit.replaceAll(' ', '_').toLowerCase()}',
                                customIcon: Icons.cloud_upload,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Action pour ajouter au preset
                                _showAddToPresetDialog();
                              },
                              icon: const Icon(Icons.add),
                              label: const Text('Ajouter'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[900],
                                foregroundColor: Colors.white,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: () {
                                // Action pour schéma
                              },
                              icon: const Icon(Icons.visibility),
                              label: Text(loc.videoPage_schema),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blueGrey[900],
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLedResult() {
    if (selectedMurLed == null) return const SizedBox.shrink();

    final largeurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[0].trim().replaceAll(' mm', '')) ?? 500) / 1000 * largeurMurLed;
    final hauteurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[1].trim().replaceAll(' mm', '')) ?? 500) / 1000 * hauteurMurLed;
    final surfaceMetres = largeurMetres * hauteurMetres;
    final nombreDalles = largeurMurLed * hauteurMurLed;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Mur LED: ${selectedMurLed!.produit}'),
        Text('Marque: ${selectedMurLed!.marque}'),
        Text('Dimensions dalle: ${selectedMurLed!.dimensions}'),
        Text('Largeur: ${largeurMurLed.toInt()} dalles (${largeurMetres.toStringAsFixed(2)} m)'),
        Text('Hauteur: ${hauteurMurLed.toInt()} dalles (${hauteurMetres.toStringAsFixed(2)} m)'),
        Text('Surface totale: ${surfaceMetres.toStringAsFixed(2)} m²'),
        Text('Nombre de dalles: ${nombreDalles.toInt()}'),
      ],
    );
  }

  List<CatalogueItem> _getLedWalls() {
    return ref.watch(catalogueProvider).where((item) => 
      item.categorie == 'Vidéo' && 
      item.sousCategorie == 'Mur LED'
    ).toList();
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_ledResultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _ledResultKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _showQuantityDialog(CatalogueItem item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Quantité - ${item.produit}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Combien de ${item.produit} voulez-vous ajouter ?'),
            const SizedBox(height: 16),
            TextField(
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Quantité',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                // Logique pour gérer la quantité
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique pour ajouter au panier
              print('Ajout de ${item.produit} au panier');
              Navigator.pop(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }

  // Méthode pour générer le contenu complet de l'export du mur LED
  String _buildCompleteLedWallExportContent() {
    final loc = AppLocalizations.of(context)!;
    final projectState = ref.read(projectProvider);
    final project = projectState.selectedProject;
    
    // Fonction helper pour traduire le nom du projet
    String getTranslatedProjectName(Project project) {
      switch (project.name) {
        case 'default_project_1':
          return loc.defaultProject1;
        case 'default_project_2':
          return loc.defaultProject2;
        case 'default_project_3':
          return loc.defaultProject3;
        default:
          return project.name;
      }
    }
    
    if (selectedMurLed == null) {
      return '''
CALCUL MUR LED
==============

DÉTAILS DU PROJET:
------------------
Nom du projet: ${getTranslatedProjectName(project)}
Lieu: ${project.location?.isNotEmpty == true ? project.location : 'Non défini'}
Date de montage: ${project.mountingDate?.isNotEmpty == true ? project.mountingDate : 'Non définie'}
Période: ${project.period?.isNotEmpty == true ? project.period : 'Non définie'}

MUR LED - DÉTAILS:
------------------
Aucun mur LED sélectionné

MATÉRIEL SÉLECTIONNÉ:
---------------------
Aucun matériel sélectionné

RÉSULTAT DU CALCUL:
-------------------
Aucun calcul effectué. Veuillez sélectionner un mur LED et effectuer le calcul.

Généré le: ${DateTime.now().toString().split('.')[0]}
''';
    }

    // Calculs des dimensions
    final largeurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[0].trim().replaceAll(' mm', '')) ?? 500) / 1000 * largeurMurLed;
    final hauteurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[1].trim().replaceAll(' mm', '')) ?? 500) / 1000 * hauteurMurLed;
    final surfaceMetres = largeurMetres * hauteurMetres;
    final nombreDalles = largeurMurLed * hauteurMurLed;
    
    // Calcul du poids (si disponible dans les données)
    final poidsDalle = double.tryParse(selectedMurLed!.poids.replaceAll(' kg', '')) ?? 0;
    final poidsTotal = poidsDalle * nombreDalles;
    
    // Calcul de la résolution (approximative basée sur les dimensions)
    final resolutionApprox = (largeurMetres * 1000 / largeurMurLed).round(); // pixels par dalle en largeur
    
    String content = '''
CALCUL MUR LED
==============

DÉTAILS DU PROJET:
------------------
Nom du projet: ${getTranslatedProjectName(project)}
Lieu: ${project.location?.isNotEmpty == true ? project.location : 'Non défini'}
Date de montage: ${project.mountingDate?.isNotEmpty == true ? project.mountingDate : 'Non définie'}
Période: ${project.period?.isNotEmpty == true ? project.period : 'Non définie'}

MUR LED - DÉTAILS:
------------------
Produit: ${selectedMurLed!.produit}
Marque: ${selectedMurLed!.marque}
Dimensions dalle: ${selectedMurLed!.dimensions}
Poids dalle: ${selectedMurLed!.poids}
Consommation: ${selectedMurLed!.conso}

MATÉRIEL SÉLECTIONNÉ:
---------------------
Configuration mur LED:
• Largeur: ${largeurMurLed.toInt()} dalles
• Hauteur: ${hauteurMurLed.toInt()} dalles
• Dimensions totales: ${largeurMetres.toStringAsFixed(2)} m × ${hauteurMetres.toStringAsFixed(2)} m

RÉSULTAT DU CALCUL:
===================

DIMENSIONS:
-----------
• Largeur: ${largeurMetres.toStringAsFixed(2)} m (${largeurMurLed.toInt()} dalles)
• Hauteur: ${hauteurMetres.toStringAsFixed(2)} m (${hauteurMurLed.toInt()} dalles)
• Surface totale: ${surfaceMetres.toStringAsFixed(2)} m²

RÉSOLUTION:
-----------
• Résolution approximative: ~${resolutionApprox}×${resolutionApprox} pixels par dalle
• Nombre total de dalles: ${nombreDalles.toInt()}

RATIO:
------
• Ratio largeur/hauteur: ${(largeurMetres / hauteurMetres).toStringAsFixed(2)}:1
• Ratio dalles largeur/hauteur: ${(largeurMurLed / hauteurMurLed).toStringAsFixed(2)}:1

POIDS:
------
• Poids par dalle: ${selectedMurLed!.poids}
• Poids total estimé: ${poidsTotal.toStringAsFixed(1)} kg

SCHÉMA REPRÉSENTATIF:
=====================
Vue de face du mur LED

''';

    // Génération du schéma ASCII
    content += _generateLedWallSchema(largeurMurLed.toInt(), hauteurMurLed.toInt());
    
    content += '''

LÉGENDE DU SCHÉMA:
-----------------
• Chaque "█" représente une dalle LED
• Dimensions réelles: ${largeurMetres.toStringAsFixed(2)}m × ${hauteurMetres.toStringAsFixed(2)}m
• Ratio des dalles: ${(largeurMurLed / hauteurMurLed).toStringAsFixed(2)}:1
• Surface totale: ${surfaceMetres.toStringAsFixed(2)} m²

RECOMMANDATIONS TECHNIQUES:
---------------------------
• Vérifier la capacité de support et de fixation
• Considérer l'angle de vision optimal
• Prévoir l'alimentation électrique nécessaire
• Planifier l'installation et la maintenance
• Tester la configuration avant l'événement

Généré le: ${DateTime.now().toString().split('.')[0]}
''';

    return content;
  }

  // Méthode pour générer un schéma ASCII du mur LED
  String _generateLedWallSchema(int largeur, int hauteur) {
    String schema = '';
    
    // Limiter la taille du schéma pour la lisibilité
    final maxLargeur = 20;
    final maxHauteur = 10;
    
    final largeurSchema = largeur > maxLargeur ? maxLargeur : largeur;
    final hauteurSchema = hauteur > maxHauteur ? maxHauteur : hauteur;
    
    // Calculer le ratio pour l'affichage
    final ratioLargeur = largeur > maxLargeur ? (largeur / maxLargeur).round() : 1;
    final ratioHauteur = hauteur > maxHauteur ? (hauteur / maxHauteur).round() : 1;
    
    schema += '┌';
    for (int i = 0; i < largeurSchema; i++) {
      schema += '─';
    }
    schema += '┐\n';
    
    for (int y = 0; y < hauteurSchema; y++) {
      schema += '│';
      for (int x = 0; x < largeurSchema; x++) {
        schema += '█';
      }
      schema += '│\n';
    }
    
    schema += '└';
    for (int i = 0; i < largeurSchema; i++) {
      schema += '─';
    }
    schema += '┘\n';
    
    if (largeur > maxLargeur || hauteur > maxHauteur) {
      schema += '\nNote: Schéma réduit pour la lisibilité\n';
      schema += 'Dimensions réelles: ${largeur}×${hauteur} dalles\n';
      schema += 'Ratio d\'affichage: ${ratioLargeur}:${ratioHauteur}\n';
    }
    
    return schema;
  }

  // Méthode pour afficher le dialogue d'ajout au preset
  void _showAddToPresetDialog() {
    if (selectedMurLed == null) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Ajouter au preset'),
        content: Text('Voulez-vous ajouter "${selectedMurLed!.produit}" au preset ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              // Logique pour ajouter au preset
              print('Ajout de ${selectedMurLed!.produit} au preset');
              Navigator.pop(context);
            },
            child: const Icon(Icons.add),
          ),
        ],
      ),
    );
  }
}
