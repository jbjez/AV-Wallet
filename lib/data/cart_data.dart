import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import 'package:collection/collection.dart';
import '../models/preset.dart';

class CartData {
  static final List<CartItem> items = [];

  static final List<CartItem> temporary = [];

  static final List<CartItem> selected = [];

  static final List<CartItem> saved = [];

  static List<CartItem> get current => items;

  static final List<Preset> presets = [];

  static int selectedPresetIndex = -1;

  static void addToCart(CatalogueItem item) {
    final existingItem = items.firstWhereOrNull(
      (cartItem) => cartItem.item.produit == item.produit,
    );
    if (existingItem != null) {
      existingItem.quantity += 1;
    } else {
      items.add(CartItem(item: item, quantity: 1));
    }
  }

  static void addItem(CatalogueItem item) {
    final existingItem = items.firstWhereOrNull(
      (cartItem) => cartItem.item.produit == item.produit,
    );
    if (existingItem != null) {
      existingItem.quantity += 1;
    } else {
      items.add(CartItem(item: item));
    }
  }

  static void removeItem(CatalogueItem item) {
    items.removeWhere((element) => element.item.produit == item.produit);
  }

  static void clearCart() {
    items.clear();
  }

  static int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }
}
