// Nouvelle page CalculProjetPage
import 'package:flutter/material.dart';
import '../services/translation_service.dart';
import 'catalogue_page.dart';
import 'light_menu_page.dart';
import 'structure_menu_page.dart';
import 'sound_menu_page.dart';
import 'video_menu_page.dart';
import 'electricite_menu_page.dart';
import 'divers_menu_page.dart';
import '../widgets/preset_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/preset_provider.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../models/preset.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/project_provider.dart';
import '../widgets/export_widget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CalculProjetPage extends ConsumerStatefulWidget {
  const CalculProjetPage({super.key});

  @override
  ConsumerState<CalculProjetPage> createState() => _CalculProjetPageState();
}

class _CalculProjetPageState extends ConsumerState<CalculProjetPage> {
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  bool showSearchResults = false;

  void _navigateTo(int index) {
    final pages = [
      const CataloguePage(),
      const LightMenuPage(),
      const StructureMenuPage(),
      const SoundMenuPage(),
      const VideoMenuPage(),
      const ElectriciteMenuPage(),
      const DiversMenuPage(),
    ];
    Offset beginOffset;
    if (index == 0 || index == 1) {
      beginOffset = const Offset(-1.0, 0.0);
    } else if (index == 5 || index == 6) {
      beginOffset = const Offset(1.0, 0.0);
    } else {
      beginOffset = Offset.zero;
    }
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => pages[index],
        transitionsBuilder: (_, animation, __, child) {
          if (beginOffset == Offset.zero) {
            return FadeTransition(opacity: animation, child: child);
          } else {
            final tween = Tween(begin: beginOffset, end: Offset.zero)
                .chain(CurveTween(curve: Curves.easeInOut));
            return SlideTransition(
                position: animation.drive(tween), child: child);
          }
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  void _showQuantityDialog(CatalogueItem item, int initialQuantity) {
    int quantity = initialQuantity;
    bool isFirstInput = true;
    final TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            void updateQuantity(String value) {
              // Si c'est la première saisie, effacer le contenu initial
              if (isFirstInput && value.isNotEmpty) {
                isFirstInput = false;
                quantityController.clear();
                return;
              }
              
              // Si la valeur est vide, ne rien faire
              if (value.isEmpty) return;
              
              // Remplacer complètement la quantité par la nouvelle valeur
              final newQuantity = int.tryParse(value) ?? 1;
              if (newQuantity > 0) {
                setState(() {
                  quantity = newQuantity;
                });
              }
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF0A1128)
                  : Colors.white,
              title: Text(
                AppLocalizations.of(context)!.projectPage_enterQuantity,
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.white
                      : Colors.black,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.marque} - ${item.produit}',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              quantityController.text = quantity.toString();
                            });
                          }
                        },
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                      SizedBox(
                        width: 80,
                        child: TextField(
                          controller: quantityController,
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white
                                : Colors.black,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white.withOpacity(0.5)
                                    : Colors.black.withOpacity(0.5),
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                              borderSide: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.white
                                    : Colors.black,
                              ),
                            ),
                          ),
                          onChanged: updateQuantity,
                          onSubmitted: updateQuantity,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            quantityController.text = quantity.toString();
                          });
                        },
                        color: Theme.of(context).brightness == Brightness.dark
                            ? Colors.white
                            : Colors.black,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    AppLocalizations.of(context)!.projectPage_cancel,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    final preset =
                        ref.read(presetProvider.notifier).activePreset;
                    if (preset != null) {
                      // Vérifier si l'article existe déjà dans le preset
                      final existingItemIndex = preset.items.indexWhere(
                        (cartItem) => cartItem.item.id == item.id,
                      );
                      
                      if (existingItemIndex != -1) {
                        // Modifier la quantité de l'article existant
                        final updatedItems = List<CartItem>.from(preset.items);
                        updatedItems[existingItemIndex] = updatedItems[existingItemIndex].copyWith(
                          quantity: quantity,
                        );
                        final updatedPreset = preset.copyWith(items: updatedItems);
                        ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                      } else {
                        // Ajouter un nouvel article au preset
                        final newCartItem = CartItem(
                          item: item,
                          quantity: quantity,
                        );
                        final updatedItems = [...preset.items, newCartItem];
                        final updatedPreset = preset.copyWith(items: updatedItems);
                        ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                      }
                    }
                  },
                  child: Text(
                    AppLocalizations.of(context)!.projectPage_addToPreset,
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _handleSearch(String value) {
    setState(() {
      searchQuery = value;
      if (value.length >= 3) {
        final items = ref.read(catalogueProvider);
        searchResults = items
            .where((item) =>
                item.produit.toLowerCase().contains(value.toLowerCase()) ||
                item.marque.toLowerCase().contains(value.toLowerCase()))
            .toList();
        showSearchResults = true;
      } else {
        showSearchResults = false;
      }
    });
  }

  void _addItemToActivePreset(CatalogueItem item) {
    final activePreset = ref.read(presetProvider.notifier).activePreset;
    if (activePreset != null) {
      final cartItem = CartItem(
        item: item,
        quantity: 1,
      );
      
      final updatedItems = [...activePreset.items, cartItem];
      final updatedPreset = activePreset.copyWith(items: updatedItems);
      
      ref.read(presetProvider.notifier).updatePreset(updatedPreset);
      
      // Fermer la recherche
      setState(() {
        searchQuery = '';
        showSearchResults = false;
        searchResults.clear();
      });
      
      // Afficher un message de confirmation
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${item.name} ajouté au preset ${activePreset.name}'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucun preset actif sélectionné'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  void _showPresetItemQuantityDialog(CartItem item, Preset preset) {
    int quantity = item.quantity;
    final TextEditingController quantityController =
        TextEditingController(text: quantity.toString());

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              backgroundColor: const Color(0xFF0A1128),
              title: Text(
                'Modifier la quantité',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                  color: Colors.white,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${item.item.name} (${item.item.marque})',
                    style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove),
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() {
                              quantity--;
                              quantityController.text = quantity.toString();
                            });
                          }
                        },
                        color: Colors.white,
                      ),
                      Container(
                        width: 80,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: TextField(
                          controller: quantityController,
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          autofocus: true,
                          onTap: () {
                            quantityController.selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: quantityController.text.length,
                            );
                          },
                          style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            color: Colors.white,
                          ),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                          onChanged: (value) {
                            final newQuantity = int.tryParse(value) ?? 1;
                            if (newQuantity > 0) {
                              setState(() {
                                quantity = newQuantity;
                              });
                            }
                          },
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        onPressed: () {
                          setState(() {
                            quantity++;
                            quantityController.text = quantity.toString();
                          });
                        },
                        color: Colors.white,
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Annuler',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                                    ElevatedButton(
                    onPressed: () async {
                      if (quantity != item.quantity) {
                        // Mettre à jour le preset
                        final updatedItems = preset.items.map((i) {
                          if (i.item.id == item.item.id) {
                            return i.copyWith(quantity: quantity);
                          }
                          return i;
                        }).toList();
                        
                        final updatedPreset = preset.copyWith(items: updatedItems);
                        await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                        
                        // Fermer le dialog et laisser le provider notifier le changement
                        if (context.mounted) {
                          Navigator.pop(context);
                        }
                      } else {
                        Navigator.pop(context);
                      }
                    },
                    child: const Text('Confirmer'),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.calculate,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: Theme.of(context).brightness == Brightness.light ? 0.15 : 0.5,
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/background.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 8),
                Expanded(
                  child: DefaultTabController(
                    length: 2,
                    child: Column(
                      children: [
                        TabBar(
                          labelColor: Theme.of(context).brightness == Brightness.dark ? Colors.lightBlue[300] : const Color(0xFF1B3B5A), // Bleu ciel en mode sombre, bleu nuit en mode clair
                          unselectedLabelColor: Colors.white.withOpacity(0.7), // Blanc transparent pour les onglets non sélectionnés
                          indicatorColor: Theme.of(context).brightness == Brightness.dark ? Colors.lightBlue[300] : const Color(0xFF1B3B5A), // Indicateur adaptatif
                          tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.bolt, 
                                    size: 18, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.lightBlue[300] : const Color(0xFF1B3B5A),
                                  ),
                                  SizedBox(width: 6),
                                  Text('${loc.projectPage_powerTabShort} ${_getProjectName()}'),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.scale, 
                                    size: 18, 
                                    color: Theme.of(context).brightness == Brightness.dark ? Colors.lightBlue[300] : const Color(0xFF1B3B5A),
                                  ),
                                  SizedBox(width: 8),
                                  Text('${loc.projectPage_weightTabShort} ${_getProjectName()}'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        PresetWidget(
                          loadOnInit: false,
                          onPresetSelected: (preset) {
                            setState(() {});
                          },
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 16),
                            decoration: BoxDecoration(
                              color: const Color(0xFF0A1128).withOpacity(0.3),
                              border: Border.all(color: Colors.white, width: 1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TabBarView(
                              children: [
                                _buildProjectTab(showConso: true),
                                _buildProjectTab(showConso: false),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.blueGrey[900],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        onTap: _navigateTo,
        items: [
          BottomNavigationBarItem(
              icon: Icon(Icons.list), label: context.t('catalogue')),
          BottomNavigationBarItem(
              icon: Icon(Icons.lightbulb), label: context.t('light')),
          BottomNavigationBarItem(
              icon: Image.asset('assets/truss_icon_grey.png',
                  width: 24, height: 24),
              label: context.t('structure')),
          BottomNavigationBarItem(
              icon: Icon(Icons.volume_up), label: context.t('sound')),
          BottomNavigationBarItem(
              icon: Icon(Icons.videocam), label: context.t('video')),
          BottomNavigationBarItem(
              icon: Icon(Icons.bolt), label: context.t('electricity')),
          BottomNavigationBarItem(
              icon: Icon(Icons.more_horiz), label: context.t('divers')),
        ],
      ),
    );
  }

  Widget _buildProjectTab({required bool showConso}) {
    // Récupérer tous les presets du projet actuel au lieu d'un seul
    final presets = ref.watch(presetProvider);
    
    if (presets.isEmpty) {
      return Center(
        child: Text(
          AppLocalizations.of(context)!.noPresetSelected,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    final grouped = <String, List<CatalogueItem>>{};
    final totalsPerCategory = <String, double>{};
    double totalProjet = 0;
    int totalItems = 0;
    int totalExports = 0;

    // 🔹 Calcule pour TOUS les presets du projet
    for (final preset in presets) {
      for (var item in preset.items) {
        final cat = item.item.categorie;
        grouped.putIfAbsent(cat, () => []).add(item.item);

        final value = showConso
            ? (item.item.conso.contains('W')
                ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                : 0)
            : (item.item.poids.contains('kg')
                ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                : 0);

        totalsPerCategory.update(
          cat,
          (existing) => existing + value,
          ifAbsent: () => value.toDouble(),
        );

        totalProjet += value;
        
        // Compter les exports
        if (item.item.categorie == 'Export') {
          totalExports += item.quantity;
        } else {
          // Compter seulement les vrais articles (pas les exports)
          totalItems += item.quantity;
        }
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Barre de recherche pour ajouts d'articles de dernière minute
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                    if (value.length >= 3) {
                      final items = ref.read(catalogueProvider);
                      searchResults = items
                          .where((item) =>
                              item.name.toLowerCase().contains(value.toLowerCase()) ||
                              item.marque.toLowerCase().contains(value.toLowerCase()) ||
                              item.produit.toLowerCase().contains(value.toLowerCase()))
                          .toList();
                      showSearchResults = true;
                    } else {
                      showSearchResults = false;
                    }
                  });
                },
                decoration: InputDecoration(
                  hintText: AppLocalizations.of(context)!.searchArticlePlaceholder,
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF0A1128).withOpacity(0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 2),
                  ),
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
            
            // Résultats de recherche
            if (showSearchResults && searchResults.isNotEmpty) ...[
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ...searchResults.take(5).map((item) => InkWell(
                      onTap: () {
                        // Fermer la recherche
                        setState(() {
                          searchQuery = '';
                          showSearchResults = false;
                          searchResults.clear();
                        });
                        // Lancer automatiquement le popup quantité
                        _showQuantityDialog(item, 1);
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.marque} - ${item.produit}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                            if (item.sousCategorie.isNotEmpty)
                              Text(
                                item.sousCategorie,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 10,
                                ),
                              ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
            
            // Résumé global du projet
            Container(
              width: double.infinity,
              constraints: BoxConstraints(
                minWidth: 200,
                maxWidth: 400, // Largeur fixe basée sur un maximum de 999 articles
              ),
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
                    '${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName}',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '${AppLocalizations.of(context)!.presetCount} : ${presets.length}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.totalArticlesCount} : $totalItems',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.exportCount} : $totalExports',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            
            // Détail par preset
            ...presets.asMap().entries.map((presetEntry) {
              final presetIndex = presetEntry.key;
              final preset = presetEntry.value;
              
              // Calculer le total pour ce preset
              double totalPreset = 0;
              final groupedByCategory = <String, List<CartItem>>{};
              
              for (var item in preset.items) {
                final cat = item.item.categorie;
                groupedByCategory.putIfAbsent(cat, () => []).add(item);
                
                final value = showConso
                    ? (item.item.conso.contains('W')
                        ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                        : 0)
                    : (item.item.poids.contains('kg')
                        ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                        : 0);
                
                totalPreset += value;
              }
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.white, width: 1), // Bordure blanche pour le cadre preset
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Titre du preset
                      Text(
                        preset.name,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      // Catégorie du preset (si tous les articles ont la même catégorie)
                      if (preset.items.isNotEmpty && preset.items.where((item) => item.item.categorie != 'Export').isNotEmpty) ...[
                        Text(
                          preset.items.where((item) => item.item.categorie != 'Export').first.item.categorie,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[300],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                      
                      // Articles du preset (sans groupement par catégorie et sans exports)
                      ...preset.items
                          .where((item) => item.item.categorie != 'Export') // Filtrer les exports
                          .map((item) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1: Nom de l'article
                            Text(
                              '${item.item.name} (${item.item.marque})',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ligne 2: Quantité avec + et - et poids à droite
                            Row(
                              children: [
                                // Bouton -
                                GestureDetector(
                                  onTap: () async {
                                    if (item.quantity > 1) {
                                      final newQuantity = item.quantity - 1;
                                      // Mettre à jour le preset
                                      final updatedItems = preset.items.map((i) {
                                        if (i.item.id == item.item.id) {
                                          return i.copyWith(quantity: newQuantity);
                                        }
                                        return i;
                                      }).toList();
                                      
                                      final updatedPreset = preset.copyWith(items: updatedItems);
                                      await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                                      
                                      // Le provider notifiera automatiquement le changement
                                    }
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.red.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Quantité (cliquable pour modification)
                                GestureDetector(
                                  onTap: () {
                                    _showPresetItemQuantityDialog(item, preset);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                // Bouton +
                                GestureDetector(
                                  onTap: () async {
                                    final newQuantity = item.quantity + 1;
                                    // Mettre à jour le preset
                                    final updatedItems = preset.items.map((i) {
                                      if (i.item.id == item.item.id) {
                                        return i.copyWith(quantity: newQuantity);
                                      }
                                      return i;
                                    }).toList();
                                    
                                    final updatedPreset = preset.copyWith(items: updatedItems);
                                    await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                                    
                                    // Le provider notifiera automatiquement le changement
                                  },
                                  child: Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.3),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.white, width: 1),
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Poids à droite
                                Text(
                                  '${showConso ? ((double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity).toStringAsFixed(2) : ((double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity).toStringAsFixed(2)} ${showConso ? AppLocalizations.of(context)!.unitWatt : AppLocalizations.of(context)!.unitKilogram}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                      
                      // Total de ce preset
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128).withOpacity(0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.lightBlue[300]!, width: 1), // Bordure bleu ciel pour le total preset
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1: Total Poids
                            Text(
                              '${AppLocalizations.of(context)!.totalPreset} ${showConso ? AppLocalizations.of(context)!.power : AppLocalizations.of(context)!.weight}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Ligne 2: Projet + résultat
                            Text(
                              '${preset.name} : ${showConso ? (totalPreset / 1000).toStringAsFixed(2) : totalPreset.toStringAsFixed(2)} ${showConso ? AppLocalizations.of(context)!.unitKilowatt : AppLocalizations.of(context)!.unitKilogram}',
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
            
            // Total global du projet (tout en bas)
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF0A1128).withOpacity(0.3),
                border: Border.all(color: Colors.white, width: 1), // Bordure blanche pour le total projet
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1: Total Puissance
                  Text(
                    '${AppLocalizations.of(context)!.totalProject} ${showConso ? AppLocalizations.of(context)!.power : AppLocalizations.of(context)!.weight}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2: Nom Projet + calcul du total en kW
                  Text(
                    '${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName} : ${showConso ? (totalProjet / 1000).toStringAsFixed(2) : totalProjet.toStringAsFixed(2)} ${showConso ? AppLocalizations.of(context)!.unitKilowatt : AppLocalizations.of(context)!.unitKilogram}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
            // Widget Export en bas de page
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ExportWidget(
                  title: '${AppLocalizations.of(context)!.defaultProjectName} ${ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : ""}',
                  content: 'Résumé complet du projet avec tous les presets et articles',
                  presetName: ref.read(projectProvider).projects.isNotEmpty ? ref.read(projectProvider).getTranslatedProjectName(ref.read(projectProvider).selectedProject, AppLocalizations.of(context)!) : AppLocalizations.of(context)!.defaultProjectName,
                  exportDate: DateTime.now(),
                  projectType: 'power',
                  projectSummary: {
                    'totalItems': totalItems.toString(),
                    'totalExports': totalExports.toString(),
                    'totalPower': showConso ? '${(totalProjet / 1000).toStringAsFixed(2)} kW' : '${totalProjet.toStringAsFixed(2)} kg',
                    'presetCount': presets.length.toString(),
                  },
                  projectData: presets.map((preset) {
                    double totalPreset = 0;
                    int itemCount = 0;
                    
                    for (var item in preset.items) {
                      final value = showConso
                          ? (item.item.conso.contains('W')
                              ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                              : 0)
                          : (item.item.poids.contains('kg')
                              ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                              : 0);
                      totalPreset += value;
                      itemCount += item.quantity;
                    }
                    
                    return {
                      'presetName': preset.name,
                      'totalPower': showConso ? '${(totalPreset / 1000).toStringAsFixed(2)} kW' : '${totalPreset.toStringAsFixed(2)} kg',
                      'itemCount': itemCount.toString(),
                    };
                  }).toList(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getProjectName() {
    final project = ref.read(projectProvider).selectedProject;
    if (project == null) return AppLocalizations.of(context)!.defaultProjectName;
    
    // Utiliser la méthode de traduction du ProjectProvider
    return ref.read(projectProvider).getTranslatedProjectName(project, AppLocalizations.of(context)!);
  }
}
