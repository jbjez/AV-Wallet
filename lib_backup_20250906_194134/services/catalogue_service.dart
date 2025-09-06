import 'package:flutter/foundation.dart';
import '../models/catalogue_item.dart';
import 'hive_service.dart';

class CatalogueService extends ChangeNotifier {
  List<CatalogueItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<CatalogueItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadCatalogue() async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      _items = await HiveService.getAllCatalogueItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addItem(CatalogueItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await HiveService.addCatalogueItem(item);
      _items = await HiveService.getAllCatalogueItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateItem(CatalogueItem item) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await HiveService.updateCatalogueItem(item);
      _items = await HiveService.getAllCatalogueItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();

      await HiveService.deleteCatalogueItem(id);
      _items = await HiveService.getAllCatalogueItems();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
