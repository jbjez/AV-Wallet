// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'preset.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PresetAdapter extends TypeAdapter<Preset> {
  @override
  final int typeId = 1;

  @override
  Preset read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Preset(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      items: (fields[3] as List?)?.cast<CartItem>(),
      createdAt: fields[4] as DateTime?,
      updatedAt: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Preset obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.items)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.updatedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PresetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
