import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
import '../../models/catalogue_item.dart';
import '../../models/cart_item.dart';
import '../../providers/catalogue_provider.dart';
import '../../providers/preset_provider.dart';
import '../../providers/sound_page_provider.dart';
import '../../models/sound_page_state.dart';
import '../export_widget.dart';
import '../preset_widget.dart';
import '../border_labeled_dropdown.dart';

class AmpTab extends ConsumerStatefulWidget {
  const AmpTab({super.key});

  @override
  ConsumerState<AmpTab> createState() => _AmpTabState();
}

class _AmpTabState extends ConsumerState<AmpTab> {
  final TextEditingController _searchController = TextEditingController();
  late ScrollController _scrollController;
  final GlobalKey _resultKey = GlobalKey();
  final GlobalKey _buttonsKey = GlobalKey();

  final List<String> amplifierTypes = ['LA4X', 'LA8', 'LA12X', 'Custom'];
  final List<String> soundCategories = ['Toutes', 'Line-Array', 'Wedge/Point Source', 'Sub', 'Ampli'];

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    // Initialiser le contrôleur avec la valeur persistée
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final soundState = ref.read(soundPageProvider);
      _searchController.text = soundState.searchQuery;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Getters pour accéder à l'état persistant
  SoundPageState get soundState => ref.watch(soundPageProvider);
  String get searchQuery => soundState.searchQuery;
  String? get selectedSpeaker => soundState.selectedSpeaker;
  int get speakerQuantity => soundState.speakerQuantity;
  List<Map<String, dynamic>> get selectedSpeakers => soundState.selectedSpeakers;
  List<CatalogueItem> get searchResults => soundState.searchResults;
  String? get calculationResult => soundState.calculationResult;
  String? get selectedCategory => soundState.selectedCategory;
  String? get selectedBrand => soundState.selectedBrand;

  // Getters pour récupérer les données du catalogue
  List<CatalogueItem> get soundItems => ref.watch(catalogueProvider)
      .where((item) => item.categorie == 'Son')
      .toList();

  List<String> get availableBrands {
    final brands = soundItems.map((item) => item.marque).toSet().toList()..sort();
    return ['Toutes', ...brands];
  }

  List<String> get availableSpeakers {
    return soundItems.map((item) => item.produit).toList();
  }

  List<CatalogueItem> get filteredSoundItems {
    var items = soundItems;
    
    if (selectedBrand != null && selectedBrand != 'Toutes') {
      items = items.where((item) => item.marque == selectedBrand).toList();
    }
    
    if (selectedCategory != null && selectedCategory != 'Toutes') {
      items = items.where((item) => item.sousCategorie == selectedCategory).toList();
    }
    
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        PresetWidget(
          onPresetSelected: (preset) {
            setState(() {
              final presets = ref.read(presetProvider);
              final index = presets.indexWhere((p) => p.id == preset.id);
              if (index != -1) {
                ref.read(presetProvider.notifier).selectPreset(index);
              }
            });
          },
        ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1128).withOpacity(0.3),
              border: Border.all(color: Colors.white, width: 1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  // Barre de recherche
                  TextField(
                    controller: _searchController,
                    textDirection: TextDirection.ltr,
                    style: Theme.of(context).textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)!.search_speaker,
                      hintStyle: Theme.of(context).textTheme.bodyMedium,
                      prefixIcon: const Icon(Icons.search, color: Colors.white, size: 20),
                      filled: true,
                      fillColor: Colors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                    ),
                    onChanged: (value) {
                      ref.read(soundPageProvider.notifier).updateSearchQuery(value);
                      _performSearch();
                    },
                  ),
                  const SizedBox(height: 8),
                  
