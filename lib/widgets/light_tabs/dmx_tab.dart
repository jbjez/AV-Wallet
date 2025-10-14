import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/preset_provider.dart';
import '../../providers/page_state_provider.dart';
import '../../models/catalogue_item.dart';
import '../../models/cart_item.dart';
import '../../models/preset.dart';
import '../../widgets/export_widget.dart';
import '../../widgets/border_labeled_dropdown.dart';
import '../../widgets/preset_widget.dart';
import '../../widgets/action_button.dart';

class DmxTab extends ConsumerStatefulWidget {
  const DmxTab({super.key});

  @override
  ConsumerState<DmxTab> createState() => _DmxTabState();
}

class _DmxTabState extends ConsumerState<DmxTab> {
  // Utilisation du provider de persistance
  LightPageState get lightState => ref.watch(lightPageStateProvider);
  
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  final GlobalKey _resultKey = GlobalKey();
  final GlobalKey _buttonsKey = GlobalKey();
  
  // Gestion des commentaires
  Map<String, String> _comments = {}; // Clé: "dmx_result", Valeur: commentaire

  List<String> get dmxTypes => [
    AppLocalizations.of(context)!.dmxPage_dmxMini,
    AppLocalizations.of(context)!.dmxPage_dmxMax,
  ];
  
