import 'package:hive/hive.dart';
import 'cart_item.dart';

part 'preset.g.dart';

// pour accéder à CartItem

@HiveType(typeId: 1)
class Preset extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String description;

  @HiveField(3)
  List<CartItem> items;

  @HiveField(4)
  DateTime createdAt;

  @HiveField(5)
  DateTime updatedAt;

  Preset({
    required this.id,
    required this.name,
    this.description = '',
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : items = items?.whereType<CartItem>().toList() ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  Preset copyWith({
    String? id,
    String? name,
    String? description,
    List<CartItem>? items,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Preset(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      items: items?.whereType<CartItem>().toList() ??
          List.from(this.items),
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'items': items.map((item) => item.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Preset.fromMap(Map<String, dynamic> map) {
    return Preset(
      id: map['id'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      items: (map['items'] as List)
          .map((item) => CartItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Preset &&
        other.id == id &&
        other.name == name &&
        other.description == description &&
        other.items.length == items.length &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        name.hashCode ^
        description.hashCode ^
        items.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
