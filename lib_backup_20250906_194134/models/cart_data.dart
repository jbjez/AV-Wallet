import 'package:hive/hive.dart';
import 'catalogue_item.dart';

part 'cart_data.g.dart';

@HiveType(typeId: 3)
class CartData extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final CatalogueItem item;

  @HiveField(2)
  int quantity;

  CartData({
    required this.id,
    required this.item,
    this.quantity = 1,
  });

  CartData copyWith({
    String? id,
    CatalogueItem? item,
    int? quantity,
  }) {
    return CartData(
      id: id ?? this.id,
      item: item ?? this.item,
      quantity: quantity ?? this.quantity,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item.toMap(),
      'quantity': quantity,
    };
  }

  factory CartData.fromMap(Map<String, dynamic> map) {
    return CartData(
      id: map['id'] as String,
      item: CatalogueItem.fromMap(map['item'] as Map<String, dynamic>),
      quantity: map['quantity'] as int,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CartData && other.id == id && other.quantity == quantity;
  }

  @override
  int get hashCode => id.hashCode ^ quantity.hashCode;
}
