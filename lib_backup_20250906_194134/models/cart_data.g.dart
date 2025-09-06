// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cart_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CartDataAdapter extends TypeAdapter<CartData> {
  @override
  final int typeId = 3;

  @override
  CartData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CartData(
      id: fields[0] as String,
      item: fields[1] as CatalogueItem,
      quantity: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, CartData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.item)
      ..writeByte(2)
      ..write(obj.quantity);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CartDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
