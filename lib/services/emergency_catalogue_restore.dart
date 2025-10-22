import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import 'hive_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class EmergencyCatalogueRestore {
  static final _logger = Logger('EmergencyCatalogueRestore');

  /// Restaure immédiatement le catalogue depuis les assets JSON
  static Future<List<CatalogueItem>> emergencyRestore() async {
    try {
      _logger.info('🚨 EMERGENCY CATALOGUE RESTORE STARTING...');
      
      // 1. Vider complètement Hive
      await HiveService.clearAllData();
      _logger.info('✅ Cleared all Hive data');
      
      // 2. Recharger depuis JSON
      final items = await _loadAllFromJsonAssets();
      _logger.info('✅ Loaded ${items.length} items from JSON');
      
      // 3. Sauvegarder dans Hive
      final box = await HiveService.getCatalogueBox();
      for (final item in items) {
        await box.put(item.id, item);
      }
      _logger.info('✅ Saved ${items.length} items to Hive');
      
      // 4. Vérification
      final savedItems = box.values.toList();
      _logger.info('✅ Verification: ${savedItems.length} items in Hive');
      
      return savedItems;
    } catch (e, stackTrace) {
      _logger.severe('❌ EMERGENCY RESTORE FAILED', e, stackTrace);
      return [];
    }
  }

  /// Charge TOUS les items depuis les assets JSON
  static Future<List<CatalogueItem>> _loadAllFromJsonAssets() async {
    final List<CatalogueItem> allItems = [];
    
    try {
      // Charger le fichier principal
      final jsonString = await rootBundle.loadString('assets/corbeille/catalogue.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      _logger.info('📁 Loading from catalogue.json...');
      
      // Parcourir TOUTES les catégories
      for (final categoryEntry in jsonData.entries) {
        final String category = categoryEntry.key;
        _logger.info('📂 Processing category: $category');
        
        if (categoryEntry.value is Map<String, dynamic>) {
          final Map<String, dynamic> brands = categoryEntry.value;
          
          // Parcourir TOUTES les marques
          for (final brandEntry in brands.entries) {
            final String brand = brandEntry.key;
            _logger.info('🏷️ Processing brand: $brand');
            
            if (brandEntry.value is List) {
              final List<dynamic> products = brandEntry.value;
              
              // Parcourir TOUS les produits
              for (int i = 0; i < products.length; i++) {
                final Map<String, dynamic> product = products[i];
                
                final item = CatalogueItem(
                  id: '${category}_${brand}_${i}_${DateTime.now().millisecondsSinceEpoch}',
                  name: product['name'] ?? 'Unknown Product',
                  description: product['description'] ?? '',
                  categorie: category,
                  sousCategorie: product['sousCategorie'] ?? 'Default',
                  marque: brand,
                  produit: product['name'] ?? 'Unknown Product',
                  dimensions: product['dimensions'] ?? '',
                  poids: product['weight'] ?? '',
                  conso: product['power'] ?? '',
                );
                
                allItems.add(item);
              }
            }
          }
        }
      }
      
      _logger.info('✅ Loaded ${allItems.length} items from JSON');
      return allItems;
    } catch (e, stackTrace) {
      _logger.severe('❌ Error loading from JSON', e, stackTrace);
      return [];
    }
  }

  /// Vérifie l'état du catalogue
  static Future<Map<String, dynamic>> getDetailedStatus() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final items = box.values.toList();
      
      final categories = items.map((item) => item.categorie).toSet().toList();
      final brands = items.map((item) => item.marque).toSet().toList();
      
      final categoryCounts = <String, int>{};
      for (final item in items) {
        categoryCounts[item.categorie] = (categoryCounts[item.categorie] ?? 0) + 1;
      }
      
      return {
        'totalItems': items.length,
        'categories': categories,
        'brands': brands,
        'categoryCounts': categoryCounts,
        'isEmpty': items.isEmpty,
        'hiveBoxLength': box.length,
      };
    } catch (e) {
      return {
        'totalItems': 0,
        'categories': [],
        'brands': [],
        'categoryCounts': {},
        'isEmpty': true,
        'error': e.toString(),
      };
    }
  }
}
