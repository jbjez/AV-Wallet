import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/hive_service.dart';

class CatalogueStatsPage extends ConsumerStatefulWidget {
  const CatalogueStatsPage({super.key});

  @override
  ConsumerState<CatalogueStatsPage> createState() => _CatalogueStatsPageState();
}

class _CatalogueStatsPageState extends ConsumerState<CatalogueStatsPage> {
  Map<String, dynamic>? _stats;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final items = box.values.toList();
      
      // Analyser par catégorie
      final categories = <String, int>{};
      final brands = <String, int>{};
      final subCategories = <String, int>{};
      
      for (final item in items) {
        categories[item.categorie] = (categories[item.categorie] ?? 0) + 1;
        brands[item.marque] = (brands[item.marque] ?? 0) + 1;
        subCategories[item.sousCategorie] = (subCategories[item.sousCategorie] ?? 0) + 1;
      }
      
      setState(() {
        _stats = {
          'totalItems': items.length,
          'categories': categories,
          'brands': brands,
          'subCategories': subCategories,
          'isEmpty': items.isEmpty,
        };
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _stats = {
          'totalItems': 0,
          'categories': {},
          'brands': {},
          'subCategories': {},
          'isEmpty': true,
          'error': e.toString(),
        };
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Statistiques du Catalogue'),
        backgroundColor: const Color(0xFF0A1128),
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _stats == null
              ? const Center(child: Text('Erreur de chargement'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildStatCard(
                        'Total d\'éléments',
                        '${_stats!['totalItems']}',
                        Icons.inventory,
                        Colors.blue,
                      ),
                      const SizedBox(height: 16),
                      
                      if (_stats!['error'] != null)
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.red),
                          ),
                          child: Text(
                            'Erreur: ${_stats!['error']}',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                      
                      const SizedBox(height: 16),
                      _buildCategorySection(),
                      const SizedBox(height: 16),
                      _buildBrandSection(),
                      const SizedBox(height: 16),
                      _buildSubCategorySection(),
                    ],
                  ),
                ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection() {
    final categories = _stats!['categories'] as Map<String, int>;
    final sortedCategories = categories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Par catégorie',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedCategories.map((entry) => _buildListItem(
          entry.key,
          '${entry.value} éléments',
          Icons.category,
        )),
      ],
    );
  }

  Widget _buildBrandSection() {
    final brands = _stats!['brands'] as Map<String, int>;
    final sortedBrands = brands.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Par marque (Top 10)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedBrands.take(10).map((entry) => _buildListItem(
          entry.key,
          '${entry.value} éléments',
          Icons.business,
        )),
        if (brands.length > 10)
          _buildListItem(
            '... et ${brands.length - 10} autres marques',
            '',
            Icons.more_horiz,
          ),
      ],
    );
  }

  Widget _buildSubCategorySection() {
    final subCategories = _stats!['subCategories'] as Map<String, int>;
    final sortedSubCategories = subCategories.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Par sous-catégorie (Top 15)',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ...sortedSubCategories.take(15).map((entry) => _buildListItem(
          entry.key,
          '${entry.value} éléments',
          Icons.label,
        )),
        if (subCategories.length > 15)
          _buildListItem(
            '... et ${subCategories.length - 15} autres sous-catégories',
            '',
            Icons.more_horiz,
          ),
      ],
    );
  }

  Widget _buildListItem(String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 14),
            ),
          ),
          if (subtitle.isNotEmpty)
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
    );
  }
}
