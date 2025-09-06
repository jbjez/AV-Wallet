// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalogue_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CatalogueItemAdapter extends TypeAdapter<CatalogueItem> {
  @override
  final int typeId = 0;

  @override
  CatalogueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CatalogueItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      categorie: fields[3] as String,
      sousCategorie: fields[4] as String,
      marque: fields[5] as String,
      produit: fields[6] as String,
      taille: fields[21] as int?,
      dimensions: fields[7] as String,
      poids: fields[8] as String,
      conso: fields[9] as String,
      imageUrl: fields[10] as String?,
      resolutionDalle: fields[11] as String?,
      angle: fields[12] as String?,
      lux: fields[13] as String?,
      lumens: fields[14] as String?,
      definition: fields[15] as String?,
      dmxMax: fields[16] as String?,
      dmxMini: fields[17] as String?,
      resolution: fields[18] as String?,
      pitch: fields[19] as String?,
      optiques: (fields[20] as List?)?.cast<Lens>(),
      puissanceAdmissible: fields[22] as String?,
      impedanceNominale: fields[23] as String?,
      impedanceOhms: fields[24] as int?,
      powerRmsW: fields[25] as int?,
      powerProgramW: fields[26] as int?,
      powerPeakW: fields[27] as int?,
      maxVoltageVrms: fields[28] as double?,
    );
  }

  @override
  void write(BinaryWriter writer, CatalogueItem obj) {
    writer
      ..writeByte(29)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.categorie)
      ..writeByte(4)
      ..write(obj.sousCategorie)
      ..writeByte(5)
      ..write(obj.marque)
      ..writeByte(6)
      ..write(obj.produit)
      ..writeByte(21)
      ..write(obj.taille)
      ..writeByte(7)
      ..write(obj.dimensions)
      ..writeByte(8)
      ..write(obj.poids)
      ..writeByte(9)
      ..write(obj.conso)
      ..writeByte(10)
      ..write(obj.imageUrl)
      ..writeByte(11)
      ..write(obj.resolutionDalle)
      ..writeByte(12)
      ..write(obj.angle)
      ..writeByte(13)
      ..write(obj.lux)
      ..writeByte(14)
      ..write(obj.lumens)
      ..writeByte(15)
      ..write(obj.definition)
      ..writeByte(16)
      ..write(obj.dmxMax)
      ..writeByte(17)
      ..write(obj.dmxMini)
      ..writeByte(18)
      ..write(obj.resolution)
      ..writeByte(19)
      ..write(obj.pitch)
      ..writeByte(20)
      ..write(obj.optiques)
      ..writeByte(22)
      ..write(obj.puissanceAdmissible)
      ..writeByte(23)
      ..write(obj.impedanceNominale)
      ..writeByte(24)
      ..write(obj.impedanceOhms)
      ..writeByte(25)
      ..write(obj.powerRmsW)
      ..writeByte(26)
      ..write(obj.powerProgramW)
      ..writeByte(27)
      ..write(obj.powerPeakW)
      ..writeByte(28)
      ..write(obj.maxVoltageVrms);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CatalogueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