  List<String> get lightCategories => [
    AppLocalizations.of(context)!.dmxPage_allCategories,
    AppLocalizations.of(context)!.dmxPage_movingHead,
    AppLocalizations.of(context)!.dmxPage_ledBar,
    AppLocalizations.of(context)!.dmxPage_strobe,
    AppLocalizations.of(context)!.dmxPage_scanner,
    AppLocalizations.of(context)!.dmxPage_wash,
  ];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _loadComments();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _searchController.text = lightState.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('dmx_comments');
      if (commentsJson != null) {
        setState(() {
          _comments = Map<String, String>.from(json.decode(commentsJson));
        });
      }
    } catch (e) {
      print('Error loading comments: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('dmx_comments', json.encode(_comments));
      // Nettoyer les anciens commentaires après sauvegarde
      await _cleanupOldComments();
    } catch (e) {
      print('Error saving comments: $e');
    }
  }

  String _getCommentForDmxResult() {
    if (lightState.dmxCalculationResult == null) return '';
    // Utiliser le hash du résultat comme clé pour que chaque calcul ait son propre commentaire
    final resultHash = lightState.dmxCalculationResult!.hashCode.toString();
    return _comments[resultHash] ?? '';
  }

  Future<void> _showCommentDialog() async {
    if (lightState.dmxCalculationResult == null) return;
    
    final TextEditingController commentController = TextEditingController(
      text: _getCommentForDmxResult(),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1128)
              : Colors.white,
          title: Text(
            'Com. DMX',
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white
                  : Colors.black,
            ),
          ),
          content: SizedBox(
            width: 300, // Largeur fixe pour éviter le resserrement
            child: TextField(
              controller: commentController,
              maxLines: 3,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire pour cette configuration DMX...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : Colors.black,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                final resultHash = lightState.dmxCalculationResult!.hashCode.toString();
                setState(() {
                  if (comment.isEmpty) {
                    _comments.remove(resultHash);
                  } else {
                    _comments[resultHash] = comment;
                  }
                });
                await _saveComments();
                Navigator.of(context).pop();
              },
              child: const Text('Sauvegarder'),
            ),
          ],
        );
      },
    );
  }

  // Méthode pour construire le contenu d'export avec commentaire
  String _buildExportContent() {
    final result = lightState.dmxCalculationResult ?? '';
    final comment = _getCommentForDmxResult();
    
    String content = result;
    
    if (comment.isNotEmpty) {
      content += '\n\nCommentaire:\n$comment';
    }
    
    return content;
  }

  // Méthode pour nettoyer les anciens commentaires (optionnel)
  Future<void> _cleanupOldComments() async {
    try {
      // Garder seulement les commentaires des 10 derniers résultats
      if (_comments.length > 10) {
        final sortedEntries = _comments.entries.toList()
          ..sort((a, b) => b.key.compareTo(a.key)); // Trier par clé (hash)
        
        final toKeep = sortedEntries.take(10).toList();
        setState(() {
          _comments = Map.fromEntries(toKeep);
        });
        await _saveComments();
      }
    } catch (e) {
      print('Error cleaning up old comments: $e');
    }
  }

  // Méthode pour faire le focus sur les boutons
  void _focusOnButtons() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_buttonsKey.currentContext != null) {
        Scrollable.ensureVisible(
          _buttonsKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  // Getters pour récupérer les données du catalogue
  List<CatalogueItem> get lightItems => ref.watch(catalogueProvider)
      .where((item) => item.categorie == 'Lumière')
      .toList();

  List<String> get _uniqueBrands {
    final items = lightItems;
    return items
        .where((item) => item.marque.isNotEmpty)
        .map((item) => item.marque)
        .toSet()
        .toList()
      ..sort();
  }

  List<String> get _filteredProducts {
    final items = lightItems;
    final filtered = items
        .where((item) {
          if (lightState.selectedBrand != null && lightState.selectedBrand != 'Toutes') {
            if (item.marque != lightState.selectedBrand) return false;
          }
          if (lightState.selectedCategory != null && lightState.selectedCategory != 'Toutes') {
            if (item.sousCategorie != lightState.selectedCategory) return false;
          }
          if (lightState.searchQuery.isNotEmpty) {
            if (!item.produit.toLowerCase().contains(lightState.searchQuery.toLowerCase()) &&
                !item.marque.toLowerCase().contains(lightState.searchQuery.toLowerCase())) {
              return false;
            }
          }
          return true;
        })
        .map((item) => item.produit)
        .toList();
    
    
    return filtered;
  }

  void _calculateDMX() {
    if (lightState.selectedFixtures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dmxPage_noProductsSelected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }


    // Liste des machines WiFi qui nécessitent un univers séparé
    final wifiMachines = ['Titan', 'Helios', 'AX3', 'AX2'];
    
    // Séparer les produits en machines WiFi et machines câblées
    List<CatalogueItem> wifiProducts = [];
    List<CatalogueItem> wiredProducts = [];
    
    for (var fixture in lightState.selectedFixtures) {
      final productName = fixture.produit;
      bool isWifi = wifiMachines.any((wifi) => productName.toLowerCase().contains(wifi.toLowerCase()));
      
      if (isWifi) {
        wifiProducts.add(fixture);
      } else {
        wiredProducts.add(fixture);
      }
    }

    // Calculer les canaux pour chaque produit
    Map<String, int> productChannels = {};
    for (var fixture in lightState.selectedFixtures) {
      final productName = fixture.produit;
      final dmxType = lightState.fixtureDmxModes[fixture] ?? AppLocalizations.of(context)!.dmxPage_dmxMini;

      int channelsPerProduct;
      if (dmxType == AppLocalizations.of(context)!.dmxPage_dmxMini && fixture.dmxMini != null) {
        channelsPerProduct = int.tryParse(fixture.dmxMini!) ?? 8;
      } else if (dmxType == AppLocalizations.of(context)!.dmxPage_dmxMax && fixture.dmxMax != null) {
        channelsPerProduct = int.tryParse(fixture.dmxMax!) ?? 16;
      } else {
        channelsPerProduct = 8;
      }

      productChannels[productName] = channelsPerProduct;
    }

    // Calculer le nombre d'univers nécessaires
    int wiredChannels = 0;
    for (var fixture in wiredProducts) {
      final productName = fixture.produit;
      final quantity = lightState.fixtureQuantities[fixture] ?? 1;
      wiredChannels += productChannels[productName]! * quantity;
    }
    
    int wiredUniverses = wiredChannels > 0 ? (wiredChannels / 512).ceil() : 0;
    
    // Calculer le nombre d'univers WiFi nécessaires (respecter la limite de 512 canaux)
    int wifiChannels = 0;
    for (var fixture in wifiProducts) {
      final productName = fixture.produit;
      final quantity = lightState.fixtureQuantities[fixture] ?? 1;
      final channelsPerProduct = productChannels[productName]!;
      wifiChannels += channelsPerProduct * quantity;
    }
    int wifiUniverses = wifiChannels > 0 ? (wifiChannels / 512).ceil() : 0;
    int totalUniverses = wiredUniverses + wifiUniverses;

    // Construire le résultat
    String resultMessage = '$totalUniverses ${AppLocalizations.of(context)!.dmxPage_universesNeeded}\n\n';

    // Traiter les machines câblées
    if (wiredProducts.isNotEmpty && wiredChannels > 0) {
      print('=== DEBUG WIRED DISTRIBUTION ===');
      print('Wired products count: ${wiredProducts.length}');
      print('Wired channels: $wiredChannels');
      print('Wired universes: $wiredUniverses');
      
      // Créer une liste de maps pour les calculs (comme avant)
      List<Map<String, dynamic>> remainingWiredProducts = wiredProducts.map((fixture) => {
        'name': fixture.produit,
        'quantity': lightState.fixtureQuantities[fixture] ?? 1,
        'dmxType': lightState.fixtureDmxModes[fixture] ?? AppLocalizations.of(context)!.dmxPage_dmxMini,
        'fixture': fixture, // Garder la référence au fixture original
      }).toList();
      
      for (int universe = 1; universe <= wiredUniverses; universe++) {
        print('Processing universe $universe');
        resultMessage += '${AppLocalizations.of(context)!.dmxPage_universe} $universe / $totalUniverses (${AppLocalizations.of(context)!.dmxPage_wired}) :\n';
        
        int channelsUsedInUniverse = 0;
        int currentChannel = 1; // Réinitialiser à 1 pour chaque univers
        List<String> universeProducts = [];
        List<Map<String, dynamic>> productsToRemove = [];
        
        print('Remaining products for universe $universe: ${remainingWiredProducts.length}');
        
        // Traiter tous les produits restants pour cet univers
        for (int i = remainingWiredProducts.length - 1; i >= 0; i--) {
          var product = remainingWiredProducts[i];
          final productName = product['name'] as String;
          final quantity = product['quantity'] as int;
          final dmxType = product['dmxType'] as String;
          final channelsPerProduct = productChannels[productName]!;
          
          print('Product: $productName, quantity: $quantity, channels: $channelsPerProduct');
          print('Current universe channels: $channelsUsedInUniverse');
          
          // Calculer combien de machines peuvent rentrer dans cet univers
          int availableChannels = 512 - channelsUsedInUniverse;
          int machinesThatFit = availableChannels ~/ channelsPerProduct;
          
          if (machinesThatFit > 0) {
            int machinesToAdd = machinesThatFit < quantity ? machinesThatFit : quantity;
            int channelsUsed = machinesToAdd * channelsPerProduct;
            
            final startChannel = currentChannel;
            final endChannel = currentChannel + channelsUsed - 1;
            final productLine = '  • $machinesToAdd x $productName $dmxType : $startChannel - $endChannel';
            universeProducts.add(productLine);
            print('Added to universe: $productLine');
            
            currentChannel += channelsUsed;
            channelsUsedInUniverse += channelsUsed;
            
            // Mettre à jour la quantité restante
            if (machinesToAdd == quantity) {
              // Toutes les machines de ce produit sont ajoutées
              productsToRemove.add(product);
            } else {
              // Mettre à jour la quantité restante
              product['quantity'] = quantity - machinesToAdd;
              // Mettre à jour aussi dans le provider
              final fixture = product['fixture'] as CatalogueItem;
              ref.read(lightPageStateProvider.notifier).updateSingleFixtureQuantity(
                fixture, 
                quantity - machinesToAdd
              );
            }
          } else {
            print('No machines of this type can fit in universe $universe');
          }
        }
        
        // Retirer les produits traités
        for (var product in productsToRemove) {
          remainingWiredProducts.remove(product);
        }
        
        print('Universe $universe final products: ${universeProducts.length}');
        print('Universe $universe channels used: $channelsUsedInUniverse');
        
        // Ajouter les produits de cet univers
        for (String productLine in universeProducts) {
          resultMessage += productLine + '\n';
        }
        
        resultMessage += '  (${AppLocalizations.of(context)!.dmxPage_channelsUsed}: $channelsUsedInUniverse/512 ${AppLocalizations.of(context)!.dmxPage_channelsTotal})\n\n';
      }
      
      print('Final result message length: ${resultMessage.length}');
      print('=== END WIRED DISTRIBUTION ===');
    } else {
      print('No wired products or channels: wiredProducts=${wiredProducts.length}, wiredChannels=$wiredChannels');
    }

    // Traiter les machines WiFi (respecter la limite de 512 canaux par univers)
    if (wifiProducts.isNotEmpty) {
      print('=== DEBUG WIFI DISTRIBUTION ===');
      print('WiFi products count: ${wifiProducts.length}');
      print('WiFi channels: $wifiChannels');
      print('WiFi universes: $wifiUniverses');
      
      List<CatalogueItem> remainingWifiProducts = List.from(wifiProducts);
      int currentUniverse = wiredUniverses + 1;
      
      while (remainingWifiProducts.isNotEmpty) {
        resultMessage += '${AppLocalizations.of(context)!.dmxPage_universe} $currentUniverse / $totalUniverses (WiFi) :\n';
        
        int channelsUsedInUniverse = 0;
        int currentChannel = 1;
        List<CatalogueItem> productsToRemove = [];
        
        print('Processing WiFi universe $currentUniverse');
        print('Remaining WiFi products: ${remainingWifiProducts.length}');
        
        // Traiter tous les produits WiFi restants pour cet univers
        for (int i = remainingWifiProducts.length - 1; i >= 0; i--) {
          final fixture = remainingWifiProducts[i];
          final productName = fixture.produit;
          final quantity = lightState.fixtureQuantities[fixture] ?? 1;
          final dmxType = lightState.fixtureDmxModes[fixture] ?? AppLocalizations.of(context)!.dmxPage_dmxMini;
          final channelsPerProduct = productChannels[productName]!;
          final totalChannelsForProduct = channelsPerProduct * quantity;
          
          print('WiFi Product: $productName, quantity: $quantity, channels: $channelsPerProduct, total: $totalChannelsForProduct');
          print('Current universe channels: $channelsUsedInUniverse');
          
          // Vérifier si ce produit peut tenir dans cet univers
          if (channelsUsedInUniverse + totalChannelsForProduct <= 512) {
            resultMessage += '  • $quantity x $productName $dmxType : $currentChannel - ${currentChannel + totalChannelsForProduct - 1}\n';
            channelsUsedInUniverse += totalChannelsForProduct;
            currentChannel += totalChannelsForProduct;
            productsToRemove.add(fixture);
            print('Added to universe $currentUniverse, channels used: $channelsUsedInUniverse');
          } else {
            print('Product $productName does not fit in universe $currentUniverse, will go to next universe');
            break; // Sortir de la boucle car les produits suivants ne rentreront pas non plus
          }
        }
        
        // Supprimer les produits traités de la liste restante
        for (var product in productsToRemove) {
          remainingWifiProducts.remove(product);
        }
        
        resultMessage += '  (${AppLocalizations.of(context)!.dmxPage_channelsUsed}: $channelsUsedInUniverse/512 ${AppLocalizations.of(context)!.dmxPage_channelsTotal})\n\n';
        currentUniverse++;
        
        print('Universe $currentUniverse completed, channels used: $channelsUsedInUniverse');
        print('Remaining products: ${remainingWifiProducts.length}');
      }
      
      print('=== END WIFI DISTRIBUTION ===');
    }

    ref.read(lightPageStateProvider.notifier).updateDmxCalculation(resultMessage);

    // Auto-scroll vers le résultat
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_resultKey.currentContext != null) {
        Scrollable.ensureVisible(
          _resultKey.currentContext!,
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _addToPreset() {
    if (lightState.selectedFixtures.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dmxPage_noProductsSelected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final presetNotifier = ref.read(presetProvider.notifier);
    final selectedPresetIndex = presetNotifier.selectedPresetIndex;
    
    if (selectedPresetIndex < 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dmxPage_noPresetSelected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final preset = ref.read(presetProvider)[selectedPresetIndex];
    
    // Convertir les produits sélectionnés en CatalogueItem et les ajouter au preset
    for (var fixture in lightState.selectedFixtures) {
      final productName = fixture.produit;
      final quantity = lightState.fixtureQuantities[fixture] ?? 1;
      
      // Trouver l'item correspondant dans le catalogue
      final catalogueItem = lightItems.firstWhere(
        (item) => item.produit == productName,
        orElse: () => throw Exception('Item non trouvé: $productName'),
      );
      
      // Vérifier si l'item existe déjà dans le preset
      final existingIndex = preset.items.indexWhere(
        (item) => item.item.id == catalogueItem.id,
      );
      
      if (existingIndex != -1) {
        // Mettre à jour la quantité
        preset.items[existingIndex] = CartItem(
          item: catalogueItem,
          quantity: quantity,
        );
      } else {
        // Ajouter un nouvel item
        preset.items.add(
          CartItem(
            item: catalogueItem,
            quantity: quantity,
          ),
        );
      }
    }
    
    // Sauvegarder le preset
    presetNotifier.updatePreset(preset);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${lightState.selectedFixtures.length} ${AppLocalizations.of(context)!.dmxPage_productsAddedToPreset}'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showQuantityDialog(BuildContext context, String product) {
    final loc = AppLocalizations.of(context)!;
    int quantity = 1;
    
    String? selectedDmxType = dmxTypes.first;
    
    // Trouver l'item du catalogue correspondant au produit sélectionné
    final catalogueItem = lightItems.firstWhere(
      (item) => item.produit == product,
      orElse: () => lightItems.first,
    );
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              title: Text('${loc.soundPage_quantity} $product',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                    fontSize: 16,
                  )),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Sélection de la quantité (en premier)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() {
                              quantity--;
                            });
                          }
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                        ),
                      ),
                      Container(
                        width: 80,
                        alignment: Alignment.center,
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                final quantityController = TextEditingController(text: quantity.toString());
                                return AlertDialog(
                                  backgroundColor: Colors.blueGrey[900],
                                  title: Text(AppLocalizations.of(context)!.quantity,
                                      style: TextStyle(color: Colors.white)),
                                  content: TextField(
                                    controller: quantityController,
                                    keyboardType: TextInputType.number,
                                    autofocus: true,
                                    style: TextStyle(
                                      color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: AppLocalizations.of(context)!.dmxPage_quantityEnter,
                                      hintStyle: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.black54 : Colors.white70,
                                      ),
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: Text(AppLocalizations.of(context)!.dmxPage_cancel,
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        final newQuantity = int.tryParse(quantityController.text) ?? 1;
                                        if (newQuantity > 0) {
                                          setDialogState(() {
                                            quantity = newQuantity;
                                          });
                                        }
                                        Navigator.pop(context);
                                      },
                                      child: Text(AppLocalizations.of(context)!.dmxPage_ok,
                                          style: TextStyle(color: Colors.white)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey[400]!, width: 1),
                            ),
                            child: Text(
                              quantity.toString(),
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                          });
                        },
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: const CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Sélection du type DMX
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonFormField<String>(
                      value: selectedDmxType,
                      decoration: InputDecoration(
                        labelText: AppLocalizations.of(context)!.dmxPage_dmxType,
                        labelStyle: TextStyle(color: Colors.white),
                        filled: true,
                        fillColor: Colors.transparent,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.3)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
                        ),
                      ),
                      dropdownColor: Colors.blueGrey[800],
                      style: const TextStyle(color: Colors.white),
                      items: dmxTypes.map((String type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(type, style: const TextStyle(color: Colors.white)),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setDialogState(() {
                          selectedDmxType = newValue;
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Affichage des informations DMX du produit
                  if (catalogueItem.dmxMini != null || catalogueItem.dmxMax != null) ...[
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[800],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          if (catalogueItem.dmxMini != null)
                            Text('${AppLocalizations.of(context)!.dmxPage_dmxMini}: ${catalogueItem.dmxMini}',
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                          if (catalogueItem.dmxMax != null)
                            Text('${AppLocalizations.of(context)!.dmxPage_dmxMax}: ${catalogueItem.dmxMax}',
                                style: const TextStyle(color: Colors.white, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(AppLocalizations.of(context)!.dmxPage_cancel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                      )),
                ),
                TextButton(
                  onPressed: () {
                    // Ajouter le produit au provider
                    final newFixtures = List<CatalogueItem>.from(lightState.selectedFixtures);
                    if (!newFixtures.contains(catalogueItem)) {
                      newFixtures.add(catalogueItem);
                    }
                    
                    // Mettre à jour les quantités et modes DMX
                    final newQuantities = Map<CatalogueItem, int>.from(lightState.fixtureQuantities);
                    final newDmxModes = Map<CatalogueItem, String>.from(lightState.fixtureDmxModes);
                    
                    newQuantities[catalogueItem] = quantity;
                    newDmxModes[catalogueItem] = selectedDmxType!;
                    
                    // Mettre à jour le provider
                    ref.read(lightPageStateProvider.notifier).updateSelectedFixtures(newFixtures);
                    ref.read(lightPageStateProvider.notifier).updateFixtureQuantities(newQuantities);
                    ref.read(lightPageStateProvider.notifier).updateFixtureDmxModes(newDmxModes);
                    ref.read(lightPageStateProvider.notifier).updateSearchQuery('');
                    ref.read(lightPageStateProvider.notifier).updateSelectedBrand(null);
                    ref.read(lightPageStateProvider.notifier).updateSelectedCategory(null);
                    
                    _searchController.clear();
                    Navigator.pop(context);
                    // Focus sur les boutons après ajout d'un article
                    _focusOnButtons();
                  },
                  child: Text(AppLocalizations.of(context)!.dmxPage_confirm,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                      )),
                ),
              ],
            );
          },
        );
      },
    );
  }


  void _importPresetToLightList() {
    final presets = ref.read(presetProvider);
    
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.dmxPage_noPresetAvailable),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _showPresetSelectionDialog();
  }

  void _showPresetSelectionDialog() {
    final presets = ref.read(presetProvider);
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.blueGrey[900],
          title: Text(
            AppLocalizations.of(context)!.dmxPage_selectPreset,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Container(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                final lightItemsCount = preset.items
                    .where((item) => item.item.categorie == 'Lumière')
                    .length;
                
                return ListTile(
                  title: Text(
                    preset.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '$lightItemsCount ${AppLocalizations.of(context)!.dmxPage_lightDevices}',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importLightItemsFromPreset(preset);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                AppLocalizations.of(context)!.dmxPage_cancel,
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _importLightItemsFromPreset(Preset preset) {
    // Réinitialiser la sélection actuelle
    ref.read(lightPageStateProvider.notifier).updateSelectedFixtures([]);
    ref.read(lightPageStateProvider.notifier).updateFixtureQuantities({});
    ref.read(lightPageStateProvider.notifier).updateFixtureDmxModes({});
    ref.read(lightPageStateProvider.notifier).updateDmxCalculation(null);
    
    // Importer les éléments lumière du preset
    int importedCount = 0;
    final newProducts = <Map<String, dynamic>>[];
    for (var item in preset.items) {
      if (item.item.categorie == 'Lumière') {
        newProducts.add({
          'name': item.item.produit,
          'quantity': item.quantity,
          'dmxType': 'DMX Mini', // Valeur par défaut
        });
        importedCount++;
      }
    }

    // Mettre à jour le provider avec les nouveaux produits
    final newFixtures = <CatalogueItem>[];
    final newQuantities = <CatalogueItem, int>{};
    final newDmxModes = <CatalogueItem, String>{};
    
    for (var product in newProducts) {
      final productName = product['name'] as String;
      final quantity = product['quantity'] as int;
      final dmxType = product['dmxType'] as String;
      
      final fixture = lightItems.firstWhere(
        (item) => item.produit == productName,
        orElse: () => lightItems.first,
      );
      
      newFixtures.add(fixture);
      newQuantities[fixture] = quantity;
      newDmxModes[fixture] = dmxType;
    }
    
    ref.read(lightPageStateProvider.notifier).updateSelectedFixtures(newFixtures);
    ref.read(lightPageStateProvider.notifier).updateFixtureQuantities(newQuantities);
    ref.read(lightPageStateProvider.notifier).updateFixtureDmxModes(newDmxModes);

    // Focus sur les boutons après import de preset
    _focusOnButtons();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$importedCount ${AppLocalizations.of(context)!.dmxPage_importedFromPreset} "${preset.name}"'),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      child: Column(
        children: [
          // Preset Widget
          const PresetWidget(),
          // Cadre principal
          Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                // Barre de recherche
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: _searchController,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.dmxPage_searchHint,
                      hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white.withOpacity(0.7)
                            : Colors.black.withOpacity(0.7),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                        size: 20,
                      ),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                    onChanged: (value) {
                      ref.read(lightPageStateProvider.notifier).updateSearchQuery(value);
                    },
                  ),
                ),
                
                // Résultats de recherche
                if (lightState.searchQuery.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _filteredProducts.length,
                      itemBuilder: (context, index) {
                        final productName = _filteredProducts[index];
                        final item = lightItems.firstWhere(
                          (item) => item.produit == productName,
                          orElse: () => lightItems.first,
                        );
                        return InkWell(
                          onTap: () {
                            ref.read(lightPageStateProvider.notifier).updateSelectedBrand(item.marque);
                            ref.read(lightPageStateProvider.notifier).updateSelectedProduct(item.produit);
                            ref.read(lightPageStateProvider.notifier).updateSearchQuery('');
                            _searchController.clear();
                            _showQuantityDialog(context, item.produit);
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
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  item.sousCategorie,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                
                // Menus déroulants
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: BorderLabeledDropdown<String>(
                              label: AppLocalizations.of(context)!.brand,
                              value: lightState.selectedBrand,
                              items: _uniqueBrands.map((brand) => DropdownMenuItem(
                                value: brand,
                                child: Text(brand, style: const TextStyle(fontSize: 11)),
                              )).toList(),
                              onChanged: (value) {
                                ref.read(lightPageStateProvider.notifier).updateSelectedBrand(value);
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: BorderLabeledDropdown<String>(
                              label: AppLocalizations.of(context)!.category,
                              value: lightState.selectedCategory,
                              items: lightCategories.map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category, style: const TextStyle(fontSize: 11)),
                              )).toList(),
                              onChanged: (value) {
                                ref.read(lightPageStateProvider.notifier).updateSelectedCategory(value);
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Menu Produits centré avec 50% de la largeur
                      Center(
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: BorderLabeledDropdown<String>(
                            label: AppLocalizations.of(context)!.product,
                            value: _filteredProducts.contains(lightState.selectedProduct) ? lightState.selectedProduct : null,
                            items: _filteredProducts.map((product) => DropdownMenuItem(
                              value: product,
                              child: Text(product, style: const TextStyle(fontSize: 11)),
                            )).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                _showQuantityDialog(context, value);
                              }
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Bouton Import Preset
                      Center(
                        child: ElevatedButton(
                          onPressed: _importPresetToLightList,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1565C0),
                            side: BorderSide(
                              color: const Color(0xFF1976D2),
                              width: 1,
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.download, color: Colors.white, size: 16),
                              SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.dmxPage_importPreset,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                // Articles sélectionnés
                if (lightState.selectedFixtures.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.3),
                      border: Border.all(color: Colors.white, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppLocalizations.of(context)!.dmxPage_selectedProducts,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: lightState.selectedFixtures.length,
                          itemBuilder: (context, index) {
                            final fixture = lightState.selectedFixtures[index];
                            final quantity = lightState.fixtureQuantities[fixture] ?? 1;
                            final dmxType = lightState.fixtureDmxModes[fixture] ?? AppLocalizations.of(context)!.dmxPage_dmxMini;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          color: const Color(0xFF0A1128).withOpacity(0.5),
          child: Padding(
                                padding: const EdgeInsets.all(8),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Ligne 1: Nom de l'article
                                    Text(
                                      fixture.produit,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    // Ligne 2: Contrôles de quantité
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        // Boutons de quantité à gauche
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            IconButton(
                                              icon: const Icon(Icons.remove, color: Colors.white, size: 16),
                                              onPressed: () {
                                                if (quantity > 1) {
                                                  final newQuantities = Map<CatalogueItem, int>.from(lightState.fixtureQuantities);
                                                  newQuantities[fixture] = quantity - 1;
                                                  ref.read(lightPageStateProvider.notifier).updateFixtureQuantities(newQuantities);
                                                }
                                              },
                                            ),
                                            // Affichage de la quantité entre les boutons
                                            Container(
                                              width: 30,
                                              alignment: Alignment.center,
                                              child: Text(
                                                '$quantity',
                                                style: TextStyle(
                                                  color: Theme.of(context).brightness == Brightness.light ? Colors.black : Colors.white,
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            IconButton(
                                              icon: const Icon(Icons.add, color: Colors.white, size: 16),
                                              onPressed: () {
                                                final newQuantities = Map<CatalogueItem, int>.from(lightState.fixtureQuantities);
                                                newQuantities[fixture] = quantity + 1;
                                                ref.read(lightPageStateProvider.notifier).updateFixtureQuantities(newQuantities);
                                              },
                                            ),
                                          ],
                                        ),
                                        // Bouton de suppression à droite
                                        IconButton(
                                          icon: const Icon(Icons.delete, color: Colors.red, size: 16),
                                          onPressed: () {
                                            final newFixtures = List<CatalogueItem>.from(lightState.selectedFixtures);
                                            final newQuantities = Map<CatalogueItem, int>.from(lightState.fixtureQuantities);
                                            final newDmxModes = Map<CatalogueItem, String>.from(lightState.fixtureDmxModes);
                                            
                                            newFixtures.removeAt(index);
                                            newQuantities.remove(fixture);
                                            newDmxModes.remove(fixture);
                                            
                                            ref.read(lightPageStateProvider.notifier).updateSelectedFixtures(newFixtures);
                                            ref.read(lightPageStateProvider.notifier).updateFixtureQuantities(newQuantities);
                                            ref.read(lightPageStateProvider.notifier).updateFixtureDmxModes(newDmxModes);
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
                // Boutons icônes
                Row(
                  key: _buttonsKey,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: _addToPreset,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.add,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 25),
                    ElevatedButton(
                      onPressed: _calculateDMX,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.calculate,
                          color: Colors.white, size: 28),
                    ),
                    const SizedBox(width: 25),
                    ElevatedButton(
                      onPressed: () {
                        // Reset complet de l'état
                        ref.read(lightPageStateProvider.notifier).reset();
                        // Vider le contrôleur de recherche
                        _searchController.clear();
                        // Forcer la mise à jour de l'interface
                        setState(() {});
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.all(12),
                      ),
                      child: const Icon(Icons.refresh,
                          color: Colors.white, size: 28),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Résultat - toujours visible s'il existe
                if (lightState.dmxCalculationResult != null)
                  Container(
                    key: _resultKey,
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1128).withOpacity(0.5),
                      border: Border.all(color: Colors.blueGrey[600]!, width: 1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Titre "Map DMX" avec nom du projet
                        Center(
                          child: Text(
                            '${AppLocalizations.of(context)!.dmxPage_mapDmx} \'${ref.watch(activePresetProvider)?.name ?? 'Preset'}\'',
                            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Center(
                          child: Text(
                            lightState.dmxCalculationResult!,
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        
                        // Commentaire utilisateur (au-dessus des boutons)
                        if (_getCommentForDmxResult().isNotEmpty) ...[
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.blue[900]?.withOpacity(0.3)
                                  : Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue[300]!
                                    : Colors.blue[300]!,
                                width: 1,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.chat_bubble_outline,
                                  size: 16,
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? Colors.lightBlue[300]
                                      : Colors.blue[700],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _getCommentForDmxResult(),
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? Colors.white
                                        : Colors.black87,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 12),
                        ],
                        
                        // Boutons d'action
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Bouton Commentaire (icône uniquement)
                            ActionButton.comment(
                              onPressed: () => _showCommentDialog(),
                              iconSize: 28,
                            ),
                            const SizedBox(width: 20),
                            // Bouton Export
                            ExportWidget(
                              title: 'Configuration DMX',
                              content: _buildExportContent(),
                              projectType: 'dmx',
                              fileName: 'configuration_dmx',
                              customIcon: Icons.cloud_upload,
                              backgroundColor: Colors.blueGrey[900],
                              tooltip: 'Exporter la configuration',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ],
      ),
    );
  }
}