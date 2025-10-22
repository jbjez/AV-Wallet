import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../../providers/catalogue_provider.dart';
import '../../models/catalogue_item.dart';
import '../../models/lens.dart';
import '../../pages/ar_measure_page.dart';
import '../../widgets/border_labeled_dropdown.dart';
import '../../widgets/export_widget.dart';
import '../action_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class ProjectionTab extends ConsumerStatefulWidget {
  const ProjectionTab({super.key});

  @override
  ConsumerState<ProjectionTab> createState() => _ProjectionTabState();
}

class _ProjectionTabState extends ConsumerState<ProjectionTab> {
  String? selectedBrand;
  CatalogueItem? selectedProjector;
  double largeurProjection = 5;
  double distanceProjection = 10;
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  final TextEditingController searchController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final GlobalKey resultKey = GlobalKey();
  final GlobalKey buttonsKey = GlobalKey();
  bool showProjectionResult = false;
  String selectedFormat = '16/9';
  int nbProjecteurs = 1;
  double chevauchement = 15.0;
  
  // Gestion des commentaires
  Map<String, String> _comments = {};
  final String _currentProjectionResult = '';
  

  @override
  void initState() {
    super.initState();
    // Charger la persistance après que le widget soit construit
    // TEMPORAIREMENT DÉSACTIVÉ POUR TESTER
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loadPersistedState();
    // });
    // Charger les commentaires
    _loadComments();
  }

  @override
  void dispose() {
    searchController.dispose();
    scrollController.dispose();
    _savePersistedState();
    super.dispose();
  }

  List<CatalogueItem> get projectors {
    return ref
        .watch(catalogueProvider)
        .where((item) =>
            item.categorie == 'Vidéo' &&
            item.sousCategorie == 'Videoprojection')
        .toList();
  }


  double get ratio {
    if (selectedFormat == '16/9') {
      return 16 / 9;
    } else if (selectedFormat == '4/3') {
      return 4 / 3;
    } else if (selectedFormat == '1/1') {
      return 1;
    }
    return 16 / 9;
  }

  // Calcul de recommandation pour la projection
  Map<String, dynamic>? get recommendation {
    // Calculer le ratio recommandé
    String ratioRecommandee;
    String optiqueRecommandee;
    
    if (selectedProjector == null) {
      // Si aucun projecteur sélectionné, calculer le ratio basé sur distance/largeur
      final ratioCalcul = distanceProjection / largeurProjection;
      ratioRecommandee = ratioCalcul.toStringAsFixed(2);
      optiqueRecommandee = 'À définir';
    } else {
      // Si projecteur sélectionné, calculer le ratio d'optique
      // Pour le softage, utiliser la largeur de chaque VP individuellement
      double largeurPourRatio = largeurProjection;
      if (nbProjecteurs > 1) {
        largeurPourRatio = largeurProjection / nbProjecteurs;
      }
      final ratioCalcul = distanceProjection / largeurPourRatio;
      ratioRecommandee = ratioCalcul.toStringAsFixed(2);
      
      // Déterminer l'optique recommandée basée sur les optiques disponibles
      if (selectedProjector!.optiques != null && selectedProjector!.optiques!.isNotEmpty) {
        // Utiliser la vraie logique de sélection d'optiques
        final recommendedLens = _getRecommendedLens(selectedProjector!, ratioCalcul);
        optiqueRecommandee = recommendedLens?.reference ?? 'Choisir une optique';
        
        // Inclure le ratio de l'optique recommandée
        if (recommendedLens != null) {
          optiqueRecommandee = '${recommendedLens.reference} (${recommendedLens.ratio})';
        }
      } else {
        // Si aucune optique référencée, indiquer qu'il faut en choisir une
        optiqueRecommandee = 'Choisir une optique';
      }
    }
    
    return {
      'ratio': ratioRecommandee,
      'optique': optiqueRecommandee,
    };
  }

