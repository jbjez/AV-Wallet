import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import '../providers/catalogue_provider.dart';
import 'package:av_wallet_hive/l10n/app_localizations.dart';

class UnifiedSearchWidget extends ConsumerStatefulWidget {
  final String hintText;
  final Function(CatalogueItem) onItemSelected;
  final String? category;
  final String? subCategory;
  final bool showQuantityDialog;
  final bool showAmplifierDialog; // Pour la page son
  final bool showDmxDialog; // Pour la page lumière

  const UnifiedSearchWidget({
    super.key,
    required this.hintText,
    required this.onItemSelected,
    this.category,
    this.subCategory,
    this.showQuantityDialog = true,
    this.showAmplifierDialog = false,
    this.showDmxDialog = false,
  });

  @override
  ConsumerState<UnifiedSearchWidget> createState() => _UnifiedSearchWidgetState();
}

class _UnifiedSearchWidgetState extends ConsumerState<UnifiedSearchWidget> {
  final TextEditingController _searchController = TextEditingController();
  List<CatalogueItem> _searchResults = [];
  bool _showSearchResults = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _handleSearch(String value) {
    setState(() {
      if (value.length >= 3) {
        final items = ref.read(catalogueProvider);
        _searchResults = items
            .where((item) {
              // Filtrer par catégorie et sous-catégorie si spécifiées
              bool categoryMatch = widget.category == null || item.categorie == widget.category;
              bool subCategoryMatch = widget.subCategory == null || item.sousCategorie == widget.subCategory;
              
              // Filtrer par texte de recherche
              bool textMatch = item.produit.toLowerCase().contains(value.toLowerCase()) ||
                              item.marque.toLowerCase().contains(value.toLowerCase());
              
              return categoryMatch && subCategoryMatch && textMatch;
            })
            .toList();
        _showSearchResults = true;
      } else {
        _showSearchResults = false;
        _searchResults.clear();
      }
    });
  }

  void _selectItem(CatalogueItem item) {
    // Fermer immédiatement les résultats de recherche
    setState(() {
      _searchController.clear();
      _showSearchResults = false;
      _searchResults.clear();
    });
    
    // Appeler la fonction de callback
    widget.onItemSelected(item);
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    
    return GestureDetector(
      onTap: () {
        // Fermer les résultats de recherche si on clique en dehors
        if (_showSearchResults) {
          setState(() {
            _showSearchResults = false;
            _searchResults.clear();
          });
        }
      },
      child: Stack(
        children: [
        // Barre de recherche
        GestureDetector(
          onTap: () {}, // Empêcher la propagation du tap
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: TextField(
            controller: _searchController,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: Colors.white.withOpacity(0.7),
              ),
              prefixIcon: Icon(
                Icons.search,
                color: Colors.white.withOpacity(0.7),
              ),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _searchController.clear();
                          _showSearchResults = false;
                          _searchResults.clear();
                        });
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            onChanged: _handleSearch,
            ),
          ),
        ),
        
        // Résultats de recherche en surimpression
        if (_showSearchResults && _searchResults.isNotEmpty)
          Positioned(
            top: 60, // Position juste en dessous de la barre de recherche
            left: 16,
            right: 16,
            child: GestureDetector(
              onTap: () {}, // Empêcher la propagation du tap
              child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF0A1128).withOpacity(0.95),
                  border: Border.all(color: Colors.white, width: 1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // En-tête des résultats
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            color: Colors.white.withOpacity(0.7),
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${_searchResults.length} résultat${_searchResults.length > 1 ? 's' : ''} trouvé${_searchResults.length > 1 ? 's' : ''}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.white.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    // Liste des résultats (limité à 5)
                    ..._searchResults.take(5).map((item) => InkWell(
                      onTap: () => _selectItem(item),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.white.withOpacity(0.1),
                              width: 1,
                            ),
                          ),
                        ),
                        child: Row(
                          children: [
                            // Icône du produit
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                _getCategoryIcon(item.categorie),
                                color: Colors.white.withOpacity(0.7),
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),
                            
                            // Informations du produit
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.produit,
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item.marque,
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Colors.white.withOpacity(0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            // Icône d'ajout
                            Icon(
                              Icons.add_circle_outline,
                              color: Colors.white.withOpacity(0.7),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'son':
        return Icons.volume_up;
      case 'vidéo':
        return Icons.videocam;
      case 'lumière':
        return Icons.lightbulb;
      case 'structure':
        return Icons.build;
      case 'électricité':
        return Icons.electrical_services;
      default:
        return Icons.inventory;
    }
  }
}
