import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/catalogue_item.dart';
import '../models/cart_item.dart';
import '../services/hive_service.dart';

class CartNotifier extends StateNotifier<List<CartItem>> {
  CartNotifier() : super([]);

  Future<void> loadCart() async {
    final items = await HiveService.getAllCartItems();
    state = items;
  }

  Future<void> addItem(CatalogueItem item, {int quantity = 1}) async {
    final existingIndex =
        state.indexWhere((cartItem) => cartItem.item.id == item.id);
    if (existingIndex != -1) {
      final updated = state[existingIndex]
          .copyWith(quantity: state[existingIndex].quantity + quantity);
      state = [
        for (int i = 0; i < state.length; i++)
          if (i == existingIndex) updated else state[i],
      ];
      await HiveService.updateCartItem(updated);
    } else {
      final newCartItem = CartItem(item: item, quantity: quantity);
      state = [...state, newCartItem];
      await HiveService.addToCart(newCartItem);
    }
  }

  Future<void> removeItem(String itemId) async {
    state = state.where((cartItem) => cartItem.item.id != itemId).toList();
    await HiveService.removeFromCart(itemId);
  }

  Future<void> updateQuantity(String itemId, int quantity) async {
    state = [
      for (final cartItem in state)
        if (cartItem.item.id == itemId)
          cartItem.copyWith(quantity: quantity)
        else
          cartItem,
    ];
    final updated = state.firstWhere((cartItem) => cartItem.item.id == itemId);
    await HiveService.updateCartItem(updated);
  }

  Future<void> clear() async {
    state = [];
    await HiveService.clearCart();
  }
}

final cartProvider = StateNotifierProvider<CartNotifier, List<CartItem>>((ref) {
  final notifier = CartNotifier();
  notifier.loadCart();
  return notifier;
});