                  // Menus déroulants
                  Row(
                    children: [
                      Expanded(
                        flex: 1,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.brand,
                          value: selectedBrand,
                          items: availableBrands.map((brand) => DropdownMenuItem(
                            value: brand,
                            child: Text(brand, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            ref.read(soundPageProvider.notifier).updateSelectedBrand(newValue);
                            if (searchQuery.isNotEmpty) {
                              _performSearch();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 1,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.category,
                          value: selectedCategory,
                          items: soundCategories.map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            ref.read(soundPageProvider.notifier).updateSelectedCategory(newValue);
                            if (searchQuery.isNotEmpty) {
                              _performSearch();
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Menu Enceinte
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.5,
                        child: BorderLabeledDropdown<String>(
                          label: AppLocalizations.of(context)!.speaker,
                          value: selectedSpeaker,
                          items: filteredSoundItems.map((CatalogueItem item) => DropdownMenuItem(
                            value: item.produit,
                            child: Text(item.produit, style: const TextStyle(fontSize: 11)),
                          )).toList(),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              _showQuantityDialog(context, newValue);
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  
                  // Bouton Import Preset
                  Center(
                    child: ElevatedButton(
                      onPressed: _importPresetToSoundList,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueGrey[900],
                        side: BorderSide(
                          color: Colors.blueGrey[800]!,
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
                            'Import Preset',
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
                  const SizedBox(height: 8),
                  
                  // Enceintes sélectionnées (toujours affichées)
                  Text('Enceintes sélectionnées :',
                      style: Theme.of(context).textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  if (selectedSpeakers.isNotEmpty)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: selectedSpeakers.length,
                      itemBuilder: (context, index) {
                        final speaker = selectedSpeakers[index];
                        return ListTile(
                          title: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove, color: Colors.white),
                                onPressed: () {
                                  if (speaker['quantity'] > 1) {
                                    final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                                    newSpeakers[index]['quantity'] = (speaker['quantity'] as int) - 1;
                                    ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                                  }
                                },
                              ),
                              Text(
                                '${speaker['quantity']}',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              IconButton(
                                icon: const Icon(Icons.add, color: Colors.white),
                                onPressed: () {
                                  final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                                  newSpeakers[index]['quantity'] = (speaker['quantity'] as int) + 1;
                                  ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                                },
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  speaker['name'],
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.white),
                            onPressed: () {
                              final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                              newSpeakers.removeAt(index);
                              ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                            },
                          ),
                        );
                      },
                    )
                  else
                    Text(
                      AppLocalizations.of(context)!.soundPage_noSpeakersSelected,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  const SizedBox(height: 16),
                  
                  // Résultat du calcul
                  if (calculationResult != null)
                    Container(
                      key: _resultKey,
                      margin: const EdgeInsets.all(16),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1128).withOpacity(0.3),
                        border: Border.all(color: const Color(0xFF0A1128), width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Text(
                              AppLocalizations.of(context)!.soundPage_ampConfigTitle,
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            calculationResult!,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: ExportWidget(
                              title: 'Configuration Amplification',
                              content: calculationResult!,
                              projectType: 'amp',
                              fileName: 'configuration_amplification',
                              customIcon: Icons.cloud_upload,
                              backgroundColor: Colors.blueGrey[900],
                              tooltip: 'Exporter la configuration',
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
        
        // Boutons d'action (toujours visibles en bas)
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
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
                child: const Icon(Icons.add, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 25),
              ElevatedButton(
                onPressed: _calculateAmplification,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.calculate, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 25),
              ElevatedButton(
                onPressed: () {
                  ref.read(soundPageProvider.notifier).updateSelectedSpeakers([]);
                  ref.read(soundPageProvider.notifier).clearCalculationResult();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blueGrey[900],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(12),
                ),
                child: const Icon(Icons.refresh, color: Colors.white, size: 28),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _performSearch() {
    if (searchQuery.isEmpty) {
      ref.read(soundPageProvider.notifier).updateSearchResults([]);
      return;
    }

    final allItems = ref.watch(catalogueProvider);
    final results = allItems.where((item) {
      if (item.categorie != 'Son') return false;
      
      if (selectedBrand != null && selectedBrand != 'Toutes') {
        if (!item.marque.toLowerCase().contains(selectedBrand!.toLowerCase())) {
          return false;
        }
      }
      
      if (selectedCategory != null && selectedCategory != 'Toutes') {
        final productName = item.produit.toLowerCase();
        
        switch (selectedCategory) {
          case 'Line-Array':
            if (!productName.contains('line') && 
                !productName.contains('array') && 
                !productName.contains('kiva') && 
                !productName.contains('kara') &&
                !productName.contains('k2') &&
                !productName.contains('syva')) {
              return false;
            }
            break;
          case 'Wedge/Pointsource':
            if (!productName.contains('wedge') && 
                !productName.contains('point') && 
                !productName.contains('x8') && 
                !productName.contains('x12') &&
                !productName.contains('x15')) {
              return false;
            }
            break;
          case 'Sub':
            if (!productName.contains('sub') && 
                !productName.contains('sb') && 
                !productName.contains('ks28')) {
              return false;
            }
            break;
          case 'Ampli':
            if (!productName.contains('ampli') && 
                !productName.contains('la') && 
                !productName.contains('amplifier')) {
              return false;
            }
            break;
        }
      }
      
      return item.marque.toLowerCase().contains(searchQuery.toLowerCase()) ||
             item.produit.toLowerCase().contains(searchQuery.toLowerCase());
    }).toList();
    
    ref.read(soundPageProvider.notifier).updateSearchResults(results);
  }

  void _showQuantityDialog(BuildContext context, String speaker) {
    final loc = AppLocalizations.of(context)!;
    
    // Récupérer les amplis correspondants selon la marque sélectionnée
    final allItems = ref.read(catalogueProvider);
    final amplifierItems = allItems.where((item) {
      return item.categorie == 'Son' && 
             item.sousCategorie == 'ampli' &&
             (selectedBrand == null || selectedBrand == 'Toutes' || 
              item.marque.toLowerCase().contains(selectedBrand!.toLowerCase()));
    }).toList();
    
    // Créer la liste des amplis avec "Custom" en option
    final List<String> availableAmplifiers = ['Custom'];
    availableAmplifiers.addAll(amplifierItems.map((item) => item.produit).toList());
    
    String? selectedAmplifier = availableAmplifiers.isNotEmpty ? availableAmplifiers.first : 'Custom';
    int quantity = 1;
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.blueGrey[900],
              title: Text('${loc.soundPage_quantity} $speaker',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                    fontSize: 16,
                  )),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Contrôleur de quantité avec boutons - et +
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setDialogState(() {
                              quantity--;
                            });
                          }
                        },
                        icon: Icon(
                          Icons.remove,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: CircleBorder(),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () {
                          final textController = TextEditingController(text: quantity.toString());
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              backgroundColor: Colors.blueGrey[900],
                              title: Text('Modifier la quantité',
                                  style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                  )),
                              content: TextField(
                                controller: textController,
                                keyboardType: TextInputType.number,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Quantité',
                                  hintStyle: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.light ? Colors.white70 : null,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white70),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.white),
                                  ),
                                ),
                                autofocus: true,
                                onTap: () {
                                  textController.selection = TextSelection(
                                    baseOffset: 0,
                                    extentOffset: textController.text.length,
                                  );
                                },
                                onSubmitted: (value) {
                                  final newQuantity = int.tryParse(value) ?? 1;
                                  if (newQuantity > 0) {
                                    setDialogState(() {
                                      quantity = newQuantity;
                                    });
                                  }
                                  Navigator.pop(context);
                                },
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Annuler',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                      )),
                                ),
                                TextButton(
                                  onPressed: () {
                                    final newQuantity = int.tryParse(textController.text) ?? 1;
                                    if (newQuantity > 0) {
                                      setDialogState(() {
                                        quantity = newQuantity;
                                      });
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: Text('Confirmer',
                                      style: TextStyle(
                                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                                      )),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[800],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blueGrey[600]!),
                          ),
                          child: Text(
                            quantity.toString(),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        onPressed: () {
                          setDialogState(() {
                            quantity++;
                          });
                        },
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                          size: 24,
                        ),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.blueGrey[800],
                          shape: CircleBorder(),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  BorderLabeledDropdown<String>(
                    label: AppLocalizations.of(context)!.amplifier,
                    value: selectedAmplifier,
                    items: availableAmplifiers.map((type) => DropdownMenuItem(
                      value: type,
                      child: Text(type, style: const TextStyle(fontSize: 11)),
                    )).toList(),
                    onChanged: (String? newValue) {
                      setDialogState(() {
                        selectedAmplifier = newValue;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(loc.catalogPage_cancel,
                      style: TextStyle(
                        color: Theme.of(context).brightness == Brightness.light ? Colors.white : null,
                      )),
                ),
                TextButton(
                  onPressed: () {
                    final newSpeakers = List<Map<String, dynamic>>.from(selectedSpeakers);
                    newSpeakers.add({
                      'name': speaker,
                      'quantity': quantity,
                      'amplifier': selectedAmplifier,
                    });
                    ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);
                    ref.read(soundPageProvider.notifier).updateSearchResults([]);
                    ref.read(soundPageProvider.notifier).updateSearchQuery('');
                    _searchController.clear();
                    Navigator.pop(context);
                    
                    // Centrer la vue sur les boutons après avoir ajouté une enceinte
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_buttonsKey.currentContext != null) {
                        Scrollable.ensureVisible(
                          _buttonsKey.currentContext!,
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeInOut,
                          alignment: 0.5, // Centre la vue
                        );
                      }
                    });
                  },
                  child: Text(loc.catalogPage_confirm,
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

  void _calculateAmplification() {
    // Logique de calcul simplifiée pour l'instant
    String resultMessage = '${AppLocalizations.of(context)!.soundPage_ampConfigTitle} :\n\n';
    
    if (selectedSpeakers.isEmpty) {
      resultMessage = AppLocalizations.of(context)!.soundPage_noSpeakersSelected;
    } else {
      for (var speaker in selectedSpeakers) {
        final name = speaker['name'] as String;
        final qty = speaker['quantity'] as int;
        final amp = speaker['amplifier'] as String;
        resultMessage += '$qty x $name ${AppLocalizations.of(context)!.soundPage_with} $amp\n';
      }
    }

    ref.read(soundPageProvider.notifier).updateCalculationResult(resultMessage);
  }

  void _addToPreset() {
    if (selectedSpeakers.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.soundPage_noSpeakersSelected),
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
          content: Text(AppLocalizations.of(context)!.soundPage_noPresetSelected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final preset = ref.read(presetProvider)[selectedPresetIndex];
    
    for (var speaker in selectedSpeakers) {
      final speakerName = speaker['name'] as String;
      final quantity = speaker['quantity'] as int;
      
      final catalogueItem = soundItems.firstWhere(
        (item) => item.produit == speakerName,
        orElse: () => throw Exception('Item non trouvé: $speakerName'),
      );
      
      final existingIndex = preset.items.indexWhere(
        (item) => item.item.id == catalogueItem.id,
      );
      
      if (existingIndex != -1) {
        preset.items[existingIndex] = CartItem(
          item: catalogueItem,
          quantity: quantity,
        );
      } else {
        preset.items.add(
          CartItem(
            item: catalogueItem,
            quantity: quantity,
          ),
        );
      }
    }
    
    presetNotifier.updatePreset(preset);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${selectedSpeakers.length} enceinte(s) ajoutée(s) au preset'),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _importPresetToSoundList() {
    final presets = ref.read(presetProvider);
    
    if (presets.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun preset disponible à importer'),
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
            'Sélectionner un preset',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 300,
            child: ListView.builder(
              itemCount: presets.length,
              itemBuilder: (context, index) {
                final preset = presets[index];
                final soundItemsCount = preset.items
                    .where((item) => item.item.categorie == 'Son')
                    .length;
                
                return ListTile(
                  title: Text(
                    preset.name,
                    style: TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    '$soundItemsCount appareil(s) son',
                    style: TextStyle(color: Colors.white70),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.white),
                  onTap: () {
                    Navigator.of(context).pop();
                    _importSoundItemsFromPreset(preset);
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _importSoundItemsFromPreset(preset) {
    ref.read(soundPageProvider.notifier).updateSelectedSpeakers([]);
    
    int importedCount = 0;
    final newSpeakers = <Map<String, dynamic>>[];
    for (var item in preset.items) {
      if (item.item.categorie == 'Son') {
        newSpeakers.add({
          'name': item.item.produit,
          'quantity': item.quantity,
          'amplifier': 'LA4X',
        });
        importedCount++;
      }
    }

    ref.read(soundPageProvider.notifier).updateSelectedSpeakers(newSpeakers);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$importedCount appareil(s) importé(s) depuis "${preset.name}"'),
        backgroundColor: Colors.green,
      ),
    );
  }
}
