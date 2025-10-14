import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/page_state_provider.dart';
import '../../models/catalogue_item.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';
import '../uniform_dropdown.dart';
import '../unified_search_widget.dart';
import '../unified_quantity_dialog.dart';
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
    final videoState = ref.watch(videoPageStateProvider);

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
                      child: BrandDropdown(
                        selectedBrand: selectedMurLed?.marque,
                        brands: _getLedWalls().map((item) => item.marque).toSet().toList()..sort(),
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
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: LedWallDropdownWithFirstSelect(
                        selectedLedWall: selectedMurLed,
                        ledWalls: _getLedWalls(),
                        selectedBrand: selectedMurLed?.marque,
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
                        fontSize: 14,
                        firstSelectText: 'Sélectionnez une marque d\'abord',
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
                      border: Border.all(color: Colors.white, width: 1),
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

  Widget _buildLedResult() {
    if (selectedMurLed == null) return const SizedBox.shrink();

    final largeurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[0].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * largeurMurLed;
    final hauteurMetres = (double.tryParse(selectedMurLed!.dimensions.split('x')[1].trim().replaceAll(' mm', '') ?? '500') ?? 500) / 1000 * hauteurMurLed;
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
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}
