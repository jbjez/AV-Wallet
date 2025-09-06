import 'package:hive/hive.dart';
import 'catalogue_item.dart';

part 'cart_item.g.dart';

@HiveType(typeId: 4)
class CartItem {
  @HiveField(0)
  final CatalogueItem item;
  
  @HiveField(1)
  int quantity;

  CartItem({required this.item, this.quantity = 1});

  Map<String, dynamic> toMap() {
    return {
      'item': item.toMap(),
      'quantity': quantity,
    };
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      item: CatalogueItem.fromMap(map['item']),
      quantity: map['quantity'] ?? 1,
    );
  }

  CartItem copyWith({
    CatalogueItem? item,
    int? quantity,
  }) {
    return CartItem(
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }
}
