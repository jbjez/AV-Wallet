// Nouvelle page CalculProjetPage
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:av_wallet/l10n/app_localizations.dart';
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
import '../models/cart_item.dart';
import '../models/catalogue_item.dart';
import '../models/preset.dart';
import '../providers/preset_files_provider.dart';
import '../providers/preset_pdf_provider.dart';
import '../widgets/pdf_preview_dialog.dart';
import '../utils/consumption_parser.dart';
import 'package:share_plus/share_plus.dart';
import '../widgets/custom_app_bar.dart';
import '../providers/project_provider.dart';
import '../services/freemium_access_service.dart';
import '../widgets/export_widget.dart';
import '../widgets/action_button.dart';
import '../providers/imported_photos_provider.dart';
class CalculProjetPage extends ConsumerStatefulWidget {
  const CalculProjetPage({super.key});

  @override
  ConsumerState<CalculProjetPage> createState() => _CalculProjetPageState();
}

class _CalculProjetPageState extends ConsumerState<CalculProjetPage> {
  String searchQuery = '';
  List<CatalogueItem> searchResults = [];
  bool showSearchResults = false;
  
  // Gestion des commentaires
  Map<String, String> _comments = {}; // Clé: "projectId_tabKey", Valeur: commentaire
  
  @override
  void initState() {
    super.initState();
    _loadComments();
    // Initialiser le provider des photos importées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('DEBUG Init - Loading photos...');
      ref.read(importedPhotosProvider.notifier).loadPhotos().then((_) {
        debugPrint('DEBUG Init - Photos loaded: ${ref.read(importedPhotosProvider)}');
      });
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Recharger les commentaires quand on change de projet
    _loadComments();
    // Recharger les photos importées
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('DEBUG didChangeDependencies - Reloading photos...');
      ref.read(importedPhotosProvider.notifier).loadPhotos().then((_) {
        debugPrint('DEBUG didChangeDependencies - Photos reloaded: ${ref.read(importedPhotosProvider)}');
      });
    });
  }

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

  // Méthodes de gestion des commentaires
  Future<void> _loadComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final commentsJson = prefs.getString('calcul_projet_comments');
      if (commentsJson != null) {
        setState(() {
          _comments = Map<String, String>.from(json.decode(commentsJson));
        });
      }
    } catch (e) {
      debugPrint('Error loading comments: $e');
    }
  }

  Future<void> _saveComments() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('calcul_projet_comments', json.encode(_comments));
      // Nettoyer les anciens commentaires (garder seulement les 20 plus récents)
      _cleanupOldComments();
    } catch (e) {
      debugPrint('Error saving comments: $e');
    }
  }

  void _cleanupOldComments() {
    if (_comments.length > 20) {
      // Garder seulement les 20 commentaires les plus récents
      final sortedEntries = _comments.entries.toList()
        ..sort((a, b) => a.key.compareTo(b.key));
      
      _comments.clear();
      for (int i = 0; i < 20 && i < sortedEntries.length; i++) {
        _comments[sortedEntries[i].key] = sortedEntries[i].value;
      }
    }
  }

  String _getCommentForTab(String tabKey) {
    final projectId = ref.read(projectProvider).selectedProject.id;
    final commentKey = '${projectId}_$tabKey';
    return _comments[commentKey] ?? '';
  }

  void _showPhotoPreview(String photoPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            children: [
              // Image en plein écran
              Center(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.9,
                    maxHeight: MediaQuery.of(context).size.height * 0.8,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(photoPath),
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
              // Bouton fermer
              Positioned(
                top: 50,
                right: 20,
                child: IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 30,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.5),
                    shape: const CircleBorder(),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _exportPhoto(String photoPath) async {
    try {
      final file = File(photoPath);
      if (await file.exists()) {
        await Share.shareXFiles([XFile(photoPath)], text: 'Photo du projet');
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photo_exported),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.photo_not_found),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors de l\'export: $e'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }


  Future<void> _showCommentDialog(String tabKey, String tabName) async {
    final TextEditingController commentController = TextEditingController(
      text: _getCommentForTab(tabKey),
    );

    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF0A1128)
              : Colors.white,
          content: SizedBox(
            width: 300, // Largeur fixe pour éviter le resserrement
            child: TextField(
              controller: commentController,
              maxLines: 3,
              minLines: 3,
              decoration: InputDecoration(
                hintText: 'Ajouter un commentaire pour $tabName...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.all(12),
              ),
              autofocus: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () async {
                final comment = commentController.text.trim();
                final projectId = ref.read(projectProvider).selectedProject.id;
                final commentKey = '${projectId}_$tabKey';
                setState(() {
                  if (comment.isEmpty) {
                    _comments.remove(commentKey);
                  } else {
                    _comments[commentKey] = comment;
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
                                    ? Colors.white.withValues(alpha: 0.5)
                                    : Colors.black.withValues(alpha: 0.5),
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
    
    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.calculate,
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.1,
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
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border(
                              bottom: BorderSide(
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? Colors.lightBlue[300]!
                                    : const Color(0xFF0A1128),
                                width: 2,
                              ),
                            ),
                          ),
         child: TabBar(
           dividerColor: Colors.transparent, // Supprime la ligne de séparation
           indicatorColor: Colors.transparent, // Supprime l'indicateur bleu
           labelColor: Theme.of(context).brightness == Brightness.dark
               ? Colors.lightBlue[300]  // Bleu ciel en mode nuit
               : const Color(0xFF0A1128),  // Bleu nuit en mode jour
           unselectedLabelColor: Colors.white.withValues(alpha: 0.7), // Blanc transparent pour les onglets non sélectionnés
           tabs: [
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate, 
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.consumption,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.bolt, 
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                            Tab(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.calculate, 
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      AppLocalizations.of(context)!.weight_tab_title,
                                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.scale, 
                                    size: 16,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
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
                              color: const Color(0xFF0A1128).withValues(alpha: 0.3),
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
            ? ConsumptionParser.parseConsumption(item.item.conso) * item.quantity
            : ConsumptionParser.parseWeight(item.item.poids) * item.quantity;

        totalsPerCategory.update(
          cat,
          (existing) => existing + value,
          ifAbsent: () => value.toDouble(),
        );

        totalProjet += value;
        
        // Compter les exports
        if (item.item.categorie == 'Export') {
          totalExports += item.quantity.toInt();
        } else {
          // Compter seulement les vrais articles (pas les exports)
          totalItems += item.quantity.toInt();
        }
      }
    }
    
    // Ajouter 10% de câblage pour le mode poids au total global
    if (!showConso) {
      totalProjet = totalProjet * 1.1; // +10% de câblage
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1128).withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        scrollDirection: Axis.vertical,
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
                  hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
                  prefixIcon: Icon(Icons.search, color: Colors.white),
                  filled: true,
                  fillColor: const Color(0xFF0A1128).withValues(alpha: 0.3),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
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
                  color: const Color(0xFF0A1128).withValues(alpha: 0.3),
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
                                  color: Colors.white.withValues(alpha: 0.7),
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
            
            // Cadre 1: Nom du Projet (fond transparent, bordure blanche)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final projectState = ref.watch(projectProvider);
                      final projectName = projectState.projects.isNotEmpty 
                          ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
                          : AppLocalizations.of(context)!.defaultProjectName;
                      
                      return Text(
                        projectName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: Theme.of(context).textTheme.titleLarge!.fontSize! - 3,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Paramètres du projet
                  Consumer(
                    builder: (context, ref, child) {
                      final project = ref.watch(projectProvider).selectedProject;
                      
                      // Debug: afficher les paramètres du projet
                      debugPrint('DEBUG Calcul Projet - Project parameters:');
                      debugPrint('  - Location: ${project.location}');
                      debugPrint('  - Mounting Date: ${project.mountingDate}');
                      debugPrint('  - Period: ${project.period}');
                      
                      return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppLocalizations.of(context)!.project_parameters,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                            '${AppLocalizations.of(context)!.project_location}: ${project.location ?? AppLocalizations.of(context)!.not_defined}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                            '${AppLocalizations.of(context)!.project_mounting_date}: ${project.mountingDate ?? AppLocalizations.of(context)!.not_defined}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                            '${AppLocalizations.of(context)!.project_period}: ${project.period ?? AppLocalizations.of(context)!.not_defined}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                    ],
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Statistiques détaillées du projet
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${AppLocalizations.of(context)!.project_stats_presets}: ${presets.length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context)!.project_stats_articles}: $totalItems',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context)!.project_stats_calculations}: ${presets.fold<int>(0, (total, preset) {
                          final pdfMaps = ref.read(presetPdfProvider(preset.id));
                          debugPrint('DEBUG: Preset ${preset.name} (${preset.id}) a ${pdfMaps.length} fichiers PDF: ${pdfMaps.map((m) => m['name']).toList()}');
                          return total + pdfMaps.length;
                        })}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${AppLocalizations.of(context)!.project_stats_photos}: ${presets.fold<int>(0, (total, preset) => total + (ref.read(presetImageFilesProvider(preset.id)).length)) + ref.read(projectPhotosProvider(ref.read(projectProvider).selectedProject.name)).length}',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white,
                        ),
                      ),
                    ],
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
              
              // Ajouter 10% de câblage pour le mode poids
              if (!showConso) {
                totalPreset = totalPreset * 1.1; // +10% de câblage
              }
              
              // Alternance bleu/blanc pour les bordures : index pair = bleu, index impair = blanc
              final isBlueBorder = presetIndex % 2 == 0;
              
              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isBlueBorder 
                        ? Colors.blue[700]!
                        : Colors.white,
                    width: 2,
                  ),
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
                      // Articles du preset groupés par catégorie (sans exports)
                      ...() {
                        // Grouper les articles par catégorie
                        final Map<String, List<CartItem>> groupedItems = {};
                        for (var item in preset.items.where((item) => item.item.categorie != 'Export')) {
                          final category = item.item.categorie;
                          if (!groupedItems.containsKey(category)) {
                            groupedItems[category] = [];
                          }
                          groupedItems[category]!.add(item);
                        }
                        
                        // Créer les widgets pour chaque catégorie
                        List<Widget> widgets = [];
                        groupedItems.forEach((category, items) {
                          // Sous-titre de catégorie
                          widgets.add(
                            Padding(
                              padding: const EdgeInsets.only(top: 8, bottom: 4),
                              child: Text(
                                category,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.lightBlue[300],
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          );
                          
                          // Articles de cette catégorie
                          widgets.addAll(
                            items.map((item) => Padding(
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
                                    width: 20, // Réduit de 24 à 20
                                    height: 20, // Réduit de 24 à 20
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10), // Réduit de 12 à 10
                                    ),
                                    child: Icon(
                                      Icons.remove,
                                      color: Colors.white,
                                      size: 14, // Réduit de 16 à 14
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6), // Réduit de 8 à 6
                                // Quantité (cliquable pour modification)
                                GestureDetector(
                                  onTap: () {
                                    _showPresetItemQuantityDialog(item, preset);
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2), // Réduit le padding
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6), // Réduit de 8 à 6
                                    ),
                                    child: Text(
                                      '${item.quantity}',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12, // Ajouté une taille fixe
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6), // Réduit de 8 à 6
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
                                    width: 20, // Réduit de 24 à 20
                                    height: 20, // Réduit de 24 à 20
                                    decoration: BoxDecoration(
                                      color: Colors.green.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10), // Réduit de 12 à 10
                                    ),
                                    child: Icon(
                                      Icons.add,
                                      color: Colors.white,
                                      size: 14, // Réduit de 16 à 14
                                    ),
                                  ),
                                ),
                                const Spacer(),
                                // Poids/Puissance à droite
                                Flexible(
                                  child: Text(
                                    '${showConso ? (ConsumptionParser.parseConsumption(item.item.conso) * item.quantity / 1000).toStringAsFixed(2) : (ConsumptionParser.parseWeight(item.item.poids) * item.quantity).toStringAsFixed(2)} ${showConso ? 'kW' : AppLocalizations.of(context)!.unitKilogram}',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                      fontSize: 12, // Augmenté de 10 à 12 (2 points de plus)
                                    ),
                                    overflow: TextOverflow.ellipsis, // Évite l'overflow avec des points de suspension
                                  ),
                                ),
                                const SizedBox(width: 6), // Réduit de 8 à 6
                                // Bouton corbeille pour supprimer l'article
                                GestureDetector(
                                  onTap: () async {
                                    // Supprimer l'article du preset
                                    final updatedItems = preset.items.where((i) => i.item.id != item.item.id).toList();
                                    final updatedPreset = preset.copyWith(items: updatedItems);
                                    await ref.read(presetProvider.notifier).updatePreset(updatedPreset);
                                  },
                                  child: Container(
                                    width: 20, // Réduit de 24 à 20
                                    height: 20, // Réduit de 24 à 20
                                    decoration: BoxDecoration(
                                      color: Colors.red.withValues(alpha: 0.3),
                                      borderRadius: BorderRadius.circular(10), // Réduit de 12 à 10
                                    ),
                                    child: Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                      size: 14, // Réduit de 16 à 14
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      )),
                            );
                          });
                          
                          return widgets;
                        }(),
                      
                      // Total de ce preset
                      Container(
                        margin: const EdgeInsets.only(top: 12),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0A1128).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.lightBlue[300]!, 
                            width: 1
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Ligne 1: Total Poids avec câblage
                            Text(
                              'Total ${preset.name} ${showConso ? AppLocalizations.of(context)!.power : AppLocalizations.of(context)!.weight}${!showConso ? ' ${AppLocalizations.of(context)!.cabling_addition}' : ''}',
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
            
            // Cadre 3: Total global du projet (fond transparent, bordure bleue)
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.blue[700]!,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ligne 1: Total Puissance
                  Consumer(
                    builder: (context, ref, child) {
                      final projectState = ref.watch(projectProvider);
                      final projectName = projectState.projects.isNotEmpty 
                          ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
                          : AppLocalizations.of(context)!.defaultProjectName;
                      
                      return Text(
                        'Total $projectName ${showConso ? AppLocalizations.of(context)!.power : AppLocalizations.of(context)!.weight}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  // Ligne 2: Nom Projet + calcul du total en kW
                  Consumer(
                    builder: (context, ref, child) {
                      final projectState = ref.watch(projectProvider);
                      final projectName = projectState.projects.isNotEmpty 
                          ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
                          : AppLocalizations.of(context)!.defaultProjectName;
                      
                      return Text(
                        '$projectName : ${showConso ? (totalProjet / 1000).toStringAsFixed(2) : totalProjet.toStringAsFixed(2)} ${showConso ? AppLocalizations.of(context)!.unitKilowatt : AppLocalizations.of(context)!.unitKilogram}',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
            
            
            // Commentaire utilisateur (au-dessus des boutons)
            if (_getCommentForTab(showConso ? 'power_tab' : 'weight_tab').isNotEmpty) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? Colors.blue[900]?.withValues(alpha: 0.3)
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
                      _getCommentForTab(showConso ? 'power_tab' : 'weight_tab'),
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
            ],
            
            // Cadre des fichiers importés par preset avec bordure blanche
            Consumer(
              builder: (context, ref, child) {
                final presets = ref.watch(presetProvider);
                if (presets.isEmpty) return const SizedBox.shrink();
                
                // [L1320] — NOUVEAU SYSTÈME PDF
                Map<String, List<Map>> allPresetPdfs = {};
                Map<String, List<String>> allPresetImages = {};
                
                for (final preset in presets) {
                  // Utiliser le nouveau provider pour les PDFs
                  final pdfMaps = ref.watch(presetPdfProvider(preset.id));
                  final imageFiles = ref.watch(presetImageFilesProvider(preset.id));
                  
                  if (pdfMaps.isNotEmpty || imageFiles.isNotEmpty) {
                    allPresetPdfs[preset.id] = pdfMaps;
                    allPresetImages[preset.id] = imageFiles;
                  }
                }
                
                // Vérifier aussi les photos AR du projet
                final project = ref.watch(projectProvider).selectedProject;
                final projectPhotos = ref.watch(projectPhotosProvider(project.name));
                
                if (allPresetPdfs.isEmpty && allPresetImages.isEmpty && projectPhotos.isEmpty) return const SizedBox.shrink();
                
                return Column(
                  children: [
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Titre du cadre
                          Row(
                            children: [
                              Icon(
                                Icons.folder_open,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                AppLocalizations.of(context)!.imports,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // [L1370] — Afficher les fichiers par preset avec nouveau système
                          ...allPresetPdfs.entries.map((entry) {
                            final presetId = entry.key;
                            final pdfMaps = allPresetPdfs[presetId] ?? [];
                            final imageFiles = allPresetImages[presetId] ?? [];
                            
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // [L1380] — Lignes pour chaque calcul individuel (PDF) de ce preset
                                if (pdfMaps.isNotEmpty) ...[
                                  // [L1382] — Afficher chaque calcul avec icône rouge et titre simplifié
                                  ...pdfMaps.asMap().entries.map((entry) {
                                    final index = entry.key;
                                    final pdfMap = entry.value;
                                    final pdfName = pdfMap['name'] as String;
                                    
                                    // Extraire le type de calcul du nom du fichier
                                    String displayName;
                                    if (pdfName.contains('DMX')) {
                                      displayName = 'DMX ${index + 1}';
                                    } else if (pdfName.contains('Faisceau')) {
                                      displayName = 'Faisceau ${index + 1}';
                                    } else if (pdfName.contains('Led Driver')) {
                                      displayName = 'Led Driver ${index + 1}';
                                    } else if (pdfName.contains('LED') || pdfName.contains('Mur')) {
                                      displayName = 'Mur Led ${index + 1}';
                                    } else if (pdfName.contains('Son')) {
                                      displayName = 'Son ${index + 1}';
                                    } else if (pdfName.contains('Projection')) {
                                      displayName = 'Projection ${index + 1}';
                                    } else if (pdfName.contains('Charges')) {
                                      displayName = 'Charges ${index + 1}';
                                    } else if (pdfName.contains('Charge')) {
                                      displayName = 'Charge ${index + 1}';
                                    } else if (pdfName.contains('Amplification')) {
                                      displayName = 'Amplification ${index + 1}';
                                    } else if (pdfName.contains('Rider technique')) {
                                      displayName = 'Rider technique ${index + 1}';
                                    } else {
                                      displayName = 'Calcul ${index + 1}';
                                    }
                                    
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: Colors.white.withValues(alpha: 0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            Icons.calculate,
                                            color: Colors.red.withValues(alpha: 0.8),
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              displayName,
                                              style: TextStyle(
                                                color: Colors.white.withValues(alpha: 0.9),
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          // Bouton aperçu/exporter
                                          PopupMenuButton<String>(
                                            icon: Icon(
                                              Icons.more_vert,
                                              color: Colors.white.withValues(alpha: 0.7),
                                              size: 18,
                                            ),
                                            onSelected: (value) async {
                                              if (value == 'preview') {
                                                // Aperçu PDF depuis le fichier
                                                try {
                                                  final pdfPath = pdfMap['path'] as String;
                                                  final pdfFile = File(pdfPath);
                                                  
                                                  if (await pdfFile.exists()) {
                                                    showPdfPreview(context, pdfPath, displayName);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('PDF introuvable: $pdfName'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Erreur: $e'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              } else if (value == 'export') {
                                                // Exporter PDF depuis le fichier
                                                try {
                                                  final pdfPath = pdfMap['path'] as String;
                                                  final pdfFile = File(pdfPath);
                                                  
                                                  if (await pdfFile.exists()) {
                                                    await Share.shareXFiles([XFile(pdfPath)]);
                                                  } else {
                                                    ScaffoldMessenger.of(context).showSnackBar(
                                                      SnackBar(
                                                        content: Text('PDF introuvable: $pdfName'),
                                                        backgroundColor: Colors.red,
                                                      ),
                                                    );
                                                  }
                                                } catch (e) {
                                                  ScaffoldMessenger.of(context).showSnackBar(
                                                    SnackBar(
                                                      content: Text('Erreur: $e'),
                                                      backgroundColor: Colors.red,
                                                    ),
                                                  );
                                                }
                                              }
                                            },
                                            itemBuilder: (context) => [
                                              PopupMenuItem(
                                                value: 'preview',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.visibility, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(AppLocalizations.of(context)!.preview),
                                                  ],
                                                ),
                                              ),
                                              PopupMenuItem(
                                                value: 'export',
                                                child: Row(
                                                  children: [
                                                    Icon(Icons.share, size: 16),
                                                    const SizedBox(width: 8),
                                                    Text(AppLocalizations.of(context)!.export),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 8),
                        // Bouton supprimer
                        IconButton(
                          onPressed: () async {
                            try {
                              final pdfId = pdfMap['id'] as String;
                              // Supprimer de Hive
                              await ref.read(pdfRepoProvider).deletePdf(pdfId);
                              // Rafraîchir le provider
                              ref.read(presetPdfProvider(presetId).notifier).refresh();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur lors de la suppression: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                                            icon: Icon(
                                              Icons.delete_outline,
                                              color: Colors.red.withValues(alpha: 0.8),
                                              size: 18,
                                            ),
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(
                                              minWidth: 24,
                                              minHeight: 24,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                                ],
                                
                                // Ligne pour les photos avec compteur +/- de ce preset
                                if (imageFiles.isNotEmpty) ...[
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.photo_library,
                                        color: Colors.blue,
                                        size: 18,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Photos:',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      // Bouton -
                                      GestureDetector(
                                        onTap: () {
                                          if (imageFiles.isNotEmpty) {
                                            ref.read(presetFilesProvider.notifier).removeFileFromPreset(presetId, imageFiles.last);
                                          }
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.red.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.remove,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Nombre de photos
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Text(
                                          '${imageFiles.length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Bouton +
                                      GestureDetector(
                                        onTap: () {
                                          // Ici on pourrait ajouter une fonctionnalité pour ajouter plus de photos
                                          // Pour l'instant, on ne fait rien
                                        },
                                        child: Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            color: Colors.green.withValues(alpha: 0.3),
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      // Poubelle pour supprimer toutes les photos de ce preset
                                      IconButton(
                                        onPressed: () {
                                          for (final file in imageFiles) {
                                            ref.read(presetFilesProvider.notifier).removeFileFromPreset(presetId, file);
                                          }
                                        },
                                        icon: Icon(
                                          Icons.delete_outline,
                                          color: Colors.red,
                                          size: 18,
                                        ),
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 24,
                                          minHeight: 24,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                                
                                // Section globale pour les photos AR du projet entier
                                Consumer(
                                  builder: (context, ref, child) {
                                    final project = ref.watch(projectProvider).selectedProject;
                                    final projectName = project.name;
                                    final arPhotos = ref.watch(projectPhotosProvider(projectName));
                                    
                                    // Debug: afficher les informations globales
                                    debugPrint('DEBUG Calcul Projet GLOBAL - Project: $projectName');
                                    debugPrint('DEBUG Calcul Projet GLOBAL - AR Photos count: ${arPhotos.length}');
                                    debugPrint('DEBUG Calcul Projet GLOBAL - AR Photos: $arPhotos');
                                    
                                    if (arPhotos.isNotEmpty) {
                                      return Column(
                                        children: [
                                          const SizedBox(height: 20),
                                          // Liste des photos AR avec la même mise en forme que les calculs
                                          ...arPhotos.asMap().entries.map((entry) {
                                            final index = entry.key;
                                            final photoPath = entry.value;
                                            
                                            return Container(
                                              margin: const EdgeInsets.only(bottom: 8),
                                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                              decoration: BoxDecoration(
                                                color: Colors.white.withValues(alpha: 0.1),
                                                borderRadius: BorderRadius.circular(8),
                                                border: Border.all(
                                                  color: Colors.white.withValues(alpha: 0.3),
                                                  width: 1,
                                                ),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(
                                                    Icons.photo,
                                                    color: Colors.blue.withValues(alpha: 0.8),
                                                    size: 18,
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      '${ref.read(projectProvider).getTranslatedProjectName(project, AppLocalizations.of(context)!)} ${index + 1}',
                                                      style: TextStyle(
                                                        color: Colors.white.withValues(alpha: 0.9),
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                                  ),
                                                  // Menu pour aperçu/exporter/supprimer la photo
                                                  PopupMenuButton<String>(
                                                    onSelected: (value) async {
                                                      switch (value) {
                                                        case 'preview':
                                                          _showPhotoPreview(photoPath);
                                                          break;
                                                        case 'export':
                                                          _exportPhoto(photoPath);
                                                          break;
                                                        case 'delete':
                                                          await ref.read(importedPhotosProvider.notifier).removePhotoFromProject(projectName, photoPath);
                                                          break;
                                                      }
                                                    },
                                                    itemBuilder: (BuildContext context) => [
                                                      PopupMenuItem<String>(
                                                        value: 'preview',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.visibility, size: 16),
                                                            const SizedBox(width: 8),
                                                            Text(AppLocalizations.of(context)!.preview),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'export',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.share, size: 16),
                                                            const SizedBox(width: 8),
                                                            Text(AppLocalizations.of(context)!.export),
                                                          ],
                                                        ),
                                                      ),
                                                      PopupMenuItem<String>(
                                                        value: 'delete',
                                                        child: Row(
                                                          children: [
                                                            Icon(Icons.delete_outline, size: 16, color: Colors.red),
                                                            const SizedBox(width: 8),
                                                            Text(AppLocalizations.of(context)!.delete, style: TextStyle(color: Colors.red)),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(
                                                      minWidth: 24,
                                                      minHeight: 24,
                                                    ),
                                                    child: Icon(
                                                      Icons.more_vert,
                                                      color: Colors.white,
                                                      size: 18,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          }),
                                        ],
                                      );
                                    }
                                    
                                    return const SizedBox.shrink();
                                  },
                                ),
                              ],
                            );
                          },
                        ),
                      ],
                      ),
                    ),
                  ],
                );
              },
            ),
            
            // Boutons d'action en bas de page
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Bouton Commentaire (icône uniquement)
                ActionButton.comment(
                  onPressed: () => _showCommentDialog(showConso ? 'power_tab' : 'weight_tab', showConso ? 'Puissance' : 'Poids'),
                  iconSize: 28,
                ),
                const SizedBox(width: 20),
                // Bouton Export (rotated) - Premium uniquement
                Transform.rotate(
                  angle: 0, // Pas de rotation - flèche vers le haut
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900], // Identique au bouton comment
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        return FutureBuilder<bool>(
                          future: FreemiumAccessService.canExport(context, ref),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return const CircularProgressIndicator();
                            }
                            
                            final canExport = snapshot.data ?? false;
                            
                            if (!canExport) {
                              // Afficher un bouton désactivé avec message premium
                              return Tooltip(
                                message: 'Export réservé aux utilisateurs Premium',
                                child: Opacity(
                                  opacity: 0.5,
                                  child: Consumer(
                                    builder: (context, ref, child) {
                                      final projectState = ref.watch(projectProvider);
                                      final projectName = projectState.projects.isNotEmpty 
                                          ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
                                          : AppLocalizations.of(context)!.defaultProjectName;
                                      
                                      return ExportWidget(
                                        title: '${AppLocalizations.of(context)!.defaultProjectName} $projectName',
                                    content: _buildExportContent(showConso, totalProjet, totalItems, totalExports, presets),
                                        presetName: projectName,
                                    exportDate: DateTime.now(),
                                        projectType: showConso ? 'power' : 'weight',
                                    projectSummary: {
                                      'totalItems': totalItems.toString(),
                                      'totalExports': totalExports.toString(),
                                      'totalPower': showConso ? '${(totalProjet / 1000).toStringAsFixed(2)} kW' : '${totalProjet.toStringAsFixed(2)} kg',
                                      'presetCount': presets.length.toString(),
                                    },
         // Les paramètres de projet sont maintenant inclus dans projectData
                                    projectData: presets.map((preset) {
                                      double totalPreset = 0;
                                      int itemCount = 0;
                                    List<Map<String, dynamic>> items = [];
                                      
                                      for (var item in preset.items) {
                                        final value = showConso
                                            ? (item.item.conso.contains('W')
                                                ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                                                : 0)
                                            : (item.item.poids.contains('kg')
                                                ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                                                : 0);
                                        totalPreset += value;
                                        itemCount += item.quantity.toInt();
                                      
                                      // Ajouter le détail de l'article
                                      items.add({
                                        'name': item.item.name,
                                        'quantity': item.quantity,
                                        'value': showConso ? (value / 1000).toStringAsFixed(2) : value.toStringAsFixed(2),
                                        'category': item.item.categorie,
                                      });
                                    }
                                    
                                    // Ajouter 10% de câblage pour le mode poids
                                    if (!showConso) {
                                      totalPreset = totalPreset * 1.1; // +10% de câblage
                                      }
                                      
                                      return {
                                        'presetName': preset.name,
                                        'totalPower': showConso ? '${(totalPreset / 1000).toStringAsFixed(2)} kW' : '${totalPreset.toStringAsFixed(2)} kg',
                                        'itemCount': itemCount.toString(),
                                      'items': items, // Ajouter le détail des articles
                                      };
                                    }).toList(),
                                        // Inclure les photos du projet
                                        projectName: projectName,
                                        fileName: 'Projet_${projectName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
                                        // Inclure tous les PDFs de calculs importés
                                        importedPdfs: _getAllImportedPdfs(),
                                      );
                                    },
                                  ),
                                ),
                              );
                            }
                            
                            // Bouton d'export original qui partage tous les PDFs ensemble
                            return Consumer(
                              builder: (context, ref, child) {
                                final projectState = ref.watch(projectProvider);
                                final projectName = projectState.projects.isNotEmpty 
                                    ? projectState.getTranslatedProjectName(projectState.selectedProject, AppLocalizations.of(context)!)
                                    : AppLocalizations.of(context)!.defaultProjectName;
                                
                                return Transform.rotate(
                                  angle: 0, // Pas de rotation - flèche vers le haut naturellement
                                  child: ExportWidget(
                                    title: '${AppLocalizations.of(context)!.defaultProjectName} $projectName',
                              content: _buildExportContent(showConso, totalProjet, totalItems, totalExports, presets),
                                    presetName: projectName,
                              exportDate: DateTime.now(),
                                    projectType: showConso ? 'power' : 'weight',
                              projectSummary: {
                                'totalItems': totalItems.toString(),
                                'totalExports': totalExports.toString(),
                                'totalPower': showConso ? '${(totalProjet / 1000).toStringAsFixed(2)} kW' : '${totalProjet.toStringAsFixed(2)} kg',
                                'presetCount': presets.length.toString(),
                              },
                              projectData: presets.map((preset) {
                                double totalPreset = 0;
                                int itemCount = 0;
                                      List<Map<String, dynamic>> items = [];
                                
                                for (var item in preset.items) {
                                  final value = showConso
                                      ? (item.item.conso.contains('W')
                                          ? (double.tryParse(item.item.conso.replaceAll('W', '').trim()) ?? 0) * item.quantity
                                          : 0)
                                      : (item.item.poids.contains('kg')
                                          ? (double.tryParse(item.item.poids.replaceAll('kg', '').trim()) ?? 0) * item.quantity
                                          : 0);
                                  totalPreset += value;
                                  itemCount += item.quantity.toInt();
                                        
                                        items.add({
                                          'name': item.item.name,
                                          'quantity': item.quantity,
                                          'value': showConso ? (value / 1000).toStringAsFixed(2) : value.toStringAsFixed(2),
                                          'category': item.item.categorie,
                                        });
                                      }
                                      
                                      if (!showConso) {
                                        totalPreset = totalPreset * 1.1; // +10% de câblage
                                }
                                
                                return {
                                  'presetName': preset.name,
                                  'totalPower': showConso ? '${(totalPreset / 1000).toStringAsFixed(2)} kW' : '${totalPreset.toStringAsFixed(2)} kg',
                                  'itemCount': itemCount.toString(),
                                        'items': items,
                                };
                              }).toList(),
                                    projectName: projectName,
                                    fileName: 'Projet_${projectName.replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}',
                                    // Inclure tous les PDFs de calculs importés
                                    importedPdfs: _getAllImportedPdfs(),
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }


  // Méthode pour construire le contenu d'export
  String _buildExportContent(bool showConso, double totalProjet, int totalItems, int totalExports, List<Preset> presets) {
    final String type = showConso ? 'PUISSANCE' : 'POIDS';
    final String totalFormatted = showConso ? '${(totalProjet / 1000).toStringAsFixed(2)} kW' : '${totalProjet.toStringAsFixed(2)} kg';
    
    String content = '''
CALCUL DE ${type} - PROJET COMPLET
=================================

RÉSUMÉ GLOBAL:
--------------
Total ${type.toLowerCase()}: $totalFormatted
Nombre total d'articles: $totalItems
Nombre d'exports: $totalExports
Nombre de presets: ${presets.length}

DÉTAIL PAR PRESET:
-----------------
''';

    for (int i = 0; i < presets.length; i++) {
      final preset = presets[i];
      double totalPreset = 0;
      int itemCount = 0;
      
      for (var item in preset.items) {
        final value = showConso
            ? ConsumptionParser.parseConsumption(item.item.conso) * item.quantity
            : ConsumptionParser.parseWeight(item.item.poids) * item.quantity;
        
        totalPreset += value;
        itemCount += item.quantity;
      }
      
      final presetTotal = showConso ? '${(totalPreset / 1000).toStringAsFixed(2)} kW' : '${totalPreset.toStringAsFixed(2)} kg';
      
      content += '''
${i + 1}. ${preset.name}
   Total ${type.toLowerCase()}: $presetTotal
   Articles: $itemCount
   
   Détail des articles:
''';
      
      // Grouper les articles par catégorie
      final Map<String, List<CartItem>> groupedItems = {};
      for (var item in preset.items) {
        final category = item.item.categorie;
        if (!groupedItems.containsKey(category)) {
          groupedItems[category] = [];
        }
        groupedItems[category]!.add(item);
      }
      
      // Afficher les articles groupés par catégorie
      groupedItems.forEach((category, items) {
        content += '   ${category}:\n';
        for (var item in items) {
          final value = showConso
              ? ConsumptionParser.parseConsumption(item.item.conso) * item.quantity
              : ConsumptionParser.parseWeight(item.item.poids) * item.quantity;
          
          final itemTotal = showConso ? '${(value / 1000).toStringAsFixed(2)} kW' : '${value.toStringAsFixed(2)} kg';
          content += '     • ${item.item.produit} (x${item.quantity}): $itemTotal\n';
        }
      });
      
      content += '\n';
    }
    
    content += '''
RECOMMANDATIONS:
---------------
${showConso ? 
  '• Vérifier la capacité des alimentations\n• Considérer les facteurs de puissance\n• Prévoir des marges de sécurité\n• Calculer les courants de démarrage' :
  '• Vérifier la capacité de levage\n• Considérer les charges dynamiques\n• Prévoir des marges de sécurité\n• Calculer les centres de gravité'
}

Généré le: ${DateTime.now().toString().split('.')[0]}
''';
    
    return content;
  }

  // Méthode pour récupérer tous les PDFs importés de tous les presets
  List<Map<String, dynamic>> _getAllImportedPdfs() {
    final presets = ref.read(presetProvider);
    final allPdfs = <Map<String, dynamic>>[];
    
    for (final preset in presets) {
      final pdfMaps = ref.read(presetPdfProvider(preset.id));
      // Convertir Map<dynamic, dynamic> en Map<String, dynamic>
      for (final pdfMap in pdfMaps) {
        final convertedMap = <String, dynamic>{};
        pdfMap.forEach((key, value) {
          convertedMap[key.toString()] = value;
        });
        allPdfs.add(convertedMap);
      }
    }
    
    return allPdfs;
  }

  // Méthode pour grouper les calculs par type avec numérotation individuelle
}