  // Logique de sélection d'optiques intelligente (copiée de video_menu_page.dart)
  Lens? _getRecommendedLens(CatalogueItem proj, double ratio) {
    if (proj.optiques == null || proj.optiques!.isEmpty) return null;

    print('🔍 ProjectionTab: ratio calculé = $ratio');
    print('🔍 Projecteur: ${proj.name}');
    print('🔍 Nombre d\'optiques: ${proj.optiques!.length}');

    // 1. Chercher d'abord une optique dont la plage contient le ratio calculé
    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
      print('🔍 Test optique: ${lens.reference} - ${lens.ratio}');

      // Vérifier si c'est une optique fixe
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        final lensRatio = double.tryParse(
                ratioStr.trim().split(':').first.replaceAll(',', '.')) ??
            -1;
        print('🔍 Optique fixe: ratio = $lensRatio');
        if (lensRatio != -1 && (lensRatio - ratio).abs() < 0.1) {
          print('✅ Optique fixe trouvée: ${lens.reference}');
          return lens;
        }
      }
      // Vérifier si le ratio est dans la plage de l'optique
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').first) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').first) ?? -1;
          print('🔍 Plage: min = $min, max = $max');
          
          if (min != -1 && max != -1 && min <= ratio && ratio <= max) {
            print('✅ Optique avec plage trouvée: ${lens.reference}');
            return lens;
          }
        }
      }
    }

    print('⚠️ Aucune optique ne contient le ratio, recherche de la plus proche...');

    // 2. Si aucune optique ne contient le ratio, chercher la plus proche
    Lens? bestLens;
    double bestRatioDiff = double.infinity;

    for (var lens in proj.optiques!) {
      final ratioStr = lens.ratio;
      double lensRatio;

      // Gérer les optiques fixes
      if (!ratioStr.contains('–') && !ratioStr.contains('-')) {
        lensRatio = double.tryParse(
                ratioStr.trim().split(':').first.replaceAll(',', '.')) ??
            -1;
        if (lensRatio == -1) continue;
      }
      // Gérer les optiques avec plage
      else {
        final parts = ratioStr.replaceAll(',', '.').split(RegExp(r'[–-]'));
        if (parts.length == 2) {
          final min = double.tryParse(parts[0].trim().split(':').first) ?? -1;
          final max = double.tryParse(parts[1].trim().split(':').first) ?? -1;
          if (min == -1 || max == -1) continue;
          
          // Utiliser le ratio moyen de la plage pour la comparaison
          lensRatio = (min + max) / 2;
        } else {
          continue;
        }
      }

      // Calculer la différence absolue avec le ratio calculé
      final ratioDiff = (ratio - lensRatio).abs();
      print('🔍 ${lens.reference}: ratio = $lensRatio, diff = $ratioDiff');

      // Garder l'optique avec la différence la plus petite
      if (ratioDiff < bestRatioDiff) {
        bestLens = lens;
        bestRatioDiff = ratioDiff;
      }
    }

    if (bestLens != null) {
      print('✅ Optique la plus proche: ${bestLens.reference}');
    } else {
      print('❌ Aucune optique trouvée');
    }

    return bestLens;
  }

  // Méthodes pour l'export PDF
  List<Map<String, dynamic>> _buildProjectionData() {
    if (selectedProjector == null) return [];
    
    final recommendation = this.recommendation;
    
    // Pour le softage, calculer le ratio basé sur la largeur de chaque VP individuellement
    double largeurPourRatio = largeurProjection;
    if (nbProjecteurs > 1) {
      largeurPourRatio = largeurProjection / nbProjecteurs;
    }
    final ratioCalcul = distanceProjection / largeurPourRatio;
    
    // Calculer la hauteur de l'image basée sur le format (chaque VP individuellement)
    double hauteurImageVP = 0;
    switch (selectedFormat) {
      case '16/9':
        hauteurImageVP = largeurProjection * 9 / 16;
        break;
      case '4/3':
        hauteurImageVP = largeurProjection * 3 / 4;
        break;
      case '21/9':
        hauteurImageVP = largeurProjection * 9 / 21;
        break;
      case '1/1':
        hauteurImageVP = largeurProjection;
        break;
    }
    
    // Calculer les dimensions du softage
    double largeurTotale = 0;
    double hauteurTotale = hauteurImageVP; // Même hauteur pour tous les VP
    
    if (nbProjecteurs == 1) {
      largeurTotale = largeurProjection;
    } else {
      // Softage : chaque VP projette la même largeur, avec chevauchement
      double largeurVP = largeurProjection / nbProjecteurs;
      double chevauchementReel = largeurVP * chevauchement / 100;
      largeurTotale = (largeurVP * nbProjecteurs) - (chevauchementReel * (nbProjecteurs - 1));
    }
    
    return [
      {
        'type': 'projection',
        'nom_vp': selectedProjector!.name,
        'nom_projet': 'Projection ${selectedProjector!.name}',
        'largeur_totale': '${largeurTotale.toStringAsFixed(2)} m',
        'hauteur_totale': '${hauteurTotale.toStringAsFixed(2)} m',
        'largeur_vp': '${(largeurProjection / nbProjecteurs).toStringAsFixed(2)} m',
        'hauteur_vp': '${hauteurImageVP.toStringAsFixed(2)} m',
        'distance_projection': '${distanceProjection.toStringAsFixed(2)} m',
        'format': selectedFormat,
        'ratio_calculé': ratioCalcul.toStringAsFixed(2),
        'optique_recommandée': recommendation?['optique'] ?? 'N/A',
        'nb_projecteurs': nbProjecteurs,
        'chevauchement': nbProjecteurs > 1 ? '${chevauchement.toStringAsFixed(1)}%' : 'N/A',
      }
    ];
  }
  
  Map<String, dynamic> _buildProjectionSummary() {
    if (selectedProjector == null) return {};
    
    final recommendation = this.recommendation;
    
    // Pour le softage, calculer le ratio basé sur la largeur de chaque VP individuellement
    double largeurPourRatio = largeurProjection;
    if (nbProjecteurs > 1) {
      largeurPourRatio = largeurProjection / nbProjecteurs;
    }
    final ratioCalcul = distanceProjection / largeurPourRatio;
    
    // Calculer la hauteur de l'image basée sur le format (chaque VP individuellement)
    double hauteurImageVP = 0;
    switch (selectedFormat) {
      case '16/9':
        hauteurImageVP = largeurProjection * 9 / 16;
        break;
      case '4/3':
        hauteurImageVP = largeurProjection * 3 / 4;
        break;
      case '21/9':
        hauteurImageVP = largeurProjection * 9 / 21;
        break;
      case '1/1':
        hauteurImageVP = largeurProjection;
        break;
    }
    
    // Calculer les dimensions du softage
    double largeurTotale = 0;
    double hauteurTotale = hauteurImageVP; // Même hauteur pour tous les VP
    
    if (nbProjecteurs == 1) {
      largeurTotale = largeurProjection;
    } else {
      // Softage : chaque VP projette la même largeur, avec chevauchement
      double largeurVP = largeurProjection / nbProjecteurs;
      double chevauchementReel = largeurVP * chevauchement / 100;
      largeurTotale = (largeurVP * nbProjecteurs) - (chevauchementReel * (nbProjecteurs - 1));
    }
    
    return {
      'nom_vp': selectedProjector!.name,
      'nom_projet': 'Projection ${selectedProjector!.name}',
      'largeur_totale': largeurTotale,
      'hauteur_totale': hauteurTotale,
      'largeur_vp': largeurProjection / nbProjecteurs,
      'hauteur_vp': hauteurImageVP,
      'distance_projection': distanceProjection,
      'format': selectedFormat,
      'ratio_calculé': ratioCalcul,
      'optique_recommandée': recommendation?['optique'] ?? 'N/A',
      'nb_projecteurs': nbProjecteurs,
      'chevauchement': chevauchement,
    };
  }

  // Méthodes de persistance
  Future<void> _loadPersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Attendre que le catalogue soit chargé
      await Future.delayed(const Duration(milliseconds: 1000));
      
      if (!mounted) return;
      
      // Vérifier que le catalogue est chargé
      final projectorsList = projectors;
      if (projectorsList.isEmpty) {
        print('Projection: Catalogue not loaded yet, skipping persistence restoration');
        return;
      }
      
      print('Projection: Loading persisted state...');
      
      // Restaurer les paramètres de projection
      final savedLargeurProjection = prefs.getDouble('projection_largeur');
      final savedDistanceProjection = prefs.getDouble('projection_distance');
      final savedSelectedFormat = prefs.getString('projection_selected_format');
      final savedNbProjecteurs = prefs.getInt('projection_nb_projecteurs');
      final savedChevauchement = prefs.getDouble('projection_chevauchement');
      final savedSelectedBrand = prefs.getString('projection_selected_brand');
      final savedSelectedProduct = prefs.getString('projection_selected_product');
      final savedShowResult = prefs.getBool('projection_show_result');
      final savedSearchQuery = prefs.getString('projection_search_query');
      
      print('Projection: Saved values - Largeur: $savedLargeurProjection, Distance: $savedDistanceProjection, Format: $savedSelectedFormat, Brand: $savedSelectedBrand, Product: $savedSelectedProduct');
      
      if (!mounted) return;
      
      setState(() {
        if (savedLargeurProjection != null && savedLargeurProjection >= 1 && savedLargeurProjection <= 20) {
          largeurProjection = savedLargeurProjection;
          print('Projection: Restored largeur: $largeurProjection');
        }
        
        if (savedDistanceProjection != null && savedDistanceProjection >= 1 && savedDistanceProjection <= 50) {
          distanceProjection = savedDistanceProjection;
          print('Projection: Restored distance: $distanceProjection');
        }
        
        if (savedSelectedFormat != null && ['16/9', '4/3', '1/1'].contains(savedSelectedFormat)) {
          selectedFormat = savedSelectedFormat;
          print('Projection: Restored format: $selectedFormat');
        }
        
        if (savedNbProjecteurs != null && savedNbProjecteurs >= 1 && savedNbProjecteurs <= 10) {
          nbProjecteurs = savedNbProjecteurs;
          print('Projection: Restored nb projecteurs: $nbProjecteurs');
        }
        
        if (savedChevauchement != null && savedChevauchement >= 0 && savedChevauchement <= 50) {
          chevauchement = savedChevauchement;
          print('Projection: Restored chevauchement: $chevauchement');
        }
        
        if (savedSelectedBrand != null && savedSelectedBrand.isNotEmpty) {
          // Vérifier que la marque existe dans la liste des projecteurs
          final availableBrands = projectors.map((p) => p.marque).toSet().toList();
          if (availableBrands.contains(savedSelectedBrand)) {
            selectedBrand = savedSelectedBrand;
            print('Projection: Restored brand: $selectedBrand');
          } else {
            print('Projection: Saved brand $savedSelectedBrand not found in available brands: $availableBrands');
            selectedBrand = null;
          }
        }
        
        if (savedShowResult != null) {
          showProjectionResult = savedShowResult;
          print('Projection: Restored show result: $showProjectionResult');
        }
        
        if (savedSearchQuery != null && savedSearchQuery.isNotEmpty) {
          searchQuery = savedSearchQuery;
          searchController.text = savedSearchQuery;
          print('Projection: Restored search query: $searchQuery');
        }
      });
      
      // Restaurer le produit sélectionné après avoir chargé les projecteurs
      if (savedSelectedProduct != null && savedSelectedProduct.isNotEmpty) {
        try {
          final product = projectorsList.firstWhere((item) => item.produit == savedSelectedProduct);
          if (mounted) {
            setState(() {
              selectedProjector = product;
              // S'assurer que la marque correspond aussi
              selectedBrand = product.marque;
            });
            print('Projection: Restored selected product: $savedSelectedProduct with brand: ${product.marque}');
          }
        } catch (e) {
          print('Projection: Could not restore selected product: $e');
          // Si le produit n'existe plus, réinitialiser
          if (mounted) {
            setState(() {
              selectedProjector = null;
              selectedBrand = null;
            });
          }
        }
      }
      
      print('Projection: Persistence restoration completed successfully');
    } catch (e) {
      print('Projection: Error loading persisted state: $e');
    }
  }

  Future<void> _savePersistedState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      print('Projection: Saving state...');
      
      // Sauvegarder les paramètres de projection
      await prefs.setDouble('projection_largeur', largeurProjection);
      await prefs.setDouble('projection_distance', distanceProjection);
      await prefs.setString('projection_selected_format', selectedFormat);
      await prefs.setInt('projection_nb_projecteurs', nbProjecteurs);
      await prefs.setDouble('projection_chevauchement', chevauchement);
      await prefs.setString('projection_selected_brand', selectedBrand ?? '');
      await prefs.setString('projection_selected_product', selectedProjector?.produit ?? '');
      await prefs.setBool('projection_show_result', showProjectionResult);
      await prefs.setString('projection_search_query', searchQuery);
      
      print('Projection: State saved successfully');
    } catch (e) {
      print('Projection: Error saving state: $e');
    }
  }

  // Méthodes de validation pour éviter les crashes de dropdown
  String? _getValidBrandValue() {
    if (selectedBrand == null) return null;
    try {
      final availableBrands = projectors.map((p) => p.marque).toSet();
      return availableBrands.contains(selectedBrand) ? selectedBrand : null;
    } catch (e) {
      print('Projection: Error getting valid brand value: $e');
      return null;
    }
  }

  String? _getValidProductValue() {
    if (selectedProjector == null) return null;
    try {
      final availableProducts = projectors
          .where((item) => selectedBrand == null || item.marque == selectedBrand)
          .map((p) => p.produit)
          .toSet();
      return availableProducts.contains(selectedProjector!.produit) ? selectedProjector!.produit : null;
    } catch (e) {
      print('Projection: Error getting valid product value: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return SingleChildScrollView(
      controller: scrollController,
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF0A1128).withOpacity(0.3),
          border: Border.all(color: Colors.white, width: 1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche
            TextField(
              controller: searchController,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: loc.videoPage_selectProduct,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
                border: InputBorder.none,
                prefixIcon: Icon(
                  Icons.search,
                  color: Colors.white.withOpacity(0.7),
                ),
                filled: true,
                fillColor: Colors.transparent,
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                  if (value.isEmpty) {
                    searchResults = [];
                  } else {
                    searchResults = projectors
                        .where((item) =>
                            item.marque.toLowerCase().contains(value.toLowerCase()) ||
                            item.produit.toLowerCase().contains(value.toLowerCase()))
                        .toList();
                  }
                });
                _savePersistedState();
              },
            ),
            
            // Résultats de recherche
            if (searchResults.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: searchResults.length,
                  itemBuilder: (context, index) {
                    final item = searchResults[index];
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedBrand = item.marque;
                          selectedProjector = item;
                          searchQuery = '';
                          searchResults = [];
                          searchController.clear();
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 8,
                          horizontal: 12
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.marque} - ${item.produit}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                            Text(
                              item.sousCategorie,
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: Theme.of(context).textTheme.bodySmall?.color?.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            const SizedBox(height: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: BorderLabeledDropdown<String>(
                        label: loc.videoPage_brand,
                        value: _getValidBrandValue(),
                        items: projectors
                            .map((item) => item.marque)
                            .toSet()
                            .map((marque) {
                          return DropdownMenuItem(
                            value: marque,
                            child: Text(marque, style: const TextStyle(fontSize: 11)),
                          );
                        }).toList(),
                        onChanged: (brand) {
                          setState(() {
                            selectedBrand = brand;
                            selectedProjector = null;
                          });
                          _savePersistedState();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BorderLabeledDropdown<String>(
                        label: loc.videoPage_model,
                        value: _getValidProductValue(),
                        items: projectors
                            .where((item) => 
                              selectedBrand == null || 
                              item.marque == selectedBrand)
                            .map((item) {
                          return DropdownMenuItem(
                            value: item.produit,
                            child: Text(item.produit, style: const TextStyle(fontSize: 11)),
                          );
                        }).toList(),
                        onChanged: (produit) {
                          final item = projectors.firstWhere(
                            (p) => p.produit == produit,
                            orElse: () => projectors.first,
                          );
                          setState(() {
                            selectedProjector = item;
                          });
                          _savePersistedState();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: BorderLabeledDropdown<String>(
                        label: loc.videoPage_format,
                        value: selectedFormat,
                        items: [
                          DropdownMenuItem(
                            value: '16/9',
                            child: Text('16/9', style: const TextStyle(fontSize: 11)),
                          ),
                          DropdownMenuItem(
                            value: '4/3',
                            child: Text('4/3', style: const TextStyle(fontSize: 11)),
                          ),
                          DropdownMenuItem(
                            value: '1/1',
                            child: Text('1/1', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              selectedFormat = value;
                            });
                            _savePersistedState();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BorderLabeledDropdown<String>(
                        label: loc.videoPage_projectorCount,
                        value: nbProjecteurs.toString(),
                        items: List.generate(6, (index) {
                          return DropdownMenuItem(
                            value: (index + 1).toString(),
                            child: Text((index + 1).toString(), style: const TextStyle(fontSize: 11)),
                          );
                        }),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              nbProjecteurs = int.parse(value);
                            });
                            _savePersistedState();
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: BorderLabeledDropdown<String>(
                        label: loc.videoPage_overlap,
                        value: '${chevauchement.toInt()}%',
                        items: [
                          DropdownMenuItem(
                            value: '10%',
                            child: Text('10%', style: const TextStyle(fontSize: 11)),
                          ),
                          DropdownMenuItem(
                            value: '15%',
                            child: Text('15%', style: const TextStyle(fontSize: 11)),
                          ),
                          DropdownMenuItem(
                            value: '20%',
                            child: Text('20%', style: const TextStyle(fontSize: 11)),
                          ),
                        ],
                        onChanged: nbProjecteurs > 1
                            ? (value) {
                                if (value != null) {
                                  setState(() {
                                    chevauchement = double.parse(value.replaceAll('%', ''));
                                  });
                                  _savePersistedState();
                                }
                              }
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  '${loc.videoPage_imageWidth} : ${largeurProjection.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.bodyMedium),
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
                    _savePersistedState();
                  },
                ),
                Text(
                  '${loc.videoPage_projectorDistance} : ${distanceProjection.toStringAsFixed(1)} m',
                  style: Theme.of(context).textTheme.bodyMedium),
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
                    _savePersistedState();
                  },
                ),
                ActionButtonRow(
                  buttons: [
                    ActionButton.photo(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ArMeasurePage()),
                        );
                      },
                    ),
                    ActionButton.calculate(
                      onPressed: () {
                        // Logique de calcul pour la projection
                        setState(() {
                          showProjectionResult = true;
                        });
                        _savePersistedState();
                        // Centrer la vue sur le résultat après un délai pour permettre le rebuild
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (scrollController.hasClients && resultKey.currentContext != null) {
                            final RenderBox renderBox = resultKey.currentContext!.findRenderObject() as RenderBox;
                            final position = renderBox.localToGlobal(Offset.zero);
                            final scrollPosition = position.dy - 100; // Offset pour centrer
                            scrollController.animateTo(
                              scrollPosition,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          }
                        });
                      },
                    ),
                    ActionButton.reset(
                      onPressed: () {
                        // Logique de reset pour la projection
                        setState(() {
                          selectedBrand = null;
                          selectedProjector = null;
                          largeurProjection = 5;
                          distanceProjection = 10;
                          selectedFormat = '16/9';
                          nbProjecteurs = 1;
                          chevauchement = 15.0;
                          showProjectionResult = false;
                          searchQuery = '';
                          searchResults = [];
                          searchController.clear();
                        });
                        _savePersistedState();
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (showProjectionResult && recommendation != null)
                  Container(
                    key: resultKey,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Center(
                          child: Column(
                            children: [
                              Text(
                                'Optique recommandée',
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                recommendation!['optique'],
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: Colors.white,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ActionButton.comment(
                                onPressed: () => _showCommentDialog('projection_tab'),
                              ),
                              const SizedBox(width: 16),
                              ExportWidget(
                                title: 'Export Projection',
                                content: 'Ratio: ${recommendation!['ratio']}\nOptique recommandée: ${recommendation!['optique']}',
                                projectType: 'proj',
                                projectData: _buildProjectionData(),
                                projectSummary: _buildProjectionSummary(),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('video_comments');
      if (commentsJson != null) {
        final Map<String, dynamic> commentsMap = json.decode(commentsJson);
        _comments = commentsMap.map((key, value) => MapEntry(key, value.toString()));
      }
    } catch (e) {
      print('Erreur lors du chargement des commentaires: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = json.encode(_comments);
      await prefs.setString('video_comments', commentsJson);
    } catch (e) {
      print('Erreur lors de la sauvegarde des commentaires: $e');
    }
  }

  String _getCommentForTab(String tabKey) {
    return _comments[tabKey] ?? '';
  }

  String _generateProjectionResultKey() {
    return 'projection_${selectedProjector?.id ?? 'none'}_${largeurProjection}_${distanceProjection}_${selectedFormat}_${nbProjecteurs}_$chevauchement';
  }

  Future<void> _showCommentDialog(String tabKey) async {
    final currentComment = _getCommentForTab(tabKey);
    final controller = TextEditingController(text: currentComment);

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Commentaire',
          style: TextStyle(fontSize: 10),
        ),
        content: TextField(
          controller: controller,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Entrez votre commentaire...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              final comment = controller.text.trim();
              if (comment.isNotEmpty) {
                _comments[tabKey] = comment;
              } else {
                _comments.remove(tabKey);
              }
              await _saveComments();
              setState(() {});
              Navigator.of(context).pop();
            },
            child: const Text('Sauvegarder'),
          ),
        ],
      ),
    );
  }
}
