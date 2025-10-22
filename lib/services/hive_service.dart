import 'package:hive_flutter/hive_flutter.dart';
import 'package:logging/logging.dart';
import '../models/catalogue_item.dart';
import '../models/preset.dart';
import '../models/lens.dart';
import '../models/cart_item.dart';
import '../models/project.dart';
import '../models/project_calculation.dart';
import '../models/pdf_data.dart';
import 'catalogue_dmx_migration_service.dart';
import 'supabase_service.dart';

class HiveService {
  static final _logger = Logger('HiveService');
  static bool _isInitialized = false;

  /// Obtenir l'email de l'utilisateur connecté pour la persistance
  static String? _getCurrentUserEmail() {
    try {
      final user = SB.user;
      return user?.email;
    } catch (e) {
      _logger.warning('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  /// Générer un nom de box spécifique à l'utilisateur
  static String _getUserSpecificBoxName(String baseName) {
    final userEmail = _getCurrentUserEmail();
    if (userEmail != null) {
      // Utiliser l'email comme suffixe pour le nom de la box
      final emailHash = userEmail.hashCode.abs().toString();
      return '${baseName}_user_$emailHash';
    }
    // Si pas d'utilisateur connecté, utiliser une box générique
    return '${baseName}_guest';
  }

  static Future<void> initialize() async {
    if (_isInitialized) {
      _logger.info('Hive is already initialized');
      return;
    }

    try {
      _logger.info('Initializing Hive...');
      await Hive.initFlutter();

      // Nettoyer les adaptateurs existants si nécessaire
      try {
        if (Hive.isAdapterRegistered(0)) {
          _logger.info('CatalogueItemAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(CatalogueItemAdapter());
          _logger.info('CatalogueItemAdapter registered');
        }
        
        if (Hive.isAdapterRegistered(1)) {
          _logger.info('PresetAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(PresetAdapter());
          _logger.info('PresetAdapter registered');
        }
        
        if (Hive.isAdapterRegistered(2)) {
          _logger.info('LensAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(LensAdapter());
          _logger.info('LensAdapter registered');
        }
        
        if (Hive.isAdapterRegistered(3)) {
          _logger.info('CartItemAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(CartItemAdapter());
          _logger.info('CartItemAdapter registered');
        }
        
        if (Hive.isAdapterRegistered(2)) {
          _logger.info('ProjectAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(ProjectAdapter());
          _logger.info('ProjectAdapter registered');
        }
        
        if (Hive.isAdapterRegistered(10)) {
          _logger.info('PdfDataHiveAdapter already registered, skipping');
        } else {
          Hive.registerAdapter(PdfDataHiveAdapter());
          _logger.info('PdfDataHiveAdapter registered');
        }
      } catch (e) {
        _logger.warning('Error registering adapters: $e');
        // Continuer même si l'enregistrement échoue
      }

      // Ouvrir les boxes avec gestion d'erreur et migration
      try {
        await Future.wait([
          _openBoxWithMigration<CatalogueItem>('catalogue'),
          _openBoxWithMigration<Preset>('presets'),
          _openBoxWithMigration<Lens>('lenses'),
          _openBoxWithMigration<CartItem>('cart'),
          _openBoxWithMigration<Project>('projects'),
          _openBoxWithMigration<ProjectCalculation>('project_calculations'),
          _openBoxWithMigration<PdfDataHive>('pdf_storage'),
        ]);
      } catch (e) {
        _logger.warning('Error opening boxes, attempting to recover...', e);
        // En cas d'erreur, on essaie d'ouvrir les boxes une par une
        await _openBoxWithMigration<CatalogueItem>('catalogue');
        await _openBoxWithMigration<Preset>('presets');
        await _openBoxWithMigration<Lens>('lenses');
        await _openBoxWithMigration<CartItem>('cart');
        await _openBoxWithMigration<Project>('projects');
        await _openBoxWithMigration<ProjectCalculation>('project_calculations');
        await _openBoxWithMigration<PdfDataHive>('pdf_storage');
      }

      _isInitialized = true;
      _logger.info('Hive initialized successfully');
    } catch (e, stackTrace) {
      _logger.severe('Error initializing Hive', e, stackTrace);
      rethrow;
    }
  }

  static Future<Box<T>> _openBoxWithMigration<T>(String name) async {
    try {
      if (!Hive.isBoxOpen(name)) {
        final box = await Hive.openBox<T>(name);
        _logger.info('$name box opened successfully');

        // Migration des données si nécessaire
        if (name == 'presets') {
          await _migratePresets(box as Box<Preset>);
        }

        return box;
      } else {
        final box = Hive.box<T>(name);
        _logger.info('$name box already open');
        return box;
      }
    } catch (e) {
      _logger.warning('Error opening $name box, attempting to recover...', e);
      // En cas d'erreur, on essaie de supprimer et recréer la box
      if (Hive.isBoxOpen(name)) {
        await Hive.box(name).close();
      }
      await Hive.deleteBoxFromDisk(name);
      final box = await Hive.openBox<T>(name);
      _logger.info('$name box recovered successfully');
      return box;
    }
  }

  static Future<void> _migratePresets(Box<Preset> box) async {
    try {
      _logger.info('Starting presets migration...');
      final keys = box.keys.toList();

      for (final key in keys) {
        try {
          final preset = box.get(key);
          if (preset != null) {
            // Vérifier et corriger les items si nécessaire
            final validItems =
                preset.items.whereType<CartItem>().toList();
            if (validItems.length != preset.items.length) {
              _logger.warning('Found invalid items in preset $key, fixing...');
              final updatedPreset = preset.copyWith(items: validItems);
              await box.put(key, updatedPreset);
            }
          }
        } catch (e) {
          _logger.warning('Error migrating preset $key: $e');
          // Supprimer le preset corrompu
          await box.delete(key);
        }
      }
      _logger.info('Presets migration completed');
    } catch (e) {
      _logger.severe('Error during presets migration', e);
    }
  }

  static Future<Box<CatalogueItem>> getCatalogueBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      _logger.info('Getting catalogue box...');
      if (!Hive.isBoxOpen('catalogue')) {
        final box = await Hive.openBox<CatalogueItem>('catalogue');
        _logger.info('Catalogue box opened successfully');
        return box;
      } else {
        final box = Hive.box<CatalogueItem>('catalogue');
        _logger.info('Catalogue box already open');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting catalogue box', e, stackTrace);
      rethrow;
    }
  }

  static Future<Box<Preset>> getPresetsBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      _logger.info('Getting presets box...');
      if (!Hive.isBoxOpen('presets')) {
        final box = await Hive.openBox<Preset>('presets');
        _logger.info('Presets box opened successfully');
        return box;
      } else {
        final box = Hive.box<Preset>('presets');
        _logger.info('Presets box already open');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting presets box', e, stackTrace);
      rethrow;
    }
  }

  /// Obtenir la box des presets spécifique à l'utilisateur connecté
  static Future<Box<Preset>> getUserPresetsBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      final boxName = _getUserSpecificBoxName('presets');
      _logger.info('Getting user-specific presets box: $boxName');
      
      if (!Hive.isBoxOpen(boxName)) {
        final box = await Hive.openBox<Preset>(boxName);
        _logger.info('User presets box opened successfully: $boxName');
        return box;
      } else {
        final box = Hive.box<Preset>(boxName);
        _logger.info('User presets box already open: $boxName');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting user presets box', e, stackTrace);
      rethrow;
    }
  }

  static Future<Box<Project>> getProjectsBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      _logger.info('Getting projects box...');
      if (!Hive.isBoxOpen('projects')) {
        final box = await Hive.openBox<Project>('projects');
        _logger.info('Projects box opened successfully');
        return box;
      } else {
        final box = Hive.box<Project>('projects');
        _logger.info('Projects box already open');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting projects box', e, stackTrace);
      rethrow;
    }
  }

  /// Obtenir la box des projets spécifique à l'utilisateur connecté
  static Future<Box<Project>> getUserProjectsBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      final boxName = _getUserSpecificBoxName('projects');
      _logger.info('Getting user-specific projects box: $boxName');
      
      // S'assurer que l'adapter Project est enregistré
      if (!Hive.isAdapterRegistered(2)) {
        _logger.info('Registering ProjectAdapter for user-specific box');
        Hive.registerAdapter(ProjectAdapter());
      }
      
      if (!Hive.isBoxOpen(boxName)) {
        final box = await Hive.openBox<Project>(boxName);
        _logger.info('User projects box opened successfully: $boxName');
        return box;
      } else {
        final box = Hive.box<Project>(boxName);
        _logger.info('User projects box already open: $boxName');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting user projects box', e, stackTrace);
      rethrow;
    }
  }

  static Future<Box<Lens>> getLensesBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      _logger.info('Getting lenses box...');
      if (!Hive.isBoxOpen('lenses')) {
        final box = await Hive.openBox<Lens>('lenses');
        _logger.info('Lenses box opened successfully');
        return box;
      } else {
        final box = Hive.box<Lens>('lenses');
        _logger.info('Lenses box already open');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting lenses box', e, stackTrace);
      rethrow;
    }
  }

  static Future<Box<CartItem>> getCartBox() async {
    if (!_isInitialized) {
      await initialize();
    }
    try {
      _logger.info('Getting cart box...');
      if (!Hive.isBoxOpen('cart')) {
        final box = await Hive.openBox<CartItem>('cart');
        _logger.info('Cart box opened successfully');
        return box;
      } else {
        final box = Hive.box<CartItem>('cart');
        _logger.info('Cart box already open');
        return box;
      }
    } catch (e, stackTrace) {
      _logger.severe('Error getting cart box', e, stackTrace);
      rethrow;
    }
  }

  static Future<void> addCatalogueItem(CatalogueItem item) async {
    final box = await getCatalogueBox();
    await box.put(item.id, item);
  }

  static Future<void> addPreset(Preset preset) async {
    final box = await getPresetsBox();
    await box.put(preset.id, preset);
  }

  static Future<void> updateCatalogueItem(CatalogueItem item) async {
    final box = await getCatalogueBox();
    await box.put(item.id, item);
  }

  static Future<void> updatePreset(Preset preset) async {
    final box = await getPresetsBox();
    await box.put(preset.id, preset);
  }

  static Future<void> deleteCatalogueItem(String id) async {
    final box = await getCatalogueBox();
    await box.delete(id);
  }

  static Future<void> deletePreset(String id) async {
    final box = await getPresetsBox();
    await box.delete(id);
  }

  static Future<List<CatalogueItem>> getAllCatalogueItems() async {
    final box = await getCatalogueBox();
    return box.values.toList();
  }

  static Future<List<Preset>> getAllPresets() async {
    final box = await getPresetsBox();
    return box.values.toList();
  }

  static Future<CatalogueItem?> getCatalogueItem(String id) async {
    final box = await getCatalogueBox();
    return box.get(id);
  }

  static Future<Preset?> getPreset(String id) async {
    final box = await getPresetsBox();
    return box.get(id);
  }

  static Future<void> clearCatalogue() async {
    final box = await getCatalogueBox();
    await box.clear();
  }

  static Future<void> clearPresets() async {
    final box = await getPresetsBox();
    await box.clear();
  }

  static Future<void> addToCart(CartItem item) async {
    final box = await getCartBox();
    await box.put(item.item.produit, item);
  }

  static Future<void> updateCartItem(CartItem item) async {
    final box = await getCartBox();
    await box.put(item.item.produit, item);
  }

  static Future<void> removeFromCart(String id) async {
    final box = await getCartBox();
    await box.delete(id);
  }

  static Future<List<CartItem>> getAllCartItems() async {
    final box = await getCartBox();
    return box.values.toList();
  }

  static Future<CartItem?> getCartItem(String id) async {
    final box = await getCartBox();
    return box.get(id);
  }

  static Future<void> clearCart() async {
    final box = await getCartBox();
    await box.clear();
  }

  static Future<void> clearAllData() async {
    try {
      print('Clearing all Hive data...');
      await Hive.deleteBoxFromDisk('catalogue');
      await Hive.deleteBoxFromDisk('presets');
      await Hive.deleteBoxFromDisk('lenses');
      await Hive.deleteBoxFromDisk('cart');
      await Hive.deleteBoxFromDisk('projects');
      await Hive.deleteBoxFromDisk('project_calculations');
      print('All Hive data cleared successfully');
    } catch (e) {
      print('Error clearing Hive data: $e');
      rethrow;
    }
  }

  /// Initialise Hive et exécute les migrations nécessaires
  static Future<void> init() async {
    try {
      _logger.info('Initializing Hive with migrations...');
      
      // Initialiser Hive
      await initialize();
      
      // Exécuter la migration DMX si nécessaire
      final needsDmxMigration = await CatalogueDmxMigrationService.needsDmxMigration();
      if (needsDmxMigration) {
        _logger.info('DMX migration needed, executing...');
        await CatalogueDmxMigrationService.migrateDmxDataAndNewProducts();
        _logger.info('DMX migration completed');
      } else {
        _logger.info('No DMX migration needed');
      }
      
      _logger.info('Hive initialization with migrations completed');
    } catch (e, stackTrace) {
      _logger.severe('Error during Hive initialization with migrations', e, stackTrace);
      rethrow;
    }
  }
}
