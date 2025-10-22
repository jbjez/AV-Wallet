import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import '../services/hive_service.dart';

import '../services/catalogue_service.dart';
import '../services/son_replacement_service.dart';
import '../services/cleanup_son_service.dart';
import '../services/screen_migration_service.dart';
import '../services/catalogue_migration_service.dart';
import 'package:logging/logging.dart';

final logger = Logger('CatalogueProvider');

final catalogueProvider =
    StateNotifierProvider<CatalogueNotifier, List<CatalogueItem>>((ref) {
  final notifier = CatalogueNotifier();
  // Initialisation différée pour améliorer les performances
  Future.delayed(const Duration(milliseconds: 500), () {
    print('CatalogueProvider: Starting delayed initialization');
    notifier._initAsync();
  });
  return notifier;
});

final catalogueLoadingProvider = StateProvider<bool>((ref) => false);

final catalogueItemProvider =
    Provider.family<CatalogueItem?, String>((ref, id) {
  final items = ref.watch(catalogueProvider);
  try {
    return items.firstWhere((item) => item.id == id);
  } catch (e) {
    return null;
  }
});

final searchQueryProvider = StateProvider<String>((ref) => '');
final selectedCategoryProvider = StateProvider<String>((ref) => '');

final filteredCatalogueProvider = Provider<List<CatalogueItem>>((ref) {
  final items = ref.watch(catalogueProvider);
  final searchQuery = ref.watch(searchQueryProvider);
  final selectedCategory = ref.watch(selectedCategoryProvider);

  return items.where((item) {
    final matchesSearch = searchQuery.isEmpty ||
        item.produit.toLowerCase().contains(searchQuery.toLowerCase()) ||
        item.marque.toLowerCase().contains(searchQuery.toLowerCase()) ||
        (item.name.isNotEmpty &&
            item.name.toLowerCase().contains(searchQuery.toLowerCase())) ||
        (item.description.isNotEmpty &&
            item.description.toLowerCase().contains(searchQuery.toLowerCase()));

    final matchesCategory =
        selectedCategory.isEmpty || item.categorie == selectedCategory;

    return matchesSearch && matchesCategory;
  }).toList();
});

final catalogueServiceProvider = Provider<CatalogueService>((ref) {
  return CatalogueService();
});

class CatalogueNotifier extends StateNotifier<List<CatalogueItem>> {
  bool _isInitialized = false;
  bool _isInitializing = false;

  CatalogueNotifier() : super([]);

  // Initialisation asynchrone non-bloquante
  Future<void> _initAsync() async {
    if (_isInitializing || _isInitialized) {
      print('CatalogueNotifier: Skipping initialization - already initializing or initialized');
      return;
    }
    _isInitializing = true;
    
    try {
      print('CatalogueNotifier: Starting automatic initialization...');
      logger.info('CatalogueNotifier: Starting automatic initialization...');
      await loadCatalogue();
      
      // Remplacer les données SON existantes par les nouvelles
      await SonReplacementService.replaceSonData();
      
      // Migrer les données d'écrans vers Hive
      await ScreenMigrationService.migrateScreenData();
      
      // Migrer les nouvelles catégories (Lumière, Divers, etc.)
      await CatalogueMigrationService.migrateNewCategories();
      
      // Nettoyer les items JBL de la catégorie Son
      await CleanupSonService.checkAndCleanup();
      
      // Recharger le catalogue après la migration et le nettoyage
      await loadCatalogue();
      
      _isInitialized = true;
      print('CatalogueNotifier: Automatic initialization completed with ${state.length} items');
      logger.info('CatalogueNotifier: Automatic initialization completed with ${state.length} items');
    } catch (e) {
      print('CatalogueNotifier: Error during automatic initialization: $e');
      logger.severe('CatalogueNotifier: Error during automatic initialization', e);
      // En cas d'erreur, on laisse l'état vide
      state = [];
    } finally {
      _isInitializing = false;
    }
  }

  Future<void> loadCatalogue() async {
    // Éviter les appels multiples pendant l'initialisation
    if (_isInitializing) return;
    
    try {
      logger.info('Starting to load catalogue...');

      final box = await HiveService.getCatalogueBox();
      logger.info('Got catalogue box, contains ${box.length} items');

      // FORCER LA MIGRATION COMPLÈTE (reset total)
      logger.info('🚨 RESET COMPLET - MIGRATION FORCÉE...');
      
      // 1. Vider complètement la box
      await box.clear();
      logger.info('✅ Box Hive vidée');
      
      // 2. Migration complète depuis catalogue_data.dart
      await CatalogueMigrationService.migrateAllCategories();
      logger.info('✅ Migration complète effectuée');
      
      // 3. Migration des données SON
      await SonReplacementService.replaceSonData();
      logger.info('✅ Données SON migrées');
      
      // 4. Migration des données d'écrans
      await ScreenMigrationService.migrateScreenData();
      logger.info('✅ Données écrans migrées');
      
      // 5. Recharger le catalogue
      final allItems = box.values.toList();
      state = allItems;
      logger.info('✅ CATALOGUE MIGRÉ avec ${allItems.length} items');
      
      if (false) { // Désactivé pour forcer la migration
        logger.info('Catalogue has existing data, checking for new items...');
        // Charger les données existantes
        state = box.values.toList();
        
        // Vérifier et ajouter les nouveaux items du migration service
        await _syncWithMigrationService();
        
        logger.info(
            'Catalogue loaded and synced with ${state.length} items');
      }

      // Vérifier les catégories disponibles
      final categories = state.map((item) => item.categorie).toSet().toList();
      logger.info('Available categories: $categories');
    } catch (e, stackTrace) {
      logger.severe('Error loading catalogue', e, stackTrace);
      // Ne pas relancer l'erreur pour éviter de bloquer l'interface
      state = [];
    }
  }

