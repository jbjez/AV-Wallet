import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/catalogue_provider.dart';
import '../models/catalogue_item.dart';
import '../widgets/custom_app_bar.dart';
import 'package:av_wallet/l10n/app_localizations.dart';

class DiversProductsPage extends ConsumerWidget {
  const DiversProductsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final loc = AppLocalizations.of(context)!;
    final catalogueItems = ref.watch(catalogueProvider);
    
    // Filtrer les produits de la catégorie Divers
    final diversItems = catalogueItems.where((item) => item.categorie == 'Divers').toList();
    
    // Grouper par sous-catégorie
    final backstageItems = diversItems.where((item) => item.sousCategorie == 'Backstage').toList();
    final traiteurItems = diversItems.where((item) => item.sousCategorie == 'Traiteur').toList();

    return Scaffold(
      appBar: CustomAppBar(
        pageIcon: Icons.more_horiz,
        title: 'Divers',
      ),
      body: Stack(
        children: [
          Opacity(
            opacity: 0.15,
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
            child: DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  const SizedBox(height: 6),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900]?.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const TabBar(
                      tabs: [
                        Tab(text: 'Backstage'),
                        Tab(text: 'Traiteur'),
                      ],
                      labelColor: Colors.white,
                      unselectedLabelColor: Colors.grey,
                      indicatorColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildProductList(backstageItems, 'Backstage'),
                        _buildProductList(traiteurItems, 'Traiteur'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductList(List<CatalogueItem> items, String category) {
    if (items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun produit dans $category',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les produits apparaîtront après la synchronisation',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: Colors.blueGrey[900]?.withOpacity(0.8),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            title: Text(
              item.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  item.description,
                  style: TextStyle(
                    color: Colors.grey[300],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildInfoChip('Marque', item.marque),
                    const SizedBox(width: 8),
                    _buildInfoChip('Dimensions', item.dimensions),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _buildInfoChip('Poids', item.poids),
                    const SizedBox(width: 8),
                    _buildInfoChip('Consommation', item.conso),
                  ],
                ),
              ],
            ),
            trailing: Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey[400],
              size: 16,
            ),
            onTap: () {
              // TODO: Ouvrir la page de détail du produit
            },
          ),
        );
      },
    );
  }

  Widget _buildInfoChip(String label, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blueGrey[800]?.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$label: $value',
        style: TextStyle(
          color: Colors.grey[300],
          fontSize: 12,
        ),
      ),
    );
  }
}


