import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/page_state_provider.dart';
import '../../models/catalogue_item.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../uniform_dropdown.dart';
import '../unified_search_widget.dart';
import '../unified_quantity_dialog.dart';

class ProjectorTab extends ConsumerStatefulWidget {
  const ProjectorTab({super.key});

  @override
  ConsumerState<ProjectorTab> createState() => _ProjectorTabState();
}

class _ProjectorTabState extends ConsumerState<ProjectorTab> {
  CatalogueItem? selectedProjector;
  double largeurProjection = 5;
  double distanceProjection = 10;
  String selectedFormat = '16/9';
  int nbProjecteurs = 1;
  double chevauchement = 15.0;
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _projectionResultKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final videoState = ref.watch(videoPageStateProvider);
    final projectors = ref.watch(catalogueProvider).where((item) => 
      item.categorie == 'Vidéo' && 
      item.sousCategorie == 'Videoprojection'
    ).toList();

    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          UnifiedSearchWidget(
            hintText: loc.catalogPage_search,
            category: 'Vidéo',
            onItemSelected: (item) {
              setState(() {
                if (item.sousCategorie == 'Mur LED') {
                  // Ne pas traiter les murs LED ici
                  return;
                } else {
                  ref.read(videoPageStateProvider.notifier).updateSelectedBrand(item.marque);
                  selectedProjector = item;
                }
              });
              // Lancer automatiquement le popup quantité
              _showQuantityDialog(item);
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BrandDropdown(
                        selectedBrand: videoState.selectedBrand,
                        brands: projectors.map((item) => item.marque).toSet().toList()..sort(),
                        onChanged: (brand) {
                          ref.read(videoPageStateProvider.notifier).updateSelectedBrand(brand);
                          setState(() {
                            selectedProjector = null;
                          });
                        },
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ProjectorModelDropdownWithFirstSelect(
                        selectedProjector: selectedProjector,
                        projectors: projectors,
                        selectedBrand: videoState.selectedBrand,
                        onChanged: (item) {
                          setState(() {
                            selectedProjector = item;
                          });
                        },
                        fontSize: 14,
                        firstSelectText: 'Sélectionnez une marque d\'abord',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: FormatDropdown(
                        selectedFormat: selectedFormat,
                        formats: ['16/9', '4/3', '1/1'],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFormat = value;
                            });
                          }
                        },
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ProjectorCountDropdown(
                        selectedCount: nbProjecteurs,
                        maxCount: 6,
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              nbProjecteurs = value;
                            });
                          }
                        },
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OverlapDropdown(
                        selectedOverlap: chevauchement,
                        overlapValues: [10.0, 15.0, 20.0],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              chevauchement = value;
                            });
                          }
                        },
                        enabled: nbProjecteurs > 1,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${loc.videoPage_imageWidth} : ${largeurProjection.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)
                ),
                Slider(
                  value: largeurProjection,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: largeurProjection.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      largeurProjection = value;
                    });
                  },
                ),
                Text(
                  '${loc.videoPage_projectorDistance} : ${distanceProjection.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 14)
                ),
                Slider(
                  value: distanceProjection,
                  min: 1,
                  max: 50,
                  divisions: 49,
                  label: distanceProjection.toStringAsFixed(1),
                  onChanged: (value) {
                    setState(() {
                      distanceProjection = value;
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
                        setState(() {
                          ref.read(videoPageStateProvider.notifier).updateProjectionResult(true);
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
                            selectedProjector = null;
                            largeurProjection = 5;
                            distanceProjection = 10;
                            selectedFormat = '16/9';
                            nbProjecteurs = 1;
                            chevauchement = 15.0;
                            ref.read(videoPageStateProvider.notifier).updateProjectionResult(false);
                          });
                        },
                        child: const Icon(Icons.refresh, size: 20, color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (videoState.showProjectionResult && selectedProjector != null)
                  Container(
                    key: _projectionResultKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Résultat de projection',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _buildProjectionResult(),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: () {
                                // Action pour exporter
                              },
                              icon: const Icon(Icons.download),
                              label: Text(loc.export),
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

  Widget _buildProjectionResult() {
    if (selectedProjector == null) return const SizedBox.shrink();

    // Calculs de projection (logique existante)
    final ratio = selectedFormat == '16/9' ? 16/9 : selectedFormat == '4/3' ? 4/3 : 1.0;
    final hauteurProjection = largeurProjection / ratio;
    final surfaceProjection = largeurProjection * hauteurProjection;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Projecteur: ${selectedProjector!.produit}'),
        Text('Marque: ${selectedProjector!.marque}'),
        Text('Format: $selectedFormat'),
        Text('Largeur: ${largeurProjection.toStringAsFixed(1)} m'),
        Text('Hauteur: ${hauteurProjection.toStringAsFixed(1)} m'),
        Text('Surface: ${surfaceProjection.toStringAsFixed(1)} m²'),
        Text('Distance: ${distanceProjection.toStringAsFixed(1)} m'),
        if (nbProjecteurs > 1) ...[
          Text('Nombre de projecteurs: $nbProjecteurs'),
          Text('Chevauchement: ${chevauchement.toInt()}%'),
        ],
      ],
    );
  }

  void _scrollToResult() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_projectionResultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _projectionResultKey.currentContext!,
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
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