  /// Synchronise le catalogue existant avec les nouveaux items du migration service
  Future<void> _syncWithMigrationService() async {
    try {
      logger.info('Starting catalogue synchronization...');
      
      // Récupérer tous les items du migration service
      final migrationItems = await _getMigrationServiceItems();
      logger.info('Migration service contains ${migrationItems.length} items');
      
      final box = await HiveService.getCatalogueBox();
      final existingIds = box.keys.toSet();
      
      int newItemsCount = 0;
      int updatedItemsCount = 0;
      
      // Vérifier chaque item du migration service
      for (final migrationItem in migrationItems) {
        if (!existingIds.contains(migrationItem.id)) {
          // Nouvel item : l'ajouter
          await box.put(migrationItem.id, migrationItem);
          newItemsCount++;
          logger.info('Added new item: ${migrationItem.id}');
        } else {
          // Item existant : vérifier s'il a été modifié
          final existingItem = box.get(migrationItem.id);
          if (existingItem != null && _hasItemChanged(existingItem, migrationItem)) {
            await box.put(migrationItem.id, migrationItem);
            updatedItemsCount++;
            logger.info('Updated existing item: ${migrationItem.id}');
          }
        }
      }
      
      // Mettre à jour l'état avec les nouvelles données
      state = box.values.toList();
      
      if (newItemsCount > 0 || updatedItemsCount > 0) {
        logger.info('Synchronization completed: $newItemsCount new items, $updatedItemsCount updated items');
      } else {
        logger.info('Synchronization completed: no changes detected');
      }
      
    } catch (e, stackTrace) {
      logger.severe('Error during catalogue synchronization', e, stackTrace);
      // Ne pas relancer l'erreur pour éviter de bloquer l'interface
    }
  }

  /// Récupère les items du migration service en lisant directement le fichier
  Future<List<CatalogueItem>> _getMigrationServiceItems() async {
    try {
      // Créer une liste d'items basée sur les données du migration service
      // Cette méthode simule ce que contient le migration service
      // Retourner une liste vide car tous les items sont maintenant dans catalogue_data.dart
      return [];
    } catch (e, stackTrace) {
      logger.severe('Error getting migration service items', e, stackTrace);
      return [];
    }
  }

  /// Vérifie si un item a été modifié en comparant ses propriétés clés
  bool _hasItemChanged(CatalogueItem existing, CatalogueItem migration) {
    return existing.produit != migration.produit ||
           existing.marque != migration.marque ||
           existing.dimensions != migration.dimensions ||
           existing.poids != migration.poids ||
           existing.conso != migration.conso ||
           existing.dmxMax != migration.dmxMax ||
           existing.dmxMini != migration.dmxMini ||
           existing.lumens != migration.lumens ||
           existing.resolution != migration.resolution;
  }

  Future<void> addItem(CatalogueItem item) async {
    try {
      logger.info('Adding item to catalogue: ${item.id}');
      final box = await HiveService.getCatalogueBox();
      await box.put(item.id, item);
      state = [...state, item];
      logger.info('Item added successfully');
    } catch (e, stackTrace) {
      logger.severe('Error adding item to catalogue', e, stackTrace);
      rethrow;
    }
  }

  Future<void> updateItem(CatalogueItem item) async {
    try {
      logger.info('Updating item in catalogue: ${item.id}');
      final box = await HiveService.getCatalogueBox();
      await box.put(item.id, item);
      state = state.map((i) => i.id == item.id ? item : i).toList();
      logger.info('Item updated successfully');
    } catch (e, stackTrace) {
      logger.severe('Error updating item in catalogue', e, stackTrace);
      rethrow;
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      logger.info('Deleting item from catalogue: $id');
      final box = await HiveService.getCatalogueBox();
      await box.delete(id);
      state = state.where((item) => item.id != id).toList();
      logger.info('Item deleted successfully');
    } catch (e, stackTrace) {
      logger.severe('Error deleting item from catalogue', e, stackTrace);
      rethrow;
    }
  }
}
