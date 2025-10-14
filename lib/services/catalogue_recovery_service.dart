import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import 'hive_service.dart';
import 'dart:convert';
import 'package:flutter/services.dart';

class CatalogueRecoveryService {
  static final _logger = Logger('CatalogueRecoveryService');

  /// Force le rechargement complet du catalogue depuis Hive
  static Future<List<CatalogueItem>> forceReloadCatalogue() async {
    try {
      _logger.info('Starting catalogue recovery...');
      
      // Vider le cache Hive si nécessaire
      await HiveService.clearCatalogue();
      
      // Recharger depuis les données JSON
      await _loadFromJsonAssets();
      
      // Récupérer depuis Hive
      final box = await HiveService.getCatalogueBox();
      final items = box.values.toList();
      
      _logger.info('Catalogue recovery completed. Found ${items.length} items');
      return items;
    } catch (e, stackTrace) {
      _logger.severe('Error during catalogue recovery', e, stackTrace);
      return [];
    }
  }

  /// Charge les données depuis les assets JSON
  static Future<void> _loadFromJsonAssets() async {
    try {
      _logger.info('Loading catalogue from JSON assets...');
      
      // Charger le fichier JSON
      final jsonString = await rootBundle.loadString('assets/corbeille/catalogue.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      final List<CatalogueItem> items = [];
      
      // Parcourir les catégories
      for (final categoryEntry in jsonData.entries) {
        final String category = categoryEntry.key;
        
        if (categoryEntry.value is Map<String, dynamic>) {
          final Map<String, dynamic> brands = categoryEntry.value;
          
          // Parcourir les marques
          for (final brandEntry in brands.entries) {
            final String brand = brandEntry.key;
            
            if (brandEntry.value is List) {
              final List<dynamic> products = brandEntry.value;
              
              // Parcourir les produits
              for (int i = 0; i < products.length; i++) {
                final Map<String, dynamic> product = products[i];
                
                final item = CatalogueItem(
                  id: '${category}_${brand}_${i}',
                  name: product['name'] ?? 'Unknown',
                  description: product['description'] ?? '',
                  categorie: category,
                  sousCategorie: product['sousCategorie'] ?? 'Default',
                  marque: brand,
                  produit: product['name'] ?? 'Unknown',
                  dimensions: product['dimensions'] ?? '',
                  poids: product['weight'] ?? '',
                  conso: product['power'] ?? '',
                );
                
                items.add(item);
              }
            }
          }
        }
      }
      
      _logger.info('Loaded ${items.length} items from JSON');
      
      // Sauvegarder dans Hive
      final box = await HiveService.getCatalogueBox();
      for (final item in items) {
        await box.put(item.id, item);
      }
      
      _logger.info('Saved ${items.length} items to Hive');
    } catch (e, stackTrace) {
      _logger.severe('Error loading from JSON assets', e, stackTrace);
    }
  }

  /// Vérifie l'état du catalogue
  static Future<Map<String, dynamic>> getCatalogueStatus() async {
    try {
      final box = await HiveService.getCatalogueBox();
      final items = box.values.toList();
      
      final categories = items.map((item) => item.categorie).toSet().toList();
      final brands = items.map((item) => item.marque).toSet().toList();
      
      return {
        'totalItems': items.length,
        'categories': categories,
        'brands': brands,
        'isEmpty': items.isEmpty,
      };
    } catch (e) {
      return {
        'totalItems': 0,
        'categories': [],
        'brands': [],
        'isEmpty': true,
        'error': e.toString(),
      };
    }
  }
}
